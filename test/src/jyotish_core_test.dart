import 'package:test/test.dart';
import 'package:jyotish/jyotish.dart';

void main() {
  group('Jyotish Core Facade', () {
    late Jyotish jyotish;

    setUp(() async {
      jyotish = Jyotish();
      await jyotish.initialize();
    });

    test('getPlanetPosition returns a valid position', () async {
      final position = await jyotish.getPlanetPosition(
        planet: Planet.sun,
        dateTime: DateTime.now(),
        location: GeographicLocation(
          latitude: 27.7172,
          longitude: 85.3240,
        ),
      );

      expect(position, isNotNull);
      expect(position.planet, equals(Planet.sun));
      expect(position.longitude, isNonNegative);
    });

    test('calculateVedicChart generates a chart', () async {
      final chart = await jyotish.calculateVedicChart(
        dateTime: DateTime.now(),
        location: GeographicLocation(
          latitude: 27.7172,
          longitude: 85.3240,
        ),
      );

      expect(chart, isNotNull);
      expect(chart.planets.length, greaterThan(0));
      expect(chart.houses, isNotNull);
    });
  });
}
