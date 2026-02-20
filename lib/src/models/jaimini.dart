import 'planet.dart';
import 'rashi.dart';

/// Represents the Karakamsa (Atmakaraka's sign in Navamsa).
class KarakamsaInfo {
  const KarakamsaInfo({
    required this.atmakaraka,
    required this.karakamsaSign,
    required this.karakamsaHouse,
  });

  /// The Atmakaraka planet (planet with highest degree).
  final Planet atmakaraka;

  /// The sign where Atmakaraka is placed in the Navamsa chart.
  final Rashi karakamsaSign;

  /// The house number from Navamsa Lagna where Karakamsa falls.
  final int karakamsaHouse;
}

/// Represents Rashi Drishti (Sign aspects in Jaimini system).
class RashiDrishtiInfo {
  const RashiDrishtiInfo({
    required this.aspectingSign,
    required this.aspectedSign,
    this.planetsInAspectingSign = const [],
    this.planetsInAspectedSign = const [],
  });

  /// The sign casting the aspect.
  final Rashi aspectingSign;

  /// The sign receiving the aspect.
  final Rashi aspectedSign;

  /// Planets in the aspecting sign.
  final List<Planet> planetsInAspectingSign;

  /// Planets in the aspected sign.
  final List<Planet> planetsInAspectedSign;
}
