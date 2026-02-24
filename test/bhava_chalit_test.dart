import 'package:flutter_test/flutter_test.dart';
import 'package:jyotish_flutter_library_fork/jyotish.dart';

void main() {
  group('Bhava Chalit calculation', () {
    test('Mid-cusp logic bounds test', () async {
      final service = BhavaChalitService();
      final vedicService = VedicChartService();

      final chart = await vedicService.calculateChart(
        dateTime: DateTime.utc(2023, 10, 15, 12, 0),
        location:
            const GeographicLocation(latitude: 28.6139, longitude: 77.2090),
      );

      final bhavaChalit = service.calculateSriPatiChart(chart);

      final ascendant = chart.ascendant;
      expect(bhavaChalit.houses[1]?.midpoint, closeTo(ascendant, 0.01));
    });
  });
}
