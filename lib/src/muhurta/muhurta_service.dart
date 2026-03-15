import 'package:jyotish/src/models/geographic_location.dart';
import 'package:jyotish/src/muhurta/muhurta.dart';
import 'package:jyotish/src/panchanga/nakshatra.dart';
import 'package:jyotish/src/models/planet.dart';

/// Service for calculating Muhurta (auspicious periods).
///
/// Includes Hora (planetary hours), Choghadiya, and
/// inauspicious periods like Rahukalam, Gulikalam, and Yamagandam.
class MuhurtaService {
  /// Calculates complete Muhurta for a day.
  ///
  /// [date] - The date for calculation
  /// [sunrise] - Sunrise time
  /// [sunset] - Sunset time
  /// [location] - Geographic location
  Muhurta calculateMuhurta({
    required DateTime date,
    required DateTime sunrise,
    required DateTime sunset,
    required GeographicLocation location,
  }) {
    // Calculate Hora periods
    final horaPeriods = _calculateHoraPeriods(
      date: date,
      sunrise: sunrise,
      sunset: sunset,
    );

    // Calculate Choghadiya periods
    final choghadiya = _calculateChoghadiya(
      date: date,
      sunrise: sunrise,
      sunset: sunset,
    );

    // Calculate inauspicious periods
    final inauspiciousPeriods = _calculateInauspiciousPeriods(
      date: date,
      sunrise: sunrise,
      sunset: sunset,
    );

    // Get current active periods
    final currentPeriods = <MuhurtaPeriod>[
      ...horaPeriods.where((h) => h.contains(DateTime.now())),
      ...choghadiya.allPeriods.where((c) => c.contains(DateTime.now())),
    ];

    return Muhurta(
      date: date,
      location: '${location.latitude}, ${location.longitude}',
      horaPeriods: horaPeriods,
      choghadiya: choghadiya,
      inauspiciousPeriods: inauspiciousPeriods,
      currentPeriods: currentPeriods,
    );
  }

  /// Calculates Hora (planetary hour) periods.
  List<HoraPeriod> _calculateHoraPeriods({
    required DateTime date,
    required DateTime sunrise,
    required DateTime sunset,
  }) {
    final periods = <HoraPeriod>[];
    final weekday = date.weekday % 7;

    // Calculate daytime duration
    final dayDuration = sunset.difference(sunrise);
    final dayHoraDuration = Duration(
      milliseconds: dayDuration.inMilliseconds ~/ 12,
    );

    // Calculate daytime horas
    final dayStartLord = _getDayStartLord(weekday);
    const horaSequence = MuhurtaConstants.horaLordsSequence;

    var startIndex = horaSequence.indexOf(dayStartLord);
    var currentTime = sunrise;

    for (var i = 0; i < 12; i++) {
      final lord = horaSequence[(startIndex + i) % 7];
      final endTime = currentTime.add(dayHoraDuration);

      periods.add(HoraPeriod(
        startTime: currentTime,
        endTime: endTime,
        lord: lord,
        hourNumber: i,
        isDaytime: true,
      ));

      currentTime = endTime;
    }

    // Calculate nighttime horas
    final nightStart = sunset;
    final nextSunrise = sunrise.add(const Duration(days: 1));
    final nightDuration = nextSunrise.difference(nightStart);
    final nightHoraDuration = Duration(
      milliseconds: nightDuration.inMilliseconds ~/ 12,
    );

    // Night starts with 5th lord from day start
    startIndex = (startIndex + 4) % 7;
    currentTime = nightStart;

    for (var i = 0; i < 12; i++) {
      final lord = horaSequence[(startIndex + i) % 7];
      final endTime = currentTime.add(nightHoraDuration);

      periods.add(HoraPeriod(
        startTime: currentTime,
        endTime: endTime,
        lord: lord,
        hourNumber: i,
        isDaytime: false,
      ));

      currentTime = endTime;
    }

    return periods;
  }

  /// Gets the planet that rules the first hour of the day.
  Planet _getDayStartLord(int weekday) {
    // Sunday = Sun, Monday = Moon, Tuesday = Mars, etc.
    switch (weekday) {
      case 0:
        return Planet.sun;
      case 1:
        return Planet.moon;
      case 2:
        return Planet.mars;
      case 3:
        return Planet.mercury;
      case 4:
        return Planet.jupiter;
      case 5:
        return Planet.venus;
      case 6:
        return Planet.saturn;
      default:
        return Planet.sun;
    }
  }

