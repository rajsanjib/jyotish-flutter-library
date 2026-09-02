import 'package:flutter_test/flutter_test.dart';
import 'package:jyotish/jyotish.dart';
import 'package:path/path.dart' as p;

void main() {
  setUpAll(() async {
    final jyotish = Jyotish();
    await jyotish.initialize(ephemerisPath: p.absolute('ephe'));
  });

  group('Advanced Jyotish Feature Suite Tests', () {
    late VedicChart chart;
    late GeographicLocation location;

    setUp(() async {
      location = GeographicLocation(
        latitude: 28.6139,
        longitude: 77.2090,
        altitude: 216.0,
        timezone: 'Asia/Kolkata',
      );

      // A standard birth chart calculation
      chart = await Jyotish().calculateVedicChart(
        dateTime: DateTime(1990, 5, 15, 14, 30),
        location: location,
      );
    });

    test('1. Divisional Chart Variations', () {
      final jyotish = Jyotish();

      // D9 Navamsha calculation with customized parampara config
      const config = VargaConfiguration(
        horaMethod: HoraMethod.labhaMandooka,
        drekkanaMethod: DrekkanaMethod.somanatha,
        navamshaMethod: NavamshaMethod.krishnaMishra,
        dashamshaMethod: DashamshaMethod.behari,
      );

      final d9Chart = jyotish.getDivisionalChart(
        rashiChart: chart,
        type: DivisionalChartType.d9,
        config: config,
      );

      expect(d9Chart, isNotNull);
      expect(d9Chart.planets, isNotEmpty);
      expect(d9Chart.planets[Planet.sun], isNotNull);
    });

    test('2. Graha Yuddha (Planetary War) scan', () {
      final jyotish = Jyotish();

      // Check if Graha Yuddha evaluator runs without errors on chart
      final war = jyotish.checkGrahaYuddha(chart);

      // Even if there is no active war in this specific chart, the method should return null
      // or a valid WarDetails. Let's make sure the call executes successfully.
      if (war != null) {
        expect(war.planet1, isNotNull);
        expect(war.planet2, isNotNull);
        expect(war.winnerId, isNotNull);
      } else {
        expect(war, isNull);
      }
    });

    test('3. Prastara Ashtakavarga Grid calculation', () {
      final jyotish = Jyotish();

      final prastara = jyotish.calculatePrastaraAshtakavarga(
        chart,
        Planet.jupiter,
      );

      expect(prastara, isNotNull);
      expect(prastara.planet, equals(Planet.jupiter));
      expect(prastara.grid, isNotNull);
      expect(prastara.grid.length, equals(96)); // 8 contributors x 12 signs

      // Every element in the grid must be either 0 or 1
      for (final cell in prastara.grid) {
        expect(cell == 0 || cell == 1, isTrue);
      }
    });

    test('4. Special Mathematical Lagnas', () {
      final jyotish = Jyotish();
      final sunrise = DateTime(1990, 5, 15, 5, 25);

      final lagnas = jyotish.calculateSpecialLagnas(chart, sunrise);

      expect(lagnas, isNotNull);
      expect(lagnas.horaLagna, isA<double>());
      expect(lagnas.ghatiLagna, isA<double>());
      expect(lagnas.sreeLagna, isA<double>());

      // Degrees must be in valid 0-360 range
      expect(lagnas.horaLagna >= 0.0 && lagnas.horaLagna < 360.0, isTrue);
      expect(lagnas.ghatiLagna >= 0.0 && lagnas.ghatiLagna < 360.0, isTrue);
      expect(lagnas.sreeLagna >= 0.0 && lagnas.sreeLagna < 360.0, isTrue);
    });

    test('5. Marriage Compatibility Suite API', () async {
      final jyotish = Jyotish();

      // Create a second chart for the prospective partner
      final girlChart = await jyotish.calculateVedicChart(
        dateTime: DateTime(1992, 8, 20, 8, 15),
        location: location,
      );

      final report = jyotish.calculateCompatibilityReport(chart, girlChart);

      expect(report, isNotNull);
      expect(report.totalScore, isA<double>());
      expect(report.totalScore >= 0.0 && report.totalScore <= 36.0, isTrue);

      expect(report.gunaScores, isNotNull);
      expect(
        report.gunaScores.total,
        equals(
          report.gunaScores.varna +
              report.gunaScores.vashya +
              report.gunaScores.tara +
              report.gunaScores.yoni +
              report.gunaScores.grahaMaitri +
              report.gunaScores.gana +
              report.gunaScores.bhakoot +
              report.gunaScores.nadi,
        ),
      );

      expect(
        report.compatibilityPercentage >= 0.0 &&
            report.compatibilityPercentage <= 100.0,
        isTrue,
      );
      expect(report.hasNadiDosha, isA<bool>());
      expect(report.hasBhakootDosha, isA<bool>());
      expect(report.boyManglik, isA<bool>());
      expect(report.girlManglik, isA<bool>());
      expect(report.boyManglikCancellations, isA<List<String>>());
      expect(report.girlManglikCancellations, isA<List<String>>());
      expect(report.analysis, isA<List<String>>());

      // Test JSON serialization
      final json = report.toJson();
      expect(json['totalScore'], equals(report.totalScore));
      expect(
        (json['gunaScores'] as Map<String, dynamic>)['nadi'],
        equals(report.gunaScores.nadi),
      );
      expect(
        json['compatibilityPercentage'],
        equals(report.compatibilityPercentage),
      );
    });

    test('6. Eclipse Prediction (Lunar & Solar)', () async {
      final jyotish = Jyotish();
      final startDate = DateTime(2026, 1, 1);

      // Lunar prediction
      final lunar = await jyotish.eclipse.predictLunarEclipses(
        startDate: startDate,
        count: 2,
      );
      expect(lunar, isNotEmpty);
      expect(lunar.length, equals(2));
      for (final e in lunar) {
        expect(e.date.isAfter(startDate), isTrue);
        expect(
          e.eclipseType.name.contains('Lunar') ||
              e.eclipseType == EclipseType.lunar,
          isTrue,
        );
      }

      // Solar prediction (global)
      final solar = await jyotish.eclipse.predictSolarEclipses(
        startDate: startDate,
        count: 2,
      );
      expect(solar, isNotEmpty);
      expect(solar.length, equals(2));
      for (final e in solar) {
        expect(e.date.isAfter(startDate), isTrue);
        expect(
          e.eclipseType.name.contains('Solar') ||
              e.eclipseType == EclipseType.solar,
          isTrue,
        );
      }

      // Merged prediction
      final merged = await jyotish.eclipse.predictEclipses(
        startDate: startDate,
        count: 4,
        type: EclipseType.any,
      );
      expect(merged.length, equals(4));
      // Assert chronological order
      for (var i = 0; i < merged.length - 1; i++) {
        expect(
          merged[i].date.isBefore(merged[i + 1].date) ||
              merged[i].date.isAtSameMomentAs(merged[i + 1].date),
          isTrue,
        );
      }
    });

    test('7. Vedic Time Conversion', () async {
      final jyotish = Jyotish();
      final now = DateTime(2026, 5, 31, 12, 0); // Noon

      final vt = await VedicTime.calculate(
        time: now,
        location: location,
        getSunriseSunset: jyotish.getSunriseSunset,
      );

      expect(vt, isNotNull);
      expect(vt.ghati >= 0 && vt.ghati < 60, isTrue);
      expect(vt.vighati >= 0 && vt.vighati < 60, isTrue);
      expect(vt.lipta >= 0 && vt.lipta < 60, isTrue);
      expect(vt.prana >= 0 && vt.prana < 6, isTrue);
      expect(vt.totalGhatis >= 0.0 && vt.totalGhatis <= 60.0, isTrue);
      expect(vt.format(), isNotEmpty);
      expect(vt.toString(), isNotEmpty);

      // Verify conversion back to Gregorian DateTime
      final convertedBack = vt.toDateTime();
      expect(
          convertedBack.difference(now.toLocal()).inSeconds.abs() <= 5, isTrue);
    });
  });
}
