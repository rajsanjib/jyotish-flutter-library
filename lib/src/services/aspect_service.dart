import '../models/aspect.dart';
import '../models/jaimini.dart';
import '../models/planet.dart';
import '../models/planet_position.dart';
import '../models/vedic_chart.dart';
import 'jaimini_service.dart';

/// Service for calculating Vedic planetary aspects (Graha Drishti).
///
/// **Vedic (whole-sign) mode** [default for [AspectConfig.vedic]]:
/// Aspects are cast sign-to-sign — a planet in sign X aspects every planet
/// in the target sign regardless of exact degree separation. Strength is
/// always 1.0 (full).
///
/// Aspect houses from aspecting planet’s sign:
/// - All planets aspect the 7th house (opposition sign)
/// - Mars also aspects the 4th and 8th houses
/// - Jupiter also aspects the 5th and 9th houses
/// - Saturn also aspects the 3rd and 10th houses
///
/// **Western (degree-based) mode** [AspectConfig with useWholeSignAspects=false]:
/// Standard degree+orb calculation, useful for KP or Western tropical use.
class AspectService {
  /// Returns Rashi Drishti (sign aspects) for the chart.
  ///
  /// Delegates to [JaiminiService] which implements the Jaimini sign-aspect rules:
  /// - Movable signs aspect all Fixed signs (except adjacent)
  /// - Fixed signs aspect all Movable signs (except adjacent)
  /// - Dual signs aspect all other Dual signs
  List<RashiDrishtiInfo> getRashiAspects(
    VedicChart chart, {
    bool activeOnly = true,
  }) {
    final jaiminiService = JaiminiService();
    return activeOnly
        ? jaiminiService.calculateActiveRashiDrishti(chart)
        : jaiminiService.calculateRashiDrishti(chart);
  }

  /// Calculates all aspects between planetary positions.
  ///
  /// [positions] - Map of planets to their positions
  /// [config] - Configuration for aspect calculations
  ///
  /// Returns a list of all aspects found.
  List<AspectInfo> calculateAspects(
    Map<Planet, PlanetPosition> positions, {
    AspectConfig config = AspectConfig.vedic,
  }) {
    final aspects = <AspectInfo>[];
    final planets = positions.keys.toList();

    for (var i = 0; i < planets.length; i++) {
      for (var j = i + 1; j < planets.length; j++) {
        final planet1 = planets[i];
        final planet2 = planets[j];

        // Skip nodes if not configured
        if (!config.includeNodes &&
            (planet1 == Planet.meanNode ||
                planet1 == Planet.trueNode ||
                planet2 == Planet.meanNode ||
                planet2 == Planet.trueNode)) {
          continue;
        }

        final pos1 = positions[planet1]!;
        final pos2 = positions[planet2]!;

        // Check for aspects from planet1 to planet2
        final aspectsFrom1 = _getAspectsBetween(
          planet1,
          pos1,
          planet2,
          pos2,
          config,
        );
        aspects.addAll(aspectsFrom1);

        // Check for aspects from planet2 to planet1 (reverse)
        final aspectsFrom2 = _getAspectsBetween(
          planet2,
          pos2,
          planet1,
          pos1,
          config,
        );
        aspects.addAll(aspectsFrom2);
      }
    }

    // Remove duplicate aspects and filter by minimum strength
    final uniqueAspects = <AspectInfo>[];
    for (final aspect in aspects) {
      if (aspect.strength >= config.minimumStrength) {
        final isDuplicate = uniqueAspects.any((a) =>
            (a.aspectingPlanet == aspect.aspectingPlanet &&
                a.aspectedPlanet == aspect.aspectedPlanet &&
                a.type == aspect.type) ||
            (a.aspectingPlanet == aspect.aspectedPlanet &&
                a.aspectedPlanet == aspect.aspectingPlanet &&
                a.type == aspect.type));
        if (!isDuplicate) {
          uniqueAspects.add(aspect);
        }
      }
    }

    return uniqueAspects;
  }

