import 'package:jyotish/src/models/calculation_flags.dart';
import 'package:jyotish/src/systems/kp_calculations.dart';
import 'package:jyotish/src/models/planet.dart';
import 'package:jyotish/src/astronomy/planet_position.dart';
import 'package:jyotish/src/models/vedic_chart.dart';
import 'package:jyotish/src/astronomy/ephemeris_service.dart';

/// Service for calculating KP (Krishnamurti Paddhati) astrology elements.
///
/// **System requirement**: All methods in this service expect charts and flags
/// created with [CalculationFlags.kp()] (KP VP291 ayanamsa + Placidus houses).
/// Passing a chart computed under a different system will throw a [StateError].
///
/// KP astrology subdivides each Nakshatra into 9 Sub-Lords (Sign  Star  Sub
///  Sub-Sub), giving 249 divisions across the zodiac.
class KPService {
  KPService(this._ephemerisService);

  final EphemerisService _ephemerisService;

  //  Guard-rail 

  /// Throws [StateError] if [flags] do not declare [AstrologicalSystem.kp].
  ///
  /// Call this at the top of any public method that is KP-exclusive.
  void _assertKPSystem(CalculationFlags flags, String methodName) {
    if (!flags.isKP) {
      throw StateError(
        '$methodName requires CalculationFlags.kp() '
        '(AstrologicalSystem.kp + KP VP291 ayanamsa). '
        'Received system: ${flags.system.name}, '
        'ayanamsa: ${flags.siderealMode.name}. '
        'Create the chart with CalculationFlags.kp() and houseSystem: "P" '
        '(Placidus) before calling KP-specific services.',
      );
    }
  }

