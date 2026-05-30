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

      final prastara =
          jyotish.calculatePrastaraAshtakavarga(chart, Planet.jupiter);

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
          equals(report.gunaScores.varna +
              report.gunaScores.vashya +
              report.gunaScores.tara +
              report.gunaScores.yoni +
              report.gunaScores.grahaMaitri +
              report.gunaScores.gana +
              report.gunaScores.bhakoot +
              report.gunaScores.nadi));

      expect(
          report.compatibilityPercentage >= 0.0 &&
              report.compatibilityPercentage <= 100.0,
          isTrue);
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
      expect((json['gunaScores'] as Map<String, dynamic>)['nadi'],
          equals(report.gunaScores.nadi));
      expect(json['compatibilityPercentage'],
          equals(report.compatibilityPercentage));
    });
  });
}