  /// Gets aspects for a specific planet.
  ///
  /// [planet] - The planet to get aspects for
  /// [positions] - All planetary positions
  /// [config] - Configuration for aspect calculations
  ///
  /// Returns aspects where the planet is either aspecting or aspected.
  List<AspectInfo> getAspectsForPlanet(
    Planet planet,
    Map<Planet, PlanetPosition> positions, {
    AspectConfig config = AspectConfig.vedic,
  }) {
    final allAspects = calculateAspects(positions, config: config);
    return allAspects
        .where((a) => a.aspectingPlanet == planet || a.aspectedPlanet == planet)
        .toList();
  }

  /// Gets aspects cast by a specific planet (where it is the aspecting planet).
  List<AspectInfo> getAspectsCastBy(
    Planet planet,
    Map<Planet, PlanetPosition> positions, {
    AspectConfig config = AspectConfig.vedic,
  }) {
    final allAspects = calculateAspects(positions, config: config);
    return allAspects.where((a) => a.aspectingPlanet == planet).toList();
  }

  /// Gets aspects received by a specific planet (where it is the aspected planet).
  List<AspectInfo> getAspectsReceivedBy(
    Planet planet,
    Map<Planet, PlanetPosition> positions, {
    AspectConfig config = AspectConfig.vedic,
  }) {
    final allAspects = calculateAspects(positions, config: config);
    return allAspects.where((a) => a.aspectedPlanet == planet).toList();
  }

  /// Internal: Find aspects between two planets.
  List<AspectInfo> _getAspectsBetween(
    Planet planet1,
    PlanetPosition pos1,
    Planet planet2,
    PlanetPosition pos2,
    AspectConfig config,
  ) {
    final aspects = <AspectInfo>[];

    if (config.useWholeSignAspects) {
      // —— WHOLE-SIGN VEDIC ASPECTS ——
      // Convert both planets to their sign index (0-11)
      final sign1 = (pos1.longitude / 30).floor() % 12;
      final sign2 = (pos2.longitude / 30).floor() % 12;
      // Forward distance from planet1’s sign to planet2’s sign
      final d = (sign2 - sign1 + 12) % 12;

      // Conjunction: same sign (d == 0)
      if (d == 0) {
        aspects.add(_createWholeSignAspect(
            planet1, pos1, planet2, pos2, AspectType.conjunction));
      }

      // 7th house: all planets aspect the sign 6 signs ahead
      if (d == 6) {
        aspects.add(_createWholeSignAspect(
            planet1, pos1, planet2, pos2, AspectType.opposition));
      }

      // Special aspects (only when configured)
      if (config.includeSpecialAspects) {
        // Mars: 4th (d==3) and 8th (d==7)
        if (planet1 == Planet.mars) {
          if (d == 3) {
            aspects.add(_createWholeSignAspect(
                planet1, pos1, planet2, pos2, AspectType.marsSpecial4th));
          }
          if (d == 7) {
            aspects.add(_createWholeSignAspect(
                planet1, pos1, planet2, pos2, AspectType.marsSpecial8th));
          }
        }
        // Jupiter: 5th (d==4) and 9th (d==8)
        if (planet1 == Planet.jupiter) {
          if (d == 4) {
            aspects.add(_createWholeSignAspect(
                planet1, pos1, planet2, pos2, AspectType.jupiterSpecial5th));
          }
          if (d == 8) {
            aspects.add(_createWholeSignAspect(
                planet1, pos1, planet2, pos2, AspectType.jupiterSpecial9th));
          }
        }
        // Saturn: 3rd (d==2) and 10th (d==9)
        if (planet1 == Planet.saturn) {
          if (d == 2) {
            aspects.add(_createWholeSignAspect(
                planet1, pos1, planet2, pos2, AspectType.saturnSpecial3rd));
          }
          if (d == 9) {
            aspects.add(_createWholeSignAspect(
                planet1, pos1, planet2, pos2, AspectType.saturnSpecial10th));
          }
        }
      }
    } else {
      // —— DEGREE-BASED WESTERN ASPECTS (KP / Western tropical) ——
      final angularDiff =
          _calculateAngularDifference(pos1.longitude, pos2.longitude);

      // Conjunction
      final conjunctionOrb = _getOrb(AspectType.conjunction, config);
      if (angularDiff.abs() <= conjunctionOrb) {
        aspects.add(_createAspect(planet1, pos1, planet2, pos2,
            AspectType.conjunction, angularDiff, config));
      }

      // 7th house aspect (opposition)
      final oppositionOrb = _getOrb(AspectType.opposition, config);
      final oppDiff = (angularDiff - 180).abs();
      if (oppDiff <= oppositionOrb) {
        aspects.add(_createAspect(planet1, pos1, planet2, pos2,
            AspectType.opposition, 180 - angularDiff.abs(), config));
      }

      // Special aspects
      if (config.includeSpecialAspects) {
        aspects.addAll(_checkSpecialAspects(
            planet1, pos1, planet2, pos2, angularDiff, config));
      }
    }

    return aspects;
  }

