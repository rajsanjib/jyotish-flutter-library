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
    final mid = lo.add(Duration(seconds: hi.difference(lo).inSeconds ~/ 2));
    final p = await jyotish.calculatePanchanga(dateTime: mid, location: location);
    if (field(p) == currentValue) {
      lo = mid;
    } else {
      hi = mid;
    }
  }
  return hi;
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
    final p = await jyotish.calculatePanchanga(dateTime: slot, location: location);
    final val = field(p);
    if (prev == null) {
      prev = val;
      prevTime = slot;
      continue;
    }
    if (val != prev) {
      final transTime = await findTransition(
        jyotish: jyotish,
        location: location,
        lo: prevTime!,
        hi: slot,
        field: field,
        currentValue: prev,
      );
      results.add((transTime, prev));
      prev = val;
      prevTime = slot;
    }
    prevTime = slot;
  }
  results.add((end, prev!));
  return results;
}

/// Formats a UTC DateTime as IST "HH:MM [24 Feb]"
String fmtIST(DateTime utc, {DateTime? dayRef, required Duration istOffset}) {
  final ist = utc.toUtc().add(istOffset);
  final hhmm = '${ist.hour.toString().padLeft(2, '0')}:${ist.minute.toString().padLeft(2, '0')}';
  if (dayRef != null) {
    final refDate = dayRef.toUtc().add(istOffset);
    if (ist.day != refDate.day || ist.month != refDate.month) {
      return '$hhmm, ${ist.day} ${_monthName(ist.month)}';
    }
  }
  return hhmm;
}

String _monthName(int m) => const [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ][m];

String _weekdayName(int w) => const [
      '', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ][w];

/// Print transitions in DrikPanchang style
void printTransitions(
  String label,
  List<(DateTime, String)> transitions,
  DateTime dayRefUtc,
  DateTime windowEnd,
  Duration istOffset,
) {
  for (int i = 0; i < transitions.length; i++) {
    final (endTime, value) = transitions[i];
    final isLast = i == transitions.length - 1;
    if (isLast && endTime == windowEnd) {
      print('  ${label.padRight(12)}: $value (continues after window)');
    } else {
      print('  ${label.padRight(12)}: $value upto ${fmtIST(endTime, dayRef: dayRefUtc, istOffset: istOffset)}');
    }
    label = '';
  }
}

