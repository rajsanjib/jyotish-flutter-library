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
      final tzDt = tz.TZDateTime.from(localDt, location);
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
      final tzDt = tz.TZDateTime.from(date, location);
      return Duration(milliseconds: tzDt.timeZoneOffset.inMilliseconds);
    } catch (e) {
      return Duration.zero;
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
