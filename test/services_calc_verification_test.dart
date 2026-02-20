import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

// Mock Ephemeris Service
class MockEphemerisService extends EphemerisService {
  @override
  Future<(DateTime?, DateTime?)> getSunriseSunset({
    required DateTime date,
    required GeographicLocation location,
    double atpress = 0.0,
    double attemp = 0.0,
  }) async {
    // 6 AM Sunrise, 6 PM Sunset for easy calculation
    final sunrise = DateTime.utc(date.year, date.month, date.day, 6, 0);
    final sunset = DateTime.utc(date.year, date.month, date.day, 18, 0);
    return (sunrise, sunset);
  }

  @override
  Future<void> initialize({String? ephemerisPath}) async {}
}

// Helper to create a chart
VedicChart _createMockChart() {
  final now = DateTime.utc(2023, 1, 1, 12, 0); // Noon
  final planets = <Planet, VedicPlanetInfo>{};

  // Helper to add planet
  void addPlanet(
      Planet planet, double long, int house, PlanetaryDignity dignity) {
    planets[planet] = VedicPlanetInfo(
      position: PlanetPosition(
        planet: planet,
        dateTime: now,
        longitude: long,
        latitude: 0.0,
        distance: 1.0,
        longitudeSpeed: 1.0,
        latitudeSpeed: 0.0,
        distanceSpeed: 0.0,
      ),
      house: house,
      dignity: dignity,
    );
  }

  // Sun Exalted in Aries (10 deg)
  addPlanet(Planet.sun, 10.0, 1, PlanetaryDignity.exalted);
  // Saturn Debilitated in Aries (20 deg)
  addPlanet(Planet.saturn, 20.0, 1, PlanetaryDignity.debilitated);
  // Mars in Capricorn (Exalted) 280 deg
  addPlanet(Planet.mars, 280.0, 10, PlanetaryDignity.exalted);
  // Jupiter in Cancer (Exalted) 95 deg
  addPlanet(Planet.jupiter, 95.0, 4, PlanetaryDignity.exalted);
  // Venus in Pisces (Exalted) 355 deg
  addPlanet(Planet.venus, 355.0, 12, PlanetaryDignity.exalted);
  // Mercury in Virgo (Exalted) 165 deg
  addPlanet(Planet.mercury, 165.0, 6, PlanetaryDignity.exalted);
  // Moon in Taurus (Exalted) 35 deg
  addPlanet(Planet.moon, 35.0, 2, PlanetaryDignity.exalted);

  return VedicChart(
    dateTime: now,
    location: 'Test',
    latitude: 0.0,
    longitudeCoord: 0.0,
    houses: HouseSystem(
      // Minimal Mock
      system: 'E',
      cusps: List.generate(12, (i) => i * 30.0),
      ascendant: 0.0,
      midheaven: 270.0,
    ),
    planets: planets,
    rahu: VedicPlanetInfo(
        position: PlanetPosition(
            planet: Planet.meanNode,
            dateTime: now,
            longitude: 0,
            latitude: 0,
            distance: 0,
            longitudeSpeed: 0,
            latitudeSpeed: 0,
            distanceSpeed: 0),
        house: 1,
        dignity: PlanetaryDignity.neutralSign),
    ketu: KetuPosition(
        rahuPosition: PlanetPosition(
            planet: Planet.meanNode,
            dateTime: now,
            longitude: 0,
            latitude: 0,
            distance: 0,
            longitudeSpeed: 0,
            latitudeSpeed: 0,
            distanceSpeed: 0)),
  );
}

