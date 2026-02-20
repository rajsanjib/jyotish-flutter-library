import '../models/planet.dart';
import '../models/vedic_chart.dart';

/// Represents the Ashtakavarga (eightfold division) system.
///
/// Ashtakavarga is a system of evaluating planetary strength
/// by counting benefic points (bindus) contributed by each planet
/// in each sign of the zodiac.
class Ashtakavarga {
  const Ashtakavarga({
    required this.natalChart,
    required this.bhinnashtakavarga,
    required this.sarvashtakavarga,
    required this.samudayaAshtakavarga,
  });

  /// Birth chart used for calculations
  final VedicChart natalChart;

  /// Bhinnashtakavarga for each planet
  final Map<Planet, Bhinnashtakavarga> bhinnashtakavarga;

  /// Sarvashtakavarga (total points per house)
  final Sarvashtakavarga sarvashtakavarga;

  /// Samudaya Ashtakavarga (total for all planets)
  final List<int> samudayaAshtakavarga;

  /// Gets the total bindus for a specific house (1-12)
  int getTotalBindusForHouse(int houseNumber) {
    if (houseNumber < 1 || houseNumber > 12) {
      throw ArgumentError('House number must be between 1 and 12');
    }
    return sarvashtakavarga.bindus[houseNumber - 1];
  }

  /// Gets the total bindus for a specific sign (0=Aries, 11=Pisces)
  int getTotalBindusForSign(int signIndex) {
    if (signIndex < 0 || signIndex > 11) {
      throw ArgumentError('Sign index must be between 0 and 11');
    }
    return sarvashtakavarga.bindus[signIndex];
  }

  /// Checks if a house has more than 28 bindus (favorable)
  bool isHouseFavorable(int houseNumber) {
    return getTotalBindusForHouse(houseNumber) > 28;
  }

  /// Checks if a sign has more than 28 bindus (favorable for transits)
  bool isSignFavorableForTransits(int signIndex) {
    return getTotalBindusForSign(signIndex) > 28;
  }

  /// Gets the prastara ashtakavarga (contribution breakdown)
  Map<Planet, List<int>> get prastaraAshtakavarga {
    final result = <Planet, List<int>>{};
    for (final entry in bhinnashtakavarga.entries) {
      result[entry.key] = entry.value.contributions;
    }
    return result;
  }
}

/// Bhinnashtakavarga for a single planet.
///
/// Contains the bindus (points) contributed by each of the 7 planets
/// plus ascendant in each of the 12 signs.
class Bhinnashtakavarga {
  const Bhinnashtakavarga({
    required this.planet,
    required this.bindus,
    required this.contributions,
  });

  /// The planet this Ashtakavarga belongs to
  final Planet planet;

  /// Number of bindus in each sign (0-8)
  final List<int> bindus;

  /// Detailed contributions (which planets contribute to each sign)
  /// Each element is a bitmask of contributing planets
  final List<int> contributions;

  /// Gets bindus for a specific sign (0=Aries, 11=Pisces)
  int getBindusForSign(int signIndex) {
    if (signIndex < 0 || signIndex > 11) {
      throw ArgumentError('Sign index must be between 0 and 11');
    }
    return bindus[signIndex];
  }

  /// Gets contributing planets for a specific sign
  List<Planet> getContributingPlanetsForSign(int signIndex) {
    if (signIndex < 0 || signIndex > 11) {
      throw ArgumentError('Sign index must be between 0 and 11');
    }

    final contribution = contributions[signIndex];
    final result = <Planet>[];
    final contributingPlanets = [
      Planet.sun,
      Planet.moon,
      Planet.mars,
      Planet.mercury,
      Planet.jupiter,
      Planet.venus,
      Planet.saturn,
    ];

    for (var i = 0; i < contributingPlanets.length; i++) {
      if (contribution & (1 << i) != 0) {
        result.add(contributingPlanets[i]);
      }
    }

    return result;
  }

  /// Total bindus for this planet (should be between 0-337)
  int get totalBindus => bindus.fold(0, (sum, b) => sum + b);
}

/// Sarvashtakavarga (cumulative Ashtakavarga).
///
/// Contains the total bindus contributed by all planets
/// in each of the 12 signs.
class Sarvashtakavarga {
  const Sarvashtakavarga({required this.bindus});

  /// Total bindus in each sign (0-11)
  final List<int> bindus;

  /// Total bindus across all signs (should be between 0-337)
  int get total => bindus.fold(0, (sum, b) => sum + b);

  /// Average bindus per sign
  double get average => total / 12;

  /// Gets the sign with maximum bindus
  int get strongestSign {
    var maxIndex = 0;
    for (var i = 1; i < 12; i++) {
      if (bindus[i] > bindus[maxIndex]) {
        maxIndex = i;
      }
    }
    return maxIndex;
  }

