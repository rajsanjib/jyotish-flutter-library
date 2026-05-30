import 'package:jyotish/src/models/calculation_flags.dart';
import 'package:jyotish/src/models/geographic_location.dart';
import 'package:jyotish/src/models/planet.dart';
import 'package:jyotish/src/systems/varshapal.dart';
import 'package:jyotish/src/astronomy/ephemeris_service.dart';
import 'package:jyotish/src/analysis/vedic_chart_service.dart';
import 'package:jyotish/src/models/vedic_chart.dart';
import 'package:jyotish/src/models/rashi.dart';
import 'package:jyotish/src/strength/relationship.dart';
import 'package:jyotish/src/astronomy/astrology_time_service.dart';

/// Service for calculating Varshapal (Annual Chart) and its periods.
///
/// Varshapal is calculated from the birthday each year and shows the
/// planetary influences for that year based on the solar return chart.
class VarshapalService {
  VarshapalService(this._ephemerisService);

  final EphemerisService _ephemerisService;

  /// The 60-year Samvatsara cycle names (Vrihaspati Chakra).
  static const List<String> samvatsaraNames = [
    'Prabhava',
    'Vibhava',
    'Shukla',
    'Pramodoota',
    'Prajothpatti',
    'Aangirasa',
    'Shreemukha',
    'Bhaava',
    'Yuva',
    'Dhaatu',
    'Eeshwara',
    'Bahudhanya',
    'Pramaadi',
    'Vikrama',
    'Vishu',
    'Chitrabhanu',
    'Svabhanu',
    'Taarana',
    'Paarthiva',
    'Vyaya',
    'Sarvajith',
    'Sarvadhaari',
    'Virodhi',
    'Vikrita',
    'Khara',
    'Nandana',
    'Vijaya',
    'Jaya',
    'Manmatha',
    'Durmukhi',
    'Hevilambi',
    'Vilambi',
    'Vikaari',
    'Shaarvari',
    'Plava',
    'Shubhakruth',
    'Shobhakruth',
    'Krodhi',
    'Vishvaavasu',
    'Paraabhava',
    'Plavanga',
    'Keelaka',
    'Saumya',
    'Saadhaarana',
    'Virodhikruth',
    'Paridhawi',
    'Pramaadeecha',
    'Aananda',
    'Raakshasa',
    'Nala',
    'Pingala',
    'Kaalayukthi',
    'Siddharthi',
    'Raudra',
    'Durmathi',
    'Dundubhi',
    'Rudhirodgaari',
    'Ruktaakshi',
    'Krodhana',
    'Akshaya',
  ];

  /// Varsha Dasa order (which planet rules each year in sequence).
  static const List<Planet> varshaDasaOrder = [
    Planet.sun,
    Planet.moon,
    Planet.mars,
    Planet.mercury,
    Planet.jupiter,
    Planet.venus,
    Planet.saturn,
  ];

  /// Maas Dasa order (month periods).
  static const List<Planet> maasaDasaOrder = [
    Planet.sun,
    Planet.moon,
    Planet.mars,
    Planet.mercury,
    Planet.jupiter,
    Planet.venus,
    Planet.saturn,
  ];

  /// Dina Dasa order (day periods).
  static const List<Planet> dinaDasaOrder = [
    Planet.sun,
    Planet.moon,
    Planet.mars,
    Planet.mercury,
    Planet.jupiter,
    Planet.venus,
    Planet.saturn,
  ];

  /// Hora Dasa order (hour periods).
  static const List<Planet> horaDasaOrder = [
    Planet.sun,
    Planet.moon,
    Planet.mars,
    Planet.mercury,
    Planet.jupiter,
    Planet.venus,
    Planet.saturn,
  ];

