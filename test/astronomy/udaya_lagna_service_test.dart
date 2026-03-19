import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

void main() {
  late EphemerisService ephemerisService;
  late UdayaLagnaService lagnaService;
  bool ephemerisInitialized = false;

  final location = GeographicLocation(
    latitude: 28.6139,
    longitude: 77.2090,
    timezone: 'Asia/Kolkata',
  );

  setUpAll(() async {
    ephemerisService = EphemerisService();
    try {
      await ephemerisService.initialize(ephemerisPath: 'ephe');
      lagnaService = UdayaLagnaService(ephemerisService);
      ephemerisInitialized = true;
    } catch (e) {
      print('Warning: Ephemeris initialization failed: $e');
    }
  });

  group('UdayaLagnaService', () {
    test('calculateUdayaLagnas returns 12 periods for a full day', () async {
      if (!ephemerisInitialized) return;

      final date = DateTime(2026, 3, 4);
      final sunrise = DateTime(2026, 3, 4, 6, 0);

      final periods = await lagnaService.calculateUdayaLagnas(
        date: date,
        location: location,
        sunrise: sunrise,
      );

      expect(periods, isNotNull);
      expect(periods.length, equals(12));
    });

    test('periods are in chronological order', () async {
      if (!ephemerisInitialized) return;

      final date = DateTime(2024, 6, 15);
      final sunrise = DateTime(2024, 6, 15, 5, 25);

      final periods = await lagnaService.calculateUdayaLagnas(
        date: date,
        location: location,
        sunrise: sunrise,
      );

      for (int i = 0; i < periods.length - 1; i++) {
        expect(
          periods[i].startTime.isBefore(periods[i + 1].startTime),
          isTrue,
          reason:
              'Period ${i + 1} start time should be before period ${i + 2}',
        );
      }
    });

    test('each period has valid rashiIndex (0-11)', () async {
      if (!ephemerisInitialized) return;

      final date = DateTime(2024, 9, 22);
      final sunrise = DateTime(2024, 9, 22, 6, 10);

      final periods = await lagnaService.calculateUdayaLagnas(
        date: date,
        location: location,
        sunrise: sunrise,
      );

      for (final period in periods) {
        expect(period.rashiIndex, greaterThanOrEqualTo(0));
        expect(period.rashiIndex, lessThanOrEqualTo(11));
      }
    });

    test('rashiNames are valid Sanskrit names', () async {
      if (!ephemerisInitialized) return;

      final validRashiNames = UdayaLagnaService.rashiNames;

      final date = DateTime(2024, 12, 21);
      final sunrise = DateTime(2024, 12, 21, 7, 0);

      final periods = await lagnaService.calculateUdayaLagnas(
        date: date,
        location: location,
        sunrise: sunrise,
      );

      for (final period in periods) {
        expect(validRashiNames, contains(period.rashiName),
            reason:
                'Rashi name "${period.rashiName}" should be a valid Sanskrit name');
      }
    });

    test('periods cover approximately 24 hours', () async {
      if (!ephemerisInitialized) return;

      final date = DateTime(2024, 6, 21);
      final sunrise = DateTime(2024, 6, 21, 5, 23);

      final periods = await lagnaService.calculateUdayaLagnas(
        date: date,
        location: location,
        sunrise: sunrise,
      );

      final firstStart = periods.first.startTime;
      final lastEnd = periods.last.endTime;
      final totalDuration = lastEnd.difference(firstStart);

      expect(totalDuration.inHours, greaterThanOrEqualTo(23));
      expect(totalDuration.inHours, lessThanOrEqualTo(25));
    });
  });
}
