import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'package:synchronized/synchronized.dart';

import 'package:jyotish/src/bindings/swisseph_bindings.dart';
import 'package:jyotish/src/models/geographic_location.dart';
import 'package:jyotish/src/astronomy/ephemeris_service.dart'; // To reuse EclipseData & EclipseType

/// A service to predict future and past solar and lunar eclipses.
///
/// It supports both global predictions (all eclipses occurring on Earth) and
/// local predictions (eclipses visible at a specific geographic location).
class EclipseService {
  final SwissEphBindings _bindings;
  final _lock = Lock();

  EclipseService(this._bindings);

  /// Predicts the next [count] lunar eclipses starting from [startDate].
  ///
  /// Since lunar eclipses are globally visible (wherever the Moon is above the horizon),
  /// no geographic location is required for this search.
  Future<List<EclipseData>> predictLunarEclipses({
    required DateTime startDate,
    required int count,
  }) async {
    return _lock.synchronized(() async {
      final eclipses = <EclipseData>[];
      var currentJd = _dateTimeToJulianDay(startDate);
      final errorBuffer = malloc<ffi.Char>(256);

      try {
        while (eclipses.length < count) {
          final tret = _bindings.findLunarEclipseWhen(
            julianDay: currentJd,
            flags: 0,
            eclipseTypeFlags: 14, // SE_ECL_ALLTYPES_LUNAR
            backward: false,
            errorBuffer: errorBuffer,
          );

          if (tret == null) break;

          final maxTime = _julianDayToDateTime(tret[0]);

          // Get detailed attributes at the moment of maximum
          final attr = _bindings.calculateLunarEclipseHow(
            julianDay: tret[0],
            flags: 0,
            errorBuffer: errorBuffer,
          );

          if (attr != null) {
            final umbralMag = attr[0];
            final penumbralMag = attr[1];

            EclipseType eclipseType = EclipseType.lunarPenumbral;
            if (umbralMag >= 1.0) {
              eclipseType = EclipseType.lunarTotal;
            } else if (umbralMag > 0.0) {
              eclipseType = EclipseType.lunarPartial;
            }

            // Contact times
            final u1 = tret[2] > 0 ? _julianDayToDateTime(tret[2]) : null;
            final u4 = tret[3] > 0 ? _julianDayToDateTime(tret[3]) : null;
            final u2 = tret[4] > 0 ? _julianDayToDateTime(tret[4]) : null;
            final u3 = tret[5] > 0 ? _julianDayToDateTime(tret[5]) : null;
            final p1 = tret[6] > 0 ? _julianDayToDateTime(tret[6]) : null;
            final p4 = tret[7] > 0 ? _julianDayToDateTime(tret[7]) : null;

            eclipses.add(
              EclipseData(
                date: maxTime,
                eclipseType: eclipseType,
                magnitude: umbralMag,
                penumbralMagnitude: penumbralMag,
                isVisible: true,
                maxEclipseTime: maxTime,
                startTime: u1 ?? p1,
                endTime: u4 ?? p4,
                partialStartTime: u1,
                partialEndTime: u4,
                totalStartTime: u2,
                totalEndTime: u3,
                penumbralStartTime: p1,
                penumbralEndTime: p4,
                duration: u4 != null && u1 != null
                    ? u4.difference(u1)
                    : (p4 != null && p1 != null ? p4.difference(p1) : null),
                description:
                    '${eclipseType.name} Eclipse (Mag: ${umbralMag.toStringAsFixed(3)})',
              ),
            );
          }

          // Advance past current eclipse (at least 15 days forward)
          currentJd = tret[0] + 15.0;
        }
      } finally {
        malloc.free(errorBuffer);
      }
      return eclipses;
    });
  }

