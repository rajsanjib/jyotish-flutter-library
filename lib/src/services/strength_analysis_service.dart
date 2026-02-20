import '../models/divisional_chart_type.dart';
import '../models/planet.dart';
import '../models/vedic_chart.dart';
import 'divisional_chart_service.dart';

/// Service for advanced strength and analysis calculations.
///
/// This service provides specialized APIs for:
/// - Ishtaphala and Kashtaphala (auspicious/inauspicious results)
/// - Bhava Bala (house strength calculations)
/// - Vimshopak Bala (strength across 20 divisional charts)
class StrengthAnalysisService {
  final DivisionalChartService _divisionalChartService =
      DivisionalChartService();

  /// Calculates Ishtaphala (auspicious fruit) for a planet.
  ///
  /// Ishtaphala represents the favorable results a planet can give based on:
  /// - Its positional strength (Shadbala)
  /// - Its dignity in the chart
  /// - Its relationship with the lagna lord
  ///
  /// [planet] - The planet to analyze
  /// [chart] - The Vedic chart
  /// [shadbalaStrength] - The Shadbala strength (0-600)
  ///
  /// Returns a value from 0.0 to 1.0 representing the auspicious potential
  double getIshtaphala({
    required Planet planet,
    required VedicChart chart,
    required double shadbalaStrength,
  }) {
    final planetInfo = chart.planets[planet];
    if (planetInfo == null) return 0.0;

    var ishtaphala = 0.0;

    // 1. Dignity factor (0-40%)
    final dignityScore = _getDignityScore(planetInfo.dignity);
    ishtaphala += dignityScore * 0.4;

    // 2. Shadbala factor (0-30%)
    // Normalize Shadbala (0-600) to (0-1)
    final shadbalaFactor = (shadbalaStrength / 600.0).clamp(0.0, 1.0);
    ishtaphala += shadbalaFactor * 0.3;

    // 3. House placement factor (0-20%)
    final houseScore = _getHouseScore(planetInfo.house);
    ishtaphala += houseScore * 0.2;

    // 4. Relationship with lagna lord (0-10%)
    final lagnaLord = _getLagnaLord(chart.houses.ascendant);
    if (lagnaLord != null) {
      final relationshipScore =
          _getPlanetaryRelationship(planet, lagnaLord, chart);
      ishtaphala += relationshipScore * 0.1;
    }

    return ishtaphala.clamp(0.0, 1.0);
  }

  /// Calculates Kashtaphala (inauspicious fruit) for a planet.
  ///
  /// Kashtaphala represents the unfavorable results a planet can give.
  /// It is inversely related to Ishtaphala but considers different factors
  /// like afflictions, combustions, and enemy placements.
  ///
  /// [planet] - The planet to analyze
  /// [chart] - The Vedic chart
  /// [shadbalaStrength] - The Shadbala strength (0-600)
  ///
  /// Returns a value from 0.0 to 1.0 representing the inauspicious potential
  double getKashtaphala({
    required Planet planet,
    required VedicChart chart,
    required double shadbalaStrength,
  }) {
    final planetInfo = chart.planets[planet];
    if (planetInfo == null) return 0.0;

    var kashtaphala = 0.0;

    // 1. Debilitation/enemy sign factor (0-35%)
    final debilitationScore = _getDebilitationScore(planetInfo.dignity);
    kashtaphala += debilitationScore * 0.35;

    // 2. Combustion factor (0-25%)
    if (planetInfo.isCombust) {
      kashtaphala += 0.25;
    } else {
      // Check proximity to Sun
      final sunInfo = chart.planets[Planet.sun];
      if (sunInfo != null) {
        final distanceFromSun =
            (planetInfo.longitude - sunInfo.longitude).abs() % 360;
        if (distanceFromSun < 15 || distanceFromSun > 345) {
          kashtaphala += 0.15 * (1 - distanceFromSun / 15);
        }
      }
    }

    // 3. Weak Shadbala factor (0-25%)
    // Low Shadbala contributes to Kashtaphala
    final weakShadbalaFactor = (1 - (shadbalaStrength / 300.0)).clamp(0.0, 1.0);
    kashtaphala += weakShadbalaFactor * 0.25;

    // 4. Malefic house placement (0-15%)
    final maleficHouses = [6, 8, 12];
    if (maleficHouses.contains(planetInfo.house)) {
      kashtaphala += 0.15;
    }

    return kashtaphala.clamp(0.0, 1.0);
  }

