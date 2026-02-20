import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';

/// FFI bindings for Swiss Ephemeris C library.
///
/// This class provides low-level bindings to the Swiss Ephemeris shared library.
class SwissEphBindings {
  SwissEphBindings() {
    _lib = _loadLibrary();
  }
  late final ffi.DynamicLibrary _lib;

  // Function signatures
  late final _sweSetEphePath = _lib.lookupFunction<
      ffi.Void Function(ffi.Pointer<ffi.Char>),
      void Function(ffi.Pointer<ffi.Char>)>('swe_set_ephe_path');

  late final _sweCalcUt = _lib.lookupFunction<
      ffi.Int32 Function(
        ffi.Double,
        ffi.Int32,
        ffi.Int32,
        ffi.Pointer<ffi.Double>,
        ffi.Pointer<ffi.Char>,
      ),
      int Function(
        double,
        int,
        int,
        ffi.Pointer<ffi.Double>,
        ffi.Pointer<ffi.Char>,
      )>('swe_calc_ut');

  late final _sweSetSidMode = _lib.lookupFunction<
      ffi.Void Function(ffi.Int32, ffi.Double, ffi.Double),
      void Function(int, double, double)>('swe_set_sid_mode');

  late final _sweSetTopo = _lib.lookupFunction<
      ffi.Void Function(ffi.Double, ffi.Double, ffi.Double),
      void Function(double, double, double)>('swe_set_topo');

  late final _sweClose =
      _lib.lookupFunction<ffi.Void Function(), void Function()>('swe_close');

  late final _sweJulday = _lib.lookupFunction<
      ffi.Double Function(
        ffi.Int32,
        ffi.Int32,
        ffi.Int32,
        ffi.Double,
        ffi.Int32,
      ),
      double Function(
        int,
        int,
        int,
        double,
        int,
      )>('swe_julday');

  late final _sweVersion = _lib.lookupFunction<ffi.Pointer<ffi.Char> Function(),
      ffi.Pointer<ffi.Char> Function()>('swe_version');

  late final _sweGetAyanamsaUt = _lib.lookupFunction<
      ffi.Double Function(ffi.Double),
      double Function(double)>('swe_get_ayanamsa_ut');

  late final _sweHouses = _lib.lookupFunction<
      ffi.Int32 Function(
        ffi.Double,
        ffi.Double,
        ffi.Double,
        ffi.Int32,
        ffi.Pointer<ffi.Double>,
        ffi.Pointer<ffi.Double>,
      ),
      int Function(
        double,
        double,
        double,
        int,
        ffi.Pointer<ffi.Double>,
        ffi.Pointer<ffi.Double>,
      )>('swe_houses');

  late final _sweRiseTrans = _lib.lookupFunction<
      ffi.Int32 Function(
        ffi.Double,
        ffi.Int32,
        ffi.Pointer<ffi.Char>,
        ffi.Int32,
        ffi.Int32,
        ffi.Pointer<ffi.Double>,
        ffi.Double,
        ffi.Double,
        ffi.Pointer<ffi.Double>,
        ffi.Pointer<ffi.Char>,
      ),
      int Function(
        double,
        int,
        ffi.Pointer<ffi.Char>,
        int,
        int,
        ffi.Pointer<ffi.Double>,
        double,
        double,
        ffi.Pointer<ffi.Double>,
        ffi.Pointer<ffi.Char>,
      )>('swe_rise_trans');

