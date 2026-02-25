import '../exceptions/jyotish_exception.dart';
import '../models/calculation_flags.dart';
import '../models/geographic_location.dart';
import '../models/planet.dart';
import '../models/planet_position.dart';
import '../models/relationship.dart';
import '../models/vedic_chart.dart';
import 'ephemeris_service.dart';

/// Service for calculating Vedic astrology charts.
class VedicChartService {
  VedicChartService(this._ephemerisService);
  final EphemerisService _ephemerisService;

  /// Calculates a complete Vedic astrology chart.
  ///
  /// [dateTime] - Birth date and time
  /// [location] - Birth location
  /// [houseSystem] - House system to use (default: Whole Sign 'W')
  /// [includeOuterPlanets] - Include Uranus, Neptune, Pluto (default: false)
  /// [flags] - Optional calculation flags (uses default if not provided)
  Future<VedicChart> calculateChart({
    required DateTime dateTime,
    required GeographicLocation location,
    String houseSystem = 'W', // Whole Sign by default
    bool includeOuterPlanets = false,
    CalculationFlags? flags,
  }) async {
    try {
      // Use provided flags or default Lahiri ayanamsa (sidereal is now default)
      flags ??= CalculationFlags.traditionalist();

      // Automate house system selection for KP (v2.5.0)
      if (flags.isKP) {
        houseSystem = 'P'; // Placidus is mandatory for KP
      }

      // Calculate Ascendant and house cusps
      final houses = await _calculateHouses(
        dateTime: dateTime,
        location: location,
        houseSystem: houseSystem,
        siderealMode: flags.siderealMode,
      );

      // Get list of planets to calculate
      final planetsToCalculate =
          includeOuterPlanets ? Planet.majorPlanets : Planet.traditionalPlanets;

      // Calculate all planetary positions
      final planetPositions = <Planet, PlanetPosition>{};
      for (final planet in planetsToCalculate) {
        final position = await _ephemerisService.calculatePlanetPosition(
          planet: planet,
          dateTime: dateTime,
          location: location,
          flags: flags,
        );
        planetPositions[planet] = position;
      }

      // Calculate Rahu based on node type (Mean Node or True Node)
      final rahuPosition = await _ephemerisService.calculatePlanetPosition(
        planet: flags.nodeType.planet,
        dateTime: dateTime,
        location: location,
        flags: flags,
      );

      // Create Ketu position (180° opposite to Rahu)
      final ketu = KetuPosition(rahuPosition: rahuPosition);

      // Calculate Sun position for combustion checks
      final sunPosition = planetPositions[Planet.sun]!;

      // Build house map for Tatkalika (temporal) friendship calculation
      final planetHouseMap = <Planet, int>{
        for (final e in planetPositions.entries)
          e.key: houses.getHouseForLongitude(e.value.longitude),
      };

      // Create Vedic planet info for each planet
      final vedicPlanets = <Planet, VedicPlanetInfo>{};
      for (final entry in planetPositions.entries) {
        final planet = entry.key;
        final position = entry.value;

        final house = houses.getHouseForLongitude(position.longitude);
        final dignity = _calculateDignity(
            planet, position.longitude, planetHouseMap, house);
        final isCombust = PlanetPosition.calculateCombustion(
            planet, position.longitude, sunPosition.longitude,
            longitudeSpeed: position.longitudeSpeed);

        vedicPlanets[planet] = VedicPlanetInfo(
          position: position,
          house: house,
          dignity: dignity,
          isCombust: isCombust,
          exaltationDegree: _getExaltationDegree(planet),
          debilitationDegree: _getDebilitationDegree(planet),
        );
      }

      // Create Vedic info for Rahu
      final rahuHouse = houses.getHouseForLongitude(rahuPosition.longitude);
      final rahuDignity = _calculateDignity(flags.nodeType.planet,
          rahuPosition.longitude, planetHouseMap, rahuHouse);
      final rahuInfo = VedicPlanetInfo(
        position: rahuPosition,
        house: rahuHouse,
        dignity: rahuDignity,
        isCombust: false, // Rahu/Ketu are never combust
      );

      return VedicChart(
        dateTime: dateTime,
        location:
            '${location.latitude.toStringAsFixed(4)}°N, ${location.longitude.toStringAsFixed(4)}°E',
        latitude: location.latitude,
        longitudeCoord: location.longitude,
        houses: houses,
        planets: vedicPlanets,
        rahu: rahuInfo,
        ketu: ketu,
        calculationFlags: flags,
      );
    } catch (e, stackTrace) {
      // Re-throw JyotishException subclasses (e.g. PolarRegionException) without wrapping
      // so callers can catch the specific type.
      if (e is JyotishException) rethrow;
      throw CalculationException(
        'Failed to calculate Vedic chart: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Calculates house cusps using Swiss Ephemeris.
  Future<HouseSystem> _calculateHouses({
    required DateTime dateTime,
    required GeographicLocation location,
    required String houseSystem,
    required SiderealMode siderealMode,
  }) async {
    // Calculate houses (returns tropical positions)
    final houseData = await _ephemerisService.calculateHouses(
      dateTime: dateTime,
      location: location,
      houseSystem: houseSystem,
    );

    // Get ayanamsa for sidereal correction
    final ayanamsa = await _ephemerisService.getAyanamsa(
      dateTime: dateTime,
      mode: siderealMode, // Use provided ayanamsa
      timezoneId: location.timezone,
    );

    // Convert tropical positions to sidereal
    final tropicalAscendant = houseData['ascmc']![0];
    final ascendant = (tropicalAscendant - ayanamsa + 360) % 360;

    final tropicalMidheaven = houseData['ascmc']![1];
    final midheaven = (tropicalMidheaven - ayanamsa + 360) % 360;

    // Convert house cusps to sidereal
    final tropicalCusps = houseData['cusps']!;
    List<double> cusps;

    if (houseSystem == 'W') {
      // For Whole Sign, Swiss Ephemeris returns cusps aligned with TROPICAL signs.
      // Subtracting ayanamsa breaks the alignment with SIDEREAL signs.
      // We must manually align the cusps to the sidereal sign of the Ascendant.
      final ascSignIndex = (ascendant / 30).floor();
      cusps = List.generate(12, (i) {
        final signIndex = (ascSignIndex + i) % 12;
        return signIndex * 30.0;
      });
    } else {
      // For other systems (Placidus, Equal, etc.), subtracting ayanamsa from
      // the tropical cusps correctly yields the exact sidereal cusps.
      cusps =
          tropicalCusps.map((cusp) => (cusp - ayanamsa + 360) % 360).toList();
    }

    return HouseSystem(
      system: _getHouseSystemName(houseSystem),
      cusps: cusps,
      ascendant: ascendant,
      midheaven: midheaven,
    );
  }

  /// Gets the display name for a house system code.
  String _getHouseSystemName(String code) {
    return switch (code) {
      'W' => 'Whole Sign',
      'P' => 'Placidus',
      'K' => 'Koch',
      'O' => 'Porphyry',
      'R' => 'Regiomontanus',
      'C' => 'Campanus',
      'E' => 'Equal',
      'V' => 'Vehlow',
      'X' => 'Axial Rotation',
      'H' => 'Horizontal',
      'T' => 'Polich/Page',
      'B' => 'Alcabitus',
      'M' => 'Morinus',
      'U' => 'Krusinski-Pisa-Goelzer',
      'G' => 'Gauquelin sectors',
      _ => code,
    };
  }

  /// Calculates planetary dignity based on sign placement.
  ///
  /// Priority order per BPHS:
  /// Exalted → Moola Trikona (within degree range) → Own Sign → Debilitated → Friend/Enemy
  PlanetaryDignity _calculateDignity(
    Planet planet,
    double longitude,
    Map<Planet, int> planetHouseMap,
    int planetHouse,
  ) {
    final signIndex = (longitude / 30).floor() % 12;
    final degreeInSign = longitude % 30; // 0–30° within the sign

    // 1. Exaltation
    final exaltationSign = _getExaltationSign(planet);
    if (exaltationSign != null && signIndex == exaltationSign) {
      return PlanetaryDignity.exalted;
    }

    // 2. Debilitation
    final debilitationSign = _getDebilitationSign(planet);
    if (debilitationSign != null && signIndex == debilitationSign) {
      return PlanetaryDignity.debilitated;
    }

    // 3. Moola Trikona — must be checked BEFORE own sign because some planets
    //    share the MT sign with their own sign (e.g. Sun: Leo, Mars: Aries).
    //    BPHS defines specific degree ranges within those signs for MT.
    final mtRange = _getMoolaTrikonaRange(planet);
    if (mtRange != null &&
        signIndex == mtRange.$1 &&
        degreeInSign >= mtRange.$2 &&
        degreeInSign < mtRange.$3) {
      return PlanetaryDignity.moolaTrikona;
    }

    // 4. Own sign
    final ownSigns = _getOwnSigns(planet);
    if (ownSigns.contains(signIndex)) {
      return PlanetaryDignity.ownSign;
    }

    // 5. Friendship-based dignity
    final signLord = _getSignLord(signIndex);
    if (signLord != null) {
      return _calculateFriendshipDignity(
          planet, signLord, planetHouseMap, planetHouse);
    }

    return PlanetaryDignity.neutralSign;
  }

  /// Calculates friendship-based dignity.
  PlanetaryDignity _calculateFriendshipDignity(
    Planet planet,
    Planet signLord,
    Map<Planet, int> planetHouseMap,
    int planetHouse,
  ) {
    // 1. Naisargika (natural / permanent) friendship
    final natural = RelationshipCalculator.naturalRelationships[planet]
            ?[signLord] ??
        RelationshipType.neutral;

    // 2. Tatkalika (temporal / chart-based) friendship
    final signLordHouse = planetHouseMap[signLord];
    final temporary = signLordHouse != null
        ? RelationshipCalculator.calculateTemporary(planetHouse, signLordHouse)
        : RelationshipType.neutral;

    // 3. Panchadha Maitri (compound)
    final compound =
        RelationshipCalculator.calculateCompound(natural, temporary);

    return switch (compound) {
      RelationshipType.greatFriend => PlanetaryDignity.greatFriend,
      RelationshipType.friend => PlanetaryDignity.friendSign,
      RelationshipType.neutral => PlanetaryDignity.neutralSign,
      RelationshipType.enemy => PlanetaryDignity.enemySign,
      RelationshipType.greatEnemy => PlanetaryDignity.greatEnemy,
    };
  }

  /// Gets the lord of a zodiac sign.
  Planet? _getSignLord(int signIndex) {
    const signLords = {
      0: Planet.mars, // Aries
      1: Planet.venus, // Taurus
      2: Planet.mercury, // Gemini
      3: Planet.moon, // Cancer
      4: Planet.sun, // Leo
      5: Planet.mercury, // Virgo
      6: Planet.venus, // Libra
      7: Planet.mars, // Scorpio
      8: Planet.jupiter, // Sagittarius
      9: Planet.saturn, // Capricorn
      10: Planet.saturn, // Aquarius
      11: Planet.jupiter, // Pisces
    };
    return signLords[signIndex];
  }

  /// Gets exaltation sign index for a planet.
  ///
  /// Both Mean Node and True Node are mapped identically (Issue 6).
  /// Ketu is exalted in Sagittarius (opposite of Rahu's debilitation).
  int? _getExaltationSign(Planet planet) {
    const exaltations = {
      Planet.sun: 0, // Aries
      Planet.moon: 1, // Taurus
      Planet.mercury: 5, // Virgo
      Planet.venus: 11, // Pisces
      Planet.mars: 9, // Capricorn
      Planet.jupiter: 3, // Cancer
      Planet.saturn: 6, // Libra
      Planet.meanNode: 2, // Gemini (Rahu exalted)
      Planet.trueNode: 2, // Gemini (True Node — same dignity as Mean Node)
    };
    // Ketu is always 180° from Rahu — its exaltation is Sagittarius (8)
    if (planet == Planet.ketu) return 8;
    return exaltations[planet];
  }

  /// Gets debilitation sign index for a planet.
  ///
  /// Both Mean Node and True Node are mapped identically (Issue 6).
  /// Ketu is debilitated in Gemini (opposite of Rahu's exaltation).
  int? _getDebilitationSign(Planet planet) {
    const debilitations = {
      Planet.sun: 6, // Libra
      Planet.moon: 7, // Scorpio
      Planet.mercury: 11, // Pisces
      Planet.venus: 5, // Virgo
      Planet.mars: 3, // Cancer
      Planet.jupiter: 9, // Capricorn
      Planet.saturn: 0, // Aries
      Planet.meanNode: 8, // Sagittarius (Rahu debilitated)
      Planet.trueNode: 8, // Sagittarius (True Node — same dignity as Mean Node)
    };
    // Ketu is debilitated in Gemini (2)
    if (planet == Planet.ketu) return 2;
    return debilitations[planet];
  }

  /// Gets exaltation degree for a planet.
  double? _getExaltationDegree(Planet planet) {
    const degrees = {
      Planet.sun: 10.0, // 10° Aries
      Planet.moon: 33.0, // 3° Taurus
      Planet.mercury: 165.0, // 15° Virgo
      Planet.venus: 357.0, // 27° Pisces
      Planet.mars: 298.0, // 28° Capricorn
      Planet.jupiter: 95.0, // 5° Cancer
      Planet.saturn: 200.0, // 20° Libra
    };
    return degrees[planet];
  }

  /// Gets debilitation degree for a planet.
  double? _getDebilitationDegree(Planet planet) {
    const degrees = {
      Planet.sun: 190.0, // 10° Libra   (180 + 10)
      Planet.moon: 213.0, // 3° Scorpio  (210 + 3)
      Planet.mercury: 345.0, // 15° Pisces  (330 + 15)
      Planet.venus: 177.0, // 27° Virgo  (150 + 27) — fixed from 165.0
      Planet.mars: 118.0, // 28° Cancer  (90 + 28)
      Planet.jupiter: 278.0, // 5° Capricorn (270 + 5) — corrected to 275.0
      Planet.saturn: 20.0, // 20° Aries   (0 + 20)
    };
    return degrees[planet];
  }

  /// Gets own signs for a planet.
  List<int> _getOwnSigns(Planet planet) {
    const ownSigns = {
      Planet.sun: [4], // Leo
      Planet.moon: [3], // Cancer
      Planet.mercury: [2, 5], // Gemini, Virgo
      Planet.venus: [1, 6], // Taurus, Libra
      Planet.mars: [0, 7], // Aries, Scorpio
      Planet.jupiter: [8, 11], // Sagittarius, Pisces
      Planet.saturn: [9, 10], // Capricorn, Aquarius
    };
    return ownSigns[planet] ?? [];
  }

  /// Gets the Moola Trikona sign and degree range for a planet per BPHS.
  ///
  /// Returns a record of (signIndex, startDegree, endDegree) or null.
  /// A planet is in Moola Trikona only when it falls within [startDegree, endDegree)
  /// of the specified sign. Outside this range (but in the same sign), it is
  /// classified as Own Sign.
  ///
  /// Classical BPHS ranges:
  /// | Planet  | Sign        | MT Range  |
  /// |---------|-------------|-----------|
  /// | Sun     | Leo (4)     | 0°–20°   |
  /// | Moon    | Taurus (1)  | 4°–20°   |
  /// | Mars    | Aries (0)   | 0°–12°   |
  /// | Mercury | Virgo (5)   | 16°–20°  |
  /// | Jupiter | Sagittarius | 0°–10°   |
  /// | Venus   | Libra (6)   | 0°–15°   |
  /// | Saturn  | Aquarius(10)| 0°–20°   |
  (int, double, double)? _getMoolaTrikonaRange(Planet planet) {
    return switch (planet) {
      Planet.sun => (4, 0.0, 20.0), // Leo 0°–20°
      Planet.moon => (1, 4.0, 20.0), // Taurus 4°–20° (0°–3° is exaltation)
      Planet.mars => (0, 0.0, 12.0), // Aries 0°–12°
      Planet.mercury => (5, 16.0, 20.0), // Virgo 16°–20°
      Planet.jupiter => (8, 0.0, 10.0), // Sagittarius 0°–10°
      Planet.venus => (6, 0.0, 15.0), // Libra 0°–15°
      Planet.saturn => (10, 0.0, 20.0), // Aquarius 0°–20°
      _ => null,
    };
  }
}
