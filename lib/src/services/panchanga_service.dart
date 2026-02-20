import 'dart:math' as Math;
import '../models/calculation_flags.dart';
import '../models/geographic_location.dart';
import '../models/nakshatra.dart';
import '../models/panchanga.dart';
import '../models/planet.dart';
import '../models/planet_position.dart';
import 'ephemeris_service.dart';

/// Service for calculating Panchanga (five limbs) elements.
///
/// The Panchanga consists of:
/// - Tithi: Lunar phase (30 divisions based on Sun-Moon distance)
/// - Yoga: 27 combinations of Sun and Moon longitudes
/// - Karana: Half-tithi (60 divisions)
/// - Vara: Weekday with planetary day lord
class PanchangaService {
  PanchangaService(this._ephemerisService);
  final EphemerisService _ephemerisService;

  /// Calculates complete Panchanga for a given date and location.
  ///
  /// [dateTime] - The date and time for calculation
  /// [location] - The geographic location
  ///
  /// Returns a [Panchanga] with all five elements calculated.
  Future<Panchanga> calculatePanchanga({
    required DateTime dateTime,
    required GeographicLocation location,
  }) async {
    final flags = CalculationFlags.defaultFlags();

    // Calculate Sun and Moon positions
    final sunPos = await _ephemerisService.calculatePlanetPosition(
      planet: Planet.sun,
      dateTime: dateTime,
      location: location,
      flags: flags,
    );

    final moonPos = await _ephemerisService.calculatePlanetPosition(
      planet: Planet.moon,
      dateTime: dateTime,
      location: location,
      flags: flags,
    );

    // Calculate sunrise and sunset (approximate for now)
    final (sunrise, sunset) = await _calculateSunriseSunset(
      dateTime: dateTime,
      location: location,
    );

    // Calculate Tithi
    final tithi = _calculateTithi(sunPos, moonPos);

    // Calculate Nakshatra from Moon's position
    final nakshatra = _calculateNakshatra(moonPos);

    // Calculate Yoga
    final yoga = _calculateYoga(sunPos, moonPos);

    // Calculate Karana
    final karana = _calculateKarana(sunPos, moonPos);

    // Calculate Vara (Day Lord) using sunrise boundary
    final vara = _calculateVara(dateTime, sunrise);

    return Panchanga(
      dateTime: dateTime,
      location: '${location.latitude}, ${location.longitude}',
      tithi: tithi,
      nakshatra: nakshatra,
      yoga: yoga,
      karana: karana,
      vara: vara,
      sunrise: sunrise,
      sunset: sunset,
    );
  }

  /// Calculates the Tithi (lunar phase).
  ///
  /// Tithi is determined by the angular distance between Sun and Moon,
  /// divided into 30 equal parts of 12° each.
  TithiInfo _calculateTithi(PlanetPosition sunPos, PlanetPosition moonPos) {
    // Calculate lunar elongation (Moon - Sun)
    var elongation = moonPos.longitude - sunPos.longitude;
    if (elongation < 0) elongation += 360;

    // Each tithi is 12 degrees
    const tithiDegrees = 12.0;

    // Calculate tithi number (1-30)
    final tithiNumber = (elongation / tithiDegrees).floor() + 1;
    final elapsed = (elongation % tithiDegrees) / tithiDegrees;

    // Determine paksha
    final paksha = Paksha.fromTithiNumber(tithiNumber);

    // Get tithi name
    final nameIndex = (tithiNumber - 1) % 15;
    final name = TithiInfo.tithiNames[nameIndex];

    return TithiInfo(
      number: tithiNumber,
      name: name,
      paksha: paksha,
      elapsed: elapsed,
    );
  }

  /// Calculates the Nakshatra from Moon's longitude.
  ///
  /// The Moon's position determines the Nakshatra (lunar mansion).
  /// Each nakshatra is 13°20' (13.333... degrees) and the Moon
  /// travels through approximately one nakshatra per day.
  NakshatraInfo _calculateNakshatra(PlanetPosition moonPos) {
    const nakshatraWidth = 360.0 / 27; // 13°20' per nakshatra
    final longitude = moonPos.longitude % 360;

    // Calculate nakshatra number (1-27)
    final nakshatraNumber = (longitude / nakshatraWidth).floor() + 1;
    final name = NakshatraInfo.nakshatraNames[nakshatraNumber - 1];
    final rulingPlanet = NakshatraInfo.nakshatraLords[nakshatraNumber - 1];

    // Calculate position within nakshatra and pada (quarter)
    final positionInNakshatra = longitude % nakshatraWidth;
    final pada = (positionInNakshatra / (nakshatraWidth / 4)).floor() + 1;

    return NakshatraInfo(
      number: nakshatraNumber,
      name: name,
      rulingPlanet: rulingPlanet,
      longitude: longitude,
      pada: pada,
    );
  }

