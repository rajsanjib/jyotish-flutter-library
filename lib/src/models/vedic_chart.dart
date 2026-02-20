import '../models/planet.dart';
import '../models/planet_position.dart';

/// Represents Vedic astrology house system information.
///
/// ## House System Precision Notes
///
/// Different house systems have varying precision at extreme latitudes:
/// - **Whole Sign (W)**: Most reliable across all latitudes, recommended for Vedic astrology
/// - **Placidus (P)**: May produce unreliable results above 65° latitude
/// - **Koch (K)**: Limited accuracy above 60° latitude
/// - **Porphyrius (O)**: Moderate reliability at high latitudes
/// - **Regiomontanus (R)**: Similar limitations to Placidus
/// - **Campanus (C)**: Good accuracy across most latitudes
///
/// For locations above 65°N or below 65°S, Whole Sign houses are recommended.
class HouseSystem {
  const HouseSystem({
    required this.system,
    required this.cusps,
    required this.ascendant,
    required this.midheaven,
  });

  /// The house system used (default: Whole Sign)
  final String system;

  /// The 12 house cusps in degrees (0-360)
  final List<double> cusps;

  /// The Ascendant (Lagna) degree
  final double ascendant;

  /// The Midheaven (MC) degree
  final double midheaven;

  /// Gets the house number (1-12) for a given longitude
  int getHouseForLongitude(double longitude) {
    for (var i = 0; i < 12; i++) {
      final currentCusp = cusps[i];
      final nextCusp = cusps[(i + 1) % 12];

      if (nextCusp > currentCusp) {
        if (longitude >= currentCusp && longitude < nextCusp) {
          return i + 1;
        }
      } else {
        // House crosses 0° Aries
        if (longitude >= currentCusp || longitude < nextCusp) {
          return i + 1;
        }
      }
    }
    return 1; // Default to first house
  }

  /// Gets the zodiac sign of the Ascendant
  String get ascendantSign {
    final signIndex = (ascendant / 30).floor() % 12;
    return _zodiacSigns[signIndex];
  }

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
}

/// Represents Ketu (South Node) position.
/// Ketu is always 180° opposite to Rahu.
class KetuPosition {
  const KetuPosition({required this.rahuPosition});

  /// The planet position of Rahu used to calculate Ketu
  final PlanetPosition rahuPosition;

  /// Ketu's longitude (180° opposite to Rahu)
  double get longitude => (rahuPosition.longitude + 180) % 360;

  /// Ketu's latitude (opposite to Rahu)
  double get latitude => -rahuPosition.latitude;

  /// Ketu's distance (same as Rahu)
  double get distance => rahuPosition.distance;

  /// Ketu's speed (opposite to Rahu)
  double get longitudeSpeed => -rahuPosition.longitudeSpeed;

  /// Ketu always moves retrograde (like Rahu)
  bool get isRetrograde => true;

  /// Gets the zodiac sign
  String get zodiacSign {
    final signIndex = (longitude / 30).floor() % 12;
    return _zodiacSigns[signIndex];
  }

  /// Gets position within the sign (0-30°)
  double get positionInSign => longitude % 30;

  /// Gets the nakshatra index
  int get nakshatraIndex => (longitude / (360 / 27)).floor() % 27;

  /// Gets the nakshatra name
  String get nakshatra => _nakshatras[nakshatraIndex];

  /// Gets the nakshatra pada (1-4)
  int get nakshatraPada {
    final posInNakshatra = longitude % (360 / 27);
    return (posInNakshatra / (360 / 27 / 4)).floor() + 1;
  }

  /// Formatted position string
  String get formattedPosition {
    final dms = positionInSignDMS;
    return '${dms['degrees']}° $zodiacSign ${dms['minutes']}\'';
  }

  /// Gets position in DMS within the sign
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