  /// Calculates the Varshapal (Annual Chart) for a given date.
  ///
  /// [birthDateTime] - Original birth date and time
  /// [varshaDateTime] - The birthday date/time for the year to calculate
  /// [location] - Birth location (used for chart calculation)
  /// [houseSystem] - House system to use (default: Whole Sign 'W')
  /// [flags] - Ayanamsa/calculation override
  /// [checkDate] - Optional date to check current periods (defaults to now)
  ///
  /// Returns complete Varshapal with chart and all period calculations.
  Future<Varshapal> calculateVarshapal({
    required DateTime birthDateTime,
    required DateTime varshaDateTime,
    required GeographicLocation location,
    String houseSystem = 'W',
    CalculationFlags? flags,
    DateTime? checkDate,
  }) async {
    checkDate ??= DateTime.now();
    final activeFlags = flags ?? CalculationFlags.defaultFlags();

    final vedicChartService = VedicChartService(_ephemerisService);

    // 1. Calculate natal chart
    final natalChart = await vedicChartService.calculateChart(
      dateTime: birthDateTime,
      location: location,
      houseSystem: houseSystem,
      flags: activeFlags,
    );

    // 2. Calculate annual chart for the varsha date
    final chart = await vedicChartService.calculateChart(
      dateTime: varshaDateTime,
      location: location,
      houseSystem: houseSystem,
      flags: activeFlags,
    );

    // 3. Get Jupiter's position to determine varsha number
    final jupiterInfo = chart.getPlanet(Planet.jupiter);
    final jupiterLongitude = jupiterInfo?.longitude ?? 0;
    final varshaNumber = _calculateVarshaNumber(jupiterLongitude);
    final samvatsaraName = samvatsaraNames[(varshaNumber - 1) % 60];

    // 4. Calculate Panchavargiya Bala
    final panchavargiyaBala = <Planet, PanchavargiyaBalaResult>{};
    for (final planet in Planet.traditionalPlanets) {
      panchavargiyaBala[planet] = calculatePanchavargiyaBala(planet, chart);
    }

    // 5. Determine Year Lord (Varshesh / varshaLord) using Panchadhikari rules
    final varshaLord = determineVarshesh(
      natalChart: natalChart,
      annualChart: chart,
      balaMap: panchavargiyaBala,
      varshaDateTime: varshaDateTime,
      birthDateTime: birthDateTime,
    );

    // 6. Calculate Mudda Dasha
    final muddaDashaList = await calculateMuddaDasha(
      birthDateTime: birthDateTime,
      varshaDateTime: varshaDateTime,
      annualChart: chart,
      location: location,
      flags: activeFlags,
    );

    // 7. Calculate legacy periods based on the calculated Year Lord (varshaLord)
    final allVarshaPeriods = _calculateVarshaPeriods(
      startDate: varshaDateTime,
      varshaLord: varshaLord,
    );

    final allMaasaPeriods = _calculateMaasaPeriods(
      startDate: varshaDateTime,
      varshaLord: varshaLord,
    );

    final allDinaPeriods = _calculateDinaPeriods(
      startDate: varshaDateTime,
      varshaLord: varshaLord,
    );

    final allHoraPeriods = _calculateHoraPeriods(
      startDate: varshaDateTime,
      varshaLord: varshaLord,
    );

    // Find current periods
    final currentVarshaPeriod = _findCurrentPeriod(allVarshaPeriods, checkDate);
    final currentMaasaPeriod = _findCurrentPeriod(allMaasaPeriods, checkDate);
    final currentDinaPeriod = _findCurrentPeriod(allDinaPeriods, checkDate);
    final currentHoraPeriod = _findCurrentPeriod(allHoraPeriods, checkDate);

    return Varshapal(
      chart: chart,
      birthDateTime: birthDateTime,
      varshaDateTime: varshaDateTime,
      varshaLord: varshaLord,
      varshaNumber: varshaNumber,
      samvatsaraName: samvatsaraName,
      allVarshaPeriods: allVarshaPeriods,
      allMaasaPeriods: allMaasaPeriods,
      allDinaPeriods: allDinaPeriods,
      allHoraPeriods: allHoraPeriods,
      currentVarshaPeriod: currentVarshaPeriod,
      currentMaasaPeriod: currentMaasaPeriod,
      currentDinaPeriod: currentDinaPeriod,
      currentHoraPeriod: currentHoraPeriod,
      panchavargiyaBala: panchavargiyaBala,
      muddaDasha: muddaDashaList,
    );
  }

  /// Alias for [calculateVarshapal] to support legacy tests.
  Future<Varshapal> getVarshapal({
    required DateTime birthDateTime,
    required DateTime varshaDateTime,
    required GeographicLocation location,
    String houseSystem = 'W',
    CalculationFlags? flags,
    DateTime? checkDate,
  }) =>
      calculateVarshapal(
        birthDateTime: birthDateTime,
        varshaDateTime: varshaDateTime,
        location: location,
        houseSystem: houseSystem,
        flags: flags,
        checkDate: checkDate,
      );

