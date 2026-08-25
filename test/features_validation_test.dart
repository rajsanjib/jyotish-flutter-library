import 'package:flutter_test/flutter_test.dart';
import 'package:jyotish/jyotish.dart';
import 'package:path/path.dart' as p;

void main() {
  setUpAll(() async {
    final jyotish = Jyotish();
    await jyotish.initialize(ephemerisPath: p.absolute('ephe'));
  });

  group('Astrological Features Validation Suite', () {
    late VedicChart chart;
    late GeographicLocation location;
    late DateTime birthDate;

    setUp(() async {
      location = GeographicLocation(
        latitude: 28.6139,
        longitude: 77.2090,
        altitude: 216.0,
        timezone: 'Asia/Kolkata',
      );
      birthDate = DateTime(1995, 8, 20, 10, 30);
      chart = await Jyotish().calculateVedicChart(
        dateTime: birthDate,
        location: location,
      );
    });

    test('1. Ashtakavarga Reductions & Shodhya Pinda calculations', () {
      final jyotish = Jyotish();
      final ashtakavargaService = jyotish.systems.ashtakavarga;

      // Compute raw Ashtakavarga
      final rawAshtakavarga = ashtakavargaService.calculateAshtakavarga(chart);
      expect(rawAshtakavarga, isNotNull);
      expect(rawAshtakavarga.bhinnashtakavarga.keys, isNotEmpty);

      // Compute Shodhya Pinda (this executes Trikona and Ekadhipati reductions)
      final shodhyaPinda =
          ashtakavargaService.calculateShodhyaPinda(rawAshtakavarga);

      expect(shodhyaPinda, isNotNull);
      expect(shodhyaPinda.trikonaReducedAshtakavarga, isNotNull);
      expect(shodhyaPinda.ekadhipatiReducedAshtakavarga, isNotNull);
      expect(shodhyaPinda.reducedPinda, isNotEmpty);

      // Verify that reduced bindus are less than or equal to raw bindus
      for (final planet in Planet.traditionalPlanets) {
        final rawBav = rawAshtakavarga.bhinnashtakavarga[planet]!;
        final reducedBav = shodhyaPinda
            .ekadhipatiReducedAshtakavarga.bhinnashtakavarga[planet]!;

        for (var sign = 0; sign < 12; sign++) {
          expect(reducedBav.bindus[sign] <= rawBav.bindus[sign], isTrue);
        }

        // Verify Pinda calculations are non-zero/valid
        final pindaResult = shodhyaPinda.reducedPinda[planet]!;
        expect(pindaResult.totalPinda >= 0.0, isTrue);
      }
    });

    test('2. KP 4-Level Significators Table validation', () async {
      final jyotish = Jyotish();

      // Calculate a KP-compatible chart (KP New Ayanamsa + Placidus houses)
      final kpChart = await jyotish.calculateVedicChart(
        dateTime: birthDate,
        location: location,
        flags: CalculationFlags.kp(),
        houseSystem: 'P',
      );

      // Calculate KP calculations
      final kpData = await jyotish.calculateKPData(kpChart);
      expect(kpData, isNotNull);
      expect(kpData.planetSignificators, isNotEmpty);

      // Verify significators (ABCD) exist for each traditional planet
      for (final planet in Planet.traditionalPlanets) {
        final significator = kpData.planetSignificators[planet];
        expect(significator, isNotNull);

        // Significators map lists must exist
        expect(significator!.aSignificators, isA<List<int>>());
        expect(significator.bSignificators, isA<List<int>>());
        expect(significator.cSignificators, isA<List<int>>());
        expect(significator.dSignificators, isA<List<int>>());

        // House values must be in valid range (1-12)
        for (final house in significator.allSignificators) {
          expect(house >= 1 && house <= 12, isTrue);
        }
      }
    });

    test('3. Vimshopaka Bala point scale validation', () async {
      final jyotish = Jyotish();

      // Compute Vimshopaka Bala for all traditional planets
      for (final planet in Planet.traditionalPlanets) {
        final score = jyotish.getVimshopakBala(planet, chart);

        // Vimshopaka Bala score must be in standard range (0-20 points)
        expect(score >= 0.0 && score <= 20.0, isTrue);
      }
    });

    test('4. SamvatInfo, Ayana, and Pravishte facade calculations', () async {
      final jyotish = Jyotish();

      // Test SamvatInfo
      final samvat = await jyotish.getSamvatInfo(
        dateTime: birthDate,
        location: location,
      );
      expect(samvat, isNotNull);
      expect(samvat.vikramSamvat > 2000, isTrue);
      expect(samvat.shakaSamvat > 1900, isTrue);
      expect(samvat.gujaratiSamvat > 2000, isTrue);
      expect(samvat.samvatsaraName.isNotEmpty, isTrue);
      expect(samvat.samvatsaraNumber >= 0 && samvat.samvatsaraNumber < 60, isTrue);

      // Test Ayana
      final ayana = await jyotish.getAyana(
        dateTime: birthDate,
        location: location,
      );
      expect(ayana, isNotNull);
      expect(ayana == Ayana.dakshinayana || ayana == Ayana.uttarayana, isTrue);

      // Test Pravishte
      final pravishte = await jyotish.getPravishte(
        dateTime: birthDate,
        location: location,
      );
      expect(pravishte, isNotNull);
      expect(pravishte.day >= 1 && pravishte.day <= 32, isTrue);
      expect(pravishte.monthName.isNotEmpty, isTrue);
    });
  });
}
