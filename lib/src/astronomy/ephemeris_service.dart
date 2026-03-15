import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';

import '../bindings/swisseph_bindings.dart';
import '../constants/planet_constants.dart';
import '../exceptions/jyotish_exception.dart';
import 'package:jyotish/src/models/calculation_flags.dart';
import 'package:jyotish/src/models/geographic_location.dart';
import 'package:jyotish/src/models/planet.dart';
import 'package:jyotish/src/astronomy/planet_position.dart';
import 'package:jyotish/src/astronomy/astrology_time_service.dart';

/// Service for calculating planetary positions using Swiss Ephemeris.
///
/// This service provides high-level methods for astronomical calculations
/// using the Swiss Ephemeris library.
class EphemerisService {
  SwissEphBindings? _bindings;
  bool _isInitialized = false;

  /// Initializes the Swiss Ephemeris service.
  ///
  /// [ephemerisPath] - Optional path to Swiss Ephemeris data files.
  /// If not provided, the library will use its default search paths.
  ///
  /// Throws [InitializationException] if initialization fails.
  Future<void> initialize({String? ephemerisPath}) async {
    if (_isInitialized) {
      return;
    }

    try {
      _bindings = SwissEphBindings();

      // Set ephemeris path if provided
      if (ephemerisPath != null) {
        _bindings!.setEphemerisPath(ephemerisPath);
      }

      // Test that the library is working
      _bindings!.getVersion();

      _isInitialized = true;
    } catch (e, stackTrace) {
      throw InitializationException(
        'Failed to initialize Swiss Ephemeris: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Calculates the position of a planet.
  ///
  /// [planet] - The planet to calculate.
  /// [dateTime] - The date and time for calculation.
  /// [location] - The geographic location for calculation.
  /// [flags] - Calculation flags.
  ///
  /// Returns a [PlanetPosition] with the calculated data.
  ///
  /// Throws [CalculationException] if calculation fails.
  Future<PlanetPosition> calculatePlanetPosition({
    required Planet planet,
    required DateTime dateTime,
    required GeographicLocation location,
    required CalculationFlags flags,
  }) async {
    if (!_isInitialized || _bindings == null) {
      throw CalculationException('EphemerisService is not initialized');
    }

    try {
      // Set topocentric position if required
      if (flags.useTopocentric) {
        _bindings!.setTopocentric(
          location.longitude,
          location.latitude,
          location.altitude,
        );
      }

      // Convert DateTime to Julian Day
      final julianDay = _dateTimeToJulianDay(dateTime);

      // Set sidereal mode and get ayanamsa for this date
      // We always use sidereal calculations for Vedic astrology
      _bindings!.setSiderealMode(
        flags.siderealModeConstant,
        0.0,
        0.0,
      );
      final ayanamsa = _bindings!.getAyanamsaUT(julianDay);

      // Calculate position (tropical, then we subtract ayanamsa)
      final errorBuffer = malloc<ffi.Char>(256);
      try {
        final results = _bindings!.calculateUT(
          julianDay: julianDay,
          planetId: planet.swissEphId,
          flags: flags.toSwissEphFlag(),
          errorBuffer: errorBuffer,
        );

        if (results == null) {
          final error = errorBuffer.cast<Utf8>().toDartString();
          throw JyotishException(
            'Failed to calculate position for ${planet.displayName}: $error',
          );
        }

        // Fetch Declination (Equatorial Latitude)
        // We need an additional call with SEFLG_EQUATORIAL flag
        // SEFLG_EQUATORIAL = 2048 (0x800)
        final eqResults = _bindings!.calculateUT(
          julianDay: julianDay,
          planetId: planet.swissEphId,
          flags: flags.toSwissEphFlag() | 0x800,
          errorBuffer: errorBuffer,
        );

        if (eqResults != null) {
          results.add(eqResults[1]); // results[6] is now declination
        } else {
          results.add(0.0);
        }

        // Convert tropical to sidereal by subtracting ayanamsa
        results[0] = (results[0] - ayanamsa + 360) % 360;

        // Determine retrograde status BEFORE adjusting speed
        // The precession adjustment is very small (~0.000137/day) but could
        // theoretically affect edge cases near zero velocity
        final isRetrograde = results[3] < 0;

        // Adjust longitudeSpeed for sidereal frame:
        // In the sidereal frame, speeds are slightly lower due to precession.
        // The precession rate is ~50.3"/year = ~0.000137/day.
        // This adjustment is negligible for most practical purposes (~0.01%),
        // but included for professional-grade precision in Chesta Bala.
        // Note: Retrograde status is determined from the original speed above.
        const double precessionRatePerDay = 50.3 / 3600.0 / 365.25; // deg/day
        results[3] = results[3] - precessionRatePerDay;

        return PlanetPosition.fromSwissEph(
          planet: planet,
          dateTime: dateTime,
          results: results,
          isRetrograde: isRetrograde,
        );
      } finally {
        malloc.free(errorBuffer);
      }
    } catch (e, stackTrace) {
      if (e is CalculationException) rethrow;
      throw CalculationException(
        'Error calculating planet position: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Converts a DateTime to Julian Day number.
  double _dateTimeToJulianDay(DateTime dateTime, {String? timezoneId}) {
    // Convert to UTC
    final utc = timezoneId != null
        ? AstrologyTimeService.localToUtc(dateTime, timezoneId)
        : dateTime.toUtc();

    // Calculate hour as decimal
    final hour = utc.hour +
        (utc.minute / 60.0) +
        (utc.second / 3600.0) +
        (utc.millisecond / 3600000.0);

    return _bindings!.julianDay(
      year: utc.year,
      month: utc.month,
      day: utc.day,
      hour: hour,
      isGregorian: true,
    );
  }

  /// Gets the ayanamsa (sidereal offset) for a given date and time.
  ///
  /// [dateTime] - The date and time to calculate for.
  /// [mode] - The sidereal mode to use.
  ///
  /// Returns the ayanamsa in degrees.
  Future<double> getAyanamsa({
    required DateTime dateTime,
    required SiderealMode mode,
    String? timezoneId,
  }) async {
    if (!_isInitialized || _bindings == null) {
      throw CalculationException('EphemerisService is not initialized');
    }

    try {
      // Set sidereal mode
      _bindings!.setSiderealMode(mode.constant, 0.0, 0.0);

      // Convert DateTime to Julian Day
      final julianDay = _dateTimeToJulianDay(dateTime, timezoneId: timezoneId);

      // Get ayanamsa
      return _bindings!.getAyanamsaUT(julianDay);
    } catch (e, stackTrace) {
      throw CalculationException(
        'Error calculating ayanamsa: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Calculates house cusps and ascendant/midheaven.
  ///
  /// [dateTime] - The date and time for calculation.
  /// [location] - The geographic location for calculation.
  /// [houseSystem] - The house system to use ('P' = Placidus, 'K' = Koch, 'W' = Whole Sign, etc.)
  ///
  /// Note: For latitudes above 65, some house systems (Placidus, Koch) may produce
  /// unreliable results. Whole Sign ('W') is recommended for high-latitude locations.
  ///
  /// Returns a map with 'cusps' and 'ascmc' arrays.
  ///
  /// Throws [CalculationException] if calculation fails.
  Future<Map<String, List<double>>> calculateHouses({
    required DateTime dateTime,
    required GeographicLocation location,
    String houseSystem = 'P',
  }) async {
    if (!_isInitialized || _bindings == null) {
      throw CalculationException('EphemerisService is not initialized');
    }

    final absLat = location.latitude.abs();
    if (houseSystem == 'P' || houseSystem == 'K') {
      const arcticCircle = 66.5;
      if (absLat >= arcticCircle) {
        throw PolarRegionException(
          'House system "$houseSystem" is mathematically unstable/undefined above ${arcticCircle} latitude ($absLat requested). '
          'Switch to Whole Sign ("W"), Campanus ("C"), or Equal ("E").',
          latitude: location.latitude,
          houseSystem: houseSystem,
        );
      }
    }

    try {
      // Convert DateTime to Julian Day
      final julianDay =
          _dateTimeToJulianDay(dateTime, timezoneId: location.timezone);

      // Calculate houses
      final result = _bindings!.calculateHouses(
        julianDay: julianDay,
        latitude: location.latitude,
        longitude: location.longitude,
        houseSystem: houseSystem,
      );

      if (result == null) {
        throw CalculationException('Failed to calculate houses');
      }

      return result;
    } catch (e, stackTrace) {
      throw CalculationException(
        'Error calculating houses: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Calculates high-precision rise or set time for a planet.
  ///
  /// Uses Swiss Ephemeris' swe_rise_trans function for professional-grade accuracy.
  ///
  /// [planet] - The planet to calculate rise/set for (use Planet.sun for sunrise/sunset)
  /// [date] - The date to search for the event
  /// [location] - Geographic location
  /// [rsmi] - Rise/Set calculation flag:
  ///   - SwissEphConstants.calcRise (1) for rise time
  ///   - SwissEphConstants.calcSet (2) for set time
  ///   - Can combine with bit flags like SwissEphConstants.bitHinduRising
  /// [atpress] - Atmospheric pressure in mbar (default: 0 = standard)
  /// [attemp] - Atmospheric temperature in Celsius (default: 0 = standard)
  ///
  /// Returns the DateTime of the event, or null if the event doesn't occur
  /// (e.g., polar regions where the sun doesn't rise/set for extended periods).
  ///
  /// Throws [CalculationException] if calculation fails.
  Future<DateTime?> getRiseSet({
    required Planet planet,
    required DateTime date,
    required GeographicLocation location,
    required int rsmi,
    double atpress = 0.0,
    double attemp = 0.0,
    bool searchFromExactTime = false,
  }) async {
    if (!_isInitialized || _bindings == null) {
      throw CalculationException('EphemerisService is not initialized');
    }

    // Check for extreme latitudes that may cause issues
    final absLatitude = location.latitude.abs();
    if (absLatitude > 66.5) {
      // Beyond Arctic/Antarctic Circle - sun may not rise/set for extended periods
      // Return null with a log message (could add logging here if needed)
    }

    try {
      // By default search from beginning of the day in UTC.
      // When searchFromExactTime is true, use the exact DateTime provided so
      // that callers can locate the NEXT rise/set after a known event.
      final DateTime searchStart;
      if (searchFromExactTime) {
        searchStart = date.isUtc ? date : date.toUtc();
      } else {
        searchStart = DateTime.utc(date.year, date.month, date.day);
      }
      final julianDay =
          _dateTimeToJulianDay(searchStart, timezoneId: location.timezone);

      final errorBuffer = malloc<ffi.Char>(256);
      try {
        final result = _bindings!.calculateRiseSet(
          julianDay: julianDay,
          planetId: planet.swissEphId,
          rsmi: rsmi,
          latitude: location.latitude,
          longitude: location.longitude,
          errorBuffer: errorBuffer,
          atpress: atpress,
          attemp: attemp,
        );

        if (result == null) {
          final error = errorBuffer.cast<Utf8>().toDartString();
          if (error.isNotEmpty) {
            // Some errors are expected (e.g., polar regions where sun doesn't rise/set)
            // Return null in such cases
            return null;
          }
          return null;
        }

        // Convert Julian Day back to DateTime
        return _julianDayToDateTime(result);
      } finally {
        malloc.free(errorBuffer);
      }
    } catch (e, stackTrace) {
      throw CalculationException(
        'Error calculating rise/set: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets high-precision sunrise and sunset times for a date.
  ///
  /// [date] - The date to calculate for
  /// [location] - Geographic location
  /// [atpress] - Atmospheric pressure in mbar (optional)
  /// [attemp] - Atmospheric temperature in Celsius (optional)
  ///
  /// Returns a tuple (sunrise, sunset), or null for times that don't occur.
  Future<(DateTime? sunrise, DateTime? sunset)> getSunriseSunset({
    required DateTime date,
    required GeographicLocation location,
    double atpress = 0.0,
    double attemp = 0.0,
  }) async {
    final sunrise = await getRiseSet(
      planet: Planet.sun,
      date: date,
      location: location,
      rsmi: SwissEphConstants.calcRise,
      atpress: atpress,
      attemp: attemp,
    );

    final sunset = await getRiseSet(
      planet: Planet.sun,
      date: date,
      location: location,
      rsmi: SwissEphConstants.calcSet,
      atpress: atpress,
      attemp: attemp,
    );

    return (sunrise, sunset);
  }

  /// Gets rise and set times for any planet.
  ///
  /// [planet] - The planet to calculate for
  /// [date] - The date to calculate for
  /// [location] - Geographic location
  /// [atpress] - Atmospheric pressure in mbar (optional)
  /// [attemp] - Atmospheric temperature in Celsius (optional)
  ///
  /// Returns a tuple (riseTime, setTime), or null for times that don't occur.
  Future<(DateTime? riseTime, DateTime? setTime)> getPlanetRiseSet({
    required Planet planet,
    required DateTime date,
    required GeographicLocation location,
    double atpress = 0.0,
    double attemp = 0.0,
  }) async {
    final riseTime = await getRiseSet(
      planet: planet,
      date: date,
      location: location,
      rsmi: SwissEphConstants.calcRise,
      atpress: atpress,
      attemp: attemp,
    );

    final setTime = await getRiseSet(
      planet: planet,
      date: date,
      location: location,
      rsmi: SwissEphConstants.calcSet,
      atpress: atpress,
      attemp: attemp,
    );

    return (riseTime, setTime);
  }

  /// Calculates meridian transit (culmination) times for a planet.
  ///
  /// Meridian transit occurs when a planet reaches its highest (upper culmination)
  /// or lowest (lower culmination) point in the sky.
  ///
  /// [planet] - The planet to calculate for
  /// [date] - The date to calculate for
  /// [location] - Geographic location
  /// [upperCulmination] - If true, calculates upper culmination; if false, lower culmination
  ///
  /// Returns the DateTime of the transit, or null if it doesn't occur.
  Future<DateTime?> getMeridianTransit({
    required Planet planet,
    required DateTime date,
    required GeographicLocation location,
    bool upperCulmination = true,
  }) async {
    // SE_CALC_MTRANSIT = 4 for upper culmination
    // SE_CALC_ITRANSIT = 8 for lower culmination
    final rsmi = upperCulmination
        ? SwissEphConstants.calcMTransit
        : SwissEphConstants.calcITransit;

    return await getRiseSet(
      planet: planet,
      date: date,
      location: location,
      rsmi: rsmi,
    );
  }

  /// Determines planet visibility (heliacal rise/set) at a location.
  ///
  /// Heliacal rise: First visible appearance of a planet before sunrise
  /// Heliacal set: Last visible appearance of a planet after sunset
  ///
  /// [planet] - The planet to check
  /// [date] - The date to check
  /// [location] - Geographic location
  ///
  /// Returns visibility information including whether visible, magnitude, etc.
  Future<PlanetVisibility> getPlanetVisibility({
    required Planet planet,
    required DateTime date,
    required GeographicLocation location,
  }) async {
    final flags = CalculationFlags.defaultFlags();

    // Get planet position
    final planetPos = await calculatePlanetPosition(
      planet: planet,
      dateTime: date,
      location: location,
      flags: flags,
    );

    // Get Sun position
    final sunPos = await calculatePlanetPosition(
      planet: Planet.sun,
      dateTime: date,
      location: location,
      flags: flags,
    );

    // Get sunrise/sunset
    final (sunrise, sunset) = await getSunriseSunset(
      date: date,
      location: location,
    );

    // Calculate elongation from Sun
    var elongation = (planetPos.longitude - sunPos.longitude).abs();
    if (elongation > 180) elongation = 360 - elongation;

    // Determine visibility
    bool isVisible = false;
    VisibilityType visibilityType = VisibilityType.notVisible;
    String description = '';

    if (sunrise != null && sunset != null) {
      final isBeforeSunrise = date.isBefore(sunrise);
      final isAfterSunset = date.isAfter(sunset);

      // Heliacal rise: planet visible before sunrise (eastern elongation)
      if (isBeforeSunrise && elongation > 15) {
        isVisible = true;
        visibilityType = VisibilityType.heliacalRise;
        description =
            '${planet.displayName} visible before sunrise (heliacal rise)';
      }
      // Heliacal set: planet visible after sunset (western elongation)
      else if (isAfterSunset && elongation > 15) {
        isVisible = true;
        visibilityType = VisibilityType.heliacalSet;
        description =
            '${planet.displayName} visible after sunset (heliacal set)';
      }
      // Daytime visibility (rare for most planets except Venus)
      else if (!isBeforeSunrise && !isAfterSunset && elongation > 30) {
        isVisible = true;
        visibilityType = VisibilityType.daytime;
        description = '${planet.displayName} visible in daylight';
      } else {
        description = '${planet.displayName} not visible - too close to Sun';
      }
    }

    // Calculate apparent magnitude (simplified)
    final magnitude = _calculateApparentMagnitude(planet, elongation);

    return PlanetVisibility(
      planet: planet,
      date: date,
      isVisible: isVisible,
      visibilityType: visibilityType,
      elongation: elongation,
      magnitude: magnitude,
      sunrise: sunrise,
      sunset: sunset,
      description: description,
    );
  }

  /// Calculates apparent magnitude for a planet (simplified).
  double _calculateApparentMagnitude(Planet planet, double elongation) {
    // Simplified magnitude calculation
    // Real calculation requires distance from Earth and Sun
    const baseMagnitudes = {
      Planet.mercury: -0.4,
      Planet.venus: -4.4,
      Planet.mars: -2.0,
      Planet.jupiter: -2.9,
      Planet.saturn: -0.3,
    };

    final baseMag = baseMagnitudes[planet];
    if (baseMag == null) return 99.0; // Not applicable

    // Brightness decreases when close to Sun (phase effect)
    final phaseFactor = (elongation / 180.0).clamp(0.0, 1.0);
    return baseMag + (2.5 * (1 - phaseFactor));
  }

  /// Gets high-precision eclipse data for solar and lunar eclipses.
  ///
  /// [date] - The date to search for eclipses
  /// [location] - Geographic location (for solar eclipse visibility)
  /// [eclipseType] - Type of eclipse to search for
  ///
  /// Returns detailed eclipse information or null if no eclipse.
  Future<EclipseData?> getEclipseData({
    required DateTime date,
    required GeographicLocation location,
    EclipseType eclipseType = EclipseType.any,
  }) async {
    if (!_isInitialized || _bindings == null) {
      throw CalculationException('EphemerisService is not initialized');
    }

    try {
      // Geometric Eclipse Detection
      // 1. Find exact moment of New Moon (Solar) or Full Moon (Lunar)
      // 2. Check Moon's latitude at that moment

      final syzygy = await _findSyzygy(date, location);

      if (syzygy == null) {
        return null; // No New/Full Moon on this date
      }

      final (time, type) = syzygy;

      // Filter by requested type if it's not EclipseType.any
      if (eclipseType != EclipseType.any) {
        final isRequestedSolar = eclipseType == EclipseType.solar ||
            eclipseType == EclipseType.solarTotal ||
            eclipseType == EclipseType.solarPartial ||
            eclipseType == EclipseType.solarAnnular;
        final isFoundSolar = type == EclipseType.solar;

        if (isRequestedSolar != isFoundSolar) {
          return null;
        }
      }

      // For Lunar Eclipses, use the superior Swiss Ephemeris built-in functions
      if (type == EclipseType.lunar ||
          type == EclipseType.lunarTotal ||
          type == EclipseType.lunarPartial ||
          type == EclipseType.lunarPenumbral) {
        return _getDetailedLunarEclipse(time, location);
      }

      // For Solar Eclipses, use the local Swiss Ephemeris built-in functions
      if (type == EclipseType.solar ||
          type == EclipseType.solarTotal ||
          type == EclipseType.solarPartial ||
          type == EclipseType.solarAnnular) {
        return _getDetailedSolarEclipse(time, location);
      }

      return null;
    } catch (e, stackTrace) {
      throw CalculationException(
        'Error calculating eclipse data: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Finds exact time of Syzygy (Conjunction/Opposition) on the given date.
  /// Returns (DateTime, EclipseType) or null.
  Future<(DateTime, EclipseType)?> _findSyzygy(
      DateTime date, GeographicLocation location) async {
    // Check start and end of day
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(Duration(days: 1));

    final posStartSun = await calculatePlanetPosition(
        planet: Planet.sun,
        dateTime: start,
        location: location,
        flags: CalculationFlags.defaultFlags());
    final posStartMoon = await calculatePlanetPosition(
        planet: Planet.moon,
        dateTime: start,
        location: location,
        flags: CalculationFlags.defaultFlags());

    final posEndSun = await calculatePlanetPosition(
        planet: Planet.sun,
        dateTime: end,
        location: location,
        flags: CalculationFlags.defaultFlags());
    final posEndMoon = await calculatePlanetPosition(
        planet: Planet.moon,
        dateTime: end,
        location: location,
        flags: CalculationFlags.defaultFlags());

    double diffStart =
        (posStartMoon.longitude - posStartSun.longitude + 360) % 360;
    double diffEnd = (posEndMoon.longitude - posEndSun.longitude + 360) % 360;

    // Check for New Moon (crossing 0/360)
    // If diff goes from ~350 to ~10, or 355 to 5.
    // Logic: If diffStart > 300 and diffEnd < 60
    if (diffStart > 330 && diffEnd < 30) {
      return (
        await _binarySearchSyzygy(start, end, location, 0),
        EclipseType.solar
      );
    }

    // Check for Full Moon (crossing 180)
    // If diff goes from < 180 to > 180
    if (diffStart <= 180 && diffEnd >= 180) {
      return (
        await _binarySearchSyzygy(start, end, location, 180),
        EclipseType.lunar
      );
    }

    return null;
  }

  Future<DateTime> _binarySearchSyzygy(DateTime start, DateTime end,
      GeographicLocation loc, double targetDiff) async {
    var low = start.millisecondsSinceEpoch;
    var high = end.millisecondsSinceEpoch;

    for (var i = 0; i < 10; i++) {
      // 10 iterations enough for ~1 min precision
      final mid = (low + high) ~/ 2;
      final time = DateTime.fromMillisecondsSinceEpoch(mid);

      final sun = await calculatePlanetPosition(
          planet: Planet.sun,
          dateTime: time,
          location: loc,
          flags: CalculationFlags.defaultFlags());
      final moon = await calculatePlanetPosition(
          planet: Planet.moon,
          dateTime: time,
          location: loc,
          flags: CalculationFlags.defaultFlags());

      double diff = (moon.longitude - sun.longitude + 360) % 360;

      if (targetDiff == 0) {
        // New Moon
        if (diff > 180) {
          // Still before 0 (e.g. 359)
          low = mid;
        } else {
          // Past 0 (e.g. 1)
          high = mid;
        }
      } else {
        // Full Moon (180)
        if (diff < 180) {
          low = mid;
        } else {
          high = mid;
        }
      }
    }

    return DateTime.fromMillisecondsSinceEpoch((low + high) ~/ 2);
  }

  /// Calculates detailed local solar eclipse data using Swiss Ephemeris.
  Future<EclipseData?> _getDetailedSolarEclipse(
      DateTime globalDate, GeographicLocation location) async {
    final jd = _dateTimeToJulianDay(globalDate);
    final errorBuffer = malloc<ffi.Char>(256);

    try {
      print('Calling findSolarEclipseWhenLoc...');
      // 1. Get precise local maximum and contact times using swe_sol_eclipse_when_loc.
      // We search from 1 day before the global syzygy date.
      final result = _bindings!.findSolarEclipseWhenLoc(
        julianDay: jd - 1.0,
        latitude: location.latitude,
        longitude: location.longitude,
        altitude: location.altitude,
        flags: 0,
        backward: false,
        errorBuffer: errorBuffer,
      );
      print('findSolarEclipseWhenLoc returned successfully.');

      if (result == null) return null;

      // Unpack the unified tret + attr array (30 elements)
      final tret = result.sublist(0, 10);
      final attr = result.sublist(10, 30);

      // tret[0] = time of maximum eclipse
      // tret[1] = first contact (partial start)
      // tret[2] = second contact (total/annular start)
      // tret[3] = third contact (total/annular end)
      // tret[4] = fourth contact (partial end)
      // tret[5] = sunrise/sunset
      final maxTime = _julianDayToDateTime(tret[0]);

      // Since findSolarEclipseWhenLoc searches forward, if this syzygy is not an eclipse,
      // it will return the NEXT eclipse (months/years later).
      // We must check if the returned eclipse is close to the syzygy date.
      if (maxTime.difference(globalDate).inDays.abs() > 2) {
        return null; // The found eclipse is for a future syzygy, not this one
      }

      final c1 = tret[1] > 0 ? _julianDayToDateTime(tret[1]) : null;
      final c2 = tret[2] > 0 ? _julianDayToDateTime(tret[2]) : null;
      final c3 = tret[3] > 0 ? _julianDayToDateTime(tret[3]) : null;
      final c4 = tret[4] > 0 ? _julianDayToDateTime(tret[4]) : null;

      // attr[0] = fraction of solar diameter covered by moon (magnitude)
      // attr[1] = ratio of lunar diameter to solar one
      // attr[2] = fraction of solar disc covered (obscuration)
      final localMagnitude = attr[0];

      if (localMagnitude <= 0) {
        return null; // Not visible at this specific observer location
      }

      EclipseType type = EclipseType.solarPartial;
      if (attr[1] >= 1.0 && c2 != null && c3 != null) {
        type = EclipseType.solarTotal;
      } else if (attr[1] < 1.0 && c2 != null && c3 != null) {
        type = EclipseType.solarAnnular;
      }

      return EclipseData(
        date: maxTime,
        eclipseType: type,
        magnitude: localMagnitude,
        isVisible: true,
        maxEclipseTime: maxTime,
        startTime: c1,
        endTime: c4,
        partialStartTime: c1,
        partialEndTime: c4,
        totalStartTime: c2,
        totalEndTime: c3,
        duration: c4 != null && c1 != null ? c4.difference(c1) : null,
        description:
            '${type.name} Eclipse (Local Mag: ${localMagnitude.toStringAsFixed(3)})',
      );
    } finally {
      malloc.free(errorBuffer);
    }
  }

  /// Converts DateTime to Julian Day.
  ///
  /// [dateTime] - The DateTime to convert
  /// [timezoneId] - Optional timezone ID
  ///
  /// Returns the Julian Day number.
  double getJulianDay(DateTime dateTime, {String? timezoneId}) {
    return _dateTimeToJulianDay(dateTime, timezoneId: timezoneId);
  }

  /// Converts Julian Day to DateTime (UTC).
  DateTime _julianDayToDateTime(double julianDay) {
    // Julian Day 0 = January 1, 4713 BC at noon
    // JD 2451545.0 = January 1, 2000 at noon

    // Calculate days since J2000.0
    final daysSinceJ2000 = julianDay - 2451545.0;

    // Convert to Unix epoch (seconds since 1970-01-01)
    // J2000.0 is 946728000 seconds after Unix epoch
    final secondsSinceEpoch = (daysSinceJ2000 * 86400.0) + 946728000;

    return DateTime.fromMillisecondsSinceEpoch(
      (secondsSinceEpoch * 1000).round(),
      isUtc: true,
    );
  }

  /// Disposes of resources.
  void dispose() {
    if (_isInitialized && _bindings != null) {
      _bindings!.close();
      _isInitialized = false;
    }
  }

  /// Gets whether the service is initialized.
  bool get isInitialized => _isInitialized;

  /// Calculates detailed lunar eclipse data using Swiss Ephemeris.
  Future<EclipseData?> _getDetailedLunarEclipse(
      DateTime date, GeographicLocation location) async {
    final jd = _dateTimeToJulianDay(date);
    final errorBuffer = malloc<ffi.Char>(256);

    try {
      // 1. Get detailed magnitude and attribute info at moment of maximum.
      final attr = _bindings!.calculateLunarEclipseHow(
        julianDay: jd,
        flags: 0,
        errorBuffer: errorBuffer,
      );

      if (attr == null) return null;

      // attr[0] = umbral magnitude
      // attr[1] = penumbral magnitude
      final umbralMag = attr[0];
      final penumbralMag = attr[1];

      if (penumbralMag <= 0) return null; // Not even penumbral

      // 2. Get all contact times.
      // Search from 1 day BEFORE the syzygy date so we capture all 7 times
      // including P4 which may fall a day after the date passed in.
      final tret = _bindings!.findLunarEclipseWhen(
        julianDay: jd - 1.0,
        flags: 0,
        eclipseTypeFlags: 14, // SE_ECL_ALLTYPES_LUNAR
        backward: false,
        errorBuffer: errorBuffer,
      );

      if (tret == null) return null;

      // Verified Swiss Ephemeris tret mapping for swe_lun_eclipse_when:
      // tret[0] = maximum eclipse
      // tret[2] = beginning of partial phase  Umbral first contact (U1)
      // tret[3] = end of partial phase  Umbral last contact (U4)
      // tret[4] = beginning of total phase (U2)
      // tret[5] = end of total phase (U3)
      // tret[6] = beginning of penumbral phase (P1)
      // tret[7] = end of penumbral phase (P4)
      // (tret[1], tret[8], tret[9] are unused / zero for lunar eclipses)
      final maxTime = _julianDayToDateTime(tret[0]);
      final u1 = tret[2] > 0 ? _julianDayToDateTime(tret[2]) : null;
      final u4 = tret[3] > 0 ? _julianDayToDateTime(tret[3]) : null;
      final u2 = tret[4] > 0 ? _julianDayToDateTime(tret[4]) : null;
      final u3 = tret[5] > 0 ? _julianDayToDateTime(tret[5]) : null;
      final p1 = tret[6] > 0 ? _julianDayToDateTime(tret[6]) : null;
      final p4 = tret[7] > 0 ? _julianDayToDateTime(tret[7]) : null;

      // 3. Get moonrise at the observer's location.
      // PenumbralStartTime (P1) is the earliest relevant time; start from
      // the day containing P1 so we get the correct evening moonrise.
      final searchDate = p1 ?? maxTime;
      final moonrise = await getRiseSet(
        planet: Planet.moon,
        date: searchDate,
        location: location,
        rsmi: SwissEphConstants.calcRise,
      );

      // 4. Get moonset AFTER moonrise (not the previous night's moonset).
      // Pass moonriseTime as the start if available, otherwise searchDate.
      DateTime? moonset;
      if (moonrise != null) {
        moonset = await getRiseSet(
          planet: Planet.moon,
          date: moonrise, // start searching from moonrise onward
          location: location,
          rsmi: SwissEphConstants.calcSet,
          searchFromExactTime: true, // use exact moonrise time, not midnight
        );
      }

      EclipseType type = EclipseType.lunarPenumbral;
      if (umbralMag >= 1.0) {
        type = EclipseType.lunarTotal;
      } else if (umbralMag > 0) {
        type = EclipseType.lunarPartial;
      }

      return EclipseData(
        date: maxTime,
        eclipseType: type,
        magnitude: umbralMag,
        penumbralMagnitude: penumbralMag,
        isVisible: true,
        description:
            '${type.name} Eclipse (Mag: ${umbralMag.toStringAsFixed(3)})',
        maxEclipseTime: maxTime,
        startTime: u1 ?? p1,
        endTime: u4 ?? p4,
        partialStartTime: u1,
        partialEndTime: u4,
        totalStartTime: u2,
        totalEndTime: u3,
        penumbralStartTime: p1,
        penumbralEndTime: p4,
        duration: u4 != null && u1 != null ? u4.difference(u1) : null,
        moonrise: moonrise,
        moonset: moonset,
      );
    } finally {
      malloc.free(errorBuffer);
    }
  }
}

/// Represents planet visibility information.
class PlanetVisibility {
  const PlanetVisibility({
    required this.planet,
    required this.date,
    required this.isVisible,
    required this.visibilityType,
    required this.elongation,
    required this.magnitude,
    required this.sunrise,
    required this.sunset,
    required this.description,
  });

  /// The planet
  final Planet planet;

  /// The date checked
  final DateTime date;

  /// Whether the planet is visible
  final bool isVisible;

  /// Type of visibility
  final VisibilityType visibilityType;

  /// Elongation from Sun (degrees)
  final double elongation;

  /// Apparent magnitude (lower is brighter)
  final double magnitude;

  /// Sunrise time
  final DateTime? sunrise;

  /// Sunset time
  final DateTime? sunset;

  /// Description of visibility
  final String description;

  /// Whether this is a heliacal event (rise or set)
  bool get isHeliacal =>
      visibilityType == VisibilityType.heliacalRise ||
      visibilityType == VisibilityType.heliacalSet;
}

/// Types of planet visibility
enum VisibilityType {
  notVisible('Not Visible'),
  heliacalRise('Heliacal Rise'),
  heliacalSet('Heliacal Set'),
  daytime('Daytime Visible'),
  evening('Evening Star'),
  morning('Morning Star');

  const VisibilityType(this.name);
  final String name;
}

/// Types of eclipses
enum EclipseType {
  any('Any'),
  solar('Solar'),
  lunar('Lunar'),
  solarTotal('Solar Total'),
  solarPartial('Solar Partial'),
  solarAnnular('Solar Annular'),
  lunarTotal('Lunar Total'),
  lunarPartial('Lunar Partial'),
  lunarPenumbral('Lunar Penumbral');

  const EclipseType(this.name);
  final String name;
}

/// Represents eclipse data
class EclipseData {
  const EclipseData({
    required this.date,
    required this.eclipseType,
    required this.magnitude,
    required this.isVisible,
    required this.description,
    this.duration,
    this.startTime,
    this.endTime,
    this.maxEclipseTime,
    this.penumbralMagnitude,
    this.partialStartTime,
    this.partialEndTime,
    this.totalStartTime,
    this.totalEndTime,
    this.penumbralStartTime,
    this.penumbralEndTime,
    this.moonrise,
    this.moonset,
  });

  /// Date (moment of maximum eclipse  UTC)
  final DateTime date;

  /// Type of eclipse
  final EclipseType eclipseType;

  /// Umbral magnitude (0 = penumbral only, 1.0 = total)
  final double magnitude;

  /// Penumbral magnitude (2.18 for this eclipse)
  final double? penumbralMagnitude;

  /// Whether globally visible (always true for lunar)
  final bool isVisible;

  /// Human-readable description
  final String description;

  // ------------------------------------------------------------------
  // Global contact times (UTC, independent of observer location)
  // ------------------------------------------------------------------

  /// Duration of the umbral/partial phase (U1U4)
  final Duration? duration;

  /// Umbral start (U1), or penumbral start (P1) when umbra absent
  final DateTime? startTime;

  /// Umbral end (U4), or penumbral end (P4) when umbra absent
  final DateTime? endTime;

  /// Moment of maximum eclipse
  final DateTime? maxEclipseTime;

  /// First contact with umbra  Partial begins (U1)
  final DateTime? partialStartTime;

  /// Last contact with umbra  Partial ends (U4)
  final DateTime? partialEndTime;

  /// Total phase begins  Moon fully in umbra (U2)
  final DateTime? totalStartTime;

  /// Total phase ends (U3)
  final DateTime? totalEndTime;

  /// First contact with penumbra (P1)
  final DateTime? penumbralStartTime;

  /// Last contact with penumbra (P4)
  final DateTime? penumbralEndTime;

  // ------------------------------------------------------------------
  // Location-specific fields (set when observer location is provided)
  // ------------------------------------------------------------------

  /// Moonrise at the observer's location (UTC). Null if Moon doesn't rise.
  final DateTime? moonrise;

  /// Moonset at the observer's location (UTC). Null if Moon doesn't set.
  final DateTime? moonset;

  // ------------------------------------------------------------------
  // Derived convenience getters
  // ------------------------------------------------------------------

  /// Whether it's a total eclipse
  bool get isTotal => magnitude >= 1.0;

  /// Whether it's a partial eclipse
  bool get isPartial => magnitude > 0.0 && magnitude < 1.0;

  /// Whether it's penumbral-only
  bool get isPenumbralOnly => magnitude <= 0.0 && (penumbralMagnitude ?? 0) > 0;

  /// The eclipse start visible from the observer's location.
  ///
  /// For lunar eclipses: the later of [partialStartTime] and [moonrise].
  /// This matches the "Lunar Eclipse Starts (With Moonrise)" field
  /// shown on astrology sites.
  DateTime? get localStartTime {
    final globalStart = partialStartTime ?? penumbralStartTime ?? startTime;
    if (globalStart == null) return null;
    if (moonrise == null) return globalStart;
    return moonrise!.isAfter(globalStart) ? moonrise : globalStart;
  }

  /// The eclipse end visible from the observer's location.
  ///
  /// The earlier of [partialEndTime] and [moonset] (or global end if Moon
  /// stays above the horizon throughout).
  DateTime? get localEndTime {
    final globalEnd = partialEndTime ?? penumbralEndTime ?? endTime;
    if (globalEnd == null) return null;
    if (moonset == null) return globalEnd;
    return moonset!.isBefore(globalEnd) ? moonset : globalEnd;
  }

  /// Duration of the eclipse as visible from the observer's location.
  Duration? get localDuration {
    final s = localStartTime;
    final e = localEndTime;
    if (s == null || e == null) return null;
    final d = e.difference(s);
    return d.isNegative ? Duration.zero : d;
  }

  // ------------------------------------------------------------------
  // Sutak (religious fast / abstinence period)
  // ------------------------------------------------------------------

  bool get _isSolar =>
      eclipseType == EclipseType.solar ||
      eclipseType == EclipseType.solarTotal ||
      eclipseType == EclipseType.solarPartial ||
      eclipseType == EclipseType.solarAnnular;

  /// Sutak for healthy adults.
  ///
  /// Computed as 9 hours (3 Prahars) before the eclipse becomes visible at
  /// the observer's location:
  ///  - Uses [localStartTime] (moonrise if after U1) as the anchor.
  ///  - Falls back to the global umbral start (U1) when no moon-rise data.
  /// For Solar Eclipse: 12 hours (4 Prahars) before U1.
  DateTime? get sutakStartTime {
    // Use local visibility start if available (accounts for moonrise after U1)
    final anchor = localStartTime ?? partialStartTime ?? startTime;
    if (anchor == null) return null;
    return anchor.subtract(Duration(hours: _isSolar ? 12 : 9));
  }

  /// Sutak for children, elderly, and the sick.
  ///
  /// 3 hours (1 Prahar) before the eclipse becomes visible at the observer's
  /// location ([localStartTime]), falling back to global U1.
  DateTime? get sutakForSensitive {
    final anchor = localStartTime ?? partialStartTime ?? startTime;
    if (anchor == null) return null;
    return anchor.subtract(const Duration(hours: 3));
  }

  /// Sutak ends when the umbral phase ends (U4)  same as [partialEndTime].
  DateTime? get sutakEndTime => partialEndTime ?? endTime;
}
