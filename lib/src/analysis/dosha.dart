import '../models/planet.dart';
import 'compatibility.dart'; // To reuse ManglikDoshaResult

/// Result of Kala Sarpa Dosha check.
class KalaSarpaDoshaResult {
  const KalaSarpaDoshaResult({
    required this.hasDosha,
    required this.type,
    required this.description,
  });

  /// True if Kala Sarpa Dosha is present.
  final bool hasDosha;

  /// The type of Kala Sarpa Dosha (e.g. "Anant", "Kulik", "None").
  final String type;

  /// Astrological description of the placement.
  final String description;
}

/// Result of Pitru Dosha check.
class PitruDoshaResult {
  const PitruDoshaResult({
    required this.hasDosha,
    required this.factorsMatched,
    required this.remedies,
  });

  /// True if Pitru Dosha is present.
  final bool hasDosha;

  /// Specific karmic rules/factors matched in the chart.
  final List<String> factorsMatched;

  /// Suggested remedies.
  final List<String> remedies;
}

/// Result of Guru Chandala Dosha check.
class GuruChandalaDoshaResult {
  const GuruChandalaDoshaResult({
    required this.hasDosha,
    required this.conjoiningNode,
    required this.jupiterIsStronger,
    required this.description,
  });

  /// True if Guru Chandala Dosha is present.
  final bool hasDosha;

  /// The node conjoining Jupiter (Rahu, Rahu True, or Ketu).
  final Planet? conjoiningNode;

  /// True if Jupiter is stronger than the node, mitigating the dosha.
  final bool jupiterIsStronger;

  /// Astrological description.
  final String description;
}

/// Result of Ganda Moola Dosha check.
class GandaMoolaDoshaResult {
  const GandaMoolaDoshaResult({
    required this.hasDosha,
    required this.nakshatra,
    required this.description,
  });

  /// True if Ganda Moola Dosha is present.
  final bool hasDosha;

  /// The Ganda Moola Nakshatra of birth.
  final String nakshatra;

  /// Detailed description.
  final String description;
}

/// Result of Kalathra Dosha check.
class KalathraDoshaResult {
  const KalathraDoshaResult({
    required this.hasDosha,
    required this.causingMalefics,
    required this.description,
  });

  /// True if Kalathra Dosha is present.
  final bool hasDosha;

  /// List of natural malefics causing the affliction in the spouse/partner houses.
  final List<Planet> causingMalefics;

  /// Detailed description.
  final String description;
}

/// Result of Ghata or Shrapit conjunction doshas.
class ConjunctionDoshaResult {
  const ConjunctionDoshaResult({
    required this.hasDosha,
    required this.name,
    required this.description,
  });

  /// True if the conjunction dosha is present.
  final bool hasDosha;

  /// Name of the dosha ("Ghata Dosha" or "Shrapit Dosha").
  final String name;

  /// Detailed description.
  final String description;
}

/// A comprehensive report of all individual natal doshas.
class FullDoshaReport {
  const FullDoshaReport({
    required this.kalaSarpa,
    required this.manglik,
    required this.pitru,
    required this.guruChandala,
    required this.gandaMoola,
    required this.kalathra,
    required this.ghata,
    required this.shrapit,
  });

  final KalaSarpaDoshaResult kalaSarpa;
  final ManglikDoshaResult manglik;
  final PitruDoshaResult pitru;
  final GuruChandalaDoshaResult guruChandala;
  final GandaMoolaDoshaResult gandaMoola;
  final KalathraDoshaResult kalathra;
  final ConjunctionDoshaResult ghata;
  final ConjunctionDoshaResult shrapit;
}
