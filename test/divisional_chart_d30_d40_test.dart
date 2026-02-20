import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

void main() {
  group('DivisionalChartService - D30 and D40', () {
    late Jyotish jyotish;

    setUp(() {
      jyotish = Jyotish();
    });

    VedicChart createMockChart(double longitude, {int signIndex = 0}) {
      final absoluteLongitude = (signIndex * 30.0) + longitude;

      final houses = HouseSystem(
        system: 'Whole Sign',
        cusps: List.generate(12, (i) => i * 30.0),
        ascendant: 10.0,
        midheaven: 270.0,
      );

      final planets = {
        Planet.sun: VedicPlanetInfo(
          position: PlanetPosition(
            planet: Planet.sun,
            dateTime: DateTime.now(),
            longitude: absoluteLongitude,
            latitude: 0,
            distance: 1,
            longitudeSpeed: 1,
            latitudeSpeed: 0,
            distanceSpeed: 0,
          ),
          house: (absoluteLongitude / 30).floor() + 1,
          dignity: PlanetaryDignity.neutralSign,
        ),
      };

      return VedicChart(
        dateTime: DateTime.now(),
        location: 'Test',
        latitude: 0,
        longitudeCoord: 0,
        houses: houses,
        planets: planets,
        rahu: planets[Planet.sun]!,
        ketu: KetuPosition(rahuPosition: planets[Planet.sun]!.position),
      );
    }

    test('D30 - Aries (Odd) at 3° (0-5 range) -> Aries', () {
      final chart = createMockChart(3.0, signIndex: 0); // Aries
      final d30 = jyotish.getDivisionalChart(
          rashiChart: chart, type: DivisionalChartType.d30);
      expect(d30.planets[Planet.sun]!.zodiacSign, 'Aries');
    });

    test('D30 - Aries (Odd) at 8° (5-10 range) -> Aquarius', () {
      final chart = createMockChart(8.0, signIndex: 0); // Aries
      final d30 = jyotish.getDivisionalChart(
          rashiChart: chart, type: DivisionalChartType.d30);
      expect(d30.planets[Planet.sun]!.zodiacSign, 'Aquarius');
    });

    test('D30 - Taurus (Even) at 3° (0-5 range) -> Taurus', () {
      final chart = createMockChart(3.0, signIndex: 1); // Taurus
      final d30 = jyotish.getDivisionalChart(
          rashiChart: chart, type: DivisionalChartType.d30);
      expect(d30.planets[Planet.sun]!.zodiacSign, 'Taurus');
    });

    test('D30 - Taurus (Even) at 8° (5-12 range) -> Virgo', () {
      final chart = createMockChart(8.0, signIndex: 1); // Taurus
      final d30 = jyotish.getDivisionalChart(
          rashiChart: chart, type: DivisionalChartType.d30);
      expect(d30.planets[Planet.sun]!.zodiacSign, 'Virgo');
    });

    test('D40 - Aries (Odd) at 0.5° (Part 0) -> Aries', () {
      // 30/40 = 0.75 deg per part. 0.5 is in part 0.
      final chart = createMockChart(0.5, signIndex: 0); // Aries
      final d40 = jyotish.getDivisionalChart(
          rashiChart: chart, type: DivisionalChartType.d40);
      expect(d40.planets[Planet.sun]!.zodiacSign, 'Aries');
    });

    test('D40 - Taurus (Even) at 0.5° (Part 0) -> Libra', () {
      // 30/40 = 0.75 deg per part. 0.5 is in part 0.
      // Even starts from Libra (6). 6 + 0 = 6 (Libra).
      final chart = createMockChart(0.5, signIndex: 1); // Taurus
      final d40 = jyotish.getDivisionalChart(
          rashiChart: chart, type: DivisionalChartType.d40);
      expect(d40.planets[Planet.sun]!.zodiacSign, 'Libra');
    });
  });
}
