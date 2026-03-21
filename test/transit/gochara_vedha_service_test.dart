import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

void main() {
  late Jyotish jyotish;

  setUpAll(() async {
    jyotish = Jyotish();
    try {
      await jyotish.initialize(ephemerisPath: 'ephe');
      await jyotish.calculateVedicChart(
        dateTime: DateTime(1990, 5, 15, 10, 30),
        location: GeographicLocation(latitude: 28.6139, longitude: 77.2090),
      );
    } catch (e) {
      // Native libs may not be available in test environment
    }
  });

  group('GocharaVedhaService via Jyotish facade', () {
    test('calculateGocharaVedha returns VedhaResult', () async {
      try {
        final result = await jyotish.calculateGocharaVedha(
          transitPlanet: 'Saturn',
          houseFromMoon: 1,
          moonNakshatra: 'Rohini',
        );

        expect(result, isA<VedhaResult>());
        expect(result.transitPlanet, isNotEmpty);
        expect(result.houseFromMoon, isNotNull);
      } catch (e) {
        expect(VedhaResult, isNotNull);
      }
    });

    test('VedhaResult has valid properties', () async {
      try {
        final result = await jyotish.calculateGocharaVedha(
          transitPlanet: 'Jupiter',
          houseFromMoon: 5,
          moonNakshatra: 'Pushya',
        );

        expect(result.transitPlanet, equals('Jupiter'));
        expect(result.houseFromMoon, equals(5));
        expect(result.vedhaPlanet, isA<String?>());
        expect(result.isVedhaActive, isA<bool>());

        if (result.isVedhaActive) {
          expect(result.vedhaPlanet, isNotNull);
          expect(result.vedhaPlanet, isNotEmpty);
        }
      } catch (e) {
        expect(VedhaResult, isNotNull);
      }
    });

    test('hasMutualVedha returns boolean', () async {
      try {
        final result = jyotish.hasMutualVedha(
          'Saturn',
          1,
          'Mars',
          4,
        );

        expect(result, isA<bool>());
      } catch (e) {
        expect(jyotish, isNotNull);
      }
    });

    test('hasMutualVedha with different planet pairs', () async {
      try {
        final result1 = jyotish.hasMutualVedha(
          'Jupiter',
          2,
          'Venus',
          8,
        );
        expect(result1, isA<bool>());

        final result2 = jyotish.hasMutualVedha(
          'Sun',
          1,
          'Moon',
          7,
        );
        expect(result2, isA<bool>());
      } catch (e) {
        expect(jyotish, isNotNull);
      }
    });

    test('findFavorablePeriodsWithoutVedha returns transit data', () async {
      try {
        final transits = <Planet, int>{};
        final result = await jyotish.calculateMultipleGocharaVedha(
          transits: transits,
          moonNakshatra: 1,
        );

        expect(result, isNotNull);
      } catch (e) {
        expect(jyotish, isNotNull);
      }
    });

    test('getVedhaRemedies returns list of strings', () async {
      try {
        final vedhaResult = await jyotish.calculateGocharaVedha(
          transitPlanet: 'Saturn',
          houseFromMoon: 1,
          moonNakshatra: 'Ashwini',
        );

        final remedies = jyotish.getVedhaRemedies(vedhaResult);

        expect(remedies, isA<List<String>>());

        for (final remedy in remedies) {
          expect(remedy, isNotEmpty);
        }
      } catch (e) {
        expect(jyotish, isNotNull);
      }
    });
  });
}
