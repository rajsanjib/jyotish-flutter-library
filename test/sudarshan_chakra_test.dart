import 'package:test/test.dart';
import 'package:jyotish/src/models/planet.dart';
import 'package:jyotish/src/models/sudarshan_chakra.dart';
import 'package:jyotish/src/services/sudarshan_chakra_service.dart';
import 'package:jyotish/src/models/vedic_chart.dart';
import 'package:jyotish/src/models/planet_position.dart';

void main() {
  group('SudarshanChakraService', () {
    late SudarshanChakraService service;

    setUp(() {
      service = SudarshanChakraService();
    });

    test('calculates house strengths for all 12 houses', () {
      // Create a mock chart with known positions
      final chart = _createMockChart(
        ascendant: 0.0, // Aries rising
        moonLongitude: 60.0, // Gemini (sign 2)
        sunLongitude: 30.0, // Taurus (sign 1)
      );

      final result = service.calculateSudarshanChakra(chart);

      // Verify all 12 houses are present
      expect(result.houseStrengths.length, equals(12));
      for (var i = 1; i <= 12; i++) {
        expect(result.houseStrengths.containsKey(i), isTrue);
      }

      // Verify sign indices are correct
      expect(result.lagnaSign, equals(0)); // Aries
      expect(result.chandraSign, equals(2)); // Gemini
      expect(result.suryaSign, equals(1)); // Taurus
    });

    test('calculates planet strengths for traditional planets', () {
      final chart = _createMockChart(
        ascendant: 0.0,
        moonLongitude: 60.0,
        sunLongitude: 30.0,
      );

      final result = service.calculateSudarshanChakra(chart);

      // Should have entries for traditional planets that are in the chart
      expect(result.planetStrengths.containsKey(Planet.sun), isTrue);
      expect(result.planetStrengths.containsKey(Planet.moon), isTrue);
    });

    test('house 1 from Lagna perspective is always house 1', () {
      final chart = _createMockChart(
        ascendant: 90.0, // Cancer rising (sign 3)
        moonLongitude: 180.0, // Libra (sign 6)
        sunLongitude: 270.0, // Capricorn (sign 9)
      );

      final result = service.calculateSudarshanChakra(chart);
      final house1 = result.houseStrengths[1]!;

      // House 1 from Lagna is always 1
      expect(house1.lagnaHouse, equals(1));
      // House 1 covers sign 3 (Cancer), from Moon (sign 6): (3 - 6 + 12) % 12 + 1 = 10
      expect(house1.chandraHouse, equals(10));
      // House 1 covers sign 3, from Sun (sign 9): (3 - 9 + 12) % 12 + 1 = 7
      expect(house1.suryaHouse, equals(7));
    });

    test('overall strength is calculated correctly', () {
      final chart = _createMockChart(
        ascendant: 0.0,
        moonLongitude: 0.0, // Same as Lagna
        sunLongitude: 0.0, // Same as Lagna
      );

      final result = service.calculateSudarshanChakra(chart);

      // When all three lagnas are the same sign, each house should have
      // identical perspective scores
      expect(result.overallStrength, greaterThan(0));
      expect(result.overallStrength, lessThanOrEqualTo(100));
    });

    test('strength categories are assigned correctly', () {
      expect(
        SudarshanStrengthCategory.fromScore(85),
        equals(SudarshanStrengthCategory.excellent),
      );
      expect(
        SudarshanStrengthCategory.fromScore(70),
        equals(SudarshanStrengthCategory.good),
      );
      expect(
        SudarshanStrengthCategory.fromScore(50),
        equals(SudarshanStrengthCategory.moderate),
      );
      expect(
        SudarshanStrengthCategory.fromScore(30),
        equals(SudarshanStrengthCategory.weak),
      );
      expect(
        SudarshanStrengthCategory.fromScore(10),
        equals(SudarshanStrengthCategory.veryWeak),
      );
    });
  });
}

/// Creates a minimal mock VedicChart for testing.
VedicChart _createMockChart({
  required double ascendant,
  required double moonLongitude,
  required double sunLongitude,
}) {
  final houses = HouseSystem(
    system: 'Whole Sign',
    cusps: List.generate(12, (i) => (ascendant + i * 30) % 360),
    ascendant: ascendant,
    midheaven: (ascendant + 270) % 360,
  );

  final sunPosition = PlanetPosition(
    planet: Planet.sun,
    dateTime: DateTime(2024, 1, 1),
    longitude: sunLongitude,
    latitude: 0.0,
    distance: 1.0,
    longitudeSpeed: 1.0,
    latitudeSpeed: 0.0,
    distanceSpeed: 0.0,
  );

  final moonPosition = PlanetPosition(
    planet: Planet.moon,
    dateTime: DateTime(2024, 1, 1),
    longitude: moonLongitude,
    latitude: 0.0,
    distance: 1.0,
    longitudeSpeed: 13.0,
    latitudeSpeed: 0.0,
    distanceSpeed: 0.0,
  );

  final planets = <Planet, VedicPlanetInfo>{
    Planet.sun: VedicPlanetInfo(
      position: sunPosition,
      house: houses.getHouseForLongitude(sunLongitude),
      dignity: PlanetaryDignity.neutralSign,
      isCombust: false,
    ),
    Planet.moon: VedicPlanetInfo(
      position: moonPosition,
      house: houses.getHouseForLongitude(moonLongitude),
      dignity: PlanetaryDignity.neutralSign,
      isCombust: false,
    ),
  };

  return VedicChart(
    dateTime: DateTime(2024, 1, 1),
    location: '0.0°N, 0.0°E',
    latitude: 0.0,
    longitudeCoord: 0.0,
    houses: houses,
    planets: planets,
    rahu: VedicPlanetInfo(
      position: sunPosition, // Placeholder
      house: 1,
      dignity: PlanetaryDignity.neutralSign,
      isCombust: false,
    ),
    ketu: KetuPosition(rahuPosition: sunPosition),
  );
}