  /// DateTime of the calculation
  DateTime get dateTime => rahuPosition.dateTime;

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

/// Represents planetary dignity in Vedic astrology.
enum PlanetaryDignity {
  exalted('Exalted', 'Uccha'),
  ownSign('Own Sign', 'Swakshetra'),
  greatFriend('Great Friend', 'Adhi-Mitra'),
  friendSign('Friend\'s Sign', 'Mitra'),
  neutralSign('Neutral Sign', 'Sama'),
  enemySign('Enemy\'s Sign', 'Shatru'),
  greatEnemy('Great Enemy', 'Adhi-Shatru'),
  debilitated('Debilitated', 'Neecha'),
  moolaTrikona('Moola Trikona', 'Moola Trikona');

  const PlanetaryDignity(this.english, this.sanskrit);

  final String english;
  final String sanskrit;

  @override
  String toString() => english;
}

/// Vedic-specific planetary information.
class VedicPlanetInfo {
  const VedicPlanetInfo({
    required this.position,
    required this.house,
    required this.dignity,
    this.isCombust = false,
    this.exaltationDegree,
    this.debilitationDegree,
    this.positionInSign,
    this.subSpan,
  });

  /// The base planet position
  final PlanetPosition position;

  /// The house number (1-12) the planet is in
  final int house;

  /// Planetary dignity
  final PlanetaryDignity dignity;

  /// Combust status (too close to Sun)
  final bool isCombust;

  /// Exaltation degree
  final double? exaltationDegree;

  /// Debilitation degree
  final double? debilitationDegree;

  /// Position within sign (0-30), useful for KP and D249
  final double? positionInSign;

  /// Span of the subdivision, useful for D249
  final double? subSpan;

  /// Gets the planet
  Planet get planet => position.planet;

  /// Gets the longitude
  double get longitude => position.longitude;

  /// Gets the zodiac sign
  String get zodiacSign => position.zodiacSign;

  /// Gets the nakshatra
  String get nakshatra => position.nakshatra;

  /// Gets the pada
  int get pada => position.nakshatraPada;

  /// Is retrograde
  bool get isRetrograde => position.isRetrograde;

  /// Formatted position
  String get formattedPosition => position.formattedPosition;
}

/// Complete Vedic astrology chart data.
class VedicChart {
  const VedicChart({
    required this.dateTime,
    required this.location,
    required this.latitude,
    required this.longitudeCoord,
    required this.houses,
    required this.planets,
    required this.rahu,
    required this.ketu,
  });

  /// Date and time of the chart
  final DateTime dateTime;

  /// Location of the chart
  final String location;

  /// Latitude
  final double latitude;

  /// Longitude
  final double longitudeCoord;

  /// House system information
  final HouseSystem houses;

  /// All planetary positions with Vedic info
  final Map<Planet, VedicPlanetInfo> planets;

  /// Rahu (North Node) position
  final VedicPlanetInfo rahu;

  /// Ketu (South Node) position
  final KetuPosition ketu;

  /// Gets the Ascendant sign
  String get ascendantSign => houses.ascendantSign;

  /// Gets the Ascendant degree
  double get ascendant => houses.ascendant;

  /// Gets a planet's information
  VedicPlanetInfo? getPlanet(Planet planet) => planets[planet];

  /// Gets all planets in a specific house
  List<VedicPlanetInfo> getPlanetsInHouse(int houseNumber) {
    return planets.values.where((info) => info.house == houseNumber).toList();
  }

  /// Gets all retrograde planets
  List<VedicPlanetInfo> get retrogradePlanets {
    return planets.values.where((info) => info.isRetrograde).toList();
  }

  /// Gets all exalted planets
  List<VedicPlanetInfo> get exaltedPlanets {
    return planets.values
        .where((info) => info.dignity == PlanetaryDignity.exalted)
        .toList();
  }

  /// Gets all debilitated planets
  List<VedicPlanetInfo> get debilitatedPlanets {
    return planets.values
        .where((info) => info.dignity == PlanetaryDignity.debilitated)
        .toList();
  }

  /// Gets all combust planets
  List<VedicPlanetInfo> get combustPlanets {
    return planets.values.where((info) => info.isCombust).toList();
  }
}