  /// Calculates complete KP data for a birth chart.
  ///
  /// [natalChart] - The Vedic birth chart. **Must** have been calculated
  ///   with [CalculationFlags.kp()] and Placidus houses (`houseSystem: 'P'`).
  /// [useNewAyanamsa] - Whether to use KP New VP291 (true, default)
  ///   or old KP ayanamsa (false).
  ///
  /// Returns [KPCalculations] with Sub-Lords and significators.
  ///
  /// Throws [StateError] if [natalChart.flags] is not [AstrologicalSystem.kp].
  Future<KPCalculations> calculateKPData(
    VedicChart natalChart, {
    bool useNewAyanamsa = true,
  }) async {
    _assertKPSystem(natalChart.flags, 'calculateKPData');
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
  ///
  /// C and D significators now use the chart's actual Placidus house cusps
  /// (via [KPPlanetOwnership.getOwnedHousesFromChart]) for correct KP analysis.
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

    // C Significators: Houses OWNED by the planet (cusp-based, not Aries Lagna)
    final cSignificators =
        KPPlanetOwnership.getOwnedHousesFromChart(planet, natalChart);

    // D Significators: Houses OWNED by the planet's sign lord (cusp-based)
    final dSignificators = KPPlanetOwnership.getOwnedHousesFromChart(
        division.signLord, natalChart);

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

  // ============================================================
  // TRANSIT VS NATAL COMPARISON
  // ============================================================

  /// Compares transit KP divisions against natal KP divisions for each planet.
  ///
  /// For each planet present in both [natalKP] and [transitDivisions], this
  /// method checks:
  /// - Whether the **Star-Lord** matches between transit and natal.
  /// - Whether the **Sub-Lord** matches (primary KP activation trigger).
  /// - Which house significators are **common** to both sides.
  ///
  /// [natalKP] - The birth chart's KP data from [calculateKPData].
  /// [transitDivisions] - Transit KP divisions from [calculateTransitKPDivisions].
  /// [natalSignificators] - Optional: if omitted, A+B significators are used.
  ///
  /// Returns a sorted list, strongest matches first.
  List<KPTransitComparison> compareTransitToNatal({
    required KPCalculations natalKP,
    required Map<Planet, KPDivision> transitDivisions,
  }) {
    final comparisons = <KPTransitComparison>[];

    for (final entry in transitDivisions.entries) {
      final planet = entry.key;
      final transitDiv = entry.value;
      final natalDiv = natalKP.planetDivisions[planet];

      if (natalDiv == null) continue;

      final starLordMatches = transitDiv.starLord == natalDiv.starLord;
      final subLordMatches = transitDiv.subLord == natalDiv.subLord;

      // Collect natal significators for this planet (A + B grades)
      final natalSig = natalKP.planetSignificators[planet];
      final natalHouses = natalSig != null
          ? {...natalSig.aSignificators, ...natalSig.bSignificators}
          : <int>{};

      // Collect transit significators (star lord and sign lord occupied houses)
      // Use transit star lord's star as a proxy for transit significators
      final transitHouses = <int>{};
      // Transit A: houses occupied by transit sign lord in natal chart
      final natalTransitSignLordInfo =
          natalKP.planetSignificators[transitDiv.signLord];
      if (natalTransitSignLordInfo != null) {
        transitHouses.addAll(natalTransitSignLordInfo.aSignificators);
      }
      // Transit B: houses occupied by transit star lord in natal chart
      final natalTransitStarLordInfo =
          natalKP.planetSignificators[transitDiv.starLord];
      if (natalTransitStarLordInfo != null) {
        transitHouses.addAll(natalTransitStarLordInfo.bSignificators);
      }

      final commonHouses = natalHouses.intersection(transitHouses).toList()
        ..sort();

      comparisons.add(KPTransitComparison(
        planet: planet,
        transitDivision: transitDiv,
        natalDivision: natalDiv,
        starLordMatches: starLordMatches,
        subLordMatches: subLordMatches,
        commonNatalSignificators: commonHouses,
      ));
    }

    // Sort: strongest matches first
    comparisons.sort((a, b) => b.matchStrength.compareTo(a.matchStrength));
    return comparisons;
  }

  // ============================================================
  // RULING PLANETS (KP PRASHNA)
  // ============================================================

  /// Calculates the seven KP Ruling Planets at a query moment.
  ///
  /// The Ruling Planets are the lords of the Sign, Star and Sub at:
  /// 1. Day Lord (weekday planet)
  /// 2. Ascendant (Sign, Star, Sub lords)
  /// 3. Moon (Sign, Star, Sub lords)
  ///
  /// This is the first step in any KP Prashna (horary) reading.
  ///
  /// [chart] - The Prashna chart calculated at the exact query moment.
  ///           Must be computed with Placidus houses and KP ayanamsa.
  /// [useNewAyanamsa] - Use KP New VP291 (true, default) or old KP ayanamsa.
  ///
  /// Returns [KPRulingPlanets] with all seven lords.
  Future<KPRulingPlanets> calculateRulingPlanets(
    VedicChart chart, {
    bool useNewAyanamsa = true,
  }) async {
    _assertKPSystem(chart.flags, 'calculateRulingPlanets');
    final queryDateTime = chart.dateTime;

    // 1. Day Lord  use weekday
    final dayLord = _getDayLord(queryDateTime);

    // 2. Calculate KP ayanamsa and adjustment for this chart
    final kpAyanamsa = await _calculateKPAyanamsa(
      queryDateTime,
      useNewAyanamsa: useNewAyanamsa,
    );
    final lahiriAyanamsa = await _ephemerisService.getAyanamsa(
      dateTime: queryDateTime,
      mode: SiderealMode.lahiri,
    );
    final ayanamsaDiff = kpAyanamsa - lahiriAyanamsa;

    // 3. Ascendant division
    final rawAscendant = chart.houses.ascendant;
    final adjustedAscendant = (rawAscendant - ayanamsaDiff + 360) % 360;
    final ascDiv = _calculateKPDivision(adjustedAscendant, null);

    // 4. Moon division
    final moonInfo = chart.planets[Planet.moon];
    if (moonInfo == null) {
      throw ArgumentError('Moon not found in Prashna chart');
    }
    final rawMoonLong = moonInfo.position.longitude;
    final adjustedMoonLong = (rawMoonLong - ayanamsaDiff + 360) % 360;
    final moonDiv = _calculateKPDivision(adjustedMoonLong, Planet.moon);

    return KPRulingPlanets(
      dayLord: dayLord,
      ascendantSignLord: ascDiv.signLord,
      ascendantStarLord: ascDiv.starLord,
      ascendantSubLord: ascDiv.subLord,
      moonSignLord: moonDiv.signLord,
      moonStarLord: moonDiv.starLord,
      moonSubLord: moonDiv.subLord,
      queryDateTime: queryDateTime,
      ascendantDivision: ascDiv,
      moonDivision: moonDiv,
    );
  }

  /// Returns the traditional KP day lord for a given date/time.
  ///
  /// KP day sequence (same as Hora weekday order):
  /// Sun, Moon, Mars, Mercury, Jupiter, Venus, Saturn.
  Planet _getDayLord(DateTime dt) {
    // weekday: Mon=1, Tue=2, Wed=3, Thu=4, Fri=5, Sat=6, Sun=7
    const weekdayLords = [
      Planet.moon, // Monday
      Planet.mars, // Tuesday
      Planet.mercury, // Wednesday
      Planet.jupiter, // Thursday
      Planet.venus, // Friday
      Planet.saturn, // Saturday
      Planet.sun, // Sunday
    ];
    return weekdayLords[dt.weekday - 1];
  }

  // ============================================================
  // 249-DIVISION TABLE
  // ============================================================

  /// Generates the complete KP 249 Sub-Lord table.
  ///
  /// KP astrology divides the 27 Nakshatras into 9 Sub-Lords (27 * 9 = 243).
  /// Because 6 Sub-Lords cross zodiac sign boundaries, they are split,
  /// resulting in exactly 249 divisions.
  List<KPDivisionEntry> generateKPDivisionTable() {
    final table = <KPDivisionEntry>[];
    var index = 1;

    for (var star = 1; star <= 27; star++) {
      final starStart = (star - 1) * (360.0 / 27);
      var currentSubStart = starStart;

      final dashaPeriods = [7.0, 20.0, 6.0, 10.0, 7.0, 18.0, 16.0, 19.0, 17.0];
      const totalPeriods = 120.0;
      final starSpan = 360.0 / 27;

      final starLord = KPPlanetOwnership.getStarLord(star);
      final planets = [
        Planet.ketu,
        Planet.venus,
        Planet.sun,
        Planet.moon,
        Planet.mars,
        Planet.meanNode,
        Planet.jupiter,
        Planet.saturn,
        Planet.mercury
      ];
      // Note: in _calculateSubLord we had meanNode. Make sure starLord logic uses meanNode for Rahu.
      final searchStarLord =
          (starLord == Planet.trueNode) ? Planet.meanNode : starLord;
      final startPlanetIndex = planets.indexOf(searchStarLord);

      for (var i = 0; i < 9; i++) {
        final ptIndex = (startPlanetIndex + i) % 9;
        final subLord = planets[ptIndex];

        final subSpan = starSpan * (dashaPeriods[ptIndex] / totalPeriods);
        final subEnd = currentSubStart + subSpan;

        // Round to avoid floating point precision issues near boundary
        final signStart = ((currentSubStart + 0.000001) / 30).floor();
        final signEnd = ((subEnd - 0.000001) / 30).floor();

        if (signStart != signEnd && (subEnd % 30).abs() > 0.0001) {
          // Crosses boundary, split into two
          final boundary = signEnd * 30.0;

          final div1 = _calculateKPDivision(currentSubStart, null);
          table.add(KPDivisionEntry(
            index: index++,
            sign: div1.sign,
            signLord: div1.signLord,
            star: star,
            starLord: starLord,
            subLord: subLord,
            startLongitude: currentSubStart,
            endLongitude: boundary,
          ));

          final div2 = _calculateKPDivision(boundary + 0.000001, null);
          table.add(KPDivisionEntry(
            index: index++,
            sign: div2.sign,
            signLord: div2.signLord,
            star: star,
            starLord: starLord,
            subLord: subLord,
            startLongitude: boundary,
            endLongitude: subEnd,
          ));
        } else {
          final div = _calculateKPDivision(currentSubStart + 0.000001, null);
          table.add(KPDivisionEntry(
            index: index++,
            sign: div.sign,
            signLord: div.signLord,
            star: star,
            starLord: starLord,
            subLord: subLord,
            startLongitude: currentSubStart,
            endLongitude: subEnd,
          ));
        }

        currentSubStart = subEnd;
      }
    }

    return table;
  }

  // ============================================================
  // AYANAMSA
  // ============================================================

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
