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
      if (sunInfo != null) {
        // Sun deep exaltation is at 10 degrees Aries.
        expect(sunInfo.isDeepExalted(360.0), isTrue);
        expect(sunInfo.isDeepDebilitated(360.0), isTrue);
        expect(sunInfo.isDeepExalted(0.0001), isFalse); // Sun in mid-May is in Taurus, not Aries 10
      }
    });

    test('4. Planet-Specific Combustion (Kopa) Ranges', () {
      // Verify combustion distance limits
      final moonInfo = chart.getPlanet(Planet.moon);
      if (moonInfo != null) {
        expect(moonInfo.combustionDistance, equals(12.0));
      }

      final marsInfo = chart.getPlanet(Planet.mars);
      if (marsInfo != null) {
        expect(marsInfo.combustionDistance, equals(17.0));
      }

      final mercuryInfo = chart.getPlanet(Planet.mercury);
      if (mercuryInfo != null) {
        if (mercuryInfo.isRetrograde) {
          expect(mercuryInfo.combustionDistance, equals(12.0));
        } else {
          expect(mercuryInfo.combustionDistance, equals(14.0));
        }
      }
    });

    test('5. Simplified Compound Friendship Queries', () {
      // Test querying Panchadha Maitri directly on the chart
      final relation = chart.getCompoundRelationship(Planet.sun, Planet.moon);
      expect(relation, isA<CompoundRelationship>());
      
      // Self relationship should be greatFriend
      final selfRelation = chart.getCompoundRelationship(Planet.sun, Planet.sun);
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
  });
}
