import 'package:jyotish/jyotish.dart';

void main() async {
  final jyotish = Jyotish();
  await jyotish.initialize();

  final location = GeographicLocation(
    latitude: 28.6139,
    longitude: 77.2090,
    timezone: 'Asia/Kolkata',
  );

  // Today's date from system: 2026-03-04T17:41:55+05:30
  final now =
      DateTime(2026, 3, 4, 12, 0); // Using noon for daily panchang properties

  print(
      "================ TODAY'S PANCHANG (DELHI, MAR 4, 2026) ================");

  final panchanga = await jyotish.calculatePanchanga(
    dateTime: now,
    location: location,
  );

  print('--- Basic Panchang ---');
  print(
      'Tithi: ${panchanga.tithi.name} (elapsed: ${(panchanga.tithi.elapsed * 100).toStringAsFixed(2)}%)');
  print(
      'Nakshatra: ${panchanga.nakshatra.name} (ruler: ${panchanga.nakshatra.rulingPlanet.displayName})');
  print(
      'Yoga: ${panchanga.yoga.name} (elapsed: ${(panchanga.yoga.elapsed * 100).toStringAsFixed(2)}%)');
  print('Karana: ${panchanga.karana.name}');
  print('Vara: ${panchanga.vara.name}');
  print('Sunrise: ${panchanga.sunrise}');
  print('Sunset: ${panchanga.sunset}');
  print('Moonrise: ${panchanga.moonrise}');
  print('Moonset: ${panchanga.moonset}');

  print('\\n--- Samvat Metadata ---');
  final masaService = MasaService(EphemerisService()..initialize());
  final samvatInfo =
      await masaService.getSamvatInfo(dateTime: now, location: location);
  print(
      'Vikram Samvat: ${samvatInfo.vikramSamvat} (${samvatInfo.samvatsaraName})');
  print('Shaka Samvat: ${samvatInfo.shakaSamvat}');
  print('Gujarati Samvat: ${samvatInfo.gujaratiSamvat}');

  final ayana = await masaService.getAyana(dateTime: now, location: location);
  print('Ayana: ${ayana.name}');

  final pravishte =
      await masaService.getPravishte(dateTime: now, location: location);
  print('Pravishte: ${pravishte.monthName} ${pravishte.day}');

  print('\\n--- Muhurta Extensions ---');
  final muhurtaService = MuhurtaService();
  final durMuhurtam = muhurtaService.calculateDurMuhurtam(
    date: now,
    sunrise: panchanga.sunrise,
    sunset: panchanga.sunset,
  );
  print('Dur Muhurtam:');
  for (var i = 0; i < durMuhurtam.length; i++) {
    print(
        '  ${i + 1}: ${durMuhurtam[i].start.toLocal()} to ${durMuhurtam[i].end.toLocal()}');
  }

  final dishaShool = muhurtaService.getDishashool(date: now);
  print('Disha Shool: ${dishaShool.direction}');

  final rahuVasa = muhurtaService.getRahuVasa(nakshatra: panchanga.nakshatra);
  print('Rahu Vasa: ${rahuVasa.location}');

  final chandraVasa = muhurtaService.getChandraVasa(
      moonLongitude: panchanga.nakshatra.longitude);
  print('Chandra Vasa: ${chandraVasa.location}');

  final varjyam = muhurtaService.calculateVarjyam(
    nakshatra: panchanga.nakshatra,
    // Provide arbitrary span
    nakshatraStart: now.subtract(Duration(hours: 10)),
    nakshatraEnd: now.add(Duration(hours: 14)),
  );
  if (varjyam != null) {
    print('Varjyam: ${varjyam.start} to ${varjyam.end}');
  } else {
    print('Varjyam: None');
  }

  print('\\n--- Strength (Balam) ---');
  final strengthService = PanchangStrengthService();
  final chandrabalam = strengthService.calculateChandrabalam(
      currentMoonNakshatra: panchanga.nakshatra);
  print('Moon Rashi Index: ${chandrabalam.moonRashiIndex}');

  final tarabalam = strengthService.calculateTarabalam(
    birthNakshatraIndex: 0, // Ashwini
    currentNakshatra: panchanga.nakshatra,
  );
  print('Tarabalam (for Ashwini native): ${tarabalam.taraType.name}');

  print('\\n--- Ritual Elements ---');
  final ritualService = RitualService();
  final rituals = ritualService.calculateRitualElements(panchanga: panchanga);
  print('Homahuti: ${rituals.homahuti.description}');
  print('Agnivasa: ${rituals.agnivasa}');
  print('Shivavasa: ${rituals.shivavasa}');
  print('Kumbha Chakra: ${rituals.kumbhaChakra.description}');

  print('\\n--- Udaya Lagnas ---');
  final udayaLagnaService = UdayaLagnaService(EphemerisService()..initialize());
  final lagnas = await udayaLagnaService.calculateUdayaLagnas(
    date: now,
    location: location,
    sunrise: panchanga.sunrise,
  );
  print('Udaya Lagnas (${lagnas.length} periods):');
  for (var i = 0; i < lagnas.length; i++) {
    final l = lagnas[i];
    print(
        '  ${l.rashiName}: ${l.startTime.toLocal().toString().split('.')[0]} to ${l.endTime.toLocal().toString().split('.')[0]}');
  }

  jyotish.dispose();
}
