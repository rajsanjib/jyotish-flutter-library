import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Service for handling high-precision historical timezone conversions.
///
/// This service uses the IANA/Olson database to convert local times
/// to UTC for any historical date, accounting for local DST changes.
class AstrologyTimeService {
  static bool _isInitialized = false;

  /// Initializes the timezone database.
  ///
  /// This must be called once before performing any conversions.
  static void initialize() {
    if (_isInitialized) return;
    tz.initializeTimeZones();
    _isInitialized = true;
  }

  /// Loads custom/updated timezone database bytes at runtime.
  ///
  /// [databaseBytes] - Raw bytes of a timezone/zoneinfo database file (.tzf).
  static void loadDatabase(List<int> databaseBytes) {
    tz.initializeDatabase(databaseBytes);
    _isInitialized = true;
  }

  /// Converts a local date and time to UTC using a specific IANA timezone ID.
  ///
  /// [localDt] - The date and time in the local timezone.
  /// [zoneId] - The IANA timezone ID (e.g., 'Asia/Kolkata', 'America/New_York').
  ///
  /// Returns a [DateTime] in UTC.
  static DateTime localToUtc(DateTime localDt, String zoneId) {
    _ensureInitialized();
    try {
      final location = tz.getLocation(zoneId);
      final tzDt = tz.TZDateTime(
        location,
        localDt.year,
        localDt.month,
        localDt.day,
        localDt.hour,
        localDt.minute,
        localDt.second,
      );
      return tzDt.toUtc();
    } catch (e) {
      // Fallback to UTC if zone is not found
      return localDt.toUtc();
    }
  }

  /// Gets the timezone offset for a specific date and timezone.
  ///
  /// Returns a [Duration] representing the offset from UTC.
  static Duration getOffset(DateTime date, String zoneId) {
    _ensureInitialized();
    try {
      final location = tz.getLocation(zoneId);
      final tzDt = tz.TZDateTime(
        location,
        date.year,
        date.month,
        date.day,
        date.hour,
        date.minute,
        date.second,
      );
      return Duration(milliseconds: tzDt.timeZoneOffset.inMilliseconds);
    } catch (e) {
      return Duration.zero;
    }
  }

  /// Converts a UTC date and time to a local date and time using a specific IANA timezone ID.
  static DateTime utcToLocal(DateTime utcDt, String zoneId) {
    _ensureInitialized();
    try {
      final location = tz.getLocation(zoneId);
      final tzDt = tz.TZDateTime.from(utcDt, location);
      return DateTime(
        tzDt.year,
        tzDt.month,
        tzDt.day,
        tzDt.hour,
        tzDt.minute,
        tzDt.second,
        tzDt.millisecond,
        tzDt.microsecond,
      );
    } catch (e) {
      // Fallback
      return utcDt.toLocal();
    }
  }

  /// Gets a list of all available IANA timezone IDs.
  static List<String> get availableTimezones =>
      tz.timeZoneDatabase.locations.keys.toList();

  static void _ensureInitialized() {
    if (!_isInitialized) {
      initialize();
    }
  }
}
