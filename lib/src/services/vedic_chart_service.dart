import '../exceptions/jyotish_exception.dart';
import '../models/calculation_flags.dart';
import '../models/geographic_location.dart';
import '../models/planet.dart';
import '../models/planet_position.dart';
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
      flags ??= CalculationFlags.defaultFlags();

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

      // Create Vedic planet info for each planet
      final vedicPlanets = <Planet, VedicPlanetInfo>{};
      for (final entry in planetPositions.entries) {
        final planet = entry.key;
        final position = entry.value;

        final house = houses.getHouseForLongitude(position.longitude);
        final dignity = _calculateDignity(planet, position.longitude);
        final isCombust = PlanetPosition.calculateCombustion(
            planet, position.longitude, sunPosition.longitude);

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
      final rahuDignity =
          _calculateDignity(flags.nodeType.planet, rahuPosition.longitude);
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
      );
    } catch (e, stackTrace) {
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
    final cusps =
        tropicalCusps.map((cusp) => (cusp - ayanamsa + 360) % 360).toList();

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
  PlanetaryDignity _calculateDignity(Planet planet, double longitude) {
    final signIndex = (longitude / 30).floor() % 12;

    // Exaltation and debilitation degrees
    final exaltationMap = _getExaltationSign(planet);
    final debilitationMap = _getDebilitationSign(planet);

    if (exaltationMap != null && signIndex == exaltationMap) {
      return PlanetaryDignity.exalted;
    }

    if (debilitationMap != null && signIndex == debilitationMap) {
      return PlanetaryDignity.debilitated;
    }

    // Own signs
    final ownSigns = _getOwnSigns(planet);
    if (ownSigns.contains(signIndex)) {
      return PlanetaryDignity.ownSign;
    }

    // Moola Trikona
    final moolaTrikona = _getMoolaTrikona(planet);
    if (moolaTrikona != null && signIndex == moolaTrikona) {
      return PlanetaryDignity.moolaTrikona;
    }

    // Calculate planetary friendship
    final signLord = _getSignLord(signIndex);
    if (signLord != null) {
      return _calculateFriendshipDignity(planet, signLord);
    }

    return PlanetaryDignity.neutralSign;
  }

  /// Calculates friendship-based dignity.
  PlanetaryDignity _calculateFriendshipDignity(Planet planet, Planet signLord) {
    // Define planetary relationships
    // Friend (Mitra): +1 relationship value
    // Enemy (Shatru): -1 relationship value
    // Neutral (Sama): 0 relationship value

    final relationships = _getPlanetaryRelationships();
    final relationship = relationships[planet]?[signLord] ?? 0;

    // Check for Great Friend (Adhi-Mitra): Friend's friend
    // Check for Great Enemy (Adhi-Shatru): Enemy's friend or Friend's enemy
    if (relationship == 1) {
      // Check if signLord considers planet as friend (mutual friendship = Great Friend)
      final reverseRelationship = relationships[signLord]?[planet] ?? 0;
      if (reverseRelationship == 1) {
        return PlanetaryDignity.greatFriend;
      }
      return PlanetaryDignity.friendSign;
    } else if (relationship == -1) {
      // Check if signLord considers planet as enemy (mutual enmity = Great Enemy)
      final reverseRelationship = relationships[signLord]?[planet] ?? 0;
      if (reverseRelationship == -1) {
        return PlanetaryDignity.greatEnemy;
      }
      return PlanetaryDignity.enemySign;
    }

    return PlanetaryDignity.neutralSign;
  }

  /// Gets planetary relationships map.
  /// 1 = Friend, -1 = Enemy, 0 = Neutral
  Map<Planet, Map<Planet, int>> _getPlanetaryRelationships() {
    return {
      Planet.sun: {
        Planet.moon: 1,
        Planet.mars: 1,
        Planet.jupiter: 1,
        Planet.mercury: 0,
        Planet.venus: -1,
        Planet.saturn: -1,
      },
      Planet.moon: {
        Planet.sun: 1,
        Planet.mercury: 1,
        Planet.venus: 1, // Added as per user request
        Planet.mars: 0,
        Planet.jupiter: 0,
        Planet.saturn: 0,
      },
      Planet.mars: {
        Planet.sun: 1,
        Planet.moon: 1,
        Planet.jupiter: 1,
        Planet.mercury: -1,
        Planet.venus: 0,
        Planet.saturn: 0,
      },
      Planet.mercury: {
        Planet.sun: 1,
        Planet.venus: 1,
        Planet.moon: -1, // Added as per user request
        Planet.mars: 0,
        Planet.jupiter: 0,
        Planet.saturn: 0,
      },
      Planet.jupiter: {
        Planet.sun: 1,
        Planet.moon: 1,
        Planet.mars: 1,
        Planet.mercury: -1,
        Planet.venus: -1,
        Planet.saturn: 0,
      },
      Planet.venus: {
        Planet.mercury: 1,
        Planet.saturn: 1,
        Planet.mars: 0,
        Planet.jupiter: 0,
        Planet.sun: -1,
        Planet.moon: -1,
      },
      Planet.saturn: {
        Planet.mercury: 1,
        Planet.venus: 1,
        Planet.jupiter: 0,
        Planet.mars: -1,
        Planet.sun: -1,
        Planet.moon: -1,
      },
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
  int? _getExaltationSign(Planet planet) {
    const exaltations = {
      Planet.sun: 0, // Aries
      Planet.moon: 1, // Taurus
      Planet.mercury: 5, // Virgo
      Planet.venus: 11, // Pisces
      Planet.mars: 9, // Capricorn
      Planet.jupiter: 3, // Cancer
      Planet.saturn: 6, // Libra
      Planet.meanNode: 2, // Gemini (Rahu)
    };
    return exaltations[planet];
  }

  /// Gets debilitation sign index for a planet.
  int? _getDebilitationSign(Planet planet) {
    const debilitations = {
      Planet.sun: 6, // Libra
      Planet.moon: 7, // Scorpio
      Planet.mercury: 11, // Pisces
      Planet.venus: 5, // Virgo
      Planet.mars: 3, // Cancer
      Planet.jupiter: 9, // Capricorn
      Planet.saturn: 0, // Aries
      Planet.meanNode: 8, // Sagittarius (Rahu)
    };
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
      Planet.sun: 190.0, // 10° Libra
      Planet.moon: 213.0, // 3° Scorpio
      Planet.mercury: 345.0, // 15° Pisces
      Planet.venus: 165.0, // 27° Virgo (actually 177° - 27° Virgo)
      Planet.mars: 118.0, // 28° Cancer
      Planet.jupiter: 278.0, // 5° Capricorn
      Planet.saturn: 20.0, // 20° Aries
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

  /// Gets Moola Trikona sign for a planet.
  int? _getMoolaTrikona(Planet planet) {
    const moolaTrikona = {
      Planet.sun: 4, // Leo
      Planet.moon: 1, // Taurus
      Planet.mercury: 5, // Virgo
      Planet.venus: 6, // Libra
      Planet.mars: 0, // Aries
      Planet.jupiter: 8, // Sagittarius
      Planet.saturn: 10, // Aquarius
    };
    return moolaTrikona[planet];
  }
}
