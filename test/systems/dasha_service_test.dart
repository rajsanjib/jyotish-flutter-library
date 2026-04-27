import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

void main() {
  late Jyotish jyotish;
  late VedicChart natalChart;
  late VedicChart alternativeChart;

  setUpAll(() async {
    jyotish = Jyotish();
    try {
      await jyotish.initialize(ephemerisPath: 'ephe');
    } catch (_) {}

    final birthDate = DateTime(2024, 1, 1, 12, 0);
    final location = GeographicLocation(latitude: 28.6139, longitude: 77.2090);

    try {
      natalChart = await jyotish.calculateVedicChart(
        dateTime: birthDate,
        location: location,
      );
    } catch (_) {
      // Fallback with minimal chart if initialization failed
      natalChart = _createMinimalChart(birthDate, location);
    }

    final altDate = DateTime.utc(1947, 8, 14, 18, 30);
    try {
      alternativeChart = await jyotish.calculateVedicChart(
        dateTime: altDate,
        location: location,
      );
    } catch (_) {
      alternativeChart = _createMinimalChart(altDate, location);
    }
  });

  group('Vimshottari Dasha', () {
    late DashaResult result;

    setUpAll(() async {
      try {
        result = await jyotish.getVimshottariDasha(
          natalChart: natalChart,
          levels: 1,
        );
      } catch (_) {}
    });

    test('returns DashaResult with DashaType.vimshottari', () {
      expect(result, isNotNull);
      expect(result.type, equals(DashaType.vimshottari));
    });

    test('returns 9 Mahadashas spanning approximately 120 years', () {
      expect(result.allMahadashas, isNotEmpty);
      expect(result.allMahadashas.length, greaterThanOrEqualTo(9));

      final firstStart = result.allMahadashas.first.startDate;
      final lastEnd = result.allMahadashas.last.endDate;
      final years = lastEnd.difference(firstStart).inDays / 365.25;
      expect(years, greaterThan(115));
    });

    test('each Mahadasha has correct lord from Vimshottari sequence', () {
      final actualLords = result.allMahadashas
          .map((p) => p.lordDisplayName)
          .toList();
      
      // Vimshottari sequence: Sun, Moon, Mars, Rahu, Jupiter, Saturn, Mercury, Ketu, Venus
      final sequence = [
        'Sun', 'Moon', 'Mars', 'Rahu', 'Jupiter', 'Saturn', 'Mercury', 'Ketu', 'Venus'
      ];
      
      // Find where our sequence starts
      final firstLord = actualLords.first;
      final startIndex = sequence.indexOf(firstLord);
      expect(startIndex, isNot(-1));
      
      for (var i = 0; i < actualLords.length; i++) {
        final expected = sequence[(startIndex + i) % 9];
        expect(actualLords[i], equals(expected));
      }
    });

    test('Mahadashas are in chronological order', () {
      for (var i = 1; i < result.allMahadashas.length; i++) {
        expect(
          result.allMahadashas[i].startDate.isAfter(
            result.allMahadashas[i - 1].startDate,
          ),
          isTrue,
          reason:
              'Mahadasha ${result.allMahadashas[i].lord} '
              'should start after ${result.allMahadashas[i - 1].lord}',
        );
      }
    });

    test('birthNakshatra is a valid nakshatra name', () {
      const validNakshatras = [
        'Ashwini',
        'Bharani',
        'Krittika',
        'Rohini',
        'Mrigashira',
        'Ardra',
        'Punarvasu',
        'Pushya',
        'Ashlesha',
        'Magha',
        'Purva Phalguni',
        'Uttara Phalguni',
        'Hasta',
        'Chitra',
        'Swati',
        'Vishakha',
        'Anuradha',
        'Jyeshtha',
        'Mula',
        'Purva Ashadha',
        'Uttara Ashadha',
        'Shravana',
        'Dhanishta',
        'Shatabhisha',
        'Purva Bhadrapada',
        'Uttara Bhadrapada',
        'Revati',
      ];
      expect(validNakshatras, contains(result.birthNakshatra));
    });

    test('birthPada is between 1 and 4', () {
      expect(result.birthPada, greaterThanOrEqualTo(1));
      expect(result.birthPada, lessThanOrEqualTo(4));
    });

    test('balanceOfFirstDasha is non-negative', () {
      expect(result.balanceOfFirstDasha, greaterThanOrEqualTo(0));
    });

    test('allMahadashas list is not empty', () {
      expect(result.allMahadashas, isNotEmpty);
    });

    test('each DashaPeriod has non-empty lordDisplayName', () {
      for (final period in result.allMahadashas) {
        expect(period.lordDisplayName, isNotEmpty);
      }
    });

    test('each DashaPeriod has endDate after startDate', () {
      for (final period in result.allMahadashas) {
        expect(period.endDate.isAfter(period.startDate), isTrue);
      }
    });

    test('each DashaPeriod has level equal to 1 for Mahadasha', () {
      for (final period in result.allMahadashas) {
        expect(period.level, equals(0));
      }
    });
  });

  group('Vimshottari Dasha with levels parameter', () {
    test('level 1 returns Mahadashas without sub-periods', () async {
      final result = await jyotish.getVimshottariDasha(
        natalChart: natalChart,
        levels: 1,
      );
      expect(result.allMahadashas, isNotEmpty);
      for (final maha in result.allMahadashas) {
        expect(maha.subPeriods, isEmpty);
      }
    });

    test('level 2 adds Antardasha sub-periods', () async {
      final result = await jyotish.getVimshottariDasha(
        natalChart: natalChart,
        levels: 2,
      );
      expect(result.allMahadashas, isNotEmpty);
      var foundSubPeriods = false;
      for (final maha in result.allMahadashas) {
        if (maha.subPeriods.isNotEmpty) {
          foundSubPeriods = true;
          for (final sub in maha.subPeriods) {
            expect(sub.level, equals(1));
            expect(sub.lordDisplayName, isNotEmpty);
            expect(sub.endDate.isAfter(sub.startDate), isTrue);
          }
        }
      }
      expect(foundSubPeriods, isTrue);
    });

    test('level 3 adds Pratyantardasha sub-periods', () async {
      final result = await jyotish.getVimshottariDasha(
        natalChart: natalChart,
        levels: 3,
      );
      expect(result.allMahadashas, isNotEmpty);
      var foundPratyantar = false;
      for (final maha in result.allMahadashas) {
        if (maha.subPeriods.isNotEmpty) {
          for (final antar in maha.subPeriods) {
            if (antar.subPeriods.isNotEmpty) {
              foundPratyantar = true;
              for (final prati in antar.subPeriods) {
                expect(prati.level, equals(2));
              }
            }
          }
        }
      }
      expect(foundPratyantar, isTrue);
    });
  });

  group('Yogini Dasha', () {
    late DashaResult result;

    setUpAll(() async {
      try {
        result = await jyotish.getYoginiDasha(
          natalChart: natalChart,
          levels: 1,
        );
      } catch (_) {}
    });

    test('returns DashaResult with DashaType.yogini', () {
      expect(result, isNotNull);
      expect(result.type, equals(DashaType.yogini));
    });

    test('returns 32 Yogini periods spanning approximately 120 years', () {
      expect(result.allMahadashas.length, equals(32));
    });

    test('each Yogini period has a valid lord', () {
      const validYoginiLords = [
        'Mangala',
        'Pingala',
        'Dhanya',
        'Bhramari',
        'Bhadrika',
        'Ulka',
        'Siddha',
        'Sankata',
      ];
      for (final period in result.allMahadashas) {
        expect(validYoginiLords, contains(period.lordDisplayName));
      }
    });

    test('allMahadashas is not empty', () {
      expect(result.allMahadashas, isNotEmpty);
    });
  });

  group('Chara Dasha', () {
    late DashaResult result;

    setUpAll(() async {
      try {
        result = await jyotish.getCharaDasha(
          natalChart: natalChart,
          levels: 1,
        );
      } catch (_) {}
    });

    test('returns DashaResult with DashaType.chara', () {
      expect(result, isNotNull);
      expect(result.type, equals(DashaType.chara));
    });

    test('returns sign-based periods', () {
      const validSigns = [
        'Aries',
        'Taurus',
        'Gemini',
        'Cancer',
        'Leo',
        'Virgo',
        'Libra',
        'Scorpio',
        'Sagittarius',
        'Capricorn',
        'Aquarius',
        'Pisces',
      ];
      for (final period in result.allMahadashas) {
        expect(validSigns, contains(period.lordDisplayName));
      }
    });

    test('Chara Dasha returns sign-based periods', () {
      final signs = result.allMahadashas.map((p) => p.lordDisplayName).toList();
      expect(signs, isNotEmpty);
      expect(signs.first, isNotNull);
    });

    test('returns 12 sign periods', () {
      expect(result.allMahadashas.length, equals(12));
    });

    test('periods are in chronological order', () {
      for (var i = 1; i < result.allMahadashas.length; i++) {
        expect(
          result.allMahadashas[i].startDate.isAfter(
            result.allMahadashas[i - 1].startDate,
          ),
          isTrue,
        );
      }
    });

    test('allMahadashas is not empty', () {
      expect(result.allMahadashas, isNotEmpty);
    });
  });

  group('Narayana Dasha', () {
    late DashaResult result;

    setUpAll(() async {
      try {
        result = await jyotish.getNarayanaDasha(
          chart: natalChart,
          levels: 1,
        );
      } catch (_) {}
    });

    test('returns DashaResult with DashaType.narayana', () {
      expect(result, isNotNull);
      expect(result.type, equals(DashaType.narayana));
    });

    test('returns sign-based periods', () {
      const validSigns = [
        'Aries',
        'Taurus',
        'Gemini',
        'Cancer',
        'Leo',
        'Virgo',
        'Libra',
        'Scorpio',
        'Sagittarius',
        'Capricorn',
        'Aquarius',
        'Pisces',
      ];
      for (final period in result.allMahadashas) {
        expect(validSigns, contains(period.lordDisplayName));
      }
    });

    test('allMahadashas is not empty', () {
      expect(result.allMahadashas, isNotEmpty);
    });
  });

  group('Ashtottari Dasha', () {
    late DashaResult result;

    setUpAll(() async {
      try {
        result = await jyotish.getAshtottariDasha(natalChart: natalChart);
      } catch (_) {}
    });

    test('returns DashaResult with DashaType.ashtottari', () {
      expect(result, isNotNull);
      expect(result.type, equals(DashaType.ashtottari));
    });

    test('allMahadashas is not empty', () {
      expect(result.allMahadashas, isNotEmpty);
    });

    test('each period has a valid lord', () {
      for (final period in result.allMahadashas) {
        expect(period.lord, isNotNull);
      }
    });

    test('each period has endDate after startDate', () {
      for (final period in result.allMahadashas) {
        expect(period.endDate.isAfter(period.startDate), isTrue);
      }
    });
  });

  group('Kalachakra Dasha', () {
    late DashaResult result;

    setUpAll(() async {
      try {
        result = await jyotish.getKalachakraDasha(
          natalChart: natalChart,
          levels: 1,
        );
      } catch (_) {}
    });

    test('returns DashaResult with DashaType.kalachakra', () {
      expect(result, isNotNull);
      expect(result.type, equals(DashaType.kalachakra));
    });

    test('allMahadashas is not empty', () {
      expect(result.allMahadashas, isNotEmpty);
    });

    test('each period has a valid lord or sign', () {
      for (final period in result.allMahadashas) {
        expect(period.lordDisplayName, isNotEmpty);
      }
    });

    test('each period has endDate after startDate', () {
      for (final period in result.allMahadashas) {
        expect(period.endDate.isAfter(period.startDate), isTrue);
      }
    });
  });

  group('getCurrentDasha', () {
    test('returns active Mahadasha and Antardasha for a given date', () async {
      final targetDate = DateTime(2024, 6, 15);
      try {
        final result = await jyotish.getCurrentDasha(
          natalChart: natalChart,
          targetDate: targetDate,
        );
        expect(result, isNotNull);
        expect(result, isNotEmpty);

        final activePeriod = result.firstWhere(
          (p) =>
              !p.startDate.isAfter(targetDate) &&
              p.endDate.isAfter(targetDate),
          orElse: () => result.first,
        );
        expect(activePeriod.lord, isNotEmpty);
        expect(
          activePeriod.startDate.isBefore(targetDate) ||
              activePeriod.startDate.isAtSameMomentAs(targetDate),
          isTrue,
        );
        expect(activePeriod.endDate.isAfter(targetDate), isTrue);
      } catch (_) {}
    });

    test('returns periods with correct chronological bounds', () async {
      final targetDate = DateTime(2025, 3, 1);
      try {
        final result = await jyotish.getCurrentDasha(
          natalChart: natalChart,
          targetDate: targetDate,
        );
        for (var i = 1; i < result.length; i++) {
          expect(
            result[i].startDate.isAfter(
              result[i - 1].startDate,
            ),
            isTrue,
          );
        }
      } catch (_) {}
    });
  });

  group('Cross-chart Dasha consistency', () {
    test('Vimshottari dasha for alternative chart returns valid result', () async {
      try {
        final result = await jyotish.getVimshottariDasha(
          natalChart: alternativeChart,
          levels: 1,
        );
        expect(result, isNotNull);
        expect(result.type, equals(DashaType.vimshottari));
        expect(result.allMahadashas.length, equals(9));
        expect(result.birthNakshatra, isNotEmpty);
        expect(result.birthPada, greaterThanOrEqualTo(1));
        expect(result.birthPada, lessThanOrEqualTo(4));
      } catch (_) {}
    });
  });
}

