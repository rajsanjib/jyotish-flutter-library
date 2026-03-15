import 'package:test/test.dart';
import 'package:jyotish/jyotish.dart';

void main() {
  group('Ritual Elements Tests', () {
    late RitualService ritualService;

    setUp(() {
      ritualService = RitualService();
    });

    test('calculateRitualElements assigns valid ritual fields', () {
      final tithi = TithiInfo(
          number: 1, name: 'Pratipada', paksha: Paksha.shukla, elapsed: 0.5);
      final nakshatra = NakshatraInfo(
          number: 1,
          name: 'Ashwini',
          rulingPlanet: Planet.ketu,
          longitude: 10.0,
          pada: 1,
          isAbhijit: false,
          abhijitPortion: 0.0);
      final vara =
          VaraInfo(name: 'Sunday', weekday: 0, rulingPlanet: Planet.sun);

      final panchanga = Panchanga(
        dateTime: DateTime(2026, 3, 4),
        location: '0,0',
        tithi: tithi,
        nakshatra: nakshatra,
        yoga: YogaInfo(number: 1, name: 'Vishkumbha', elapsed: 0.0),
        karana:
            KaranaInfo(number: 1, name: 'Bava', isFixed: false, elapsed: 0.0),
        vara: vara,
        sunrise: DateTime(2026, 3, 4, 6),
        sunset: DateTime(2026, 3, 4, 18),
      );

      final elements =
          ritualService.calculateRitualElements(panchanga: panchanga);

      expect(elements.homahuti, HomahutiLevel.siddha); // Tithi 1 -> Siddha
      // Day = Sun (0). Modified weekday = 1. (Tithi(1) + 1) % 4 = 2 -> Underworld
      expect(elements.agnivasa, 'Underworld (Inauspicious)');
      // Shiva vasa -> 1 % 6 = 1 = With Gauri
      expect(elements.shivavasa, 'With Gauri (Auspicious)');
      // Kumbha -> (Nakshatra(1) + Weekday(0)) % 4 = 1 -> Good
      expect(elements.kumbhaChakra, KumbhaChakraLevel.good);
    });
  });
}