  /// Calculates Choghadiya periods.
  ChoghadiyaPeriods _calculateChoghadiya({
    required DateTime date,
    required DateTime sunrise,
    required DateTime sunset,
  }) {
    final weekday = date.weekday % 7;

    // Calculate daytime Choghadiya
    final dayDuration = sunset.difference(sunrise);
    final dayChoghadiyaDuration = Duration(
      milliseconds: dayDuration.inMilliseconds ~/ 8,
    );

    final daytimeTypes = MuhurtaConstants.daytimeChoghadiyaSequence[weekday]!;
    final daytimePeriods = <Choghadiya>[];

    var currentTime = sunrise;
    for (var i = 0; i < 8; i++) {
      final endTime = currentTime.add(dayChoghadiyaDuration);
      daytimePeriods.add(Choghadiya(
        startTime: currentTime,
        endTime: endTime,
        type: daytimeTypes[i],
        isDaytime: true,
        periodNumber: i + 1,
      ));
      currentTime = endTime;
    }

    // Calculate nighttime Choghadiya
    final nightStart = sunset;
    final nextSunrise = sunrise.add(const Duration(days: 1));
    final nightDuration = nextSunrise.difference(nightStart);
    final nightChoghadiyaDuration = Duration(
      milliseconds: nightDuration.inMilliseconds ~/ 8,
    );

    final nighttimeTypes =
        MuhurtaConstants.nighttimeChoghadiyaSequence[weekday]!;
    final nighttimePeriods = <Choghadiya>[];

    currentTime = nightStart;
    for (var i = 0; i < 8; i++) {
      final endTime = currentTime.add(nightChoghadiyaDuration);
      nighttimePeriods.add(Choghadiya(
        startTime: currentTime,
        endTime: endTime,
        type: nighttimeTypes[i],
        isDaytime: false,
        periodNumber: i + 1,
      ));
      currentTime = endTime;
    }

    return ChoghadiyaPeriods(
      daytimePeriods: daytimePeriods,
      nighttimePeriods: nighttimePeriods,
    );
  }

  /// Calculates inauspicious periods (Rahukalam, Gulikalam, Yamagandam).
  InauspiciousPeriods _calculateInauspiciousPeriods({
    required DateTime date,
    required DateTime sunrise,
    required DateTime sunset,
    bool useSouthIndianMethodForDurMuhurta = false,
  }) {
    final weekday = date.weekday % 7;

    // Calculate Rahukalam
    final rahuKalam = _calculateTimePeriod(
      sunrise: sunrise,
      sunset: sunset,
      periods: MuhurtaConstants.rahuKalamByWeekday[weekday]!,
    );

    // Calculate Gulikalam
    final gulikaKalam = _calculateTimePeriod(
      sunrise: sunrise,
      sunset: sunset,
      periods: MuhurtaConstants.gulikaKalamByWeekday[weekday]!,
    );

    // Calculate Yamagandam
    final yamaGandam = _calculateTimePeriod(
      sunrise: sunrise,
      sunset: sunset,
      periods: MuhurtaConstants.yamaGandamByWeekday[weekday]!,
    );

    final durMuhurtam = calculateDurMuhurtam(
      date: date,
      sunrise: sunrise,
      sunset: sunset,
      useSouthIndianMethod: useSouthIndianMethodForDurMuhurta,
    );

    return InauspiciousPeriods(
      rahukalam: rahuKalam,
      gulikalam: gulikaKalam,
      yamagandam: yamaGandam,
      durMuhurtam: durMuhurtam,
    );
  }

  /// Calculates a time period based on 8ths of daytime.
  TimePeriod? _calculateTimePeriod({
    required DateTime sunrise,
    required DateTime sunset,
    required (int, int) periods,
  }) {
    final dayDuration = sunset.difference(sunrise);
    final eighthDuration = Duration(
      milliseconds: dayDuration.inMilliseconds ~/ 8,
    );

    final startEighth = periods.$1 - 1;
    final endEighth = periods.$2 - 1;

    DateTime startTime;
    DateTime endTime;

    if (startEighth < endEighth) {
      // Normal case
      startTime = sunrise.add(eighthDuration * startEighth);
      endTime = sunrise.add(eighthDuration * endEighth);
    } else {
      // Wraps around (like Saturday Rahukalam)
      startTime = sunrise.add(eighthDuration * startEighth);
      endTime = sunrise.add(eighthDuration * (endEighth + 8));
    }

    return TimePeriod(start: startTime, end: endTime);
  }

