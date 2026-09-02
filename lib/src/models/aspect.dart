import 'package:jyotish/src/models/planet.dart';

/// Vedic aspect types (Graha Drishti).
///
/// In Vedic astrology, all planets cast their full aspect on the 7th house/sign
/// from their position. Additionally, Mars, Jupiter, and Saturn have special
/// aspects (vishesh drishti).
enum AspectType {
  /// Conjunction - planets in same sign (0 degrees separation).
  conjunction('Conjunction', 'Yuti', 0, 10.0),

  /// Opposition - 7th house aspect (180 degrees separation) - All planets have this.
  opposition('Opposition', 'Sama-Saptama', 180, 10.0),

  /// Trine - 5th house aspect (120 degrees separation).
  trine5th('5th Trine', 'Trikona (5th)', 120, 8.0),

  /// Trine - 9th house aspect (240 degrees separation).
  trine9th('9th Trine', 'Trikona (9th)', 240, 8.0),

  /// Square - 4th house aspect (90 degrees separation).
  square4th('4th Square', 'Kendra (4th)', 90, 6.0),

  /// Square - 10th house aspect (270 degrees separation).
  square10th('10th Square', 'Kendra (10th)', 270, 6.0),

  /// Sextile - 3rd house aspect (60 degrees separation).
  sextile3rd('3rd Sextile', 'Upachaya (3rd)', 60, 4.0),

  /// Sextile - 11th house aspect (300 degrees separation).
  sextile11th('11th Sextile', 'Upachaya (11th)', 300, 4.0),

  /// Mars special 4th house aspect (Vishesh Drishti).
  marsSpecial4th('Mars 4th Aspect', 'Mangal Drishti (4th)', 90, 10.0),

  /// Mars special 8th house aspect (Vishesh Drishti).
  marsSpecial8th('Mars 8th Aspect', 'Mangal Drishti (8th)', 210, 10.0),

  /// Jupiter special 5th house aspect (Vishesh Drishti).
  jupiterSpecial5th('Jupiter 5th Aspect', 'Guru Drishti (5th)', 120, 10.0),

  /// Jupiter special 9th house aspect (Vishesh Drishti).
  jupiterSpecial9th('Jupiter 9th Aspect', 'Guru Drishti (9th)', 240, 10.0),

  /// Saturn special 3rd house aspect (Vishesh Drishti).
  saturnSpecial3rd('Saturn 3rd Aspect', 'Shani Drishti (3rd)', 60, 10.0),

  /// Saturn special 10th house aspect (Vishesh Drishti).
  saturnSpecial10th('Saturn 10th Aspect', 'Shani Drishti (10th)', 270, 10.0);

  const AspectType(this.english, this.sanskrit, this.angle, this.defaultOrb);

  /// English name of the aspect.
  final String english;

  /// Sanskrit/Hindi name of the aspect.
  final String sanskrit;

  /// The nominal angle of the aspect in degrees.
  final double angle;

  /// Default orb allowance for this aspect when using degree-based calculations.
  final double defaultOrb;

  @override
  String toString() => english;

  /// Whether this is a special aspect (Mars, Jupiter, or Saturn's unique Vishesh Drishti).
  bool get isSpecialAspect =>
      this == marsSpecial4th ||
      this == marsSpecial8th ||
      this == jupiterSpecial5th ||
      this == jupiterSpecial9th ||
      this == saturnSpecial3rd ||
      this == saturnSpecial10th;

  /// Whether this is traditionally considered a benefic aspect (trines and Jupiter's special aspects).
  bool get isBenefic =>
      this == trine5th ||
      this == trine9th ||
      this == jupiterSpecial5th ||
      this == jupiterSpecial9th;

  /// Whether this is traditionally considered a malefic aspect (squares and Mars/Saturn's special aspects).
  bool get isMalefic =>
      this == square4th ||
      this == square10th ||
      this == marsSpecial4th ||
      this == marsSpecial8th ||
      this == saturnSpecial3rd ||
      this == saturnSpecial10th;
}

