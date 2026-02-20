import 'planet.dart';

/// Vedic aspect types (Graha Drishti).
///
/// In Vedic astrology, all planets cast their full aspect on the 7th house/sign
/// from their position. Additionally, Mars, Jupiter, and Saturn have special
/// aspects (vishesh drishti).
enum AspectType {
  /// Conjunction - planets in same sign (0°)
  conjunction('Conjunction', 'Yuti', 0, 10.0),

  /// Opposition - 7th house aspect (180°) - All planets have this
  opposition('Opposition', 'Sama-Saptama', 180, 10.0),

  /// Trine - 5th house aspect (120°)
  trine5th('5th Trine', 'Trikona (5th)', 120, 8.0),

  /// Trine - 9th house aspect (240°)
  trine9th('9th Trine', 'Trikona (9th)', 240, 8.0),

  /// Square - 4th house aspect (90°)
  square4th('4th Square', 'Kendra (4th)', 90, 6.0),

  /// Square - 10th house aspect (270°)
  square10th('10th Square', 'Kendra (10th)', 270, 6.0),

  /// Sextile - 3rd house aspect (60°)
  sextile3rd('3rd Sextile', 'Upachaya (3rd)', 60, 4.0),

  /// Sextile - 11th house aspect (300°)
  sextile11th('11th Sextile', 'Upachaya (11th)', 300, 4.0),

  /// Mars special 4th house aspect
  marsSpecial4th('Mars 4th Aspect', 'Mangal Drishti (4th)', 90, 10.0),

  /// Mars special 8th house aspect
  marsSpecial8th('Mars 8th Aspect', 'Mangal Drishti (8th)', 210, 10.0),

  /// Jupiter special 5th house aspect
  jupiterSpecial5th('Jupiter 5th Aspect', 'Guru Drishti (5th)', 120, 10.0),

  /// Jupiter special 9th house aspect
  jupiterSpecial9th('Jupiter 9th Aspect', 'Guru Drishti (9th)', 240, 10.0),

  /// Saturn special 3rd house aspect
  saturnSpecial3rd('Saturn 3rd Aspect', 'Shani Drishti (3rd)', 60, 10.0),

  /// Saturn special 10th house aspect
  saturnSpecial10th('Saturn 10th Aspect', 'Shani Drishti (10th)', 270, 10.0);

  const AspectType(this.english, this.sanskrit, this.angle, this.defaultOrb);

  /// English name of the aspect
  final String english;

  /// Sanskrit/Hindi name of the aspect
  final String sanskrit;

  /// The angle of the aspect in degrees
  final double angle;

  /// Default orb allowance for this aspect
  final double defaultOrb;

  @override
  String toString() => english;

  /// Whether this is a special aspect (Mars, Jupiter, Saturn special aspects)
  bool get isSpecialAspect =>
      this == marsSpecial4th ||
      this == marsSpecial8th ||
      this == jupiterSpecial5th ||
      this == jupiterSpecial9th ||
      this == saturnSpecial3rd ||
      this == saturnSpecial10th;

  /// Whether this is a benefic aspect (trines, sextiles, Jupiter aspects)
  bool get isBenefic =>
      this == trine5th ||
      this == trine9th ||
      this == jupiterSpecial5th ||
      this == jupiterSpecial9th;

  /// Whether this is a malefic aspect (squares, Mars/Saturn special aspects)
  bool get isMalefic =>
      this == square4th ||
      this == square10th ||
      this == marsSpecial4th ||
      this == marsSpecial8th ||
      this == saturnSpecial3rd ||
      this == saturnSpecial10th;
}

/// Represents an aspect between two planets.
///
/// Contains detailed information about the planetary aspect including
/// the applying/separating status and aspect strength.
class AspectInfo {
  /// Creates a new aspect info.
  const AspectInfo({
    required this.aspectingPlanet,
    required this.aspectedPlanet,
    required this.type,
    required this.exactOrb,
    required this.isApplying,
    required this.strength,
    required this.aspectingLongitude,
    required this.aspectedLongitude,
  });

  /// The planet casting the aspect
  final Planet aspectingPlanet;

  /// The planet receiving the aspect
  final Planet aspectedPlanet;

  /// The type of aspect
  final AspectType type;

  /// The exact angular difference between planets
  final double exactOrb;

  /// Whether the aspect is applying (planets moving toward exact aspect)
  final bool isApplying;

  /// Whether the aspect is separating (planets moving away from exact aspect)
  bool get isSeparating => !isApplying;

  /// Aspect strength from 0.0 (weak) to 1.0 (exact)
  /// Calculated based on how close to exact the aspect is
  final double strength;

  /// Longitude of the aspecting planet
  final double aspectingLongitude;

  /// Longitude of the aspected planet
  final double aspectedLongitude;

  /// Gets a human-readable description of the aspect
  String get description {
    final applying = isApplying ? 'applying' : 'separating';
    return '${aspectingPlanet.displayName} ${type.english} ${aspectedPlanet.displayName} ($applying, orb: ${exactOrb.toStringAsFixed(2)}°)';
  }

  /// Whether the aspect is exact (orb less than 1°)
  bool get isExact => exactOrb.abs() < 1.0;

  /// Whether the aspect is tight (orb less than 3°)
  bool get isTight => exactOrb.abs() < 3.0;

  @override
  String toString() => description;

  /// Converts to JSON map
  Map<String, dynamic> toJson() => {
        'aspectingPlanet': aspectingPlanet.displayName,
        'aspectedPlanet': aspectedPlanet.displayName,
        'type': type.english,
        'exactOrb': exactOrb,
        'isApplying': isApplying,
        'strength': strength,
        'aspectingLongitude': aspectingLongitude,
        'aspectedLongitude': aspectedLongitude,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AspectInfo &&
        other.aspectingPlanet == aspectingPlanet &&
        other.aspectedPlanet == aspectedPlanet &&
        other.type == type;
  }

  @override
  int get hashCode => Object.hash(aspectingPlanet, aspectedPlanet, type);
}

/// Configuration for aspect calculations
class AspectConfig {
  const AspectConfig({
    this.includeSpecialAspects = true,
    this.customOrbs,
    this.minimumStrength = 0.0,
    this.includeNodes = true,
  });

  /// Whether to include special planetary aspects (Mars, Jupiter, Saturn)
  final bool includeSpecialAspects;

  /// Custom orb values for each aspect type (overrides defaults)
  final Map<AspectType, double>? customOrbs;

  /// Minimum strength threshold (0.0-1.0) to include an aspect
  final double minimumStrength;

  /// Whether to include Rahu/Ketu in aspect calculations
  final bool includeNodes;

  /// Default configuration for Vedic astrology
  static const AspectConfig vedic = AspectConfig(
    includeSpecialAspects: true,
    includeNodes: true,
    minimumStrength: 0.0,
  );
}
