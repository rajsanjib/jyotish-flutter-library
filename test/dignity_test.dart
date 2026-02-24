import 'package:flutter_test/flutter_test.dart';
import 'package:jyotish_flutter_library_fork/jyotish.dart';

void main() {
  group('Dignity Calculation', () {
    test('VedicChartService handles Panchadha Maitri correctly', () async {
      final service = VedicChartService();

      final chart = await service.calculateChart(
        dateTime: DateTime.utc(2023, 10, 15, 12, 0),
        location:
            const GeographicLocation(latitude: 28.6139, longitude: 77.2090),
      );

      expect(chart.planets[Planet.sun]?.dignity, isNotNull);
      expect(chart.planets[Planet.moon]?.dignity, isNotNull);
    });
  });
}
