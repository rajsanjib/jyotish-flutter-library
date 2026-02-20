/// Represents a geographic location on Earth.
///
/// This class is used to specify the location for which planetary
/// positions should be calculated.
class GeographicLocation {
  /// Creates a new [GeographicLocation].
  ///
  /// [latitude] - Latitude in decimal degrees (-90.0 to 90.0).
  /// [longitude] - Longitude in decimal degrees (-180.0 to 180.0).
  /// [altitude] - Optional altitude in meters above sea level (defaults to 0.0).
  /// [timezone] - Optional IANA timezone ID (e.g., 'Asia/Kolkata').
  ///
  /// Throws [ArgumentError] if latitude or longitude is out of range.
  GeographicLocation({
    required this.latitude,
    required this.longitude,
    this.altitude = 0.0,
    this.timezone,
  }) {
    if (latitude < -90.0 || latitude > 90.0) {
      throw ArgumentError(
        'Latitude must be between -90.0 and 90.0, got $latitude',
      );
    }
    if (longitude < -180.0 || longitude > 180.0) {
      throw ArgumentError(
        'Longitude must be between -180.0 and 180.0, got $longitude',
      );
    }
  }

  /// Creates a location from degrees, minutes, and seconds.
  ///
  /// [latDegrees] - Latitude degrees (0-90).
  /// [latMinutes] - Latitude minutes (0-59).
  /// [latSeconds] - Latitude seconds (0-59.999...).
  /// [isNorth] - True for North, false for South.
  /// [lonDegrees] - Longitude degrees (0-180).
  /// [lonMinutes] - Longitude minutes (0-59).
  /// [lonSeconds] - Longitude seconds (0-59.999...).
  /// [isEast] - True for East, false for West.
  /// [altitude] - Optional altitude in meters.
  /// [timezone] - Optional IANA timezone ID.
  factory GeographicLocation.fromDMS({
    required int latDegrees,
    required int latMinutes,
    required double latSeconds,
    required bool isNorth,
    required int lonDegrees,
    required int lonMinutes,
    required double lonSeconds,
    required bool isEast,
    double altitude = 0.0,
    String? timezone,
  }) {
    final latitude = _dmsToDecimal(latDegrees, latMinutes, latSeconds, isNorth);
    final longitude = _dmsToDecimal(lonDegrees, lonMinutes, lonSeconds, isEast);

    return GeographicLocation(
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      timezone: timezone,
    );
  }

  /// Creates a location from a JSON map.
  factory GeographicLocation.fromJson(Map<String, dynamic> json) {
    return GeographicLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble() ?? 0.0,
      timezone: json['timezone'] as String?,
    );
  }

  /// Latitude in decimal degrees.
  /// Positive values represent North, negative values represent South.
  /// Valid range: -90.0 to 90.0
  final double latitude;

  /// Longitude in decimal degrees.
  /// Positive values represent East, negative values represent West.
  /// Valid range: -180.0 to 180.0
  final double longitude;

  /// Altitude/elevation above sea level in meters.
  /// Defaults to 0.0 (sea level).
  final double altitude;

  /// IANA timezone ID (e.g., 'Asia/Kolkata').
  /// Optional, used for high-precision historical time conversions.
  final String? timezone;

  /// Converts DMS (Degrees, Minutes, Seconds) to decimal degrees.
  static double _dmsToDecimal(
    int degrees,
    int minutes,
    double seconds,
    bool isPositive,
  ) {
    final decimal = degrees.abs() + (minutes / 60.0) + (seconds / 3600.0);
    return isPositive ? decimal : -decimal;
  }

  /// Converts latitude to DMS format.
  Map<String, dynamic> get latitudeDMS {
    final isNorth = latitude >= 0;
    final absLat = latitude.abs();
    final degrees = absLat.floor();
    final minutesDecimal = (absLat - degrees) * 60;
    final minutes = minutesDecimal.floor();
    final seconds = (minutesDecimal - minutes) * 60;

    return {
      'degrees': degrees,
      'minutes': minutes,
      'seconds': seconds,
      'direction': isNorth ? 'N' : 'S',
    };
  }

  /// Converts longitude to DMS format.
  Map<String, dynamic> get longitudeDMS {
    final isEast = longitude >= 0;
    final absLon = longitude.abs();
    final degrees = absLon.floor();
    final minutesDecimal = (absLon - degrees) * 60;
    final minutes = minutesDecimal.floor();
    final seconds = (minutesDecimal - minutes) * 60;

    return {
      'degrees': degrees,
      'minutes': minutes,
      'seconds': seconds,
      'direction': isEast ? 'E' : 'W',
    };
  }

  @override
  String toString() {
    final latDMS = latitudeDMS;
    final lonDMS = longitudeDMS;
    return 'GeographicLocation('
        'lat: ${latDMS['degrees']}°${latDMS['minutes']}\'${latDMS['seconds'].toStringAsFixed(2)}"${latDMS['direction']}, '
        'lon: ${lonDMS['degrees']}°${lonDMS['minutes']}\'${lonDMS['seconds'].toStringAsFixed(2)}"${lonDMS['direction']}, '
        'alt: ${altitude.toStringAsFixed(1)}m'
        '${timezone != null ? ', tz: $timezone' : ''})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GeographicLocation &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.altitude == altitude &&
        other.timezone == timezone;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude, altitude, timezone);

  /// Creates a copy of this location with optional parameter overrides.
  GeographicLocation copyWith({
    double? latitude,
    double? longitude,
    double? altitude,
    String? timezone,
  }) {
    return GeographicLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      timezone: timezone ?? this.timezone,
    );
  }

  /// Converts this location to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      if (timezone != null) 'timezone': timezone,
    };
  }
}
