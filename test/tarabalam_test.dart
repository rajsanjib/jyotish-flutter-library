import 'package:test/test.dart';
import 'package:jyotish/jyotish.dart';

void main() {
  group('Tarabalam Analysis', () {
    late PanchangStrengthService service;

    setUp(() {
      service = PanchangStrengthService();
    });

    test('Tarabalam from Ashwini to Krittika', () {
      // 1 = Ashwini (index 0)
      // 3 = Krittika (index 2)
      final krittika = NakshatraInfo(
        number: 3,
        name: 'Krittika',
        rulingPlanet: Planet.sun,
        longitude: 30.0,
        pada: 1,
        isAbhijit: false,
        abhijitPortion: 0.0,
      );

      final result = service.calculateTarabalam(
        birthNakshatraIndex: 0,
        currentNakshatra: krittika,
      );

      expect(result.currentNakshatraIndex, 2);

      // From 0 to 2 is 3rd star: Vipat
      expect(result.taraType, TaraType.vipat);
      expect(result.isAuspicious, false);
    });
  });
}