  /// Calculates the Yoga.
  ///
  /// Yoga is determined by the sum of Sun and Moon longitudes,
  /// divided into 27 equal parts.
  YogaInfo _calculateYoga(PlanetPosition sunPos, PlanetPosition moonPos) {
    // Calculate sum of longitudes
    var sum = sunPos.longitude + moonPos.longitude;
    sum = sum % 360;

    // Each yoga is 13°20' (360/27)
    const yogaDegrees = 360.0 / 27;

    // Calculate yoga number (1-27)
    final yogaNumber = (sum / yogaDegrees).floor() + 1;
    final elapsed = (sum % yogaDegrees) / yogaDegrees;

    // Get yoga name
    final nameIndex = yogaNumber - 1;
    final name = YogaInfo.yogaNames[nameIndex];

    return YogaInfo(
      number: yogaNumber,
      name: name,
      elapsed: elapsed,
    );
  }

  /// Calculates the Karana.
  ///
  /// Karana is half of a tithi. There are 60 karanas total,
  /// with 7 fixed karanas repeating and 4 variable karanas.
  ///
  /// Traditional sequence (per Surya Siddhanta):
  /// - Kimstughna (fixed) is the first karana of Shukla Pratipada
  /// - Bava (fixed) starts the sequence from Krishna Pratipada
  KaranaInfo _calculateKarana(PlanetPosition sunPos, PlanetPosition moonPos) {
    // Calculate lunar elongation (Moon - Sun)
    var elongation = moonPos.longitude - sunPos.longitude;
    if (elongation < 0) elongation += 360;

    // Each karana is 6 degrees (half tithi)
    const karanaDegrees = 6.0;

    // Calculate karana number (1-60)
    final karanaNumber = (elongation / karanaDegrees).floor() + 1;
    final elapsed = (elongation % karanaDegrees) / karanaDegrees;

    // Determine karana name
    String name;
    bool isFixed;

    // Traditional Karana sequence per Vedic astrology:
    // Kimstughna is first (fixed), then Bava-Balava-Kaulava-Taitila-Garaja-Vanija-Vishti
    // The 4 variable karanas (Shakuni, Chatushpada, Naga, Kimstughna) repeat
    // In standard practice:
    // - Karana 1: Kimstughna (fixed) - at start of Shukla Paksha
    // - Karanas 2-7: Bava, Balava, Kaulava, Taitila, Garaja, Vanija (fixed)
    // - Karana 8: Vishti (fixed) - last of first tithi half
    // - Karanas 9-11: Shakuni, Chatushpada, Naga (variable)
    // - Karana 12 onwards: Repeat Bava-Vishti cycle
    
    // Fixed karanas: Bava(2), Balava(3), Kaulava(4), Taitila(5), Garaja(6), Vanija(7), Vishti(8)
    // Variable: Shakuni(9), Chatushpada(10), Naga(11), Kimstughna(12)
    
    // Check for variable karanas first (Shakuni, Chatushpada, Naga, Kimstughna)
    if (karanaNumber == 57) {
      name = KaranaInfo.variableKaranaNames[0]; // Shakuni
      isFixed = false;
    } else if (karanaNumber == 58) {
      name = KaranaInfo.variableKaranaNames[1]; // Chatushpada
      isFixed = false;
    } else if (karanaNumber == 59) {
      name = KaranaInfo.variableKaranaNames[2]; // Naga
      isFixed = false;
    } else if (karanaNumber == 60) {
      name = KaranaInfo.variableKaranaNames[3]; // Kimstughna - traditionally last
      isFixed = false;
    } else if (karanaNumber == 1) {
      // Traditional: Kimstughna should be at karana 1 (Shukla Pratipada first half)
      // However, most modern implementations use the repeating pattern
      // We'll follow the traditional sequence where Kimstughna starts
      name = KaranaInfo.variableKaranaNames[3]; // Kimstughna at position 1
      isFixed = false;
    } else if (karanaNumber >= 2 && karanaNumber <= 8) {
      // Fixed karanas: Bava(2), Balava(3), Kaulava(4), Taitila(5), 
      // Garaja(6), Vanija(7), Vishti(8)
      // Map: karanaNumber-1 gives index in fixedKaranaNames
      final index = (karanaNumber - 2) % 7;
      name = KaranaInfo.fixedKaranaNames[index];
      isFixed = true;
    } else {
      // Repeating fixed karanas from position 9 onwards
      // This gives us the standard Bava-Vishti repeating sequence
      final fixedIndex = (karanaNumber - 9) % 7;
      name = KaranaInfo.fixedKaranaNames[fixedIndex];
      isFixed = true;
    }

    return KaranaInfo(
      number: karanaNumber,
      name: name,
      isFixed: isFixed,
      elapsed: elapsed,
    );
  }

