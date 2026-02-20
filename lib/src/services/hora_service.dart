import '../models/geographic_location.dart';
import '../models/muhurta.dart';
import '../models/planet.dart';
import 'ephemeris_service.dart';

/// Service for calculating Hora (Planetary Hours).
///
/// Each day is ruled by a planet (Vara Lord), and the day is divided into
/// 24 hours (Horas) - 12 during the day and 12 during the night. The length
/// of a Hora varies with the length of the day/night.
///
/// The first Hora of the day is ruled by the Vara Lord (e.g., Sun on Sunday).
/// Subsequent Horas follow the Chaldean order:
/// Saturn -> Jupiter -> Mars -> Sun -> Venus -> Mercury -> Moon -> Saturn...
class HoraService {
  HoraService(this._ephemerisService);

  final EphemerisService _ephemerisService;

  /// Chaldean order for Hora sequence (slowest to fastest apparent speed).
  static const List<Planet> chaldeanOrder = [
    Planet.saturn,
    Planet.jupiter,
    Planet.mars,
    Planet.sun,
    Planet.venus,
    Planet.mercury,
    Planet.moon,
  ];

  /// Gets the current planetary Hora for a given time and location.
  Future<HoraPeriod> getCurrentHora({
    required DateTime dateTime,
    required GeographicLocation location,
  }) async {
    final sunriseSunset = await _ephemerisService.getSunriseSunset(
      date: dateTime,
      location: location,
    );

    final sunrise = sunriseSunset.$1;
    final sunset = sunriseSunset.$2;

    if (sunrise == null || sunset == null) {
      throw Exception('Could not determine sunrise/sunset for location');
    }

    // Determine if we should consider the previous day's sunrise
    // (e.g. if time is 2 AM, it's before sunrise, so part of previous "day" night)
    DateTime effectiveSunrise = sunrise;
    DateTime effectiveSunset = sunset;

    // Check if the input time is before today's sunrise
    if (dateTime.isBefore(sunrise)) {
      final prevDate = dateTime.subtract(const Duration(days: 1));
      final prevSunriseSunset = await _ephemerisService.getSunriseSunset(
        date: prevDate,
        location: location,
      );
      if (prevSunriseSunset.$1 != null && prevSunriseSunset.$2 != null) {
        effectiveSunrise = prevSunriseSunset.$1!;
        effectiveSunset = prevSunriseSunset.$2!;
      }
    } else if (dateTime.isAfter(sunset)) {
      // If after sunset, we might need next day's sunrise for night duration calculation
      // But effective (start) sunrise is still today's sunrise
    }

    return _calculateHoraForTime(
        dateTime, effectiveSunrise, effectiveSunset, location);
  }

  /// Calculates the specific Hora for a given time relative to sunrise/sunset.
  Future<HoraPeriod> _calculateHoraForTime(
    DateTime time,
    DateTime sunrise,
    DateTime sunset,
    GeographicLocation location,
  ) async {
    // If time is before sunrise (meaning late night of previous day),
    // we need to handle it carefully. But getCurrentHora logic should align us to the correct "day".
    // Let's assume passed sunrise/sunset define the current Vedic day.

    // Calculate next sunrise for night duration
    DateTime nextSunrise;
    // Check if we are in the night period after sunset
    if (time.isAfter(sunset)) {
      final nextDate = sunrise.add(const Duration(days: 1));
      final nextSunriseSunset = await _ephemerisService.getSunriseSunset(
        date: nextDate,
        location: location,
      );
      nextSunrise =
          nextSunriseSunset.$1 ?? sunrise.add(const Duration(hours: 24));
    } else if (time.isBefore(sunrise)) {
      // This case is tricky: if the input time < sunrise, it technically belongs to previous day's night.
      // The caller (getCurrentHora) tried to adjust for this.
      // Let's rely on standard logic: find the specific interval containing 'time'.
      nextSunrise = sunrise; // Current 'sunrise' acts as end of previous night
      // To find start of previous night, we need previous sunset.
      final prevDate = sunrise.subtract(const Duration(days: 1));
      final prevSunriseSunset = await _ephemerisService.getSunriseSunset(
        date: prevDate,
        location: location,
      );
      // Re-assign sunrise/sunset to represent the previous day
      if (prevSunriseSunset.$1 != null && prevSunriseSunset.$2 != null) {
        sunrise = prevSunriseSunset.$1!;
        sunset = prevSunriseSunset.$2!;
      }
    } else {
      // Daytime
      final nextDate = sunrise.add(const Duration(days: 1));
      final nextSunriseSunset = await _ephemerisService.getSunriseSunset(
          date: nextDate, location: location);
      nextSunrise =
          nextSunriseSunset.$1 ?? sunrise.add(const Duration(hours: 24));
    }

    final isDaytime = time.isAfter(sunrise) && time.isBefore(sunset);

    // Day Lord determines the 1st Hora
    // Weekday of the SUNRISE determines the Day Lord
    // (e.g. Monday starts at Monday Sunrise)
    final weekday = sunrise.weekday;
    final dayLord = _getDayLord(weekday);

    // Find index of day lord in chaldean sequence
    int startIndex = chaldeanOrder.indexOf(dayLord);

    if (isDaytime) {
      final dayDuration = sunset.difference(sunrise);
      final horaLength = dayDuration.inMicroseconds / 12;
      final timeSinceSunrise = time.difference(sunrise).inMicroseconds;
      final horaIndex = (timeSinceSunrise / horaLength).floor(); // 0-11

      final currentHoraIndex = (startIndex + horaIndex) % 7;
      final lord = chaldeanOrder[currentHoraIndex];

      final startTime =
          sunrise.add(Duration(microseconds: (horaLength * horaIndex).round()));
      final endTime = sunrise
          .add(Duration(microseconds: (horaLength * (horaIndex + 1)).round()));

      return HoraPeriod(
        lord: lord,
        startTime: startTime,
        endTime: endTime,
        hourNumber: horaIndex + 1,
        isDaytime: true,
      );
    } else {
      // Nighttime
      // Night starts with the 1st Hora of night.
      // 12th hour of day is followed by 1st hour of night.
      // Sequence continues unbroken.
      // Day has 12 hours. So Night 1st hour is startIndex + 12 in sequence.
      // (startIndex + 12) % 7 = (startIndex + 5) % 7.

      final nightStartLordIndex = (startIndex + 5) % 7;

      final nightDuration = nextSunrise.difference(sunset);
      final horaLength = nightDuration.inMicroseconds / 12;
      final timeSinceSunset = time.difference(sunset).inMicroseconds;
      final horaIndex = (timeSinceSunset / horaLength).floor(); // 0-11

      final currentHoraIndex = (nightStartLordIndex + horaIndex) % 7;
      final lord = chaldeanOrder[currentHoraIndex];

      final startTime =
          sunset.add(Duration(microseconds: (horaLength * horaIndex).round()));
      final endTime = sunset
          .add(Duration(microseconds: (horaLength * (horaIndex + 1)).round()));

      return HoraPeriod(
        lord: lord,
        startTime: startTime,
        endTime: endTime,
        hourNumber: horaIndex + 1,
        isDaytime: false,
      );
    }
  }

