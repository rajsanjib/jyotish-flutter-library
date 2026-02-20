import '../models/dasha.dart';
import '../models/planet.dart';
import '../models/rashi.dart';
import '../models/vedic_chart.dart';

/// Internal helper class for Vimshottari planet info.
class _VimshottariPlanetInfo {
  const _VimshottariPlanetInfo(this.planet, this.name, this.years);
  final Planet planet;
  final String name;
  final double years;
}

/// Service for calculating Vedic dasha periods.
///
/// Supports Vimshottari, Yogini, Chara, Narayana, Ashtottari, and Kalachakra dasha systems.
///
/// Year Length Options:
/// - 365.25 (default): Sidereal year with leap days
/// - 360.0: Savana year (traditional) - 12 x 30-day months
///   Many traditional schools prefer the 360-day year for precision.
class DashaService {
  /// Default year length (sidereal year with leap days)
  static const double defaultYearLength = 365.25;
  
  /// Traditional Savana year length (360 days)
  static const double savanaYearLength = 360.0;

  /// Vimshottari dasha sequence: Sun, Moon, Mars, Rahu, Jupiter, Saturn, Mercury, Ketu, Venus
  static const List<Planet> vimshottariSequence = [
    Planet.sun,
    Planet.moon,
    Planet.mars,
    Planet.meanNode, // Rahu
    Planet.jupiter,
    Planet.saturn,
    Planet.mercury,
    Planet.ketu,
    Planet.venus,
  ];

  static const List<_VimshottariPlanetInfo> _vimshottariPlanets = [
    _VimshottariPlanetInfo(Planet.sun, 'Sun', 6.0),
    _VimshottariPlanetInfo(Planet.moon, 'Moon', 10.0),
    _VimshottariPlanetInfo(Planet.mars, 'Mars', 7.0),
    _VimshottariPlanetInfo(Planet.meanNode, 'Rahu', 18.0),
    _VimshottariPlanetInfo(Planet.jupiter, 'Jupiter', 16.0),
    _VimshottariPlanetInfo(Planet.saturn, 'Saturn', 19.0),
    _VimshottariPlanetInfo(Planet.mercury, 'Mercury', 17.0),
    _VimshottariPlanetInfo(Planet.ketu, 'Ketu', 7.0),
    _VimshottariPlanetInfo(Planet.venus, 'Venus', 20.0),
  ];

  static const List<int> _nakshatraDashaLordIndex = [
    7, 8, 0, 1, 2, 3, 4, 5, 6, // 1-9
    7, 8, 0, 1, 2, 3, 4, 5, 6, // 10-18
    7, 8, 0, 1, 2, 3, 4, 5, 6, // 19-27
  ];

  static const List<String> _nakshatraNames = [
    'Ashwini',
    'Bharani',
    'Krittika',
    'Rohini',
    'Mrigashira',
    'Ardra',
    'Punarvasu',
    'Pushya',
    'Ashlesha',
    'Magha',
    'Purva Phalguni',
    'Uttara Phalguni',
    'Hasta',
    'Chitra',
    'Swati',
    'Vishakha',
    'Anuradha',
    'Jyeshtha',
    'Mula',
    'Purva Ashadha',
    'Uttara Ashadha',
    'Shravana',
    'Dhanishta',
    'Shatabhisha',
    'Purva Bhadrapada',
    'Uttara Bhadrapada',
    'Revati'
  ];