  /// Calculates Bhava Bala (house strength) for all 12 houses.
  ///
  /// Bhava Bala measures the cumulative strength of each house based on:
  /// - The strength of the house lord
  /// - Planets placed in the house
  /// - Aspects on the house
  /// - Placement in divisional charts
  ///
  /// [chart] - The Vedic chart
  /// [shadbalaResults] - Shadbala results for all planets
  ///
  /// Returns a map of house numbers (1-12) to their strength values (0-100)
  Map<int, double> getBhavaBala({
    required VedicChart chart,
    required Map<Planet, double> shadbalaResults,
  }) {
    final bhavaBala = <int, double>{};

    for (var houseNum = 1; houseNum <= 12; houseNum++) {
      var strength = 0.0;

      // 1. House lord strength (40%)
      final houseLord = _getHouseLord(houseNum, chart.houses.ascendant);
      if (houseLord != null) {
        final lordStrength = shadbalaResults[houseLord] ?? 0.0;
        strength += (lordStrength / 600.0) * 40.0;
      }

      // 2. Planets in house strength (35%)
      final planetsInHouse = chart.getPlanetsInHouse(houseNum);
      var planetsStrength = 0.0;
      for (final planet in planetsInHouse) {
        final planetStrength = shadbalaResults[planet.planet] ?? 0.0;
        planetsStrength += planetStrength / 600.0;
      }
      // Average if multiple planets
      if (planetsInHouse.isNotEmpty) {
        planetsStrength /= planetsInHouse.length;
      }
      strength += planetsStrength * 35.0;

      // 3. House nature factor (15%)
      // Kendra (1,4,7,10) = Strongest
      // Panapara (2,5,8,11) = Medium
      // Apoklima (3,6,9,12) = Weakest
      if ([1, 4, 7, 10].contains(houseNum)) {
        strength += 15.0;
      } else if ([2, 5, 8, 11].contains(houseNum)) {
        strength += 10.0;
      } else {
        strength += 5.0;
      }

      // 4. Aspect strength (10%)
      // Benefic aspects add strength
      var aspectStrength = 0.0;
      final beneficPlanets = [Planet.jupiter, Planet.venus, Planet.mercury];
      for (final benefic in beneficPlanets) {
        final beneficInfo = chart.planets[benefic];
        if (beneficInfo != null) {
          // Check if benefic aspects this house
          if (_isPlanetAspectingHouse(
              beneficInfo.longitude, houseNum, chart, benefic)) {
            aspectStrength += 3.33; // Max 10 for 3 benefics
          }
        }
      }
      strength += aspectStrength.clamp(0.0, 10.0);

      bhavaBala[houseNum] = strength.clamp(0.0, 100.0);
    }

    return bhavaBala;
  }

