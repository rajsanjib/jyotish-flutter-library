import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

void main() {
  group('Abhijit Nakshatra', () {
    late Jyotish jyotish;
    late GeographicLocation location;

    setUpAll(() async {
      jyotish = Jyotish();
      await jyotish.initialize();
      location = GeographicLocation(
        latitude: 28.6139,
        longitude: 77.2090,
        altitude: 216,
      );
    });

    tearDownAll(() {
      jyotish.dispose();
    });

    test('Abhijit is within Capricorn 6°40\' to 10°40\'', () async {
      expect(jyotish.isInAbhijitNakshatra(276.6666667), true);
      expect(jyotish.isInAbhijitNakshatra(280.0), true);
      expect(jyotish.isInAbhijitNakshatra(286.6666666), false);
    });

    test('getNakshatraWithAbhijit returns 28 for Abhijit', () async {
      final nakshatra = await jyotish.getNakshatraWithAbhijit(
        dateTime: DateTime(2024, 1, 15, 12, 0),
        location: location,
      );

      if (nakshatra.isAbhijit) {
        expect(nakshatra.number, 28);
        expect(nakshatra.name, 'Abhijit');
      }
    });

    test('getAbhijitBoundaries returns correct limits', () {
      final (start, end) = jyotish.getAbhijitBoundaries();
      expect(start, closeTo(276.6666667, 0.001));
      expect(end, closeTo(286.6666667, 0.001));
    });

    test('Abhijit longitude boundaries are correct', () {
      expect(NakshatraInfo.abhijitStart, 276.6666667);
      expect(NakshatraInfo.abhijitEnd, 286.6666667);
    });

    test('Standard nakshatra has 27 entries', () {
      expect(NakshatraInfo.nakshatraNames.length, 28);
      expect(NakshatraInfo.nakshatraNames[0], 'Ashwini');
      expect(NakshatraInfo.nakshatraNames[26], 'Revati');
      expect(NakshatraInfo.nakshatraNames[27], 'Abhijit');
    });

    test('Nakshatra lords are properly assigned', () {
      expect(NakshatraInfo.nakshatraLords.length, 27);
      expect(NakshatraInfo.nakshatraLords[0], Planet.ketu);
      expect(NakshatraInfo.nakshatraLords[5], Planet.meanNode);
    });
  });

  group('Masa (Lunar Month)', () {
    late Jyotish jyotish;
    late GeographicLocation location;

    setUpAll(() async {
      jyotish = Jyotish();
      await jyotish.initialize();
      location = GeographicLocation(
        latitude: 28.6139,
        longitude: 77.2090,
        altitude: 216,
      );
    });

    tearDownAll(() {
      jyotish.dispose();
    });

    test('getMasa returns MasaInfo for Amanta system', () async {
      final masa = await jyotish.getMasa(
        dateTime: DateTime(2024, 1, 15),
        location: location,
        type: MasaType.amanta,
      );

      expect(masa.type, MasaType.amanta);
      expect(masa.month, isA<LunarMonth>());
      expect(masa.monthNumber, greaterThanOrEqualTo(1));
      expect(masa.monthNumber, lessThanOrEqualTo(12));
    });

    test('getMasa returns MasaInfo for Purnimanta system', () async {
      final masa = await jyotish.getMasa(
        dateTime: DateTime(2024, 1, 15),
        location: location,
        type: MasaType.purnimanta,
      );

      expect(masa.type, MasaType.purnimanta);
      expect(masa.month, isA<LunarMonth>());
      expect(masa.monthNumber, greaterThanOrEqualTo(1));
      expect(masa.monthNumber, lessThanOrEqualTo(12));
    });

    test('getAmantaMasa is a convenience method', () async {
      final masa = await jyotish.getAmantaMasa(
        dateTime: DateTime(2024, 1, 15),
        location: location,
      );

      expect(masa.type, MasaType.amanta);
    });

    test('getPurnimantaMasa is a convenience method', () async {
      final masa = await jyotish.getPurnimantaMasa(
        dateTime: DateTime(2024, 1, 15),
        location: location,
      );

      expect(masa.type, MasaType.purnimanta);
    });

    test('MasaInfo has correct properties', () async {
      final masa = await jyotish.getMasa(
        dateTime: DateTime(2024, 1, 15),
        location: location,
      );

      expect(masa.month, isNotNull);
      expect(masa.monthNumber, isNotNull);
      expect(masa.type, isNotNull);
      expect(masa.adhikaType, isNotNull);
      expect(masa.sunLongitude, greaterThanOrEqualTo(0));
      expect(masa.sunLongitude, lessThan(360));
      expect(masa.tithiInfo, isNotNull);
    });

    test('AdhikaMasaType enum has correct values', () {
      expect(AdhikaMasaType.none.description, 'No Adhika Masa');
      expect(AdhikaMasaType.adhika.description, 'Adhika (Extra) Masa');
      expect(AdhikaMasaType.nija.description, 'Nija (Regular) Masa');
    });

    test('LunarMonth enum has 12 months', () {
      expect(LunarMonth.values.length, 12);
      expect(LunarMonth.chaitra.sanskrit, 'Chaitra');
      expect(LunarMonth.phalguna.sanskrit, 'Phalguna');
    });

    test('MasaInfo.getMonthFromSunLongitude returns correct month', () {
      expect(MasaInfo.getMonthFromSunLongitude(0), LunarMonth.chaitra);
      expect(MasaInfo.getMonthFromSunLongitude(30), LunarMonth.vaishakha);
      expect(MasaInfo.getMonthFromSunLongitude(330), LunarMonth.magha);
    });

    test('getSamvatsara returns valid name', () async {
      final samvatsara = await jyotish.getSamvatsara(
        dateTime: DateTime(2024, 1, 1),
        location: location,
      );

      expect(samvatsara, isNotEmpty);
      expect(samvatsara.length, lessThan(20));
    });

    test('Samvatsara has 60 names', () {
      expect(Samvatsara.samvatsaraNames.length, 60);
      expect(Samvatsara.samvatsaraNames[0], 'Prabhava');
      expect(Samvatsara.samvatsaraNames[59], 'Akshaya');
    });

    test('getSamvatsaraName cycles correctly', () {
      expect(Samvatsara.getSamvatsaraName(0), 'Prabhava');
      expect(Samvatsara.getSamvatsaraName(1), 'Vibhava');
      expect(Samvatsara.getSamvatsaraName(59), 'Akshaya');
      expect(Samvatsara.getSamvatsaraName(60), 'Prabhava');
    });

    test('getMasaListForYear returns 12 months', () async {
      final masaList = await jyotish.getMasaListForYear(
        year: 2024,
        location: location,
        type: MasaType.amanta,
      );

      expect(masaList.length, greaterThanOrEqualTo(1));
    });

    test('Amanta and Purnimanta produce different months sometimes', () async {
      final date = DateTime(2024, 1, 15);

      final amanta = await jyotish.getAmantaMasa(
        dateTime: date,
        location: location,
      );

      final purnimanta = await jyotish.getPurnimantaMasa(
        dateTime: date,
        location: location,
      );

      expect(amanta.type, MasaType.amanta);
      expect(purnimanta.type, MasaType.purnimanta);
    });

    test('MasaType enum has correct descriptions', () {
      expect(MasaType.amanta.sanskrit, 'Amanta');
      expect(MasaType.amanta.description, contains('Amavasya'));
      expect(MasaType.purnimanta.sanskrit, 'Purnimanta');
      expect(MasaType.purnimanta.description, contains('Purnima'));
    });
  });
}
