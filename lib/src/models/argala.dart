import 'planet.dart';

/// Types of Argala (planetary intervention).
enum ArgalaType {
  primary('Primary', 'Planets in 2nd, 4th, 11th from a house'),
  secondary('Secondary', 'Planets in 5th from a house'),
  virodha('Virodha', 'Obstruction from 12th, 10th, 3rd');

  const ArgalaType(this.name, this.description);
  final String name;
  final String description;
}

/// Represents an Argala (planetary intervention) on a house or planet.
class ArgalaInfo {
  const ArgalaInfo({
    required this.sourceHouse,
    required this.targetHouse,
    required this.type,
    required this.causingPlanets,
    required this.isObstructed,
    this.obstructingPlanets = const [],
    this.strength = 1.0,
  });

  /// The house from which Argala is caused.
  final int sourceHouse;

  /// The house receiving the Argala.
  final int targetHouse;

  /// Type of Argala.
  final ArgalaType type;

  /// Planets causing the Argala.
  final List<Planet> causingPlanets;

  /// Whether this Argala is obstructed (Virodha Argala).
  final bool isObstructed;

  /// Planets causing obstruction to the Argala.
  final List<Planet> obstructingPlanets;

  /// Strength of the Argala (0.0 to 1.0).
  /// 1.0 = unobstructed, reduced if obstructed.
  final double strength;
}