void main() async {
  const istOffset = Duration(hours: 5, minutes: 30);
  
  // Use current local time from system/environment
  // For safety and consistency with user prompt, we take the date: 2026-03-21
  final now = DateTime(2026, 3, 21); 
  
  final dayStart = DateTime(now.year, now.month, now.day, 0, 1)
      .toUtc()
      .subtract(istOffset);
  final dayEnd = dayStart.add(const Duration(hours: 30));
  final dayRefUtc = DateTime.utc(now.year, now.month, now.day, 0, 0);

  final location = GeographicLocation(
    latitude: 28.6139,
    longitude: 77.2090,
    timezone: 'Asia/Kolkata',
  );

  final jyotish = Jyotish();
  await jyotish.initialize(ephemerisPath: 'ephe');

  try {
    print('Calculating today\'s Panchang for New Delhi, India...');
    print('');

    final noonUtc = dayStart.add(const Duration(hours: 12));
    final pnoon = await jyotish.calculatePanchanga(dateTime: noonUtc, location: location);
    final sunriseIST = pnoon.sunrise.toUtc().add(istOffset);
    final sunsetIST = pnoon.sunset.toUtc().add(istOffset);

    final tithiT = await collectTransitions(
      jyotish: jyotish, location: location, start: dayStart, end: dayEnd, field: (p) => p.tithi.name,
    );
    final nakshatraT = await collectTransitions(
      jyotish: jyotish, location: location, start: dayStart, end: dayEnd, field: (p) => p.nakshatra.name,
    );
    final yogaT = await collectTransitions(
      jyotish: jyotish, location: location, start: dayStart, end: dayEnd, field: (p) => p.yoga.name,
    );
    final karanaT = await collectTransitions(
      jyotish: jyotish, location: location, start: dayStart, end: dayEnd, field: (p) => p.karana.name,
    );

    final chartUtc = pnoon.sunrise.add(const Duration(minutes: 10)); // near sunrise
    final chart = await jyotish.calculateVedicChart(
      dateTime: chartUtc,
      location: location,
      flags: const CalculationFlags(siderealMode: SiderealMode.lahiri),
    );
    final pSunrise = await jyotish.calculatePanchanga(dateTime: pnoon.sunrise, location: location);

    print('New Delhi, India');
    print('${_weekdayName(sunriseIST.weekday)}, ${_monthName(sunriseIST.month)} ${sunriseIST.day}, ${sunriseIST.year}');
    print('');
    print('  Sunrise      : ${sunriseIST.hour.toString().padLeft(2, '0')}:${sunriseIST.minute.toString().padLeft(2, '0')}');
    print('  Sunset       : ${sunsetIST.hour.toString().padLeft(2, '0')}:${sunsetIST.minute.toString().padLeft(2, '0')}');
    print('');

    List<(DateTime, String)> dayOnly(List<(DateTime, String)> all) {
      return all.where((t) {
        final endIST = t.$1.toUtc().add(istOffset);
        return endIST.day >= sunriseIST.day;
      }).toList();
    }

    printTransitions('Tithi', dayOnly(tithiT), dayRefUtc, dayEnd, istOffset);
    print('');
    printTransitions('Nakshatra', dayOnly(nakshatraT), dayRefUtc, dayEnd, istOffset);
    print('');
    printTransitions('Yoga', dayOnly(yogaT), dayRefUtc, dayEnd, istOffset);
    print('');
    printTransitions('Karana', dayOnly(karanaT), dayRefUtc, dayEnd, istOffset);
    print('');
    print('  Paksha       : ${pSunrise.tithi.paksha.sanskrit}');
    print('  Weekday      : ${pSunrise.vara.name}  (${pSunrise.vara.rulingPlanet.displayName})');
    print('');

    final moonInfo = chart.getPlanet(Planet.moon);
    final sunInfo = chart.getPlanet(Planet.sun);
    print('  Moon sign    : ${moonInfo?.zodiacSign ?? ""}  (${moonInfo?.longitude.toStringAsFixed(2)})');
    print('  Sun sign     : ${sunInfo?.zodiacSign ?? ""}  (${sunInfo?.longitude.toStringAsFixed(2)})');
    print('');

    print(' Planetary Positions at Sunrise (Sidereal / Lahiri) ');
    print('  ${"Planet".padRight(12)} ${"Longitude".padRight(12)} ${"Sign".padRight(18)} House  Nakshatra');
    print('  ${"-" * 72}');

    final orderedPlanets = [
      Planet.sun, Planet.moon, Planet.mercury, Planet.venus,
      Planet.mars, Planet.jupiter, Planet.saturn, Planet.meanNode,
    ];
    for (final planet in orderedPlanets) {
      final info = chart.getPlanet(planet);
      if (info == null) continue;
      final retro = info.isRetrograde ? ' (R)' : '';
      final combust = info.isCombust == true ? ' (C)' : '';
      final nakStr = '${info.nakshatra} P${info.pada}';
      print('  ${planet.displayName.padRight(12)}'
          ' ${info.longitude.toStringAsFixed(4).padRight(12)}'
          ' ${(info.zodiacSign).padRight(18)}'
          ' H${info.house.toString().padRight(4)}'
          ' $nakStr$retro$combust');
    }
    final rahu = chart.rahu;
    print('  ${"Rahu".padRight(12)} ${rahu.longitude.toStringAsFixed(4).padRight(12)} ${rahu.zodiacSign.padRight(18)} H${rahu.house}');
    final ketu = chart.ketu;
    print('  ${"Ketu".padRight(12)} ${ketu.longitude.toStringAsFixed(4).padRight(12)} ${ketu.zodiacSign}');
    print('');
    print('  Ascendant    : ${chart.ascendant.toStringAsFixed(4)}  (${chart.ascendantSign})');
    print('');
  } catch (e) {
    print('Error: $e');
  } finally {
    jyotish.dispose();
  }
}