  /// Calculates Varshapal for the current year (from birthday to next birthday).
  Future<Varshapal> calculateCurrentVarshapal({
    required DateTime birthDateTime,
    required GeographicLocation location,
    String houseSystem = 'W',
    CalculationFlags? flags,
    DateTime? checkDate,
  }) async {
    checkDate ??= DateTime.now();
    final activeFlags = flags ?? CalculationFlags.defaultFlags();

    final thisYearSolarReturn = await calculateSolarReturn(
      birthDateTime: birthDateTime,
      targetYear: checkDate.year,
      location: location,
      flags: activeFlags,
    );

    final varshaDateTime = thisYearSolarReturn.isAfter(checkDate)
        ? await calculateSolarReturn(
            birthDateTime: birthDateTime,
            targetYear: checkDate.year - 1,
            location: location,
            flags: activeFlags,
          )
        : thisYearSolarReturn;

    return calculateVarshapal(
      birthDateTime: birthDateTime,
      varshaDateTime: varshaDateTime,
      location: location,
      houseSystem: houseSystem,
      flags: activeFlags,
      checkDate: checkDate,
    );
  }

  /// Alias for [calculateCurrentVarshapal] to support legacy tests.
  Future<Varshapal> getCurrentVarshapal({
    required DateTime birthDateTime,
    required GeographicLocation location,
    String houseSystem = 'W',
    CalculationFlags? flags,
    DateTime? checkDate,
  }) =>
      calculateCurrentVarshapal(
        birthDateTime: birthDateTime,
        location: location,
        houseSystem: houseSystem,
        flags: flags,
        checkDate: checkDate,
      );

  /// Calculates the exact millisecond the transiting Sun returns to its natal longitude.
  Future<DateTime> calculateSolarReturn({
    required DateTime birthDateTime,
    required int targetYear,
    required GeographicLocation location,
    CalculationFlags? flags,
  }) async {
    final activeFlags = flags ?? CalculationFlags.defaultFlags();
    final birthUtc = birthDateTime.isUtc
        ? birthDateTime
        : AstrologyTimeService.localToUtc(
            birthDateTime, location.timezone ?? 'UTC');

    final natalSunLong =
        await _getSunLongitude(birthUtc, location, activeFlags);

    // Initial guess: same month/day/time in the target year in local time, then to UTC
    final approxLocal = DateTime(
      targetYear,
      birthDateTime.month,
      birthDateTime.day,
      birthDateTime.hour,
      birthDateTime.minute,
      birthDateTime.second,
      birthDateTime.millisecond,
    );
    final approxUtc = AstrologyTimeService.localToUtc(
        approxLocal, location.timezone ?? 'UTC');

    var low = approxUtc.subtract(const Duration(days: 2));
    var high = approxUtc.add(const Duration(days: 2));
    var best = approxUtc;

    for (var i = 0; i < 35; i++) {
      if (high.difference(low).inMilliseconds <= 1) {
        break;
      }
      final midMs =
          (low.millisecondsSinceEpoch + high.millisecondsSinceEpoch) ~/ 2;
      final midTime = DateTime.fromMillisecondsSinceEpoch(midMs, isUtc: true);
      final midLong = await _getSunLongitude(midTime, location, activeFlags);

      var diff = midLong - natalSunLong;
      while (diff < -180) {
        diff += 360;
      }
      while (diff > 180) {
        diff -= 360;
      }

      if (diff.abs() < 1e-12) {
        best = midTime;
        break;
      }

      if (diff > 0) {
        high = midTime;
      } else {
        low = midTime;
      }
      best = midTime;
    }

    // Convert UTC result back to local timezone
    return AstrologyTimeService.utcToLocal(best, location.timezone ?? 'UTC');
  }

  Future<double> _getSunLongitude(
    DateTime dateTime,
    GeographicLocation location,
    CalculationFlags flags,
  ) async {
    final pos = await _ephemerisService.calculatePlanetPosition(
      planet: Planet.sun,
      dateTime: dateTime,
      location: location,
      flags: flags,
    );
    return pos.longitude;
  }

