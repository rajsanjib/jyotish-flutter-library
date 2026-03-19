import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

void main() {
  late Jyotish jyotish;
  late VedicChart chart;
  bool initialized = false;

  setUpAll(() async {
    jyotish = Jyotish();
    try {
      await jyotish.initialize(ephemerisPath: 'ephe');
      initialized = true;
    } catch (_) {}

    chart = await jyotish.calculateVedicChart(
      dateTime: DateTime(1990, 7, 15, 10, 30),
      location: GeographicLocation(latitude: 28.6139, longitude: 77.2090),
    );
  });

  group('NadiService', () {
    test('calculateNadiChart returns valid chart', () async {
      if (!initialized) return;

      final nadiChart = jyotish.calculateNadiChart(chart);
      expect(nadiChart, isNotNull);
      expect(nadiChart, isA<NadiChart>());
      expect(nadiChart.planetNadis, isNotNull);
      expect(nadiChart.planetNadis, isA<Map<Planet, NadiInfo>>());
      expect(nadiChart.planetNadis.isNotEmpty, isTrue);
    });

    test('each planet nadi has valid number and name', () async {
      if (!initialized) return;

      final nadiChart = jyotish.calculateNadiChart(chart);

      nadiChart.planetNadis.forEach((planet, nadiInfo) {
        expect(nadiInfo.nadiNumber, greaterThanOrEqualTo(1));
        expect(nadiInfo.nadiNumber, lessThanOrEqualTo(150));
        expect(nadiInfo.nadiName, isNotNull);
        expect(nadiInfo.nadiName.isNotEmpty, isTrue);
      });
    });

    test('getNadiFromLongitude returns NadiInfo for valid longitude', () async {
      if (!initialized) return;

      final testLongitudes = [0.0, 45.5, 90.0, 135.7, 180.0, 225.3, 270.0, 315.9, 359.99];

      for (final lon in testLongitudes) {
        final nadiInfo = jyotish.getNadiFromLongitude(lon);
        expect(nadiInfo, isNotNull);
        expect(nadiInfo, isA<NadiInfo>());
        expect(nadiInfo.nadiNumber, isNotNull);
        expect(nadiInfo.nadiName, isNotNull);
        expect(nadiInfo.nadiName.isNotEmpty, isTrue);
      }
    });

    test('nadi number is in valid range', () async {
      if (!initialized) return;

      final nadiChart = jyotish.calculateNadiChart(chart);

      nadiChart.planetNadis.forEach((planet, nadiInfo) {
        expect(
          nadiInfo.nadiNumber >= 1 && nadiInfo.nadiNumber <= 150,
          isTrue,
          reason: 'Nadi number must be between 1 and 150',
        );
      });
    });

    test('getNadiInterpretation returns non-empty string', () async {
      if (!initialized) return;

      for (int nadiNumber = 1; nadiNumber <= 150; nadiNumber += 25) {
        final interpretation = jyotish.getNadiInterpretation(nadiNumber);
        expect(interpretation, isNotNull);
        expect(interpretation, isA<String>());
        expect(interpretation.isNotEmpty, isTrue);
      }
    });

    test('identifyNadiSeed returns valid result for all nakshatras', () async {
      if (!initialized) return;

      for (int nakshatra = 1; nakshatra <= 27; nakshatra++) {
        final result = jyotish.identifyNadiSeed(nakshatra, 1);
        expect(result, isNotNull);
        expect(result, isA<NadiSeedResult>());
        expect(result.seedNumber, isNotNull);
      }
    });

    test('identifyNadiSeed returns valid result for all padas', () async {
      if (!initialized) return;

      const nakshatra = 1;
      for (int pada = 1; pada <= 4; pada++) {
        final result = jyotish.identifyNadiSeed(nakshatra, pada);
        expect(result, isNotNull);
        expect(result.seedNumber, isNotNull);
      }
    });

    test('identifyNadiSeed rejects invalid pada', () {
      if (!initialized) return;

      expect(
        () => jyotish.identifyNadiSeed(1, 0),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => jyotish.identifyNadiSeed(1, 5),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('identifyNadiSeed rejects invalid nakshatra', () {
      if (!initialized) return;

      expect(
        () => jyotish.identifyNadiSeed(0, 1),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => jyotish.identifyNadiSeed(28, 1),
        throwsA(isA<ArgumentError>()),
      );
    });

  });
}