  /// Gets the sign with minimum bindus
  int get weakestSign {
    var minIndex = 0;
    for (var i = 1; i < 12; i++) {
      if (bindus[i] < bindus[minIndex]) {
        minIndex = i;
      }
    }
    return minIndex;
  }

  /// Gets favorable signs (more than 28 bindus)
  List<int> get favorableSigns {
    return List.generate(12, (i) => i).where((i) => bindus[i] > 28).toList();
  }

  /// Gets unfavorable signs (28 or fewer bindus)
  List<int> get unfavorableSigns {
    return List.generate(12, (i) => i).where((i) => bindus[i] <= 28).toList();
  }
}

/// Ashtakavarga transit analysis.
class AshtakavargaTransit {
  const AshtakavargaTransit({
    required this.transitDate,
    required this.transitPlanet,
    required this.transitSign,
    required this.bindus,
    required this.isFavorable,
    required this.strengthScore,
  });

  /// Transit date
  final DateTime transitDate;

  /// Planet in transit
  final Planet transitPlanet;

  /// Sign being transited (0-11)
  final int transitSign;

  /// Bindus in that sign for the transiting planet
  final int bindus;

  /// Whether this is a favorable transit (> 28 total bindus in Sarvashtakavarga)
  final bool isFavorable;

  /// A normalized strength score (0-100) representing the relative
  /// auspiciousness of the transit based on bindu counts.
  final int strengthScore;
}

/// Ashtakavarga table constants.
///
/// These tables define which planets contribute bindus (1)
/// in which signs from the perspective of each planet.
class AshtakavargaTables {
  // Contribution tables for each planet
  // Each row represents a sign (0=Aries, 11=Pisces)
  // Each column represents contributing planet (Sun, Moon, Mars, Mercury, Jupiter, Venus, Saturn)
  // 1 = contributes bindu, 0 = does not contribute

  /// Sun's Ashtakavarga contributions (standard Parashari)
  /// Columns: Sun, Moon, Mars, Mercury, Jupiter, Venus, Saturn
  /// Jupiter contributes to Sun in houses: 1, 4, 5, 6, 9, 10, 11
  static const List<List<int>> sunTable = [
    // Su Mo Ma Me Ju Ve Sa
    [1, 0, 1, 0, 1, 0, 0], // Aries (1st from Sun)
    [1, 0, 0, 1, 0, 1, 0], // Taurus (2nd from Sun)
    [0, 1, 0, 1, 0, 0, 1], // Gemini (3rd from Sun)
    [1, 0, 1, 0, 1, 0, 0], // Cancer (4th from Sun)
    [0, 1, 0, 0, 1, 1, 0], // Leo (5th from Sun) - Jupiter contributes
    [0, 0, 0, 1, 1, 0, 1], // Virgo (6th from Sun) - Jupiter contributes
    [1, 1, 0, 0, 1, 1, 0], // Libra (7th from Sun)
    [1, 0, 1, 0, 0, 0, 0], // Scorpio (8th from Sun)
    [1, 0, 0, 1, 1, 0, 1], // Sagittarius (9th from Sun) - Jupiter contributes
    [1, 1, 0, 0, 1, 1, 0], // Capricorn (10th from Sun) - Jupiter contributes
    [1, 0, 1, 0, 1, 0, 1], // Aquarius (11th from Sun) - Jupiter contributes
    [0, 1, 0, 1, 0, 0, 0], // Pisces (12th from Sun)
  ];

  /// Moon's Ashtakavarga contributions
  static const List<List<int>> moonTable = [
    [0, 1, 0, 0, 1, 0, 0], // Aries
    [0, 0, 0, 0, 1, 1, 0], // Taurus
    [0, 0, 0, 1, 0, 0, 1], // Gemini
    [0, 1, 0, 0, 1, 0, 0], // Cancer
    [0, 0, 0, 0, 1, 1, 0], // Leo
    [1, 0, 0, 1, 0, 0, 1], // Virgo
    [1, 1, 0, 0, 1, 0, 0], // Libra
    [0, 0, 0, 0, 1, 0, 0], // Scorpio
    [0, 0, 0, 1, 0, 0, 1], // Sagittarius
    [0, 1, 0, 0, 0, 1, 0], // Capricorn
    [0, 0, 1, 0, 0, 0, 1], // Aquarius
    [0, 1, 0, 1, 0, 0, 0], // Pisces
  ];

  /// Mars' Ashtakavarga contributions
  static const List<List<int>> marsTable = [
    [1, 0, 1, 0, 1, 0, 0], // Aries
    [0, 0, 0, 1, 0, 1, 0], // Taurus
    [0, 1, 0, 1, 0, 0, 1], // Gemini
    [1, 0, 1, 0, 1, 0, 0], // Cancer
    [0, 1, 1, 0, 1, 1, 0], // Leo
    [0, 0, 0, 1, 0, 0, 1], // Virgo
    [0, 1, 0, 0, 1, 1, 0], // Libra
    [1, 0, 1, 0, 1, 0, 0], // Scorpio
    [0, 0, 0, 1, 0, 0, 1], // Sagittarius
    [0, 1, 0, 0, 0, 1, 0], // Capricorn
    [0, 0, 1, 0, 0, 0, 1], // Aquarius
    [1, 1, 0, 1, 0, 0, 0], // Pisces
  ];