  /// Calculates Panchavargiya Bala (5-fold planetary strength) for a planet in a VedicChart.
  PanchavargiyaBalaResult calculatePanchavargiyaBala(
      Planet planet, VedicChart chart) {
    final planetInfo = chart.getPlanet(planet);
    if (planetInfo == null) {
      return PanchavargiyaBalaResult(
        planet: planet,
        kshetraBala: 0,
        haddaBala: 0,
        drekkanaBala: 0,
        navamsaBala: 0,
        ucchaBala: 0,
        totalBala: 0,
        vishwaBala: 0,
      );
    }

    final double longitude = planetInfo.longitude;
    final sign = Rashi.fromLongitude(longitude);
    final double degree = longitude % 30;

    // 1. Kshetra Bala
    final signLord = sign.lord;
    double kshetraBala = 15.0; // Default to neutral
    if (planet == signLord) {
      kshetraBala = 30.0;
    } else {
      final rel = _getTajikaFriendship(planet, signLord, chart);
      if (rel == RelationshipType.friend) {
        kshetraBala = 22.5;
      } else if (rel == RelationshipType.enemy) {
        kshetraBala = 7.5;
      }
    }

    // 2. Hadda Bala
    final haddaLord = _getHaddaLord(sign, degree);
    double haddaBala = 7.5; // Default to neutral
    if (planet == haddaLord) {
      haddaBala = 15.0;
    } else {
      final rel = _getTajikaFriendship(planet, haddaLord, chart);
      if (rel == RelationshipType.friend) {
        haddaBala = 11.25;
      } else if (rel == RelationshipType.enemy) {
        haddaBala = 3.75;
      }
    }

    // 3. Drekkana Bala
    final drekkanaLord = _getDrekkanaLord(sign, degree);
    double drekkanaBala = 5.0; // Default to neutral
    if (planet == drekkanaLord) {
      drekkanaBala = 10.0;
    } else {
      final rel = _getTajikaFriendship(planet, drekkanaLord, chart);
      if (rel == RelationshipType.friend) {
        drekkanaBala = 7.5;
      } else if (rel == RelationshipType.enemy) {
        drekkanaBala = 2.5;
      }
    }

    // 4. Navamsa Bala
    final navamsaLord = _getNavamsaLord(sign, degree);
    double navamsaBala = 2.5; // Default to neutral
    if (planet == navamsaLord) {
      navamsaBala = 5.0;
    } else {
      final rel = _getTajikaFriendship(planet, navamsaLord, chart);
      if (rel == RelationshipType.friend) {
        navamsaBala = 3.75;
      } else if (rel == RelationshipType.enemy) {
        navamsaBala = 1.25;
      }
    }

    // 5. Uccha Bala (Exaltation strength)
    final Map<Planet, double> exaltationDegrees = {
      Planet.sun: 10.0,
      Planet.moon: 33.0,
      Planet.mars: 298.0,
      Planet.mercury: 165.0,
      Planet.jupiter: 95.0,
      Planet.venus: 357.0,
      Planet.saturn: 200.0,
    };

    final E = exaltationDegrees[planet] ?? 0.0;
    final debilPoint = (E + 180.0) % 360.0;
    var diff = longitude - debilPoint;
    while (diff < 0) {
      diff += 360;
    }
    while (diff >= 360) {
      diff -= 360;
    }

    double ucchaBala;
    if (diff <= 180.0) {
      ucchaBala = diff / 9.0;
    } else {
      ucchaBala = (360.0 - diff) / 9.0;
    }

    final double totalBala =
        kshetraBala + haddaBala + drekkanaBala + navamsaBala + ucchaBala;
    final double vishwaBala = totalBala / 4.0;

    return PanchavargiyaBalaResult(
      planet: planet,
      kshetraBala: kshetraBala,
      haddaBala: haddaBala,
      drekkanaBala: drekkanaBala,
      navamsaBala: navamsaBala,
      ucchaBala: ucchaBala,
      totalBala: totalBala,
      vishwaBala: vishwaBala,
    );
  }