  /// Calculates all 24 Horas for a complete day (Sunrise to next Sunrise).
  Future<List<HoraPeriod>> getHorasForDay({
    required DateTime date,
    required GeographicLocation location,
  }) async {
    // Get sunrise/sunset for the requested date
    final sunriseSunset = await _ephemerisService.getSunriseSunset(
      date: date,
      location: location,
    );

    var sunrise = sunriseSunset.$1;
    var sunset = sunriseSunset.$2;

    if (sunrise == null || sunset == null) return [];

    // Get next day's sunrise for night duration
    final nextDate = date.add(const Duration(days: 1));
    final nextSunriseSunset = await _ephemerisService.getSunriseSunset(
      date: nextDate,
      location: location,
    );
    final nextSunrise =
        nextSunriseSunset.$1 ?? sunrise.add(const Duration(hours: 24));

    final weekday = sunrise.weekday;
    final dayLord = _getDayLord(weekday);
    final startIndex = chaldeanOrder.indexOf(dayLord); // Index of 1st Hora Lord

    final horas = <HoraPeriod>[];

    // 12 Daytime Horas
    final dayDuration = sunset.difference(sunrise);
    final dayHoraLength = dayDuration.inMicroseconds / 12;

    for (var i = 0; i < 12; i++) {
      final lordIndex = (startIndex + i) % 7;
      final lord = chaldeanOrder[lordIndex];

      final start =
          sunrise.add(Duration(microseconds: (dayHoraLength * i).round()));
      final end = sunrise
          .add(Duration(microseconds: (dayHoraLength * (i + 1)).round()));

      horas.add(HoraPeriod(
        lord: lord,
        startTime: start,
        endTime: end,
        hourNumber: i + 1,
        isDaytime: true,
      ));
    }

    // 12 Nighttime Horas
    final nightDuration = nextSunrise.difference(sunset);
    final nightHoraLength = nightDuration.inMicroseconds / 12;
    // Night starts after 12 day hours. Offset = 12.
    final nightStartIndex = (startIndex + 12) % 7; // or (startIndex + 5) % 7

    for (var i = 0; i < 12; i++) {
      final lordIndex = (nightStartIndex + i) % 7;
      final lord = chaldeanOrder[lordIndex];

      final start =
          sunset.add(Duration(microseconds: (nightHoraLength * i).round()));
      final end = sunset
          .add(Duration(microseconds: (nightHoraLength * (i + 1)).round()));

      horas.add(HoraPeriod(
        lord: lord,
        startTime: start,
        endTime: end,
        hourNumber: i + 1,
        isDaytime: false,
      ));
    }

    return horas;
  }

  Planet _getDayLord(int weekday) {
    // DateTime.weekday: 1=Mon, ..., 7=Sun
    return switch (weekday) {
      7 => Planet.sun, // Sunday
      1 => Planet.moon, // Monday
      2 => Planet.mars, // Tuesday
      3 => Planet.mercury, // Wednesday
      4 => Planet.jupiter, // Thursday
      5 => Planet.venus, // Friday
      6 => Planet.saturn, // Saturday
      _ => Planet.sun,
    };
  }
}
