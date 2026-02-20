import '../models/planet.dart';

/// Service for calculating Gochara Vedha (obstructions in transit results).
///
/// Gochara Vedha is a crucial concept in transit analysis where certain
/// planetary positions can obstruct or nullify the results of other planets
/// in transit. This service identifies these obstructions.
class GocharaVedhaService {
  /// Standard Gochara positions (houses from Moon) for benefic results.
  ///
  /// These are the favorable transit houses for each planet:
  /// - Sun: 3, 6, 10, 11
  /// - Moon: 1, 3, 6, 7, 10, 11
  /// - Mars: 3, 6, 11
  /// - Mercury: 2, 4, 6, 8, 10, 11
  /// - Jupiter: 2, 5, 7, 9, 11
  /// - Venus: 1, 2, 3, 4, 5, 8, 9, 11, 12
  /// - Saturn: 3, 6, 11
  static const Map<Planet, List<int>> gocharaFavorableHouses = {
    Planet.sun: [3, 6, 10, 11],
    Planet.moon: [1, 3, 6, 7, 10, 11],
    Planet.mars: [3, 6, 11],
    Planet.mercury: [2, 4, 6, 8, 10, 11],
    Planet.jupiter: [2, 5, 7, 9, 11],
    Planet.venus: [1, 2, 3, 4, 5, 8, 9, 11, 12],
    Planet.saturn: [3, 6, 11],
  };

  /// Vedha (obstruction) relationships between planets.
  ///
  /// When two planets are transiting favorable houses simultaneously,
  /// they can obstruct each other's results according to these rules:
  /// - Sun and Saturn obstruct each other
  /// - Moon and Mercury obstruct each other
  /// - Mars and Venus obstruct each other
  /// - Jupiter has no Vedha (no obstruction)
  static const Map<Planet, List<Planet>> vedhaRelationships = {
    Planet.sun: [Planet.saturn],
    Planet.saturn: [Planet.sun],
    Planet.moon: [Planet.mercury],
    Planet.mercury: [Planet.moon],
    Planet.mars: [Planet.venus],
    Planet.venus: [Planet.mars],
    Planet.jupiter: [], // Jupiter has no Vedha
  };

  /// Nakshatra-based Vedha positions.
  ///
  /// Certain nakshatras create Vedha when planets transit through them
  /// in specific relationships to the Moon's nakshatra.
  static const Map<int, List<int>> nakshatraVedha = {
    // Ashwini (1) is obstructed by...
    1: [10, 19], // Magha (10), Mula (19)
    // Bharani (2) is obstructed by...
    2: [11, 20],
    // Continue for all 27 nakshatras...
  };

  /// Calculates Gochara Vedha for a specific transit.
  ///
  /// [transitPlanet] - The planet in transit
  /// [houseFromMoon] - House position from natal Moon (1-12)
  /// [moonNakshatra] - Current Moon's nakshatra (1-27)
  /// [otherTransits] - Other planets currently transiting
  ///
  /// Returns Vedha analysis result
  VedhaResult calculateVedha({
    required Planet transitPlanet,
    required int houseFromMoon,
    required int moonNakshatra,
    required Map<Planet, int> otherTransits, // Planet -> House from Moon
  }) {
    // Check if transit planet is in favorable house
    final isFavorable = _isFavorablePosition(transitPlanet, houseFromMoon);

    // Find planets causing Vedha
    final vedhaPlanets = <Planet>[];
    final obstructionDetails = <String>[];

    // 1. Check house-based Vedha
    final obstructingPlanets = vedhaRelationships[transitPlanet] ?? [];
    for (final obstructingPlanet in obstructingPlanets) {
      if (otherTransits.containsKey(obstructingPlanet)) {
        final otherHouse = otherTransits[obstructingPlanet]!;
        
        // Check if the obstructing planet is also in a favorable house
        if (_isFavorablePosition(obstructingPlanet, otherHouse)) {
          vedhaPlanets.add(obstructingPlanet);
          obstructionDetails.add(
            '${obstructingPlanet.displayName} in house $otherHouse from Moon',
          );
        }
      }
    }

    // 2. Check if transit is favorable but obstructed
    final isObstructed = isFavorable && vedhaPlanets.isNotEmpty;

    // 3. Calculate Vedha strength
    final vedhaStrength = _calculateVedhaStrength(
      transitPlanet: transitPlanet,
      vedhaPlanets: vedhaPlanets,
      houseFromMoon: houseFromMoon,
    );

    // 4. Determine result effectiveness
    final resultEffectiveness = isObstructed
        ? 1.0 - vedhaStrength // Reduced by Vedha
        : (isFavorable ? 1.0 : 0.0);

    return VedhaResult(
      transitPlanet: transitPlanet,
      houseFromMoon: houseFromMoon,
      isFavorablePosition: isFavorable,
      isObstructed: isObstructed,
      obstructingPlanets: vedhaPlanets,
      obstructionDetails: obstructionDetails,
      vedhaStrength: vedhaStrength,
      resultEffectiveness: resultEffectiveness,
      interpretation: _generateInterpretation(
        transitPlanet: transitPlanet,
        isFavorable: isFavorable,
        isObstructed: isObstructed,
        vedhaPlanets: vedhaPlanets,
      ),
    );
  }