  /// Predicts the next [count] solar eclipses starting from [startDate].
  ///
  /// If [location] is provided, it returns only solar eclipses *visible at that specific location*.
  /// If [location] is null, it returns all *global* solar eclipses.
  Future<List<EclipseData>> predictSolarEclipses({
    required DateTime startDate,
    required int count,
    GeographicLocation? location,
  }) async {
    return _lock.synchronized(() async {
      final eclipses = <EclipseData>[];
      var currentJd = _dateTimeToJulianDay(startDate);
      final errorBuffer = malloc<ffi.Char>(256);

      try {
        if (location != null) {
          // Local solar eclipses
          while (eclipses.length < count) {
            final result = _bindings.findSolarEclipseWhenLoc(
              julianDay: currentJd,
              latitude: location.latitude,
              longitude: location.longitude,
              altitude: location.altitude,
              flags: 0,
              backward: false,
              errorBuffer: errorBuffer,
            );

            if (result == null) break;

            final tret = result.sublist(0, 10);
            final attr = result.sublist(10, 30);
            final maxTime = _julianDayToDateTime(tret[0]);

            final c1 = tret[1] > 0 ? _julianDayToDateTime(tret[1]) : null;
            final c2 = tret[2] > 0 ? _julianDayToDateTime(tret[2]) : null;
            final c3 = tret[3] > 0 ? _julianDayToDateTime(tret[3]) : null;
            final c4 = tret[4] > 0 ? _julianDayToDateTime(tret[4]) : null;
            final localMagnitude = attr[0];

            EclipseType type = EclipseType.solarPartial;
            if (attr[1] >= 1.0 && c2 != null && c3 != null) {
              type = EclipseType.solarTotal;
            } else if (attr[1] < 1.0 && c2 != null && c3 != null) {
              type = EclipseType.solarAnnular;
            }

            eclipses.add(
              EclipseData(
                date: maxTime,
                eclipseType: type,
                magnitude: localMagnitude,
                isVisible: localMagnitude > 0,
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
              ),
            );

            currentJd = tret[0] + 15.0;
          }
        } else {
          // Global solar eclipses
          while (eclipses.length < count) {
            final tret = _bindings.findSolarEclipseWhenGlob(
              julianDay: currentJd,
              flags: 0,
              eclipseTypeFlags: 7, // SE_ECL_ALLTYPES_SOLAR
              backward: false,
              errorBuffer: errorBuffer,
            );

            if (tret == null) break;

            final maxTime = _julianDayToDateTime(tret[0]);
            final c1 = tret[1] > 0 ? _julianDayToDateTime(tret[1]) : null;
            final c4 = tret[2] > 0 ? _julianDayToDateTime(tret[2]) : null;

            final c2 = (tret[3] > 0 ? tret[3] : (tret[5] > 0 ? tret[5] : 0.0));
            final c3 = (tret[4] > 0 ? tret[4] : (tret[6] > 0 ? tret[6] : 0.0));
            final totalStart = c2 > 0 ? _julianDayToDateTime(c2) : null;
            final totalEnd = c3 > 0 ? _julianDayToDateTime(c3) : null;

            EclipseType type = EclipseType.solarPartial;
            if (tret[3] > 0) {
              type = EclipseType.solarTotal;
            } else if (tret[5] > 0) {
              type = EclipseType.solarAnnular;
            }

            eclipses.add(
              EclipseData(
                date: maxTime,
                eclipseType: type,
                magnitude: type == EclipseType.solarTotal ? 1.0 : 0.5,
                isVisible: true,
                maxEclipseTime: maxTime,
                startTime: c1,
                endTime: c4,
                partialStartTime: c1,
                partialEndTime: c4,
                totalStartTime: totalStart,
                totalEndTime: totalEnd,
                duration: c4 != null && c1 != null ? c4.difference(c1) : null,
                description: 'Global ${type.name} Eclipse',
              ),
            );

            currentJd = tret[0] + 15.0;
          }
        }
      } finally {
        malloc.free(errorBuffer);
      }
      return eclipses;
    });
  }