  /// Internal: Check for special planetary aspects (Mars, Jupiter, Saturn).
  List<AspectInfo> _checkSpecialAspects(
    Planet planet1,
    PlanetPosition pos1,
    Planet planet2,
    PlanetPosition pos2,
    double angularDiff,
    AspectConfig config,
  ) {
    final aspects = <AspectInfo>[];

    // Mars special aspects: 4th (90°) and 8th (210°)
    if (planet1 == Planet.mars) {
      final orb4th = _getOrb(AspectType.marsSpecial4th, config);
      final orb8th = _getOrb(AspectType.marsSpecial8th, config);

      if ((angularDiff - 90).abs() <= orb4th) {
        aspects.add(_createAspect(
          planet1,
          pos1,
          planet2,
          pos2,
          AspectType.marsSpecial4th,
          angularDiff - 90,
          config,
        ));
      }
      if ((angularDiff - 210).abs() <= orb8th) {
        aspects.add(_createAspect(
          planet1,
          pos1,
          planet2,
          pos2,
          AspectType.marsSpecial8th,
          angularDiff - 210,
          config,
        ));
      }
    }

    // Jupiter special aspects: 5th (120°) and 9th (240°)
    if (planet1 == Planet.jupiter) {
      final orb5th = _getOrb(AspectType.jupiterSpecial5th, config);
      final orb9th = _getOrb(AspectType.jupiterSpecial9th, config);

      if ((angularDiff - 120).abs() <= orb5th) {
        aspects.add(_createAspect(
          planet1,
          pos1,
          planet2,
          pos2,
          AspectType.jupiterSpecial5th,
          angularDiff - 120,
          config,
        ));
      }
      if ((angularDiff - 240).abs() <= orb9th) {
        aspects.add(_createAspect(
          planet1,
          pos1,
          planet2,
          pos2,
          AspectType.jupiterSpecial9th,
          angularDiff - 240,
          config,
        ));
      }
    }

    // Saturn special aspects: 3rd (60°) and 10th (270°)
    if (planet1 == Planet.saturn) {
      final orb3rd = _getOrb(AspectType.saturnSpecial3rd, config);
      final orb10th = _getOrb(AspectType.saturnSpecial10th, config);

      if ((angularDiff - 60).abs() <= orb3rd) {
        aspects.add(_createAspect(
          planet1,
          pos1,
          planet2,
          pos2,
          AspectType.saturnSpecial3rd,
          angularDiff - 60,
          config,
        ));
      }
      if ((angularDiff - 270).abs() <= orb10th) {
        aspects.add(_createAspect(
          planet1,
          pos1,
          planet2,
          pos2,
          AspectType.saturnSpecial10th,
          angularDiff - 270,
          config,
        ));
      }
    }

    return aspects;
  }

  /// Internal: Calculate angular difference (0-360°).
  double _calculateAngularDifference(double lon1, double lon2) {
    var diff = (lon2 - lon1) % 360;
    if (diff < 0) diff += 360;
    return diff;
  }

  /// Internal: Get orb for an aspect type.
  double _getOrb(AspectType type, AspectConfig config) {
    return config.customOrbs?[type] ?? type.defaultOrb;
  }

