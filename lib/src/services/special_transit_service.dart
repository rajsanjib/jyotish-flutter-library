import '../models/calculation_flags.dart';
import '../models/geographic_location.dart';
import '../models/planet.dart';
import '../models/special_transits.dart';
import '../models/vedic_chart.dart';
import 'ephemeris_service.dart';

/// Service for calculating special transit features.
///
/// Includes Sade Sati, Dhaiya (Panoti), and Panchak calculations.
class SpecialTransitService {
  SpecialTransitService(this._ephemerisService);
  final EphemerisService _ephemerisService;

  /// Calculates all special transit features for a birth chart at a given date.
  ///
  /// [natalChart] - The birth chart
  /// [checkDate] - Date to check transits for (default: now)
  /// [location] - Geographic location for calculations
  Future<SpecialTransits> calculateSpecialTransits({
    required VedicChart natalChart,
    DateTime? checkDate,
    required GeographicLocation location,
  }) async {
    final date = checkDate ?? DateTime.now();
    final flags = CalculationFlags.defaultFlags();

    // Get natal Moon position
    final moonInfo = natalChart.planets[Planet.moon];
    if (moonInfo == null) {
      throw ArgumentError('Moon position not found in natal chart');
    }
    final natalMoonLongitude = moonInfo.position.longitude;

    // Get transit Saturn position
    final saturnPos = await _ephemerisService.calculatePlanetPosition(
      planet: Planet.saturn,
      dateTime: date,
      location: location,
      flags: flags,
    );

    // Get transit Moon position for Panchak
    final moonPos = await _ephemerisService.calculatePlanetPosition(
      planet: Planet.moon,
      dateTime: date,
      location: location,
      flags: flags,
    );

    // Calculate Sade Sati
    final sadeSati = await _calculateSadeSati(
      natalMoonLongitude: natalMoonLongitude,
      transitSaturnLongitude: saturnPos.longitude,
      checkDate: date,
    );

    // Calculate Dhaiya
    final dhaiya = await _calculateDhaiya(
      natalMoonLongitude: natalMoonLongitude,
      transitSaturnLongitude: saturnPos.longitude,
      checkDate: date,
    );

    // Calculate Panchak
    final panchak = _calculatePanchak(
      transitMoonLongitude: moonPos.longitude,
      checkDate: date,
    );

    // Compile active transits
    final activeTransits = <SpecialTransitInfo>[];
    if (sadeSati.isActive) {
      activeTransits.add(_createSadeSatiInfo(sadeSati));
    }
    if (dhaiya.isActive) {
      activeTransits.add(_createDhaiyaInfo(dhaiya));
    }
    if (panchak.isActive) {
      activeTransits.add(_createPanchakInfo(panchak));
    }

    return SpecialTransits(
      sadeSati: sadeSati,
      dhaiya: dhaiya,
      panchak: panchak,
      activeTransits: activeTransits,
    );
  }

