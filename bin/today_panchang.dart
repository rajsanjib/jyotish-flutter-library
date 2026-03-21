// ignore_for_file: avoid_print
import 'package:jyotish/jyotish.dart';

/// Binary-searches for the exact UTC time when a Panchanga field changes.
/// [lo] is a time where value == currentValue, [hi] is where it differs.
Future<DateTime> findTransition({
  required Jyotish jyotish,
  required GeographicLocation location,
  required DateTime lo,
  required DateTime hi,
  required String Function(Panchanga) field,
  required String currentValue,
}) async {
  for (int i = 0; i < 14; i++) {
    // ~2s precision after 14 bisections from 48h window
    final mid = lo.add(Duration(seconds: hi.difference(lo).inSeconds ~/ 2));
    final p =
        await jyotish.calculatePanchanga(dateTime: mid, location: location);
    if (field(p) == currentValue) {
      lo = mid;
    } else {
      hi = mid;
    }
  }
  return hi; // hi is the first moment with the NEW value
}

/// Collects all transitions of a field from [start] to [end] UTC.
Future<List<(DateTime, String)>> collectTransitions({
  required Jyotish jyotish,
  required GeographicLocation location,
  required DateTime start,
  required DateTime end,
  required String Function(Panchanga) field,
}) async {
  final results = <(DateTime, String)>[];
  // Sample every 30 minutes to detect changes
  final slots = <DateTime>[];
  var t = start;
  while (t.isBefore(end)) {
    slots.add(t);
    t = t.add(const Duration(minutes: 30));
  }
  slots.add(end);

  String? prev;
  DateTime? prevTime;
  for (final slot in slots) {
    final p =
        await jyotish.calculatePanchanga(dateTime: slot, location: location);
    final val = field(p);
    if (prev == null) {
      prev = val;
      prevTime = slot;
      continue;
    }
    if (val != prev) {
      // Binary search for exact transition between prevTime and slot
      final transTime = await findTransition(
        jyotish: jyotish,
        location: location,
        lo: prevTime!,
        hi: slot,
        field: field,
        currentValue: prev,
      );
      results.add((transTime, prev)); // (when it ends, value)
      prev = val;
      prevTime = slot;
    }
    prevTime = slot;
  }
  // Add final value (runs until end of window)
  results.add((end, prev!));
  return results;
}

/// Formats a UTC DateTime as IST "HH:MM [24 Feb]"
String fmtIST(DateTime utc, {DateTime? dayRef}) {
  final ist = utc.toUtc().add(const Duration(hours: 5, minutes: 30));
  final hhmm =
      '${ist.hour.toString().padLeft(2, '0')}:${ist.minute.toString().padLeft(2, '0')}';
  // Only add date suffix if it's a different calendar day from dayRef
  if (dayRef != null) {
    final refDate = dayRef.toUtc().add(const Duration(hours: 5, minutes: 30));
    if (ist.day != refDate.day || ist.month != refDate.month) {
      return '$hhmm, ${ist.day} ${_monthName(ist.month)}';
    }
  }
  return hhmm;
}

String _monthName(int m) => const [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ][m];

/// Print transitions in DrikPanchang style
void printTransitions(
  String label,
  List<(DateTime, String)> transitions,
  DateTime dayRefUtc,
  DateTime windowEnd,
) {
  for (int i = 0; i < transitions.length; i++) {
    final (endTime, value) = transitions[i];
    final isLast = i == transitions.length - 1;
    if (isLast && endTime == windowEnd) {
      print('  ${label.padRight(12)}: $value (continues after window)');
    } else {
      print(
          '  ${label.padRight(12)}: $value upto ${fmtIST(endTime, dayRef: dayRefUtc)}');
    }
    label = ''; // only print label on first line
  }
}

