import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

void main() {
  late Jyotish jyotish;
  late VedicChart chart;
  late Map<int, BhavaBalaResult> bhavaBala;

  setUpAll(() async {
    jyotish = Jyotish();
    try {
      await jyotish.initialize(ephemerisPath: 'ephe');
    } catch (_) {}
    chart = await jyotish.calculateVedicChart(
      dateTime: DateTime(2024, 1, 1, 12, 0),
      location: GeographicLocation(latitude: 28.6139, longitude: 77.2090),
    );
    try {
      bhavaBala = await jyotish.getBhavaBala(chart);
    } catch (_) {
      bhavaBala = {};
    }
  });

  group('Bhava Bala Service', () {
    test('returns results for all 12 houses', () {
      expect(bhavaBala.length, equals(12),
          reason: 'Should return results for exactly 12 houses');
      for (int i = 1; i <= 12; i++) {
        expect(bhavaBala.containsKey(i), isTrue,
            reason: 'House $i should have a BhavaBala result');
      }
    });

    test('each house has non-negative strength', () {
      for (final entry in bhavaBala.entries) {
        expect(entry.value.strength, greaterThanOrEqualTo(0),
            reason: 'House ${entry.key} strength should be non-negative');
      }
    });

    test('house numbers are 1-12', () {
      for (final key in bhavaBala.keys) {
        expect(key, inInclusiveRange(1, 12),
            reason: 'House number should be between 1 and 12');
      }
    });

    test('each house has valid bala components', () {
      for (final entry in bhavaBala.entries) {
        final result = entry.value;
        expect(result.lordStrength, greaterThanOrEqualTo(0),
            reason: 'House ${entry.key} lordStrength should be non-negative');
        expect(result.placementStrength, greaterThanOrEqualTo(0),
            reason: 'House ${entry.key} placementStrength should be non-negative');
        expect(result.digBala, greaterThanOrEqualTo(0),
            reason: 'House ${entry.key} digBala should be non-negative');
      }
    });
  });
}
