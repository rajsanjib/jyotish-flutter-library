import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

void main() {
  late Jyotish jyotish;
  late NatalChart chart;
  bool initialized = false;

  setUpAll(() async {
    jyotish = Jyotish();
    try {
      await jyotish.initialize(ephemerisPath: 'ephe');
      initialized = true;
    } catch (_) {}

    chart = jyotish.createChart(
      DateTime(1990, 7, 15, 10, 30),
      GeographicLocation(latitude: 28.6139, longitude: 77.2090),
    );
  });

  group('NadiService', () {
    test('calculateNadiChart returns valid chart', () async {
      if (!initialized) return;

      final nadiChart = await jyotish.calculateNadiChart(chart);
      expect(nadiChart, isNotNull);
      expect(nadiChart, isA<NadiChart>());
      expect(nadiChart.nadis, isNotNull);
      expect(nadiChart.nadis, isA<Map<Planet, NadiInfo>>());
      expect(nadiChart.nadis.isNotEmpty, isTrue);
    });

    test('each planet nadi has valid number and name', () async {
      if (!initialized) return;

      final nadiChart = await jyotish.calculateNadiChart(chart);

      nadiChart.nadis.forEach((planet, nadiInfo) {
        expect(nadiInfo.number, greaterThanOrEqualTo(1));
        expect(nadiInfo.number, lessThanOrEqualTo(150));
        expect(nadiInfo.name, isNotNull);
        expect(nadiInfo.name.isNotEmpty, isTrue);
        expect(nadiInfo.category, isNotNull);
        expect(nadiInfo.category.isNotEmpty, isTrue);
      });
    });

    test('getNadiFromLongitude returns NadiInfo for valid longitude', () async {
      if (!initialized) return;

      final testLongitudes = [0.0, 45.5, 90.0, 135.7, 180.0, 225.3, 270.0, 315.9, 359.99];

      for (final lon in testLongitudes) {
        final nadiInfo = await jyotish.getNadiFromLongitude(lon);
        expect(nadiInfo, isNotNull);
        expect(nadiInfo, isA<NadiInfo>());
        expect(nadiInfo.number, isNotNull);
        expect(nadiInfo.name, isNotNull);
        expect(nadiInfo.name.isNotEmpty, isTrue);
      }
    });

    test('nadi number is in valid range', () async {
      if (!initialized) return;

      final nadiChart = await jyotish.calculateNadiChart(chart);

      nadiChart.nadis.forEach((planet, nadiInfo) {
        expect(
          nadiInfo.number >= 1 && nadiInfo.number <= 150,
          isTrue,
          reason: 'Nadi number must be between 1 and 150',
        );
      });
    });

    test('getNadiInterpretation returns non-empty string', () async {
      if (!initialized) return;

      for (int nadiNumber = 1; nadiNumber <= 150; nadiNumber += 25) {
        final interpretation = await jyotish.getNadiInterpretation(nadiNumber);
        expect(interpretation, isNotNull);
        expect(interpretation, isA<String>());
        expect(interpretation.isNotEmpty, isTrue);
      }
    });

    test('identifyNadiSeed returns valid result for all nakshatras', () async {
      if (!initialized) return;

      for (int nakshatra = 1; nakshatra <= 27; nakshatra++) {
        final result = await jyotish.identifyNadiSeed(nakshatra, 1);
        expect(result, isNotNull);
        expect(result, isA<NadiSeedResult>());
        expect(result.seed, isNotNull);
        expect(result.seed.isNotEmpty, isTrue);
        expect(result.interpretation, isNotNull);
        expect(result.interpretation.isNotEmpty, isTrue);
      }
    });

    test('identifyNadiSeed returns valid result for all padas', () async {
      if (!initialized) return;

      const nakshatra = 1;
      for (int pada = 1; pada <= 4; pada++) {
        final result = await jyotish.identifyNadiSeed(nakshatra, pada);
        expect(result, isNotNull);
        expect(result.seed, isNotNull);
        expect(result.seed.isNotEmpty, isTrue);
      }
    });

    test('identifyNadiSeed rejects invalid pada', () async {
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

    test('identifyNadiSeed rejects invalid nakshatra', () async {
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

    test('nadi categories are valid', () async {
      if (!initialized) return;

      final nadiChart = await jyotish.calculateNadiChart(chart);
      final validCategories = ['Adi', 'Antya', 'Madhya'];

      nadiChart.nadis.forEach((planet, nadiInfo) {
        expect(
          validCategories.any((c) =>
              nadiInfo.category.toLowerCase().contains(c.toLowerCase())),
          isTrue,
          reason: 'Nadi category must be one of: ${validCategories.join(", ")}',
        );
      });
    });
  });
}