/// Detailed information about an aspect between two planets.
///
/// Contains the aspect type, angular separation (orb), strength, and
/// whether the planets are moving toward (applying) or away from (separating) the aspect.
class AspectInfo {
  /// Creates a new [AspectInfo] record.
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

  /// The planet casting the aspect (the Graha).
  final Planet aspectingPlanet;

  /// The planet or point receiving the aspect.
  final Planet aspectedPlanet;

  /// The type of aspect being cast (e.g., 7th house opposition, Jupiter's 5th).
  final AspectType type;

  /// The absolute angular difference (in degrees) from the exact aspect angle.
  final double exactOrb;

  /// True if the planets are moving toward the exact aspect angle.
  final bool isApplying;

  /// True if the planets are moving away from the exact aspect angle.
  bool get isSeparating => !isApplying;

  /// The relative strength of the aspect (0.0 to 1.0).
  ///
  /// In whole-sign aspects, this is usually 1.0. In degree-based aspects,
  /// it scales linearly based on the proximity to the exact angle.
  final double strength;

  /// The longitudinal position of the aspecting planet.
  final double aspectingLongitude;

  /// The longitudinal position of the aspected planet or point.
  final double aspectedLongitude;

  /// Gets a human-readable description of the aspect.
  String get description {
    final applying = isApplying ? 'applying' : 'separating';
    return '${aspectingPlanet.displayName} ${type.english} ${aspectedPlanet.displayName} ($applying, orb: ${exactOrb.toStringAsFixed(2)})';
  }

  /// Whether the aspect is extremely close (orb < 1 degree).
  bool get isExact => exactOrb.abs() < 1.0;

  /// Whether the aspect is considered tight (orb < 3 degrees).
  bool get isTight => exactOrb.abs() < 3.0;

  @override
  String toString() => description;

  /// Converts the aspect information to a JSON-compatible map.
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

/// Configuration settings for calculating planetary aspects (Graha Drishti).
class AspectConfig {
  /// Creates a custom configuration for aspect calculations.
  const AspectConfig({
    this.includeSpecialAspects = true,
    this.customOrbs,
    this.minimumStrength = 0.0,
    this.includeNodes = true,
    this.useWholeSignAspects = true,
  });

  /// Whether to include the special aspects of Mars, Jupiter, and Saturn (Vishesh Drishti).
  final bool includeSpecialAspects;

  /// Optional map of custom orb values for specific aspect types, overriding defaults.
  final Map<AspectType, double>? customOrbs;

  /// Minimum strength threshold (0.0 to 1.0) required for an aspect to be returned.
  final double minimumStrength;

  /// Whether to include aspects involving Rahu and Ketu (Lunar Nodes).
  final bool includeNodes;

  /// Whether to use whole-sign (sign-to-sign) Vedic aspects.
  ///
  /// When `true` (default), a planet aspects an entire sign regardless of
  /// degree separation per the classical Parashari Graha Drishti model.
  /// Aspect strength is always 1.0 (binary).
  ///
  /// When `false`, degree-based orb calculations are used (suitable for
  /// Western astrology, KP, or custom research).
  final bool useWholeSignAspects;

  /// Default configuration for classical Vedic (Parashari) astrology.
  ///
  /// Uses whole-sign aspects per BPHS standards.
  static const AspectConfig vedic = AspectConfig(
    includeSpecialAspects: true,
    includeNodes: true,
    minimumStrength: 0.0,
    useWholeSignAspects: true,
  );

  /// Configuration for Western or KP-style astrology (degree-based orb aspects).
  static const AspectConfig western = AspectConfig(
    includeSpecialAspects: false,
    includeNodes: false,
    minimumStrength: 0.0,
    useWholeSignAspects: false,
  );
}
