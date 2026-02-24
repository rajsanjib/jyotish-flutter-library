import '../models/planet.dart';
import '../models/vedic_chart.dart';

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

/// Represents a row in the KP 249-Division table.
class KPDivisionEntry {
  const KPDivisionEntry({
    required this.index,
    required this.sign,
    required this.signLord,
    required this.star,
    required this.starLord,
    required this.subLord,
    this.subSubLord,
    required this.startLongitude,
    required this.endLongitude,
  });

  /// The division index (1 to 249)
  final int index;
  final int sign;
  final Planet signLord;
  final int star;
  final Planet starLord;
  final Planet subLord;
  final Planet? subSubLord;
  final double startLongitude;
  final double endLongitude;
  
  /// Formats longitude to DMS string
  String get startDms {
    final d = startLongitude.floor();
    final m = ((startLongitude - d) * 60).floor();
    final s = (((startLongitude - d) * 60 - m) * 60).round();
    return '$d° $m\' $s"';
  }
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

  /// Gets houses owned by a planet using the **chart's actual Placidus cusps**.
  ///
  /// This is the correct KP approach: the owned houses depend on which signs
  /// occupy which houses in this particular chart, not the natural Aries Lagna.
  ///
  /// For example, if Mars rules Aries (house 1) and Scorpio (house 8) in a natural
  /// chart but in the queried chart Aries is the 5th house and Scorpio is the 12th,
  /// this method returns [5, 12].
  ///
  /// [planet] - The planet whose owned houses are sought.
  /// [chart]  - The Vedic birth chart with Placidus house cusps.
  static List<int> getOwnedHousesFromChart(Planet planet, VedicChart chart) {
    // Get the two signs owned by the planet (Aries Lagna numbering 1–12)
    final naturalHouses = getOwnedHouses(planet);
    if (naturalHouses.isEmpty) return [];

    final ownedHouseNumbers = <int>[];

    for (final naturalHouseNo in naturalHouses) {
      // The sign number (1-based, Aries=1) of the planet's owned sign
      final signNumber = _naturalHouseToSignNumber(naturalHouseNo);

      // Walk through the chart's 12 cusps to find which house starts in that sign
      for (var h = 1; h <= 12; h++) {
        final cuspLongitude = chart.houses.cusps[h - 1];
        final cuspSignNumber = (cuspLongitude / 30).floor() + 1;
        if (cuspSignNumber == signNumber) {
          ownedHouseNumbers.add(h);
          break;
        }
      }
    }

    return ownedHouseNumbers..sort();
  }

  /// Maps a natural-zodiac house number (Aries Lagna) to a sign number (1=Aries).
  static int _naturalHouseToSignNumber(int naturalHouseNo) {
    // In an Aries Lagna chart, house N = sign N (Aries=1, Taurus=2, …)
    return naturalHouseNo;
  }

  /// Gets houses owned by a planet in a natural zodiac (Aries Lagna).
  ///
  /// **Prefer [getOwnedHousesFromChart] for real chart analysis.**
  /// This method returns fixed sign ownership, useful only when no chart is
  /// available (e.g. natural-strength tables).
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

// ============================================================
// KP TRANSIT COMPARISON
// ============================================================

/// Compares a planet's KP transit division against its natal division.
///
/// Used in KP Prashna and transit prediction: when a transiting planet's
/// Sub-Lord matches the natal Sub-Lord (or signifies the same houses), the
/// event is more likely to materialise.
class KPTransitComparison {
  const KPTransitComparison({
    required this.planet,
    required this.transitDivision,
    required this.natalDivision,
    required this.starLordMatches,
    required this.subLordMatches,
    required this.commonNatalSignificators,
  });

  /// The planet being compared.
  final Planet planet;

  /// KP division of the planet at the transit moment.
  final KPDivision transitDivision;

  /// KP division of the same planet at birth.
  final KPDivision natalDivision;

  /// True if the transit Star-Lord equals the natal Star-Lord.
  final bool starLordMatches;

