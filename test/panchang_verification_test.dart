import 'package:flutter_test/flutter_test.dart';
import 'package:jyotish/jyotish.dart';
import 'dart:io';
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

    print('\n=== PANCHANG VERIFICATION REPORT ===');
    print('Location: New Delhi (28.61, 77.21)');
    print('Date: May 2, 2026\n');

    print('--- Solar/Lunar ---');
    print('Sunrise:  ${timeFormat.format(panchanga.sunrise)} (Expected: 05:40 AM)');
    print('Sunset:   ${timeFormat.format(panchanga.sunset)} (Expected: 06:57 PM)');
    print('Moonrise: ${panchanga.moonrise != null ? timeFormat.format(panchanga.moonrise!) : "N/A"} (Expected: 07:50 PM)');
    print('Moonset:  ${panchanga.moonset != null ? timeFormat.format(panchanga.moonset!) : "No Moonset"} (Expected: No Moonset)');
    
    print('\n--- 5 Limbs (Panchanga) ---');
    print('Weekday:   ${panchanga.vara.name} (Expected: Shaniwara/Saturday)');
    print('Tithi:     ${panchanga.tithi.name} (${panchanga.tithi.paksha.name}) (Expected: Pratipada, Krishna Paksha)');
    print('Nakshatra: ${panchanga.nakshatra.name} (Expected: Vishakha)');
    print('Yoga:      ${panchanga.yoga.name} (Expected: Vyatipata)');
    print('Karana:    ${panchanga.karana.name} (Expected: Balava/Kaulava)');

    print('\n--- Months ---');
    print('Amanta:    ${amantaMasa.month.sanskrit} (Expected: Vaishakha)');
    print('Purnimanta: ${purnimantaMasa.month.sanskrit} (Expected: Jyeshtha)');

    print('\n--- Muhurtas (Auspicious/Inauspicious) ---');
    final abhijitPrecise = await panchangaService.calculateAbhijitMuhurta(date: dateTime, location: location);
    print('Abhijit:      ${timeFormat.format(abhijitPrecise.startTime)} to ${timeFormat.format(abhijitPrecise.endTime)} (Expected: 11:52 AM to 12:45 PM)');

    print('Rahu Kalam:   ${timeFormat.format(muhurta.inauspiciousPeriods.rahukalam!.start)} to ${timeFormat.format(muhurta.inauspiciousPeriods.rahukalam!.end)} (Expected: 08:59 AM to 10:39 AM)');
    print('Gulikai Kalam: ${timeFormat.format(muhurta.inauspiciousPeriods.gulikalam!.start)} to ${timeFormat.format(muhurta.inauspiciousPeriods.gulikalam!.end)} (Expected: 05:40 AM to 07:19 AM)');
    print('Yamaganda:    ${timeFormat.format(muhurta.inauspiciousPeriods.yamagandam!.start)} to ${timeFormat.format(muhurta.inauspiciousPeriods.yamagandam!.end)} (Expected: 01:58 PM to 03:38 PM)');
    
    for (var dm in (muhurta.inauspiciousPeriods.durMuhurtam ?? [])) {
       print('Dur Muhurtam: ${timeFormat.format(dm.start)} to ${timeFormat.format(dm.end)} (Expected: 05:40 AM to 06:33 AM, 06:33 AM to 07:26 AM)');
    }

    final varjyam = muhurtaService.calculateVarjyam(
      nakshatra: panchanga.nakshatra,
      nakshatraStart: dateTime.subtract(const Duration(hours: 12)), // Approximate for now
      nakshatraEnd: dateTime.add(const Duration(hours: 12)),
    );
    if (varjyam != null) {
      print('Varjyam:      ${timeFormat.format(varjyam.start)} to ${timeFormat.format(varjyam.end)} (Expected: 10:47 AM to 12:33 PM)');
    }

    print('\n====================================');
  });
}
