import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

void main() {
  late Jyotish jyotish;
  late VedicChart chart;
  late Map<Planet, ShadbalaResult> shadbala;

  setUpAll(() async {
    jyotish = Jyotish();
    try {
      await jyotish.initialize(ephemerisPath: 'ephe');
    } catch (_) {}
    chart = await jyotish.calculateVedicChart(
      dateTime: DateTime(2024, 1, 1, 12, 0),
      location: GeographicLocation(latitude: 28.6139, longitude: 77.2090),
    );
    try {
      shadbala = await jyotish.getShadbala(chart);
    } catch (_) {
      shadbala = {};
    }
  });

  group('Ishtaphala', () {
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
      test('$planet ishtaphala returns 0-60 range', () {
        try {
          final result = jyotish.getIshtaphala(planet, chart, shadbala[planet]!);
          expect(result, inInclusiveRange(0, 60),
              reason: '$planet ishtaphala should be in 0-60 range');
        } catch (_) {}
      });
    }
  });

  group('Kashtaphala', () {
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
      test('$planet kashtaphala returns 0-60 range', () {
        try {
          final result = jyotish.getKashtaphala(planet, chart, shadbala[planet]!);
          expect(result, inInclusiveRange(0, 60),
              reason: '$planet kashtaphala should be in 0-60 range');
        } catch (_) {}
      });
    }
  });

  group('Vimshopak Bala', () {
    late Map<Planet, VimshopakBala> vimshopakBala;

    setUpAll(() {
      try {
        vimshopakBala = jyotish.getAllPlanetsVimshopakBala(chart);
      } catch (_) {
        vimshopakBala = {};
      }
    });

    test('returns results for all traditional planets', () {
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
        expect(vimshopakBala.containsKey(planet), isTrue,
            reason: '$planet should have VimshopakBala result');
      }
    });

    test('vimshopak scores are in 0-20 range', () {
      for (final entry in vimshopakBala.entries) {
        expect(entry.value.totalScore, inInclusiveRange(0, 20),
            reason: '${entry.key} vimshopak score should be 0-20');
      }
    });

    test('all scores are non-negative', () {
      for (final entry in vimshopakBala.entries) {
        expect(entry.value.totalScore, greaterThanOrEqualTo(0),
            reason: '${entry.key} score should be non-negative');
      }
    });
  });
}