  /// Mercury's Ashtakavarga contributions
  static const List<List<int>> mercuryTable = [
    [1, 0, 0, 1, 1, 0, 0], // Aries
    [0, 0, 0, 1, 0, 1, 0], // Taurus
    [0, 1, 0, 1, 0, 0, 1], // Gemini
    [1, 0, 0, 1, 1, 0, 0], // Cancer
    [0, 1, 0, 1, 1, 1, 0], // Leo
    [1, 0, 0, 1, 0, 0, 1], // Virgo
    [0, 1, 0, 1, 1, 1, 0], // Libra
    [1, 0, 0, 1, 1, 0, 0], // Scorpio
    [0, 0, 0, 1, 0, 0, 1], // Sagittarius
    [0, 1, 0, 1, 0, 1, 0], // Capricorn
    [0, 0, 0, 1, 0, 0, 1], // Aquarius
    [1, 1, 0, 1, 0, 0, 0], // Pisces
  ];

  /// Jupiter's Ashtakavarga contributions
  static const List<List<int>> jupiterTable = [
    [1, 0, 1, 0, 1, 0, 0], // Aries
    [0, 0, 0, 0, 1, 1, 0], // Taurus
    [0, 1, 0, 1, 1, 0, 1], // Gemini
    [1, 0, 1, 0, 1, 0, 0], // Cancer
    [0, 1, 1, 0, 1, 1, 0], // Leo
    [0, 0, 0, 0, 1, 0, 1], // Virgo
    [0, 1, 0, 0, 1, 1, 0], // Libra
    [1, 0, 1, 0, 1, 0, 0], // Scorpio
    [0, 0, 0, 1, 1, 0, 1], // Sagittarius
    [0, 1, 0, 0, 0, 1, 0], // Capricorn
    [0, 0, 1, 0, 0, 0, 1], // Aquarius
    [1, 1, 0, 0, 1, 0, 0], // Pisces
  ];

  /// Venus' Ashtakavarga contributions
  static const List<List<int>> venusTable = [
    [0, 0, 0, 0, 1, 1, 0], // Aries
    [0, 0, 0, 0, 1, 1, 0], // Taurus
    [0, 0, 0, 1, 0, 0, 1], // Gemini
    [0, 0, 0, 0, 1, 1, 0], // Cancer
    [0, 1, 0, 0, 1, 1, 0], // Leo
    [1, 0, 0, 1, 0, 0, 1], // Virgo
    [1, 1, 0, 0, 1, 1, 0], // Libra
    [0, 0, 0, 0, 1, 1, 0], // Scorpio
    [0, 0, 0, 1, 0, 0, 1], // Sagittarius
    [0, 1, 0, 0, 0, 1, 0], // Capricorn
    [0, 0, 1, 0, 0, 0, 1], // Aquarius
    [0, 1, 0, 0, 1, 1, 0], // Pisces
  ];

  /// Saturn's Ashtakavarga contributions
  static const List<List<int>> saturnTable = [
    [0, 0, 1, 0, 0, 0, 1], // Aries
    [0, 0, 0, 1, 0, 0, 1], // Taurus
    [0, 0, 0, 1, 0, 0, 1], // Gemini
    [0, 0, 1, 0, 0, 0, 1], // Cancer
    [0, 1, 1, 0, 0, 0, 1], // Leo
    [1, 0, 0, 1, 0, 0, 1], // Virgo
    [0, 1, 0, 0, 0, 0, 1], // Libra
    [0, 0, 1, 0, 0, 0, 1], // Scorpio
    [0, 0, 0, 1, 0, 0, 1], // Sagittarius
    [0, 1, 0, 0, 0, 1, 1], // Capricorn
    [0, 0, 1, 0, 0, 0, 1], // Aquarius
    [1, 1, 0, 1, 0, 0, 1], // Pisces
  ];

  /// Gets the contribution table for a specific planet
  static List<List<int>> getTableForPlanet(Planet planet) {
    switch (planet) {
      case Planet.sun:
        return sunTable;
      case Planet.moon:
        return moonTable;
      case Planet.mars:
        return marsTable;
      case Planet.mercury:
        return mercuryTable;
      case Planet.jupiter:
        return jupiterTable;
      case Planet.venus:
        return venusTable;
      case Planet.saturn:
        return saturnTable;
      default:
        throw ArgumentError('Ashtakavarga not defined for $planet');
    }
  }
}
