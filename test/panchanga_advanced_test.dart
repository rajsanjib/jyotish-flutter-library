import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

void main() {
  group('Advanced Panchanga Tests', () {
    late Jyotish jyotish;
    final location =
        GeographicLocation(latitude: 28.6139, longitude: 77.2090); // Delhi

    setUpAll(() async {
      jyotish = Jyotish();
      await jyotish.initialize();
    });

    test('Vedic Vara respects Sunrise boundary', () async {
      // Example: 2024-01-01 (Monday)
      // Sunrise in Delhi is approx 7:14 AM
      final dateAt4AM = DateTime(2024, 1, 1, 4, 0);
      final dateAt8AM = DateTime(2024, 1, 1, 8, 0);

      final vara4AM =
          await jyotish.getVara(dateTime: dateAt4AM, location: location);
      final vara8AM =
          await jyotish.getVara(dateTime: dateAt8AM, location: location);

      // 4 AM on Monday should still be Sunday (Vara = 0) in Vedic system
      expect(vara4AM.weekday, 0); // Sunday
      expect(vara4AM.name, 'Sunday');

      // 8 AM on Monday should be Monday (Vara = 1) in Vedic system
      expect(vara8AM.weekday, 1); // Monday
      expect(vara8AM.name, 'Monday');
    });

    test('Tithi End-Time calculation is accurate', () async {
      final dateTime = DateTime(2024, 1, 1, 12, 0);

      final endTime = await jyotish.getTithiEndTime(
        dateTime: dateTime,
        location: location,
      );

      expect(endTime.isAfter(dateTime), true);
      expect(endTime.difference(dateTime).inHours, lessThan(24));

      // Calculate elongation at end time
      final sunPos = await jyotish.getPlanetPosition(
        planet: Planet.sun,
        dateTime: endTime,
        location: location,
      );
      final moonPos = await jyotish.getPlanetPosition(
        planet: Planet.moon,
        dateTime: endTime,
        location: location,
      );

      final elongation = (moonPos.longitude - sunPos.longitude + 360) % 360;

      // Elongation should be exactly a multiple of 12 at the end time
      final remainder = elongation % 12.0;
      // Precision should be very high due to binary search
      expect(remainder, anyOf(closeTo(0.0, 0.01), closeTo(12.0, 0.01)));
    });
  });
}
