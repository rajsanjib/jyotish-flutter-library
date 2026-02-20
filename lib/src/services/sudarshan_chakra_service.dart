import '../models/planet.dart';
import '../models/sudarshan_chakra.dart';
import '../models/vedic_chart.dart';

/// Service for calculating Sudarshan Chakra strength.
///
/// Sudarshan Chakra is a three-fold analysis that examines houses and planets
/// from three reference points:
/// 1. Lagna (Ascendant) - Traditional house positions
/// 2. Chandra Lagna (Moon) - Houses counted from Moon's sign
/// 3. Surya Lagna (Sun) - Houses counted from Sun's sign
///
/// A result is considered strong when favorable across all three perspectives.
class SudarshanChakraService {
  /// Calculates Sudarshan Chakra strength for a Vedic chart.
  ///
  /// [chart] - The calculated Vedic birth chart
  ///
  /// Returns a [SudarshanChakraResult] containing strength analysis
  /// for all 12 houses and all planets.
  SudarshanChakraResult calculateSudarshanChakra(VedicChart chart) {
    // Get the three reference signs (0-11 index)
    final lagnaSign = (chart.houses.ascendant / 30).floor() % 12;

    final moonInfo = chart.getPlanet(Planet.moon);
    final sunInfo = chart.getPlanet(Planet.sun);

    final chandraSign =
        moonInfo != null ? (moonInfo.longitude / 30).floor() % 12 : lagnaSign;
    final suryaSign =
        sunInfo != null ? (sunInfo.longitude / 30).floor() % 12 : lagnaSign;

    // Calculate house strengths
    final houseStrengths = <int, SudarshanHouseStrength>{};
    for (var house = 1; house <= 12; house++) {
      houseStrengths[house] = _calculateHouseStrength(
        houseNumber: house,
        lagnaSign: lagnaSign,
        chandraSign: chandraSign,
        suryaSign: suryaSign,
      );
    }

    // Calculate planet strengths
    final planetStrengths = <Planet, SudarshanPlanetStrength>{};
    for (final planet in Planet.traditionalPlanets) {
      final planetInfo = chart.getPlanet(planet);
      if (planetInfo != null) {
        planetStrengths[planet] = _calculatePlanetStrength(
          planet: planet,
          planetHouse: planetInfo.house,
          lagnaSign: lagnaSign,
          chandraSign: chandraSign,
          suryaSign: suryaSign,
          chart: chart,
        );
      }
    }

    return SudarshanChakraResult(
      houseStrengths: houseStrengths,
      planetStrengths: planetStrengths,
      lagnaSign: lagnaSign,
      chandraSign: chandraSign,
      suryaSign: suryaSign,
    );
  }

  /// Calculates the strength of a house from all three perspectives.
  SudarshanHouseStrength _calculateHouseStrength({
    required int houseNumber,
    required int lagnaSign,
    required int chandraSign,
    required int suryaSign,
  }) {
    // House number from each lagna (1-12)
    // The house number stays the same from Lagna perspective
    final lagnaHouse = houseNumber;

    // From Chandra Lagna: we need to find what house this becomes
    // If Moon is in sign X, then sign X becomes the 1st house from Moon
    // The original house N from Lagna corresponds to sign (lagnaSign + N - 1) % 12
    // From Moon's perspective, that sign becomes house ((sign - chandraSign + 12) % 12) + 1
    final houseSign = (lagnaSign + houseNumber - 1) % 12;
    final chandraHouse = ((houseSign - chandraSign + 12) % 12) + 1;
    final suryaHouse = ((houseSign - suryaSign + 12) % 12) + 1;

    // Calculate individual scores for each perspective
    final lagnaScore = _getHousePositionScore(lagnaHouse);
    final chandraScore = _getHousePositionScore(chandraHouse);
    final suryaScore = _getHousePositionScore(suryaHouse);

    // Combined score: average of all three perspectives
    final combinedScore = (lagnaScore + chandraScore + suryaScore) / 3.0;
    final category = SudarshanStrengthCategory.fromScore(combinedScore);

    return SudarshanHouseStrength(
      houseNumber: houseNumber,
      lagnaHouse: lagnaHouse,
      chandraHouse: chandraHouse,
      suryaHouse: suryaHouse,
      combinedScore: combinedScore,
      category: category,
    );
  }

  /// Calculates the strength of a planet from all three perspectives.
  SudarshanPlanetStrength _calculatePlanetStrength({
    required Planet planet,
    required int planetHouse,
    required int lagnaSign,
    required int chandraSign,
    required int suryaSign,
    required VedicChart chart,
  }) {
    // Planet's house from Lagna is given directly
    final lagnaPlacement = planetHouse;

    // Get the planet's sign
    final planetInfo = chart.getPlanet(planet);
    final planetSign =
        planetInfo != null ? (planetInfo.longitude / 30).floor() % 12 : 0;

    // From Moon/Sun perspective, calculate which house this planet is in
    final chandraPlacement = ((planetSign - chandraSign + 12) % 12) + 1;
    final suryaPlacement = ((planetSign - suryaSign + 12) % 12) + 1;

    // Calculate individual scores
    final lagnaScore = _getHousePositionScore(lagnaPlacement);
    final chandraScore = _getHousePositionScore(chandraPlacement);
    final suryaScore = _getHousePositionScore(suryaPlacement);

    // Combined score: average
    final combinedScore = (lagnaScore + chandraScore + suryaScore) / 3.0;
    final category = SudarshanStrengthCategory.fromScore(combinedScore);

    return SudarshanPlanetStrength(
      planet: planet,
      lagnaPlacement: lagnaPlacement,
      chandraPlacement: chandraPlacement,
      suryaPlacement: suryaPlacement,
      combinedScore: combinedScore,
      category: category,
    );
  }

  /// Scores a house position based on Vedic principles.
  ///
  /// Kendra houses (1, 4, 7, 10): Angular, strongest positions (100 points)
  /// Trikona houses (5, 9): Trines, very favorable (90 points)
  /// Upachaya houses (3, 6, 10, 11): Growth houses (70 points for 3, 11; 50 for 6)
  /// Maraka house (2): Neutral to mildly unfavorable (60 points)
  /// Dusthana houses (6, 8, 12): Challenging positions (30-40 points)
  double _getHousePositionScore(int house) {
    return switch (house) {
      1 => 100.0, // Lagna - self, very strong
      4 => 90.0, // Kendra - happiness, strong
      7 => 85.0, // Kendra - relationships
      10 => 95.0, // Kendra - karma, career (also Upachaya)
      5 => 90.0, // Trikona - children, creativity
      9 => 90.0, // Trikona - dharma, fortune
      2 => 60.0, // Maraka - wealth, but also death-inflicting
      3 => 65.0, // Upachaya - courage, siblings
      11 => 75.0, // Upachaya - gains, elder siblings
      6 => 40.0, // Dusthana & Upachaya - enemies, disease
      8 => 30.0, // Dusthana - longevity, obstacles
      12 => 35.0, // Dusthana - losses, liberation
      _ => 50.0, // Default
    };
  }
}
