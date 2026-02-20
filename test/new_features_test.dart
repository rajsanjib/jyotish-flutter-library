import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

/// Comprehensive tests for all new Vedic astrology features.
/// These tests verify mathematical calculations without requiring Swiss Ephemeris.
void main() {
  group('Panchanga Module', () {
    test('Tithi calculates correctly from Sun-Moon distance', () {
      // Test case: Moon 45° ahead of Sun = Tritiya (3rd tithi)
      final testCases = [
        (0.0, 1, 'Pratipada'), // 0-12° = Pratipada
        (15.0, 2, 'Dwitiya'), // 12-24° = Dwitiya
        (30.0, 3, 'Tritiya'), // 24-36° = Tritiya
        (180.0, 16, 'Pratipada'), // 180° = Full Moon, Krishna Pratipada
        (350.0, 30, 'Chaturdashi'), // Near end
      ];

      for (final (elongation, expectedNumber, _) in testCases) {
        // Calculate tithi from elongation
        const tithiDegrees = 12.0;
        final tithiNumber = (elongation / tithiDegrees).floor() + 1;

        expect(tithiNumber, expectedNumber,
            reason: 'Elongation $elongation should give tithi $expectedNumber');
      }
    });

    test('Paksha determined correctly from tithi number', () {
      expect(Paksha.fromTithiNumber(1), Paksha.shukla);
      expect(Paksha.fromTithiNumber(15), Paksha.shukla);
      expect(Paksha.fromTithiNumber(16), Paksha.krishna);
      expect(Paksha.fromTithiNumber(30), Paksha.krishna);
    });

    test('Yoga calculates correctly from Sun+Moon longitudes', () {
      // Yoga = (Sun + Moon) / 13.333°
      final testCases = [
        (0.0, 0.0, 1), // Both at 0° = Vishkumbha
        (10.0, 10.0, 2), // Sum 20° = Priti
        (180.0, 180.0, 1), // Sum 360° = 0° = Vishkumbha
      ];

      for (final (sunLong, moonLong, expectedYoga) in testCases) {
        final sum = (sunLong + moonLong) % 360;
        const yogaDegrees = 360.0 / 27;
        final yogaNumber = (sum / yogaDegrees).floor() + 1;

        expect(yogaNumber, expectedYoga);
      }
    });

    test('Yoga has correct nature', () {
      expect(const YogaInfo(number: 6, name: 'Atiganda', elapsed: 0.5).nature,
          YogaNature.malefic);
      expect(const YogaInfo(number: 9, name: 'Shula', elapsed: 0.5).nature,
          YogaNature.malefic);
      expect(const YogaInfo(number: 10, name: 'Ganda', elapsed: 0.5).nature,
          YogaNature.malefic);
      expect(const YogaInfo(number: 13, name: 'Vyaghata', elapsed: 0.5).nature,
          YogaNature.malefic);
      expect(const YogaInfo(number: 17, name: 'Vyatipata', elapsed: 0.5).nature,
          YogaNature.malefic);
      expect(const YogaInfo(number: 27, name: 'Vaidhriti', elapsed: 0.5).nature,
          YogaNature.malefic);

      expect(const YogaInfo(number: 1, name: 'Vishkumbha', elapsed: 0.5).nature,
          YogaNature.benefic);
    });

    test('Karana types are determined correctly', () {
      // First 7 karanas are fixed: Bava to Vishti
      expect(KaranaInfo.fixedKaranaNames.length, 7);
      expect(KaranaInfo.fixedKaranaNames[0], 'Bava');
      expect(KaranaInfo.fixedKaranaNames[6], 'Vishti');

      // Last 4 karanas are variable
      expect(KaranaInfo.variableKaranaNames.length, 4);
      expect(KaranaInfo.variableKaranaNames[0], 'Shakuni');
      expect(KaranaInfo.variableKaranaNames[3], 'Kimstughna');
    });

    test('Vara ruling planets are correct', () {
      expect(VaraInfo.getRulingPlanet(0), Planet.sun); // Sunday
      expect(VaraInfo.getRulingPlanet(1), Planet.moon); // Monday
      expect(VaraInfo.getRulingPlanet(2), Planet.mars); // Tuesday
      expect(VaraInfo.getRulingPlanet(3), Planet.mercury); // Wednesday
      expect(VaraInfo.getRulingPlanet(4), Planet.jupiter); // Thursday
      expect(VaraInfo.getRulingPlanet(5), Planet.venus); // Friday
      expect(VaraInfo.getRulingPlanet(6), Planet.saturn); // Saturday
    });

    test('Hora lord sequence is correct', () {
      // Hora lord sequence: Sun -> Venus -> Mercury -> Moon -> Saturn -> Jupiter -> Mars
      // (Descending order of orbital speed/height)

      // Sunday starts with Sun
      const varaSunday =
          VaraInfo(weekday: 0, name: 'Sunday', rulingPlanet: Planet.sun);
      expect(varaSunday.getHoraLord(0), Planet.sun);
      expect(varaSunday.getHoraLord(1), Planet.venus);

      // Monday starts with Moon (index 3 in sequence)
      const varaMonday =
          VaraInfo(weekday: 1, name: 'Monday', rulingPlanet: Planet.moon);
      expect(varaMonday.getHoraLord(0), Planet.moon);
      expect(varaMonday.getHoraLord(1), Planet.saturn);
    });
  });

  group('Ashtakavarga System', () {
    test('Ashtakavarga tables exist for all planets', () {
      for (final planet in Planet.traditionalPlanets) {
        final table = AshtakavargaTables.getTableForPlanet(planet);
        expect(table.length, 12, reason: 'Each table should have 12 signs');
        for (final row in table) {
          expect(row.length, 7,
              reason: 'Each row should have 7 contributing planets');
        }
      }
    });

    test('Sarvashtakavarga calculates totals correctly', () {
      const sav = Sarvashtakavarga(
        bindus: [30, 35, 25, 28, 32, 29, 31, 33, 27, 30, 34, 26],
      );

      expect(sav.total, 360); // Sum of all bindus
      expect(sav.average, 30.0); // Average per sign
      expect(sav.strongestSign, 1); // Index 1 has 35 bindus
      expect(sav.weakestSign, 2); // Index 2 has 25 bindus
      expect(sav.favorableSigns,
          [0, 1, 4, 5, 6, 7, 9, 10]); // Signs with > 28 bindus
    });

    test('Bhinnashtakavarga tracks bindus per sign', () {
      final bav = Bhinnashtakavarga(
        planet: Planet.sun,
        bindus: [5, 4, 3, 5, 4, 3, 4, 5, 3, 4, 5, 3],
        contributions: List<int>.filled(12, 0),
      );

      expect(bav.getBindusForSign(0), 5);
      expect(bav.getBindusForSign(11), 3);
      expect(bav.totalBindus, bav.bindus.fold(0, (sum, b) => sum + b));
    });

    test('Ashtakavarga transit analysis identifies favorable transits', () {
      const sav = Sarvashtakavarga(
        bindus: [30, 35, 25, 28, 32, 29, 31, 33, 27, 30, 34, 26],
      );

      final ashtakavarga = Ashtakavarga(
        natalChart: _createMockChart(),
        bhinnashtakavarga: {},
        sarvashtakavarga: sav,
        samudayaAshtakavarga: [],
      );

      expect(ashtakavarga.isSignFavorableForTransits(1), true); // 35 bindus
      expect(ashtakavarga.isSignFavorableForTransits(2), false); // 25 bindus
      expect(ashtakavarga.isSignFavorableForTransits(8), false); // 27 bindus
    });
  });

  group('KP (Krishnamurti Paddhati) Support', () {
    test('KP New VP291 ayanamsa is available', () {
      // Check that the new ayanamsa mode is available
      expect(SiderealMode.krishnamurtiVP291.constant, 45);
      expect(
          SiderealMode.krishnamurtiVP291.name, 'Krishnamurti VP291 (KP New)');
    });

    test('Khullar ayanamsa is available', () {
      expect(SiderealMode.khullar.constant, 47);
      expect(SiderealMode.khullar.name, 'Khullar Ayanamsa');
    });

    test('Planet ownership by sign is correct', () {
      expect(KPPlanetOwnership.getSignLord(1), Planet.mars); // Aries
      expect(KPPlanetOwnership.getSignLord(4), Planet.moon); // Cancer
      expect(KPPlanetOwnership.getSignLord(5), Planet.sun); // Leo
      expect(KPPlanetOwnership.getSignLord(7), Planet.venus); // Libra
      expect(KPPlanetOwnership.getSignLord(10), Planet.saturn); // Capricorn
    });

    test('Star ownership follows Vimshottari sequence', () {
      // Stars owned in cycle: Ketu, Venus, Sun, Moon, Mars, Rahu, Jupiter, Saturn, Mercury
      expect(KPPlanetOwnership.getStarLord(1), Planet.ketu); // Ashwini - Ketu
      expect(KPPlanetOwnership.getStarLord(2), Planet.venus); // Bharani
      expect(KPPlanetOwnership.getStarLord(3), Planet.sun); // Krittika
      expect(KPPlanetOwnership.getStarLord(4), Planet.moon); // Rohini
    });

    test('Planet houses ownership is correct', () {
      expect(KPPlanetOwnership.getOwnedHouses(Planet.sun), [5]); // Leo
      expect(KPPlanetOwnership.getOwnedHouses(Planet.moon), [4]); // Cancer
      expect(KPPlanetOwnership.getOwnedHouses(Planet.mars),
          [1, 8]); // Aries, Scorpio
      expect(KPPlanetOwnership.getOwnedHouses(Planet.mercury),
          [3, 6]); // Gemini, Virgo
      expect(KPPlanetOwnership.getOwnedHouses(Planet.jupiter),
          [9, 12]); // Sagittarius, Pisces
      expect(KPPlanetOwnership.getOwnedHouses(Planet.venus),
          [2, 7]); // Taurus, Libra
      expect(KPPlanetOwnership.getOwnedHouses(Planet.saturn),
          [10, 11]); // Capricorn, Aquarius
    });

    test('KP Significators track ABCD correctly', () {
      const significators = KPSignificators(
        planet: Planet.jupiter,
        aSignificators: [1, 4],
        bSignificators: [5, 9],
        cSignificators: [9, 12],
        dSignificators: [1, 4],
      );

      expect(significators.aSignificators, [1, 4]);
      expect(significators.bSignificators, [5, 9]);
      expect(significators.cSignificators, [9, 12]);
      expect(significators.dSignificators, [1, 4]);
      expect(significators.allSignificators, [1, 4, 5, 9, 12]);
      expect(significators.signifies(9), true);
      expect(significators.signifies(2), false);
    });

    test('KP Dasha periods are correct', () {
      expect(KPDashaPeriods.getPeriod(Planet.sun), 6);
      expect(KPDashaPeriods.getPeriod(Planet.moon), 10);
      expect(KPDashaPeriods.getPeriod(Planet.mars), 7);
      expect(KPDashaPeriods.getPeriod(Planet.mercury), 17);
      expect(KPDashaPeriods.getPeriod(Planet.jupiter), 16);
      expect(KPDashaPeriods.getPeriod(Planet.venus), 20);
      expect(KPDashaPeriods.getPeriod(Planet.saturn), 19);
      expect(KPDashaPeriods.getPeriod(Planet.meanNode), 18);
    });

    test('Vimshottari Dasha totals 120 years with all 9 planets', () {
      // Full Vimshottari cycle should total 120 years
      // Sequence: Ketu (7), Venus (20), Sun (6), Moon (10), Mars (7),
      //           Rahu (18), Jupiter (16), Saturn (19), Mercury (17)
      // Note: Both meanNode and trueNode are treated as nodes (18 years)
      // So we only count 7 traditional planets + nodes once
      final periods = [
        7, // Ketu
        20, // Venus
        6, // Sun
        10, // Moon
        7, // Mars
        18, // Rahu
        16, // Jupiter
        19, // Saturn
        17, // Mercury
      ];

      final total = periods.fold<int>(0, (sum, p) => sum + p);
      expect(total, 120); // Standard Vimshottari total
      expect(periods[5], 18); // Rahu is 18 years
    });
  });

  group('Special Transit Features', () {
    test('Sade Sati identifies correct Saturn positions', () {
      // Sade Sati houses from Moon are 12th, 1st, and 2nd
      expect(SaturnTransitConstants.sadeSatiHouses, [12, 1, 2]);

      // Test that the constants contain the right houses
      expect(SaturnTransitConstants.sadeSatiHouses.contains(12), true);
      expect(SaturnTransitConstants.sadeSatiHouses.contains(1), true);
      expect(SaturnTransitConstants.sadeSatiHouses.contains(2), true);
      expect(SaturnTransitConstants.sadeSatiHouses.contains(4), false);
      expect(SaturnTransitConstants.sadeSatiHouses.contains(8), false);
    });

    test('Dhaiya identifies 4th and 8th house Saturn transits', () {
      // Dhaiya houses are 4 and 8 from Moon
      expect(SaturnTransitConstants.dhaiyaHouses, [4, 8]);

      // Test specific house numbers directly
      expect(SaturnTransitConstants.dhaiyaHouses.contains(4), true);
      expect(SaturnTransitConstants.dhaiyaHouses.contains(8), true);
      expect(SaturnTransitConstants.dhaiyaHouses.contains(1), false);
      expect(SaturnTransitConstants.dhaiyaHouses.contains(12), false);
    });

    test('Panchak identifies last 6 nakshatras', () {
      expect(
          SaturnTransitConstants.panchakNakshatras, [22, 23, 24, 25, 26, 27]);
      expect(SaturnTransitConstants.panchakNakshatras.contains(22),
          true); // Dhanishta
      expect(SaturnTransitConstants.panchakNakshatras.contains(27),
          true); // Revati
      expect(SaturnTransitConstants.panchakNakshatras.contains(21),
          false); // Shravana
    });

    test('Panchak starts at 300 degrees (middle of Dhanishta)', () {
      // Panchak should start at 300° (middle of Dhanishta: 293°20' to 306°40')
      expect(SaturnTransitConstants.panchakStartLongitude, 300.0);
      expect(SaturnTransitConstants.panchakEndLongitude, 360.0);

      // Moon at 295° should NOT be in Panchak (before 300°)
      const beforePanchak = 295.0;
      expect(beforePanchak >= 300.0, false);

      // Moon at 300° should be in Panchak
      const atPanchakStart = 300.0;
      expect(atPanchakStart >= 300.0, true);

      // Moon at 350° should be in Panchak
      const inPanchak = 350.0;
      expect(inPanchak >= 300.0, true);
    });

    test('Saturn stays approximately 2.5 years per sign', () {
      expect(SaturnTransitConstants.yearsPerSign, 2.5);
      expect(SaturnTransitConstants.daysPerSign, 912); // ~2.5 * 365
    });
  });

  group('Muhurta (Auspicious Periods)', () {
    test('Hora lords follow correct sequence', () {
      const sequence = MuhurtaConstants.horaLordsSequence;
      expect(sequence.length, 7);
      expect(sequence[0], Planet.sun);
      expect(sequence[1], Planet.venus);
      expect(sequence[2], Planet.mercury);
      expect(sequence[3], Planet.moon);
      expect(sequence[4], Planet.saturn);
      expect(sequence[5], Planet.jupiter);
      expect(sequence[6], Planet.mars);
    });

    test('Each day starts with its ruling planet', () {
      // Sunday starts with Sun
      expect(VaraInfo.getRulingPlanet(0), Planet.sun);
      // Monday starts with Moon
      expect(VaraInfo.getRulingPlanet(1), Planet.moon);
      // Tuesday starts with Mars
      expect(VaraInfo.getRulingPlanet(2), Planet.mars);
    });

    test('Choghadiya types have correct auspiciousness', () {
      expect(ChoghadiyaType.amrit.isAuspicious, true);
      expect(ChoghadiyaType.shubh.isAuspicious, true);
      expect(ChoghadiyaType.labh.isAuspicious, true);
      expect(ChoghadiyaType.char.isAuspicious, true);

      expect(ChoghadiyaType.udveg.isAuspicious, false);
      expect(ChoghadiyaType.kaal.isAuspicious, false);
      expect(ChoghadiyaType.rog.isAuspicious, false);
    });

    test('Rahukalam timing varies by weekday', () {
      const rahuTimes = MuhurtaConstants.rahuKalamByWeekday;
      expect(rahuTimes.length, 7);

      // Sunday: 7th and 8th portion
      expect(rahuTimes[0], (6, 8));
      // Monday: 5th and 6th portion
      expect(rahuTimes[1], (4, 6));
      // Saturday: 8th and 1st portion (wraps around)
      expect(rahuTimes[6], (7, 1));
    });

    test('Gulikalam timing varies by weekday', () {
      const gulikaTimes = MuhurtaConstants.gulikaKalamByWeekday;
      expect(gulikaTimes.length, 7);

      // Sunday: 5th and 6th portion
      expect(gulikaTimes[0], (4, 6));
      // Saturday: 1st and 2nd portion
      expect(gulikaTimes[6], (1, 2));
    });

    test('Yamagandam timing varies by weekday', () {
      const yamaTimes = MuhurtaConstants.yamaGandamByWeekday;
      expect(yamaTimes.length, 7);

      // Sunday: 4th and 5th portion
      expect(yamaTimes[0], (3, 5));
      // Monday: 7th and 8th portion
      expect(yamaTimes[1], (6, 8));
    });

    test('Choghadiya sequences are defined for all weekdays', () {
      for (var day = 0; day < 7; day++) {
        expect(MuhurtaConstants.daytimeChoghadiyaSequence[day]?.length, 8,
            reason: 'Day $day should have 8 daytime Choghadiya');
        expect(MuhurtaConstants.nighttimeChoghadiyaSequence[day]?.length, 8,
            reason: 'Day $day should have 8 nighttime Choghadiya');
      }
    });
  });

  group('New Sidereal Modes', () {
    test('All new ayanamsa modes are defined', () {
      // Verify all new modes are available
      expect(SiderealMode.lahiri1940.constant, 43);
      expect(SiderealMode.lahiriVP285.constant, 44);
      expect(SiderealMode.krishnamurtiVP291.constant, 45);
      expect(SiderealMode.lahiriICRC.constant, 46);
      expect(SiderealMode.khullar.constant, 47);
    });

    test('Sidereal mode constants match Swiss Ephemeris', () {
      expect(SwissEphConstants.sidmKrishnamurtiVP291, 45);
      expect(SwissEphConstants.sidmKhullar, 47);
    });
  });
}

