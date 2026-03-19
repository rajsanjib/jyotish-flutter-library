import 'package:test/test.dart';
import 'package:jyotish/jyotish.dart';

void main() {
  group('Muhurta Extensions Tests', () {
    late MuhurtaService muhurtaService;

    setUp(() {
      muhurtaService = MuhurtaService();
    });

    test('Dur Muhurtam for Wednesday', () {
      final date = DateTime(2026, 3, 4); // Wednesday
      final sunrise = DateTime(2026, 3, 4, 6, 0);
      final sunset = DateTime(2026, 3, 4, 18, 0); // 12 hours

      final durMuhurtas = muhurtaService.calculateDurMuhurtam(
        date: date,
        sunrise: sunrise,
        sunset: sunset,
      );

      // BPHS method for Wednesday has 1 period (the 5th 1/8th part)
      expect(durMuhurtas.length, 1);
    });

    test('Disha Shool for Wednesday', () {
      final date = DateTime(2026, 3, 4); // Wednesday
      final result = muhurtaService.getDishashool(date: date);
      expect(result.direction, 'North');
    });

    test('Rahu Vasa for Ashwini', () {
      final ashwini = const NakshatraInfo(
        number: 1,
        name: 'Ashwini',
        rulingPlanet: Planet.ketu,
        longitude: 10.0,
        pada: 1,
        isAbhijit: false,
        abhijitPortion: 0.0,
      );
      final result = muhurtaService.getRahuVasa(nakshatra: ashwini);
      expect(result.location, 'Sky');
    });

    test('Varjyam calculation for Ashwini', () {
      final ashwini = const NakshatraInfo(
        number: 1,
        name: 'Ashwini',
        rulingPlanet: Planet.ketu,
        longitude: 10.0,
        pada: 1,
        isAbhijit: false,
        abhijitPortion: 0.0,
      );

      final start = DateTime(2026, 3, 4, 0, 0);
      final end = DateTime(2026, 3, 5, 0, 0); // 24 hours

      final varjyam = muhurtaService.calculateVarjyam(
        nakshatra: ashwini,
        nakshatraStart: start,
        nakshatraEnd: end,
      );

      expect(varjyam, isNotNull);
      // Offset is 50/60 for Ashwini = 20 hours in
      expect(varjyam!.start, start.add(const Duration(hours: 20)));
    });
  });
}