void main() {
  group('Verification of Calculations', () {
    late VedicChart chart;
    late ShadbalaService shadbalaService;
    late BhavaBalaService bhavaBalaService;
    late GowriPanchangamService gowriService;

    setUp(() {
      chart = _createMockChart();
      final eph = MockEphemerisService();
      shadbalaService = ShadbalaService(eph);
      bhavaBalaService = BhavaBalaService(shadbalaService);
      gowriService = GowriPanchangamService(eph);
    });

    test('Vimshopaka Bala is dynamic', () {
      // Sun is Exalted (Dignity.exalted) -> Should be max points in D1
      // Saturn is Debilitated -> Should be 0 points in D1
      // Note: Test uses simplified mock where we don't calculate real D-charts for D2-D30,
      // but ShadbalaService calls `_divisionalChartService.calculateDivisionalChart`.
      // We need to ensure `DivisionalChartService` works without crashing on mock.
      // `ShadbalaService` instantiates `DivisionalChartService` internally.
      // If D-Chart calculus relies on finding planet in map, real logic will run.
      // For this test, we accept that D2-D30 might be "random" or calculated from D1 positions.

      final sunVim = shadbalaService.calculateVimshopakaBala(Planet.sun, chart);
      final satVim =
          shadbalaService.calculateVimshopakaBala(Planet.saturn, chart);

      print('Sun Vimshopaka: $sunVim');
      print('Saturn Vimshopaka: $satVim');

      // Previous hardcoded value was 15.0.
      // Current logic: Sun is Exalted in D1 (Weight 6, Points 20).
      // Even if other Vargas are average, Sun should be high.
      // Saturn is Debilitated in D1 (Weight 6, Points 0).
      // Saturn should be lower than Sun.

      expect(sunVim, isNot(15.0));
      expect(satVim, isNot(15.0));
      expect(sunVim, greaterThan(satVim));
    });

    test('Bhava Drishti Bala is dynamic', () async {
      final bhavaBala = await bhavaBalaService.calculateBhavaBala(chart);

      // Check House 7 (Libra, 180 deg).
      // Sun (10 deg Aries) aspects House 7 (Opposite) fully?
      // 180 - 10 = 170 deg? No, House 7 cusp is 180.
      // 180 - 10 = 170. Angle is 170.
      // Formula for 150-180: (Angle-150)*2 = (170-150)*2 = 40.
      // So Sun contributes 40 Strength (Malefic -> -40 / 4 = -10).

      // Let's check drishtiBala value.
      final h7 = bhavaBala[7];
      print('House 7 Drishti Bala: ${h7?.aspectStrength}');

      expect(h7?.aspectStrength, isNot(30.0)); // Old hardcoded value
    });

    test('Gowri Panchangam Night Sequence', () async {
      // Friday (5)
      // Friday Day: Soolai, Visham, Nirkku, Uthi, Amrit, Rogam, Labham, Dhana
      // Friday Night Rule: Starts with 6th of Day -> Rogam.

      // Let's mock a Friday Night time.
      // DateTime: Friday 2023-01-06 (Jan 6 2023 was Fri).
      // 8 PM (20:00). Sunset is 18:00.
      // Night 0: 18:00 - 19:30 (Rogam)
      // Night 1: 19:30 - 21:00 (Labham)

      final friNight = DateTime.utc(
          2023, 1, 6, 19, 45); // 1.75 hours after sunset -> Period 2 (Index 1)
      // If sequence starts with Rogam (Index 0), next is Labham (Index 1).

      final info = await gowriService.getCurrentGowriPanchangam(
          dateTime: friNight,
          location: GeographicLocation(latitude: 0, longitude: 0, altitude: 0));

      print('Friday Night Period 2 Gowri: ${info.type}');
      // Should be Labham if Sequence is Rogam, Labham...

      // Saturday (6)
      // Sat Day: Visham...
      // Sat Night starts with 6th of Day -> Labham.
      // Sequence: Labham, Dhana, Soolai...
      // Period 1 (Index 0) -> Labham.

      final satNight =
          DateTime.utc(2023, 1, 7, 18, 10); // 10 mins after sunset -> Period 1
      final infoSat = await gowriService.getCurrentGowriPanchangam(
          dateTime: satNight,
          location: GeographicLocation(latitude: 0, longitude: 0, altitude: 0));

      print('Saturday Night Period 1 Gowri: ${infoSat.type}');

      expect(infoSat.type, GowriType.labhamu);
    });
  });
}
