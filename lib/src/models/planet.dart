import '../constants/planet_constants.dart';

/// Enumeration of planets and celestial bodies supported by Swiss Ephemeris.
enum Planet {
  /// The Sun
  sun(SwissEphConstants.sun, 'Sun'),

  /// The Moon
  moon(SwissEphConstants.moon, 'Moon'),

  /// Mercury
  mercury(SwissEphConstants.mercury, 'Mercury'),

  /// Venus
  venus(SwissEphConstants.venus, 'Venus'),

  /// Mars
  mars(SwissEphConstants.mars, 'Mars'),

  /// Jupiter
  jupiter(SwissEphConstants.jupiter, 'Jupiter'),

  /// Saturn
  saturn(SwissEphConstants.saturn, 'Saturn'),

  /// Uranus
  uranus(SwissEphConstants.uranus, 'Uranus'),

  /// Neptune
  neptune(SwissEphConstants.neptune, 'Neptune'),

  /// Pluto
  pluto(SwissEphConstants.pluto, 'Pluto'),

  /// Mean Lunar Node (Rahu in Vedic astrology)
  meanNode(SwissEphConstants.meanNode, 'Rahu'),

  /// True Lunar Node (True Rahu)
  trueNode(SwissEphConstants.trueNode, 'Rahu (True)'),

  /// Ketu (South Lunar Node) - the descending node, opposite to Rahu
  ketu(SwissEphConstants.ketu, 'Ketu'),

  /// Mean Lunar Apogee (Black Moon Lilith)
  meanApogee(SwissEphConstants.meanApog, 'Mean Apogee'),

  /// Osculating Lunar Apogee
  osculatingApogee(SwissEphConstants.oscuApog, 'Osculating Apogee'),

  /// Earth (for heliocentric calculations)
  earth(SwissEphConstants.earthPlanet, 'Earth'),

  /// Chiron
  chiron(SwissEphConstants.chiron, 'Chiron'),

  /// Pholus
  pholus(SwissEphConstants.pholus, 'Pholus'),

  /// Ceres
  ceres(SwissEphConstants.ceres, 'Ceres'),

  /// Pallas
  pallas(SwissEphConstants.pallas, 'Pallas'),

  /// Juno
  juno(SwissEphConstants.juno, 'Juno'),

  /// Vesta
  vesta(SwissEphConstants.vesta, 'Vesta');

  const Planet(this.swissEphId, this.displayName);

  /// The Swiss Ephemeris constant for this planet
  final int swissEphId;

  /// The display name of this planet
  final String displayName;

  /// Returns a list of major planets (Sun through Pluto).
  static List<Planet> get majorPlanets => [
        sun,
        moon,
        mercury,
        venus,
        mars,
        jupiter,
        saturn,
        uranus,
        neptune,
        pluto,
      ];

  /// Returns a list of traditional planets (Sun through Saturn).
  static List<Planet> get traditionalPlanets => [
        sun,
        moon,
        mercury,
        venus,
        mars,
        jupiter,
        saturn,
      ];

  /// Returns a list of outer planets (Uranus, Neptune, Pluto).
  static List<Planet> get outerPlanets => [
        uranus,
        neptune,
        pluto,
      ];

  /// Returns a list of lunar nodes.
  static List<Planet> get lunarNodes => [
        meanNode,
        trueNode,
        ketu,
      ];

  /// Returns a list of lunar apogees.
  static List<Planet> get lunarApogees => [
        meanApogee,
        osculatingApogee,
      ];

  /// Returns a list of asteroids/minor planets.
  static List<Planet> get asteroids => [
        chiron,
        pholus,
        ceres,
        pallas,
        juno,
        vesta,
      ];

  /// Returns all planets and celestial bodies.
  static List<Planet> get all => Planet.values;

  @override
  String toString() => displayName;

  /// Gets a planet by its Swiss Ephemeris ID.
  static Planet? fromSwissEphId(int id) {
    try {
      return Planet.values.firstWhere((planet) => planet.swissEphId == id);
    } catch (e) {
      return null;
    }
  }

  /// Gets a planet by its display name (case-insensitive).
  static Planet? fromName(String name) {
    try {
      return Planet.values.firstWhere(
        (planet) => planet.displayName.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}