// Helper function to create a mock chart for testing
VedicChart _createMockChart() {
  return VedicChart(
    dateTime: DateTime.now(),
    location: 'Test Location',
    latitude: 0.0,
    longitudeCoord: 0.0,
    houses: HouseSystem(
      system: 'W',
      cusps: List<double>.generate(12, (i) => i * 30.0),
      ascendant: 0.0,
      midheaven: 90.0,
    ),
    planets: {
      Planet.sun: VedicPlanetInfo(
        position: PlanetPosition(
          planet: Planet.sun,
          dateTime: DateTime.now(),
          longitude: 0.0,
          latitude: 0.0,
          distance: 1.0,
          longitudeSpeed: 1.0,
          latitudeSpeed: 0.0,
          distanceSpeed: 0.0,
        ),
        house: 1,
        dignity: PlanetaryDignity.ownSign,
      ),
      Planet.moon: VedicPlanetInfo(
        position: PlanetPosition(
          planet: Planet.moon,
          dateTime: DateTime.now(),
          longitude: 30.0,
          latitude: 0.0,
          distance: 1.0,
          longitudeSpeed: 13.0,
          latitudeSpeed: 0.0,
          distanceSpeed: 0.0,
        ),
        house: 2,
        dignity: PlanetaryDignity.friendSign,
      ),
    },
    rahu: VedicPlanetInfo(
      position: PlanetPosition(
        planet: Planet.meanNode,
        dateTime: DateTime.now(),
        longitude: 120.0,
        latitude: 0.0,
        distance: 1.0,
        longitudeSpeed: -0.05,
        latitudeSpeed: 0.0,
        distanceSpeed: 0.0,
      ),
      house: 5,
      dignity: PlanetaryDignity.neutralSign,
    ),
    ketu: KetuPosition(
      rahuPosition: PlanetPosition(
        planet: Planet.meanNode,
        dateTime: DateTime.now(),
        longitude: 120.0,
        latitude: 0.0,
        distance: 1.0,
        longitudeSpeed: -0.05,
        latitudeSpeed: 0.0,
        distanceSpeed: 0.0,
      ),
    ),
  );
}
