import 'package:flutter_test/flutter_test.dart';
import 'package:jyotish/jyotish.dart';

void main() {
  group('Dosha Service Tests (Parity with PyJHora)', () {
    final now = DateTime.now();
    const service = DoshaService();

    // Helper to create mock PlanetPosition
    PlanetPosition mockPos(Planet planet, double longitude) {
      return PlanetPosition(
        planet: planet,
        dateTime: now,
        longitude: longitude,
        latitude: 0.0,
        distance: 1.0,
        longitudeSpeed: 1.0,
        latitudeSpeed: 0.0,
        distanceSpeed: 0.0,
      );
    }

    test('Kala Sarpa Dosha detection', () {
      final houses = HouseSystem(
        system: 'Whole Sign',
        cusps: List.generate(12, (i) => i * 30.0),
        ascendant: 15.0, // Aries Lagna
        midheaven: 270.0,
      );

      // Rahu in Aries (House 1, Sign index 0)
      final rahuPos = mockPos(Planet.meanNode, 15.0);
      final rahuInfo = VedicPlanetInfo(
        position: rahuPos,
        house: 1,
        dignity: PlanetaryDignity.neutralSign,
      );
      final ketu = KetuPosition(
          rahuPosition: rahuPos); // Ketu is in Libra (House 7, Sign index 6)

      // Place all traditional planets in houses 1 to 7 (Aries to Libra)
      // Aries (1): Sun (10.0), Moon (20.0)
      // Taurus (2): Mars (45.0)
      // Gemini (3): Mercury (75.0)
      // Cancer (4): Jupiter (105.0)
      // Leo (5): Venus (135.0)
      // Virgo (6): Saturn (165.0)
      final Map<Planet, VedicPlanetInfo> planets = {
        Planet.sun: VedicPlanetInfo(
          position: mockPos(Planet.sun, 10.0),
          house: 1,
          dignity: PlanetaryDignity.neutralSign,
        ),
        Planet.moon: VedicPlanetInfo(
          position: mockPos(Planet.moon, 20.0),
          house: 1,
          dignity: PlanetaryDignity.neutralSign,
        ),
        Planet.mars: VedicPlanetInfo(
          position: mockPos(Planet.mars, 45.0),
          house: 2,
          dignity: PlanetaryDignity.neutralSign,
        ),
        Planet.mercury: VedicPlanetInfo(
          position: mockPos(Planet.mercury, 75.0),
          house: 3,
          dignity: PlanetaryDignity.neutralSign,
        ),
        Planet.jupiter: VedicPlanetInfo(
          position: mockPos(Planet.jupiter, 105.0),
          house: 4,
          dignity: PlanetaryDignity.neutralSign,
        ),
        Planet.venus: VedicPlanetInfo(
          position: mockPos(Planet.venus, 135.0),
          house: 5,
          dignity: PlanetaryDignity.neutralSign,
        ),
        Planet.saturn: VedicPlanetInfo(
          position: mockPos(Planet.saturn, 165.0),
          house: 6,
          dignity: PlanetaryDignity.neutralSign,
        ),
      };

      final chart = VedicChart(
        dateTime: now,
        location: 'Test Location',
        latitude: 13.0,
        longitudeCoord: 80.0,
        houses: houses,
        planets: planets,
        rahu: rahuInfo,
        ketu: ketu,
      );

      final result = service.checkKalaSarpaDosha(chart);
      expect(result.hasDosha, isTrue);
      expect(result.type, equals('Anant'));
    });

    test('Guru Chandala Dosha detection and mitigation', () {
      final houses = HouseSystem(
        system: 'Whole Sign',
        cusps: List.generate(12, (i) => i * 30.0),
        ascendant: 15.0,
        midheaven: 270.0,
      );

      // Rahu in Cancer (House 4, longitude 105)
      final rahuPos = mockPos(Planet.meanNode, 105.0);
      final rahuInfo = VedicPlanetInfo(
        position: rahuPos,
        house: 4,
        dignity: PlanetaryDignity.neutralSign,
      );
      final ketu = KetuPosition(rahuPosition: rahuPos);

      // Jupiter also in Cancer (House 4) -> Conjunction!
      final jupInfo = VedicPlanetInfo(
        position: mockPos(Planet.jupiter, 100.0),
        house: 4,
        dignity: PlanetaryDignity.exalted, // Jupiter exalted in Cancer
      );

      final Map<Planet, VedicPlanetInfo> planets = {
        Planet.sun: VedicPlanetInfo(
          position: mockPos(Planet.sun, 10.0),
          house: 1,
          dignity: PlanetaryDignity.neutralSign,
        ),
        Planet.moon: VedicPlanetInfo(
          position: mockPos(Planet.moon, 20.0),
          house: 1,
          dignity: PlanetaryDignity.neutralSign,
        ),
        Planet.mars: VedicPlanetInfo(
          position: mockPos(Planet.mars, 45.0),
          house: 2,
          dignity: PlanetaryDignity.neutralSign,
        ),
        Planet.mercury: VedicPlanetInfo(
          position: mockPos(Planet.mercury, 75.0),
          house: 3,
          dignity: PlanetaryDignity.neutralSign,
        ),
        Planet.jupiter: jupInfo,
        Planet.venus: VedicPlanetInfo(
          position: mockPos(Planet.venus, 135.0),
          house: 5,
          dignity: PlanetaryDignity.neutralSign,
        ),
        Planet.saturn: VedicPlanetInfo(
          position: mockPos(Planet.saturn, 165.0),
          house: 6,
          dignity: PlanetaryDignity.neutralSign,
        ),
      };

      final chart = VedicChart(
        dateTime: now,
        location: 'Test Location',
        latitude: 13.0,
        longitudeCoord: 80.0,
        houses: houses,
        planets: planets,
        rahu: rahuInfo,
        ketu: ketu,
      );

      final result = service.checkGuruChandalaDosha(chart);
      expect(result.hasDosha, isTrue);
      expect(result.jupiterIsStronger, isTrue); // Exalted Jupiter mitigates it!
    });

    test('Ganda Moola Dosha detection', () {
      final houses = HouseSystem(
        system: 'Whole Sign',
        cusps: List.generate(12, (i) => i * 30.0),
        ascendant: 15.0,
        midheaven: 270.0,
      );

      // Moon in Ashwini Nakshatra (Longitude 5.0 -> Index 0)
      final moonPos = PlanetPosition(
        planet: Planet.moon,
        dateTime: now,
        longitude: 5.0,
        latitude: 0.0,
        distance: 1.0,
        longitudeSpeed: 13.0,
        latitudeSpeed: 0.0,
        distanceSpeed: 0.0,
      );
      final moonInfo = VedicPlanetInfo(
        position: moonPos,
        house: 1,
        dignity: PlanetaryDignity.neutralSign,
      );

      final Map<Planet, VedicPlanetInfo> planets = {
        Planet.sun: VedicPlanetInfo(
          position: mockPos(Planet.sun, 10.0),
          house: 1,
          dignity: PlanetaryDignity.neutralSign,
        ),
        Planet.moon: moonInfo,
        Planet.mars: VedicPlanetInfo(
          position: mockPos(Planet.mars, 45.0),
          house: 2,
          dignity: PlanetaryDignity.neutralSign,
        ),
        Planet.mercury: VedicPlanetInfo(
          position: mockPos(Planet.mercury, 75.0),
          house: 3,
          dignity: PlanetaryDignity.neutralSign,
        ),
        Planet.jupiter: VedicPlanetInfo(
          position: mockPos(Planet.jupiter, 105.0),
          house: 4,
          dignity: PlanetaryDignity.neutralSign,
        ),
        Planet.venus: VedicPlanetInfo(
          position: mockPos(Planet.venus, 135.0),
          house: 5,
          dignity: PlanetaryDignity.neutralSign,
        ),
        Planet.saturn: VedicPlanetInfo(
          position: mockPos(Planet.saturn, 165.0),
          house: 6,
          dignity: PlanetaryDignity.neutralSign,
        ),
      };

      final chart = VedicChart(
        dateTime: now,
        location: 'Test Location',
        latitude: 13.0,
        longitudeCoord: 80.0,
        houses: houses,
        planets: planets,
        rahu: VedicPlanetInfo(
          position: mockPos(Planet.meanNode, 185.0),
          house: 7,
          dignity: PlanetaryDignity.neutralSign,
        ),
        ketu: KetuPosition(rahuPosition: mockPos(Planet.meanNode, 185.0)),
      );

      final result = service.checkGandaMoolaDosha(chart);
      expect(result.hasDosha, isTrue);
      expect(result.nakshatra, equals('Ashwini'));
    });

    test('Ghata and Shrapit conjunction doshas', () {
      final houses = HouseSystem(
        system: 'Whole Sign',
        cusps: List.generate(12, (i) => i * 30.0),
        ascendant: 15.0,
        midheaven: 270.0,
      );

      // Conjoin Mars, Saturn, and Rahu in house 5 (Leo)
      final rahuPos = mockPos(Planet.meanNode, 135.0);
      final rahuInfo = VedicPlanetInfo(
        position: rahuPos,
        house: 5,
        dignity: PlanetaryDignity.neutralSign,
      );

      final Map<Planet, VedicPlanetInfo> planets = {
        Planet.sun: VedicPlanetInfo(
          position: mockPos(Planet.sun, 10.0),
          house: 1,
          dignity: PlanetaryDignity.neutralSign,
        ),
        Planet.moon: VedicPlanetInfo(
          position: mockPos(Planet.moon, 20.0),
          house: 1,
          dignity: PlanetaryDignity.neutralSign,
        ),
        Planet.mars: VedicPlanetInfo(
          position: mockPos(Planet.mars, 140.0),
          house: 5,
          dignity: PlanetaryDignity.neutralSign,
        ),
        Planet.mercury: VedicPlanetInfo(
          position: mockPos(Planet.mercury, 75.0),
          house: 3,
          dignity: PlanetaryDignity.neutralSign,
        ),
        Planet.jupiter: VedicPlanetInfo(
          position: mockPos(Planet.jupiter, 105.0),
          house: 4,
          dignity: PlanetaryDignity.neutralSign,
        ),
        Planet.venus: VedicPlanetInfo(
          position: mockPos(Planet.venus, 130.0),
          house: 5,
          dignity: PlanetaryDignity.neutralSign,
        ),
        Planet.saturn: VedicPlanetInfo(
          position: mockPos(Planet.saturn, 145.0),
          house: 5,
          dignity: PlanetaryDignity.neutralSign,
        ),
      };

      final chart = VedicChart(
        dateTime: now,
        location: 'Test Location',
        latitude: 13.0,
        longitudeCoord: 80.0,
        houses: houses,
        planets: planets,
        rahu: rahuInfo,
        ketu: KetuPosition(rahuPosition: rahuPos),
      );

      final ghataRes = service.checkGhataDosha(chart);
      final shrapitRes = service.checkShrapitDosha(chart);

      expect(ghataRes.hasDosha, isTrue);
      expect(shrapitRes.hasDosha, isTrue);
    });
  });
}