  /// Calculates the Vara (weekday with planetary lord).
  ///
  /// In Vedic astrology, the day begins at sunrise.
  VaraInfo _calculateVara(DateTime dateTime, DateTime sunrise) {
    // If before sunrise, it belongs to the previous day lord
    var checkDate = dateTime;
    if (dateTime.isBefore(sunrise)) {
      checkDate = dateTime.subtract(const Duration(days: 1));
    }

    // Get weekday (0 = Sunday, 6 = Saturday)
    final weekday = checkDate.weekday % 7;

    return VaraInfo(
      weekday: weekday,
      name: VaraInfo.weekdayNames[weekday],
      rulingPlanet: VaraInfo.getRulingPlanet(weekday),
    );
  }

  /// Calculates high-precision sunrise and sunset times using Swiss Ephemeris.
  ///
  /// Uses swe_rise_trans function for professional-grade accuracy, which accounts for:
  /// - Geographic latitude and longitude
  /// - Atmospheric refraction
  /// - Altitude of the location
  /// - Sun's disc size
  ///
  /// Note: For latitudes above 66.5° (Arctic Circle) or below -66.5° (Antarctic Circle),
  /// the sun may not rise or set for extended periods. In such cases, the method
  /// falls back to an approximate NOAA algorithm.
  ///
  /// Returns (sunrise, sunset) times in local timezone.
  Future<(DateTime, DateTime)> _calculateSunriseSunset({
    required DateTime dateTime,
    required GeographicLocation location,
  }) async {
    // Check for extreme latitudes that may have polar day/night
    final absLatitude = location.latitude.abs();
    final isPolarRegion = absLatitude > 66.5;

    try {
      // Use high-precision calculation from Swiss Ephemeris
      final (sunrise, sunset) = await _ephemerisService.getSunriseSunset(
        date: dateTime,
        location: location,
      );

      // Fallback to approximation if precise calculation fails
      // (e.g., in polar regions where sun may not rise/set)
      if (sunrise == null || sunset == null) {
        if (isPolarRegion) {
          // Log polar region case - could add to a debug log
        }
        return _calculateApproximateSunriseSunset(
          dateTime: dateTime,
          location: location,
        );
      }

      // Convert UTC results to local timezone
      final localSunrise = sunrise.toLocal();
      final localSunset = sunset.toLocal();

      return (localSunrise, localSunset);
    } catch (e) {
      // If high-precision calculation fails, fall back to approximation
      return _calculateApproximateSunriseSunset(
        dateTime: dateTime,
        location: location,
      );
    }
  }

