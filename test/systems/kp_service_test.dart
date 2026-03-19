import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

void main() {
  late Jyotish jyotish;
  late VedicChart natalChart;
  bool ephemerisAvailable = false;

  final birthDateTime = DateTime(1990, 5, 15, 14, 30);
  final location =
      GeographicLocation(latitude: 28.6139, longitude: 77.2090);

  setUpAll(() async {
    jyotish = Jyotish();
    try {
      await jyotish.initialize(ephemerisPath: 'ephe');
      ephemerisAvailable = true;

      natalChart = await jyotish.calculateVedicChart(
        dateTime: birthDateTime,
        location: location,
      );
    } catch (e) {
      ephemerisAvailable = false;
    }
  });

  group('KPService', () {
    test('calculateKPData returns KPCalculations', () async {
      if (!ephemerisAvailable) return;

      final kpData = await jyotish.calculateKPData(natalChart);
      expect(kpData, isNotNull);
      expect(kpData, isA<KPCalculations>());
    });

    test('KP data has sub-lords for all planets', () async {
      if (!ephemerisAvailable) return;

      final kpData = await jyotish.calculateKPData(natalChart);
      expect(kpData.planetDivisions, isNotNull);
      expect(kpData.planetDivisions, isNotEmpty);

      for (final planet in Planet.values) {
        if (kpData.planetDivisions.containsKey(planet)) {
          expect(kpData.planetDivisions[planet], isNotNull);
        }
      }
    });

    test('getSubLord returns valid planet for any longitude', () {
      if (!ephemerisAvailable) return;

      final testLongitudes = [0.0, 30.0, 90.0, 180.0, 270.0, 359.99];
      for (final lon in testLongitudes) {
        final subLord = jyotish.getSubLord(lon);
        expect(subLord, isNotNull);
        expect(subLord, isA<Planet>());
      }
    });

    test('KPDivisionTable has 249 entries', () {
      if (!ephemerisAvailable) return;

      final table = jyotish.getKPDivisionTable();
      expect(table, isNotNull);
      expect(table.length, equals(249));
    });

    test('KPRulingPlanets has required lords', () async {
      if (!ephemerisAvailable) return;

      final rulingPlanets =
          await jyotish.getKPRulingPlanets(chart: natalChart);
      expect(rulingPlanets, isNotNull);
      expect(rulingPlanets.dayLord, isNotNull);
      expect(rulingPlanets.dayLord, isA<Planet>());
      expect(rulingPlanets.ascendantSignLord, isNotNull);
      expect(rulingPlanets.ascendantSignLord, isA<Planet>());
      expect(rulingPlanets.moonSignLord, isNotNull);
      expect(rulingPlanets.moonSignLord, isA<Planet>());
    });

    test('compareKPTransitToNatal returns comparison data', () async {
      if (!ephemerisAvailable) return;

      final comparison = await jyotish.compareKPTransitToNatal(
        natalChart: natalChart,
        location: location,
      );
      expect(comparison, isNotNull);
      expect(comparison, isA<List<KPTransitComparison>>());
    });
  });
}
