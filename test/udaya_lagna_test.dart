import 'package:test/test.dart';
import 'package:jyotish/jyotish.dart';

void main() {
  group('Udaya Lagna Tests', () {
    late EphemerisService ephemerisService;
    late UdayaLagnaService lagnaService;
    final delhi = GeographicLocation(
      latitude: 28.6139,
      longitude: 77.2090,
      timezone: 'Asia/Kolkata',
    );

    setUpAll(() async {
      ephemerisService = EphemerisService();
      await ephemerisService.initialize();
      lagnaService = UdayaLagnaService(ephemerisService);
    });

    test('calculateUdayaLagnas returns 12 periods covering 24h', () async {
      final date = DateTime(2026, 3, 4);
      final sunrise = DateTime(2026, 3, 4, 6, 0); // Approx

      final periods = await lagnaService.calculateUdayaLagnas(
        date: date,
        location: delhi,
        sunrise: sunrise,
      );

      expect(periods.length, 12);
      expect(periods.first.startTime, sunrise);
      // The last one should end at exactly next sunrise
      expect(periods.last.endTime, sunrise.add(Duration(days: 1)));
    });
  });
}
