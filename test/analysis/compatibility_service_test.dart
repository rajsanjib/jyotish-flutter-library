import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

void main() {
  late Jyotish jyotish;
  late VedicChart boyChart;
  late VedicChart girlChart;
  bool initialized = false;

  setUpAll(() async {
    jyotish = Jyotish();
    try {
      await jyotish.initialize(ephemerisPath: 'ephe');
      initialized = true;
    } catch (_) {}

    boyChart = await jyotish.calculateVedicChart(
      dateTime: DateTime(1990, 7, 15, 10, 30),
      location: GeographicLocation(latitude: 28.6139, longitude: 77.2090),
    );

    girlChart = await jyotish.calculateVedicChart(
      dateTime: DateTime(1992, 3, 22, 8, 45),
      location: GeographicLocation(latitude: 19.0760, longitude: 72.8777),
    );
  });

  group('CompatibilityService', () {
    test('calculateGunaMilan returns scores summing to 0-36', () async {
      if (!initialized) return;

      final scores = jyotish.calculateGunaMilan(boyChart, girlChart);
      expect(scores, isNotNull);
      expect(scores, isA<GunaScores>());
      expect(scores.total, greaterThanOrEqualTo(0.0));
      expect(scores.total, lessThanOrEqualTo(36.0));

      final manualTotal = scores.varna +
          scores.vashya +
          scores.tara +
          scores.yoni +
          scores.grahaMaitri +
          scores.gana +
          scores.bhakoot +
          scores.nadi;
      expect(scores.total, equals(manualTotal));
    });

    test('varna score is 0 or 1', () async {
      if (!initialized) return;

      final scores = jyotish.calculateGunaMilan(boyChart, girlChart);
      expect(scores.varna, isIn([0, 1]));
    });

    test('vashya score is 0-2', () async {
      if (!initialized) return;

      final scores = jyotish.calculateGunaMilan(boyChart, girlChart);
      expect(scores.vashya, greaterThanOrEqualTo(0));
      expect(scores.vashya, lessThanOrEqualTo(2));
    });

    test('tara score is 0-3', () async {
      if (!initialized) return;

      final scores = jyotish.calculateGunaMilan(boyChart, girlChart);
      expect(scores.tara, greaterThanOrEqualTo(0.0));
      expect(scores.tara, lessThanOrEqualTo(3.0));
    });

    test('yoni score is 0-4', () async {
      if (!initialized) return;

      final scores = jyotish.calculateGunaMilan(boyChart, girlChart);
      expect(scores.yoni, greaterThanOrEqualTo(0));
      expect(scores.yoni, lessThanOrEqualTo(4));
    });

    test('grahaMaitri score is 0-5', () async {
      if (!initialized) return;

      final scores = jyotish.calculateGunaMilan(boyChart, girlChart);
      expect(scores.grahaMaitri, greaterThanOrEqualTo(0));
      expect(scores.grahaMaitri, lessThanOrEqualTo(5));
    });

    test('gana score is 0-6', () async {
      if (!initialized) return;

      final scores = jyotish.calculateGunaMilan(boyChart, girlChart);
      expect(scores.gana, greaterThanOrEqualTo(0));
      expect(scores.gana, lessThanOrEqualTo(6));
    });

    test('bhakoot score is 0-7', () async {
      if (!initialized) return;

      final scores = jyotish.calculateGunaMilan(boyChart, girlChart);
      expect(scores.bhakoot, greaterThanOrEqualTo(0));
      expect(scores.bhakoot, lessThanOrEqualTo(7));
    });

    test('nadi score is 0-8', () async {
      if (!initialized) return;

      final scores = jyotish.calculateGunaMilan(boyChart, girlChart);
      expect(scores.nadi, greaterThanOrEqualTo(0));
      expect(scores.nadi, lessThanOrEqualTo(8));
    });

    test('checkManglikDosha returns valid result', () async {
      if (!initialized) return;

      final result = jyotish.checkManglikDosha(boyChart);
      expect(result, isNotNull);
      expect(result, isA<ManglikDoshaResult>());
      expect(result.isManglik, isA<bool>());
      expect(result.housesAffected, isNotNull);
      expect(result.housesAffected, isA<List<int>>());
      expect(result.severity, isNotNull);
      expect(result.remedies, isNotNull);
      expect(result.remedies, isA<List<String>>());
    });

    test('compatibility level is valid', () async {
      if (!initialized) return;

      final result = jyotish.calculateCompatibility(boyChart, girlChart);
      expect(result, isNotNull);
      expect(result, isA<CompatibilityResult>());
      expect(result.level, isNotNull);
      expect(result.level, isA<CompatibilityLevel>());

      expect(
        [
          CompatibilityLevel.excellent,
          CompatibilityLevel.veryGood,
          CompatibilityLevel.good,
          CompatibilityLevel.average,
          CompatibilityLevel.poor,
        ].contains(result.level),
        isTrue,
        reason: 'Level must be a valid CompatibilityLevel',
      );
    });

    test('calculateCompatibility adjusts score for doshas', () async {
      if (!initialized) return;

      final gunaMilan = jyotish.calculateGunaMilan(boyChart, girlChart);
      final compatibility = jyotish.calculateCompatibility(boyChart, girlChart);

      expect(compatibility.totalScore, greaterThanOrEqualTo(0.0));
      expect(compatibility.totalScore, lessThanOrEqualTo(36.0));
      expect(compatibility.gunaScores, isNotNull);
      expect(compatibility.doshaCheck, isNotNull);
      expect(compatibility.doshaCheck, isA<DoshaCheck>());

      if (compatibility.doshaCheck.hasManglikDosha) {
        expect(
          compatibility.totalScore <= gunaMilan.total,
          isTrue,
          reason: 'Manglik dosha should reduce or keep same total score',
        );
      }
    });

    test('checkNadiDosha returns boolean result', () async {
      if (!initialized) return;

      final result = jyotish.checkNadiDosha(boyChart, girlChart);
      expect(result, isNotNull);
      expect(result.hasDosha, isA<bool>());
      expect(result.boyNadi, isNotNull);
      expect(result.girlNadi, isNotNull);
    });

    test('checkBhakootDosha returns boolean result', () async {
      if (!initialized) return;

      final result = jyotish.checkBhakootDosha(boyChart, girlChart);
      expect(result, isNotNull);
      expect(result.hasDosha, isA<bool>());
      expect(result.boyRashi, isNotNull);
      expect(result.girlRashi, isNotNull);
      expect(result.description, isNotNull);
    });
  });
}
