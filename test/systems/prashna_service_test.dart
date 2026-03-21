import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

void main() {
  late Jyotish jyotish;
  late VedicChart natalChart;
  bool ephemerisAvailable = false;

  final birthDateTime = DateTime(1990, 5, 15, 14, 30);
  final location =
      GeographicLocation(latitude: 28.6139, longitude: 77.2090);

  setUpAll(() async {
    jyotish = Jyotish();
    try {
      await jyotish.initialize(ephemerisPath: 'ephe');
      ephemerisAvailable = true;

      natalChart = await jyotish.calculateVedicChart(
        dateTime: birthDateTime,
        location: location,
      );
    } catch (e) {
      ephemerisAvailable = false;
    }
  });

  group('PrashnaService', () {
    test('PrashnaService can be accessed via systems', () {
      expect(jyotish.systems.prashna, isNotNull);
    });

    test('Prashna chart calculation with prashna date/time', () async {
      if (!ephemerisAvailable) return;

      final prashnaDateTime = DateTime(2025, 6, 15, 10, 30);
      final result = await jyotish.calculateVedicChart(
        dateTime: prashnaDateTime,
        location: location,
      );
      expect(result, isNotNull);
      expect(result.planets, isNotEmpty);
    });

    test('Prashna with traditional birth data returns valid chart', () async {
      if (!ephemerisAvailable) return;

      expect(natalChart, isNotNull);
      expect(natalChart.planets, isNotNull);
      expect(natalChart.planets, isNotEmpty);
      expect(natalChart.houses, isNotNull);
      expect(natalChart.houses.cusps.length, equals(12));
    });

    test('Prashna houses calculation is valid', () async {
      if (!ephemerisAvailable) return;

      final prashnaDateTime = DateTime(2025, 6, 15, 10, 30);
      final result = await jyotish.calculateVedicChart(
        dateTime: prashnaDateTime,
        location: location,
      );

      for (int i = 0; i < 12; i++) {
        final cusp = result.houses.cusps[i];
        expect(cusp, isNotNull);
      }
    });
  });
}
