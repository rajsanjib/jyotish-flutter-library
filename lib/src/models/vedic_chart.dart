import 'package:jyotish/src/models/planet.dart';
import 'package:jyotish/src/models/rashi.dart';
import 'package:jyotish/src/astronomy/planet_position.dart';
import 'package:jyotish/src/models/calculation_flags.dart';
import 'package:jyotish/src/models/divisional_chart_type.dart';
import 'package:jyotish/src/analysis/divisional_chart_service.dart';
import 'package:jyotish/src/strength/planetary_relationship_service.dart';
import 'package:jyotish/src/strength/relationship.dart';

/// Represents Vedic astrology house system information.
///
/// ## House System Precision Notes
///
/// Different house systems have varying precision at extreme latitudes:
/// - **Whole Sign (W)**: Most reliable across all latitudes, recommended for Vedic astrology
/// - **Placidus (P)**: May produce unreliable results above 65 latitude
/// - **Koch (K)**: Limited accuracy above 60 latitude
/// - **Porphyrius (O)**: Moderate reliability at high latitudes
/// - **Regiomontanus (R)**: Similar limitations to Placidus
/// - **Campanus (C)**: Good accuracy across most latitudes
///
/// For locations above 65N or below 65S, Whole Sign houses are recommended.
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
        // House crosses 0 Aries
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

  /// Sanskrit name of the Ascendant sign.
  String get ascendantSignSanskrit {
    final signIndex = (ascendant / 30).floor() % 12;
    return Rashi.values[signIndex].sanskritName;
  }

  /// Converts this HouseSystem to a JSON map.
  Map<String, dynamic> toJson() => {
        'system': system,
        'ascendant': ascendant,
        'midheaven': midheaven,
        'cusps': cusps,
      };

  /// Gets a list of all 12 houses as [House] models.
  List<House> get individualHouses {
    return List.generate(12, (index) {
      final num = index + 1;
      final cusp = cusps[index];
      final signIndex = (cusp / 30).floor() % 12;
      return House(
        number: num,
        cusp: cusp,
        zodiacSign: _zodiacSigns[signIndex],
      );
    });
  }

  /// Gets a specific house model by its house number (1-12).
  House getHouse(int number) {
    if (number < 1 || number > 12) {
      throw RangeError.range(number, 1, 12, 'house number');
    }
    final cusp = cusps[number - 1];
    final signIndex = (cusp / 30).floor() % 12;
    return House(
      number: number,
      cusp: cusp,
      zodiacSign: _zodiacSigns[signIndex],
    );
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
/// Ketu is always 180 opposite to Rahu.
class KetuPosition {
  const KetuPosition({required this.rahuPosition});

  /// The planet position of Rahu used to calculate Ketu
  final PlanetPosition rahuPosition;

  /// Ketu's longitude (180 opposite to Rahu)
  double get longitude => (rahuPosition.longitude + 180) % 360;

  /// Ketu's latitude (opposite to Rahu)
  double get latitude => -rahuPosition.latitude;

  /// Ketu's distance (same as Rahu)
  double get distance => rahuPosition.distance;

  /// Ketu's speed (opposite to Rahu)
  double get longitudeSpeed => rahuPosition.longitudeSpeed;

  /// Ketu always moves retrograde (like Rahu)
  bool get isRetrograde => true;

  /// Gets the zodiac sign
  String get zodiacSign {
    final signIndex = (longitude / 30).floor() % 12;
    return _zodiacSigns[signIndex];
  }

  /// Gets position within the sign (0-30)
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
    return '${dms['degrees']} $zodiacSign ${dms['minutes']}\'';
  }

  /// Gets position in DMS within the sign
  Map<String, dynamic> get positionInSignDMS {
    final pos = positionInSign;
    final degrees = pos.floor();
    final minutesDecimal = (pos - degrees) * 60;
    final minutes = minutesDecimal.floor();
    final seconds = (minutesDecimal - minutes) * 60;

    return {'degrees': degrees, 'minutes': minutes, 'seconds': seconds};
  }

  /// DateTime of the calculation
  DateTime get dateTime => rahuPosition.dateTime;

  /// Converts this KetuPosition to a JSON map.
  Map<String, dynamic> toJson() => {
        'longitude': longitude,
        'latitude': latitude,
        'distance': distance,
        'longitudeSpeed': longitudeSpeed,
        'isRetrograde': isRetrograde,
        'zodiacSign': zodiacSign,
        'positionInSign': positionInSign,
        'nakshatra': nakshatra,
        'nakshatraPada': nakshatraPada,
      };

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

  /// Checks if the planet is in its Moola Trikona sign and degree range.
  bool get isMoolatrikona => dignity == PlanetaryDignity.moolaTrikona;

  /// Checks if the planet is within a specific orb (in degrees) of its deep exaltation degree (Param Uccha).
  bool isDeepExalted(double orb) {
    if (exaltationDegree == null) return false;
    final diff = ((longitude - exaltationDegree! + 540) % 360) - 180;
    return diff.abs() <= orb;
  }

  /// Checks if the planet is within a specific orb (in degrees) of its deep debilitation degree (Param Neecha).
  bool isDeepDebilitated(double orb) {
    if (debilitationDegree == null) return false;
    final diff = ((longitude - debilitationDegree! + 540) % 360) - 180;
    return diff.abs() <= orb;
  }

  /// Gets the combustion distance limit for this planet in degrees, taking retrograde status into account.
  /// Returns null for the Sun or if the planet has no defined combustion limit.
  double? get combustionDistance {
    if (planet == Planet.sun) return null;
    return switch (planet) {
      Planet.moon => 12.0,
      Planet.mercury => isRetrograde ? 12.0 : 14.0,
      Planet.venus => isRetrograde ? 8.0 : 10.0,
      Planet.mars => 17.0,
      Planet.jupiter => 11.0,
      Planet.saturn => 15.0,
      _ => null,
    };
  }

  /// Converts this VedicPlanetInfo to a JSON map.
  Map<String, dynamic> toJson() => {
        'planet': position.planet.displayName,
        'house': house,
        'dignity': dignity.english,
        'dignitySanskrit': dignity.sanskrit,
        'isCombust': isCombust,
        'exaltationDegree': exaltationDegree,
        'debilitationDegree': debilitationDegree,
        'position': position.toJson(),
      };
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
    this.calculationFlags,
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

  /// Flags used to calculate the chart (preserves ayanamsa choice).
  final CalculationFlags? calculationFlags;

  /// The [CalculationFlags] used to calculate this chart.
  ///
  /// Defaults to [CalculationFlags.traditionalist()] for charts created
  /// before the `system` field was introduced (backwards-compatible).
  CalculationFlags get flags =>
      calculationFlags ?? CalculationFlags.traditionalist();

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

  /// Converts this VedicChart to a JSON map.
  Map<String, dynamic> toJson() => {
        'dateTime': dateTime.toIso8601String(),
        'location': location,
        'latitude': latitude,
        'longitude': longitudeCoord,
        'ascendant': ascendant,
        'ascendantSign': ascendantSign,
        'houses': houses.toJson(),
        'planets': planets.map(
          (planet, info) => MapEntry(planet.displayName, info.toJson()),
        ),
        'rahu': rahu.toJson(),
        'ketu': ketu.toJson(),
      };

  /// Gets the zodiac sign index (0-11) for any planet in the chart.
  int? getPlanetSignIndex(Planet planet) {
    if (planet == Planet.ketu) {
      return (ketu.longitude / 30).floor() % 12;
    }
    final info = getPlanet(planet);
    if (info != null) {
      return info.position.zodiacSignIndex;
    }
    if (planet == Planet.meanNode || planet == Planet.trueNode) {
      return rahu.position.zodiacSignIndex;
    }
    return null;
  }

  /// Checks if a planet is Vargottama (occupies the same sign index in both this chart and the Navamsa D-9 chart).
  bool isVargottama(Planet planet) {
    final originalSignIndex = getPlanetSignIndex(planet);
    if (originalSignIndex == null) return false;

    final d9Chart = DivisionalChartService().calculateDivisionalChart(
      this,
      DivisionalChartType.d9,
    );
    final d9SignIndex = d9Chart.getPlanetSignIndex(planet);
    return originalSignIndex == d9SignIndex;
  }

  /// Gets the Vargottama status of a planet.
  VargottamaStatus getVargottamaStatus(Planet planet) {
    if (!isVargottama(planet)) {
      return VargottamaStatus.none;
    }

    final signIndex = getPlanetSignIndex(planet);
    if (signIndex == null) return VargottamaStatus.none;

    final exaltationSign = _exaltationSigns[planet];
    final debilitationSign = _debilitationSigns[planet];

    if (signIndex == exaltationSign) {
      return VargottamaStatus.ucchaVargottama;
    } else if (signIndex == debilitationSign) {
      return VargottamaStatus.neechaVargottama;
    }

    return VargottamaStatus.vargottama;
  }

  static const Map<Planet, int> _exaltationSigns = {
    Planet.sun: 0,
    Planet.moon: 1,
    Planet.mercury: 5,
    Planet.venus: 11,
    Planet.mars: 9,
    Planet.jupiter: 3,
    Planet.saturn: 6,
    Planet.meanNode: 2,
    Planet.trueNode: 2,
    Planet.ketu: 8,
  };

  static const Map<Planet, int> _debilitationSigns = {
    Planet.sun: 6,
    Planet.moon: 7,
    Planet.mercury: 11,
    Planet.venus: 5,
    Planet.mars: 3,
    Planet.jupiter: 9,
    Planet.saturn: 0,
    Planet.meanNode: 8,
    Planet.trueNode: 8,
    Planet.ketu: 2,
  };

  /// Returns the simplified compound relationship (Panchadha Maitri) between two planets.
  CompoundRelationship getCompoundRelationship(Planet planetA, Planet planetB) {
    final rel = PlanetaryRelationshipService().getRelationship(
      planetA,
      planetB,
      this,
    );
    return switch (rel.compound) {
      RelationshipType.greatFriend => CompoundRelationship.greatFriend,
      RelationshipType.friend => CompoundRelationship.friend,
      RelationshipType.neutral => CompoundRelationship.neutral,
      RelationshipType.enemy => CompoundRelationship.enemy,
      RelationshipType.greatEnemy => CompoundRelationship.greatEnemy,
    };
  }
}

/// The Vargottama status of a planet.
enum VargottamaStatus { none, vargottama, neechaVargottama, ucchaVargottama }

/// Represents an individual house in a Vedic chart.
class House {
  const House({
    required this.number,
    required this.cusp,
    required this.zodiacSign,
  });

  /// The house number (1-12)
  final int number;

  /// The cusp degree of this house (0-360)
  final double cusp;

  /// The zodiac sign name of the house cusp
  final String zodiacSign;

  /// Whether this house is a Kendra (angular house: 1, 4, 7, 10)
  bool get isKendra =>
      number == 1 || number == 4 || number == 7 || number == 10;

  /// Whether this house is a Trikona (trine house: 1, 5, 9)
  bool get isTrikona => number == 1 || number == 5 || number == 9;

  /// Whether this house is a Dusthana (difficult house: 6, 8, 12)
  bool get isDusthana => number == 6 || number == 8 || number == 12;

  /// Whether this house is an Upachaya (growing house: 3, 6, 10, 11)
  bool get isUpachaya =>
      number == 3 || number == 6 || number == 10 || number == 11;
}

typedef VedicHouse = House;