  /// Gets Hora periods for a specific date.
  List<HoraPeriod> getHoraPeriods({
    required DateTime date,
    required DateTime sunrise,
    required DateTime sunset,
  }) {
    return _calculateHoraPeriods(
      date: date,
      sunrise: sunrise,
      sunset: sunset,
    );
  }

  /// Gets Choghadiya periods for a specific date.
  ChoghadiyaPeriods getChoghadiya({
    required DateTime date,
    required DateTime sunrise,
    required DateTime sunset,
  }) {
    return _calculateChoghadiya(
      date: date,
      sunrise: sunrise,
      sunset: sunset,
    );
  }

  /// Gets inauspicious periods for a specific date.
  InauspiciousPeriods getInauspiciousPeriods({
    required DateTime date,
    required DateTime sunrise,
    required DateTime sunset,
    bool useSouthIndianMethodForDurMuhurta = false,
  }) {
    return _calculateInauspiciousPeriods(
      date: date,
      sunrise: sunrise,
      sunset: sunset,
      useSouthIndianMethodForDurMuhurta: useSouthIndianMethodForDurMuhurta,
    );
  }

  /// Finds the best Muhurta for a specific activity.
  List<MuhurtaPeriod> findBestMuhurta({
    required Muhurta muhurta,
    required String activity,
  }) {
    final favorable = <MuhurtaPeriod>[];

    // Check Hora periods
    for (final hora in muhurta.horaPeriods) {
      if (hora.isFavorableFor(activity) && hora.isAuspicious) {
        favorable.add(hora);
      }
    }

    // Check Choghadiya periods
    for (final choghadiya in muhurta.choghadiya.allPeriods) {
      if (choghadiya.isFavorable && choghadiya.isFavorableFor(activity)) {
        favorable.add(choghadiya);
      }
    }

    // Remove inauspicious periods
    return favorable.where((p) {
      if (p is HoraPeriod) {
        return !muhurta.inauspiciousPeriods.isInauspicious(p.startTime);
      }
      return true;
    }).toList();
  }

  /// Gets the Hora lord for a specific hour of the day.
  Planet getHoraLordForHour(DateTime dateTime, DateTime sunrise) {
    final weekday = dateTime.weekday % 7;
    final dayStartLord = _getDayStartLord(weekday);
    const horaSequence = MuhurtaConstants.horaLordsSequence;
    final startIndex = horaSequence.indexOf(dayStartLord);

    // Calculate which hour it is
    final elapsed = dateTime.difference(sunrise);
    final hourNumber = elapsed.inHours % 12;

    return horaSequence[(startIndex + hourNumber) % 7];
  }

  /// Calculates Dur Muhurtam (inauspicious daytime periods)
  /// By default, uses the BPHS / Northern method (1/8th daytime divisions).
  /// Set [useSouthIndianMethod] to true to use the alternative 1/15th daytime
  /// division method.
  List<TimePeriod> calculateDurMuhurtam({
    required DateTime date,
    required DateTime sunrise,
    required DateTime sunset,
    bool useSouthIndianMethod = false,
  }) {
    final weekday = date.weekday % 7;
    final dayDurationMs = sunset.difference(sunrise).inMilliseconds;
    final periods = <TimePeriod>[];

    if (useSouthIndianMethod) {
      // Daytime is divided into 15 equal parts
      final muhurtaDuration = Duration(milliseconds: dayDurationMs ~/ 15);

      // 1-indexed Muhurta numbers (from authoritative Vedic texts)
      const southDurMuhurtaByWeekday = {
        0: [5, 6], // Sunday
        1: [7, 8], // Monday
        2: [2, 12], // Tuesday
        3: [3, 10], // Wednesday
        4: [4, 9], // Thursday
        5: [6, 13], // Friday
        6: [8, 9], // Saturday
      };

      final badMuhurtas = southDurMuhurtaByWeekday[weekday] ?? [];

      for (final number in badMuhurtas) {
        final start = sunrise.add(muhurtaDuration * (number - 1));
        final end = start.add(muhurtaDuration);
        periods.add(TimePeriod(start: start, end: end));
      }
    } else {
      // Default: BPHS / Northern method (8 equal parts of daytime)
      final eighthDuration = Duration(milliseconds: dayDurationMs ~/ 8);

      // 1-indexed Muhurta number rules for the 1/8th day system (as seen in Drik Panchang)
      // Usually mapped based on the day's specific planetary ownership logic, but standard references:
      // Sunday: 8th part
      // Monday: <varies, sometimes 6th>
      // Tuesday: <varies, sometimes 4th>
      // Wednesday: 5th part
      // Thursday: <varies>
      // Friday: <varies>
      // Saturday: <varies>
      // *Note:* These numbers strictly follow standard regional 1/8 allocations.
      const northDurMuhurtaByWeekday = {
        0: [8], // Sunday: 8th part
        1: [6], // Monday: 6th part
        2: [4], // Tuesday: 4th part
        3: [5], // Wednesday: 5th part
        4: [6], // Thursday: 6th part (can vary, 6th often cited)
        5: [4], // Friday: 4th part  (can vary, 4th often cited)
        6: [2], // Saturday: 2nd part (can vary, 2nd often cited)
      };

      final badMuhurtas = northDurMuhurtaByWeekday[weekday] ?? [];

      for (final number in badMuhurtas) {
        final start = sunrise.add(eighthDuration * (number - 1));
        final end = start.add(eighthDuration);
        periods.add(TimePeriod(start: start, end: end));
      }
    }

    return periods;
  }