  /// Calculates Vimshottari Dasha from birth details.
  ///
  /// [moonLongitude] - Moon's longitude in degrees (0-360)
  /// [birthDateTime] - Birth date and time
  /// [levels] - Number of dasha levels (1-4): Mahadasha, Antardasha, Pratyantardasha, Sookshmadasha
  /// [birthTimeUncertainty] - Uncertainty in birth time in minutes (for precision warning)
  /// [yearLength] - Year length in days. Default is 365.25 (sidereal).
  ///                 Use 360.0 for traditional Savana year (more precise for some schools).
  DashaResult calculateVimshottariDasha({
    required double moonLongitude,
    required DateTime birthDateTime,
    int levels = 3,
    int? birthTimeUncertainty,
    double yearLength = defaultYearLength,
  }) {
    const nakshatraWidth = 360.0 / 27;
    final nakshatraIndex = (moonLongitude / nakshatraWidth).floor() % 27;
    final positionInNakshatra = moonLongitude % nakshatraWidth;
    final pada = (positionInNakshatra / (nakshatraWidth / 4)).floor() + 1;
    final startingLordIndex = _nakshatraDashaLordIndex[nakshatraIndex];
    final portionTraversed = positionInNakshatra / nakshatraWidth;
    final portionRemaining = 1.0 - portionTraversed;
    final firstDashaYears = _vimshottariPlanets[startingLordIndex].years;
    final balanceDays = firstDashaYears * yearLength * portionRemaining;

    final mahadashas = _calculateMahadashas(
      birthDateTime: birthDateTime,
      startingLordIndex: startingLordIndex,
      balanceDays: balanceDays,
      levels: levels,
      yearLength: yearLength,
    );

    // Generate precision warning if birth time uncertainty is provided
    String? precisionWarning;
    if (birthTimeUncertainty != null && birthTimeUncertainty > 0) {
      precisionWarning =
          'Birth time uncertain by $birthTimeUncertainty minutes. '
          'Dasha timing may vary by up to ${(birthTimeUncertainty / 60 * 0.2).toStringAsFixed(1)} days.';
    }

    // Add note about year length used
    if (yearLength != defaultYearLength) {
      precisionWarning = precisionWarning != null 
          ? '$precisionWarning Using $yearLength-day year for calculations.'
          : 'Using $yearLength-day year for calculations.';
    }

    return DashaResult(
      type: DashaType.vimshottari,
      birthDateTime: birthDateTime,
      moonLongitude: moonLongitude,
      birthNakshatra: _nakshatraNames[nakshatraIndex],
      birthPada: pada,
      balanceOfFirstDasha: balanceDays,
      allMahadashas: mahadashas,
      precisionWarning: precisionWarning,
    );
  }

  List<DashaPeriod> _calculateMahadashas({
    required DateTime birthDateTime,
    required int startingLordIndex,
    required double balanceDays,
    required int levels,
    double yearLength = defaultYearLength,
  }) {
    final mahadashas = <DashaPeriod>[];
    var currentDate = birthDateTime;

    for (var cycle = 0; cycle < 2; cycle++) {
      for (var i = 0; i < 9; i++) {
        final lordIndex = (startingLordIndex + i) % 9;
        final planetInfo = _vimshottariPlanets[lordIndex];
        double durationDays =
            (cycle == 0 && i == 0) ? balanceDays : planetInfo.years * yearLength;
        final endDate = currentDate.add(Duration(days: durationDays.round()));

        List<DashaPeriod> subPeriods = [];
        if (levels >= 2) {
          subPeriods = _calculateAntardashas(
            mahadashaStart: currentDate,
            mahadashaDays: durationDays,
            startingLordIndex: lordIndex,
            levels: levels,
            yearLength: yearLength,
          );
        }

        mahadashas.add(DashaPeriod(
          lord: planetInfo.planet,
          lordName: planetInfo.name,
          startDate: currentDate,
          endDate: endDate,
          duration: Duration(days: durationDays.round()),
          level: 0,
          subPeriods: subPeriods,
        ));
        currentDate = endDate;
      }
    }
    return mahadashas;
  }

