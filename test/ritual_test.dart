import 'package:test/test.dart';
import 'package:jyotish/jyotish.dart';

void main() {
  group('Ritual Elements Tests', () {
    late RitualService ritualService;

    setUp(() {
      ritualService = RitualService();
    });

    test('calculateRitualElements assigns valid ritual fields', () {
      const tithi = TithiInfo(
          number: 1, name: 'Pratipada', paksha: Paksha.shukla, elapsed: 0.5);
      const nakshatra = NakshatraInfo(
          number: 1,
          name: 'Ashwini',
          rulingPlanet: Planet.ketu,
          longitude: 10.0,
          pada: 1,
          isAbhijit: false,
          abhijitPortion: 0.0);
      const vara =
          VaraInfo(name: 'Sunday', weekday: 0, rulingPlanet: Planet.sun);

      final panchanga = Panchanga(
        dateTime: DateTime(2026, 3, 4),
        location: '0,0',
        tithi: tithi,
        nakshatra: nakshatra,
        yoga: const YogaInfo(number: 1, name: 'Vishkumbha', elapsed: 0.0),
        karana: const KaranaInfo(
            number: 1, name: 'Bava', isFixed: false, elapsed: 0.0),
        vara: vara,
        sunrise: DateTime(2026, 3, 4, 6),
        sunset: DateTime(2026, 3, 4, 18),
      );

      final elements =
          ritualService.calculateRitualElements(panchanga: panchanga);

      expect(elements.homahuti, HomahutiLevel.siddha); // Tithi 1 -> Siddha
      // agniVal = (1 + 1 + 1) % 4 = 3 -> Earth
      expect(elements.agnivasa, 'Earth (Auspicious)');
      // shivaVal = (1 - 1) % 7 = 0 -> Mount Kailash
      expect(elements.shivavasa, 'Mount Kailash (Auspicious)');
      // Kumbha -> (Nakshatra(1) + Weekday(0)) % 4 = 1 -> Good
      expect(elements.kumbhaChakra, KumbhaChakraLevel.good);
    });
  });
}
