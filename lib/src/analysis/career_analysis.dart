import 'package:jyotish/src/models/planet.dart';
import 'package:jyotish/src/models/rashi.dart';
import 'package:jyotish/src/models/vedic_chart.dart';

enum D10StrengthCategory {
  excellent('Excellent', 'Highly favorable for career growth and authority.'),
  good('Good', 'Positive indicators for professional success.'),
  average('Average', 'Standard career prospects with expected effort.'),
  challenging('Challenging', 'Requires perseverance; obstacles possible.');

  const D10StrengthCategory(this.label, this.description);
  final String label;
  final String description;
}

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

  /// The calculated D-10 Dashamsha chart
  final VedicChart d10Chart;

  /// The lord of the 10th house in D-10
  final Planet tenthLord;

  /// The sign of the 10th house in D-10
  final Rashi tenthSign;

  /// Primary career fields indicated by the 10th lord and strong planets
  final List<String> primaryDomains;

  /// Planets that are strong (exalted, own sign, Moola Trikona) in D-10
  final List<Planet> strongPlanets;

  /// Interpretive strings for the user
  final List<String> careerThemes;

  /// The overall strength assessment of the D-10 chart
  final D10StrengthCategory overallStrength;
}