  List<DashaPeriod> _calculateAntardashas({
    required DateTime mahadashaStart,
    required double mahadashaDays,
    required int startingLordIndex,
    required int levels,
    double yearLength = defaultYearLength,
  }) {
    final antardashas = <DashaPeriod>[];
    var currentDate = mahadashaStart;

    for (var i = 0; i < 9; i++) {
      final lordIndex = (startingLordIndex + i) % 9;
      final planetInfo = _vimshottariPlanets[lordIndex];
      final durationDays = mahadashaDays * (planetInfo.years / 120.0);
      final endDate = currentDate.add(Duration(days: durationDays.round()));

      List<DashaPeriod> subPeriods = [];
      if (levels >= 3) {
        subPeriods = _calculatePratyantardashas(
          antardashaStart: currentDate,
          antardashaDays: durationDays,
          startingLordIndex: lordIndex,
          levels: levels,
        );
      }

      antardashas.add(DashaPeriod(
        lord: planetInfo.planet,
        lordName: planetInfo.name,
        startDate: currentDate,
        endDate: endDate,
        duration: Duration(days: durationDays.round()),
        level: 1,
        subPeriods: subPeriods,
      ));
      currentDate = endDate;
    }
    return antardashas;
  }

  List<DashaPeriod> _calculatePratyantardashas({
    required DateTime antardashaStart,
    required double antardashaDays,
    required int startingLordIndex,
    required int levels,
  }) {
    final pratyantardashas = <DashaPeriod>[];
    var currentDate = antardashaStart;

    for (var i = 0; i < 9; i++) {
      final lordIndex = (startingLordIndex + i) % 9;
      final planetInfo = _vimshottariPlanets[lordIndex];
      final durationDays = antardashaDays * (planetInfo.years / 120.0);
      final endDate = currentDate.add(Duration(days: durationDays.round()));

      List<DashaPeriod> subPeriods = [];
      if (levels >= 4) {
        subPeriods = _calculateSookshmadashas(
          pratyantharStart: currentDate,
          pratyantharDays: durationDays,
          startingLordIndex: lordIndex,
          levels: levels,
        );
      }

      pratyantardashas.add(DashaPeriod(
        lord: planetInfo.planet,
        lordName: planetInfo.name,
        startDate: currentDate,
        endDate: endDate,
        duration: Duration(days: durationDays.round()),
        level: 2,
        subPeriods: subPeriods,
      ));
      currentDate = endDate;
    }
    return pratyantardashas;
  }

  List<DashaPeriod> _calculateSookshmadashas({
    required DateTime pratyantharStart,
    required double pratyantharDays,
    required int startingLordIndex,
    required int levels,
  }) {
    final sookshmadashas = <DashaPeriod>[];
    var currentDate = pratyantharStart;

    for (var i = 0; i < 9; i++) {
      final lordIndex = (startingLordIndex + i) % 9;
      final planetInfo = _vimshottariPlanets[lordIndex];
      final durationDays = pratyantharDays * (planetInfo.years / 120.0);
      final endDate = currentDate.add(Duration(days: durationDays.round()));

      List<DashaPeriod> subPeriods = [];
      if (levels >= 5) {
        subPeriods = _calculatePranadashas(
          sookshmaStart: currentDate,
          sookshmaDays: durationDays,
          startingLordIndex: lordIndex,
        );
      }

      sookshmadashas.add(DashaPeriod(
        lord: planetInfo.planet,
        lordName: planetInfo.name,
        startDate: currentDate,
        endDate: endDate,
        duration: Duration(days: durationDays.round()),
        level: 3,
        subPeriods: subPeriods,
      ));
      currentDate = endDate;
    }
    return sookshmadashas;
  }

  List<DashaPeriod> _calculatePranadashas({
    required DateTime sookshmaStart,
    required double sookshmaDays,
    required int startingLordIndex,
  }) {
    final pranadashas = <DashaPeriod>[];
    var currentDate = sookshmaStart;

    for (var i = 0; i < 9; i++) {
      final lordIndex = (startingLordIndex + i) % 9;
      final planetInfo = _vimshottariPlanets[lordIndex];
      final durationDays = sookshmaDays * (planetInfo.years / 120.0);
      final endDate = currentDate.add(Duration(days: durationDays.round()));

      pranadashas.add(DashaPeriod(
        lord: planetInfo.planet,
        lordName: planetInfo.name,
        startDate: currentDate,
        endDate: endDate,
        duration: Duration(days: durationDays.round()),
        level: 4,
        subPeriods: const [],
      ));
      currentDate = endDate;
    }
    return pranadashas;
  }