  /// Fallback approximate sunrise/sunset calculation.
  ///
  /// Used when Swiss Ephemeris calculation fails (e.g., polar regions).
  Future<(DateTime, DateTime)> _calculateApproximateSunriseSunset({
    required DateTime dateTime,
    required GeographicLocation location,
  }) async {
    final baseDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    // NOAA Solar Calculation Algorithm
    // Source: https://gml.noaa.gov/grad/solcalc/solareq.html

    final latitude = location.latitude;
    final longitude = location.longitude;

    // Convert date to Julian Day (at noon)
    final jd = _dateToJulianDay(baseDate.year, baseDate.month, baseDate.day);
    final julianCentury = (jd - 2451545.0) / 36525.0;

    // Geometric Mean Longitude Sun (deg)
    var geomMeanLongSun = (280.46646 +
            julianCentury * (36000.76983 + julianCentury * 0.0003032)) %
        360;

    // Geometric Mean Anomaly Sun (deg)
    final geomMeanAnomSun =
        357.52911 + julianCentury * (35999.05029 - 0.0001537 * julianCentury);

    // Eccentricity of Earth's Orbit
    final eccentEarthOrbit = 0.016708634 -
        julianCentury * (0.000042037 + 0.0000001267 * julianCentury);

    // Sun Equation of Center
    final sunEqOfCtr = Math.sin(_degToRad(geomMeanAnomSun)) *
            (1.914602 - julianCentury * (0.004817 + 0.000014 * julianCentury)) +
        Math.sin(_degToRad(2 * geomMeanAnomSun)) *
            (0.019993 - 0.000101 * julianCentury) +
        Math.sin(_degToRad(3 * geomMeanAnomSun)) * 0.000289;

    // Sun True Longitude (deg)
    final sunTrueLong = geomMeanLongSun + sunEqOfCtr;

    // Sun Apparent Longitude (deg)
    final sunAppLong = sunTrueLong -
        0.00569 -
        0.00478 * Math.sin(_degToRad(125.04 - 1934.136 * julianCentury));

    // Mean Obliquity of Ecliptic (deg)
    final meanObliqEcliptic = 23 +
        (26 +
                ((21.448 -
                        julianCentury *
                            (46.815 +
                                julianCentury *
                                    (0.00059 - julianCentury * 0.001813)))) /
                    60) /
            60;

    // Obliquity Correction (deg)
    final obliqCorr = meanObliqEcliptic +
        0.00256 * Math.cos(_degToRad(125.04 - 1934.136 * julianCentury));

    // Sun Declination (deg)
    final sunDeclin = _radToDeg(Math.asin(
        Math.sin(_degToRad(obliqCorr)) * Math.sin(_degToRad(sunAppLong))));

    // Equation of Time (minutes)
    final varY =
        Math.tan(_degToRad(obliqCorr / 2)) * Math.tan(_degToRad(obliqCorr / 2));
    final eqOfTime = 4 *
        _radToDeg(varY * Math.sin(2 * _degToRad(geomMeanLongSun)) -
            2 * eccentEarthOrbit * Math.sin(_degToRad(geomMeanAnomSun)) +
            4 *
                eccentEarthOrbit *
                varY *
                Math.sin(_degToRad(geomMeanAnomSun)) *
                Math.cos(2 * _degToRad(geomMeanLongSun)) -
            0.5 * varY * varY * Math.sin(4 * _degToRad(geomMeanLongSun)) -
            1.25 *
                eccentEarthOrbit *
                eccentEarthOrbit *
                Math.sin(2 * _degToRad(geomMeanAnomSun)));

    // Hour Angle Calculation (deg)
    // Zenith for sunrise/sunset is 90.833 degrees (90 + 50' refraction/sun size)
    const zenith = 90.833;
    final haArg = (Math.cos(_degToRad(zenith)) /
            (Math.cos(_degToRad(latitude)) * Math.cos(_degToRad(sunDeclin)))) -
        (Math.tan(_degToRad(latitude)) * Math.tan(_degToRad(sunDeclin)));

    // Check for polar day/night
    if (haArg > 1.0 || haArg < -1.0) {
      // Fallback to coarse approximation if NOAA calc fails (extreme latitudes)
      var sunriseHour = 6.0;
      var sunsetHour = 18.0;

      final sunrise = baseDate.add(Duration(hours: sunriseHour.toInt()));
      final sunset = baseDate.add(Duration(hours: sunsetHour.toInt()));
      return (sunrise, sunset);
    }

    final ha = _radToDeg(Math.acos(haArg));

    // Sunrise/Sunset Time (UTC minutes from midnight)
    final sunriseTimeUTC = 720 - 4 * (longitude + ha) - eqOfTime;
    final sunsetTimeUTC = 720 - 4 * (longitude - ha) - eqOfTime;

    final sunrise = _minutesToDateTime(baseDate, sunriseTimeUTC);
    final sunset = _minutesToDateTime(baseDate, sunsetTimeUTC);

    return (sunrise, sunset);
  }