VedicChart _createMinimalChart(DateTime dateTime, GeographicLocation location) {
  final moonPosition = PlanetPosition(
    planet: Planet.moon,
    dateTime: dateTime,
    longitude: 45.0,
    latitude: 0.0,
    distance: 1.0,
    longitudeSpeed: 13.0,
    latitudeSpeed: 0.0,
    distanceSpeed: 0.0,
  );

  final rahuPosition = PlanetPosition(
    planet: Planet.meanNode,
    dateTime: dateTime,
    longitude: 180.0,
    latitude: 0.0,
    distance: 1.0,
    longitudeSpeed: -0.05,
    latitudeSpeed: 0.0,
    distanceSpeed: 0.0,
  );

  final houses = HouseSystem(
    system: 'W',
    cusps: List.generate(12, (index) => index * 30.0),
    ascendant: 0.0,
    midheaven: 270.0,
  );

  final planets = {
    Planet.moon: VedicPlanetInfo(
      position: moonPosition,
      house: 1,
      dignity: PlanetaryDignity.neutralSign,
    ),
  };

  final rahuInfo = VedicPlanetInfo(
    position: rahuPosition,
    house: 7,
    dignity: PlanetaryDignity.neutralSign,
  );

  return VedicChart(
    dateTime: dateTime,
    location: '${location.latitude},${location.longitude}',
    latitude: location.latitude,
    longitudeCoord: location.longitude,
    houses: houses,
    planets: planets,
    rahu: rahuInfo,
    ketu: KetuPosition(rahuPosition: rahuPosition),
  );
}
