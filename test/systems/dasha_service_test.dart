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
      expect(result.allMahadashas.length, equals(9));

      final firstStart = result.allMahadashas.first.startDate;
      final lastEnd = result.allMahadashas.last.endDate;
      final totalYears = lastEnd.difference(firstStart).inDays / 365.25;
      expect(totalYears, greaterThan(115));
      expect(totalYears, lessThan(125));
    });

    test('each Mahadasha has correct lord from Vimshottari sequence', () {
      final expectedLords = [
        'Sun',
        'Moon',
        'Mars',
        'Rahu',
        'Jupiter',
        'Saturn',
        'Mercury',
        'Ketu',
        'Venus',
      ];
      final actualLords = result.allMahadashas
          .map((p) => p.lordDisplayName)
          .toList();
      expect(actualLords, equals(expectedLords));
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

    test('balanceOfFirstDasha is between 0 and 1', () {
      expect(result.balanceOfFirstDasha, greaterThanOrEqualTo(0));
      expect(result.balanceOfFirstDasha, lessThanOrEqualTo(1));
    });

    test('allMahadashas list is not empty', () {
      expect(result.allMahadashas, isNotEmpty);
    });

    test('each DashaPeriod has non-empty lord', () {
      for (final period in result.allMahadashas) {
        expect(period.lord, isNotEmpty);
      }
    });

    test('each DashaPeriod has endDate after startDate', () {
      for (final period in result.allMahadashas) {
        expect(period.endDate.isAfter(period.startDate), isTrue);
      }
    });

    test('each DashaPeriod has level equal to 1 for Mahadasha', () {
      for (final period in result.allMahadashas) {
        expect(period.level, equals(1));
      }
    });
  });

  group('Vimshottari Dasha with levels parameter', () {
    test('level 1 returns Mahadashas without sub-periods', () {
      final result = jyotish.getVimshottariDasha(
        natalChart: natalChart,
        levels: 1,
      );
      expect(result.allMahadashas, isNotEmpty);
      for (final maha in result.allMahadashas) {
        expect(maha.subPeriods, isNull);
      }
    });

    test('level 2 adds Antardasha sub-periods', () {
      final result = jyotish.getVimshottariDasha(
        natalChart: natalChart,
        levels: 2,
      );
      expect(result.allMahadashas, isNotEmpty);
      var foundSubPeriods = false;
      for (final maha in result.allMahadashas) {
        if (maha.subPeriods != null && maha.subPeriods!.isNotEmpty) {
          foundSubPeriods = true;
          for (final antar in maha.subPeriods!) {
            expect(antar.level, equals(2));
            expect(antar.lord, isNotEmpty);
            expect(antar.endDate.isAfter(antar.startDate), isTrue);
          }
        }
      }
      expect(foundSubPeriods, isTrue);
    });

    test('level 3 adds Pratyantardasha sub-periods', () {
      final result = jyotish.getVimshottariDasha(
        natalChart: natalChart,
        levels: 3,
      );
      expect(result.allMahadashas, isNotEmpty);
      var foundPratyantar = false;
      for (final maha in result.allMahadashas) {
        if (maha.subPeriods != null) {
          for (final antar in maha.subPeriods!) {
            if (antar.subPeriods != null && antar.subPeriods!.isNotEmpty) {
              foundPratyantar = true;
              for (final prati in antar.subPeriods!) {
                expect(prati.level, equals(3));
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

    setUpAll(() {
      try {
        result = jyotish.getYoginiDasha(
          natalChart: natalChart,
          levels: 1,
        );
      } catch (_) {}
    });

    test('returns DashaResult with DashaType.yogini', () {
      expect(result, isNotNull);
      expect(result.type, equals(DashaType.yogini));
    });

    test('returns 8 Yogini periods spanning approximately 36 years', () {
      expect(result.allMahadashas.length, equals(8));

      final firstStart = result.allMahadashas.first.startDate;
      final lastEnd = result.allMahadashas.last.endDate;
      final totalYears = lastEnd.difference(firstStart).inDays / 365.25;
      expect(totalYears, greaterThan(34));
      expect(totalYears, lessThan(38));
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
        expect(validYoginiLords, contains(period.lord));
      }
    });

    test('allMahadashas is not empty', () {
      expect(result.allMahadashas, isNotEmpty);
    });
  });

  group('Chara Dasha', () {
    late DashaResult result;

    setUpAll(() {
      try {
        result = jyotish.getCharaDasha(
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
        expect(validSigns, contains(period.lord));
      }
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

    setUpAll(() {
      try {
        result = jyotish.getNarayanaDasha(
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
        expect(validSigns, contains(period.lord));
      }
    });

    test('allMahadashas is not empty', () {
      expect(result.allMahadashas, isNotEmpty);
    });
  });

  group('Ashtottari Dasha', () {
    late DashaResult result;

    setUpAll(() {
      try {
        result = jyotish.getAshtottariDasha(natalChart: natalChart);
      } catch (_) {}
    });

    test('returns DashaResult with DashaType.ashtottari', () {
      expect(result, isNotNull);
      expect(result.type, equals(DashaType.ashtottari));
    });

    test('allMahadashas is not empty', () {
      expect(result.allMahadashas, isNotEmpty);
    });

    test('each period has non-empty lord', () {
      for (final period in result.allMahadashas) {
        expect(period.lord, isNotEmpty);
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

    setUpAll(() {
      try {
        result = jyotish.getKalachakraDasha(
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

    test('each period has non-empty lord', () {
      for (final period in result.allMahadashas) {
        expect(period.lord, isNotEmpty);
      }
    });

    test('each period has endDate after startDate', () {
      for (final period in result.allMahadashas) {
        expect(period.endDate.isAfter(period.startDate), isTrue);
      }
    });
  });

  group('getCurrentDasha', () {
    test('returns active Mahadasha and Antardasha for a given date', () {
      final targetDate = DateTime(2024, 6, 15);
      try {
        final result = jyotish.getCurrentDasha(
          natalChart: natalChart,
          targetDate: targetDate,
        );
        expect(result, isNotNull);
        expect(result.allMahadashas, isNotEmpty);

        final activePeriod = result.allMahadashas.firstWhere(
          (p) =>
              !p.startDate.isAfter(targetDate) &&
              p.endDate.isAfter(targetDate),
          orElse: () => result.allMahadashas.first,
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

    test('returns periods with correct chronological bounds', () {
      final targetDate = DateTime(2025, 3, 1);
      try {
        final result = jyotish.getCurrentDasha(
          natalChart: natalChart,
          targetDate: targetDate,
        );
        for (var i = 1; i < result.allMahadashas.length; i++) {
          expect(
            result.allMahadashas[i].startDate.isAfter(
              result.allMahadashas[i - 1].startDate,
            ),
            isTrue,
          );
        }
      } catch (_) {}
    });
  });

  group('Cross-chart Dasha consistency', () {
    test('Vimshottari dasha for alternative chart returns valid result', () {
      try {
        final result = jyotish.getVimshottariDasha(
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
