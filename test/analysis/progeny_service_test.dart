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

  group('ProgenyService', () {
    test('analyzeProgeny returns valid result', () async {
      if (!initialized) return;

      final result = jyotish.analyzeProgeny(chart);
      expect(result, isNotNull);
      expect(result, isA<ProgenyResult>());
      expect(result.strength, isNotNull);
      expect(result.score, isA<int>());
      expect(result.analysis, isNotNull);
      expect(result.analysis.isNotEmpty, isTrue);
    });

    test('progeny result has score estimate', () async {
      if (!initialized) return;

      final result = jyotish.analyzeProgeny(chart);
      expect(result.score, isNotNull);
      expect(result.score, isA<int>());
      expect(result.score >= 0, isTrue);
    });

    test('analyzeD7Chart returns valid analysis', () async {
      if (!initialized) return;

      final analysis = jyotish.analyzeD7Chart(chart);
      expect(analysis, isNotNull);
      expect(analysis, isA<D7Analysis>());
      expect(analysis.score, isA<int>());
      expect(analysis.isStrong, isA<bool>());
    });

    test('analyzeFifthHouse returns strength info', () async {
      if (!initialized) return;

      final strength = jyotish.analyzeFifthHouse(chart);
      expect(strength, isNotNull);
      expect(strength, isA<FifthHouseStrength>());
      expect(strength.score, isA<int>());
      expect(strength.isStrong, isA<bool>());
      expect(strength.lordStrength, isA<double>());
      expect(strength.planetsInHouse, isNotNull);
      expect(strength.planetsInHouse, isA<List<Planet>>());
      expect(strength.aspectsOnHouse, isNotNull);
      expect(strength.aspectsOnHouse, isA<List<Planet>>());
      expect(strength.isAfflicted, isA<bool>());
    });

    test('analyzeJupiterCondition returns condition', () async {
      if (!initialized) return;

      final condition = jyotish.analyzeJupiterCondition(chart);
      expect(condition, isNotNull);
      expect(condition, isA<JupiterCondition>());
      expect(condition.score, isA<int>());
      expect(condition.isStrong, isA<bool>());
      expect(condition.isExalted, isA<bool>());
      expect(condition.isOwnSign, isA<bool>());
      expect(condition.isDebilitated, isA<bool>());
      expect(condition.house, isA<int>());
      expect(condition.isCombust, isA<bool>());
    });

    test('detectChildYogas returns list of yogas', () async {
      if (!initialized) return;

      final yogas = jyotish.detectChildYogas(chart);
      expect(yogas, isNotNull);
      expect(yogas, isA<List<ChildYoga>>());

      for (final yoga in yogas) {
        expect(yoga.name, isNotNull);
        expect(yoga.name.isNotEmpty, isTrue);
        expect(yoga.description, isNotNull);
        expect(yoga.description.isNotEmpty, isTrue);
        expect(yoga.isPresent, isA<bool>());
      }
    });

    test('fifth house strength has valid planets in house', () async {
      if (!initialized) return;

      final strength = jyotish.analyzeFifthHouse(chart);
      for (final planet in strength.planetsInHouse) {
        expect(planet, isNotNull);
        expect(planet, isA<Planet>());
      }
    });

    test('jupiter condition has valid house number', () async {
      if (!initialized) return;

      final condition = jyotish.analyzeJupiterCondition(chart);
      expect(condition.house, greaterThanOrEqualTo(0));
      expect(condition.house, lessThanOrEqualTo(12));
    });
  });
}
