import '../constants/planet_constants.dart';

/// Enumeration of planets and celestial bodies supported by Swiss Ephemeris.
enum Planet {
  /// The Sun
  sun(SwissEphConstants.sun, 'Sun', 'Sūrya'),

  /// The Moon
  moon(SwissEphConstants.moon, 'Moon', 'Candra'),

  /// Mercury
  mercury(SwissEphConstants.mercury, 'Mercury', 'Budha'),

  /// Venus
  venus(SwissEphConstants.venus, 'Venus', 'Śukra'),

  /// Mars
  mars(SwissEphConstants.mars, 'Mars', 'Maṅgala'),

  /// Jupiter
  jupiter(SwissEphConstants.jupiter, 'Jupiter', 'Guru'),

  /// Saturn
  saturn(SwissEphConstants.saturn, 'Saturn', 'Śani'),

  /// Uranus
  uranus(SwissEphConstants.uranus, 'Uranus', 'Uranus'),

  /// Neptune
  neptune(SwissEphConstants.neptune, 'Neptune', 'Neptune'),

  /// Pluto
  pluto(SwissEphConstants.pluto, 'Pluto', 'Pluto'),

  /// Mean Lunar Node (Rahu in Vedic astrology)
  meanNode(SwissEphConstants.meanNode, 'Rahu', 'Rāhu'),

  /// True Lunar Node (True Rahu)
  trueNode(SwissEphConstants.trueNode, 'Rahu (True)', 'Rāhu (True)'),

  /// Ketu (South Lunar Node) - the descending node, opposite to Rahu
  ketu(SwissEphConstants.ketu, 'Ketu', 'Ketu'),

  /// Mean Lunar Apogee (Black Moon Lilith)
  meanApogee(SwissEphConstants.meanApog, 'Mean Apogee', 'Mean Apogee'),

  /// Osculating Lunar Apogee
  osculatingApogee(
    SwissEphConstants.oscuApog,
    'Osculating Apogee',
    'Osculating Apogee',
  ),

  /// Earth (for heliocentric calculations)
  earth(SwissEphConstants.earthPlanet, 'Earth', 'Bhūmi'),

  /// Chiron
  chiron(SwissEphConstants.chiron, 'Chiron', 'Chiron'),

  /// Pholus
  pholus(SwissEphConstants.pholus, 'Pholus', 'Pholus'),

  /// Ceres
  ceres(SwissEphConstants.ceres, 'Ceres', 'Ceres'),

  /// Pallas
  pallas(SwissEphConstants.pallas, 'Pallas', 'Pallas'),

  /// Juno
  juno(SwissEphConstants.juno, 'Juno', 'Juno'),

  /// Vesta
  vesta(SwissEphConstants.vesta, 'Vesta', 'Vesta');

  const Planet(this.swissEphId, this.displayName, this.sanskritName);

  /// The Swiss Ephemeris constant for this planet
  final int swissEphId;

  /// The display name of this planet
  final String displayName;

  /// The Sanskrit / traditional Vedic name
  final String sanskritName;

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
  static List<Planet> get outerPlanets => [uranus, neptune, pluto];

  /// Returns a list of lunar nodes.
  static List<Planet> get lunarNodes => [meanNode, trueNode, ketu];

  /// Returns a list of lunar apogees.
  static List<Planet> get lunarApogees => [meanApogee, osculatingApogee];

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