  /// Determines the Year Lord (Varshesh) using strict aspect checks from the five candidate planets.
  Planet determineVarshesh({
    required VedicChart natalChart,
    required VedicChart annualChart,
    required Map<Planet, PanchavargiyaBalaResult> balaMap,
    required DateTime varshaDateTime,
    required DateTime birthDateTime,
  }) {
    final janmaLagnaLord = Rashi.fromLongitude(natalChart.ascendant).lord;
    final varshaLagnaLord = Rashi.fromLongitude(annualChart.ascendant).lord;

    final age = varshaDateTime.year - birthDateTime.year;
    final munthaSignIndex =
        (Rashi.fromLongitude(natalChart.ascendant).number + age) % 12;
    final munthaLord = Rashi.values[munthaSignIndex].lord;

    final sunHouse = annualChart.getPlanet(Planet.sun)?.house ?? 1;
    final bool isDay = sunHouse >= 7 && sunHouse <= 12;

    // Dina-Ratri Lord: Sun for day birth, Moon for night birth
    final dinaRatriLord = isDay ? Planet.sun : Planet.moon;

    // Trirashi Lord
    final trirashiLord =
        getTrirashiLord(Rashi.fromLongitude(annualChart.ascendant), isDay);

    final candidates = [
      janmaLagnaLord,
      varshaLagnaLord,
      munthaLord,
      dinaRatriLord,
      trirashiLord,
    ];

    // Filter candidates that aspect the Lagna (house 1, 3, 4, 5, 7, 9, 10, 11)
    final eligibleCandidates = candidates.where((p) {
      final h = annualChart.getPlanet(p)?.house;
      if (h == null) return false;
      return h == 1 ||
          h == 3 ||
          h == 4 ||
          h == 5 ||
          h == 7 ||
          h == 9 ||
          h == 10 ||
          h == 11;
    }).toList();

    final List<Planet> activeCandidates =
        eligibleCandidates.isNotEmpty ? eligibleCandidates : candidates;

    Planet bestPlanet = activeCandidates.first;
    double maxBala = -1.0;

    for (final p in activeCandidates) {
      final bala = balaMap[p]?.totalBala ?? 0.0;
      if (bala > maxBala) {
        maxBala = bala;
        bestPlanet = p;
      } else if (bala == maxBala) {
        // Tie breaker 1: Occurrences
        final countP = candidates.where((c) => c == p).length;
        final countBest = candidates.where((c) => c == bestPlanet).length;
        if (countP > countBest) {
          bestPlanet = p;
        } else if (countP == countBest) {
          // Tie breaker 2: Priority order
          final priority = [
            varshaLagnaLord,
            janmaLagnaLord,
            munthaLord,
            trirashiLord,
            dinaRatriLord,
          ];
          if (priority.indexOf(p) < priority.indexOf(bestPlanet)) {
            bestPlanet = p;
          }
        }
      }
    }

    return bestPlanet;
  }

  Planet getTrirashiLord(Rashi lagnaSign, bool isDay) {
    final s = lagnaSign.index;
    if (isDay) {
      return switch (s) {
        0 => Planet.sun,
        1 => Planet.venus,
        2 => Planet.saturn,
        3 => Planet.venus,
        4 => Planet.jupiter,
        5 => Planet.moon,
        6 => Planet.mercury,
        7 => Planet.mars,
        8 => Planet.saturn,
        9 => Planet.mars,
        10 => Planet.jupiter,
        11 => Planet.moon,
        _ => Planet.sun,
      };
    } else {
      return switch (s) {
        0 => Planet.jupiter,
        1 => Planet.moon,
        2 => Planet.mercury,
        3 => Planet.mars,
        4 => Planet.sun,
        5 => Planet.venus,
        6 => Planet.saturn,
        7 => Planet.moon,
        8 => Planet.mercury,
        9 => Planet.jupiter,
        10 => Planet.mars,
        11 => Planet.saturn,
        _ => Planet.jupiter,
      };
    }
  }