  /// Calculates Yogini Dasha.
  DashaResult calculateYoginiDasha({
    required double moonLongitude,
    required DateTime birthDateTime,
    int levels = 3,
    int? birthTimeUncertainty,
  }) {
    const nakshatraWidth = 360.0 / 27;
    final nakshatraIndex = (moonLongitude / nakshatraWidth).floor() % 27;
    final positionInNakshatra = moonLongitude % nakshatraWidth;
    final startingYoginiIndex = (nakshatraIndex + 3) % 8;
    final portionRemaining = 1.0 - (positionInNakshatra / nakshatraWidth);
    final firstDashaYears = Yogini.values[startingYoginiIndex].years;
    final balanceDays = firstDashaYears * 365.25 * portionRemaining;

    final mahadashas = <DashaPeriod>[];
    var currentDate = birthDateTime;

    for (var cycle = 0; cycle < 4; cycle++) {
      for (var i = 0; i < 8; i++) {
        final idx = (startingYoginiIndex + i) % 8;
        final yogini = Yogini.values[idx];
        double durationDays =
            (cycle == 0 && i == 0) ? balanceDays : yogini.years * 365.25;
        final endDate = currentDate.add(Duration(days: durationDays.round()));

        List<DashaPeriod> subPeriods = [];
        if (levels >= 2) {
          subPeriods = _calculateYoginiAntardashas(
            mahadashaStart: currentDate,
            mahadashaDays: durationDays,
            startingYoginiIndex: idx,
            levels: levels,
          );
        }

        mahadashas.add(DashaPeriod(
            lord: yogini.planet,
            lordName: yogini.name,
            startDate: currentDate,
            endDate: endDate,
            duration: Duration(days: durationDays.round()),
            level: 0,
            subPeriods: subPeriods));
        currentDate = endDate;
      }
    }

    return DashaResult(
      type: DashaType.yogini,
      birthDateTime: birthDateTime,
      moonLongitude: moonLongitude,
      birthNakshatra: _nakshatraNames[nakshatraIndex],
      birthPada: (positionInNakshatra / (nakshatraWidth / 4)).floor() + 1,
      balanceOfFirstDasha: balanceDays,
      allMahadashas: mahadashas,
      precisionWarning: birthTimeUncertainty != null && birthTimeUncertainty > 0
          ? 'Birth time uncertain by $birthTimeUncertainty minutes. '
              'Dasha timing may vary by up to ${(birthTimeUncertainty / 60 * 0.2).toStringAsFixed(1)} days.'
          : null,
    );
  }

  List<DashaPeriod> _calculateYoginiAntardashas({
    required DateTime mahadashaStart,
    required double mahadashaDays,
    required int startingYoginiIndex,
    required int levels,
  }) {
    final antardashas = <DashaPeriod>[];
    var currentDate = mahadashaStart;

    // In Yogini Dasha, the order of Antardashas always starts from the Mahadasha lord
    // and follows the standard sequence: Mangala, Pingala, Dhanya, Bhramari, Bhadrika, Ulka, Siddha, Sankata
    for (var i = 0; i < 8; i++) {
      final idx = (startingYoginiIndex + i) % 8;
      final yogini = Yogini.values[idx];

      // Proportional duration:
      // Antardasha years = (Mahadasha Lord Years * Antardasha Lord Years) / 36
      // Since we work in days:
      // Sub-period Days = Total Period Days * (Sub-period Lord Years / 36)
      final durationDays = mahadashaDays * (yogini.years / 36.0);
      final endDate = currentDate.add(Duration(days: durationDays.round()));

      List<DashaPeriod> subPeriods = [];
      if (levels >= 3) {
        subPeriods = _calculateYoginiPratyantardashas(
          antardashaStart: currentDate,
          antardashaDays: durationDays,
          startingYoginiIndex: idx,
        );
      }

      antardashas.add(DashaPeriod(
        lord: yogini.planet,
        lordName: yogini.name,
        startDate: currentDate,
        endDate: endDate,
        duration: Duration(days: durationDays.round()),
        level: 1,
        subPeriods: subPeriods,
      ));
      currentDate = endDate;
    }
    return antardashas;
  }