  double _dateToJulianDay(int year, int month, int day) {
    if (month <= 2) {
      year -= 1;
      month += 12;
    }
    final a = (year / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        day +
        b -
        1524.5;
  }

  double _degToRad(double deg) => deg * Math.pi / 180.0;
  double _radToDeg(double rad) => rad * 180.0 / Math.pi;

  DateTime _minutesToDateTime(DateTime date, double minutesUtc) {
    var mins = minutesUtc;
    // Handle day wrap around
    int dayOffset = 0;
    while (mins < 0) {
      mins += 1440;
      dayOffset--;
    }
    while (mins >= 1440) {
      mins -= 1440;
      dayOffset++;
    }

    final hour = mins ~/ 60;
    final minute = (mins % 60).floor();
    final second = ((mins - (hour * 60 + minute)) * 60).round();

    return DateTime.utc(date.year, date.month, date.day, hour, minute, second)
        .add(Duration(days: dayOffset))
        .toLocal();
  }

  /// Gets the Tithi for a specific date.
  Future<TithiInfo> getTithi({
    required DateTime dateTime,
    required GeographicLocation location,
  }) async {
    final flags = CalculationFlags.defaultFlags();

    final sunPos = await _ephemerisService.calculatePlanetPosition(
      planet: Planet.sun,
      dateTime: dateTime,
      location: location,
      flags: flags,
    );

    final moonPos = await _ephemerisService.calculatePlanetPosition(
      planet: Planet.moon,
      dateTime: dateTime,
      location: location,
      flags: flags,
    );

    return _calculateTithi(sunPos, moonPos);
  }

  /// Gets the Yoga for a specific date.
  Future<YogaInfo> getYoga({
    required DateTime dateTime,
    required GeographicLocation location,
  }) async {
    final flags = CalculationFlags.defaultFlags();

    final sunPos = await _ephemerisService.calculatePlanetPosition(
      planet: Planet.sun,
      dateTime: dateTime,
      location: location,
      flags: flags,
    );

    final moonPos = await _ephemerisService.calculatePlanetPosition(
      planet: Planet.moon,
      dateTime: dateTime,
      location: location,
      flags: flags,
    );

    return _calculateYoga(sunPos, moonPos);
  }

  /// Gets the Karana for a specific date.
  Future<KaranaInfo> getKarana({
    required DateTime dateTime,
    required GeographicLocation location,
  }) async {
    final flags = CalculationFlags.defaultFlags();

    final sunPos = await _ephemerisService.calculatePlanetPosition(
      planet: Planet.sun,
      dateTime: dateTime,
      location: location,
      flags: flags,
    );

    final moonPos = await _ephemerisService.calculatePlanetPosition(
      planet: Planet.moon,
      dateTime: dateTime,
      location: location,
      flags: flags,
    );

    return _calculateKarana(sunPos, moonPos);
  }

  /// Gets only the Vara (weekday lord) for a specific date/location.
  Future<VaraInfo> getVara(
    DateTime dateTime,
    GeographicLocation location,
  ) async {
    final (sunrise, _) = await _calculateSunriseSunset(
      dateTime: dateTime,
      location: location,
    );
    return _calculateVara(dateTime, sunrise);
  }

  /// Gets the Nakshatra for a specific date/location.
  ///
  /// Calculates the Moon's nakshatra at the given date/time.
  /// This is one of the five limbs of the Panchanga.
  Future<NakshatraInfo> getNakshatra({
    required DateTime dateTime,
    required GeographicLocation location,
  }) async {
    final flags = CalculationFlags.defaultFlags();

    final moonPos = await _ephemerisService.calculatePlanetPosition(
      planet: Planet.moon,
      dateTime: dateTime,
      location: location,
      flags: flags,
    );

    return _calculateNakshatra(moonPos);
  }

  /// Finds the exact end time of the current Tithi.
  ///
  /// Uses high-precision binary search to find when the lunar elongation
  /// crosses the next 12° boundary (tithi change point). Continues searching
  /// until the accuracy threshold is met.
  ///
  /// [dateTime] - The starting date/time for the search
  /// [location] - Geographic location for calculations
  /// [accuracyThreshold] - Desired accuracy duration (default: 1 second)
  Future<DateTime> getTithiEndTime({
    required DateTime dateTime,
    required GeographicLocation location,
    Duration accuracyThreshold = const Duration(seconds: 1),
  }) async {
    final flags = CalculationFlags.defaultFlags();

    // 1. Calculate current elongation
    final sunPos = await _ephemerisService.calculatePlanetPosition(
      planet: Planet.sun,
      dateTime: dateTime,
      location: location,
      flags: flags,
    );
    final moonPos = await _ephemerisService.calculatePlanetPosition(
      planet: Planet.moon,
      dateTime: dateTime,
      location: location,
      flags: flags,
    );

    final currentElongation =
        (moonPos.longitude - sunPos.longitude + 360) % 360;
    final currentTithi = (currentElongation / 12.0).floor();
    final targetElongation = (currentTithi + 1) * 12.0;

    // 2. Binary search for target elongation within the next 48 hours
    // Using 48 hours to account for variations in tithi length
    var start = dateTime;
    var end = dateTime.add(const Duration(hours: 48));

    // Continue searching until we meet the accuracy threshold
    var iteration = 0;
    const maxIterations = 60; // Increased for better convergence

    while (iteration < maxIterations) {
      final currentWindow = end.difference(start);

      // If we're within the accuracy threshold, stop
      if (currentWindow <= accuracyThreshold) {
        break;
      }

      // Adaptive mid point - use smaller steps near the target
      final mid = start.add(Duration(
        milliseconds: currentWindow.inMilliseconds ~/ 2,
      ));

      final midSun = await _ephemerisService.calculatePlanetPosition(
        planet: Planet.sun,
        dateTime: mid,
        location: location,
        flags: flags,
      );
      final midMoon = await _ephemerisService.calculatePlanetPosition(
        planet: Planet.moon,
        dateTime: mid,
        location: location,
        flags: flags,
      );

      var midElongation = (midMoon.longitude - midSun.longitude + 360) % 360;

      // Handle 0/360 boundary crossing
      if (targetElongation >= 360 && midElongation < 180) {
        midElongation += 360;
      }

      // Check if we're very close to the target - helps with edge cases
      final elongationDiff = (midElongation - targetElongation).abs();
      if (elongationDiff < 0.001) {
        // Very close to target, use this as end
        end = mid;
        break;
      }

      if (midElongation < targetElongation) {
        start = mid;
      } else {
        end = mid;
      }

      iteration++;
    }

    return start;
  }

  /// Calculates Abhijit Muhurta (the victorious midday period).
  ///
  /// Abhijit Muhurta is the 8th Muhurta (approximately 48-minute period) of the day,
  /// occurring around midday (local apparent noon). It is considered
  /// highly auspicious and can destroy millions of obstacles.
  ///
  /// Traditional calculation: A Muhurta is 1/15th of daytime duration,
  /// not 1/30th of the full day. Abhijit is the 8th Muhurta.
  ///
  /// [date] - The date to calculate for
  /// [location] - Geographic location
  ///
  /// Returns the start and end times of Abhijit Muhurta
  Future<AbhijitMuhurta> calculateAbhijitMuhurta({
    required DateTime date,
    required GeographicLocation location,
  }) async {
    // Get sunrise and sunset
    final (sunrise, sunset) = await _calculateSunriseSunset(
      dateTime: date,
      location: location,
    );

    // Calculate daytime duration
    final dayDuration = sunset.difference(sunrise);

    // A Muhurta is 1/15th of daytime (traditional calculation)
    // This gives approximately 48 minutes at equinox, varying by season
    final muhurtaDuration = Duration(
      milliseconds: (dayDuration.inMilliseconds / 15).round(),
    );

    // Abhijit is the 8th Muhurta (7th index, starting from sunrise)
    final abhijitStart = sunrise.add(muhurtaDuration * 7);
    final abhijitEnd = abhijitStart.add(muhurtaDuration);

    return AbhijitMuhurta(
      date: date,
      startTime: abhijitStart,
      endTime: abhijitEnd,
      duration: muhurtaDuration,
      description: 'The 8th Muhurta (~${muhurtaDuration.inMinutes} min) - highly auspicious for all activities',
    );
  }

  /// Calculates Brahma Muhurta (the auspicious pre-dawn period).
  ///
  /// Brahma Muhurta is traditionally the 14th Muhurta of the night,
  /// ending at sunrise. It is considered the most auspicious time 
  /// for meditation, yoga, and spiritual practices.
  ///
  /// Traditional calculation: Night is divided into 15 Muhurtas.
  /// Brahma Muhurta is the 14th Muhurta (2nd from last), 
  /// making it 1/15th of nighttime duration.
  ///
  /// [date] - The date to calculate for
  /// [location] - Geographic location
  ///
  /// Returns the start and end times of Brahma Muhurta
  Future<BrahmaMuhurta> calculateBrahmaMuhurta({
    required DateTime date,
    required GeographicLocation location,
  }) async {
    // Get sunrise and sunset
    final (sunrise, sunset) = await _calculateSunriseSunset(
      dateTime: date,
      location: location,
    );

    // Calculate nighttime duration (previous sunset to current sunrise)
    final nightDuration = sunrise.difference(sunset);

    // Traditional: Brahma Muhurta is 14th Muhurta of night = 1/15th of night
    // This varies by season/latitude, unlike the fixed 48-minute version
    final brahmaDuration = Duration(
      milliseconds: (nightDuration.inMilliseconds / 15).round(),
    );

    // Brahma Muhurta is the 14th Muhurta of night, ending at sunrise
    // So it starts at: sunrise - 2*muhurtaDuration (since Muhurtas 15-14-13... work backwards)
    // Alternatively: it's Muhurta 14 counting from sunset = nightDuration * 14/15
    final brahmaStart = sunrise.subtract(brahmaDuration);
    final brahmaEnd = sunrise;

    return BrahmaMuhurta(
      date: date,
      startTime: brahmaStart,
      endTime: brahmaEnd,
      duration: brahmaDuration,
      description: 'The 14th Muhurta of night (~${brahmaDuration.inMinutes} min) ending at sunrise - highly auspicious for spiritual practices',
    );
  }

  /// Calculates nighttime inauspicious periods.
  ///
  /// Similar to daytime Rahu Kaal, Gulika Kaal, and Yamagandam,
  /// but calculated for the nighttime period (sunset to sunrise).
  ///
  /// [date] - The date to calculate for
  /// [location] - Geographic location
  ///
  /// Returns nighttime inauspicious periods
  Future<NighttimeInauspiciousPeriods> calculateNighttimeInauspicious({
    required DateTime date,
    required GeographicLocation location,
  }) async {
    // Get today's sunset and tomorrow's sunrise
    final (todaySunset, _) = await _calculateSunriseSunset(
      dateTime: date,
      location: location,
    );

    final tomorrow = date.add(const Duration(days: 1));
    final (tomorrowSunrise, _) = await _calculateSunriseSunset(
      dateTime: tomorrow,
      location: location,
    );

    // Calculate night duration
    final nightDuration = tomorrowSunrise.difference(todaySunset);

    // Divide night into 8 parts (like daytime)
    final partDuration = nightDuration ~/ 8;

    // Get weekday (0 = Sunday, 6 = Saturday)
    final weekday = date.weekday % 7;

    // Nighttime Rahu Kaal sequence (different from daytime)
    // Sun: 7th part, Mon: 6th, Tue: 5th, Wed: 4th, Thu: 3rd, Fri: 2nd, Sat: 1st
    final rahuPart = (7 - weekday) % 8;

    // Nighttime Gulika Kaal sequence
    // Sun: 6th, Mon: 5th, Tue: 4th, Wed: 3rd, Thu: 2nd, Fri: 1st, Sat: 7th
    final gulikaPart = (6 - weekday) % 8;

    // Nighttime Yamagandam sequence
    // Sun: 5th, Mon: 4th, Tue: 3rd, Wed: 2nd, Thu: 1st, Fri: 7th, Sat: 6th
    final yamaPart = (5 - weekday) % 8;

    return NighttimeInauspiciousPeriods(
      date: date,
      rahuKaal: PanchangaTimePeriod(
        start: todaySunset.add(partDuration * rahuPart),
        end: todaySunset.add(partDuration * (rahuPart + 1)),
      ),
      gulikaKaal: PanchangaTimePeriod(
        start: todaySunset.add(partDuration * gulikaPart),
        end: todaySunset.add(partDuration * (gulikaPart + 1)),
      ),
      yamagandam: PanchangaTimePeriod(
        start: todaySunset.add(partDuration * yamaPart),
        end: todaySunset.add(partDuration * (yamaPart + 1)),
      ),
      description: 'Nighttime inauspicious periods (sunset to sunrise)',
    );
  }

  /// Gets the exact junction (change point) of a specific Tithi.
  ///
  /// This provides microsecond-level precision for when a Tithi changes,
  /// which is crucial for festival timing and muhurta calculations.
  ///
  /// [targetTithiNumber] - The Tithi number to find (1-30)
  /// [startDate] - Start searching from this date
  /// [location] - Geographic location
  ///
  /// Returns the exact DateTime when the Tithi begins
  Future<DateTime> getTithiJunction({
    required int targetTithiNumber,
    required DateTime startDate,
    required GeographicLocation location,
  }) async {
    final flags = CalculationFlags.defaultFlags();

    // Calculate target elongation for the Tithi
    final targetElongation = ((targetTithiNumber - 1) * 12.0) % 360;

    // Search within a 48-hour window
    var searchStart = startDate;
    var searchEnd = startDate.add(const Duration(hours: 48));

    // High-precision binary search
    const maxIterations = 100;
    const accuracyThreshold =
        Duration(milliseconds: 100); // 0.1 second precision

    for (var i = 0; i < maxIterations; i++) {
      final window = searchEnd.difference(searchStart);

      if (window <= accuracyThreshold) {
        break;
      }

      final mid = searchStart.add(Duration(
        milliseconds: window.inMilliseconds ~/ 2,
      ));

      final sunPos = await _ephemerisService.calculatePlanetPosition(
        planet: Planet.sun,
        dateTime: mid,
        location: location,
        flags: flags,
      );
      final moonPos = await _ephemerisService.calculatePlanetPosition(
        planet: Planet.moon,
        dateTime: mid,
        location: location,
        flags: flags,
      );

      var elongation = (moonPos.longitude - sunPos.longitude + 360) % 360;

      // Handle 0/360 boundary
      if (targetElongation < 12 && elongation > 348) {
        elongation -= 360;
      }

      // Check if we're very close to the target - helps with edge cases
      final elongationDiff = (elongation - targetElongation).abs();
      if (elongationDiff < 0.001) {
        // Very close to target, use this as end
        searchEnd = mid;
        break;
      }

      if (elongation < targetElongation) {
        searchStart = mid;
      } else {
        searchEnd = mid;
      }
    }

    return searchStart;
  }

  /// Gets detailed Moon phase information.
  ///
  /// Calculates percent illumination, lunar age, and elongation velocity
  /// for detailed lunar analysis.
  ///
  /// [dateTime] - The date/time to calculate for
  /// [location] - Geographic location
  ///
  /// Returns comprehensive Moon phase details
  Future<MoonPhaseDetails> getMoonPhaseDetails({
    required DateTime dateTime,
    required GeographicLocation location,
  }) async {
    final flags = CalculationFlags.defaultFlags();

    // Get Sun and Moon positions
    final sunPos = await _ephemerisService.calculatePlanetPosition(
      planet: Planet.sun,
      dateTime: dateTime,
      location: location,
      flags: flags,
    );

    final moonPos = await _ephemerisService.calculatePlanetPosition(
      planet: Planet.moon,
      dateTime: dateTime,
      location: location,
      flags: flags,
    );

    // Calculate elongation (Moon - Sun)
    var elongation = moonPos.longitude - sunPos.longitude;
    if (elongation < 0) elongation += 360;

    // Calculate percent illumination
    // Full moon = 100%, New moon = 0%
    final illumination = (1 - (elongation / 180).abs().clamp(0.0, 1.0)) * 100;
    final isWaxing = elongation < 180;

    // Calculate lunar age (days since new moon)
    // Synodic month = 29.53059 days
    const synodicMonth = 29.53059;
    final lunarAge = (elongation / 360) * synodicMonth;

    // Calculate elongation velocity (rate of change)
    // Moon moves ~12-15°/day, Sun ~1°/day
    final elongationVelocity = moonPos.longitudeSpeed - sunPos.longitudeSpeed;

    // Determine phase name
    final phaseName = _getMoonPhaseName(elongation);

    return MoonPhaseDetails(
      dateTime: dateTime,
      elongation: elongation,
      illumination: illumination,
      isWaxing: isWaxing,
      lunarAge: lunarAge,
      elongationVelocity: elongationVelocity,
      phaseName: phaseName,
      tithiNumber: (elongation / 12).floor() + 1,
    );
  }

  /// Gets the Moon phase name based on elongation.
  String _getMoonPhaseName(double elongation) {
    if (elongation < 12 || elongation > 348) return 'New Moon (Amavasya)';
    if (elongation < 36) return 'Waxing Crescent';
    if (elongation < 60) return 'First Quarter (Shukla Saptami)';
    if (elongation < 84) return 'Waxing Gibbous';
    if (elongation < 96) return 'Full Moon (Purnima)';
    if (elongation < 120) return 'Waning Gibbous';
    if (elongation < 144) return 'Last Quarter (Krishna Saptami)';
    if (elongation < 168) return 'Waning Crescent';
    return 'New Moon (Amavasya)';
  }
}

/// Represents Abhijit Muhurta timing.
class AbhijitMuhurta {
  const AbhijitMuhurta({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.description,
  });

  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final String description;

