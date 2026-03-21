import 'package:test/test.dart';
import 'package:jyotish/jyotish.dart';

void main() {
  group('Chandrabalam Analysis', () {
    late PanchangStrengthService service;

    setUp(() {
      service = PanchangStrengthService();
    });

    test('Chandrabalam for Moon in Aries', () {
      // Aries is index 0. Longitude = 15.0
      const ariesMoon = NakshatraInfo(
        number: 1, // Ashwini
        name: 'Ashwini',
        rulingPlanet: Planet.ketu,
        longitude: 15.0,
        pada: 1,
        isAbhijit: false,
        abhijitPortion: 0.0,
      );

      final result =
          service.calculateChandrabalam(currentMoonNakshatra: ariesMoon);

      expect(result.moonRashiIndex, 0); // Aries
      expect(result.entries.length, 12);

      // For a native with Aries Rashi (index 0), Moon in Aries (index 0) = position 1 -> Strong
      expect(result.entries[0].level, ChandrabalamLevel.strong);

      // For Taurus native (1), Moon is 12th -> Weak
      expect(result.entries[1].level, ChandrabalamLevel.weak);

      // For Gemini native (2), Moon is 11th -> Strong
      expect(result.entries[2].level, ChandrabalamLevel.strong);
    });
  });
}
