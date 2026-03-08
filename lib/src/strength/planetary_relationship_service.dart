import 'package:jyotish/src/models/planet.dart';
import 'package:jyotish/src/strength/relationship.dart';
import 'package:jyotish/src/models/vedic_chart.dart';

/// Service for computing complete Pancha-Vargeeya Maitri
/// (5-fold planetary friendship) for a given chart.
///
/// The 5-fold friendship combines:
/// 1. Naisargika Maitri  Natural (permanent) friendship
/// 2. Tatkalika Maitri   Temporal friendship based on chart placement
///  Compound result is Panchadha Maitri
///
/// Rules for Tatkalika (temporary) friendship:
/// A planet is a **temporary friend** of another if it occupies the
/// 2nd, 3rd, 4th, 10th, 11th, or 12th house FROM the other planet.
/// Otherwise it is a temporary enemy.
///
/// Compound (Panchadha) mapping:
/// | Natural | Temporal | Compound     |
/// |---------|----------|--------------|
/// | Friend  | Friend   | Great Friend |
/// | Friend  | Enemy    | Neutral      |
/// | Neutral | Friend   | Friend       |
/// | Neutral | Enemy    | Enemy        |
/// | Enemy   | Friend   | Neutral      |
/// | Enemy   | Enemy    | Great Enemy  |
class PlanetaryRelationshipService {
  /// Returns the full 77 relationship matrix for the seven traditional
  /// planets in the given [chart].
  ///
  /// The return value is a map keyed by `planet`  `otherPlanet` 
  /// [PlanetaryRelationship].
  ///
  /// Example:
  /// ```dart
  /// final rels = service.getAllRelationships(chart);
  /// final rel = rels[Planet.sun]![Planet.saturn]!;
  /// print(rel.natural);   // enemy
  /// print(rel.temporary); // friend (if Saturn occupies 2nd-4th or 10th-12th from Sun in the chart)
  /// print(rel.compound);  // neutral (enemy + friend = neutral)
  /// ```
  Map<Planet, Map<Planet, PlanetaryRelationship>> getAllRelationships(
    VedicChart chart,
  ) {
    final result = <Planet, Map<Planet, PlanetaryRelationship>>{};

    final planets = Planet
        .traditionalPlanets; // Sun, Moon, Mars, Mercury, Jupiter, Venus, Saturn

    for (final a in planets) {
      result[a] = {};
      for (final b in planets) {
        if (a == b) continue;
        result[a]![b] = getRelationship(a, b, chart);
      }
    }

    return result;
  }

  /// Returns [PlanetaryRelationship] between [planet] and [otherPlanet]
  /// in the context of the given [chart].
  ///
  /// [planet]  The reference planet (viewpoint).
  /// [otherPlanet]  The other planet being evaluated.
  /// [chart]  The Vedic chart providing actual house placements.
  ///
  /// Throws [ArgumentError] if the same planet is passed twice.
  PlanetaryRelationship getRelationship(
    Planet planet,
    Planet otherPlanet,
    VedicChart chart,
  ) {
    if (planet == otherPlanet) {
      throw ArgumentError(
          'Cannot compute relationship of a planet with itself.');
    }

    // 1. Natural friendship
    final natural = RelationshipCalculator.naturalRelationships[planet]
            ?[otherPlanet] ??
        RelationshipType.neutral;

    // 2. Temporal friendship based on house positions
    final houseA = chart.planets[planet]?.house;
    final houseB = chart.planets[otherPlanet]?.house;

    final RelationshipType temporary;
    if (houseA != null && houseB != null) {
      temporary = RelationshipCalculator.calculateTemporary(houseA, houseB);
    } else {
      // If we can't determine house (e.g., outer planets not in chart),
      // default to neutral temporary relationship
      temporary = RelationshipType.neutral;
    }

    // 3. Compound (Panchadha Maitri)
    final compound =
        RelationshipCalculator.calculateCompound(natural, temporary);

    return PlanetaryRelationship(
      planet: planet,
      otherPlanet: otherPlanet,
      natural: natural,
      temporary: temporary,
      compound: compound,
    );
  }

  /// Returns a human-readable summary of the compound relationship
  /// between two planets in a chart.
  ///
  /// Example: "Sun  Saturn: Great Enemy (Natural: Enemy, Temporal: Enemy)"
  String describeRelationship(
    Planet planet,
    Planet otherPlanet,
    VedicChart chart,
  ) {
    final rel = getRelationship(planet, otherPlanet, chart);
    return '${rel.planet.displayName}  ${rel.otherPlanet.displayName}: '
        '${rel.compound.displayName} '
        '(Natural: ${rel.natural.displayName}, Temporal: ${rel.temporary.displayName})';
  }
}