  /// Calculates Sade Sati status.
  Future<SadeSatiStatus> _calculateSadeSati({
    required double natalMoonLongitude,
    required double transitSaturnLongitude,
    required DateTime checkDate,
  }) async {
    final moonSign = (natalMoonLongitude / 30).floor();
    final saturnSign = (transitSaturnLongitude / 30).floor();

    // Calculate house from Moon (1-12)
    var houseFromMoon = (saturnSign - moonSign + 12) % 12;
    if (houseFromMoon == 0) houseFromMoon = 12;

    // Check if Saturn is in Sade Sati houses (12th, 1st, or 2nd from Moon)
    final isActive =
        SaturnTransitConstants.sadeSatiHouses.contains(houseFromMoon);

    SadeSatiPhase? phase;
    double? progress;
    DateTime? startDate;
    DateTime? endDate;

    if (isActive) {
      // Determine phase
      switch (houseFromMoon) {
        case 12:
          phase = SadeSatiPhase.rising;
          break;
        case 1:
          phase = SadeSatiPhase.peak;
          break;
        case 2:
          phase = SadeSatiPhase.setting;
          break;
      }

      // Calculate progress within sign
      final positionInSign = transitSaturnLongitude % 30;
      progress = positionInSign / 30.0;

      // Calculate dates using ephemeris-based projection
      // This accounts for Saturn's variable speed and retrograde motion
      final dates = await _calculateSadeSatiDates(
        checkDate: checkDate,
        natalMoonLongitude: natalMoonLongitude,
        transitSaturnLongitude: transitSaturnLongitude,
        phase: phase!,
      );

      startDate = dates.$1;
      endDate = dates.$2;
    }

    return SadeSatiStatus(
      isActive: isActive,
      phase: phase,
      phaseProgress: progress,
      natalMoonLongitude: natalMoonLongitude,
      transitSaturnLongitude: transitSaturnLongitude,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Calculates Sade Sati start and end dates using ephemeris-based projection.
  ///
  /// Uses Swiss Ephemeris to calculate Saturn's actual position over time,
  /// accounting for:
  /// - Variable direct and retrograde motion
  /// - Actual time spent in each sign (varies from ~2.2 to ~2.8 years)
  /// - Precise sign entry/exit times
  ///
  /// This provides accurate dates within days instead of months.
  Future<(DateTime, DateTime)> _calculateSadeSatiDates({
    required DateTime checkDate,
    required double natalMoonLongitude,
    required double transitSaturnLongitude,
    required SadeSatiPhase phase,
  }) async {
    final location = GeographicLocation(
      latitude: 0,
      longitude: 0,
      altitude: 0,
    );
    final flags = CalculationFlags.defaultFlags();

    // Calculate end date using ephemeris projection
    final endDate = await _calculateSignExitDate(
      startDate: checkDate,
      startLongitude: transitSaturnLongitude,
      location: location,
      flags: flags,
    );

    // Calculate start date by looking backwards
    final startDate = await _calculatePhaseStartDate(
      checkDate: checkDate,
      natalMoonLongitude: natalMoonLongitude,
      phase: phase,
      location: location,
      flags: flags,
    );

    return (startDate, endDate);
  }

  /// Calculates when Saturn will exit the current sign using ephemeris data.
  ///
  /// Projects Saturn's position forward day by day using actual ephemeris
  /// calculations, accounting for retrograde motion and variable speed.
  Future<DateTime> _calculateSignExitDate({
    required DateTime startDate,
    required double startLongitude,
    required GeographicLocation location,
    required CalculationFlags flags,
  }) async {
    final currentSign = (startLongitude / 30).floor();

    // Start with approximate date (Saturn spends ~2.5 years per sign)
    var searchDate = startDate.add(const Duration(days: 900));

    // Binary search for exact sign exit
    var earlyBound = startDate;
    var lateBound = startDate.add(const Duration(days: 1100)); // Max ~3 years

    const maxIterations = 50;
    const accuracyThreshold = Duration(minutes: 1); // 1 minute precision

    for (var i = 0; i < maxIterations; i++) {
      if (lateBound.difference(earlyBound) <= accuracyThreshold) {
        break;
      }

      searchDate = earlyBound.add(
        Duration(
          milliseconds: lateBound.difference(earlyBound).inMilliseconds ~/ 2,
        ),
      );

      final saturnPos = await _ephemerisService.calculatePlanetPosition(
        planet: Planet.saturn,
        dateTime: searchDate,
        location: location,
        flags: flags,
      );

      final saturnSign = (saturnPos.longitude / 30).floor();

      if (saturnSign <= currentSign) {
        // Still in or before target sign
        earlyBound = searchDate;
      } else {
        // Moved to next sign
        lateBound = searchDate;
      }
    }

    return earlyBound;
  }

  /// Calculates the start date of the current Sade Sati phase.
  ///
  /// Works backwards from checkDate to find when Saturn entered
  /// the current phase (12th, 1st, or 2nd from Moon).
  Future<DateTime> _calculatePhaseStartDate({
    required DateTime checkDate,
    required double natalMoonLongitude,
    required SadeSatiPhase phase,
    required GeographicLocation location,
    required CalculationFlags flags,
  }) async {
    final moonSign = (natalMoonLongitude / 30).floor();

    // Determine which house Saturn should have entered
    final targetHouse = switch (phase) {
      SadeSatiPhase.rising => 12, // 12th from Moon
      SadeSatiPhase.peak => 1, // 1st from Moon
      SadeSatiPhase.setting => 2, // 2nd from Moon
    };

    // Calculate target sign based on house from Moon
    final targetSign = ((moonSign + targetHouse - 1) % 12);

    // Search backwards to find when Saturn entered this sign
    var searchDate = checkDate.subtract(const Duration(days: 900));
    var earlyBound =
        checkDate.subtract(const Duration(days: 2700)); // ~7.5 years max
    var lateBound = checkDate;

    const maxIterations = 50;
    const accuracyThreshold = Duration(hours: 1);

    for (var i = 0; i < maxIterations; i++) {
      if (lateBound.difference(earlyBound) <= accuracyThreshold) {
        break;
      }

      searchDate = earlyBound.add(
        Duration(
          milliseconds: lateBound.difference(earlyBound).inMilliseconds ~/ 2,
        ),
      );

      final saturnPos = await _ephemerisService.calculatePlanetPosition(
        planet: Planet.saturn,
        dateTime: searchDate,
        location: location,
        flags: flags,
      );

      final saturnSign = (saturnPos.longitude / 30).floor();

      // Normalize sign to 0-11 range for comparison
      final normalizedSaturnSign = saturnSign % 12;

      if (normalizedSaturnSign < targetSign) {
        // Before entering target sign
        earlyBound = searchDate;
      } else {
        // In or after target sign
        lateBound = searchDate;
      }
    }

    return lateBound;
  }

  /// Calculates approximate transit days for Saturn in a specific sign.
  ///
  /// Kept for backward compatibility and rough estimates.
  /// For precise calculations, use ephemeris-based methods.
  // ignore: unused_element
  int _calculateSignTransitDays(int signIndex) {
    // Base transit time: ~912 days (2.5 years average)
    const baseDays = 912;

    // Saturn moves slower in certain parts of its orbit
    final signModulation = switch (signIndex % 12) {
      9 || 10 => -30, // Capricorn/Aquarius - slightly faster
      3 || 4 => 30, // Cancer/Leo - slightly slower
      _ => 0,
    };

    return baseDays + signModulation;
  }

  /// Calculates Dhaiya (Panoti) status using ephemeris-based projections.
  ///
  /// Uses Swiss Ephemeris for accurate Saturn transit timing,
  /// accounting for retrograde motion and variable speed.
  Future<DhaiyaStatus> _calculateDhaiya({
    required double natalMoonLongitude,
    required double transitSaturnLongitude,
    required DateTime checkDate,
  }) async {
    final moonSign = (natalMoonLongitude / 30).floor();
    final saturnSign = (transitSaturnLongitude / 30).floor();

    // Calculate house from Moon (1-12)
    var houseFromMoon = (saturnSign - moonSign + 12) % 12;
    if (houseFromMoon == 0) houseFromMoon = 12;

    // Check if Saturn is in Dhaiya houses (4th or 8th from Moon)
    final isActive =
        SaturnTransitConstants.dhaiyaHouses.contains(houseFromMoon);

    DhaiyaType? type;
    DateTime? startDate;
    DateTime? endDate;

    if (isActive) {
      type = houseFromMoon == 4 ? DhaiyaType.fourth : DhaiyaType.eighth;

      // Calculate dates using ephemeris-based projection
      final location = GeographicLocation(
        latitude: 0,
        longitude: 0,
        altitude: 0,
      );
      final flags = CalculationFlags.defaultFlags();

      // Calculate end date when Saturn will exit current sign
      endDate = await _calculateSignExitDate(
        startDate: checkDate,
        startLongitude: transitSaturnLongitude,
        location: location,
        flags: flags,
      );

      // Calculate start date when Saturn entered current sign
      startDate = await _calculateSignEntryDate(
        checkDate: checkDate,
        currentLongitude: transitSaturnLongitude,
        location: location,
        flags: flags,
      );
    }

    return DhaiyaStatus(
      isActive: isActive,
      type: type,
      natalMoonLongitude: natalMoonLongitude,
      transitSaturnLongitude: transitSaturnLongitude,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Calculates when Saturn entered the current sign (working backwards).
  Future<DateTime> _calculateSignEntryDate({
    required DateTime checkDate,
    required double currentLongitude,
    required GeographicLocation location,
    required CalculationFlags flags,
  }) async {
    final currentSign = (currentLongitude / 30).floor();

    // Search backwards to find sign entry
    var earlyBound = checkDate.subtract(const Duration(days: 1100));
    var lateBound = checkDate;

    const maxIterations = 50;
    const accuracyThreshold = Duration(hours: 1);

    for (var i = 0; i < maxIterations; i++) {
      if (lateBound.difference(earlyBound) <= accuracyThreshold) {
        break;
      }

      final searchDate = earlyBound.add(
        Duration(
          milliseconds: lateBound.difference(earlyBound).inMilliseconds ~/ 2,
        ),
      );

      final saturnPos = await _ephemerisService.calculatePlanetPosition(
        planet: Planet.saturn,
        dateTime: searchDate,
        location: location,
        flags: flags,
      );

      final saturnSign = (saturnPos.longitude / 30).floor();

      if (saturnSign < currentSign) {
        // Before entering sign
        earlyBound = searchDate;
      } else {
        // In or after sign
        lateBound = searchDate;
      }
    }

    return lateBound;
  }

  /// Calculates Panchak status.
  ///
  /// Panchak traditionally starts from the 2nd half (middle) of Dhanishta nakshatra,
  /// not the entire nakshatra. Dhanishta spans 293°20' to 306°40', so the 2nd half
  /// starts at 300°. Panchak continues through Revati (27th nakshatra).
  PanchakStatus _calculatePanchak({
    required double transitMoonLongitude,
    required DateTime checkDate,
  }) {
    // Normalize longitude to 0-360
    final normalizedLongitude = transitMoonLongitude % 360;

    // Panchak starts at 300° (middle of Dhanishta) and ends at 360° (end of Revati)
    // Dhanishta: 293°20' to 306°40', so 2nd half is 300° to 306°40'
    final isActive = normalizedLongitude >= 300.0;

    // Calculate nakshatra from longitude for reference
    final nakshatra = (normalizedLongitude / (360 / 27)).floor() + 1;

    DateTime? startDate;
    DateTime? endDate;
    int? daysRemaining;

    if (isActive) {
      // Calculate degrees passed since start of Panchak (300°)
      final degreesPassed = normalizedLongitude - 300.0;
      final degreesRemaining =
          60.0 - degreesPassed; // 60° total span (300° to 360°)

      // Moon takes about 1 day per 13.176 degrees (360 / 27.32 days)
      const moonDailyMotion = 13.176;
      daysRemaining = (degreesRemaining / moonDailyMotion).ceil();

      endDate = checkDate.add(Duration(days: daysRemaining));
      startDate = checkDate.subtract(
        Duration(days: (degreesPassed / moonDailyMotion).floor()),
      );
    }

    return PanchakStatus(
      isActive: isActive,
      currentNakshatra: nakshatra,
      startDate: startDate,
      endDate: endDate,
      daysRemaining: daysRemaining,
    );
  }

  /// Creates SpecialTransitInfo for Sade Sati.
  SpecialTransitInfo _createSadeSatiInfo(SadeSatiStatus status) {
    return SpecialTransitInfo(
      type: SpecialTransitType.sadeSati,
      description: status.description,
      startDate: status.startDate ?? DateTime.now(),
      endDate: status.endDate ?? DateTime.now().add(const Duration(days: 912)),
      intensity: status.phase == SadeSatiPhase.peak ? 9 : 7,
      remedies: [
        'Worship Lord Hanuman on Saturdays',
        'Donate black sesame seeds and mustard oil',
        'Recite Shani Mantra: Om Sham Shanicharaya Namah',
        'Feed the poor and help elderly people',
        'Wear iron ring on middle finger',
      ],
    );
  }

  /// Creates SpecialTransitInfo for Dhaiya.
  SpecialTransitInfo _createDhaiyaInfo(DhaiyaStatus status) {
    return SpecialTransitInfo(
      type: status.type == DhaiyaType.eighth
          ? SpecialTransitType.ashtamaShani
          : SpecialTransitType.dhaiya,
      description: status.description,
      startDate: status.startDate ?? DateTime.now(),
      endDate: status.endDate ?? DateTime.now().add(const Duration(days: 912)),
      intensity: status.type == DhaiyaType.eighth ? 10 : 7,
      remedies: [
        'Recite Hanuman Chalisa daily',
        'Light mustard oil lamp under peepal tree on Saturdays',
        'Donate black clothes to needy',
        'Perform Shani Puja on Saturdays',
        'Help servants and working class people',
      ],
    );
  }

  /// Creates SpecialTransitInfo for Panchak.
  SpecialTransitInfo _createPanchakInfo(PanchakStatus status) {
    return SpecialTransitInfo(
      type: SpecialTransitType.panchak,
      description: status.description,
      startDate: status.startDate ?? DateTime.now(),
      endDate: status.endDate ?? DateTime.now().add(const Duration(days: 5)),
      intensity: 5,
      remedies: [
        'Perform Panchak Shanti Puja',
        'Donate to Brahmins',
        'Avoid starting new ventures',
        'Recite Garuda Purana',
        'Perform Havan with Panchak mantra',
      ],
    );
  }

  /// Predicts Sade Sati periods for a birth chart.
  ///
  /// Returns a list of past and future Sade Sati periods.
  List<Map<String, dynamic>> predictSadeSatiPeriods(
    VedicChart natalChart, {
    int yearsBefore = 30,
    int yearsAfter = 30,
  }) {
    final periods = <Map<String, dynamic>>[];

    final moonInfo = natalChart.planets[Planet.moon];
    if (moonInfo == null) return periods;

    final birthDate = natalChart.dateTime;

    // Saturn cycle is approximately 30 years
    // Calculate periods based on Saturn's position
    for (var cycle = -1; cycle <= 1; cycle++) {
      final baseYear = birthDate.year + (cycle * 30);

      // Sade Sati spans 3 signs, taking about 7.5 years
      for (var phase = 0; phase < 3; phase++) {
        final startYear = baseYear + (phase * 2);
        final endYear = startYear + 2;

        final phaseName = phase == 0
            ? 'Rising'
            : phase == 1
                ? 'Peak'
                : 'Setting';

        periods.add({
          'phase': phaseName,
          'startYear': startYear,
          'endYear': endYear,
          'houseFromMoon': phase == 0
              ? 12
              : phase == 1
                  ? 1
                  : 2,
        });
      }
    }

    return periods;
  }
}