  /// Loads the appropriate Swiss Ephemeris library for the platform.
  ffi.DynamicLibrary _loadLibrary() {
    // Try custom path first (from environment or development location)
    final customPath = Platform.environment['SWISSEPH_LIB_PATH'];
    if (customPath != null && customPath.isNotEmpty) {
      try {
        return ffi.DynamicLibrary.open(customPath);
      } catch (e) {
        // Silently fail if custom path is invalid
      }
    }

    // Try development/local paths
    if (Platform.isMacOS) {
      final devPaths = [
        '/Users/sanjibacharya/Developer/jyotish/native/swisseph/swisseph-master/libswisseph.dylib',
        '/usr/local/lib/libswisseph.dylib',
        'libswisseph.dylib',
      ];

      for (final path in devPaths) {
        try {
          return ffi.DynamicLibrary.open(path);
        } catch (e) {
          // Try next path
          continue;
        }
      }
    }

    // Fall back to standard loading
    if (Platform.isAndroid) {
      return ffi.DynamicLibrary.open('libswisseph.so');
    } else if (Platform.isIOS || Platform.isMacOS) {
      return ffi.DynamicLibrary.open('libswisseph.dylib');
    } else if (Platform.isLinux) {
      return ffi.DynamicLibrary.open('libswisseph.so');
    } else if (Platform.isWindows) {
      return ffi.DynamicLibrary.open('swisseph.dll');
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  /// Sets the path to Swiss Ephemeris data files.
  void setEphemerisPath(String path) {
    final pathPtr = path.toNativeUtf8();
    try {
      _sweSetEphePath(pathPtr.cast());
    } finally {
      malloc.free(pathPtr);
    }
  }

  /// Calculates planet position using Universal Time.
  ///
  /// Returns a list of 6 doubles: [longitude, latitude, distance,
  /// longitudeSpeed, latitudeSpeed, distanceSpeed]
  ///
  /// Returns null if calculation fails, with error message in [errorBuffer].
  List<double>? calculateUT({
    required double julianDay,
    required int planetId,
    required int flags,
    required ffi.Pointer<ffi.Char> errorBuffer,
  }) {
    final resultPtr = malloc<ffi.Double>(6);
    try {
      final returnCode = _sweCalcUt(
        julianDay,
        planetId,
        flags,
        resultPtr,
        errorBuffer,
      );

      if (returnCode < 0) {
        return null;
      }

      return List.generate(6, (i) => resultPtr[i]);
    } finally {
      malloc.free(resultPtr);
    }
  }

  /// Sets sidereal mode.
  void setSiderealMode(int mode, double t0, double ayanT0) {
    _sweSetSidMode(mode, t0, ayanT0);
  }

  /// Sets topocentric position.
  void setTopocentric(double longitude, double latitude, double altitude) {
    _sweSetTopo(longitude, latitude, altitude);
  }

  /// Closes Swiss Ephemeris and frees resources.
  void close() {
    _sweClose();
  }

  /// Converts Gregorian date to Julian day number.
  double julianDay({
    required int year,
    required int month,
    required int day,
    required double hour,
    bool isGregorian = true,
  }) {
    final calendarType = isGregorian ? 1 : 0; // SE_GREG_CAL = 1, SE_JUL_CAL = 0
    return _sweJulday(year, month, day, hour, calendarType);
  }

  /// Gets Swiss Ephemeris version string.
  String getVersion() {
    final versionPtr = _sweVersion();
    return versionPtr.cast<Utf8>().toDartString();
  }

  /// Gets ayanamsa (sidereal offset) for a given Julian day.
  double getAyanamsaUT(double julianDay) {
    return _sweGetAyanamsaUt(julianDay);
  }

  /// Calculates house cusps and ascendant/midheaven.
  ///
  /// Returns a map with:
  /// - 'cusps': List of 12 house cusps (0-11)
  /// - 'ascmc': List with ascendant, MC, ARMC, vertex, etc.
  ///
  /// House system codes:
  /// - 'P' = Placidus
  /// - 'K' = Koch
  /// - 'O' = Porphyrius
  /// - 'R' = Regiomontanus
  /// - 'C' = Campanus
  /// - 'A' or 'E' = Equal (cusp 1 is Ascendant)
  /// - 'W' = Whole sign
  Map<String, List<double>>? calculateHouses({
    required double julianDay,
    required double latitude,
    required double longitude,
    String houseSystem = 'P', // Placidus by default
  }) {
    // Allocate memory for cusps (13 elements, index 0 unused, 1-12 are house cusps)
    final cuspsPtr = malloc<ffi.Double>(13);
    // Allocate memory for ascmc (10 elements: ascendant, MC, ARMC, vertex, etc.)
    final ascmcPtr = malloc<ffi.Double>(10);

    try {
      final systemCode = houseSystem.codeUnitAt(0);

      final returnCode = _sweHouses(
        julianDay,
        latitude,
        longitude,
        systemCode,
        cuspsPtr,
        ascmcPtr,
      );

      if (returnCode < 0) {
        return null;
      }

      // Extract cusps (indices 1-12, skip index 0)
      final cusps = List.generate(12, (i) => cuspsPtr[i + 1]);

      // Extract ascmc values
      // [0] = Ascendant, [1] = MC, [2] = ARMC, [3] = Vertex,
      // [4] = Equatorial ascendant, [5] = Co-ascendant (Koch), etc.
      final ascmc = List.generate(10, (i) => ascmcPtr[i]);

      return {
        'cusps': cusps,
        'ascmc': ascmc,
      };
    } finally {
      malloc.free(cuspsPtr);
      malloc.free(ascmcPtr);
    }
  }

  /// Calculates rise, set, or transit times for a planet.
  ///
  /// [julianDay] - Julian day number for start of search
  /// [planetId] - Planet number (SE_SUN for sunrise/sunset)
  /// [rsmi] - Calculation flag (SE_CALC_RISE, SE_CALC_SET, etc.)
  /// [latitude] - Geographic latitude
  /// [longitude] - Geographic longitude
  /// [errorBuffer] - Buffer for error messages
  ///
  /// Returns the Julian day of the event, or null if calculation fails.
  double? calculateRiseSet({
    required double julianDay,
    required int planetId,
    required int rsmi,
    required double latitude,
    required double longitude,
    required ffi.Pointer<ffi.Char> errorBuffer,
    double atpress = 0.0,
    double attemp = 0.0,
  }) {
    // geopos array: longitude, latitude, altitude
    final geoposPtr = malloc<ffi.Double>(3);
    final resultPtr = malloc<ffi.Double>(1);

    try {
      geoposPtr[0] = longitude;
      geoposPtr[1] = latitude;
      geoposPtr[2] = 0.0; // altitude

      final returnCode = _sweRiseTrans(
        julianDay,
        planetId,
        ffi.nullptr, // starname
        0, // epheflag (SEFLG_SWIEPH)
        rsmi,
        geoposPtr,
        atpress,
        attemp,
        resultPtr,
        errorBuffer,
      );

      if (returnCode < 0) {
        return null;
      }

      return resultPtr[0];
    } finally {
      malloc.free(geoposPtr);
      malloc.free(resultPtr);
    }
  }
}
