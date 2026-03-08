import 'package:jyotish/src/models/planet.dart';
import 'package:jyotish/src/models/vedic_chart.dart';
import 'package:jyotish/src/strength/strength_report.dart';
import 'package:jyotish/src/systems/shadbala_service.dart';
import 'package:jyotish/src/strength/house_strength_service.dart';
import 'package:jyotish/src/strength/graha_avastha_service.dart';
import 'package:jyotish/src/strength/strength_analysis_service.dart';

/// Aggregates all planetary strength metrics into a unified report.
class StrengthReportService {
  StrengthReportService({
    required ShadbalaService shadbalaService,
    required HouseStrengthService houseStrengthService,
    required GrahaAvasthaService grahaAvasthaService,
    required StrengthAnalysisService strengthAnalysisService,
  })  : _shadbalaService = shadbalaService,
        _houseStrengthService = houseStrengthService,
        _grahaAvasthaService = grahaAvasthaService,
        _strengthAnalysisService = strengthAnalysisService;

  final ShadbalaService _shadbalaService;
  final HouseStrengthService _houseStrengthService;
  final GrahaAvasthaService _grahaAvasthaService;
  final StrengthAnalysisService _strengthAnalysisService;

  /// Defines the minimum Shadbala required (in Virupas) for standard evaluation.
  /// Copied from ShadbalaService since it's private there.
  static const _minimumShadbala = {
    Planet.sun: 390.0, // 6.5 Rupas
    Planet.moon: 360.0, // 6.0 Rupas
    Planet.mars: 300.0, // 5.0 Rupas
    Planet.mercury: 420.0, // 7.0 Rupas
    Planet.jupiter: 390.0, // 6.5 Rupas
    Planet.venus: 330.0, // 5.5 Rupas
    Planet.saturn: 300.0, // 5.0 Rupas
  };

  /// Generates a comprehensive ChartStrengthReport for a given chart.
  Future<ChartStrengthReport> generateChartReport(VedicChart chart) async {
    // Compute all required data
    final shadbalas = await _shadbalaService.calculateShadbala(chart);
    final vimsopakas = _houseStrengthService.calculateVimsopakaBala(chart);
    final avasthas = _grahaAvasthaService.calculateAllAvasthas(chart);

    // Sort planets by Shadbala total bala to determine ranks
    final sortedByShadbala = shadbalas.entries.toList()
      ..sort((a, b) => b.value.totalBala.compareTo(a.value.totalBala));

    final ranks = <Planet, int>{};
    for (int i = 0; i < sortedByShadbala.length; i++) {
      ranks[sortedByShadbala[i].key] = i + 1;
    }

    final byPlanet = <Planet, PlanetStrengthReport>{};
    final aboveMinimum = <Planet>[];

    for (final entry in chart.planets.entries) {
      final planet = entry.key;
      final info = entry.value;

      // Skip nodes as they don't have standard Shadbala
      if (Planet.lunarNodes.contains(planet)) continue;

      final sbResult = shadbalas[planet]!;
      final vimResult = vimsopakas[planet]!;
      final avastha = avasthas[planet];

      // Convert Virupas to Rupas (1 Rupa = 60 Virupas)
      final totalRupas = sbResult.totalBala / 60.0;

      // Check if above minimum
      final requiredBala = _minimumShadbala[planet] ?? 300.0;
      if (sbResult.totalBala >= requiredBala) {
        aboveMinimum.add(planet);
      }

      final ishtaphala = _strengthAnalysisService.getIshtaphala(
        planet: planet,
        chart: chart,
        shadbalaStrength: sbResult.totalBala,
      );

      final kashtaphala = _strengthAnalysisService.getKashtaphala(
        planet: planet,
        chart: chart,
        shadbalaStrength: sbResult.totalBala,
      );

      byPlanet[planet] = PlanetStrengthReport(
        planet: planet,
        dignity: info.dignity,
        shadbalaTotalRupas: totalRupas,
        shadbalaCategory: sbResult.strengthCategory,
        shadbalaRank: ranks[planet] ?? 7,
        vimshopakaBala: vimResult.totalScore,
        vimsopakaCategory: vimResult.category,
        avastha: avastha,
        isCombust: info.isCombust,
        isRetrograde: info.isRetrograde,
        ishtaphala: ishtaphala,
        kashtaphala: kashtaphala,
      );
    }

    return ChartStrengthReport(
      byPlanet: byPlanet,
      strongestPlanet: sortedByShadbala.first.key,
      weakestPlanet: sortedByShadbala.last.key,
      planetsAboveMinimum: aboveMinimum,
    );
  }

  /// Extracts a detailed PlanetStrengthReport for a specific planet.
  Future<PlanetStrengthReport> getPlanetReport(
      Planet planet, VedicChart chart) async {
    if (Planet.lunarNodes.contains(planet)) {
      throw ArgumentError(
          'Strength report is only available for 7 main planets');
    }
    final report = await generateChartReport(chart);
    return report.byPlanet[planet]!;
  }
}
