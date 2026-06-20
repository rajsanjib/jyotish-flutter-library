import 'package:flutter_test/flutter_test.dart';
import 'package:jyotish/jyotish.dart';
import 'package:path/path.dart' as p;

void main() {
  late EphemerisService ephemerisService;
  late PanchangaService panchangaService;
  late KPService kpService;

  setUpAll(() async {
    ephemerisService = EphemerisService();
    final ephemerisPath = p.absolute('ephe');
    await ephemerisService.initialize(ephemerisPath: ephemerisPath);
    panchangaService = PanchangaService(ephemerisService);
    kpService = KPService(ephemerisService);
  });

  group('Precision Improvements Tests', () {
    final location = GeographicLocation(
      latitude: 28.6139,
      longitude: 77.2090,
      altitude: 216.0,
      timezone: 'Asia/Kolkata',
    );

    test('Verify Obliquity calculation via Swiss Ephemeris', () async {
      final julianDay = ephemerisService.dateTimeToJulianDay(DateTime(2026, 6, 19, 12, 0));
      final (trueObliquity, meanObliquity) = await ephemerisService.getObliquity(julianDay);

      expect(trueObliquity, closeTo(23.436, 0.01));
      expect(meanObliquity, closeTo(23.436, 0.01));
      print('True Obliquity: $trueObliquity, Mean Obliquity: $meanObliquity');
    });

    test('Verify high-precision end times for Nakshatra and Yoga', () async {
      final dateTime = DateTime(2026, 6, 19, 12, 0);

      // Verify End Time calculations
      final nakshatraEnd = await panchangaService.getNakshatraEndTime(
        dateTime: dateTime,
        location: location,
      );
      final yogaEnd = await panchangaService.getYogaEndTime(
        dateTime: dateTime,
        location: location,
      );

      expect(nakshatraEnd, isNotNull);
      expect(yogaEnd, isNotNull);
      expect(nakshatraEnd.isAfter(dateTime), isTrue);
      expect(yogaEnd.isAfter(dateTime), isTrue);
      print('Nakshatra End Time: $nakshatraEnd, Yoga End Time: $yogaEnd');
    });

    test('Verify high-precision junctions for Nakshatra and Yoga', () async {
      final startDate = DateTime(2026, 6, 19, 0, 0);

      final panchanga = await panchangaService.calculatePanchanga(
        dateTime: startDate,
        location: location,
      );
      final currentNakshatra = panchanga.nakshatra.number;
      final currentYoga = panchanga.yoga.number;

      final nextNakshatra = (currentNakshatra % 27) + 1;
      final nextYoga = (currentYoga % 27) + 1;

      // Junction of next Nakshatra
      final nakshatraJunction = await panchangaService.getNakshatraJunction(
        targetNakshatraNumber: nextNakshatra,
        startDate: startDate,
        location: location,
      );

      // Junction of next Yoga
      final yogaJunction = await panchangaService.getYogaJunction(
        targetYogaNumber: nextYoga,
        startDate: startDate,
        location: location,
      );

      expect(nakshatraJunction, isNotNull);
      expect(yogaJunction, isNotNull);
      expect(nakshatraJunction.isAfter(startDate), isTrue);
      expect(yogaJunction.isAfter(startDate), isTrue);
      print('Current Nakshatra: $currentNakshatra, Next Nakshatra Junction: $nakshatraJunction');
      print('Current Yoga: $currentYoga, Next Yoga Junction: $yogaJunction');
    });

    test('Verify KP Sub-Sub-Sub-Lord (SSSL) calculation', () async {
      // Test at a random longitude (e.g. 123.456)
      final subLord = kpService.getSubLord(123.456);
      final subSubLord = kpService.getSubSubLord(123.456);
      final subSubSubLord = kpService.getSubSubSubLord(123.456);

      expect(subLord, isNotNull);
      expect(subSubLord, isNotNull);
      expect(subSubSubLord, isNotNull);
      print('Longitude 123.456 -> Sub-Lord: $subLord, Sub-Sub-Lord: $subSubLord, SSSL: $subSubSubLord');
    });

    test('Verify calculatePanchanga with atmospheric parameters', () async {
      final dateTime = DateTime(2026, 6, 19, 12, 0);
      final p1 = await panchangaService.calculatePanchanga(
        dateTime: dateTime,
        location: location,
        atmosphericPressure: 1013.25,
        atmosphericTemperature: 15.0,
      );

      expect(p1.sunrise, isNotNull);
      expect(p1.sunset, isNotNull);
      print('Sunrise with standard refraction: ${p1.sunrise}, Sunset: ${p1.sunset}');
    });
  });
}
