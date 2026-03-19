import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

void main() {
  late EphemerisService ephemerisService;
  bool ephemerisInitialized = false;

  final location = GeographicLocation(
    latitude: 28.6139,
    longitude: 77.2090,
    timezone: 'Asia/Kolkata',
  );

  setUpAll(() async {
    ephemerisService = EphemerisService();
    try {
      await ephemerisService.initialize(ephemerisPath: 'ephe');
      ephemerisInitialized = true;
    } catch (e) {
      print('Warning: Ephemeris initialization failed: $e');
    }
  });

  group('EphemerisService', () {
    test('initialization succeeds with valid ephe path', () async {
      final service = EphemerisService();
      await service.initialize(ephemerisPath: 'ephe');
      expect(service.isInitialized, isTrue);
    });

    test('calculating Sun position returns valid longitude (0-360)',
        () async {
      if (!ephemerisInitialized) return;

      final date = DateTime(2024, 1, 1, 12, 0, 0);

      final result = await ephemerisService.calculatePlanetPosition(
        planet: Planet.sun,
        dateTime: date,
        location: location,
        flags: CalculationFlags.defaultFlags(),
      );

      expect(result.longitude, greaterThanOrEqualTo(0));
      expect(result.longitude, lessThanOrEqualTo(360));
      expect(result.longitudeSpeed, isNotNull);
    });

    test('calculating Moon position returns valid data', () async {
      if (!ephemerisInitialized) return;

      final date = DateTime(2024, 1, 15, 12, 0, 0);

      final result = await ephemerisService.calculatePlanetPosition(
        planet: Planet.moon,
        dateTime: date,
        location: location,
        flags: CalculationFlags.defaultFlags(),
      );

      expect(result.longitude, greaterThanOrEqualTo(0));
      expect(result.longitude, lessThanOrEqualTo(360));
      expect(result.distance, greaterThan(0));
    });

    test('calculating all traditional planets returns non-empty map',
        () async {
      if (!ephemerisInitialized) return;

      final date = DateTime(2024, 6, 21, 12, 0, 0);

      final planets = [
        Planet.sun,
        Planet.moon,
        Planet.mars,
        Planet.mercury,
        Planet.jupiter,
        Planet.venus,
        Planet.saturn,
      ];

      final results = <Planet, PlanetPosition>{};
      for (final planet in planets) {
        results[planet] = await ephemerisService.calculatePlanetPosition(
          planet: planet,
          dateTime: date,
          location: location,
          flags: CalculationFlags.defaultFlags(),
        );
      }

      expect(results.length, equals(7));
      for (final entry in results.entries) {
        expect(entry.value.longitude, greaterThanOrEqualTo(0));
        expect(entry.value.longitude, lessThanOrEqualTo(360));
      }
    });

    test('calculateHouses returns 12 cusps and ascendant', () async {
      if (!ephemerisInitialized) return;

      final date = DateTime(2024, 3, 21, 10, 0, 0);

      final houses = await ephemerisService.calculateHouses(
        dateTime: date,
        location: location,
        houseSystem: 'P',
      );

      expect(houses['cusps']!.length, equals(12));
      expect(houses['ascmc']![0], greaterThanOrEqualTo(0));
      expect(houses['ascmc']![0], lessThan(360));

      for (final cusp in houses['cusps']!) {
        expect(cusp, greaterThanOrEqualTo(0));
        expect(cusp, lessThan(360));
      }
    });

    test('getSunriseSunset returns sunrise before sunset', () async {
      if (!ephemerisInitialized) return;

      final date = DateTime(2024, 6, 15);

      final (sunrise, sunset) = await ephemerisService.getSunriseSunset(
        date: date,
        location: location,
      );

      expect(sunrise, isNotNull);
      expect(sunset, isNotNull);
      expect(sunrise!.isBefore(sunset!), isTrue);
    });

    test('uninitialized service throws CalculationException', () async {
      final uninitializedService = EphemerisService();
      final date = DateTime(2024, 1, 1, 12, 0, 0);

      expect(
        () => uninitializedService.calculatePlanetPosition(
          planet: Planet.sun,
          dateTime: date,
          location: location,
          flags: CalculationFlags.defaultFlags(),
        ),
        throwsA(isA<CalculationException>()),
      );
    });
  });
}