  List<DashaPeriod> _calculateYoginiPratyantardashas({
    required DateTime antardashaStart,
    required double antardashaDays,
    required int startingYoginiIndex,
  }) {
    final pratyantardashas = <DashaPeriod>[];
    var currentDate = antardashaStart;

    for (var i = 0; i < 8; i++) {
      final idx = (startingYoginiIndex + i) % 8;
      final yogini = Yogini.values[idx];
      final durationDays = antardashaDays * (yogini.years / 36.0);
      final endDate = currentDate.add(Duration(days: durationDays.round()));

      pratyantardashas.add(DashaPeriod(
        lord: yogini.planet,
        lordName: yogini.name,
        startDate: currentDate,
        endDate: endDate,
        duration: Duration(days: durationDays.round()),
        level: 2,
        subPeriods: const [],
      ));
      currentDate = endDate;
    }
    return pratyantardashas;
  }

  /// Calculates Chara Dasha (Jaimini system).
  DashaResult calculateCharaDasha(VedicChart chart, {int levels = 3}) {
    final ascendantSign = Rashi.fromLongitude(chart.houses.ascendant);
    final isDirect = ascendantSign.isOdd;
    final sequence = <Rashi>[];

    for (var i = 0; i < 12; i++) {
      final idx = isDirect
          ? (ascendantSign.number + i) % 12
          : (ascendantSign.number - i + 12) % 12;
      sequence.add(Rashi.fromIndex(idx));
    }

    final mahadashas = <DashaPeriod>[];
    var currentDate = chart.dateTime;

    for (final sign in sequence) {
      final years = _calculateCharaDashaYears(sign, chart);
      final durationDays = years * 365.25;
      final endDate = currentDate.add(Duration(days: durationDays.round()));

      mahadashas.add(DashaPeriod(
        rashi: sign,
        startDate: currentDate,
        endDate: endDate,
        duration: Duration(days: durationDays.round()),
        level: 0,
      ));
      currentDate = endDate;
    }

    return DashaResult(
      type: DashaType.chara,
      birthDateTime: chart.dateTime,
      moonLongitude: chart.planets[Planet.moon]?.position.longitude ?? 0,
      birthNakshatra: chart.planets[Planet.moon]?.nakshatra ?? 'Unknown',
      birthPada: chart.planets[Planet.moon]?.pada ?? 0,
      balanceOfFirstDasha: 0,
      allMahadashas: mahadashas,
    );
  }

  int _calculateCharaDashaYears(Rashi sign, VedicChart chart) {
    final lord = _getSignLordAdvanced(sign, chart);
    final lordPos = chart.getPlanet(lord)?.position;
    if (lordPos == null) return 0;
    final lordSign = Rashi.fromLongitude(lordPos.longitude);

    int diff = sign.isOdd
        ? (lordSign.number - sign.number + 12) % 12
        : (sign.number - lordSign.number + 12) % 12;
    return diff == 0 ? 12 : diff;
  }

