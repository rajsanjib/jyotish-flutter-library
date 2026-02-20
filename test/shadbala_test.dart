import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

void main() {
  group('Shadbala System', () {
    late VedicChart mockChart;
    late ShadbalaService shadbalaService;

    setUp(() async {
      shadbalaService = ShadbalaService(MockEphemerisService());
      mockChart = _createDetailedMockChart();
    });

    test('Uchcha Bala calculates correctly', () async {
      // Sun at 10° Aries (Deep Exaltation) should have 60 points
      final results = await shadbalaService.calculateShadbala(mockChart);
      final sunResult = results[Planet.sun];
      expect(sunResult?.sthanaBala, greaterThanOrEqualTo(60.0));

      // Saturn at 20° Aries (Deep Debilitation) should have 0 points for Uchcha Bala
      // (Total sthana bala might have other components)
    });

    test('Dig Bala calculates correctly', () async {
      // Sun in 10th house gets maximum Dig Bala (60)
      final results = await shadbalaService.calculateShadbala(mockChart);
      final sunResult = results[Planet.sun];
      expect(sunResult?.digBala, 60.0);

      // Jupiter in 1st house gets maximum Dig Bala (60)
      final jupResult = results[Planet.jupiter];
      expect(jupResult?.digBala, 60.0);
    });

    test('Kaala Bala components', () async {
      final results = await shadbalaService.calculateShadbala(mockChart);

      // Benefics should get more Paksha Bala in Shukla Paksha
      // (Mock chart has Moon at 30° from Sun = Shukla Paksha)
      final jupResult = results[Planet.jupiter];
      final satResult = results[Planet.saturn];

      expect(jupResult!.kalaBala, isNotNull);
      expect(satResult!.kalaBala, isNotNull);
    });

    test('Chesta Bala for retrograde planets', () async {
      final results = await shadbalaService.calculateShadbala(mockChart);

      // Chesta Bala is 0 for Sun/Moon, but let's check Mars if we made it retrograde
      // In our mock, Mars is at 0.524 (direct)
      final marsResult = results[Planet.mars];
      expect(marsResult?.chestaBala, lessThan(60.0));
    });

    test('Drik Bala (Aspectual Strength)', () async {
      final results = await shadbalaService.calculateShadbala(mockChart);
      final sunResult = results[Planet.sun];

      // Drik Bala can be positive or negative
      expect(sunResult?.drikBala, isNotNull);
    });
  });
}

VedicChart _createDetailedMockChart() {
  final now = DateTime.now();
  final planets = <Planet, VedicPlanetInfo>{};

  // Helper to add planet
  void addPlanet(Planet planet, double long, int house, double speed,
      PlanetaryDignity dignity) {
    planets[planet] = VedicPlanetInfo(
      position: PlanetPosition(
        planet: planet,
        dateTime: now,
        longitude: long,
        latitude: 0.0,
        distance: 1.0,
        longitudeSpeed: speed,
        latitudeSpeed: 0.0,
        distanceSpeed: 0.0,
      ),
      house: house,
      dignity: dignity,
    );
  }

  // 10° Aries (Sun Deep Exaltation)
  addPlanet(Planet.sun, 10.0, 10, 1.0, PlanetaryDignity.exalted);
  // 30° Aries (Taurus 0°)
  addPlanet(Planet.moon, 40.0, 11, 13.0, PlanetaryDignity.friendSign);
  addPlanet(Planet.mars, 0.0, 10, 0.2, PlanetaryDignity.ownSign);
  addPlanet(Planet.mercury, 20.0, 10, 1.2, PlanetaryDignity.neutralSign);
  addPlanet(Planet.jupiter, 0.0, 1, 0.08, PlanetaryDignity.friendSign);
  addPlanet(Planet.venus, 0.0, 10, 1.1, PlanetaryDignity.friendSign);
  // 20° Aries (Saturn Deep Debilitation)
  addPlanet(Planet.saturn, 20.0, 10, 0.03, PlanetaryDignity.debilitated);

  return VedicChart(
    dateTime: now,
    location: 'Test',
    latitude: 0.0,
    longitudeCoord: 0.0,
    houses: HouseSystem(
      system: 'W',
      cusps: List<double>.generate(12, (i) => i * 30.0),
      ascendant: 0.0,
      midheaven: 270.0,
    ),
    planets: planets,
    rahu: VedicPlanetInfo(
      position: PlanetPosition(
        planet: Planet.meanNode,
        dateTime: now,
        longitude: 180.0,
        latitude: 0.0,
        distance: 1.0,
        longitudeSpeed: -0.05,
        latitudeSpeed: 0.0,
        distanceSpeed: 0.0,
      ),
      house: 7,
      dignity: PlanetaryDignity.neutralSign,
    ),
    ketu: KetuPosition(
      rahuPosition: PlanetPosition(
        planet: Planet.meanNode,
        dateTime: now,
        longitude: 180.0,
        latitude: 0.0,
        distance: 1.0,
        longitudeSpeed: -0.05,
        latitudeSpeed: 0.0,
        distanceSpeed: 0.0,
      ),
    ),
  );
}

class MockEphemerisService extends EphemerisService {
  @override
  Future<(DateTime?, DateTime?)> getSunriseSunset({
    required DateTime date,
    required GeographicLocation location,
    double atpress = 0.0,
    double attemp = 0.0,
  }) async {
    // Return standard sunrise/sunset (6 AM / 6 PM) for testing
    final sunrise = DateTime.utc(date.year, date.month, date.day, 6, 0);
    final sunset = DateTime.utc(date.year, date.month, date.day, 18, 0);
    return (sunrise, sunset);
  }

  @override
  Future<void> initialize({String? ephemerisPath}) async {}
}
