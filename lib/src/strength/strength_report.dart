import 'package:jyotish/src/models/planet.dart';
import 'package:jyotish/src/models/vedic_chart.dart';
import 'package:jyotish/src/strength/graha_avastha.dart';

/// Represents the Shadbala categorical strength of a planet.
import 'package:jyotish/src/systems/shadbala_service.dart';
import 'package:jyotish/src/strength/house_strength.dart';

/// A comprehensive strength report for a single planet.
class PlanetStrengthReport {
  const PlanetStrengthReport({
    required this.planet,
    required this.dignity,
    required this.shadbalaTotalRupas,
    required this.shadbalaCategory,
    required this.shadbalaRank,
    required this.vimshopakaBala,
    required this.vimsopakaCategory,
    this.avastha,
    required this.isCombust,
    required this.isRetrograde,
    required this.ishtaphala,
    required this.kashtaphala,
  });

  final Planet planet;
  final PlanetaryDignity dignity;
  
  // Shadbala Metrics
  final double shadbalaTotalRupas;
  final ShadbalaStrength shadbalaCategory;
  final int shadbalaRank; // 1 to 7

  // Vimshopaka Metrics
  final double vimshopakaBala;
  final VimsopakaCategory vimsopakaCategory;

  // Avastha and State
  final GrahaAvastha? avastha;
  final bool isCombust;
  final bool isRetrograde;

  // Phala (Fruits)
  final double ishtaphala;
  final double kashtaphala;

  /// Returns a concise single-line summary of the planet's strength.
  String get summary {
    final dignStr = dignity.english;
    final sbStr = shadbalaCategory.name;
    final vimStr = vimsopakaCategory.name;
    final rkStr = '#$shadbalaRank';
    final combustStr = isCombust ? ' (Combust)' : '';
    final retroStr = isRetrograde ? ' (Retrograde)' : '';
    
    return '${planet.displayName}: $sbStr ($rkStr), $dignStr, Vimshopak: $vimStr$combustStr$retroStr';
  }
}

/// A comprehensive strength report for the entire chart.
class ChartStrengthReport {
  const ChartStrengthReport({
    required this.byPlanet,
    required this.strongestPlanet,
    required this.weakestPlanet,
    required this.planetsAboveMinimum,
  });

  /// The detailed structural reports mapped by planet.
  final Map<Planet, PlanetStrengthReport> byPlanet;

  /// The planet with the highest Shadbala in the chart.
  final Planet strongestPlanet;

  /// The planet with the lowest Shadbala in the chart.
  final Planet weakestPlanet;

  /// The planets that meet standard Shadbala minimum required strength.
  final List<Planet> planetsAboveMinimum;
}
