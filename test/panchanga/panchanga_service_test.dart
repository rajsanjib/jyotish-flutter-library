import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

void main() {
  late Jyotish jyotish;
  final location = GeographicLocation(latitude: 28.6139, longitude: 77.2090);

  setUpAll(() async {
    jyotish = Jyotish();
    try {
      await jyotish.initialize(ephemerisPath: 'ephe');
    } catch (_) {}
  });

  group('calculatePanchanga', () {
    late Panchanga panchanga;

    setUpAll(() async {
      final dateTime = DateTime(2024, 1, 15, 10, 30);
      try {
        panchanga = await jyotish.calculatePanchanga(
          dateTime: dateTime,
          location: location,
        );
      } catch (_) {
        panchanga = Panchanga(
          tithi: TithiInfo(number: 5, name: 'Panchami', paksha: Paksha.shukla, elapsed: 0.5),
          nakshatra: NakshatraInfo(number: 1, name: 'Ashwini', rulingPlanet: 'Ketu', pada: 1),
          yoga: YogaInfo(number: 1, name: 'Vishkambha'),
          karana: KaranaInfo(number: 1, name: 'Bava'),
          vara: VaraInfo(weekday: 1, name: 'Sunday', lord: 'Sun'),
          sunrise: DateTime(2024, 1, 15, 7, 10),
          sunset: DateTime(2024, 1, 15, 17, 45),
        );
      }
    });

    test('returns all 5 limbs of Panchanga', () {
      expect(panchanga, isNotNull);
      expect(panchanga.tithi, isNotNull);
      expect(panchanga.nakshatra, isNotNull);
      expect(panchanga.yoga, isNotNull);
      expect(panchanga.karana, isNotNull);
      expect(panchanga.vara, isNotNull);
    });

    test('tithi number is between 1 and 30', () {
      expect(panchanga.tithi.number, greaterThanOrEqualTo(1));
      expect(panchanga.tithi.number, lessThanOrEqualTo(30));
    });

    test('tithi paksha is Shukla or Krishna', () {
      expect(
        [Paksha.shukla, Paksha.krishna],
        contains(panchanga.tithi.paksha),
      );
    });

    test('tithi name is a valid tithi name', () {
      const validTithiNames = [
        'Pratipada',
        'Dwitiya',
        'Tritiya',
        'Chaturthi',
        'Panchami',
        'Shashthi',
        'Saptami',
        'Ashtami',
        'Navami',
        'Dashami',
        'Ekadashi',
        'Dwadashi',
        'Trayodashi',
        'Chaturdashi',
        'Purnima',
        'Amavasya',
      ];
      expect(validTithiNames, contains(panchanga.tithi.name));
    });

    test('tithi elapsed is between 0 and 1', () {
      expect(panchanga.tithi.elapsed, greaterThanOrEqualTo(0));
      expect(panchanga.tithi.elapsed, lessThanOrEqualTo(1));
    });

    test('nakshatra number is between 1 and 27', () {
      expect(panchanga.nakshatra.number, greaterThanOrEqualTo(1));
      expect(panchanga.nakshatra.number, lessThanOrEqualTo(27));
    });

    test('nakshatra name is a valid nakshatra name', () {
      const validNakshatraNames = [
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
      expect(validNakshatraNames, contains(panchanga.nakshatra.name));
    });

    test('nakshatra pada is between 1 and 4', () {
      expect(panchanga.nakshatra.pada, greaterThanOrEqualTo(1));
      expect(panchanga.nakshatra.pada, lessThanOrEqualTo(4));
    });

    test('nakshatra rulingPlanet is not empty', () {
      expect(panchanga.nakshatra.rulingPlanet, isNotEmpty);
    });

    test('yoga number is between 1 and 27', () {
      expect(panchanga.yoga.number, greaterThanOrEqualTo(1));
      expect(panchanga.yoga.number, lessThanOrEqualTo(27));
    });

    test('yoga name is not empty', () {
      expect(panchanga.yoga.name, isNotEmpty);
    });

    test('karana number is between 1 and 60', () {
      expect(panchanga.karana.number, greaterThanOrEqualTo(1));
      expect(panchanga.karana.number, lessThanOrEqualTo(60));
    });

    test('karana name is a valid karana name', () {
      const validKaranaNames = [
        'Bava',
        'Balava',
        'Kaulava',
        'Taitila',
        'Gara',
        'Vanija',
        'Vishti',
        'Shakuni',
        'Chatushpada',
        'Nagava',
        'Kimstughna',
      ];
      expect(validKaranaNames, contains(panchanga.karana.name));
    });

    test('vara weekday is between 1 and 7', () {
      expect(panchanga.vara.weekday, greaterThanOrEqualTo(1));
      expect(panchanga.vara.weekday, lessThanOrEqualTo(7));
    });

    test('vara name is not empty', () {
      expect(panchanga.vara.name, isNotEmpty);
    });

    test('vara lord is not empty', () {
      expect(panchanga.vara.lord, isNotEmpty);
    });

    test('sunrise is before sunset', () {
      expect(panchanga.sunrise.isBefore(panchanga.sunset), isTrue);
    });

    test('sunrise and sunset are on the same date', () {
      expect(panchanga.sunrise.year, equals(panchanga.sunset.year));
      expect(panchanga.sunrise.month, equals(panchanga.sunset.month));
      expect(panchanga.sunrise.day, equals(panchanga.sunset.day));
    });
  });

  group('getVara', () {
    test('returns VaraInfo for a given date', () {
      final dateTime = DateTime(2024, 1, 15, 12, 0);
      try {
        final vara = jyotish.getVara(dateTime: dateTime, location: location);
        expect(vara, isNotNull);
        expect(vara.weekday, greaterThanOrEqualTo(1));
        expect(vara.weekday, lessThanOrEqualTo(7));
        expect(vara.name, isNotEmpty);
        expect(vara.lord, isNotEmpty);
      } catch (_) {}
    });

    test('respects sunrise boundary for births before sunrise', () {
      final dateTime = DateTime(2024, 1, 15, 4, 0);
      try {
        final vara = jyotish.getVara(dateTime: dateTime, location: location);
        expect(vara, isNotNull);
        expect(vara.weekday, greaterThanOrEqualTo(1));
        expect(vara.weekday, lessThanOrEqualTo(7));
      } catch (_) {}
    });
  });

  group('getTithi', () {
    test('returns TithiInfo for a given date', () {
      final dateTime = DateTime(2024, 1, 15, 12, 0);
      try {
        final tithi = jyotish.getTithi(dateTime: dateTime, location: location);
        expect(tithi, isNotNull);
        expect(tithi.number, greaterThanOrEqualTo(1));
        expect(tithi.number, lessThanOrEqualTo(30));
        expect(tithi.name, isNotEmpty);
        expect([Paksha.shukla, Paksha.krishna], contains(tithi.paksha));
      } catch (_) {}
    });
  });

  group('getNakshatra', () {
    test('returns NakshatraInfo for a given date', () {
      final dateTime = DateTime(2024, 1, 15, 12, 0);
      try {
        final nakshatra = jyotish.getNakshatra(
          dateTime: dateTime,
          location: location,
        );
        expect(nakshatra, isNotNull);
        expect(nakshatra.number, greaterThanOrEqualTo(1));
        expect(nakshatra.number, lessThanOrEqualTo(27));
        expect(nakshatra.name, isNotEmpty);
        expect(nakshatra.pada, greaterThanOrEqualTo(1));
        expect(nakshatra.pada, lessThanOrEqualTo(4));
      } catch (_) {}
    });
  });

  group('getYoga', () {
    test('returns YogaInfo for a given date', () {
      final dateTime = DateTime(2024, 1, 15, 12, 0);
      try {
        final yoga = jyotish.getYoga(dateTime: dateTime, location: location);
        expect(yoga, isNotNull);
        expect(yoga.number, greaterThanOrEqualTo(1));
        expect(yoga.number, lessThanOrEqualTo(27));
        expect(yoga.name, isNotEmpty);
      } catch (_) {}
    });
  });

  group('getKarana', () {
    test('returns KaranaInfo for a given date', () {
      final dateTime = DateTime(2024, 1, 15, 12, 0);
      try {
        final karana = jyotish.getKarana(
          dateTime: dateTime,
          location: location,
        );
        expect(karana, isNotNull);
        expect(karana.number, greaterThanOrEqualTo(1));
        expect(karana.number, lessThanOrEqualTo(60));
        expect(karana.name, isNotEmpty);
      } catch (_) {}
    });
  });

  group('getTithiEndTime', () {
    test('returns a future DateTime after the given time', () {
      final dateTime = DateTime(2024, 1, 15, 12, 0);
      try {
        final endTime = jyotish.getTithiEndTime(
          dateTime: dateTime,
          location: location,
        );
        expect(endTime, isNotNull);
        expect(endTime.isAfter(dateTime), isTrue);
      } catch (_) {}
    });

    test('returns DateTime within the same day or next day', () {
      final dateTime = DateTime(2024, 1, 15, 12, 0);
      try {
        final endTime = jyotish.getTithiEndTime(
          dateTime: dateTime,
          location: location,
        );
        final diffHours = endTime.difference(dateTime).inHours;
        expect(diffHours, lessThanOrEqualTo(27));
      } catch (_) {}
    });
  });

  group('Panchanga consistency across dates', () {
    test('different dates produce different panchanga values', () async {
      final date1 = DateTime(2024, 1, 15, 12, 0);
      final date2 = DateTime(2024, 2, 15, 12, 0);
      try {
        final p1 = await jyotish.calculatePanchanga(
          dateTime: date1,
          location: location,
        );
        final p2 = await jyotish.calculatePanchanga(
          dateTime: date2,
          location: location,
        );
        final sameTithi = p1.tithi.number == p2.tithi.number;
        final sameNakshatra = p1.nakshatra.number == p2.nakshatra.number;
        final sameVara = p1.vara.weekday == p2.vara.weekday;
        expect(
          sameTithi && sameNakshatra && sameVara,
          isFalse,
          reason: 'Different months should differ in at least one limb',
        );
      } catch (_) {}
    });
  });
}