  /// Calculates Mudda Dasha (scaled annual Vimshottari periods).
  Future<List<VarshapalPeriod>> calculateMuddaDasha({
    required DateTime birthDateTime,
    required DateTime varshaDateTime,
    required VedicChart annualChart,
    required GeographicLocation location,
    required CalculationFlags flags,
  }) async {
    final moonInfo = annualChart.getPlanet(Planet.moon);
    final double moonLongitude = moonInfo?.longitude ?? 0.0;

    final double nakshatraLength = 360.0 / 27.0; // 13.333333333333334
    final int nakshatraIndex = (moonLongitude / nakshatraLength).floor() % 27;
    final double nakshatraStart = nakshatraIndex * nakshatraLength;
    final double degreeInNakshatra = moonLongitude - nakshatraStart;
    final double fractionTraversed = degreeInNakshatra / nakshatraLength;
    final double fractionRemaining = (1.0 - fractionTraversed).clamp(0.0, 1.0);

    final int rulerIndex = nakshatraIndex % 9;

    final List<Planet> muddaOrder = [
      Planet.ketu,
      Planet.venus,
      Planet.sun,
      Planet.moon,
      Planet.mars,
      Planet.meanNode,
      Planet.jupiter,
      Planet.saturn,
      Planet.mercury,
    ];

    final Map<Planet, double> vimshottariYears = {
      Planet.ketu: 7,
      Planet.venus: 20,
      Planet.sun: 6,
      Planet.moon: 10,
      Planet.mars: 7,
      Planet.meanNode: 18,
      Planet.jupiter: 16,
      Planet.saturn: 19,
      Planet.mercury: 17,
    };

    final nextVarshaDateTime = await calculateSolarReturn(
      birthDateTime: birthDateTime,
      targetYear: varshaDateTime.year + 1,
      location: location,
      flags: flags,
    );
    final yearDuration = nextVarshaDateTime.difference(varshaDateTime);

    final List<VarshapalPeriod> muddaDashaList = [];
    var currentStart = varshaDateTime;

    // 1. Balance of starting planet
    final startPlanet = muddaOrder[rulerIndex];
    final startFullDurationMs =
        (vimshottariYears[startPlanet]! / 120.0) * yearDuration.inMilliseconds;
    final startBalanceMs = startFullDurationMs * fractionRemaining;
    final startBalanceDuration = Duration(milliseconds: startBalanceMs.round());

    if (startBalanceDuration.inMilliseconds > 0) {
      final end = currentStart.add(startBalanceDuration);
      muddaDashaList.add(VarshapalPeriod(
        type: VarshapalPeriodType.varsha,
        lord: startPlanet,
        startDate: currentStart,
        endDate: end,
        duration: startBalanceDuration,
      ));
      currentStart = end;
    }

    // 2. The other 8 planets in cycle
    for (int i = 1; i < 9; i++) {
      final p = muddaOrder[(rulerIndex + i) % 9];
      final pFullMs =
          (vimshottariYears[p]! / 120.0) * yearDuration.inMilliseconds;
      final pDuration = Duration(milliseconds: pFullMs.round());

      final end = currentStart.add(pDuration);
      muddaDashaList.add(VarshapalPeriod(
        type: VarshapalPeriodType.varsha,
        lord: p,
        startDate: currentStart,
        endDate: end,
        duration: pDuration,
      ));
      currentStart = end;
    }

    // 3. The elapsed portion of the starting planet at the end
    final startElapsedMs = startFullDurationMs - startBalanceMs;
    final startElapsedDuration = Duration(milliseconds: startElapsedMs.round());

    if (startElapsedDuration.inMilliseconds > 0) {
      final end = nextVarshaDateTime;
      final finalDuration = end.difference(currentStart);
      muddaDashaList.add(VarshapalPeriod(
        type: VarshapalPeriodType.varsha,
        lord: startPlanet,
        startDate: currentStart,
        endDate: end,
        duration: finalDuration,
      ));
    }

    return muddaDashaList;
  }

  Planet _getHaddaLord(Rashi sign, double degree) {
    switch (sign) {
      case Rashi.aries:
        if (degree < 6.0) return Planet.jupiter;
        if (degree < 12.0) return Planet.venus;
        if (degree < 20.0) return Planet.mercury;
        if (degree < 25.0) return Planet.mars;
        return Planet.saturn;
      case Rashi.taurus:
        if (degree < 8.0) return Planet.venus;
        if (degree < 14.0) return Planet.mercury;
        if (degree < 22.0) return Planet.jupiter;
        if (degree < 27.0) return Planet.saturn;
        return Planet.mars;
      case Rashi.gemini:
        if (degree < 6.0) return Planet.mercury;
        if (degree < 12.0) return Planet.jupiter;
        if (degree < 19.0) return Planet.venus;
        if (degree < 25.0) return Planet.mars;
        return Planet.saturn;
      case Rashi.cancer:
        if (degree < 7.0) return Planet.mars;
        if (degree < 13.0) return Planet.venus;
        if (degree < 19.0) return Planet.mercury;
        if (degree < 26.0) return Planet.jupiter;
        return Planet.saturn;
      case Rashi.leo:
        if (degree < 6.0) return Planet.jupiter;
        if (degree < 13.0) return Planet.venus;
        if (degree < 19.0) return Planet.saturn;
        if (degree < 25.0) return Planet.mercury;
        return Planet.mars;
      case Rashi.virgo:
        if (degree < 7.0) return Planet.mercury;
        if (degree < 17.0) return Planet.venus;
        if (degree < 21.0) return Planet.jupiter;
        if (degree < 28.0) return Planet.mars;
        return Planet.saturn;
      case Rashi.libra:
        if (degree < 6.0) return Planet.saturn;
        if (degree < 14.0) return Planet.mercury;
        if (degree < 21.0) return Planet.jupiter;
        if (degree < 28.0) return Planet.venus;
        return Planet.mars;
      case Rashi.scorpio:
        if (degree < 7.0) return Planet.mars;
        if (degree < 11.0) return Planet.venus;
        if (degree < 19.0) return Planet.jupiter;
        if (degree < 24.0) return Planet.mercury;
        return Planet.saturn;
      case Rashi.sagittarius:
        if (degree < 12.0) return Planet.jupiter;
        if (degree < 17.0) return Planet.venus;
        if (degree < 21.0) return Planet.mercury;
        if (degree < 26.0) return Planet.saturn;
        return Planet.mars;
      case Rashi.capricorn:
        if (degree < 7.0) return Planet.mercury;
        if (degree < 14.0) return Planet.jupiter;
        if (degree < 22.0) return Planet.venus;
        if (degree < 26.0) return Planet.saturn;
        return Planet.mars;
      case Rashi.aquarius:
        if (degree < 7.0) return Planet.mercury;
        if (degree < 13.0) return Planet.venus;
        if (degree < 20.0) return Planet.jupiter;
        if (degree < 25.0) return Planet.mars;
        return Planet.saturn;
      case Rashi.pisces:
        if (degree < 12.0) return Planet.venus;
        if (degree < 16.0) return Planet.jupiter;
        if (degree < 19.0) return Planet.mercury;
        if (degree < 28.0) return Planet.mars;
        return Planet.saturn;
    }
  }