  /// Calculates Vedha for multiple planets transiting simultaneously.
  ///
  /// [transits] - Map of planets to their house positions from Moon
  /// [moonNakshatra] - Current Moon's nakshatra
  ///
  /// Returns Vedha analysis for all transits
  List<VedhaResult> calculateMultipleVedha({
    required Map<Planet, int> transits,
    required int moonNakshatra,
  }) {
    final results = <VedhaResult>[];

    for (final entry in transits.entries) {
      // Create map of other transits (excluding current planet)
      final otherTransits = Map<Planet, int>.from(transits)
        ..remove(entry.key);

      final vedha = calculateVedha(
        transitPlanet: entry.key,
        houseFromMoon: entry.value,
        moonNakshatra: moonNakshatra,
        otherTransits: otherTransits,
      );

      results.add(vedha);
    }

    return results;
  }

  /// Checks if there's mutual Vedha between two planets.
  ///
  /// Mutual Vedha occurs when two planets obstruct each other,
  /// effectively canceling out both results.
  ///
  /// [planet1] - First planet
  /// [house1] - First planet's house from Moon
  /// [planet2] - Second planet
  /// [house2] - Second planet's house from Moon
  ///
  /// Returns true if there's mutual obstruction
  bool hasMutualVedha(
    Planet planet1,
    int house1,
    Planet planet2,
    int house2,
  ) {
    // Check if both are in favorable positions
    final p1Favorable = _isFavorablePosition(planet1, house1);
    final p2Favorable = _isFavorablePosition(planet2, house2);

    if (!p1Favorable || !p2Favorable) return false;

    // Check if they obstruct each other
    final p1ObstructsP2 = vedhaRelationships[planet1]?.contains(planet2) ?? false;
    final p2ObstructsP1 = vedhaRelationships[planet2]?.contains(planet1) ?? false;

    return p1ObstructsP2 && p2ObstructsP1;
  }

  /// Finds the best transit periods without Vedha.
  ///
  /// [transitsOverTime] - List of transit snapshots with dates
  ///
  /// Returns list of favorable periods without obstruction
  List<FavorablePeriod> findFavorablePeriodsWithoutVedha(
    List<TransitSnapshot> transitsOverTime,
  ) {
    final favorablePeriods = <FavorablePeriod>[];

    for (final snapshot in transitsOverTime) {
      final vedhaResults = calculateMultipleVedha(
        transits: snapshot.transits,
        moonNakshatra: snapshot.moonNakshatra,
      );

      // Find planets with favorable results and no Vedha
      final unobstructedPlanets = vedhaResults
          .where((v) => v.isFavorablePosition && !v.isObstructed)
          .map((v) => v.transitPlanet)
          .toList();

      if (unobstructedPlanets.isNotEmpty) {
        favorablePeriods.add(FavorablePeriod(
          date: snapshot.date,
          planets: unobstructedPlanets,
          description: 'Favorable transit without Vedha',
        ));
      }
    }

    return favorablePeriods;
  }

  /// Gets remedial measures for Vedha.
  ///
  /// [vedhaResult] - The Vedha result to get remedies for
  ///
  /// Returns list of remedial suggestions
  List<String> getVedhaRemedies(VedhaResult vedhaResult) {
    final remedies = <String>[];

    if (!vedhaResult.isObstructed) return remedies;

    // General remedies
    remedies.add('Perform mantra japa for ${vedhaResult.transitPlanet.displayName}');
    remedies.add('Donate items related to ${vedhaResult.transitPlanet.displayName}');

    // Specific remedies based on obstructing planets
    for (final obstructingPlanet in vedhaResult.obstructingPlanets) {
      remedies.add(
        'Pacify ${obstructingPlanet.displayName} through propitiation',
      );
    }

    // House-specific remedies
    switch (vedhaResult.houseFromMoon) {
      case 1:
        remedies.add('Take care of health and well-being');
        break;
      case 2:
        remedies.add('Be careful with finances and family');
        break;
      case 3:
        remedies.add('Avoid conflicts with siblings');
        break;
      case 7:
        remedies.add('Be mindful in partnerships');
        break;
      case 10:
        remedies.add('Exercise caution in career matters');
        break;
    }

    return remedies;
  }

  // Helper methods

  bool _isFavorablePosition(Planet planet, int houseFromMoon) {
    final favorable = gocharaFavorableHouses[planet] ?? [];
    return favorable.contains(houseFromMoon);
  }

