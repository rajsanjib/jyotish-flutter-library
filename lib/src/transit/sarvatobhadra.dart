import 'package:jyotish/src/models/planet.dart';
import 'package:jyotish/src/models/vedic_chart.dart';

enum VedhaSeverity {
  mild('Mild', 'Slight obstructive or supportive effect.'),
  moderate('Moderate', 'Noticeable impact on related affairs.'),
  severe('Severe', 'Strong obstruction from malefic planets.'),
  benefic('Benefic', 'Strong support from benefic planets.');

  const VedhaSeverity(this.name, this.description);
  final String name;
  final String description;
}

class SarvatobhadraVedha {
  const SarvatobhadraVedha({
    required this.transitPlanet,
    required this.transitNakshatra,
    required this.aspectedNakshatras,
    required this.aspectsNatalMoon,
    required this.aspectsNatalAscendant,
    required this.aspectsNatalSun,
    required this.severity,
  });

  /// The transiting planet causing the Vedha
  final Planet transitPlanet;

  /// The nakshatra (1-27) the planet is transiting
  final int transitNakshatra;

  /// The nakshatras receiving Vedha (aspect) from this transit
  final List<int> aspectedNakshatras;

  /// True if the Vedha hits the natal Moon's nakshatra
  final bool aspectsNatalMoon;

  /// True if the Vedha hits the natal Ascendant's nakshatra
  final bool aspectsNatalAscendant;

  /// True if the Vedha hits the natal Sun's nakshatra
  final bool aspectsNatalSun;

  /// The severity/nature of this Vedha
  final VedhaSeverity severity;
}

class SarvatobhadraAnalysis {
  const SarvatobhadraAnalysis({
    required this.natalChart,
    required this.transitVedhas,
    required this.favorableTransits,
    required this.unfavorableTransits,
  });

  /// The original birth chart
  final VedicChart natalChart;

  /// Detailed Vedha information for each transiting planet
  final Map<Planet, SarvatobhadraVedha> transitVedhas;

  /// Benefic planets casting positive Vedhas
  final List<Planet> favorableTransits;

  /// Malefic planets casting obstructive Vedhas
  final List<Planet> unfavorableTransits;
}