void main() async {
  // Delhi, India  24 Feb 2026
  // Sunrise at 06:51 IST = 01:21 UTC
  // We scan from 00:00 IST (18:30 UTC, 23 Feb) to 06:00 IST next day (00:30 UTC, 26 Feb)
  // Use a 30-hour IST window: 00:01 IST 24 Feb  06:30 IST 25 Feb
  const istOffset = Duration(hours: 5, minutes: 30);
  final dayStart = DateTime(2026, 2, 24, 0, 1)
      .toUtc()
      .subtract(istOffset); // 00:01 IST  UTC
  final dayEnd = DateTime(2026, 2, 25, 6, 30)
      .toUtc()
      .subtract(istOffset); // 06:30 IST next day
  final dayRefUtc = DateTime.utc(2026, 2, 24, 0, 0); // for date suffix logic

  final location = GeographicLocation(
    latitude: 28.6139,
    longitude: 77.2090,
    timezone: 'Asia/Kolkata',
  );

  final jyotish = Jyotish();
  await jyotish.initialize(ephemerisPath: 'ephe');

  try {
    print('Calculating  this may take 3060 seconds...');
    print('');

    // Fetch sunrise/sunset from Panchanga at local noon
    final noonUtc = DateTime.utc(2026, 2, 24, 6, 30); // ~noon IST
    final pnoon =
        await jyotish.calculatePanchanga(dateTime: noonUtc, location: location);
    final sunriseIST = pnoon.sunrise.toUtc().add(istOffset);
    final sunsetIST = pnoon.sunset.toUtc().add(istOffset);

    // Collect transitions for each limb
    final tithiT = await collectTransitions(
      jyotish: jyotish,
      location: location,
      start: dayStart,
      end: dayEnd,
      field: (p) => p.tithi.name,
    );
    final nakshatraT = await collectTransitions(
      jyotish: jyotish,
      location: location,
      start: dayStart,
      end: dayEnd,
      field: (p) => p.nakshatra.name,
    );
    final yogaT = await collectTransitions(
      jyotish: jyotish,
      location: location,
      start: dayStart,
      end: dayEnd,
      field: (p) => p.yoga.name,
    );
    final karanaT = await collectTransitions(
      jyotish: jyotish,
      location: location,
      start: dayStart,
      end: dayEnd,
      field: (p) => p.karana.name,
    );

    // Fetch chart for planetary positions
    final chartUtc = DateTime.utc(2026, 2, 24, 7, 0); // near sunrise
    final chart = await jyotish.calculateVedicChart(
      dateTime: chartUtc,
      location: location,
      flags: const CalculationFlags(siderealMode: SiderealMode.lahiri),
    );
    final pSunrise = await jyotish.calculatePanchanga(
      dateTime: pnoon.sunrise,
      location: location,
    );

    //  Output 
    print('New Delhi, India');
    print('Tuesday, February 24, 2026');
    print('');
    print(
        '  Sunrise      : ${sunriseIST.hour.toString().padLeft(2, '0')}:${sunriseIST.minute.toString().padLeft(2, '0')}');
    print(
        '  Sunset       : ${sunsetIST.hour.toString().padLeft(2, '0')}:${sunsetIST.minute.toString().padLeft(2, '0')}');
    print('');

    // Filter transitions to only those relevant to the calendar day
    // (exclude items that ended before the previous day or start after next day)
    List<(DateTime, String)> dayOnly(List<(DateTime, String)> all) {
      return all.where((t) {
        final endIST = t.$1.toUtc().add(istOffset);
        return endIST.day >= 24; // on or after Feb 24
      }).toList();
    }

    printTransitions('Tithi', dayOnly(tithiT), dayRefUtc, dayEnd);
    print('');
    printTransitions('Nakshatra', dayOnly(nakshatraT), dayRefUtc, dayEnd);
    print('');
    printTransitions('Yoga', dayOnly(yogaT), dayRefUtc, dayEnd);
    print('');
    printTransitions('Karana', dayOnly(karanaT), dayRefUtc, dayEnd);
    print('');
    print('  Paksha       : ${pSunrise.tithi.paksha.sanskrit}');
    print(
        '  Weekday      : ${pSunrise.vara.name}  (${pSunrise.vara.rulingPlanet.displayName})');
    print('');

    // Moon sign / Sun sign
    final moonInfo = chart.getPlanet(Planet.moon);
    final sunInfo = chart.getPlanet(Planet.sun);
    print(
        '  Moon sign    : ${moonInfo?.zodiacSign ?? ""}  (${moonInfo?.longitude.toStringAsFixed(2)})');
    print(
        '  Sun sign     : ${sunInfo?.zodiacSign ?? ""}  (${sunInfo?.longitude.toStringAsFixed(2)})');
    print('');

    // Nakshatra at sunrise (for Masa etc.)
    print(' Planetary Positions at Sunrise (Sidereal / Lahiri) ');
    print(
        '  ${"Planet".padRight(12)} ${"Longitude".padRight(12)} ${"Sign".padRight(18)} House  Nakshatra');
    print('  ${"" * 72}');

    final orderedPlanets = [
      Planet.sun,
      Planet.moon,
      Planet.mercury,
      Planet.venus,
      Planet.mars,
      Planet.jupiter,
      Planet.saturn,
      Planet.meanNode,
    ];
    for (final planet in orderedPlanets) {
      final info = chart.getPlanet(planet);
      if (info == null) continue;
      final retro = info.isRetrograde ? ' ' : '';
      final combust = info.isCombust == true ? ' ' : '';
      final nakStr = '${info.nakshatra} P${info.pada}';
      print('  ${planet.displayName.padRight(12)}'
          ' ${info.longitude.toStringAsFixed(4).padRight(12)}'
          ' ${(info.zodiacSign).padRight(18)}'
          ' H${info.house.toString().padRight(4)}'
          ' $nakStr$retro$combust');
    }
    final rahu = chart.rahu;
    print(
        '  ${"Rahu".padRight(12)} ${rahu.longitude.toStringAsFixed(4).padRight(12)} ${rahu.zodiacSign.padRight(18)} H${rahu.house}');
    final ketu = chart.ketu;
    print(
        '  ${"Ketu".padRight(12)} ${ketu.longitude.toStringAsFixed(4).padRight(12)} ${ketu.zodiacSign}');
    print('');
    print(
        '  Ascendant    : ${chart.ascendant.toStringAsFixed(4)}  (${chart.ascendantSign})');
    print('');
  } finally {
    jyotish.dispose();
  }
}
