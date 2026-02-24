import 'package:flutter_test/flutter_test.dart';
import 'package:jyotish_flutter_library_fork/jyotish.dart';

void main() {
  group('Dasha System Accuracy', () {
    final dashaService = DashaService();
    final vedicService = VedicChartService();

    test('Ashtottari Dasha calculates antardashas', () async {
      final chart = await vedicService.calculateChart(
        dateTime: DateTime.utc(2023, 10, 15, 12, 0),
        location:
            const GeographicLocation(latitude: 28.6139, longitude: 77.2090),
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
      final chart = await vedicService.calculateChart(
        dateTime: DateTime.utc(2023, 10, 15, 12, 0),
        location:
            const GeographicLocation(latitude: 28.6139, longitude: 77.2090),
      );

      final yogini = dashaService.calculateYoginiDasha(
          moonLongitude: chart.planets[Planet.moon]!.longitude,
          birthDateTime: chart.dateTime);
      expect(yogini.allMahadashas, isNotEmpty);
    });
  });
}