  /// Calculates Narayana Dasha (Jaimini-style sign dasha).
  DashaResult getNarayanaDasha(VedicChart chart, {int levels = 3}) {
    final lagnaSign = Rashi.fromLongitude(chart.houses.ascendant);
    final seventhSign = Rashi.fromIndex((lagnaSign.number + 6) % 12);
    final lagnaStrength = _calculateSignSourceStrength(lagnaSign, chart);
    final seventhStrength = _calculateSignSourceStrength(seventhSign, chart);
    final startingSign =
        lagnaStrength >= seventhStrength ? lagnaSign : seventhSign;

    final sequence = <Rashi>[];
    for (var i = 0; i < 12; i++) {
      sequence.add(Rashi.fromIndex((startingSign.number + (i * 6)) % 12));
    }

    final mahadashas = <DashaPeriod>[];
    var currentDate = chart.dateTime;

    for (final sign in sequence) {
      final years = _calculateNarayanaDashaYears(sign, chart);
      final durationDays = years * 365.25;
      final endDate = currentDate.add(Duration(days: durationDays.round()));

      List<DashaPeriod> subPeriods = [];
      if (levels >= 2) {
        subPeriods = _calculateNarayanaSubPeriods(
          sequence: sequence,
          mahadashaStart: currentDate,
          mahadashaEnd: endDate,
          mahadashaSign: sign,
          chart: chart,
          levels: levels - 1,
        );
      }

      mahadashas.add(DashaPeriod(
        rashi: sign,
        startDate: currentDate,
        endDate: endDate,
        duration: Duration(days: durationDays.round()),
        level: 0,
        subPeriods: subPeriods,
      ));
      currentDate = endDate;
    }

    return DashaResult(
      type: DashaType.narayana,
      birthDateTime: chart.dateTime,
      moonLongitude: chart.planets[Planet.moon]?.position.longitude ?? 0,
      birthNakshatra: chart.planets[Planet.moon]?.nakshatra ?? 'Unknown',
      birthPada: chart.planets[Planet.moon]?.pada ?? 0,
      balanceOfFirstDasha: 0,
      allMahadashas: mahadashas,
    );
  }

  int _calculateNarayanaDashaYears(Rashi sign, VedicChart chart) {
    final lord = _getSignLordAdvanced(sign, chart);
    final lordPos = chart.getPlanet(lord)?.position;
    if (lordPos == null) return 0;
    final lordSign = Rashi.fromLongitude(lordPos.longitude);
    final diff = (lordSign.number - sign.number + 12) % 12;
    return diff == 0 ? 12 : diff;
  }

  List<DashaPeriod> _calculateNarayanaSubPeriods({
    required List<Rashi> sequence,
    required DateTime mahadashaStart,
    required DateTime mahadashaEnd,
    required Rashi mahadashaSign,
    required VedicChart chart,
    required int levels,
  }) {
    if (levels <= 0) return [];
    final subPeriods = <DashaPeriod>[];
    final totalDuration = mahadashaEnd.difference(mahadashaStart);
    var currentDate = mahadashaStart;

    for (final sign in sequence) {
      final years = _calculateNarayanaDashaYears(sign, chart);
      final proportion = years / 12.0;
      final duration = Duration(
          milliseconds: (totalDuration.inMilliseconds * proportion).round());
      final endDate = currentDate.add(duration);
      if (endDate.isAfter(mahadashaEnd)) break;

      subPeriods.add(DashaPeriod(
        rashi: sign,
        startDate: currentDate,
        endDate: endDate,
        duration: duration,
        level: 1,
      ));
      currentDate = endDate;
    }
    return subPeriods;
  }

  /// Calculates Ashtottari Dasha (108-year cycle).
  DashaResult getAshtottariDasha(VedicChart chart,
      {AshtottariScheme scheme = AshtottariScheme.ardraAdi}) {
    final moonLongitude = chart.planets[Planet.moon]!.longitude;
    final ashtottariSequence = [
      Planet.sun,
      Planet.moon,
      Planet.mars,
      Planet.mercury,
      Planet.saturn,
      Planet.jupiter,
      Planet.meanNode,
      Planet.venus
    ];
    final ashtottariYears = {
      Planet.sun: 6.0,
      Planet.moon: 15.0,
      Planet.mars: 8.0,
      Planet.mercury: 17.0,
      Planet.saturn: 10.0,
      Planet.jupiter: 19.0,
      Planet.meanNode: 12.0,
      Planet.venus: 21.0
    };

    const nakshatraWidth = 360.0 / 27;
    final nakshatraIndex = (moonLongitude / nakshatraWidth).floor() % 27;
    final startOffset = scheme == AshtottariScheme.ardraAdi ? 5 : 2;
    final relativeNakIndex = (nakshatraIndex - startOffset + 27) % 27;

    final groups = [3, 4, 3, 4, 3, 4, 3, 3];
    int startingLordIndex = 0;
    int sum = 0;
    for (var i = 0; i < groups.length; i++) {
      sum += groups[i];
      if (relativeNakIndex < sum) {
        startingLordIndex = i;
        break;
      }
    }

    final firstDashaYears =
        ashtottariYears[ashtottariSequence[startingLordIndex]] ?? 6.0;
    final balanceDays = firstDashaYears *
        365.25 *
        (1.0 - (moonLongitude % nakshatraWidth / nakshatraWidth));

    final mahadashas = <DashaPeriod>[];
    var currentDate = chart.dateTime;

    for (var i = 0; i < 8; i++) {
      final lordIdx = (startingLordIndex + i) % 8;
      final planet = ashtottariSequence[lordIdx];
      final years = ashtottariYears[planet] ?? 6.0;
      final durationDays = i == 0 ? balanceDays : years * 365.25;
      final endDate = currentDate.add(Duration(days: durationDays.round()));

      mahadashas.add(DashaPeriod(
        lord: planet,
        startDate: currentDate,
        endDate: endDate,
        duration: Duration(days: durationDays.round()),
        level: 0,
      ));
      currentDate = endDate;
    }

    final nakPada =
        (moonLongitude % nakshatraWidth / (nakshatraWidth / 4)).floor() + 1;

    return DashaResult(
      type: DashaType.ashtottari,
      birthDateTime: chart.dateTime,
      moonLongitude: moonLongitude,
      birthNakshatra: _nakshatraNames[nakshatraIndex],
      birthPada: nakPada,
      balanceOfFirstDasha: balanceDays,
      allMahadashas: mahadashas,
    );
  }

