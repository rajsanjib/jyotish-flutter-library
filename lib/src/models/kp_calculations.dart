import '../models/planet.dart';

/// Represents KP (Krishnamurti Paddhati) specific calculations.
///
/// KP astrology uses a specific ayanamsa (KP New VP291) and subdivides
/// zodiac signs into smaller divisions called Sub-Lords.
class KPCalculations {
  const KPCalculations({
    required this.ayanamsa,
    required this.planetDivisions,
    required this.houseDivisions,
    required this.planetSignificators,
  });

  /// The ayanamsa used for KP calculations
  final double ayanamsa;

  /// Sub-Lord divisions for all planets
  final Map<Planet, KPDivision> planetDivisions;

  /// Sub-Lord divisions for house cusps
  final Map<int, KPDivision> houseDivisions;

  /// ABCD significators for all planets
  final Map<Planet, KPSignificators> planetSignificators;

  /// Gets the Sub-Lord for a specific planet
  KPDivision? getPlanetSubLord(Planet planet) {
    return planetDivisions[planet];
  }

  /// Gets the Sub-Sub-Lord for a specific planet
  Planet? getPlanetSubSubLord(Planet planet) {
    return planetDivisions[planet]?.subSubLord;
  }

  /// Gets the Sub-Lord for a specific house cusp
  KPDivision? getHouseSubLord(int houseNumber) {
    return houseDivisions[houseNumber];
  }
}

/// Represents a KP division (Sign-Lord, Star-Lord, Sub-Lord, Sub-Sub-Lord).
class KPDivision {
  const KPDivision({
    required this.sign,
    required this.signLord,
    required this.star,
    required this.starLord,
    required this.subLord,
    this.subSubLord,
    required this.subStartLongitude,
    required this.subEndLongitude,
  });

  /// Sign number (1-12)
  final int sign;

  /// Sign Lord (owner of the sign)
  final Planet signLord;

  /// Star (Nakshatra) number (1-27)
  final int star;

  /// Star Lord (owner of the star)
  final Planet starLord;

  /// Sub-Lord (owner of the subdivision)
  final Planet subLord;

  /// Sub-Sub-Lord (owner of the sub-subdivision)
  final Planet? subSubLord;

  /// Starting longitude of the sub-division
  final double subStartLongitude;

  /// Ending longitude of the sub-division
  final double subEndLongitude;

  /// Gets the sign name
  String get signName => _zodiacSigns[sign - 1];

  /// Gets the star name
  String get starName => _nakshatras[star - 1];

  /// Gets the span of the sub-division in degrees
  double get subSpan => subEndLongitude - subStartLongitude;

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

/// KP Significators (ABCD significators).
///
/// In KP astrology, planets signify houses through:
/// - A: Houses occupied by the planet's sign lord
/// - B: Houses occupied by the planet's star lord
/// - C: Houses owned by the planet itself
/// - D: Houses owned by the planet's sign lord
class KPSignificators {
  const KPSignificators({
    required this.planet,
    required this.aSignificators,
    required this.bSignificators,
    required this.cSignificators,
    required this.dSignificators,
  });

  /// The planet
  final Planet planet;

  /// A significators (houses occupied by sign lord)
  final List<int> aSignificators;

  /// B significators (houses occupied by star lord)
  final List<int> bSignificators;

  /// C significators (houses owned by the planet)
  final List<int> cSignificators;

  /// D significators (houses owned by sign lord)
  final List<int> dSignificators;

  /// Gets all significators (A + B + C + D)
  List<int> get allSignificators {
    final all = <int>[
      ...aSignificators,
      ...bSignificators,
      ...cSignificators,
      ...dSignificators,
    ];
    return all.toSet().toList()..sort();
  }

  /// Checks if the planet signifies a specific house
  bool signifies(int house) {
    return allSignificators.contains(house);
  }

