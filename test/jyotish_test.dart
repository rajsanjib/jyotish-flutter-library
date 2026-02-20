import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

/// Unit tests for Jyotish library models and calculations.
/// These tests verify mathematical calculations without requiring Swiss Ephemeris.
void main() {
  group('GeographicLocation', () {
    test('creates location with valid coordinates', () {
      final location = GeographicLocation(
        latitude: 27.7172,
        longitude: 85.3240,
        altitude: 1400,
      );

      expect(location.latitude, 27.7172);
      expect(location.longitude, 85.3240);
      expect(location.altitude, 1400);
    });

    test('throws error for invalid coordinates', () {
      expect(() => GeographicLocation(latitude: 91, longitude: 0),
          throwsArgumentError);
      expect(() => GeographicLocation(latitude: 0, longitude: 181),
          throwsArgumentError);
    });

    test('converts DMS to decimal correctly', () {
      final location = GeographicLocation.fromDMS(
        latDegrees: 27,
        latMinutes: 43,
        latSeconds: 1.92,
        isNorth: true,
        lonDegrees: 85,
        lonMinutes: 19,
        lonSeconds: 26.4,
        isEast: true,
      );

      expect(location.latitude, closeTo(27.7172, 0.0001));
      expect(location.longitude, closeTo(85.3240, 0.0001));
    });
  });

  group('Planet', () {
    test('has correct Swiss Ephemeris IDs', () {
      expect(Planet.sun.swissEphId, 0);
      expect(Planet.moon.swissEphId, 1);
      expect(Planet.mercury.swissEphId, 2);
      expect(Planet.jupiter.swissEphId, 5);
    });

    test('planet lists are correct', () {
      expect(Planet.majorPlanets.length, 10);
      expect(Planet.traditionalPlanets.length, 7);
      expect(Planet.traditionalPlanets.contains(Planet.uranus), false);
    });

    test('fromSwissEphId works correctly', () {
      expect(Planet.fromSwissEphId(0), Planet.sun);
      expect(Planet.fromSwissEphId(999), null);
    });
  });

  group('PlanetPosition Calculations', () {
    test('calculates zodiac signs correctly', () {
      final testCases = [
        (0.0, 'Aries', 0),
        (45.0, 'Taurus', 15.0),
        (90.0, 'Cancer', 0.0),
        (180.0, 'Libra', 0.0),
        (270.0, 'Capricorn', 0.0),
        (359.9, 'Pisces', 29.9),
      ];

      for (final (longitude, expectedSign, expectedPos) in testCases) {
        final position = PlanetPosition(
          planet: Planet.sun,
          dateTime: DateTime.now(),
          longitude: longitude,
          latitude: 0,
          distance: 1.0,
          longitudeSpeed: 1.0,
          latitudeSpeed: 0,
          distanceSpeed: 0,
        );

        expect(position.zodiacSign, expectedSign);
        expect(position.positionInSign, closeTo(expectedPos, 0.1));
      }
    });

    test('detects retrograde motion', () {
      final retrograde = PlanetPosition(
        planet: Planet.mercury,
        dateTime: DateTime.now(),
        longitude: 100,
        latitude: 0,
        distance: 1.0,
        longitudeSpeed: -0.5,
        latitudeSpeed: 0,
        distanceSpeed: 0,
      );

      expect(retrograde.isRetrograde, true);
    });

    test('calculates nakshatras correctly', () {
      const nakshatraWidth = 360.0 / 27;

      for (var i = 0; i < 27; i++) {
        final longitude = (i * nakshatraWidth) + (nakshatraWidth / 2);
        final position = PlanetPosition(
          planet: Planet.moon,
          dateTime: DateTime.now(),
          longitude: longitude,
          latitude: 0,
          distance: 1.0,
          longitudeSpeed: 13.0,
          latitudeSpeed: 0,
          distanceSpeed: 0,
        );

        expect(position.nakshatraIndex, i);
      }
    });

    test('calculates nakshatra padas correctly', () {
      final position = PlanetPosition(
        planet: Planet.moon,
        dateTime: DateTime.now(),
        longitude: 5.0,
        latitude: 0,
        distance: 1.0,
        longitudeSpeed: 13.0,
        latitudeSpeed: 0,
        distanceSpeed: 0,
      );

      expect(position.nakshatraPada, greaterThanOrEqualTo(1));
      expect(position.nakshatraPada, lessThanOrEqualTo(4));
    });
  });

  // ============================================================
  // NEW TESTS: Aspect Calculations
  // ============================================================

  group('Aspect Calculations', () {
    test('AspectType has correct properties', () {
      expect(AspectType.conjunction.angle, 0);
      expect(AspectType.opposition.angle, 180);
      expect(AspectType.marsSpecial4th.isSpecialAspect, true);
      expect(AspectType.jupiterSpecial5th.isBenefic, true);
      expect(AspectType.saturnSpecial10th.isMalefic, true);
    });

    test('AspectInfo creates correctly', () {
      const aspect = AspectInfo(
        aspectingPlanet: Planet.mars,
        aspectedPlanet: Planet.jupiter,
        type: AspectType.opposition,
        exactOrb: 2.5,
        isApplying: true,
        strength: 0.75,
        aspectingLongitude: 100.0,
        aspectedLongitude: 280.0,
      );

      expect(aspect.aspectingPlanet, Planet.mars);
      expect(aspect.aspectedPlanet, Planet.jupiter);
      expect(aspect.type, AspectType.opposition);
      expect(aspect.isApplying, true);
      expect(aspect.isSeparating, false);
      expect(aspect.isTight, true);
    });

    test('AspectService calculates conjunction correctly', () {
      final service = AspectService();
      final positions = <Planet, PlanetPosition>{
        Planet.sun: PlanetPosition(
          planet: Planet.sun,
          dateTime: DateTime.now(),
          longitude: 100.0,
          latitude: 0,
          distance: 1.0,
          longitudeSpeed: 1.0,
          latitudeSpeed: 0,
          distanceSpeed: 0,
        ),
        Planet.mercury: PlanetPosition(
          planet: Planet.mercury,
          dateTime: DateTime.now(),
          longitude: 105.0,
          latitude: 0,
          distance: 0.5,
          longitudeSpeed: 1.5,
          latitudeSpeed: 0,
          distanceSpeed: 0,
        ),
      };

      final aspects = service.calculateAspects(positions);
      final conjunction =
          aspects.where((a) => a.type == AspectType.conjunction);
      expect(conjunction.isNotEmpty, true);
    });

    test('AspectService calculates opposition correctly', () {
      final service = AspectService();
      final positions = <Planet, PlanetPosition>{
        Planet.sun: PlanetPosition(
          planet: Planet.sun,
          dateTime: DateTime.now(),
          longitude: 10.0,
          latitude: 0,
          distance: 1.0,
          longitudeSpeed: 1.0,
          latitudeSpeed: 0,
          distanceSpeed: 0,
        ),
        Planet.saturn: PlanetPosition(
          planet: Planet.saturn,
          dateTime: DateTime.now(),
          longitude: 190.0,
          latitude: 0,
          distance: 10.0,
          longitudeSpeed: 0.03,
          latitudeSpeed: 0,
          distanceSpeed: 0,
        ),
      };

      final aspects = service.calculateAspects(positions);
      final opposition = aspects.where((a) => a.type == AspectType.opposition);
      expect(opposition.isNotEmpty, true);
    });

    test('AspectService detects Mars special aspects', () {
      final service = AspectService();
      final positions = <Planet, PlanetPosition>{
        Planet.mars: PlanetPosition(
          planet: Planet.mars,
          dateTime: DateTime.now(),
          longitude: 0.0,
          latitude: 0,
          distance: 1.5,
          longitudeSpeed: 0.5,
          latitudeSpeed: 0,
          distanceSpeed: 0,
        ),
        Planet.jupiter: PlanetPosition(
          planet: Planet.jupiter,
          dateTime: DateTime.now(),
          longitude: 210.0, // 210° from Mars = 8th aspect
          latitude: 0,
          distance: 5.0,
          longitudeSpeed: 0.1,
          latitudeSpeed: 0,
          distanceSpeed: 0,
        ),
      };

      final aspects = service.calculateAspects(positions);
      final mars8th = aspects.where((a) => a.type == AspectType.marsSpecial8th);
      expect(mars8th.isNotEmpty, true);
    });
  });

  // ============================================================
  // NEW TESTS: Dasha Calculations
  // ============================================================

  group('Dasha Calculations', () {
    test('DashaType has correct values', () {
      expect(DashaType.vimshottari.totalYears, 120);
      expect(DashaType.yogini.totalYears, 36);
    });

    test('DashaPeriod calculates duration correctly', () {
      final start = DateTime(2020, 1, 1);
      final end = DateTime(2026, 1, 1);
      final period = DashaPeriod(
        lord: Planet.sun,
        startDate: start,
        endDate: end,
        duration: end.difference(start),
        level: 0,
      );

      expect(period.durationYears, closeTo(6.0, 0.1));
      expect(period.isMahadasha, true);
      expect(period.levelName, 'Mahadasha');
    });

    test('DashaPeriod isActiveAt works correctly', () {
      final start = DateTime(2020, 1, 1);
      final end = DateTime(2026, 1, 1);
      final period = DashaPeriod(
        lord: Planet.sun,
        startDate: start,
        endDate: end,
        duration: end.difference(start),
        level: 0,
      );

      expect(period.isActiveAt(DateTime(2023, 6, 15)), true);
      expect(period.isActiveAt(DateTime(2019, 1, 1)), false);
      expect(period.isActiveAt(DateTime(2027, 1, 1)), false);
    });

    test('DashaService calculates Vimshottari correctly', () {
      final service = DashaService();
      // Moon at 15° Aries = Ashwini nakshatra = Ketu mahadasha
      final result = service.calculateVimshottariDasha(
        moonLongitude: 15.0,
        birthDateTime: DateTime(1990, 5, 15, 14, 30),
        levels: 2,
      );

      expect(result.type, DashaType.vimshottari);
      expect(result.birthNakshatra, 'Ashwini');
      expect(result.allMahadashas.isNotEmpty, true);
      expect(result.allMahadashas.first.level, 0);
    });

    test('DashaService calculates balance of first dasha', () {
      final service = DashaService();
      // Moon at exactly start of nakshatra = full dasha balance
      final result = service.calculateVimshottariDasha(
        moonLongitude: 0.0, // Start of Ashwini
        birthDateTime: DateTime(1990, 1, 1),
        levels: 1,
      );

      // Should have close to full Ketu dasha (7 years)
      expect(
          result.balanceOfFirstDasha, greaterThan(2000)); // > 5.5 years in days
    });

    test('DashaService calculates Yogini dasha', () {
      final service = DashaService();
      final result = service.calculateYoginiDasha(
        moonLongitude: 45.0,
        birthDateTime: DateTime(1990, 5, 15),
        levels: 2,
      );

      expect(result.type, DashaType.yogini);
      expect(result.allMahadashas.isNotEmpty, true);
    });

    test('DashaResult finds current period', () {
      final service = DashaService();
      final result = service.calculateVimshottariDasha(
        moonLongitude: 100.0,
        birthDateTime: DateTime(1990, 5, 15),
        levels: 3,
      );

      final currentPeriods = result.getActivePeriodsAt(DateTime.now());
      expect(currentPeriods.isNotEmpty, true);
      expect(currentPeriods.first.level, 0); // Mahadasha
    });

    test('DashaService adds precision warning for uncertain birth time', () {
      final service = DashaService();
      final result = service.calculateVimshottariDasha(
        moonLongitude: 100.0,
        birthDateTime: DateTime(1990, 5, 15),
        birthTimeUncertainty: 30, // 30 minutes uncertainty
      );

      expect(result.precisionWarning, isNotNull);
      expect(result.precisionWarning!.contains('30 minutes'), true);
    });
  });

  // ============================================================
  // NEW TESTS: Transit Models
  // ============================================================

  group('Transit Models', () {
    test('TransitInfo creates correctly', () {
      final transitPos = PlanetPosition(
        planet: Planet.saturn,
        dateTime: DateTime.now(),
        longitude: 300.0,
        latitude: 0,
        distance: 10.0,
        longitudeSpeed: 0.03,
        latitudeSpeed: 0,
        distanceSpeed: 0,
      );

      final info = TransitInfo(
        planet: Planet.saturn,
        transitPosition: transitPos,
        transitHouse: 10,
        transitSignIndex: 10,
      );

      expect(info.planet, Planet.saturn);
      expect(info.transitHouse, 10);
      expect(info.transitSign, 'Aquarius');
    });

    test('TransitEvent creates correctly', () {
      final event = TransitEvent(
        transitPlanet: Planet.jupiter,
        natalPlanet: Planet.sun,
        aspectType: AspectType.conjunction,
        exactDate: DateTime(2024, 6, 15),
        startDate: DateTime(2024, 6, 1),
        endDate: DateTime(2024, 6, 30),
        description: 'Jupiter conjunct natal Sun',
        significance: 5,
      );

      expect(event.transitPlanet, Planet.jupiter);
      expect(event.targetName, 'Sun');
      expect(event.duration.inDays, 29);
      expect(event.isActiveAt(DateTime(2024, 6, 10)), true);
    });

    test('TransitConfig oneYear creates correct range', () {
      final start = DateTime(2024, 1, 1);
      final config = TransitConfig.oneYear(from: start);

      expect(config.startDate, start);
      expect(config.endDate.difference(start).inDays, 365);
      expect(config.intervalDays, 1);
    });
  });

  // ============================================================
  // INTEGRATION TESTS (require Swiss Ephemeris)
  // ============================================================

  group('Swiss Ephemeris Integration', () {
    late Jyotish jyotish;

    setUpAll(() async {
      jyotish = Jyotish();
      try {
        await jyotish.initialize();
      } catch (e) {
        // ignore: avoid_print
        print('⚠️  Swiss Ephemeris not found. See SETUP.md for installation.');
        rethrow;
      }
    });

    tearDownAll(() {
      jyotish.dispose();
    });

    test('calculates planetary positions', () async {
      final dateTime = DateTime.utc(2024, 1, 1, 12, 0);
      final location = GeographicLocation(latitude: 0.0, longitude: 0.0);

      final position = await jyotish.getPlanetPosition(
        planet: Planet.sun,
        dateTime: dateTime,
        location: location,
      );

      expect(position.longitude, greaterThanOrEqualTo(0.0));
      expect(position.longitude, lessThan(360.0));
      expect(position.distance, greaterThan(0.0));
    });

    test('calculates sidereal positions', () async {
      final dateTime = DateTime.utc(1994, 7, 28, 5, 5);
      final location = GeographicLocation(
        latitude: 27.7172,
        longitude: 85.3240,
      );

      const flags = CalculationFlags(
        siderealMode: SiderealMode.lahiri,
        calculateSpeed: true,
      );

      final position = await jyotish.getPlanetPosition(
        planet: Planet.sun,
        dateTime: dateTime,
        location: location,
        flags: flags,
      );

      // July 28, 1994: Sun should be in Cancer (sidereal)
      expect(position.zodiacSign, 'Cancer');
      expect(position.positionInSign, greaterThan(10.0));
      expect(position.positionInSign, lessThan(12.0));
    });

    test('calculates aspects from chart', () async {
      final dateTime = DateTime.utc(1990, 5, 15, 14, 30);
      final location = GeographicLocation(
        latitude: 28.6139,
        longitude: 77.2090,
      );

      final aspects = await jyotish.getAspects(
        dateTime: dateTime,
        location: location,
      );

      expect(aspects, isNotEmpty);
      expect(aspects.first.aspectingPlanet, isNotNull);
    });

    test('calculates Vimshottari dasha from chart', () async {
      final dateTime = DateTime.utc(1990, 5, 15, 14, 30);
      final location = GeographicLocation(
        latitude: 28.6139,
        longitude: 77.2090,
      );

      final chart = await jyotish.calculateVedicChart(
        dateTime: dateTime,
        location: location,
      );

      final dasha = await jyotish.getVimshottariDasha(natalChart: chart);

      expect(dasha.type, DashaType.vimshottari);
      expect(dasha.birthNakshatra, isNotEmpty);
      expect(dasha.allMahadashas.length, greaterThan(9));
    });
  });
}
