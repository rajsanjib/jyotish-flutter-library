import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

class MockEphemerisService extends EphemerisService {
  @override
  Future<(DateTime?, DateTime?)> getSunriseSunset({
    required DateTime date,
    required GeographicLocation location,
    double atpress = 0.0,
    double attemp = 0.0,
  }) async {
    // Hardcoded sunrise/sunset for New Delhi on Oct 25, 2025
    // Sunrise ~6:28 AM, Sunset ~5:42 PM (17:42)
    final sunrise = DateTime(date.year, date.month, date.day, 6, 28);
    final sunset = DateTime(date.year, date.month, date.day, 17, 42);
    return (sunrise, sunset);
  }
}

void main() {
  late HoraService horaService;
  late ChoghadiyaService choghadiyaService;
  late GowriPanchangamService gowriPanchangamService;
  late MockEphemerisService mockEphemerisService;

  setUpAll(() async {
    mockEphemerisService = MockEphemerisService();
    horaService = HoraService(mockEphemerisService);
    choghadiyaService = ChoghadiyaService(mockEphemerisService);
    gowriPanchangamService = GowriPanchangamService(mockEphemerisService);
  });

  group('Panchanga Extensions', () {
    // New Delhi Location
    final newDelhi = GeographicLocation(
      latitude: 28.6139,
      longitude: 77.2090,
      altitude: 0,
    );

    // Test Date: Sunday, Oct 25, 2025 (Arbitrary date)
    // Weekday: Saturday (Oct 25 2025 is Saturday? Let's check)
    // 2025-10-25 is a Saturday.
    // Sunrise approx 6:28 AM, Sunset 5:42 PM
    final testDate = DateTime(2025, 10, 25, 12, 0); // Noon

    test('Hora Service', () async {
      // 1. Get Current Hora
      final hora = await horaService.getCurrentHora(
        dateTime: testDate,
        location: newDelhi,
      );

      print('Current Hora at noon: ${hora.name}');
      expect(hora, isNotNull);
      expect(hora.isDaytime, true);

      // 2. Get All Horas for Day
      final horas = await horaService.getHorasForDay(
        date: testDate,
        location: newDelhi,
      );

      expect(horas.length, 24);
      expect(horas[0].isDaytime, true);
      expect(horas[12].isDaytime, false); // First night hora

      // Verify sequence (Chaldean order)
      // Saturday (day lord Saturn)
      // 1st Hora: Saturn
      // 2nd: Jupiter
      // 3rd: Mars
      // 4th: Sun
      // 5th: Venus
      // 6th: Mercury
      // 7th: Moon
      // 8th: Saturn...

      expect(horas[0].lord, Planet.saturn);
      expect(horas[1].lord, Planet.jupiter);
      expect(horas[2].lord, Planet.mars);
      expect(horas[3].lord, Planet.sun);
    });

    test('Choghadiya Service', () async {
      // 1. Get Current Choghadiya
      final choghadiya = await choghadiyaService.getCurrentChoghadiya(
        dateTime: testDate,
        location: newDelhi,
      );

      print('Current Choghadiya at noon: ${choghadiya.name}');
      expect(choghadiya, isNotNull);

      // Saturday Day Sequence:
      // Kaal, Shubh, Rog, Udveg, Char, Labh, Amrit, Kaal
      // At noon (mid-day), it should be around 4th/5th period?
      // Sunrise ~6:30, Sunset ~17:40. Day duration ~11h 10m.
      // 11.16 hours. Each choghadiya ~1.4 hours.
      // Noon is ~5.5 hours after sunrise.
      // 5.5 / 1.4 ~ 3.9 -> 4th period (index 3).
      // Sequence: 0:Kaal, 1:Shubh, 2:Rog, 3:Udveg.

      // Let's verify start/end times logic validity
      expect(choghadiya.startTime.isBefore(testDate), true);
      expect(choghadiya.endTime.isAfter(testDate), true);
    });

    test('Gowri Panchangam Service', () async {
      // 1. Get Current Gowri
      final gowri = await gowriPanchangamService.getCurrentGowriPanchangam(
        dateTime: testDate,
        location: newDelhi,
      );

      print('Current Gowri at noon: ${gowri.description}');
      expect(gowri, isNotNull);

      // Saturday Day Sequence:
      // Visham, Nirkku, Uthi, Amrit, Rogam, Labhamu, Dhana, Soolai
      // 4th period (index 3) -> Amrit.
      // Let's see if calculation matches.

      expect(gowri.startTime.isBefore(testDate), true);
      expect(gowri.endTime.isAfter(testDate), true);
    });
  });
}
