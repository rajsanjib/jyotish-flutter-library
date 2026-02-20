import 'planet.dart';

/// Represents the calculated position of a planet at a specific time.
///
/// This class contains the ecliptic longitude, latitude, distance, and speed
/// of a celestial body as calculated by Swiss Ephemeris.
class PlanetPosition {
  /// Creates a new [PlanetPosition].
  ///
  /// [planet] - The planet this position is for.
  /// [dateTime] - The date and time of calculation.
  /// [longitude] - Ecliptic longitude in degrees.
  /// [latitude] - Ecliptic latitude in degrees.
  /// [distance] - Distance from Earth in AU.
  /// [longitudeSpeed] - Speed of longitude change in degrees/day.
  /// [latitudeSpeed] - Speed of latitude change in degrees/day.
  /// [distanceSpeed] - Speed of distance change in AU/day.
  /// [isCombust] - Whether the planet is combust (optional, defaults to false).
  /// [isRetrograde] - Override retrograde detection (optional, auto-detected if not provided).
  const PlanetPosition({
    required this.planet,
    required this.dateTime,
    required this.longitude,
    required this.latitude,
    required this.distance,
    required this.longitudeSpeed,
    required this.latitudeSpeed,
    required this.distanceSpeed,
    this.declination = 0.0,
    this.isCombust = false,
    bool? isRetrograde,
  }) : isRetrograde = isRetrograde ?? longitudeSpeed < 0;

  /// Creates a position from raw Swiss Ephemeris calculation results.
  factory PlanetPosition.fromSwissEph({
    required Planet planet,
    required DateTime dateTime,
    required List<double> results,
    double? sunLongitude,
    bool? isRetrograde,
  }) {
    return PlanetPosition(
      planet: planet,
      dateTime: dateTime,
      longitude: results[0],
      latitude: results[1],
      distance: results[2],
      longitudeSpeed: results[3],
      latitudeSpeed: results[4],
      distanceSpeed: results[5],
      declination: results.length > 6 ? results[6] : 0.0,
      isCombust: sunLongitude != null
          ? calculateCombustion(planet, results[0], sunLongitude)
          : false,
      isRetrograde: isRetrograde,
    );
  }

  /// The planet this position is for.
  final Planet planet;

  /// The date and time this position was calculated for.
  final DateTime dateTime;

  /// Ecliptic longitude in decimal degrees (0.0 - 360.0).
  final double longitude;

  /// Ecliptic latitude in decimal degrees (-90.0 to 90.0).
  final double latitude;

  /// Distance from Earth in astronomical units (AU).
  final double distance;

  /// Longitude speed in degrees per day.
  final double longitudeSpeed;

  /// Latitude speed in degrees per day.
  final double latitudeSpeed;

  /// Distance speed in AU per day.
  final double distanceSpeed;

  /// Declination in decimal degrees (-90.0 to 90.0).
  /// Calculated in equatorial coordinates.
  final double declination;

  /// Whether the planet is in retrograde motion.
  final bool isRetrograde;

  /// Whether the planet is combust (too close to the Sun).
  /// Only applicable to planets other than the Sun itself.
  final bool isCombust;

  /// Calculates if a planet is combust (too close to the Sun).
  /// Uses traditional Vedic astrology combustion distances.
  static bool calculateCombustion(
      Planet planet, double planetLongitude, double sunLongitude) {
    // Sun is never combust
    if (planet == Planet.sun) return false;

    // Calculate angular distance between planet and Sun
    final difference = ((planetLongitude - sunLongitude + 540) % 360) - 180;
    final absDiff = difference.abs();

    // Vedic astrology combustion distances (in degrees)
    final combustionDistances = {
      Planet.moon: 12.0,
      Planet.mercury: 14.0,
      Planet.venus: 10.0,
      Planet.mars: 17.0,
      Planet.jupiter: 11.0,
      Planet.saturn: 15.0,
    };

    final threshold = combustionDistances[planet] ?? 10.0;
    return absDiff < threshold;
  }

  /// Creates a copy of this position with updated combustion status.
  /// Useful when Sun's position becomes available after initial calculation.
  PlanetPosition withCombustionCheck(double sunLongitude) {
    return PlanetPosition(
      planet: planet,
      dateTime: dateTime,
      longitude: longitude,
      latitude: latitude,
      distance: distance,
      longitudeSpeed: longitudeSpeed,
      latitudeSpeed: latitudeSpeed,
      distanceSpeed: distanceSpeed,
      isCombust: calculateCombustion(planet, longitude, sunLongitude),
    );
  }