  /// Gets significators by category
  Map<String, List<int>> get significatorMap => {
        'A': aSignificators,
        'B': bSignificators,
        'C': cSignificators,
        'D': dSignificators,
      };
}

/// KP House grouping significators.
class KPHouseGroupSignificators {
  const KPHouseGroupSignificators({
    required this.selfSignificators,
    required this.wealthSignificators,
    required this.careerSignificators,
    required this.marriageSignificators,
    required this.childrenSignificators,
    required this.healthSignificators,
  });

  /// Houses that signify the self (1, 2, 3)
  final List<Planet> selfSignificators;

  /// Houses that signify wealth (2, 6, 11)
  final List<Planet> wealthSignificators;

  /// Houses that signify career (2, 6, 10, 11)
  final List<Planet> careerSignificators;

  /// Houses that signify marriage (2, 7, 11)
  final List<Planet> marriageSignificators;

  /// Houses that signify children (2, 5, 11)
  final List<Planet> childrenSignificators;

  /// Houses that signify health (1, 5, 11)
  final List<Planet> healthSignificators;
}

/// KP Constants for Vimshottari Dasha periods (in years).
class KPDashaPeriods {
  static const Map<Planet, double> vimshottariYears = {
    Planet.sun: 6,
    Planet.moon: 10,
    Planet.mars: 7,
    Planet.mercury: 17,
    Planet.jupiter: 16,
    Planet.venus: 20,
    Planet.saturn: 19,
    Planet.meanNode: 18, // Rahu
  };

  /// Gets dasha period for a planet
  static double getPeriod(Planet planet) {
    if (planet == Planet.meanNode || planet == Planet.trueNode) {
      return vimshottariYears[Planet.meanNode]!;
    }
    return vimshottariYears[planet] ?? 0;
  }
}

/// Planet ownership and rulership for KP calculations.
class KPPlanetOwnership {
  /// Gets the planet that owns a specific sign
  static Planet getSignLord(int sign) {
    switch (sign) {
      case 1: // Aries
        return Planet.mars;
      case 2: // Taurus
        return Planet.venus;
      case 3: // Gemini
        return Planet.mercury;
      case 4: // Cancer
        return Planet.moon;
      case 5: // Leo
        return Planet.sun;
      case 6: // Virgo
        return Planet.mercury;
      case 7: // Libra
        return Planet.venus;
      case 8: // Scorpio
        return Planet.mars;
      case 9: // Sagittarius
        return Planet.jupiter;
      case 10: // Capricorn
        return Planet.saturn;
      case 11: // Aquarius
        return Planet.saturn;
      case 12: // Pisces
        return Planet.jupiter;
      default:
        throw ArgumentError('Invalid sign number: $sign');
    }
  }

  /// Gets the planet that owns a specific star (nakshatra)
  static Planet getStarLord(int star) {
    // Stars are owned by planets in cycles of 9
    // Ketu, Venus, Sun, Moon, Mars, Rahu, Jupiter, Saturn, Mercury
    final starLords = [
      Planet.ketu,
      Planet.venus,
      Planet.sun,
      Planet.moon,
      Planet.mars,
      Planet.meanNode, // Rahu
      Planet.jupiter,
      Planet.saturn,
      Planet.mercury,
    ];

    final index = (star - 1) % 9;
    return starLords[index];
  }

  /// Gets houses owned by a planet in a natural zodiac (Aries Lagna)
  static List<int> getOwnedHouses(Planet planet) {
    switch (planet) {
      case Planet.sun:
        return [5]; // Leo
      case Planet.moon:
        return [4]; // Cancer
      case Planet.mars:
        return [1, 8]; // Aries, Scorpio
      case Planet.mercury:
        return [3, 6]; // Gemini, Virgo
      case Planet.jupiter:
        return [9, 12]; // Sagittarius, Pisces
      case Planet.venus:
        return [2, 7]; // Taurus, Libra
      case Planet.saturn:
        return [10, 11]; // Capricorn, Aquarius
      case Planet.meanNode:
      case Planet.trueNode:
        return []; // Nodes don't own houses
      default:
        return [];
    }
  }
}
