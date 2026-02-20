import '../models/geographic_location.dart';
import '../models/muhurta.dart';
import 'ephemeris_service.dart';

/// Service for calculating Choghadiya periods.
///
/// Choghadiya is a system of 8 planetary periods during the day and 8 during the night.
/// Each period (approx 1.5 hours) is ruled by a planet and considered auspicious or inauspicious.
/// The sequence of Choghadiyas depends on the weekday.
class ChoghadiyaService {
  ChoghadiyaService(this._ephemerisService);

  final EphemerisService _ephemerisService;

  // Day Choghadiya Sequences (indices into ChoghadiyaType.values)
  // Udveg=0, Char=1, Labh=2, Amrit=3, Kaal=4, Shubh=5, Rog=6
  static const Map<int, List<ChoghadiyaType>> _daySequences = {
    7: [
      // Sunday
      ChoghadiyaType.udveg, ChoghadiyaType.char, ChoghadiyaType.labh,
      ChoghadiyaType.amrit,
      ChoghadiyaType.kaal, ChoghadiyaType.shubh, ChoghadiyaType.rog,
      ChoghadiyaType.udveg
    ],
    1: [
      // Monday
      ChoghadiyaType.amrit, ChoghadiyaType.kaal, ChoghadiyaType.shubh,
      ChoghadiyaType.rog,
      ChoghadiyaType.udveg, ChoghadiyaType.char, ChoghadiyaType.labh,
      ChoghadiyaType.amrit
    ],
    2: [
      // Tuesday
      ChoghadiyaType.rog, ChoghadiyaType.udveg, ChoghadiyaType.char,
      ChoghadiyaType.labh,
      ChoghadiyaType.amrit, ChoghadiyaType.kaal, ChoghadiyaType.shubh,
      ChoghadiyaType.rog
    ],
    3: [
      // Wednesday
      ChoghadiyaType.labh, ChoghadiyaType.amrit, ChoghadiyaType.kaal,
      ChoghadiyaType.shubh,
      ChoghadiyaType.rog, ChoghadiyaType.udveg, ChoghadiyaType.char,
      ChoghadiyaType.labh
    ],
    4: [
      // Thursday
      ChoghadiyaType.shubh, ChoghadiyaType.rog, ChoghadiyaType.udveg,
      ChoghadiyaType.char,
      ChoghadiyaType.labh, ChoghadiyaType.amrit, ChoghadiyaType.kaal,
      ChoghadiyaType.shubh
    ],
    5: [
      // Friday
      ChoghadiyaType.char, ChoghadiyaType.labh, ChoghadiyaType.amrit,
      ChoghadiyaType.kaal,
      ChoghadiyaType.shubh, ChoghadiyaType.rog, ChoghadiyaType.udveg,
      ChoghadiyaType.char
    ],
    6: [
      // Saturday
      ChoghadiyaType.kaal, ChoghadiyaType.shubh, ChoghadiyaType.rog,
      ChoghadiyaType.udveg,
      ChoghadiyaType.char, ChoghadiyaType.labh, ChoghadiyaType.amrit,
      ChoghadiyaType.kaal
    ],
  };

  // Night Choghadiya Sequences
  static const Map<int, List<ChoghadiyaType>> _nightSequences = {
    7: [
      // Sunday
      ChoghadiyaType.shubh, ChoghadiyaType.amrit, ChoghadiyaType.char,
      ChoghadiyaType.rog,
      ChoghadiyaType.kaal, ChoghadiyaType.labh, ChoghadiyaType.udveg,
      ChoghadiyaType.shubh
    ],
    1: [
      // Monday
      ChoghadiyaType.char, ChoghadiyaType.rog, ChoghadiyaType.amrit,
      ChoghadiyaType.char, // Wait, need to verify
      // Standard correction:
      // Mon Night: Char, Rog, Kaal, Labh, Udveg, Shubh, Amrit, Char
      // Let's use standard table logic instead of hardcoding all if pattern exists
      // Pattern: Day sequence starts with Day Lord.
      // Night sequence starts with... ?
      // Sun Night starts with Shubh (Jupiter). (5th from Sun?)
      // Mon Night starts with Char (Venus). (5th from Moon?)
      // Tue Night starts with Kaal (Saturn). (5th from Mars?)

      // Let's rely on standard tables.
      // Sun: Shubh, Amrit, Char, Rog, Kaal, Labh, Udveg, Shubh
      // Mon: Char, Rog, Kaal, Labh, Udveg, Shubh, Amrit, Char
      // Tue: Kaal, Labh, Udveg, Shubh, Amrit, Char, Rog, Kaal
      // Wed: Udveg, Shubh, Amrit, Char, Rog, Kaal, Labh, Udveg
      // Thu: Amrit, Char, Rog, Kaal, Labh, Udveg, Shubh, Amrit
      // Fri: Rog, Kaal, Labh, Udveg, Shubh, Amrit, Char, Rog
      // Sat: Labh, Udveg, Shubh, Amrit, Char, Rog, Kaal, Labh

      ChoghadiyaType.char, ChoghadiyaType.rog, ChoghadiyaType.kaal,
      ChoghadiyaType.labh,
      ChoghadiyaType.udveg, ChoghadiyaType.shubh, ChoghadiyaType.amrit,
      ChoghadiyaType.char
    ],
    2: [
      // Tuesday
      ChoghadiyaType.kaal, ChoghadiyaType.labh, ChoghadiyaType.udveg,
      ChoghadiyaType.shubh,
      ChoghadiyaType.amrit, ChoghadiyaType.char, ChoghadiyaType.rog,
      ChoghadiyaType.kaal
    ],
    3: [
      // Wednesday
      ChoghadiyaType.udveg, ChoghadiyaType.shubh, ChoghadiyaType.amrit,
      ChoghadiyaType.char,
      ChoghadiyaType.rog, ChoghadiyaType.kaal, ChoghadiyaType.labh,
      ChoghadiyaType.udveg
    ],
    4: [
      // Thursday
      ChoghadiyaType.amrit, ChoghadiyaType.char, ChoghadiyaType.rog,
      ChoghadiyaType.kaal,
      ChoghadiyaType.labh, ChoghadiyaType.udveg, ChoghadiyaType.shubh,
      ChoghadiyaType.amrit
    ],
    5: [
      // Friday
      ChoghadiyaType.rog, ChoghadiyaType.kaal, ChoghadiyaType.labh,
      ChoghadiyaType.udveg,
      ChoghadiyaType.shubh, ChoghadiyaType.amrit, ChoghadiyaType.char,
      ChoghadiyaType.rog
    ],
    6: [
      // Saturday
      ChoghadiyaType.labh, ChoghadiyaType.udveg, ChoghadiyaType.shubh,
      ChoghadiyaType.amrit,
      ChoghadiyaType.char, ChoghadiyaType.rog, ChoghadiyaType.kaal,
      ChoghadiyaType.labh
    ],
  };

