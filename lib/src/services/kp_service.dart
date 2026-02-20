import '../models/calculation_flags.dart';
import '../models/kp_calculations.dart';
import '../models/planet.dart';
import '../models/planet_position.dart';
import '../models/vedic_chart.dart';
import 'ephemeris_service.dart';

/// Service for calculating KP (Krishnamurti Paddhati) astrology elements.
///
/// KP astrology is a system that uses a specific ayanamsa (KP New VP291)
/// and subdivides the zodiac into smaller divisions called Sub-Lords.
class KPService {
  KPService(this._ephemerisService);

  final EphemerisService _ephemerisService;

  /// Calculates complete KP data for a birth chart.
  ///
  /// [natalChart] - The Vedic birth chart
  /// [useNewAyanamsa] - Whether to use KP New VP291 (true) or old KP ayanamsa (false)
  ///
  /// Returns [KPCalculations] with Sub-Lords and significators.
  ///
  /// **Important**: The natal chart is typically calculated with Lahiri ayanamsa.
  /// This method adjusts house cusps and planet positions to use the correct
  /// KP ayanamsa (VP291 or old KP) before calculating sub-lords.
  Future<KPCalculations> calculateKPData(
    VedicChart natalChart, {
    bool useNewAyanamsa = true,
  }) async {
    // Calculate KP ayanamsa using precise time-varying formula from Swiss Ephemeris
    final kpAyanamsa = await _calculateKPAyanamsa(
      natalChart.dateTime,
      useNewAyanamsa: useNewAyanamsa,
    );

    // Get the Lahiri ayanamsa (default used in chart calculation)
    final lahiriAyanamsa = await _ephemerisService.getAyanamsa(
      dateTime: natalChart.dateTime,
      mode: SiderealMode.lahiri,
    );

    // Calculate the difference to adjust positions
    // Positive diff means KP ayanamsa is larger, so we need to subtract more from tropical
    // Since chart is already in Lahiri sidereal, we subtract the difference
    final ayanamsaDiff = kpAyanamsa - lahiriAyanamsa;

    // Calculate Sub-Lords for planets with adjusted positions
    final planetDivisions = <Planet, KPDivision>{};
    for (final entry in natalChart.planets.entries) {
      // Adjust planet longitude from Lahiri to KP ayanamsa
      final adjustedLongitude =
          (entry.value.position.longitude - ayanamsaDiff + 360) % 360;
      planetDivisions[entry.key] = _calculateKPDivision(
        adjustedLongitude,
        entry.key,
      );
    }

    // Calculate Sub-Lords for house cusps with adjusted positions
    final houseDivisions = <int, KPDivision>{};
    for (var house = 1; house <= 12; house++) {
      // Adjust cusp longitude from Lahiri to KP ayanamsa
      final adjustedCusp =
          (natalChart.houses.cusps[house - 1] - ayanamsaDiff + 360) % 360;
      houseDivisions[house] = _calculateKPDivision(
        adjustedCusp,
        null,
      );
    }

    // Calculate ABCD significators
    final planetSignificators = <Planet, KPSignificators>{};
    for (final planet in planetDivisions.keys) {
      planetSignificators[planet] = _calculateSignificators(
        planet,
        planetDivisions[planet]!,
        natalChart,
      );
    }

    return KPCalculations(
      ayanamsa: kpAyanamsa,
      planetDivisions: planetDivisions,
      houseDivisions: houseDivisions,
      planetSignificators: planetSignificators,
    );
  }

  /// Calculates the KP division for a specific longitude.
  ///
  /// [longitude] - The longitude in degrees (0-360)
  /// [planet] - Optional planet (for reference)
  KPDivision _calculateKPDivision(double longitude, Planet? planet) {
    // Get sign information
    final sign = (longitude / 30).floor() + 1;
    final signLord = KPPlanetOwnership.getSignLord(sign);

    // Get star information
    final starLongitude = longitude % 360;
    final star = (starLongitude / (360 / 27)).floor() + 1;
    final starLord = KPPlanetOwnership.getStarLord(star);

    // Calculate Sub-Lord and boundaries
    final subLord = _calculateSubLord(longitude, star);
    final (subStart, subEnd) = _calculateSubBoundaries(longitude, star);

    // Calculate Sub-Sub-Lord using sub-lord boundaries
    final subSubLord =
        _calculateSubSubLord(longitude, subLord, subStart, subEnd);

    return KPDivision(
      sign: sign,
      signLord: signLord,
      star: star,
      starLord: starLord,
      subLord: subLord,
      subSubLord: subSubLord,
      subStartLongitude: subStart,
      subEndLongitude: subEnd,
    );
  }

