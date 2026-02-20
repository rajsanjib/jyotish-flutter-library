import '../models/argala.dart';
import '../models/planet.dart';
import '../models/vedic_chart.dart';

/// Service for calculating Jaimini Argala (planetary intervention).
class ArgalaService {
  /// Calculates all Argalas for all houses in a chart.
  Map<int, List<ArgalaInfo>> calculateAllArgalas(VedicChart chart) {
    final result = <int, List<ArgalaInfo>>{};
    for (var house = 1; house <= 12; house++) {
      result[house] = calculateArgalaForHouse(chart, house);
    }
    return result;
  }

  /// Calculates Argalas affecting a specific house.
  List<ArgalaInfo> calculateArgalaForHouse(VedicChart chart, int targetHouse) {
    final argalas = <ArgalaInfo>[];

    // Primary Argala from 2nd, 4th, 11th
    // 2nd house Argala
    _addArgalaIfPresent(
      chart: chart,
      targetHouse: targetHouse,
      sourceOffset: 2,
      obstructOffset: 12,
      type: ArgalaType.primary,
      argalas: argalas,
    );

    // 4th house Argala
    _addArgalaIfPresent(
      chart: chart,
      targetHouse: targetHouse,
      sourceOffset: 4,
      obstructOffset: 10,
      type: ArgalaType.primary,
      argalas: argalas,
    );

    // 11th house Argala
    _addArgalaIfPresent(
      chart: chart,
      targetHouse: targetHouse,
      sourceOffset: 11,
      obstructOffset: 3,
      type: ArgalaType.primary,
      argalas: argalas,
    );

    // Secondary Argala from 5th
    _addArgalaIfPresent(
      chart: chart,
      targetHouse: targetHouse,
      sourceOffset: 5,
      obstructOffset: 9, // 9th obstructs 5th Argala
      type: ArgalaType.secondary,
      argalas: argalas,
    );

    return argalas;
  }

  /// Calculates Argalas caused by a specific planet.
  List<ArgalaInfo> calculateArgalaForPlanet(VedicChart chart, Planet planet) {
    final planetInfo = chart.getPlanet(planet);
    if (planetInfo == null) return [];

    // Get house where planet is placed
    final planetHouse = planetInfo.house;

    // Calculate which houses this planet causes Argala on
    final argalas = <ArgalaInfo>[];

    // Planet causes Argala on houses for which it is in 2nd, 4th, 5th, or 11th
    // If planet in house X, it causes Argala on:
    // House X-1 (planet is in 2nd from X-1)
    // House X-3 (planet is in 4th from X-3)
    // House X-4 (planet is in 5th from X-4)
    // House X-10 (planet is in 11th from X-10)

    final housesArgaledByPlanet = [
      ((planetHouse - 2 + 12) % 12) + 1, // 2nd Argala target
      ((planetHouse - 4 + 12) % 12) + 1, // 4th Argala target
      ((planetHouse - 5 + 12) % 12) + 1, // 5th Argala target
      ((planetHouse - 11 + 12) % 12) + 1, // 11th Argala target
    ];

    for (final targetHouse in housesArgaledByPlanet) {
      final offset = ((planetHouse - targetHouse + 12) % 12) + 1;
      final type = (offset == 5) ? ArgalaType.secondary : ArgalaType.primary;

      argalas.add(ArgalaInfo(
        sourceHouse: planetHouse,
        targetHouse: targetHouse,
        type: type,
        causingPlanets: [planet],
        isObstructed: false, // Simplified - full check would verify obstruction
      ));
    }

    return argalas;
  }

  void _addArgalaIfPresent({
    required VedicChart chart,
    required int targetHouse,
    required int sourceOffset,
    required int obstructOffset,
    required ArgalaType type,
    required List<ArgalaInfo> argalas,
  }) {
    // Calculate source house
    final sourceHouse = ((targetHouse - 1 + sourceOffset) % 12) + 1;

    // Get planets in source house
    final planetsInSource = chart.getPlanetsInHouse(sourceHouse);
    if (planetsInSource.isEmpty) return; // No Argala if no planets

    // Calculate obstruction house
    final obstructHouse = ((targetHouse - 1 + obstructOffset) % 12) + 1;

    // Get planets in obstruction house
    final planetsInObstruct = chart.getPlanetsInHouse(obstructHouse);

    // Determine if obstructed
    // Argala is obstructed if planets in obstruction house >= planets in source
    final isObstructed = planetsInObstruct.length >= planetsInSource.length;

    // Calculate strength (reduced if obstructed)
    double strength = 1.0;
    if (planetsInObstruct.isNotEmpty) {
      strength = planetsInSource.length /
          (planetsInSource.length + planetsInObstruct.length);
    }

    argalas.add(ArgalaInfo(
      sourceHouse: sourceHouse,
      targetHouse: targetHouse,
      type: isObstructed ? ArgalaType.virodha : type,
      causingPlanets: planetsInSource.map((p) => p.planet).toList(),
      isObstructed: isObstructed,
      obstructingPlanets: planetsInObstruct.map((p) => p.planet).toList(),
      strength: strength,
    ));
  }
}
