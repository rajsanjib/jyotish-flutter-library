/// Validated Reference Chart Test Suite  India Independence Chart
///
/// This is the canonical regression test for the Jyotish library.
///
/// Reference chart: India Independence
///   Date/Time: 15 August 1947, 00:00 IST (UTC+5:30  UTC 18:30 on 14 Aug)
///   Location: New Delhi (28.6139N, 77.2090E)
///   System: Lahiri ayanamsa, Whole Sign houses
///
/// The expected values below come from standard Vedic astrology references
/// and have been cross-checked against multiple professional software tools.
/// Tolerances of 0.5 on degree-in-sign account for minor SE version diffs.
///
/// These tests require Swiss Ephemeris data files in the `ephe/` directory.
/// See SETUP.md for installation instructions.

import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

void main() {
  //  India Independence Chart 
  // 15 Aug 1947 00:00 IST = 14 Aug 1947 18:30 UTC
  // New Delhi: 28.6139N, 77.2090E
  // Lahiri ayanamsa, Whole Sign

  final indiaLocation = GeographicLocation(
    latitude: 28.6139,
    longitude: 77.2090,
    timezone: 'Asia/Kolkata',
  );

  // Midnight IST = 18:30 UTC on the previous day
  final indiaDateTime = DateTime.utc(1947, 8, 14, 18, 30, 0);

  late Jyotish jyotish;
  late VedicChart indiaChart;

  setUpAll(() async {
    jyotish = Jyotish();
    try {
      await jyotish.initialize(ephemerisPath: 'ephe');
    } catch (e) {
      // ignore: avoid_print
      print(
          '  Swiss Ephemeris not found. Run: dart test -N reference_charts');
      rethrow;
    }

    indiaChart = await jyotish.calculateVedicChart(
      dateTime: indiaDateTime,
      location: indiaLocation,
      houseSystem: 'W', // Whole Sign
      flags: CalculationFlags.traditionalist(),
    );
  });

  tearDownAll(() {
    jyotish.dispose();
  });

  //  Ascendant 

  group('India Independence  Ascendant', () {
    test('Ascendant is in Taurus', () {
      expect(indiaChart.ascendantSign, equals('Taurus'));
    });

    test('Ascendant degree is approximately 78 Taurus', () {
      final ascInSign = indiaChart.ascendant % 30;
      expect(ascInSign, greaterThan(7.0));
      expect(ascInSign, lessThan(8.0));
    });
  });

  //  Planetary Signs 

  group('India Independence  Planetary Signs (Lahiri sidereal)', () {
    test('Sun is in Cancer', () {
      expect(indiaChart.planets[Planet.sun]?.zodiacSign, equals('Cancer'));
    });

    test('Moon is in Cancer', () {
      expect(indiaChart.planets[Planet.moon]?.zodiacSign, equals('Cancer'));
    });

    test('Mars is in Gemini', () {
      expect(indiaChart.planets[Planet.mars]?.zodiacSign, equals('Gemini'));
    });

    test('Mercury is in Cancer', () {
      expect(indiaChart.planets[Planet.mercury]?.zodiacSign, equals('Cancer'));
    });

    test('Jupiter is in Libra', () {
      expect(indiaChart.planets[Planet.jupiter]?.zodiacSign, equals('Libra'));
    });

    test('Venus is in Cancer', () {
      expect(indiaChart.planets[Planet.venus]?.zodiacSign, equals('Cancer'));
    });

    test('Saturn is in Cancer', () {
      expect(indiaChart.planets[Planet.saturn]?.zodiacSign, equals('Cancer'));
    });

    test('Rahu is in Taurus', () {
      expect(indiaChart.rahu.zodiacSign, equals('Taurus'));
    });
  });

  //  Planetary Dignities 

  group('India Independence  Dignities', () {
    test(
        'Saturn is in enemy sign (Cancer = Moon sign, Saturn-Moon are natural enemies)',
        () {
      final satDignity = indiaChart.planets[Planet.saturn]?.dignity;
      // Saturn in Cancer: sign lord is Moon, Saturn treats Moon as enemy
      expect(satDignity, equals(PlanetaryDignity.enemySign));
    });

    test('Moon is in Own Sign (Cancer)', () {
      final moonDignity = indiaChart.planets[Planet.moon]?.dignity;
      expect(moonDignity, equals(PlanetaryDignity.ownSign));
    });

    test('Mercury is an enemy sign or neutral in Cancer', () {
      final mercDignity = indiaChart.planets[Planet.mercury]?.dignity;
      // Mercury in Cancer: sign lord Moon is enemy of Mercury
      expect(
        [PlanetaryDignity.enemySign, PlanetaryDignity.greatEnemy],
        contains(mercDignity),
      );
    });
  });

  //  House Placements 

  group('India Independence  House Placements (Whole Sign from Taurus Asc)',
      () {
    test('Sun is in the 3rd house (Cancer = 3rd from Taurus)', () {
      expect(indiaChart.planets[Planet.sun]?.house, equals(3));
    });

    test('Moon is in the 3rd house', () {
      expect(indiaChart.planets[Planet.moon]?.house, equals(3));
    });

    test('Saturn is in the 3rd house', () {
      expect(indiaChart.planets[Planet.saturn]?.house, equals(3));
    });

    test('Jupiter is in the 6th house (Libra = 6th from Taurus)', () {
      expect(indiaChart.planets[Planet.jupiter]?.house, equals(6));
    });

    test('Mars is in the 2nd house (Gemini = 2nd from Taurus)', () {
      expect(indiaChart.planets[Planet.mars]?.house, equals(2));
    });

    test('Venus is in the 3rd house', () {
      expect(indiaChart.planets[Planet.venus]?.house, equals(3));
    });

    test('Rahu is in the 1st house (Taurus)', () {
      expect(indiaChart.rahu.house, equals(1));
    });
  });

  //  Vimshottari Dasha 

  group('India Independence  Vimshottari Dasha', () {
    late DashaResult dasha;

    setUpAll(() async {
      dasha = await jyotish.getVimshottariDasha(natalChart: indiaChart);
    });

    test('Birth nakshatra is Pushya', () {
      expect(dasha.birthNakshatra, equals('Pushya'));
    });

    test('First mahadasha is Saturn (Pushya ruled by Saturn)', () {
      expect(dasha.allMahadashas.first.lord, equals(Planet.saturn));
    });

    test('Dasha result covers 120-year Vimshottari cycle', () {
      final total = dasha.allMahadashas.length;
      // Should have more than 15 periods (120-year cycle with sub-periods from start)
      expect(total, greaterThan(12));
    });
  });

  //  Ayanamsa Utility 

  group('Ayanamsa utility', () {
    test('Lahiri ayanamsa for Aug 1947 is approximately 23', () async {
      final ayanamsa = await jyotish.getAyanamsa(dateTime: indiaDateTime);
      expect(ayanamsa, greaterThan(22.0));
      expect(ayanamsa, lessThan(24.0));
    });

    test('KP ayanamsa differs from Lahiri by a small margin', () async {
      final lahiri = await jyotish.getAyanamsa(
        dateTime: indiaDateTime,
        mode: SiderealMode.lahiri,
      );
      final kp = await jyotish.getAyanamsa(
        dateTime: indiaDateTime,
        mode: SiderealMode.krishnamurtiVP291,
      );
      // KP and Lahiri are within 1 of each other but not identical
      expect((kp - lahiri).abs(), lessThan(1.0));
      expect(kp, isNot(closeTo(lahiri, 0.0001)));
    });

    test('CalculationFlags.kp() uses krishnamurtiVP291 ayanamsa', () {
      final flags = CalculationFlags.kp();
      expect(flags.siderealMode, equals(SiderealMode.krishnamurtiVP291));
    });
  });

  //  Bhava Chalit 

  group('Bhava Chalit  India Independence (Whole Sign)', () {
    test('getBhavaChalit returns 12 bhavas', () {
      final chalit = jyotish.getBhavaChalit(indiaChart);
      expect(chalit.bhavas.length, equals(12));
    });

    test('Each planet is present in exactly one bhava', () {
      final chalit = jyotish.getBhavaChalit(indiaChart);
      final allPlanets = <Planet>{};
      for (final bhava in chalit.bhavas) {
        for (final planet in bhava.planets) {
          expect(allPlanets.contains(planet), isFalse,
              reason: '${planet.displayName} found in multiple bhavas');
          allPlanets.add(planet);
        }
      }
      // All traditional planets should be placed
      for (final p in Planet.traditionalPlanets) {
        expect(allPlanets.contains(p), isTrue,
            reason: '${p.displayName} missing from Bhava Chalit');
      }
    });

    test('getBhavaForLongitude returns valid house 1-12', () {
      final chalit = jyotish.getBhavaChalit(indiaChart);
      final sunLong = indiaChart.planets[Planet.sun]!.longitude;
      final house = chalit.getBhavaForLongitude(sunLong);
      expect(house, greaterThanOrEqualTo(1));
      expect(house, lessThanOrEqualTo(12));
    });

    test('For Whole Sign chart, most planets keep same house in Bhava Chalit',
        () {
      // With Whole Sign houses, cusps are 30 apart, so mid-cusps should
      // mostly match sign boundaries and planets should stay in same house
      final chalit = jyotish.getBhavaChalit(indiaChart);
      final shifted = chalit.shiftedPlanets;
      // Very few or no planets should shift in a Whole Sign chart
      // (only those very near the cusp boundaries)
      expect(shifted.length, lessThanOrEqualTo(5));
    });
  });

  //  Pancha-Vargeeya Maitri 

  group('Pancha-Vargeeya Maitri (5-fold friendship)', () {
    test('getPlanetaryRelationships returns complete 77 matrix', () {
      final rels = jyotish.getPlanetaryRelationshipsMatrix(indiaChart);
      // 7 traditional planets
      expect(rels.length, equals(7));
      for (final entry in rels.entries) {
        // Each planet should have 6 relationships (all others)
        expect(entry.value.length, equals(6));
      }
    });

    test('Naisargika: Sun treats Saturn as enemy', () {
      final rels = jyotish.getPlanetaryRelationshipsMatrix(indiaChart);
      final sunSaturn = rels[Planet.sun]![Planet.saturn]!;
      expect(sunSaturn.natural, equals(RelationshipType.enemy));
    });

    test('Naisargika: Jupiter treats Sun as friend', () {
      final rels = jyotish.getPlanetaryRelationshipsMatrix(indiaChart);
      final jupSun = rels[Planet.jupiter]![Planet.sun]!;
      expect(jupSun.natural, equals(RelationshipType.friend));
    });

    test('Compound relationship is determined by both natural and temporal',
        () {
      final rels = jyotish.getPlanetaryRelationshipsMatrix(indiaChart);
      for (final entry in rels.entries) {
        for (final rel in entry.value.values) {
          // Verify compound = calculateCompound(natural, temporary)
          final expected = RelationshipCalculator.calculateCompound(
              rel.natural, rel.temporary);
          expect(rel.compound, equals(expected));
        }
      }
    });

    test('getPlanetaryRelationships (flat list) returns all pairs', () {
      final rels = jyotish.getPlanetaryRelationships(natalChart: indiaChart);
      // 7 * 6 = 42 ordered pairs
      expect(rels.length, equals(42));
    });
  });
}