  /// Calculates the Sub-Lord for a given longitude.
  ///
  /// Uses proper Vimshottari Dasha sequence with all 9 planets (120 years total):
  /// Ketu (7), Venus (20), Sun (6), Moon (10), Mars (7),
  /// Rahu (18), Jupiter (16), Saturn (19), Mercury (17)
  Planet _calculateSubLord(double longitude, int star) {
    // Get star boundaries
    final starStart = (star - 1) * (360 / 27);
    final starEnd = star * (360 / 27);
    final starSpan = starEnd - starStart;

    // Position within the star (0.0 to 1.0)
    final posInStar = (longitude - starStart) / starSpan;

    // Full Vimshottari Dasha periods - total 120 years
    // Sequence: Ketu (7), Venus (20), Sun (6), Moon (10), Mars (7),
    //           Rahu (18), Jupiter (16), Saturn (19), Mercury (17)
    final dashaPeriods = [
      (Planet.ketu, 7), // Ketu (index 0)
      (Planet.venus, 20), // Venus
      (Planet.sun, 6), // Sun
      (Planet.moon, 10), // Moon
      (Planet.mars, 7), // Mars
      (Planet.meanNode, 18), // Rahu
      (Planet.jupiter, 16), // Jupiter
      (Planet.saturn, 19), // Saturn
      (Planet.mercury, 17), // Mercury
    ];

    // Total should be exactly 120 years
    const totalPeriods = 120;

    var cumulative = 0.0;

    for (final (planet, period) in dashaPeriods) {
      cumulative += period / totalPeriods;
      if (posInStar <= cumulative) {
        return planet;
      }
    }

    return Planet.mercury; // Default to last in sequence
  }

  /// Calculates the Sub-Sub-Lord for a given longitude.
  ///
  /// The Sub-Sub-Lord divides each Sub-Lord into 9 parts using the same
  /// Vimshottari sequence (120 years total).
  Planet? _calculateSubSubLord(
      double longitude, Planet subLord, double subStart, double subEnd) {
    // Full Vimshottari sequence
    final dashaPeriods = [
      (Planet.ketu, 7), // Ketu
      (Planet.venus, 20), // Venus
      (Planet.sun, 6), // Sun
      (Planet.moon, 10), // Moon
      (Planet.mars, 7), // Mars
      (Planet.meanNode, 18), // Rahu
      (Planet.jupiter, 16), // Jupiter
      (Planet.saturn, 19), // Saturn
      (Planet.mercury, 17), // Mercury
    ];

    const totalPeriods = 120;
    final subSpan = subEnd - subStart;

    // Position within the sub-lord
    final posInSub = (longitude - subStart) / subSpan;

    // Find the starting planet in the sequence
    final subLordIndex = dashaPeriods.indexWhere((p) =>
        (p.$1 == Planet.meanNode && subLord == Planet.meanNode) ||
        (p.$1 == Planet.trueNode && subLord == Planet.trueNode) ||
        p.$1 == subLord);

    if (subLordIndex < 0) return null;

    // Find which sub-sub-lord this position falls into
    var cumulative = 0.0;

    for (var i = 0; i < dashaPeriods.length; i++) {
      final index = (subLordIndex + i) % dashaPeriods.length;
      final (_, period) = dashaPeriods[index];
      cumulative += period / totalPeriods;
      if (posInSub <= cumulative) {
        return dashaPeriods[index].$1;
      }
    }

    return dashaPeriods[subLordIndex].$1;
  }

  /// Calculates the sub-division boundaries.
  ///
  /// Uses the full 9-planet Vimshottari cycle (120 years total):
  /// Ketu (7), Venus (20), Sun (6), Moon (10), Mars (7),
  /// Rahu (18), Jupiter (16), Saturn (19), Mercury (17)
  (double, double) _calculateSubBoundaries(double longitude, int star) {
    final starStart = (star - 1) * (360 / 27);
    final starEnd = star * (360 / 27);
    final starSpan = starEnd - starStart;

    final posInStar = longitude - starStart;

    // Full Vimshottari cycle - 9 planets, 120 years total
    final dashaPeriods = [
      7, // Ketu
      20, // Venus
      6, // Sun
      10, // Moon
      7, // Mars
      18, // Rahu
      16, // Jupiter
      19, // Saturn
      17, // Mercury
    ];
    const totalPeriods = 120; // Standard Vimshottari total

    var cumulative = 0.0;
    var subStart = starStart;

    for (final period in dashaPeriods) {
      final subSpan = starSpan * (period / totalPeriods);
      if (posInStar <= cumulative + subSpan) {
        return (subStart, subStart + subSpan);
      }
      cumulative += subSpan;
      subStart += subSpan;
    }

    return (starStart, starEnd);
  }