  Planet _getDrekkanaLord(Rashi sign, double degree) {
    final int s = sign.index;
    final int drekkanaIndex = (degree / 10.0).floor().clamp(0, 2);
    final int drekkanaSignIndex = (s + drekkanaIndex * 4) % 12;
    return Rashi.values[drekkanaSignIndex].lord;
  }

  Planet _getNavamsaLord(Rashi sign, double degree) {
    final int s = sign.index;
    final int navIndex = (degree / (30.0 / 9.0)).floor().clamp(0, 8);
    final int startSignIndex = switch (s % 4) {
      0 => 0, // Fire: Aries
      1 => 9, // Earth: Capricorn
      2 => 6, // Air: Libra
      3 => 3, // Water: Cancer
      _ => 0,
    };
    final int navSignIndex = (startSignIndex + navIndex) % 12;
    return Rashi.values[navSignIndex].lord;
  }

  RelationshipType _getTajikaFriendship(
      Planet planetA, Planet planetB, VedicChart chart) {
    if (planetA == planetB) return RelationshipType.friend;
    final hA = chart.getPlanet(planetA)?.house;
    final hB = chart.getPlanet(planetB)?.house;
    if (hA == null || hB == null) return RelationshipType.neutral;
    final rel = ((hA - hB) % 12 + 12) % 12 + 1;
    if (rel == 3 || rel == 5 || rel == 9 || rel == 11) {
      return RelationshipType.friend;
    } else if (rel == 1 || rel == 4 || rel == 7 || rel == 10) {
      return RelationshipType.enemy;
    } else {
      return RelationshipType.neutral;
    }
  }

  /// Calculates the varsha number (1-60) based on Jupiter's longitude.
  int _calculateVarshaNumber(double jupiterLongitude) {
    // Jupiter moves approximately 30 per year in the zodiac
    // We use a simplified calculation based on Jupiter's position
    final signNumber = (jupiterLongitude / 30).floor();
    final degreeInSign = jupiterLongitude % 30;

    // Calculate position within the 60-year cycle
    // Each sign lasts approximately 12/60 = 0.2 years = ~2 months
    final cyclePosition = (signNumber * 2 + (degreeInSign / 15).floor()) % 60;
    return cyclePosition + 1;
  }

  /// Calculates all Varsha (year) periods.
  List<VarshapalPeriod> _calculateVarshaPeriods({
    required DateTime startDate,
    required Planet varshaLord,
  }) {
    final periods = <VarshapalPeriod>[];
    var currentDate = startDate;
    var currentLordIndex = varshaDasaOrder.indexOf(varshaLord);

    for (var i = 0; i < 7; i++) {
      final lord = varshaDasaOrder[currentLordIndex % 7];
      final durationYears = _getVarshaDuration(lord);
      final endDate =
          currentDate.add(Duration(days: (durationYears * 365.25).round()));

      periods.add(VarshapalPeriod(
        type: VarshapalPeriodType.varsha,
        lord: lord,
        startDate: currentDate,
        endDate: endDate,
        duration: endDate.difference(currentDate),
      ));

      currentDate = endDate;
      currentLordIndex++;
    }

    return periods;
  }

