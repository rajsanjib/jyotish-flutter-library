import 'package:flutter_test/flutter_test.dart';
import 'package:jyotish/jyotish.dart';
import 'package:path/path.dart' as p;

void main() {
  setUpAll(() async {
    final jyotish = Jyotish();
    await jyotish.initialize(ephemerisPath: p.absolute('ephe'));
  });

  group('Native Implementations Tests', () {
    late VedicChart chart;
    late GeographicLocation location;

    setUp(() async {
      location = GeographicLocation(
        latitude: 28.6139,
        longitude: 77.2090,
        altitude: 216.0,
        timezone: 'Asia/Kolkata',
      );

      // We'll calculate a chart for a specific date
      chart = await Jyotish().calculateVedicChart(
        dateTime: DateTime(1990, 5, 15, 14, 30),
        location: location,
      );
    });

    test('1. Native Moolatrikona Dignity Detection', () {
      // Let's verify that isMoolatrikona works on planet info.
      for (final planetInfo in chart.planets.values) {
        if (planetInfo.dignity == PlanetaryDignity.moolaTrikona) {
          expect(planetInfo.isMoolatrikona, isTrue);
        } else {
          expect(planetInfo.isMoolatrikona, isFalse);
        }
      }
    });

    test('2. Vargottama & Neecha-Vargottama State Calculations', () {
      // Test that isVargottama and getVargottamaStatus run without issues
      for (final planet in Planet.traditionalPlanets) {
        final isVarg = chart.isVargottama(planet);
        final status = chart.getVargottamaStatus(planet);

        if (isVarg) {
          expect(status, isNot(equals(VargottamaStatus.none)));
        } else {
          expect(status, equals(VargottamaStatus.none));
        }
      }
    });

    test('3. Deep Exaltation & Debilitation Degrees', () {
      // Expose and test param uchha / param neecha orbs
      final sunInfo = chart.getPlanet(Planet.sun);
      expect(sunInfo, isNotNull);
      // Sun deep exaltation is at 10 degrees Aries (10° longitude).
      // Sun deep debilitation is at 10 degrees Libra (190° longitude).
      // For May 15 chart, Sun is in Taurus (~30.5°), so with fine orb it is neither.
      expect(sunInfo!.isDeepExalted(0.0001), isFalse);
      expect(sunInfo.isDeepDebilitated(0.0001), isFalse);
    });

    test('4. Planet-Specific Combustion (Kopa) Ranges', () {
      // Verify combustion distance limits
      final moonInfo = chart.getPlanet(Planet.moon);
      expect(moonInfo, isNotNull);
      expect(moonInfo!.combustionDistance, equals(12.0));

      final marsInfo = chart.getPlanet(Planet.mars);
      expect(marsInfo, isNotNull);
      expect(marsInfo!.combustionDistance, equals(17.0));

      final mercuryInfo = chart.getPlanet(Planet.mercury);
      expect(mercuryInfo, isNotNull);
      if (mercuryInfo!.isRetrograde) {
        expect(mercuryInfo.combustionDistance, equals(12.0));
      } else {
        expect(mercuryInfo.combustionDistance, equals(14.0));
      }
    });

    test('5. Simplified Compound Friendship Queries', () {
      // Test querying Panchadha Maitri directly on the chart
      final relation = chart.getCompoundRelationship(Planet.sun, Planet.moon);
      expect(relation, isA<CompoundRelationship>());

      // Self relationship should be greatFriend
      final selfRelation = chart.getCompoundRelationship(
        Planet.sun,
        Planet.sun,
      );
      expect(selfRelation, equals(CompoundRelationship.greatFriend));
    });

    test('6. Astrological House Classifications', () {
      // Check Kendra, Trikona, Dusthana, Upachaya classifications
      final house1 = chart.houses.getHouse(1);
      expect(house1.number, equals(1));
      expect(house1.isKendra, isTrue);
      expect(house1.isTrikona, isTrue);
      expect(house1.isDusthana, isFalse);
      expect(house1.isUpachaya, isFalse);

      final house6 = chart.houses.getHouse(6);
      expect(house6.isKendra, isFalse);
      expect(house6.isTrikona, isFalse);
      expect(house6.isDusthana, isTrue);
      expect(house6.isUpachaya, isTrue);

      final house12 = chart.houses.getHouse(12);
      expect(house12.isDusthana, isTrue);

      // Verify the list of all houses has length 12
      final individualHouses = chart.houses.individualHouses;
      expect(individualHouses.length, equals(12));
      for (var i = 0; i < 12; i++) {
        expect(individualHouses[i].number, equals(i + 1));
      }
    });

    test('7. True Solar Return Moment (calculateSolarReturn)', () async {
      final service = VarshapalService(Jyotish().ephemeris);
      final birthDateTime = DateTime(1990, 5, 15, 14, 30);
      final targetYear = 2026;

      final srMoment = await service.calculateSolarReturn(
        birthDateTime: birthDateTime,
        targetYear: targetYear,
        location: location,
      );

      expect(srMoment.year, equals(targetYear));
      expect(srMoment.month, equals(5));
      // Solar return should be close to May 15 (within 1-2 days)
      expect((srMoment.day - 15).abs() <= 2, isTrue);
    });

    test('8. Panchavargiya Bala calculations', () async {
      final service = VarshapalService(Jyotish().ephemeris);
      for (final planet in Planet.traditionalPlanets) {
        final result = service.calculatePanchavargiyaBala(planet, chart);
        expect(result.planet, equals(planet));
        expect(
          result.kshetraBala,
          anyOf(equals(30.0), equals(22.5), equals(15.0), equals(7.5)),
        );
        expect(
          result.haddaBala,
          anyOf(equals(15.0), equals(11.25), equals(7.5), equals(3.75)),
        );
        expect(
          result.drekkanaBala,
          anyOf(equals(10.0), equals(7.5), equals(5.0), equals(2.5)),
        );
        expect(
          result.navamsaBala,
          anyOf(equals(5.0), equals(3.75), equals(2.5), equals(1.25)),
        );
        expect(result.ucchaBala, greaterThanOrEqualTo(0.0));
        expect(result.ucchaBala, lessThanOrEqualTo(20.0));
        expect(
          result.totalBala,
          equals(
            result.kshetraBala +
                result.haddaBala +
                result.drekkanaBala +
                result.navamsaBala +
                result.ucchaBala,
          ),
        );
        expect(result.vishwaBala, equals(result.totalBala / 4.0));
      }
    });

    test(
      '9. Varshesh Determination and calculateVarshapal Integration',
      () async {
        final service = VarshapalService(Jyotish().ephemeris);
        final birthDateTime = DateTime(1990, 5, 15, 14, 30);
        final targetYear = 2026;

        final srMoment = await service.calculateSolarReturn(
          birthDateTime: birthDateTime,
          targetYear: targetYear,
          location: location,
        );

        final varshapal = await service.calculateVarshapal(
          birthDateTime: birthDateTime,
          varshaDateTime: srMoment,
          location: location,
        );

        expect(varshapal.varshaDateTime, equals(srMoment));
        expect(varshapal.varshaLord, isNotNull);
        expect(
          Planet.traditionalPlanets.contains(varshapal.varshaLord),
          isTrue,
        );
        expect(varshapal.panchavargiyaBala.keys.length, equals(7));
        for (final planet in Planet.traditionalPlanets) {
          expect(varshapal.panchavargiyaBala.containsKey(planet), isTrue);
        }
      },
    );

    test('10. Mudda Dasha scaling and duration checks', () async {
      final service = VarshapalService(Jyotish().ephemeris);
      final birthDateTime = DateTime(1990, 5, 15, 14, 30);
      final targetYear = 2026;

      final srMoment = await service.calculateSolarReturn(
        birthDateTime: birthDateTime,
        targetYear: targetYear,
        location: location,
      );

      final varshapal = await service.calculateVarshapal(
        birthDateTime: birthDateTime,
        varshaDateTime: srMoment,
        location: location,
      );

      final mudda = varshapal.muddaDasha;
      expect(mudda, isNotEmpty);
      expect(
        mudda.length,
        anyOf(equals(9), equals(10)),
      ); // Depending on if elapsed portion is 0 or not

      // The sum of durations of all periods should match the total year duration.
      final nextSrMoment = await service.calculateSolarReturn(
        birthDateTime: birthDateTime,
        targetYear: targetYear + 1,
        location: location,
      );
      final expectedYearDurationMs =
          nextSrMoment.difference(srMoment).inMilliseconds;

      var totalDurationMs = 0;
      for (final period in mudda) {
        totalDurationMs += period.duration.inMilliseconds;
      }

      // Check with a very small tolerance of 5ms due to roundings in individual period calculations.
      expect((totalDurationMs - expectedYearDurationMs).abs() <= 5, isTrue);
    });
  });
}
