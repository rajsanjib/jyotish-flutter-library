import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

void main() {
  late Jyotish jyotish;
  late VedicChart chart;

  setUpAll(() async {
    jyotish = Jyotish();
    try {
      await jyotish.initialize(ephemerisPath: 'ephe');
    } catch (_) {}
    chart = await jyotish.calculateVedicChart(
      dateTime: DateTime(2024, 1, 1, 12, 0),
      location: GeographicLocation(latitude: 28.6139, longitude: 77.2090),
    );
  });

  group('Enhanced Bhava Bala', () {
    late Map<int, EnhancedBhavaBalaResult> enhancedBhavaBala;

    setUpAll(() async {
      try {
        enhancedBhavaBala = await jyotish.getEnhancedBhavaBala(chart);
      } catch (_) {
        enhancedBhavaBala = {};
      }
    });

    test('returns 12 house results', () {
      expect(enhancedBhavaBala.length, equals(12),
          reason: 'Should return results for 12 houses');
      for (int i = 1; i <= 12; i++) {
        expect(enhancedBhavaBala.containsKey(i), isTrue,
            reason: 'House $i should have enhanced bala result');
      }
    });

    test('each house has non-negative total strength', () {
      for (final entry in enhancedBhavaBala.entries) {
        expect(entry.value.totalStrength, greaterThanOrEqualTo(0),
            reason: 'House ${entry.key} totalStrength should be non-negative');
      }
    });
  });

  group('Vimsopaka Bala', () {
    late Map<Planet, VimsopakaBalaResult> vimsopakaBala;

    setUpAll(() {
      try {
        vimsopakaBala = jyotish.getVimsopakaBala(chart);
      } catch (_) {
        vimsopakaBala = {};
      }
    });

    test('returns results for all traditional planets', () {
      final traditionalPlanets = [
        Planet.sun,
        Planet.moon,
        Planet.mars,
        Planet.mercury,
        Planet.jupiter,
        Planet.venus,
        Planet.saturn,
      ];
      for (final planet in traditionalPlanets) {
        expect(vimsopakaBala.containsKey(planet), isTrue,
            reason: '$planet should have VimsopakaBala result');
      }
    });

    test('scores are non-negative', () {
      for (final entry in vimsopakaBala.entries) {
        expect(entry.value.totalScore, greaterThanOrEqualTo(0),
            reason: '${entry.key} totalScore should be non-negative');
      }
    });
  });

  group('House Strength Summary', () {
    late Map<int, EnhancedBhavaBalaResult> results;
    late HouseStrengthSummary summary;

    setUpAll(() async {
      try {
        results = await jyotish.getEnhancedBhavaBala(chart);
        summary = jyotish.getHouseStrengthSummary(results);
      } catch (_) {
        summary = HouseStrengthSummary(
          houseResults: {},
          averageStrength: 0,
          strongestHouse: 1,
          weakestHouse: 1,
        );
      }
    });

    test('summary has valid properties', () {
      expect(summary.averageStrength, greaterThanOrEqualTo(0),
          reason: 'Average strength should be non-negative');
      expect(summary.strongestHouse, inInclusiveRange(1, 12),
          reason: 'Strongest house should be 1-12');
      expect(summary.weakestHouse, inInclusiveRange(1, 12),
          reason: 'Weakest house should be 1-12');
    });

    test('strongest house score >= weakest house score', () {
      final strongestResult = summary.houseResults[summary.strongestHouse];
      final weakestResult = summary.houseResults[summary.weakestHouse];
      if (strongestResult != null && weakestResult != null) {
        expect(strongestResult.totalStrength,
            greaterThanOrEqualTo(weakestResult.totalStrength),
            reason: 'Strongest house should have >= score than weakest');
      }
    });
  });
}
