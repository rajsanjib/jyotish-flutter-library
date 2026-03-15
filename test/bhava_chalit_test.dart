import 'package:flutter_test/flutter_test.dart';
import 'package:jyotish/jyotish.dart';

void main() {
  group('Bhava Chalit calculation', () {
    test('Mid-cusp logic bounds test', () async {
      final service = BhavaChalitService();
      final ephemeris = EphemerisService();
      await ephemeris.initialize(ephemerisPath: 'ephe');
      final vedicService = VedicChartService(ephemeris);

      final chart = await vedicService.calculateChart(
        dateTime: DateTime.utc(2023, 10, 15, 12, 0),
        location: GeographicLocation(latitude: 28.6139, longitude: 77.2090),
        houseSystem: 'P', // Placidus  cusp 1 is Ascendant
      );

      final bhavaChalit = service.calculateBhavaChalit(chart);

      final ascendant = chart.houses.ascendant;
      // In Bhava Chalit using midpoint logic, the cusp of a house
      // is usually the center of that house, not the start.
      expect(bhavaChalit.bhavas[0].cusp, closeTo(ascendant, 0.01));
    });
  });
}