  /// Calculates Vimshopak Bala (20-fold strength).
  ///
  /// Vimshopak Bala evaluates a planet's strength across 20 divisional charts:
  /// - D1 (Rashi): 3.5 points
  /// - D2 (Hora): 1.0 point
  /// - D3 (Drekkana): 1.0 point
  /// - D7 (Saptamsa): 0.5 point
  /// - D9 (Navamsa): 3.0 points
  /// - D10 (Dasamsa): 0.5 point
  /// - D12 (Dwadasamsa): 0.5 point
  /// - And 13 more divisional charts
  ///
  /// [chart] - The Vedic chart
  /// [planet] - The planet to analyze
  ///
  /// Returns VimshopakBala result with total score (0-20)
  VimshopakBala getVimshopakBala({
    required VedicChart chart,
    required Planet planet,
  }) {
    final divisionalScores = <DivisionalChartType, double>{};
    var totalScore = 0.0;

    // Define the 20 divisional charts with their weights
    final vargaWeights = {
      DivisionalChartType.d1: 3.5, // Rashi
      DivisionalChartType.d2: 1.0, // Hora
      DivisionalChartType.d3: 1.0, // Drekkana
      DivisionalChartType.d4: 0.5, // Chaturthamsa
      DivisionalChartType.d7: 0.5, // Saptamsa
      DivisionalChartType.d9: 3.0, // Navamsa
      DivisionalChartType.d10: 0.5, // Dasamsa
      DivisionalChartType.d12: 0.5, // Dwadasamsa
      DivisionalChartType.d16: 0.5, // Shodasamsa
      DivisionalChartType.d20: 0.5, // Vimsamsa
      DivisionalChartType.d24: 0.5, // Chaturvimshamsha
      DivisionalChartType.d27: 0.5, // Saptavimsamsa
      DivisionalChartType.d30: 1.0, // Trimsamsa
      DivisionalChartType.d40: 0.5, // Khavedamsa
      DivisionalChartType.d45: 0.5, // Akshavedamsa
      DivisionalChartType.d60: 4.0, // Shashtiamsa
    };

    // Calculate score for each divisional chart
    for (final entry in vargaWeights.entries) {
      final vargaType = entry.key;
      final weight = entry.value;

      final vargaChart = _divisionalChartService.calculateDivisionalChart(
        chart,
        vargaType,
      );

      final planetInfo = vargaChart.planets[planet];
      if (planetInfo != null) {
        // Score based on dignity in the varga
        final dignityScore = _getVargaDignityScore(planetInfo.dignity);
        final weightedScore = dignityScore * weight;

        divisionalScores[vargaType] = weightedScore;
        totalScore += weightedScore;
      }
    }

    return VimshopakBala(
      planet: planet,
      totalScore: totalScore,
      maxPossibleScore: 20.0,
      divisionalScores: divisionalScores,
      strengthCategory: _getVimshopakCategory(totalScore),
    );
  }

  /// Calculates Vimshopak Bala for all planets.
  ///
  /// [chart] - The Vedic chart
  ///
  /// Returns a map of all traditional planets to their Vimshopak Bala
  Map<Planet, VimshopakBala> getAllPlanetsVimshopakBala(VedicChart chart) {
    final results = <Planet, VimshopakBala>{};

    for (final planet in Planet.traditionalPlanets) {
      results[planet] = getVimshopakBala(chart: chart, planet: planet);
    }

    return results;
  }

  // Helper methods

  double _getDignityScore(PlanetaryDignity dignity) {
    return switch (dignity) {
      PlanetaryDignity.exalted => 1.0,
      PlanetaryDignity.moolaTrikona => 0.9,
      PlanetaryDignity.ownSign => 0.8,
      PlanetaryDignity.greatFriend => 0.7,
      PlanetaryDignity.friendSign => 0.6,
      PlanetaryDignity.neutralSign => 0.5,
      PlanetaryDignity.enemySign => 0.3,
      PlanetaryDignity.greatEnemy => 0.2,
      PlanetaryDignity.debilitated => 0.0,
    };
  }

  double _getDebilitationScore(PlanetaryDignity dignity) {
    return switch (dignity) {
      PlanetaryDignity.debilitated => 1.0,
      PlanetaryDignity.greatEnemy => 0.8,
      PlanetaryDignity.enemySign => 0.6,
      PlanetaryDignity.neutralSign => 0.3,
      PlanetaryDignity.friendSign => 0.2,
      PlanetaryDignity.greatFriend => 0.1,
      PlanetaryDignity.ownSign => 0.0,
      PlanetaryDignity.moolaTrikona => 0.0,
      PlanetaryDignity.exalted => 0.0,
    };
  }

  double _getHouseScore(int house) {
    // Kendra houses (1,4,7,10) = 1.0
    // Trikona houses (5,9) = 0.9
    // Upachaya (3,6,10,11) = 0.7
    // Dusthana (6,8,12) = 0.3
    return switch (house) {
      1 || 4 || 7 || 10 => 1.0,
      5 || 9 => 0.9,
      3 || 11 => 0.7,
      2 => 0.8,
      6 || 8 || 12 => 0.3,
      _ => 0.5,
    };
  }

