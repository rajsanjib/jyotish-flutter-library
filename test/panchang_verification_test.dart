// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:jyotish/jyotish.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';

void main() {
  test('Verify Panchang for New Delhi - May 2, 2026', () async {
    final ephemerisService = EphemerisService();
    final ephemerisPath = p.absolute('ephe');

    print('Initializing Ephemeris Service with path: $ephemerisPath');
    await ephemerisService.initialize(ephemerisPath: ephemerisPath);

    final panchangaService = PanchangaService(ephemerisService);
    final muhurtaService = MuhurtaService();
    final masaService = MasaService(ephemerisService);

    // New Delhi: 28.6139° N, 77.2090° E
    final location = GeographicLocation(
      latitude: 28.6139,
      longitude: 77.2090,
      altitude: 216.0,
      timezone: 'Asia/Kolkata',
    );

    // May 2, 2026 10:00 AM (Daytime calculation)
    final dateTime = DateTime(2026, 5, 2, 10, 0);

    final panchanga = await panchangaService.calculatePanchanga(
      dateTime: dateTime,
      location: location,
    );

    final muhurta = muhurtaService.calculateMuhurta(
      date: dateTime,
      sunrise: panchanga.sunrise,
      sunset: panchanga.sunset,
      location: location,
    );

    final amantaMasa = await masaService.calculateMasa(
      dateTime: dateTime,
      location: location,
      type: MasaType.amanta,
    );

    final purnimantaMasa = await masaService.calculateMasa(
      dateTime: dateTime,
      location: location,
      type: MasaType.purnimanta,
    );

    final timeFormat = DateFormat('hh:mm a');

    // --- Solar/Lunar Assertions ---
    expect(timeFormat.format(panchanga.sunrise), equals('05:39 AM'));
    expect(timeFormat.format(panchanga.sunset), equals('06:57 PM'));
    expect(panchanga.moonrise, isNotNull);
    expect(timeFormat.format(panchanga.moonrise!), equals('07:44 PM'));
    expect(panchanga.moonset, isNotNull);

    // --- 5 Limbs (Panchanga) Assertions ---
    expect(panchanga.vara.name, equals('Saturday'));
    expect(panchanga.tithi.name, equals('Pratipada'));
    expect(panchanga.tithi.paksha, equals(Paksha.krishna));
    expect(panchanga.nakshatra.name, equals('Vishakha'));
    expect(panchanga.yoga.name, equals('Vyatipata'));
    expect(panchanga.karana.name, equals('Balava'));

    // --- Months Assertions ---
    expect(amantaMasa.month.sanskrit, equals('Vaishakha'));
    expect(purnimantaMasa.month.sanskrit, equals('Jyeshtha'));

    // --- Muhurtas Assertions ---
    final abhijitPrecise = await panchangaService.calculateAbhijitMuhurta(
      date: dateTime,
      location: location,
    );
    expect(timeFormat.format(abhijitPrecise.startTime), equals('11:51 AM'));
    expect(timeFormat.format(abhijitPrecise.endTime), equals('12:44 PM'));

    expect(muhurta.inauspiciousPeriods.rahukalam, isNotNull);
    expect(
      timeFormat.format(muhurta.inauspiciousPeriods.rahukalam!.start),
      equals('08:58 AM'),
    );
    expect(
      timeFormat.format(muhurta.inauspiciousPeriods.rahukalam!.end),
      equals('10:38 AM'),
    );

    expect(muhurta.inauspiciousPeriods.gulikalam, isNotNull);
    expect(
      timeFormat.format(muhurta.inauspiciousPeriods.gulikalam!.start),
      equals('05:39 AM'),
    );
    expect(
      timeFormat.format(muhurta.inauspiciousPeriods.gulikalam!.end),
      equals('07:19 AM'),
    );

    expect(muhurta.inauspiciousPeriods.yamagandam, isNotNull);
    expect(
      timeFormat.format(muhurta.inauspiciousPeriods.yamagandam!.start),
      equals('01:58 PM'),
    );
    expect(
      timeFormat.format(muhurta.inauspiciousPeriods.yamagandam!.end),
      equals('03:37 PM'),
    );

    final durMuhurtas = muhurta.inauspiciousPeriods.durMuhurtam;
    expect(durMuhurtas, isNotNull);
    expect(durMuhurtas!.isNotEmpty, isTrue);
    expect(timeFormat.format(durMuhurtas.first.start), equals('07:19 AM'));
    expect(timeFormat.format(durMuhurtas.first.end), equals('08:58 AM'));

    final varjyam = muhurtaService.calculateVarjyam(
      nakshatra: panchanga.nakshatra,
      nakshatraStart: dateTime.subtract(const Duration(hours: 12)),
      nakshatraEnd: dateTime.add(const Duration(hours: 12)),
    );
    expect(varjyam, isNotNull);
    expect(timeFormat.format(varjyam!.start), equals('03:36 AM'));
    expect(timeFormat.format(varjyam.end), equals('05:12 AM'));
  });
}