  /// Internal: Create a whole-sign aspect (strength always 1.0, orb = 0).
  AspectInfo _createWholeSignAspect(
    Planet planet1,
    PlanetPosition pos1,
    Planet planet2,
    PlanetPosition pos2,
    AspectType type,
  ) {
    return AspectInfo(
      aspectingPlanet: planet1,
      aspectedPlanet: planet2,
      type: type,
      exactOrb: 0.0,
      isApplying: false, // not meaningful for whole-sign
      strength: 1.0, // full strength — whole signs are binary
      aspectingLongitude: pos1.longitude,
      aspectedLongitude: pos2.longitude,
    );
  }

  /// Internal: Create an AspectInfo.
  AspectInfo _createAspect(
    Planet planet1,
    PlanetPosition pos1,
    Planet planet2,
    PlanetPosition pos2,
    AspectType type,
    double orb,
    AspectConfig config,
  ) {
    // Determine if applying or separating based on speeds
    final speedDiff = pos1.longitudeSpeed - pos2.longitudeSpeed;
    final isApplying = (orb > 0 && speedDiff > 0) || (orb < 0 && speedDiff < 0);

    // Calculate strength (1.0 at exact, decreasing with orb)
    final maxOrb = _getOrb(type, config);
    final strength = 1.0 - (orb.abs() / maxOrb).clamp(0.0, 1.0);

    return AspectInfo(
      aspectingPlanet: planet1,
      aspectedPlanet: planet2,
      type: type,
      exactOrb: orb,
      isApplying: isApplying,
      strength: strength,
      aspectingLongitude: pos1.longitude,
      aspectedLongitude: pos2.longitude,
    );
  }

  /// Gets planets aspecting a specific house/sign.
  ///
  /// [houseSignIndex] - The sign index (0-11) to check
  /// [positions] - All planetary positions
  /// [useWholeSign] - Use whole-sign model (default: true, Vedic standard)
  ///
  /// Returns list of planets that aspect the sign.
  List<Planet> getPlanetsAspectingSign(
    int houseSignIndex,
    Map<Planet, PlanetPosition> positions, {
    bool useWholeSign = true,
  }) {
    final aspectingPlanets = <Planet>[];

    for (final entry in positions.entries) {
      final planet = entry.key;
      final pos = entry.value;

      if (useWholeSign) {
        // Whole-sign model: purely sign-index arithmetic
        final planetSign = (pos.longitude / 30).floor() % 12;
        final d = (houseSignIndex - planetSign + 12) % 12;

        // 7th aspect (all planets)
        if (d == 6) {
          aspectingPlanets.add(planet);
          continue;
        }
        // Conjunction (same sign)
        if (d == 0) {
          aspectingPlanets.add(planet);
          continue;
        }
        // Mars special: 4th (d==3) and 8th (d==7)
        if (planet == Planet.mars && (d == 3 || d == 7)) {
          aspectingPlanets.add(planet);
          continue;
        }
        // Jupiter special: 5th (d==4) and 9th (d==8)
        if (planet == Planet.jupiter && (d == 4 || d == 8)) {
          aspectingPlanets.add(planet);
          continue;
        }
        // Saturn special: 3rd (d==2) and 10th (d==9)
        if (planet == Planet.saturn && (d == 2 || d == 9)) {
          aspectingPlanets.add(planet);
          continue;
        }
      } else {
        // Degree-based fallback (± 15° orb around sign midpoint)
        final targetMidpoint = (houseSignIndex * 30) + 15;
        final angularDiff = _calculateAngularDifference(
            pos.longitude, targetMidpoint.toDouble());

        if ((angularDiff - 180).abs() <= 15) {
          aspectingPlanets.add(planet);
          continue;
        }
        if (planet == Planet.mars &&
            ((angularDiff - 90).abs() <= 15 ||
                (angularDiff - 210).abs() <= 15)) {
          aspectingPlanets.add(planet);
          continue;
        }
        if (planet == Planet.jupiter &&
            ((angularDiff - 120).abs() <= 15 ||
                (angularDiff - 240).abs() <= 15)) {
          aspectingPlanets.add(planet);
          continue;
        }
        if (planet == Planet.saturn &&
            ((angularDiff - 60).abs() <= 15 ||
                (angularDiff - 270).abs() <= 15)) {
          aspectingPlanets.add(planet);
          continue;
        }
      }
    }

    return aspectingPlanets;
  }
}