  /// Calculates ABCD significators for a planet.
  KPSignificators _calculateSignificators(
    Planet planet,
    KPDivision division,
    VedicChart natalChart,
  ) {
    // A Significators: Houses occupied by the planet's sign lord
    final aSignificators = _getHousesOccupiedByPlanet(
      division.signLord,
      natalChart,
    );

    // B Significators: Houses occupied by the planet's star lord
    final bSignificators = _getHousesOccupiedByPlanet(
      division.starLord,
      natalChart,
    );

    // C Significators: Houses owned by the planet itself
    final cSignificators = KPPlanetOwnership.getOwnedHouses(planet);

    // D Significators: Houses owned by the planet's sign lord
    final dSignificators = KPPlanetOwnership.getOwnedHouses(division.signLord);

    return KPSignificators(
      planet: planet,
      aSignificators: aSignificators,
      bSignificators: bSignificators,
      cSignificators: cSignificators,
      dSignificators: dSignificators,
    );
  }

  /// Gets the houses occupied by a planet.
  List<int> _getHousesOccupiedByPlanet(Planet planet, VedicChart natalChart) {
    final houses = <int>[];

    // Check if planet is in the chart
    final planetInfo = natalChart.planets[planet];
    if (planetInfo != null) {
      houses.add(planetInfo.house);
    }

    return houses;
  }

  /// Gets the Sub-Lord for a specific longitude.
  Planet? getSubLord(double longitude) {
    final division = _calculateKPDivision(longitude, null);
    return division.subLord;
  }

  /// Gets the Sub-Sub-Lord for a specific longitude.
  Planet? getSubSubLord(double longitude) {
    final division = _calculateKPDivision(longitude, null);
    return division.subSubLord;
  }

  /// Gets house group significators for a chart.
  KPHouseGroupSignificators getHouseGroupSignificators(
    Map<Planet, KPSignificators> significators,
  ) {
    final selfSignificators = <Planet>[];
    final wealthSignificators = <Planet>[];
    final careerSignificators = <Planet>[];
    final marriageSignificators = <Planet>[];
    final childrenSignificators = <Planet>[];
    final healthSignificators = <Planet>[];

    for (final entry in significators.entries) {
      final allSigs = entry.value.allSignificators;

      // Self: 1, 2, 3
      if (allSigs.any((h) => [1, 2, 3].contains(h))) {
        selfSignificators.add(entry.key);
      }

      // Wealth: 2, 6, 11
      if (allSigs.any((h) => [2, 6, 11].contains(h))) {
        wealthSignificators.add(entry.key);
      }

      // Career: 2, 6, 10, 11
      if (allSigs.any((h) => [2, 6, 10, 11].contains(h))) {
        careerSignificators.add(entry.key);
      }

      // Marriage: 2, 7, 11
      if (allSigs.any((h) => [2, 7, 11].contains(h))) {
        marriageSignificators.add(entry.key);
      }

      // Children: 2, 5, 11
      if (allSigs.any((h) => [2, 5, 11].contains(h))) {
        childrenSignificators.add(entry.key);
      }

      // Health: 1, 5, 11
      if (allSigs.any((h) => [1, 5, 11].contains(h))) {
        healthSignificators.add(entry.key);
      }
    }

    return KPHouseGroupSignificators(
      selfSignificators: selfSignificators,
      wealthSignificators: wealthSignificators,
      careerSignificators: careerSignificators,
      marriageSignificators: marriageSignificators,
      childrenSignificators: childrenSignificators,
      healthSignificators: healthSignificators,
    );
  }

  /// Calculates transit KP positions.
  Map<Planet, KPDivision> calculateTransitKPDivisions(
    Map<Planet, PlanetPosition> transitPositions,
  ) {
    final divisions = <Planet, KPDivision>{};

    for (final entry in transitPositions.entries) {
      divisions[entry.key] = _calculateKPDivision(
        entry.value.longitude,
        entry.key,
      );
    }

    return divisions;
  }

  /// Calculates KP Ayanamsa using Swiss Ephemeris precise time-varying formula.
  ///
  /// Uses SE_SIDM_KRISHNAMURTI_VP291 (mode 45) for KP New ayanamsa
  /// or SE_SIDM_KRISHNAMURTI (mode 5) for old KP ayanamsa.
  Future<double> _calculateKPAyanamsa(
    DateTime dateTime, {
    required bool useNewAyanamsa,
  }) async {
    final mode = useNewAyanamsa
        ? SiderealMode.krishnamurtiVP291
        : SiderealMode.krishnamurti;

    return await _ephemerisService.getAyanamsa(
      dateTime: dateTime,
      mode: mode,
    );
  }
}