  /// Calculates current Choghadiya.
  Future<Choghadiya> getCurrentChoghadiya({
    required DateTime dateTime,
    required GeographicLocation location,
  }) async {
    final sunriseSunset = await _ephemerisService.getSunriseSunset(
      date: dateTime,
      location: location,
    );
    // Logic similar to HoraService for "previous day" night handling
    var sunrise = sunriseSunset.$1;
    var sunset = sunriseSunset.$2;

    if (sunrise == null || sunset == null) throw Exception('No sunrise data');

    DateTime effectiveSunrise = sunrise;
    DateTime effectiveSunset = sunset;

    if (dateTime.isBefore(sunrise)) {
      final prevDate = dateTime.subtract(const Duration(days: 1));
      final prevInfo = await _ephemerisService.getSunriseSunset(
          date: prevDate, location: location);
      if (prevInfo.$1 != null) {
        effectiveSunrise = prevInfo.$1!;
        effectiveSunset = prevInfo.$2!;
      }
    }

    // Determine segments
    // Day: 8 segments from Sunrise to Sunset
    // Night: 8 segments from Sunset to Next Sunrise

    DateTime nextSunrise;
    if (dateTime.isAfter(effectiveSunset) ||
        dateTime.isBefore(effectiveSunrise)) {
      // Nighttime
      final nextDate = effectiveSunrise.add(const Duration(days: 1));
      final nextInfo = await _ephemerisService.getSunriseSunset(
          date: nextDate, location: location);
      nextSunrise =
          nextInfo.$1 ?? effectiveSunrise.add(const Duration(hours: 24));

      final nightDuration = nextSunrise.difference(effectiveSunset);
      final segmentLength = nightDuration.inMicroseconds / 8;
      final timeSinceSunset =
          dateTime.difference(effectiveSunset).inMicroseconds;
      final segmentIndex = (timeSinceSunset / segmentLength).floor();

      // Handle overflow if precision issues (e.g. at exactly next Sunrise)
      final adjustedIndex = segmentIndex >= 8 ? 7 : segmentIndex;

      final weekday =
          effectiveSunrise.weekday; // Weekday of the sunrise starting the day
      final type = _nightSequences[weekday]![adjustedIndex];

      final startTime = effectiveSunset
          .add(Duration(microseconds: (segmentLength * adjustedIndex).round()));
      final endTime = effectiveSunset.add(Duration(
          microseconds: (segmentLength * (adjustedIndex + 1)).round()));

      return Choghadiya(
        type: type,
        startTime: startTime,
        endTime: endTime,
        isDaytime: false,
        periodNumber: adjustedIndex + 1,
      );
    } else {
      // Daytime
      final dayDuration = effectiveSunset.difference(effectiveSunrise);
      final segmentLength = dayDuration.inMicroseconds / 8;
      final timeSinceSunrise =
          dateTime.difference(effectiveSunrise).inMicroseconds;
      final segmentIndex = (timeSinceSunrise / segmentLength).floor();

      final adjustedIndex = segmentIndex >= 8 ? 7 : segmentIndex;

      final weekday = effectiveSunrise.weekday;
      final type = _daySequences[weekday]![adjustedIndex];

      final startTime = effectiveSunrise
          .add(Duration(microseconds: (segmentLength * adjustedIndex).round()));
      final endTime = effectiveSunrise.add(Duration(
          microseconds: (segmentLength * (adjustedIndex + 1)).round()));

      return Choghadiya(
        type: type,
        startTime: startTime,
        endTime: endTime,
        isDaytime: true,
        periodNumber: adjustedIndex + 1,
      );
    }
  }
}