  /// Calculates Kalachakra Dasha.
  DashaResult getKalachakraDasha(VedicChart chart) {
    final moonLongitude = chart.planets[Planet.moon]!.longitude;
    const nakshatraWidth = 360.0 / 27;
    final nakshatraIndex = (moonLongitude / nakshatraWidth).floor() % 27;
    final pada =
        (moonLongitude % nakshatraWidth / (nakshatraWidth / 4)).floor() + 1;
    final groupIdx = (nakshatraIndex / 3).floor();
    final isSavya = groupIdx % 2 == 0;

    final sequence = _getKalachakraSequence(nakshatraIndex, pada, isSavya);
    final mahadashas = <DashaPeriod>[];
    var currentDate = chart.dateTime;

    for (var sign in sequence) {
      final years = _getKalachakraYears(sign);
      final durationDays = years * 365.25;
      final endDate = currentDate.add(Duration(days: durationDays.round()));
      mahadashas.add(DashaPeriod(
          rashi: sign,
          startDate: currentDate,
          endDate: endDate,
          duration: Duration(days: durationDays.round()),
          level: 0));
      currentDate = endDate;
    }

    return DashaResult(
      type: DashaType.kalachakra,
      birthDateTime: chart.dateTime,
      moonLongitude: moonLongitude,
      birthNakshatra: _nakshatraNames[nakshatraIndex],
      birthPada: pada,
      balanceOfFirstDasha: 0,
      allMahadashas: mahadashas,
    );
  }

  double _getKalachakraYears(Rashi sign) {
    return switch (sign) {
      Rashi.aries || Rashi.scorpio => 7,
      Rashi.taurus || Rashi.libra => 16,
      Rashi.gemini || Rashi.virgo => 9,
      Rashi.cancer => 21,
      Rashi.leo => 5,
      Rashi.sagittarius || Rashi.pisces => 10,
      Rashi.capricorn || Rashi.aquarius => 4,
    };
  }