  Planet? _getLagnaLord(double ascendant) {
    final signIndex = (ascendant / 30).floor() % 12;
    const lords = {
      0: Planet.mars, // Aries
      1: Planet.venus, // Taurus
      2: Planet.mercury, // Gemini
      3: Planet.moon, // Cancer
      4: Planet.sun, // Leo
      5: Planet.mercury, // Virgo
      6: Planet.venus, // Libra
      7: Planet.mars, // Scorpio
      8: Planet.jupiter, // Sagittarius
      9: Planet.saturn, // Capricorn
      10: Planet.saturn, // Aquarius
      11: Planet.jupiter, // Pisces
    };
    return lords[signIndex];
  }

  Planet? _getHouseLord(int houseNumber, double ascendant) {
    // Calculate which sign this house falls in
    final houseSignIndex = ((ascendant / 30).floor() + houseNumber - 1) % 12;
    return _getLagnaLord(houseSignIndex * 30.0);
  }

  double _getPlanetaryRelationship(
      Planet planet1, Planet planet2, VedicChart chart) {
    if (planet1 == planet2) return 1.0;

    // 1. Natural Relationship (Naisargika Maitri)
    // 1 = friend, 0 = neutral, -1 = enemy
    final naturalRel = _getNaturalRelationship(planet1, planet2);

    // 2. Temporal Relationship (Tatkalika Maitri)
    // Planets in 2, 3, 4, 10, 11, 12 from each other are friends.
    // Others (1, 5, 6, 7, 8, 9) are enemies.
    final p1Info = chart.planets[planet1];
    final p2Info = chart.planets[planet2];

    var temporalRel = -1; // Default enemy

    if (p1Info != null && p2Info != null) {
      final sign1 = (p1Info.longitude / 30).floor();
      final sign2 = (p2Info.longitude / 30).floor();

      // Count from P1 to P2
      final diff = (sign2 - sign1 + 12) % 12;
      // 2nd (1), 3rd (2), 4th (3), 10th (9), 11th (10), 12th (11) -> Friend
      if ([1, 2, 3, 9, 10, 11].contains(diff)) {
        temporalRel = 1;
      }
    }

    // 3. Pancha-Da Maitri (Compound Relationship)
    final total = naturalRel + temporalRel;

    if (total == 2) return 1.0; // Great Friend
    if (total == 1) return 0.75; // Friend (Effective)
    if (total == 0) return 0.5; // Neutral
    if (total == -1) return 0.25; // Enemy
    if (total == -2) return 0.0; // Great Enemy

    return 0.5; // Fallback
  }

  int _getNaturalRelationship(Planet p1, Planet p2) {
    final friends = {
      Planet.sun: [Planet.moon, Planet.mars, Planet.jupiter],
      Planet.moon: [Planet.sun, Planet.mercury],
      Planet.mars: [Planet.sun, Planet.moon, Planet.jupiter],
      Planet.mercury: [Planet.sun, Planet.venus],
      Planet.jupiter: [Planet.sun, Planet.moon, Planet.mars],
      Planet.venus: [Planet.mercury, Planet.saturn],
      Planet.saturn: [Planet.mercury, Planet.venus],
      Planet.meanNode: [Planet.venus, Planet.saturn],
      Planet.ketu: [Planet.mars, Planet.venus],
    };

    final enemies = {
      Planet.sun: [Planet.venus, Planet.saturn],
      Planet.moon: [],
      Planet.mars: [Planet.mercury],
      Planet.mercury: [Planet.moon],
      Planet.jupiter: [Planet.mercury, Planet.venus],
      Planet.venus: [Planet.sun, Planet.moon],
      Planet.saturn: [Planet.sun, Planet.moon, Planet.mars],
      Planet.meanNode: [Planet.sun, Planet.moon, Planet.mars],
      Planet.ketu: [Planet.sun, Planet.moon],
    };

    if (friends[p1]?.contains(p2) ?? false) return 1;
    if (enemies[p1]?.contains(p2) ?? false) return -1;
    return 0; // Neutral
  }

