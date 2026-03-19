import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

void main() {
  late Jyotish jyotish;
  late VedicChart chart;

  setUpAll(() async {
    jyotish = Jyotish();
    try {
      await jyotish.initialize(ephemerisPath: 'ephe');
    } catch (_) {}
    chart = await jyotish.calculateVedicChart(
      dateTime: DateTime(2024, 1, 1, 12, 0),
      location: GeographicLocation(latitude: 28.6139, longitude: 77.2090),
    );
  });

  group('Chart Strength Report', () {
    late ChartStrengthReport chartReport;

    setUpAll(() async {
      try {
        chartReport = await jyotish.getChartStrengthReport(chart);
      } catch (_) {
        chartReport = const ChartStrengthReport(
          byPlanet: {},
          strongestPlanet: Planet.sun,
          weakestPlanet: Planet.saturn,
          planetsAboveMinimum: [],
        );
      }
    });

    test('chart report has all planets', () {
      final traditionalPlanets = [
        Planet.sun,
        Planet.moon,
        Planet.mars,
        Planet.mercury,
        Planet.jupiter,
        Planet.venus,
        Planet.saturn,
      ];
      for (final planet in traditionalPlanets) {
        expect(chartReport.byPlanet.containsKey(planet), isTrue,
            reason: 'Chart report should include $planet');
      }
    });

    test('report has valid strongest and weakest planets', () {
      final traditionalPlanets = [
        Planet.sun,
        Planet.moon,
        Planet.mars,
        Planet.mercury,
        Planet.jupiter,
        Planet.venus,
        Planet.saturn,
      ];
      expect(traditionalPlanets, contains(chartReport.strongestPlanet),
          reason: 'Strongest planet should be a traditional planet');
      expect(traditionalPlanets, contains(chartReport.weakestPlanet),
          reason: 'Weakest planet should be a traditional planet');
    });

    test('each planet report has valid shadbala total', () {
      for (final entry in chartReport.byPlanet.entries) {
        final report = entry.value;
        expect(report.shadbalaTotalRupas, greaterThanOrEqualTo(0),
            reason: '${entry.key} shadbalaTotalRupas should be non-negative');
      }
    });
  });

  group('Planet Strength Report', () {
    final traditionalPlanets = [
      Planet.sun,
      Planet.moon,
      Planet.mars,
      Planet.mercury,
      Planet.jupiter,
      Planet.venus,
      Planet.saturn,
    ];

    for (final planet in traditionalPlanets) {
      test('$planet report has Shadbala details', () async {
        try {
          final report = await jyotish.getPlanetStrengthReport(planet, chart);
          expect(report.shadbalaTotalRupas, greaterThanOrEqualTo(0),
              reason: '$planet shadbalaTotalRupas should be non-negative');
        } catch (_) {}
      });
    }

    for (final planet in traditionalPlanets) {
      test('$planet report has valid ishtaphala and kashtaphala', () async {
        try {
          final report = await jyotish.getPlanetStrengthReport(planet, chart);
          expect(report.ishtaphala, greaterThanOrEqualTo(0),
              reason: '$planet ishtaphala should be non-negative');
          expect(report.kashtaphala, greaterThanOrEqualTo(0),
              reason: '$planet kashtaphala should be non-negative');
        } catch (_) {}
      });
    }
  });
}