  /// Gets the zodiac sign (0-11, where 0=Aries, 1=Taurus, etc.).
  int get zodiacSignIndex => (longitude / 30).floor() % 12;

  /// Gets the zodiac sign name.
  String get zodiacSign => _zodiacSigns[zodiacSignIndex];

  /// Gets the position within the zodiac sign (0.0 - 30.0 degrees).
  double get positionInSign => longitude % 30;

  /// Gets the position in degrees, minutes, and seconds within the sign.
  Map<String, dynamic> get positionInSignDMS {
    final pos = positionInSign;
    final degrees = pos.floor();
    final minutesDecimal = (pos - degrees) * 60;
    final minutes = minutesDecimal.floor();
    final seconds = (minutesDecimal - minutes) * 60;

    return {
      'degrees': degrees,
      'minutes': minutes,
      'seconds': seconds,
    };
  }

  /// Gets the nakshatra (lunar mansion) index (0-26).
  /// Each nakshatra is 13°20' (13.333... degrees).
  int get nakshatraIndex => (longitude / (360 / 27)).floor() % 27;

  /// Gets the nakshatra name.
  String get nakshatra => _nakshatras[nakshatraIndex];

  /// Gets the nakshatra pada (quarter, 1-4).
  int get nakshatraPada {
    final posInNakshatra = longitude % (360 / 27);
    return (posInNakshatra / (360 / 27 / 4)).floor() + 1;
  }

  /// Formats the position as a traditional notation (e.g., "15° Aries 30'").
  String get formattedPosition {
    final dms = positionInSignDMS;
    return '${dms['degrees']}° $zodiacSign ${dms['minutes']}\'';
  }

  /// Formats the position with full DMS notation.
  String get formattedPositionDMS {
    final dms = positionInSignDMS;
    return '${dms['degrees']}° ${dms['minutes']}\' ${dms['seconds'].toStringAsFixed(2)}" $zodiacSign';
  }

  @override
  String toString() {
    final retrograde = isRetrograde ? ' (R)' : '';
    final combust = isCombust ? ' (C)' : '';
    return 'PlanetPosition('
        '${planet.displayName}: $formattedPosition$retrograde$combust, '
        'lat: ${latitude.toStringAsFixed(4)}°, '
        'dist: ${distance.toStringAsFixed(6)} AU)';
  }

  /// Converts this position to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'planet': planet.displayName,
      'dateTime': dateTime.toIso8601String(),
      'longitude': longitude,
      'latitude': latitude,
      'distance': distance,
      'longitudeSpeed': longitudeSpeed,
      'latitudeSpeed': latitudeSpeed,
      'distanceSpeed': distanceSpeed,
      'declination': declination,
      'isRetrograde': isRetrograde,
      'isCombust': isCombust,
      'zodiacSign': zodiacSign,
      'zodiacSignIndex': zodiacSignIndex,
      'positionInSign': positionInSign,
      'nakshatra': nakshatra,
      'nakshatraIndex': nakshatraIndex,
      'nakshatraPada': nakshatraPada,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlanetPosition &&
        other.planet == planet &&
        other.dateTime == dateTime &&
        other.longitude == longitude &&
        other.latitude == latitude &&
        other.distance == distance &&
        other.isCombust == isCombust;
  }

  @override
  int get hashCode => Object.hash(
        planet,
        dateTime,
        longitude,
        latitude,
        distance,
        isCombust,
      );

  // Zodiac signs
  static const List<String> _zodiacSigns = [
    'Aries',
    'Taurus',
    'Gemini',
    'Cancer',
    'Leo',
    'Virgo',
    'Libra',
    'Scorpio',
    'Sagittarius',
    'Capricorn',
    'Aquarius',
    'Pisces',
  ];

  // Nakshatras (27 lunar mansions)
  static const List<String> _nakshatras = [
    'Ashwini',
    'Bharani',
    'Krittika',
    'Rohini',
    'Mrigashira',
    'Ardra',
    'Punarvasu',
    'Pushya',
    'Ashlesha',
    'Magha',
    'Purva Phalguni',
    'Uttara Phalguni',
    'Hasta',
    'Chitra',
    'Swati',
    'Vishakha',
    'Anuradha',
    'Jyeshtha',
    'Mula',
    'Purva Ashadha',
    'Uttara Ashadha',
    'Shravana',
    'Dhanishta',
    'Shatabhisha',
    'Purva Bhadrapada',
    'Uttara Bhadrapada',
    'Revati',
  ];
}