  /// Predicts the next [count] solar and/or lunar eclipses starting from [startDate].
  ///
  /// Merges results chronologically and filters by [type] if specified.
  Future<List<EclipseData>> predictEclipses({
    required DateTime startDate,
    required int count,
    GeographicLocation? location,
    EclipseType type = EclipseType.any,
  }) async {
    final showSolar = type == EclipseType.any ||
        type == EclipseType.solar ||
        type == EclipseType.solarTotal ||
        type == EclipseType.solarPartial ||
        type == EclipseType.solarAnnular;

    final showLunar = type == EclipseType.any ||
        type == EclipseType.lunar ||
        type == EclipseType.lunarTotal ||
        type == EclipseType.lunarPartial ||
        type == EclipseType.lunarPenumbral;

    final allResults = <EclipseData>[];

    // Predict slightly more than count to allow merging and slicing
    if (showSolar) {
      final solar = await predictSolarEclipses(
        startDate: startDate,
        count: count,
        location: location,
      );
      allResults.addAll(solar);
    }

    if (showLunar) {
      final lunar = await predictLunarEclipses(
        startDate: startDate,
        count: count,
      );
      allResults.addAll(lunar);
    }

    // Sort chronologically
    allResults.sort((a, b) => a.date.compareTo(b.date));

    // Filter by exact type if requested
    var filtered = allResults;
    if (type != EclipseType.any &&
        type != EclipseType.solar &&
        type != EclipseType.lunar) {
      filtered = allResults.where((e) => e.eclipseType == type).toList();
    }

    if (filtered.length > count) {
      return filtered.sublist(0, count);
    }
    return filtered;
  }

  /// Predicts all eclipses (solar and lunar) occurring in a specific Gregorian [year].
  Future<List<EclipseData>> predictEclipsesInYear({
    required int year,
    GeographicLocation? location,
  }) async {
    final startOfYear = DateTime.utc(year, 1, 1);
    final endOfYear = DateTime.utc(year, 12, 31, 23, 59, 59);

    // Predict up to 10 eclipses starting from Jan 1st (typically a year has 4-7 eclipses)
    final candidates = await predictEclipses(
      startDate: startOfYear,
      count: 10,
      location: location,
    );

    return candidates.where((e) => e.date.isBefore(endOfYear)).toList();
  }

  // --- Julian Day Conversions ---

  double _dateTimeToJulianDay(DateTime dateTime) {
    final utc = dateTime.toUtc();
    final year = utc.year;
    final month = utc.month;
    final day = utc.day;
    final hour = utc.hour +
        (utc.minute / 60.0) +
        (utc.second / 3600.0) +
        (utc.millisecond / 3600000.0);

    var y = year;
    var m = month;
    if (m <= 2) {
      y -= 1;
      m += 12;
    }

    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();

    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        day +
        b -
        1524.5 +
        (hour / 24.0);
  }

  DateTime _julianDayToDateTime(double julianDay) {
    final jd = julianDay + 0.5;
    final z = jd.floor();
    final f = jd - z;

    var a = z;
    if (z >= 2299161) {
      final alpha = ((z - 1867216.25) / 36524.25).floor();
      a = z + 1 + alpha - (alpha / 4).floor();
    }

    final b = a + 1524;
    final c = ((b - 122.1) / 365.25).floor();
    final d = (365.25 * c).floor();
    final e = ((b - d) / 30.6001).floor();

    final day = b - d - (30.6001 * e).floor() + f;

    var month = e - 1;
    if (e == 14 || e == 15) {
      month = e - 13;
    }

    var year = c - 4715;
    if (month > 2) {
      year = c - 4716;
    }

    final dayInt = day.floor();
    final hoursFraction = (day - dayInt) * 24.0;
    final hour = hoursFraction.floor();
    final minutesFraction = (hoursFraction - hour) * 60.0;
    final minute = minutesFraction.floor();
    final secondsFraction = (minutesFraction - minute) * 60.0;
    final second = secondsFraction.floor();
    final msFraction = (secondsFraction - second) * 1000.0;
    final ms = msFraction.round();

    return DateTime.utc(year, month, dayInt, hour, minute, second, ms);
  }
}