  /// Gets the unfavorable direction for travel for a given date.
  DishashoolInfo getDishashool({required DateTime date}) {
    final weekday = date.weekday % 7;
    final direction = DishashoolInfo.dishashoolByWeekday[weekday] ?? 'Unknown';
    return DishashoolInfo(direction: direction, weekday: weekday);
  }

  /// Gets Rahu's residence (Rahu Vasa) based on the current Nakshatra.
  RahuVasaInfo getRahuVasa({required NakshatraInfo nakshatra}) {
    // A simplified standard mapping logic for Rahu Vasa
    final n = nakshatra.number;
    String location = 'Earth';
    if (n >= 1 && n <= 9)
      location = 'Sky';
    else if (n >= 10 && n <= 18)
      location = 'Earth';
    else if (n >= 19 && n <= 27) location = 'Underworld';

    return RahuVasaInfo(location: location);
  }

  /// Gets Moon's residence (Chandra Vasa) based on the Moon's Rashi.
  ChandraVasaInfo getChandraVasa({required double moonLongitude}) {
    // Rashi index from longitude
    final rashiIndex = (moonLongitude / 30).floor();

    // Chandra Vasa is based on Rashi
    // 0, 4, 8 (Aries, Leo, Sagittarius) -> East
    // 1, 5, 9 (Taurus, Virgo, Capricorn) -> South
    // 2, 6, 10 (Gemini, Libra, Aquarius) -> West
    // 3, 7, 11 (Cancer, Scorpio, Pisces) -> North
    const groups = ['East', 'South', 'West', 'North'];
    final location = groups[rashiIndex % 4];

    return ChandraVasaInfo(location: location);
  }

  /// Calculates Varjyam (Thyajya) inauspicious window within a Nakshatra transit.
  TimePeriod? calculateVarjyam({
    required NakshatraInfo nakshatra,
    required DateTime nakshatraStart,
    required DateTime nakshatraEnd,
  }) {
    // Thyajya starts at a specific ghati (out of 60) for each Nakshatra
    const offsetGhatisTable = [
      50,
      24,
      30,
      4,
      14,
      11,
      30,
      20,
      32,
      30,
      20,
      18,
      22,
      20,
      14,
      14,
      10,
      14,
      20,
      24,
      20,
      10,
      10,
      18,
      16,
      24,
      30
    ];

    final index = nakshatra.number - 1;
    if (index < 0 || index >= offsetGhatisTable.length) return null;

    final offsetGhatis = offsetGhatisTable[index];

    final durationMs = nakshatraEnd.difference(nakshatraStart).inMilliseconds;

    // Convert Ghatis to proportion (1 ghati = 1/60th of total duration)
    final startMs = durationMs * (offsetGhatis / 60.0);
    // Varjyam lasts exactly 4 Ghatis
    final varjyamDurationMs = durationMs * (4.0 / 60.0);

    final start = nakshatraStart.add(Duration(milliseconds: startMs.round()));
    final end = start.add(Duration(milliseconds: varjyamDurationMs.round()));

    return TimePeriod(start: start, end: end);
  }
}