  /// True if the transit Sub-Lord equals the natal Sub-Lord.
  ///
  /// A Sub-Lord match is the primary KP trigger for event activation.
  final bool subLordMatches;

  /// Houses that both the natal and transit divisions signify together.
  ///
  /// The more houses overlap, the stronger the correlation.
  final List<int> commonNatalSignificators;

  /// True if this transit is considered "active" in KP terms.
  ///
  /// Active = the transit Sub-Lord or Star-Lord matches the natal side,
  /// or there is at least one common house significator.
  bool get isActive =>
      subLordMatches || starLordMatches || commonNatalSignificators.isNotEmpty;

  /// Strength indicator (0–3): counts how many of the three triggers fire.
  int get matchStrength =>
      (subLordMatches ? 1 : 0) +
      (starLordMatches ? 1 : 0) +
      (commonNatalSignificators.isNotEmpty ? 1 : 0);

  @override
  String toString() => '$planet: subLord ${subLordMatches ? "✓" : "✗"} '
      'starLord ${starLordMatches ? "✓" : "✗"} '
      'commonHouses=$commonNatalSignificators';
}

// ============================================================
// KP RULING PLANETS
// ============================================================

/// The seven Ruling Planets (RP) at the moment of a KP Prashna query.
///
/// In KP, at the exact moment a query is made, the following points are read
/// from the chart and their Sign/Star/Sub lords are the Ruling Planets:
///
/// 1. **Day Lord** – the planet that rules the weekday.
/// 2. **Ascendant Sign Lord** – sign lord of the rising degree.
/// 3. **Ascendant Star Lord** – nakshatra lord of the rising degree.
/// 4. **Ascendant Sub Lord** – KP sub-lord of the rising degree.
/// 5. **Moon Sign Lord** – sign lord of the Moon at query time.
/// 6. **Moon Star Lord** – nakshatra lord of the Moon.
/// 7. **Moon Sub Lord** – KP sub-lord of the Moon.
///
/// Duplicates are removed; the set is returned in priority order.
class KPRulingPlanets {
  const KPRulingPlanets({
    required this.dayLord,
    required this.ascendantSignLord,
    required this.ascendantStarLord,
    required this.ascendantSubLord,
    required this.moonSignLord,
    required this.moonStarLord,
    required this.moonSubLord,
    required this.queryDateTime,
    required this.ascendantDivision,
    required this.moonDivision,
  });

  /// Weekday planet lord (Sun=Sun, Mon=Moon, Tue=Mars, …).
  final Planet dayLord;

  /// Sign lord of the Ascendant at the query moment.
  final Planet ascendantSignLord;

  /// Nakshatra lord of the Ascendant.
  final Planet ascendantStarLord;

  /// KP Sub-Lord of the Ascendant.
  final Planet ascendantSubLord;

  /// Sign lord of the Moon's longitude.
  final Planet moonSignLord;

  /// Nakshatra lord of the Moon.
  final Planet moonStarLord;

  /// KP Sub-Lord of the Moon.
  final Planet moonSubLord;

  /// The date/time at which these RPs were computed.
  final DateTime queryDateTime;

  /// Full KP division of the Ascendant degree.
  final KPDivision ascendantDivision;

  /// Full KP division of the Moon.
  final KPDivision moonDivision;

  /// All seven Ruling Planets in priority order, deduplicated.
  ///
  /// Priority: Day Lord → Asc Sign Lord → Asc Star Lord → Asc Sub Lord →
  ///           Moon Sign Lord → Moon Star Lord → Moon Sub Lord.
  List<Planet> get rulingPlanets {
    final seen = <Planet>{};
    final result = <Planet>[];
    for (final p in [
      dayLord,
      ascendantSignLord,
      ascendantStarLord,
      ascendantSubLord,
      moonSignLord,
      moonStarLord,
      moonSubLord,
    ]) {
      if (seen.add(p)) result.add(p);
    }
    return result;
  }

  @override
  String toString() => 'KP Ruling Planets (${queryDateTime.toLocal()}): '
      '${rulingPlanets.map((p) => p.name).join(', ')}';
}
