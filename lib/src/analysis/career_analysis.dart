import 'package:jyotish/src/models/planet.dart';
import 'package:jyotish/src/models/rashi.dart';
import 'package:jyotish/src/models/vedic_chart.dart';

/// Categories representing the overall strength of the D-10 Dashamsha chart.
enum D10StrengthCategory {
  /// Highly favorable for career growth and authority.
  excellent('Excellent', 'Highly favorable for career growth and authority.'),

  /// Positive indicators for professional success.
  good('Good', 'Positive indicators for professional success.'),

  /// Standard career prospects with expected effort.
  average('Average', 'Standard career prospects with expected effort.'),

  /// Requires perseverance; obstacles possible.
  challenging('Challenging', 'Requires perseverance; obstacles possible.');

  const D10StrengthCategory(this.label, this.description);

  /// Human-readable label for the strength category.
  final String label;

  /// Detailed description of the career implications.
  final String description;
}

/// Represents a comprehensive career analysis based on the D-10 Dashamsha chart.
class D10CareerAnalysis {
  const D10CareerAnalysis({
    required this.d10Chart,
    required this.tenthLord,
    required this.tenthSign,
    required this.primaryDomains,
    required this.strongPlanets,
    required this.careerThemes,
    required this.overallStrength,
  });

  /// The calculated D-10 Dashamsha chart.
  final VedicChart d10Chart;

  /// The lord of the 10th house in the D-10 chart.
  final Planet tenthLord;

  /// The sign (Rashi) of the 10th house cusp in the D-10 chart.
  final Rashi tenthSign;

  /// Primary career fields or domains indicated by the 10th lord and other strong planets.
  final List<String> primaryDomains;

  /// Planets that are exceptionally strong (exalted, own sign, or Moola Trikona) in D-10.
  final List<Planet> strongPlanets;

  /// Key interpretive themes and professional characteristics derived from the chart.
  final List<String> careerThemes;

  /// The overall strength assessment of the professional life and authority.
  final D10StrengthCategory overallStrength;
}
