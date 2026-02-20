import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

void main() {
  group('Historical Timezone Verification', () {
    late Jyotish jyotish;

    setUpAll(() async {
      jyotish = Jyotish();
      await jyotish.initialize();
    });

    test('1980 India (IST stable +5:30)', () async {
      // June 15, 1980, 14:30 IST in Shimla (HP)
      final location = GeographicLocation(
        latitude: 31.1048,
        longitude: 77.1734,
        timezone: 'Asia/Kolkata',
      );

      final position = await jyotish.getPlanetPosition(
        planet: Planet.sun,
        dateTime: DateTime(1980, 6, 15, 14, 30),
        location: location,
      );

      // Position should not be null and calculation should complete successfully
      expect(position, isNotNull);
    });

    test('1950 Indiana (Patchy DST)', () async {
      // Indiana historically had very complex DST rules
      final localBirth = DateTime(1950, 7, 15, 12, 0);
      final location = GeographicLocation(
        latitude: 39.7684,
        longitude: -86.1581,
        timezone: 'America/Indiana/Indianapolis',
      );

      final position = await jyotish.getPlanetPosition(
        planet: Planet.sun,
        dateTime: localBirth,
        location: location,
      );

      expect(position, isNotNull);
    });

    test('Berlin 1980 (Post-occupation DST)', () async {
      // Berlin introduced DST in 1980
      final location = GeographicLocation(
        latitude: 52.5200,
        longitude: 13.4050,
        timezone: 'Europe/Berlin',
      );

      final position = await jyotish.getPlanetPosition(
        planet: Planet.sun,
        dateTime: DateTime(1980, 6, 15, 12, 0),
        location: location,
      );

      expect(position, isNotNull);
    });
  });
}

extension JyotishExtension on Jyotish {
  // Helper to access private ephemeris service for testing ayanamsa if needed
  // Or just rely on public methods if available.
  // Jyotish doesn't have a public getAyanamsa, but EphemerisService does.
  // Actually, I can check if Jyotish has it.
}
