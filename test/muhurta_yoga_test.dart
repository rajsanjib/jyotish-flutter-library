import 'package:test/test.dart';
import 'package:jyotish/src/muhurta/muhurta.dart';
import 'package:jyotish/src/muhurta/muhurta_service.dart';
import 'package:jyotish/src/models/geographic_location.dart';

void main() {
  final service = MuhurtaService();
  final location = GeographicLocation(
    latitude: 28.6139,
    longitude: 77.2090,
  ); // Delhi

  group('Special Yoga Calculations', () {
    test('Sarvartha Siddhi & Amrit Siddhi - Sunday + Hasta', () {
      final date = DateTime(2024, 10, 6); // Sunday
      final sunrise = DateTime(2024, 10, 6, 6, 15);
      final sunset = DateTime(2024, 10, 6, 18, 5);

      // Hasta is Nakshatra 13
      final nakshatraPeriods = [
        (13, DateTime(2024, 10, 6, 0, 0), DateTime(2024, 10, 6, 23, 59)),
      ];
      final tithiPeriods = [
        (4, DateTime(2024, 10, 6, 0, 0), DateTime(2024, 10, 6, 23, 59)),
      ];

      final muhurta = service.calculateMuhurta(
        date: date,
        sunrise: sunrise,
        sunset: sunset,
        location: location,
        tithiPeriods: tithiPeriods,
        nakshatraPeriods: nakshatraPeriods,
      );

      final yogas = muhurta.specialYogas;
      expect(
        yogas.any((y) => y.type == SpecialYogaType.sarvarthaSiddhi),
        isTrue,
      );
      expect(yogas.any((y) => y.type == SpecialYogaType.amritSiddhi), isTrue);
    });

    test('Guru Pushya Yog - Thursday + Pushya', () {
      final date = DateTime(2024, 9, 26); // Thursday
      final sunrise = DateTime(2024, 9, 26, 6, 11);
      final sunset = DateTime(2024, 9, 26, 18, 15);

      // Pushya is Nakshatra 8
      final nakshatraPeriods = [
        (8, DateTime(2024, 9, 26, 0, 0), DateTime(2024, 9, 26, 23, 59)),
      ];
      final tithiPeriods = [
        (9, DateTime(2024, 9, 26, 0, 0), DateTime(2024, 9, 26, 23, 59)),
      ];

      final muhurta = service.calculateMuhurta(
        date: date,
        sunrise: sunrise,
        sunset: sunset,
        location: location,
        tithiPeriods: tithiPeriods,
        nakshatraPeriods: nakshatraPeriods,
      );

      final yogas = muhurta.specialYogas;
      expect(yogas.any((y) => y.type == SpecialYogaType.guruPushya), isTrue);
      expect(yogas.any((y) => y.type == SpecialYogaType.amritSiddhi), isTrue);
    });

    test('Dwi Pushkar Yog - Sunday + Bhadra Tithi + Mrigashirsha', () {
      final date = DateTime(2024, 5, 12); // Sunday
      final sunrise = DateTime(2024, 5, 12, 5, 33);
      final sunset = DateTime(2024, 5, 12, 19, 3);

      // Tithi 7 is Bhadra
      // Nakshatra 5 is Mrigashirsha (Dwi-pada)
      final tithiPeriods = [
        (7, DateTime(2024, 5, 12, 10, 27), DateTime(2024, 5, 13, 11, 22)),
      ];
      final nakshatraPeriods = [
        (5, DateTime(2024, 5, 12, 10, 27), DateTime(2024, 5, 13, 11, 24)),
      ];

      final muhurta = service.calculateMuhurta(
        date: date,
        sunrise: sunrise,
        sunset: sunset,
        location: location,
        tithiPeriods: tithiPeriods,
        nakshatraPeriods: nakshatraPeriods,
      );

      final yogas = muhurta.specialYogas;
      expect(yogas.any((y) => y.type == SpecialYogaType.dwiPushkar), isTrue);
    });

    test('Tri Pushkar Yog - Sunday + Bhadra Tithi + Krittika', () {
      final date = DateTime(2024, 4, 7); // Sunday
      final sunrise = DateTime(2024, 4, 7, 6, 3);
      final sunset = DateTime(2024, 4, 7, 18, 42);

      // Tithi 2 (Pratipada end, Dwitiya start)
      // Nakshatra 3 is Krittika (Tri-pada)
      final tithiPeriods = [
        (2, DateTime(2024, 4, 6, 12, 58), DateTime(2024, 4, 7, 10, 51)),
      ];
      final nakshatraPeriods = [
        (3, DateTime(2024, 4, 7, 0, 0), DateTime(2024, 4, 7, 23, 59)),
      ];

      final muhurta = service.calculateMuhurta(
        date: date,
        sunrise: sunrise,
        sunset: sunset,
        location: location,
        tithiPeriods: tithiPeriods,
        nakshatraPeriods: nakshatraPeriods,
      );

      final yogas = muhurta.specialYogas;
      expect(yogas.any((y) => y.type == SpecialYogaType.triPushkar), isTrue);
    });
  });
}
