import 'planet.dart';

/// Result of Sudarshan Chakra strength analysis.
///
/// Sudarshan Chakra evaluates houses and planets from three perspectives:
/// 1. Lagna (Ascendant) - The rising sign at birth
/// 2. Chandra (Moon) - The Moon's sign position
/// 3. Surya (Sun) - The Sun's sign position
///
/// A house or planet is considered strong if it holds favorable positions
/// across all three reference points.
class SudarshanChakraResult {
  const SudarshanChakraResult({
    required this.houseStrengths,
    required this.planetStrengths,
    required this.lagnaSign,
    required this.chandraSign,
    required this.suryaSign,
  });

  /// Strength analysis for each of the 12 houses (keys 1-12)
  final Map<int, SudarshanHouseStrength> houseStrengths;

  /// Strength analysis for each planet
  final Map<Planet, SudarshanPlanetStrength> planetStrengths;

  /// The Lagna (Ascendant) sign index (0-11)
  final int lagnaSign;

  /// The Chandra (Moon) sign index (0-11)
  final int chandraSign;

  /// The Surya (Sun) sign index (0-11)
  final int suryaSign;

  /// Gets the overall chart strength as a percentage (0-100).
  double get overallStrength {
    if (houseStrengths.isEmpty) return 0.0;
    final totalHouseStrength =
        houseStrengths.values.fold(0.0, (sum, h) => sum + h.combinedScore);
    return totalHouseStrength / 12.0;
  }

  /// Gets a list of houses that are strong in all three perspectives.
  List<int> get strongHouses => houseStrengths.entries
      .where((e) =>
          e.value.category == SudarshanStrengthCategory.excellent ||
          e.value.category == SudarshanStrengthCategory.good)
      .map((e) => e.key)
      .toList();

  /// Gets a list of houses that are weak in all three perspectives.
  List<int> get weakHouses => houseStrengths.entries
      .where((e) =>
          e.value.category == SudarshanStrengthCategory.weak ||
          e.value.category == SudarshanStrengthCategory.veryWeak)
      .map((e) => e.key)
      .toList();

  @override
  String toString() {
    return 'SudarshanChakraResult(overallStrength: ${overallStrength.toStringAsFixed(1)}%, '
        'strongHouses: $strongHouses, weakHouses: $weakHouses)';
  }
}

/// Combined strength for a single house across all 3 lagnas.
class SudarshanHouseStrength {
  const SudarshanHouseStrength({
    required this.houseNumber,
    required this.lagnaHouse,
    required this.chandraHouse,
    required this.suryaHouse,
    required this.combinedScore,
    required this.category,
  });

  /// The house number being analyzed (1-12)
  final int houseNumber;

  /// This house's position when viewed from Lagna (1-12)
  final int lagnaHouse;

  /// This house's position when viewed from Moon sign (1-12)
  final int chandraHouse;

  /// This house's position when viewed from Sun sign (1-12)
  final int suryaHouse;

  /// Combined strength score (0-100)
  final double combinedScore;

  /// Strength category based on combined score
  final SudarshanStrengthCategory category;

  /// Whether this house is a Kendra (1, 4, 7, 10) in at least one view
  bool get hasKendraPlacement =>
      _isKendra(lagnaHouse) || _isKendra(chandraHouse) || _isKendra(suryaHouse);

  /// Whether this house is a Trikona (1, 5, 9) in at least one view
  bool get hasTrikonaPlacement =>
      _isTrikona(lagnaHouse) ||
      _isTrikona(chandraHouse) ||
      _isTrikona(suryaHouse);

  bool _isKendra(int house) => [1, 4, 7, 10].contains(house);
  bool _isTrikona(int house) => [1, 5, 9].contains(house);

  @override
  String toString() {
    return 'House $houseNumber: Lagna=$lagnaHouse, Chandra=$chandraHouse, '
        'Surya=$suryaHouse (${combinedScore.toStringAsFixed(1)}%, ${category.name})';
  }
}

/// Combined strength for a single planet across all 3 lagnas.
class SudarshanPlanetStrength {
  const SudarshanPlanetStrength({
    required this.planet,
    required this.lagnaPlacement,
    required this.chandraPlacement,
    required this.suryaPlacement,
    required this.combinedScore,
    required this.category,
  });

  /// The planet being analyzed
  final Planet planet;

  /// The planet's house when viewed from Lagna (1-12)
  final int lagnaPlacement;

  /// The planet's house when viewed from Moon sign (1-12)
  final int chandraPlacement;

  /// The planet's house when viewed from Sun sign (1-12)
  final int suryaPlacement;

  /// Combined strength score (0-100)
  final double combinedScore;

  /// Strength category based on combined score
  final SudarshanStrengthCategory category;

  /// Whether this planet is in a Kendra (1, 4, 7, 10) from all three views
  bool get isInKendraFromAll =>
      _isKendra(lagnaPlacement) &&
      _isKendra(chandraPlacement) &&
      _isKendra(suryaPlacement);

  /// Whether this planet is in a Dusthana (6, 8, 12) in any view
  bool get isInDusthanaFromAny =>
      _isDusthana(lagnaPlacement) ||
      _isDusthana(chandraPlacement) ||
      _isDusthana(suryaPlacement);

  bool _isKendra(int house) => [1, 4, 7, 10].contains(house);
  bool _isDusthana(int house) => [6, 8, 12].contains(house);

  @override
  String toString() {
    return '${planet.displayName}: Lagna=$lagnaPlacement, Chandra=$chandraPlacement, '
        'Surya=$suryaPlacement (${combinedScore.toStringAsFixed(1)}%, ${category.name})';
  }
}

/// Sudarshan Chakra strength categories.
enum SudarshanStrengthCategory {
  /// Score 80-100: Strong in multiple perspectives
  excellent('Excellent', 80, 100),

  /// Score 60-80: Good overall placement
  good('Good', 60, 80),

  /// Score 40-60: Mixed results
  moderate('Moderate', 40, 60),

  /// Score 20-40: Weak in some perspectives
  weak('Weak', 20, 40),

  /// Score 0-20: Weak in most/all perspectives
  veryWeak('Very Weak', 0, 20);

  const SudarshanStrengthCategory(this.name, this.minScore, this.maxScore);

  final String name;
  final double minScore;
  final double maxScore;

  /// Gets the category for a given score.
  static SudarshanStrengthCategory fromScore(double score) {
    if (score >= 80) return excellent;
    if (score >= 60) return good;
    if (score >= 40) return moderate;
    if (score >= 20) return weak;
    return veryWeak;
  }
}