  double _calculateVedhaStrength({
    required Planet transitPlanet,
    required List<Planet> vedhaPlanets,
    required int houseFromMoon,
  }) {
    var strength = 0.0;

    // Base strength per obstructing planet
    const baseStrengthPerPlanet = 0.3;
    strength = vedhaPlanets.length * baseStrengthPerPlanet;

    // Adjust based on dignity (simplified)
    // Malefic planets cause stronger Vedha
    final malefics = [Planet.sun, Planet.mars, Planet.saturn];
    for (final vedhaPlanet in vedhaPlanets) {
      if (malefics.contains(vedhaPlanet)) {
        strength += 0.1;
      }
    }

    // House strength factor
    // Vedha in Kendra houses (1,4,7,10) is stronger
    if ([1, 4, 7, 10].contains(houseFromMoon)) {
      strength *= 1.2;
    }

    return strength.clamp(0.0, 1.0);
  }

  String _generateInterpretation({
    required Planet transitPlanet,
    required bool isFavorable,
    required bool isObstructed,
    required List<Planet> vedhaPlanets,
  }) {
    final buffer = StringBuffer();

    if (!isFavorable) {
      buffer.write(
        '${transitPlanet.displayName} is not in a favorable position from Moon. ',
      );
      buffer.write('Results may be challenging or delayed.');
      return buffer.toString();
    }

    buffer.write(
      '${transitPlanet.displayName} is in a favorable position from Moon. ',
    );

    if (isObstructed) {
      buffer.write('However, ');
      if (vedhaPlanets.length == 1) {
        buffer.write(
          '${vedhaPlanets.first.displayName} is causing Vedha (obstruction). ',
        );
      } else {
        buffer.write(
          '${vedhaPlanets.map((p) => p.displayName).join(" and ")} are causing Vedha (obstruction). ',
        );
      }
      buffer.write('The favorable results may be reduced or delayed.');
    } else {
      buffer.write('No Vedha is present, so full favorable results expected.');
    }

    return buffer.toString();
  }
}

/// Represents a Vedha (obstruction) analysis result.
class VedhaResult {
  const VedhaResult({
    required this.transitPlanet,
    required this.houseFromMoon,
    required this.isFavorablePosition,
    required this.isObstructed,
    required this.obstructingPlanets,
    required this.obstructionDetails,
    required this.vedhaStrength,
    required this.resultEffectiveness,
    required this.interpretation,
  });

  /// The planet in transit
  final Planet transitPlanet;

  /// House position from natal Moon (1-12)
  final int houseFromMoon;

  /// Whether the position is generally favorable
  final bool isFavorablePosition;

  /// Whether Vedha obstruction is present
  final bool isObstructed;

  /// Planets causing the obstruction
  final List<Planet> obstructingPlanets;

  /// Detailed obstruction descriptions
  final List<String> obstructionDetails;

  /// Strength of Vedha (0.0 - 1.0)
  final double vedhaStrength;

  /// Effectiveness of results (0.0 - 1.0)
  final double resultEffectiveness;

  /// Text interpretation
  final String interpretation;

  /// Whether the transit is fully favorable
  bool get isFullyFavorable => isFavorablePosition && !isObstructed;

  /// Severity level of Vedha
  VedhaSeverity get severity {
    if (!isObstructed) return VedhaSeverity.none;
    if (vedhaStrength > 0.7) return VedhaSeverity.severe;
    if (vedhaStrength > 0.4) return VedhaSeverity.moderate;
    return VedhaSeverity.mild;
  }

  @override
  String toString() {
    return '${transitPlanet.displayName} in house $houseFromMoon: '
        '${isObstructed ? "Obstructed by ${obstructingPlanets.map((p) => p.displayName).join(", ")}" : "No Vedha"}';
  }
}

/// Vedha severity levels
enum VedhaSeverity {
  none('No Vedha', 'Full results expected'),
  mild('Mild Vedha', 'Slight reduction in results'),
  moderate('Moderate Vedha', 'Significant reduction in results'),
  severe('Severe Vedha', 'Results largely nullified');

  const VedhaSeverity(this.name, this.description);

  final String name;
  final String description;

  @override
  String toString() => name;
}

/// Represents a snapshot of transits at a specific time.
class TransitSnapshot {
  const TransitSnapshot({
    required this.date,
    required this.transits,
    required this.moonNakshatra,
  });

  /// Date of the snapshot
  final DateTime date;

  /// Map of planets to their house positions from Moon
  final Map<Planet, int> transits;

  /// Moon's nakshatra at that time (1-27)
  final int moonNakshatra;
}

/// Represents a favorable period without Vedha.
class FavorablePeriod {
  const FavorablePeriod({
    required this.date,
    required this.planets,
    required this.description,
  });

  /// Date of the favorable period
  final DateTime date;

  /// List of planets with favorable unobstructed transits
  final List<Planet> planets;

  /// Description of the period
  final String description;

  @override
  String toString() {
    return '${date.toIso8601String()}: ${planets.map((p) => p.displayName).join(", ")}';
  }
}
