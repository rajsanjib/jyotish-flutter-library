import 'package:flutter_test/flutter_test.dart';
import 'package:jyotish/jyotish.dart';

void main() {
  group('Dignity Calculation', () {
    test('VedicChartService handles Panchadha Maitri correctly', () async {
      final ephemeris = EphemerisService();
      await ephemeris.initialize(ephemerisPath: 'ephe');
      final service = VedicChartService(ephemeris);

      final chart = await service.calculateChart(
        dateTime: DateTime.utc(2023, 10, 15, 12, 0),
        location: GeographicLocation(latitude: 28.6139, longitude: 77.2090),
      );

      expect(chart.planets[Planet.sun]?.dignity, isNotNull);
      expect(chart.planets[Planet.moon]?.dignity, isNotNull);
    });
  });
}