  List<Rashi> _getKalachakraSequence(int nakIdx, int pada, bool isSavya) {
    final savyaSequences = [
      [
        Rashi.aries,
        Rashi.taurus,
        Rashi.gemini,
        Rashi.cancer,
        Rashi.leo,
        Rashi.virgo,
        Rashi.libra,
        Rashi.scorpio,
        Rashi.sagittarius
      ],
      [
        Rashi.capricorn,
        Rashi.aquarius,
        Rashi.pisces,
        Rashi.scorpio,
        Rashi.libra,
        Rashi.virgo,
        Rashi.cancer,
        Rashi.leo,
        Rashi.gemini
      ],
      [
        Rashi.taurus,
        Rashi.aries,
        Rashi.sagittarius,
        Rashi.capricorn,
        Rashi.aquarius,
        Rashi.pisces,
        Rashi.scorpio,
        Rashi.libra,
        Rashi.virgo
      ],
      [
        Rashi.cancer,
        Rashi.leo,
        Rashi.gemini,
        Rashi.taurus,
        Rashi.aries,
        Rashi.sagittarius,
        Rashi.capricorn,
        Rashi.aquarius,
        Rashi.pisces
      ],
    ];
    return isSavya
        ? savyaSequences[(pada - 1) % 4]
        : savyaSequences[(pada - 1) % 4].reversed.toList();
  }

  Planet _getSignLordAdvanced(Rashi sign, VedicChart chart) {
    if (sign == Rashi.scorpio) {
      final mars = chart.getPlanet(Planet.mars);
      final ketu = chart.ketu;
      final marsSignPlanets = chart
          .getPlanetsInHouse(
              chart.houses.getHouseForLongitude(mars?.longitude ?? 0))
          .length;
      final ketuSignPlanets = chart
          .getPlanetsInHouse(chart.houses.getHouseForLongitude(ketu.longitude))
          .length;
      if (marsSignPlanets > ketuSignPlanets) return Planet.mars;
      if (ketuSignPlanets > marsSignPlanets) return Planet.ketu;
      return (mars?.longitude ?? 0) % 30 > (ketu.longitude % 30)
          ? Planet.mars
          : Planet.ketu;
    } else if (sign == Rashi.aquarius) {
      final saturn = chart.getPlanet(Planet.saturn);
      final rahu = chart.getPlanet(Planet.meanNode);
      final saturnSignPlanets = chart
          .getPlanetsInHouse(
              chart.houses.getHouseForLongitude(saturn?.longitude ?? 0))
          .length;
      final rahuSignPlanets = chart
          .getPlanetsInHouse(
              chart.houses.getHouseForLongitude(rahu?.longitude ?? 0))
          .length;
      if (saturnSignPlanets > rahuSignPlanets) return Planet.saturn;
      if (rahuSignPlanets > saturnSignPlanets) return Planet.meanNode;
      return (saturn?.longitude ?? 0) % 30 > (rahu?.longitude ?? 0) % 30
          ? Planet.saturn
          : Planet.meanNode;
    }
    return switch (sign) {
      Rashi.aries || Rashi.scorpio => Planet.mars,
      Rashi.taurus || Rashi.libra => Planet.venus,
      Rashi.gemini || Rashi.virgo => Planet.mercury,
      Rashi.cancer => Planet.moon,
      Rashi.leo => Planet.sun,
      Rashi.sagittarius || Rashi.pisces => Planet.jupiter,
      Rashi.capricorn || Rashi.aquarius => Planet.saturn,
    };
  }

  double _calculateSignSourceStrength(Rashi sign, VedicChart chart) {
    var strength = 0.0;
    strength += chart.planets.values
            .where((p) => Rashi.fromLongitude(p.longitude) == sign)
            .length *
        10.0;
    final lord = _getSignLordAdvanced(sign, chart);
    final lordInfo = chart.getPlanet(lord);
    if (lordInfo != null) {
      if (lordInfo.dignity == PlanetaryDignity.exalted) strength += 20.0;
      if (lordInfo.dignity == PlanetaryDignity.ownSign) strength += 15.0;
    }
    final ak = _getAtmakaraka(chart);
    final akInfo = chart.getPlanet(ak);
    if (akInfo != null && Rashi.fromLongitude(akInfo.longitude) == sign)
      strength += 50.0;
    return strength;
  }

  Planet _getAtmakaraka(VedicChart chart) {
    Planet ak = Planet.sun;
    double maxDeg = -1.0;
    for (final planet in Planet.traditionalPlanets) {
      final deg = (chart.getPlanet(planet)?.longitude ?? 0) % 30;
      if (deg > maxDeg) {
        maxDeg = deg;
        ak = planet;
      }
    }
    return ak;
  }
}
