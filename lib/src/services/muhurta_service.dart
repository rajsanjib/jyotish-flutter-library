import '../models/geographic_location.dart';
import '../models/muhurta.dart';
import '../models/planet.dart';

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

    return InauspiciousPeriods(
      rahukalam: rahuKalam,
      gulikalam: gulikaKalam,
      yamagandam: yamaGandam,
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
  }) {
    return _calculateInauspiciousPeriods(
      date: date,
      sunrise: sunrise,
      sunset: sunset,
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
}
