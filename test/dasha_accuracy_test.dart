import 'package:flutter_test/flutter_test.dart';
import 'package:jyotish/jyotish.dart';

void main() {
  group('Dasha System Accuracy', () {
    test('Ashtottari Dasha calculates antardashas', () async {
      final dashaService = DashaService();
      final ephemeris = EphemerisService();
      await ephemeris.initialize(ephemerisPath: 'ephe');
      final vedicService = VedicChartService(ephemeris);

      final chart = await vedicService.calculateChart(
        dateTime: DateTime.utc(2023, 10, 15, 12, 0),
        location: GeographicLocation(latitude: 28.6139, longitude: 77.2090),
      );

      final ashtottari = dashaService.getAshtottariDasha(
        chart,
        forceCalculation: true,
        levels: 2,
      );

      expect(ashtottari.allMahadashas.first.subPeriods, isNotEmpty);
      expect(ashtottari.allMahadashas.first.subPeriods.length, equals(8));
    });

    test('Yogini Dasha uses index without offset', () async {
      final dashaService = DashaService();
      final ephemeris = EphemerisService();
      await ephemeris.initialize(ephemerisPath: 'ephe');
      final vedicService = VedicChartService(ephemeris);

      final chart = await vedicService.calculateChart(
        dateTime: DateTime.utc(2023, 10, 15, 12, 0),
        location: GeographicLocation(latitude: 28.6139, longitude: 77.2090),
      );

      final yogini = dashaService.calculateYoginiDasha(
          moonLongitude: chart.planets[Planet.moon]!.longitude,
          birthDateTime: chart.dateTime);
      expect(yogini.allMahadashas, isNotEmpty);
    });
  });
}