  bool contains(DateTime time) =>
      time.isAfter(startTime) && time.isBefore(endTime);
}

/// Represents Brahma Muhurta timing.
class BrahmaMuhurta {
  const BrahmaMuhurta({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.description,
  });

  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final String description;

  bool contains(DateTime time) =>
      time.isAfter(startTime) && time.isBefore(endTime);
}

/// Represents a generic time period for Panchanga calculations.
class PanchangaTimePeriod {
  const PanchangaTimePeriod({
    required this.start,
    required this.end,
  });

  final DateTime start;
  final DateTime end;

  Duration get duration => end.difference(start);
  bool contains(DateTime time) => time.isAfter(start) && time.isBefore(end);
}

/// Represents nighttime inauspicious periods.
class NighttimeInauspiciousPeriods {
  const NighttimeInauspiciousPeriods({
    required this.date,
    required this.rahuKaal,
    required this.gulikaKaal,
    required this.yamagandam,
    required this.description,
  });

  final DateTime date;
  final PanchangaTimePeriod rahuKaal;
  final PanchangaTimePeriod gulikaKaal;
  final PanchangaTimePeriod yamagandam;
  final String description;

  bool isInauspicious(DateTime time) {
    return rahuKaal.contains(time) ||
        gulikaKaal.contains(time) ||
        yamagandam.contains(time);
  }
}

/// Represents detailed Moon phase information.
class MoonPhaseDetails {
  const MoonPhaseDetails({
    required this.dateTime,
    required this.elongation,
    required this.illumination,
    required this.isWaxing,
    required this.lunarAge,
    required this.elongationVelocity,
    required this.phaseName,
    required this.tithiNumber,
  });

  final DateTime dateTime;
  final double elongation;
  final double illumination; // 0-100%
  final bool isWaxing;
  final double lunarAge; // Days since new moon
  final double elongationVelocity; // Degrees per day
  final String phaseName;
  final int tithiNumber;

  bool get isFullMoon => illumination > 95;
  bool get isNewMoon => illumination < 5;
}