  /// Calculates all Maas (month) periods.
  List<VarshapalPeriod> _calculateMaasaPeriods({
    required DateTime startDate,
    required Planet varshaLord,
  }) {
    final periods = <VarshapalPeriod>[];
    var currentDate = startDate;
    var currentLordIndex = maasaDasaOrder.indexOf(varshaLord);

    for (var i = 0; i < 12; i++) {
      final lord = maasaDasaOrder[currentLordIndex % 7];
      final endDate = _addMaasaDuration(currentDate, lord);

      periods.add(VarshapalPeriod(
        type: VarshapalPeriodType.maasa,
        lord: lord,
        startDate: currentDate,
        endDate: endDate,
        duration: endDate.difference(currentDate),
      ));

      currentDate = endDate;
      currentLordIndex++;
    }

    return periods;
  }

  /// Calculates all Dina (day) periods.
  List<VarshapalPeriod> _calculateDinaPeriods({
    required DateTime startDate,
    required Planet varshaLord,
  }) {
    final periods = <VarshapalPeriod>[];
    var currentDate = startDate;
    var currentLordIndex = dinaDasaOrder.indexOf(varshaLord);

    // Calculate for the full year (approximately 360 days for Vedic calendar)
    for (var i = 0; i < 30; i++) {
      final lord = dinaDasaOrder[currentLordIndex % 7];
      final endDate = currentDate.add(const Duration(days: 1));

      periods.add(VarshapalPeriod(
        type: VarshapalPeriodType.dina,
        lord: lord,
        startDate: currentDate,
        endDate: endDate,
        duration: const Duration(days: 1),
      ));

      currentDate = endDate;
      currentLordIndex++;
    }

    return periods;
  }

  /// Calculates all Hora (hour) periods.
  List<VarshapalPeriod> _calculateHoraPeriods({
    required DateTime startDate,
    required Planet varshaLord,
  }) {
    final periods = <VarshapalPeriod>[];
    var currentDate = startDate;
    var currentLordIndex = horaDasaOrder.indexOf(varshaLord);

    // Calculate for 24 hours
    for (var i = 0; i < 24; i++) {
      final lord = horaDasaOrder[currentLordIndex % 7];
      final endDate = currentDate.add(const Duration(hours: 1));

      periods.add(VarshapalPeriod(
        type: VarshapalPeriodType.hora,
        lord: lord,
        startDate: currentDate,
        endDate: endDate,
        duration: const Duration(hours: 1),
      ));

      currentDate = endDate;
      currentLordIndex++;
    }

    return periods;
  }

  /// Gets the duration in years for each planet's Varsha period.
  double _getVarshaDuration(Planet planet) {
    // Traditional Varsha Dasa durations (in years)
    // Based on planetaryvimshottari ratios
    switch (planet) {
      case Planet.sun:
        return 1.0;
      case Planet.moon:
        return 1.0;
      case Planet.mars:
        return 1.0;
      case Planet.mercury:
        return 1.0;
      case Planet.jupiter:
        return 1.0;
      case Planet.venus:
        return 1.0;
      case Planet.saturn:
        return 1.0;
      default:
        return 1.0;
    }
  }

  /// Adds the appropriate duration for a Maas (month) based on the ruling planet.
  DateTime _addMaasaDuration(DateTime startDate, Planet lord) {
    // Each Maas (month) is approximately 30 days in Vedic calendar
    // But variations exist based on solar month vs lunar month
    return startDate.add(const Duration(days: 30));
  }

  /// Finds the current period from a list at a given date.
  VarshapalPeriod? _findCurrentPeriod(
    List<VarshapalPeriod> periods,
    DateTime checkDate,
  ) {
    for (final period in periods) {
      if (checkDate.isAfter(period.startDate) &&
          checkDate.isBefore(period.endDate)) {
        return period;
      }
      // Handle inclusive end date
      if (checkDate.isAtSameMomentAs(period.startDate) ||
          checkDate.isAtSameMomentAs(period.endDate)) {
        return period;
      }
    }
    return periods.isNotEmpty ? periods.first : null;
  }

  /// Gets the Samvatsara name for a given year number (1-60).
  static String getSamvatsaraName(int yearNumber) {
    return samvatsaraNames[(yearNumber - 1) % 60];
  }

  /// Gets the current Varsha number based on a date and reference year.
  static int getCurrentVarshaNumber(DateTime date, {int? referenceYear}) {
    // This requires knowing a reference point (e.g., 2025 = year 7 in cycle)
    // The cycle started in 1983 (Prabhava) - year 1
    referenceYear ??= DateTime.now().year;
    final yearsSince1983 = referenceYear - 1983;
    return ((yearsSince1983 % 60) + 1);
  }
}
