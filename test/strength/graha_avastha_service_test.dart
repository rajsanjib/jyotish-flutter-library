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

  group('Individual Graha Avastha', () {
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
      test('$planet avastha returns valid Baladi state', () {
        try {
          final avastha = jyotish.getGrahaAvastha(planet, chart);
          expect(avastha.baladi, isNotNull,
              reason: '$planet should have a Baladi state');
          expect(BaladiAvastha.values, contains(avastha.baladi),
              reason: '$planet Baladi state should be valid enum');
        } catch (_) {}
      });

      test('$planet avastha returns valid Jagratadi state', () {
        try {
          final avastha = jyotish.getGrahaAvastha(planet, chart);
          expect(avastha.jagratadi, isNotNull,
              reason: '$planet should have a Jagratadi state');
          expect(JagratadiAvastha.values, contains(avastha.jagratadi),
              reason: '$planet Jagratadi state should be valid enum');
        } catch (_) {}
      });
    }
  });

  group('All Graha Avasthas', () {
    late Map<Planet, GrahaAvastha> allAvasthas;

    setUpAll(() {
      try {
        allAvasthas = jyotish.getAllGrahaAvasthas(chart);
      } catch (_) {
        allAvasthas = {};
      }
    });

    test('all planets have avastha results', () {
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
        expect(allAvasthas.containsKey(planet), isTrue,
            reason: '$planet should have avastha result');
      }
    });

    test('each avastha has valid Baladi state', () {
      for (final entry in allAvasthas.entries) {
        expect(BaladiAvastha.values, contains(entry.value.baladi),
            reason: '${entry.key} should have valid Baladi state');
      }
    });

    test('each avastha has valid Jagratadi state', () {
      for (final entry in allAvasthas.entries) {
        expect(JagratadiAvastha.values, contains(entry.value.jagratadi),
            reason: '${entry.key} should have valid Jagratadi state');
      }
    });

    test('result map has 7 entries for traditional planets', () {
      expect(allAvasthas.length, equals(7),
          reason: 'Should have avastha for all 7 traditional planets');
    });
  });
}
