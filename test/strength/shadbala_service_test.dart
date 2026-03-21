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

  group('Shadbala Service', () {
    test('all 7 traditional planets have Shadbala results', () {
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
        expect(shadbala.containsKey(planet), isTrue,
            reason: '$planet should have Shadbala result');
      }
    });

    test('each of the 6 bala components is non-negative', () {
      for (final entry in shadbala.entries) {
        final result = entry.value;
        expect(result.sthanaBala, greaterThanOrEqualTo(0),
            reason: '${entry.key} sthanaBala should be non-negative');
        expect(result.digBala, greaterThanOrEqualTo(0),
            reason: '${entry.key} digBala should be non-negative');
        expect(result.kalaBala, greaterThanOrEqualTo(0),
            reason: '${entry.key} kalaBala should be non-negative');
        expect(result.chestaBala, greaterThanOrEqualTo(0),
            reason: '${entry.key} chestaBala should be non-negative');
        expect(result.naisargikaBala, greaterThanOrEqualTo(0),
            reason: '${entry.key} naisargikaBala should be non-negative');
        expect(result.drikBala, greaterThanOrEqualTo(0),
            reason: '${entry.key} drikBala should be non-negative');
      }
    });

    test('totalBala equals sum of all 6 components', () {
      for (final entry in shadbala.entries) {
        final result = entry.value;
        final sum = result.sthanaBala +
            result.digBala +
            result.kalaBala +
            result.chestaBala +
            result.naisargikaBala +
            result.drikBala;
        expect(result.totalBala, closeTo(sum, 0.001),
            reason: '${entry.key} totalBala should equal sum of 6 components');
      }
    });

    test('strengthCategory is valid enum value', () {
      const validCategories = ShadbalaStrength.values;
      for (final entry in shadbala.entries) {
        expect(validCategories, contains(entry.value.strengthCategory),
            reason: '${entry.key} strengthCategory should be valid enum');
      }
    });

    test('ishtaPhala and kashtaPhala are in valid range (0-60)', () {
      for (final entry in shadbala.entries) {
        final result = entry.value;
        expect(result.ishtaPhala, inInclusiveRange(0, 60),
            reason: '${entry.key} ishtaPhala should be 0-60');
        expect(result.kashtaPhala, inInclusiveRange(0, 60),
            reason: '${entry.key} kashtaPhala should be 0-60');
      }
    });
  });
}
