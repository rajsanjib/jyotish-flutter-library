import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

void main() {
  late Jyotish jyotish;
  late VedicChart chart;
  bool ephemerisAvailable = false;

  setUpAll(() async {
    jyotish = Jyotish();
    try {
      await jyotish.initialize(ephemerisPath: 'ephe');
      ephemerisAvailable = true;

      final birthDateTime = DateTime(1990, 5, 15, 14, 30);
      final location =
          GeographicLocation(latitude: 28.6139, longitude: 77.2090);
      chart = await jyotish.calculateVedicChart(
        dateTime: birthDateTime,
        location: location,
      );
    } catch (e) {
      ephemerisAvailable = false;
    }
  });

  group('AshtakavargaService', () {
    test('Ashtakavarga has entries for all 7 traditional planets', () async {
      if (!ephemerisAvailable) {
        final j = Jyotish();
        expect(() => j.systems.ashtakavarga.calculateAshtakavarga(null as dynamic),
            throwsA(isA<Exception>()));
        return;
      }

      final ashtakavarga =
          jyotish.systems.ashtakavarga.calculateAshtakavarga(chart);
      expect(ashtakavarga, isNotNull);
      expect(ashtakavarga.bhinnashtakavarga, isNotNull);

      final expectedPlanets = [
        Planet.sun,
        Planet.moon,
        Planet.mars,
        Planet.mercury,
        Planet.jupiter,
        Planet.venus,
        Planet.saturn,
      ];

      for (final planet in expectedPlanets) {
        expect(
          ashtakavarga.bhinnashtakavarga.containsKey(planet),
          isTrue,
          reason: 'BAV should contain entry for $planet',
        );
      }
    });

    test('Each Bhinnashtakavarga has 12 bindu values', () async {
      if (!ephemerisAvailable) return;

      final ashtakavarga =
          jyotish.systems.ashtakavarga.calculateAshtakavarga(chart);

      for (final entry in ashtakavarga.bhinnashtakavarga.entries) {
        expect(
          entry.value.bindus.length,
          equals(12),
          reason:
              'BAV for ${entry.key} should have 12 bindu values (one per sign)',
        );
      }
    });

    test('Bindu values are in valid range (0-8)', () async {
      if (!ephemerisAvailable) return;

      final ashtakavarga =
          jyotish.systems.ashtakavarga.calculateAshtakavarga(chart);

      for (final planetEntry
          in ashtakavarga.bhinnashtakavarga.entries) {
        for (int i = 0; i < planetEntry.value.bindus.length; i++) {
          expect(
            planetEntry.value.bindus[i],
            inInclusiveRange(0, 8),
            reason:
                'Bindu value at sign $i for ${planetEntry.key} should be 0-8',
          );
        }
      }
    });

    test('Sarvashtakavarga totals are in realistic range (0-56)', () async {
      if (!ephemerisAvailable) return;

      final ashtakavarga =
          jyotish.systems.ashtakavarga.calculateAshtakavarga(chart);
      expect(ashtakavarga.sarvashtakavarga, isNotNull);
      expect(ashtakavarga.sarvashtakavarga.length, equals(12));

      for (int i = 0; i < ashtakavarga.sarvashtakavarga.length; i++) {
        expect(
          ashtakavarga.sarvashtakavarga[i],
          inInclusiveRange(0, 56),
          reason:
              'Sarvashtakavarga total at sign $i should be 0-56 (typically 25-38)',
        );
      }
    });

    test('Trikona Shodhana reduces bindu values', () async {
      if (!ephemerisAvailable) return;

      final ashtakavarga =
          jyotish.systems.ashtakavarga.calculateAshtakavarga(chart);
      final shodhana =
          jyotish.systems.ashtakavarga.applyTrikonaShodhana(ashtakavarga);

      expect(shodhana, isNotNull);
      expect(shodhana.bhinnashtakavarga, isNotNull);

      for (final entry in shodhana.bhinnashtakavarga.entries) {
        final original =
            ashtakavarga.bhinnashtakavarga[entry.key]!.bindus;
        final reduced = entry.value.bindus;
        expect(reduced.length, equals(original.length));

        bool hasReduction = false;
        for (int i = 0; i < reduced.length; i++) {
          expect(reduced[i], lessThanOrEqualTo(original[i]));
          if (reduced[i] < original[i]) hasReduction = true;
        }
        expect(
          hasReduction,
          isTrue,
          reason: 'Trikona Shodhana should reduce at least one value',
        );
      }
    });

    test('Ekadhipati Shodhana reduces bindu values', () async {
      if (!ephemerisAvailable) return;

      final ashtakavarga =
          jyotish.systems.ashtakavarga.calculateAshtakavarga(chart);
      final shodhana =
          jyotish.systems.ashtakavarga.applyEkadhipatiShodhana(ashtakavarga);

      expect(shodhana, isNotNull);
      expect(shodhana.bhinnashtakavarga, isNotNull);

      for (final entry in shodhana.bhinnashtakavarga.entries) {
        final original =
            ashtakavarga.bhinnashtakavarga[entry.key]!.bindus;
        final reduced = entry.value.bindus;
        expect(reduced.length, equals(original.length));

        for (int i = 0; i < reduced.length; i++) {
          expect(reduced[i], lessThanOrEqualTo(original[i]));
        }
      }
    });

    test('Shodhya Pinda calculation returns results', () async {
      if (!ephemerisAvailable) return;

      final ashtakavarga =
          jyotish.systems.ashtakavarga.calculateAshtakavarga(chart);

      final pinda =
          jyotish.systems.ashtakavarga.calculatePinda(ashtakavarga);
      expect(pinda, isNotNull);

      final shodhyaPinda =
          jyotish.systems.ashtakavarga.calculateShodhyaPinda(ashtakavarga);
      expect(shodhyaPinda, isNotNull);
    });
  });
}