  bool _isPlanetAspectingHouse(
      double planetLongitude, int houseNum, VedicChart chart, Planet planet) {
    // Calculate Ascendant Sign
    final ascSignIndex = (chart.houses.ascendant / 30).floor();

    // Calculate House Sign Index (1-based houseNum)
    final houseSignIndex = (ascSignIndex + houseNum - 1) % 12;

    // Calculate Planet Sign Index
    final planetSignIndex = (planetLongitude / 30).floor();

    // Count from Planet to House
    final diff = (houseSignIndex - planetSignIndex + 12) % 12;

    // Standard Aspects:
    // All planets aspect 7th (index diff 6)
    if (diff == 6) return true;

    // Special Aspects:
    // Mars: 4th (3), 8th (7)
    if (planet == Planet.mars && (diff == 3 || diff == 7)) return true;

    // Jupiter: 5th (4), 9th (8)
    if (planet == Planet.jupiter && (diff == 4 || diff == 8)) return true;

    // Saturn: 3rd (2), 10th (9)
    if (planet == Planet.saturn && (diff == 2 || diff == 9)) return true;

    // Rahu/Ketu: 5th, 9th
    if ((planet == Planet.meanNode || planet == Planet.ketu) &&
        (diff == 4 || diff == 8)) return true;

    return false;
  }

  double _getVargaDignityScore(PlanetaryDignity dignity) {
    // Score out of 1.0 for each varga
    return switch (dignity) {
      PlanetaryDignity.exalted => 1.0,
      PlanetaryDignity.moolaTrikona => 0.95,
      PlanetaryDignity.ownSign => 0.9,
      PlanetaryDignity.greatFriend => 0.75,
      PlanetaryDignity.friendSign => 0.6,
      PlanetaryDignity.neutralSign => 0.5,
      PlanetaryDignity.enemySign => 0.3,
      PlanetaryDignity.greatEnemy => 0.15,
      PlanetaryDignity.debilitated => 0.0,
    };
  }

  VimshopakStrength _getVimshopakCategory(double score) {
    if (score >= 16) return VimshopakStrength.excellent;
    if (score >= 12) return VimshopakStrength.good;
    if (score >= 8) return VimshopakStrength.moderate;
    if (score >= 4) return VimshopakStrength.weak;
    return VimshopakStrength.veryWeak;
  }
}

/// Represents Vimshopak Bala (20-fold strength) for a planet.
class VimshopakBala {
  const VimshopakBala({
    required this.planet,
    required this.totalScore,
    required this.maxPossibleScore,
    required this.divisionalScores,
    required this.strengthCategory,
  });

  /// The planet this Vimshopak Bala belongs to
  final Planet planet;

  /// Total Vimshopak score (0-20)
  final double totalScore;

  /// Maximum possible score (20.0)
  final double maxPossibleScore;

  /// Individual scores for each divisional chart
  final Map<DivisionalChartType, double> divisionalScores;

  /// Strength category based on total score
  final VimshopakStrength strengthCategory;

  /// Percentage score (0-100)
  double get percentage => (totalScore / maxPossibleScore) * 100;

  /// Whether the planet has excellent strength
  bool get isExcellent => strengthCategory == VimshopakStrength.excellent;

  /// Whether the planet has good or better strength
  bool get isStrong => totalScore >= 12;

  @override
  String toString() {
    return '${planet.displayName}: ${totalScore.toStringAsFixed(1)}/$maxPossibleScore (${strengthCategory.name})';
  }
}

/// Vimshopak strength categories
enum VimshopakStrength {
  excellent('Excellent', 16, 20),
  good('Good', 12, 16),
  moderate('Moderate', 8, 12),
  weak('Weak', 4, 8),
  veryWeak('Very Weak', 0, 4);

  const VimshopakStrength(this.name, this.minScore, this.maxScore);

  final String name;
  final double minScore;
  final double maxScore;
}

/// Represents Ishtaphala-Kashtaphala analysis for a planet.
class IshtaKashtaResult {
  const IshtaKashtaResult({
    required this.planet,
    required this.ishtaphala,
    required this.kashtaphala,
    required this.netResult,
    required this.interpretation,
  });

  /// The planet analyzed
  final Planet planet;

  /// Auspicious fruit (0-1)
  final double ishtaphala;

  /// Inauspicious fruit (0-1)
  final double kashtaphala;

  /// Net result (Ishtaphala - Kashtaphala, -1 to 1)
  final double netResult;

  /// Text interpretation
  final String interpretation;

  /// Whether the planet is generally favorable
  bool get isFavorable => netResult > 0;

  /// Overall strength score (0-100)
  double get overallScore => ((ishtaphala - kashtaphala + 1) / 2) * 100;
}
