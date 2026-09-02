import 'package:jyotish/src/models/geographic_location.dart';
import 'package:jyotish/src/astronomy/astrology_time_service.dart';

/// Represents time divided according to the traditional Vedic system.
///
/// In the Vedic time measurement system:
/// - A day (Ahoratra) starts at local **Sunrise** and ends at the next Sunrise.
/// - The day is divided into **60 Ghatis** (1 Ghati = 24 minutes in mean time).
/// - Each Ghati is divided into **60 Vighatis** (1 Vighati = 24 seconds in mean time).
/// - Each Vighati is divided into **60 Liptas** (or Chas) (1 Lipta = 0.4 seconds in mean time).
/// - Alternatively, 1 Vighati is divided into **6 Pranas** (1 Prana = 4 seconds, representing a breath).
class VedicTime {
  /// The Ghati elapsed since sunrise (0 to 59).
  final int ghati;

  /// The Vighati elapsed since the start of the current Ghati (0 to 59).
  final int vighati;

  /// The Lipta (or Cha) elapsed since the start of the current Vighati (0 to 59).
  final int lipta;

  /// The Prana (breath) elapsed since the start of the current Vighati (0 to 5).
  final int prana;

  /// The exact Sunrise time that started this Vedic day.
  final DateTime currentSunrise;

  /// The exact Sunrise time that will end this Vedic day.
  final DateTime nextSunrise;

  /// The raw total Ghatis elapsed since sunrise as a double (0.0 to 60.0).
  final double totalGhatis;

  VedicTime({
    required this.ghati,
    required this.vighati,
    required this.lipta,
    required this.prana,
    required this.currentSunrise,
    required this.nextSunrise,
    required this.totalGhatis,
  });

  /// Formats the Vedic time as a string (e.g. "32 Ghati, 15 Vighati, 4 Lipta").
  String format({bool includeLipta = true, bool includePrana = false}) {
    final parts = <String>[
      '${ghati.toString().padLeft(2, '0')} G',
      '${vighati.toString().padLeft(2, '0')} V',
    ];
    if (includeLipta) {
      parts.add('${lipta.toString().padLeft(2, '0')} L');
    }
    if (includePrana) {
      parts.add('$prana P');
    }
    return parts.join(' : ');
  }

  @override
  String toString() => format(includeLipta: true, includePrana: true);

  /// Converts this [VedicTime] back to a Gregorian [DateTime].
  DateTime toDateTime() {
    final totalDuration = nextSunrise.difference(currentSunrise);
    final elapsedMs = (totalGhatis / 60.0) * totalDuration.inMilliseconds;
    return currentSunrise.add(Duration(milliseconds: elapsedMs.round()));
  }

  /// Calculates the current [VedicTime] for a given [time] and [location].
  ///
  /// Takes a custom [getSunriseSunset] function (usually from the core Jyotish singleton)
  /// to compute high-precision sunrise times.
  static Future<VedicTime> calculate({
    required DateTime time,
    required GeographicLocation location,
    required Future<(DateTime? sunrise, DateTime? sunset)> Function({
      required DateTime date,
      required GeographicLocation location,
    }) getSunriseSunset,
  }) async {
    final utcTime = time.toUtc();

    // 1. Fetch sunrise for today
    final (srTodayVal, _) = await getSunriseSunset(
      date: time,
      location: location,
    );
    final srToday = srTodayVal?.toUtc();
    if (srToday == null) {
      throw StateError(
        'Could not calculate sunrise for the specified date and location.',
      );
    }

    DateTime currentSunrise;
    DateTime nextSunrise;

    // 2. Determine if the given time belongs to today's Vedic day or the previous one
    if (utcTime.isBefore(srToday)) {
      // Before today's sunrise: the Vedic day started yesterday
      final yesterday = time.subtract(const Duration(days: 1));
      final (srYesterdayVal, _) = await getSunriseSunset(
        date: yesterday,
        location: location,
      );
      final srYesterday = srYesterdayVal?.toUtc();

      currentSunrise = srYesterday ?? srToday.subtract(const Duration(days: 1));
      nextSunrise = srToday;
    } else {
      // After or at today's sunrise: the Vedic day starts today
      final tomorrow = time.add(const Duration(days: 1));
      final (srTomorrowVal, _) = await getSunriseSunset(
        date: tomorrow,
        location: location,
      );
      final srTomorrow = srTomorrowVal?.toUtc();

      currentSunrise = srToday;
      nextSunrise = srTomorrow ?? srToday.add(const Duration(days: 1));
    }

    // 3. Robust adjustment: Check if time is after nextSunrise (rare rounding edge cases)
    if (utcTime.isAfter(nextSunrise) || utcTime.isAtSameMomentAs(nextSunrise)) {
      currentSunrise = nextSunrise;
      final dayAfterTomorrow = time.add(const Duration(days: 2));
      final (srDayAfterVal, _) = await getSunriseSunset(
        date: dayAfterTomorrow,
        location: location,
      );
      final srDayAfter = srDayAfterVal?.toUtc();

      nextSunrise = srDayAfter ?? currentSunrise.add(const Duration(days: 1));
    }

    // 4. Calculate intervals
    final totalDuration = nextSunrise.difference(currentSunrise);
    final elapsed = utcTime.difference(currentSunrise);

    final elapsedMs = elapsed.inMilliseconds.toDouble();
    final totalMs = totalDuration.inMilliseconds.toDouble();

    // Safety check for divisions
    if (totalMs <= 0) {
      throw StateError(
        'Sunrise interval calculation returned non-positive duration.',
      );
    }

    final fraction = (elapsedMs / totalMs).clamp(0.0, 0.999999);

    final totalGhatis = fraction * 60.0;
    final ghati = totalGhatis.floor();

    final remainingGhati = totalGhatis - ghati;
    final totalVighatis = remainingGhati * 60.0;
    final vighati = totalVighatis.floor();

    final remainingVighati = totalVighatis - vighati;
    final totalLiptas = remainingVighati * 60.0;
    final lipta = totalLiptas.floor();

    final totalPranas = remainingVighati * 6.0;
    final prana = totalPranas.floor();

    return VedicTime(
      ghati: ghati.clamp(0, 59),
      vighati: vighati.clamp(0, 59),
      lipta: lipta.clamp(0, 59),
      prana: prana.clamp(0, 5),
      currentSunrise: AstrologyTimeService.utcToLocal(
          currentSunrise, location.timezone ?? 'UTC'),
      nextSunrise: AstrologyTimeService.utcToLocal(
          nextSunrise, location.timezone ?? 'UTC'),
      totalGhatis: totalGhatis,
    );
  }
}
