import 'exceptions/jyotish_exception.dart';

import 'models/aspect.dart';
import 'models/ashtakavarga.dart';
import 'models/calculation_flags.dart';
import 'models/dasha.dart';
import 'models/divisional_chart_type.dart';
import 'models/geographic_location.dart';
import 'models/kp_calculations.dart';
import 'models/masa.dart';
import 'models/muhurta.dart';
import 'models/panchanga.dart';
import 'models/nakshatra.dart';
import 'models/arudha_pada.dart';
import 'models/argala.dart';
import 'models/bhava_bala.dart';
import 'models/jaimini.dart';
import 'models/prashna.dart';
import 'models/rashi.dart';
import 'models/gowri_panchangam.dart';
import 'models/planet.dart';
import 'models/planet_position.dart';
import 'models/relationship.dart';
import 'models/special_transits.dart';
import 'models/transit.dart';
import 'models/sudarshan_chakra.dart';
import 'models/vedic_chart.dart';
import 'models/varshapal.dart';
import 'models/house_strength.dart';
import 'models/nadi.dart';
import 'models/progeny.dart';
import 'models/compatibility.dart';

import 'services/aspect_service.dart';
import 'services/ashtakavarga_service.dart';
import 'services/astrology_time_service.dart';
import 'services/dasha_service.dart';
import 'services/divisional_chart_service.dart';
import 'services/ephemeris_service.dart';
import 'services/kp_service.dart';
import 'services/masa_service.dart';
import 'services/muhurta_service.dart';
import 'services/panchanga_service.dart';
import 'services/hora_service.dart';
import 'services/choghadiya_service.dart';
import 'services/gowri_panchangam_service.dart';
import 'services/arudha_pada_service.dart';
import 'services/argala_service.dart';
import 'services/bhava_bala_service.dart';
import 'services/jaimini_service.dart';
import 'services/prashna_service.dart';
import 'services/shadbala_service.dart';
import 'services/special_transit_service.dart';
import 'services/transit_service.dart';
import 'services/house_strength_service.dart';
import 'services/nadi_service.dart';
import 'services/progeny_service.dart';
import 'services/compatibility_service.dart';
import 'services/sudarshan_chakra_service.dart';
import 'services/vedic_chart_service.dart';
import 'services/gochara_vedha_service.dart';
import 'services/strength_analysis_service.dart';
import 'services/varshapal_service.dart';

/// The main entry point for the Jyotish library.
///
/// This class provides a high-level API for calculating planetary positions,
/// aspects, transits, and dashas using Swiss Ephemeris.
///
/// Example:
/// ```dart
/// final jyotish = Jyotish();
/// await jyotish.initialize();
///
/// final position = await jyotish.getPlanetPosition(
///   planet: Planet.sun,
///   dateTime: DateTime.now(),
///   location: GeographicLocation(
///     latitude: 27.7172,
///     longitude: 85.3240,
///   ),
/// );
///
/// print('Sun longitude: ${position.longitude}');
/// ```
class Jyotish {
  /// Creates a new instance of Jyotish.
  ///
  /// Use [initialize] to set up the Swiss Ephemeris data path before
  /// performing calculations.
  Jyotish._();

  /// Gets the singleton instance of Jyotish.
  factory Jyotish() {
    _instance ??= Jyotish._();
    return _instance!;
  }
  static Jyotish? _instance;
  EphemerisService? _ephemerisService;
  VedicChartService? _vedicChartService;
  AspectService? _aspectService;
  TransitService? _transitService;
  DashaService? _dashaService;
  DivisionalChartService? _divisionalChartService;
  PanchangaService? _panchangaService;
  AshtakavargaService? _ashtakavargaService;
  KPService? _kpService;
  SpecialTransitService? _specialTransitService;
  MuhurtaService? _muhurtaService;
  ShadbalaService? _shadbalaService;
  MasaService? _masaService;
  SudarshanChakraService? _sudarshanChakraService;
  HoraService? _horaService;
  ChoghadiyaService? _choghadiyaService;
  GowriPanchangamService? _gowriPanchangamService;
  ArudhaPadaService? _arudhaPadaService;
  ArgalaService? _argalaService;
  BhavaBalaService? _bhavaBalaService;
  JaiminiService? _jaiminiService;
  PrashnaService? _prashnaService;
  GocharaVedhaService? _gocharaVedhaService;
  StrengthAnalysisService? _strengthAnalysisService;
  VarshapalService? _varshapalService;
  HouseStrengthService? _houseStrengthService;
  NadiService? _nadiService;
  ProgenyService? _progenyService;
  CompatibilityService? _compatibilityService;
  bool _isInitialized = false;

  /// Initializes the Swiss Ephemeris library.
  ///
  /// [ephemerisPath] - Optional custom path to Swiss Ephemeris data files.
  /// If not provided, the library will look for data in the default locations.
  ///
  /// This method must be called before performing any calculations.
  ///
  /// Throws [JyotishException] if initialization fails.
  Future<void> initialize({String? ephemerisPath}) async {
    if (_isInitialized) {
      return;
    }

    try {
      AstrologyTimeService.initialize();
      _ephemerisService = EphemerisService();
      await _ephemerisService!.initialize(ephemerisPath: ephemerisPath);
      _vedicChartService = VedicChartService(_ephemerisService!);
      _aspectService = AspectService();
      _transitService = TransitService(_ephemerisService!);
      _dashaService = DashaService();
      _panchangaService = PanchangaService(_ephemerisService!);
      _ashtakavargaService = AshtakavargaService();
      _kpService = KPService(_ephemerisService!);
      _specialTransitService = SpecialTransitService(_ephemerisService!);
      _muhurtaService = MuhurtaService();
      _shadbalaService = ShadbalaService(_ephemerisService!);
      _masaService = MasaService(_ephemerisService!);
      _sudarshanChakraService = SudarshanChakraService();
      _horaService = HoraService(_ephemerisService!);
      _choghadiyaService = ChoghadiyaService(_ephemerisService!);
      _gowriPanchangamService = GowriPanchangamService(_ephemerisService!);
      _arudhaPadaService = ArudhaPadaService();
      _argalaService = ArgalaService();
      _bhavaBalaService = BhavaBalaService(_shadbalaService!);
      _jaiminiService = JaiminiService();
      _prashnaService = PrashnaService(_ephemerisService!);
      _gocharaVedhaService = GocharaVedhaService();
      _strengthAnalysisService = StrengthAnalysisService();
      _varshapalService = VarshapalService(_ephemerisService!);
      _houseStrengthService = HouseStrengthService(_shadbalaService!);
      _nadiService = NadiService();
      _progenyService = ProgenyService();
      _compatibilityService = CompatibilityService();
      _isInitialized = true;
    } catch (e) {
      throw JyotishException(
        'Failed to initialize Jyotish: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Calculates the position of a planet at a given date, time, and location.
  ///
  /// [planet] - The planet to calculate the position for.
  /// [dateTime] - The date and time for the calculation.
  /// [location] - The geographic location for the calculation.
  /// [flags] - Optional calculation flags for customizing the calculation.
  ///
  /// Returns a [PlanetPosition] containing the calculated position data.
  ///
  /// Throws [JyotishException] if the library is not initialized or
  /// if the calculation fails.
  Future<PlanetPosition> getPlanetPosition({
    required Planet planet,
    required DateTime dateTime,
    required GeographicLocation location,
    CalculationFlags? flags,
  }) async {
    _ensureInitialized();

    try {
      return await _ephemerisService!.calculatePlanetPosition(
        planet: planet,
        dateTime: dateTime,
        location: location,
        flags: flags ?? CalculationFlags.defaultFlags(),
      );
    } catch (e) {
      throw JyotishException(
        'Failed to calculate planet position: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Calculates positions for multiple planets at once.
  ///
  /// This is more efficient than calling [getPlanetPosition] multiple times.
  ///
  /// [planets] - List of planets to calculate positions for.
  /// [dateTime] - The date and time for the calculation.
  /// [location] - The geographic location for the calculation.
  /// [flags] - Optional calculation flags for customizing the calculation.
  ///
  /// Returns a Map of [Planet] to [PlanetPosition].
  ///
  /// Throws [JyotishException] if the library is not initialized or
  /// if any calculation fails.
  Future<Map<Planet, PlanetPosition>> getMultiplePlanetPositions({
    required List<Planet> planets,
    required DateTime dateTime,
    required GeographicLocation location,
    CalculationFlags? flags,
  }) async {
    _ensureInitialized();

    final Map<Planet, PlanetPosition> positions = {};

    for (final planet in planets) {
      positions[planet] = await getPlanetPosition(
        planet: planet,
        dateTime: dateTime,
        location: location,
        flags: flags,
      );
    }

    return positions;
  }

  /// Calculates positions for all major planets.
  ///
  /// This is a convenience method that calculates positions for:
  /// Sun, Moon, Mercury, Venus, Mars, Jupiter, Saturn, Uranus, Neptune, Pluto.
  ///
  /// [dateTime] - The date and time for the calculation.
  /// [location] - The geographic location for the calculation.
  /// [flags] - Optional calculation flags for customizing the calculation.
  ///
  /// Returns a Map of [Planet] to [PlanetPosition].
  Future<Map<Planet, PlanetPosition>> getAllPlanetPositions({
    required DateTime dateTime,
    required GeographicLocation location,
    CalculationFlags? flags,
  }) async {
    return getMultiplePlanetPositions(
      planets: Planet.majorPlanets,
      dateTime: dateTime,
      location: location,
      flags: flags,
    );
  }

  /// Calculates a complete Vedic astrology chart.
  ///
  /// This method provides comprehensive Vedic astrology data including:
  /// - All planetary positions in sidereal zodiac (Lahiri ayanamsa)
  /// - Rahu (North Node) and Ketu (South Node) positions
  /// - House placements for all planets
  /// - Planetary dignities (exaltation, debilitation, own sign, etc.)
  /// - Combustion status
  /// - Nakshatra and pada for all planets
  /// - Ascendant (Lagna) and house cusps
  ///
  /// [dateTime] - The date and time for the chart (usually birth time)
  /// [location] - The geographic location for the chart (usually birth place)
  /// [houseSystem] - House system to use (default: 'W' for Whole Sign)
  /// [includeOuterPlanets] - Include Uranus, Neptune, Pluto (default: false, not used in traditional Vedic astrology)
  ///
  /// Returns a [VedicChart] with complete chart information.
  ///
  /// Throws [JyotishException] if the library is not initialized or
  /// if the calculation fails.
  ///
  /// Example:
  /// ```dart
  /// final chart = await jyotish.calculateVedicChart(
  ///   dateTime: DateTime(1990, 5, 15, 14, 30),
  ///   location: GeographicLocation(latitude: 28.6139, longitude: 77.2090),
  /// );
  ///
  /// print('Ascendant: ${chart.ascendantSign}');
  /// print('Sun in house: ${chart.getPlanet(Planet.sun)?.house}');
  /// ```
  Future<VedicChart> calculateVedicChart({
    required DateTime dateTime,
    required GeographicLocation location,
    String houseSystem = 'W',
    bool includeOuterPlanets = false,
    CalculationFlags? flags,
  }) async {
    _ensureInitialized();

    try {
      return await _vedicChartService!.calculateChart(
        dateTime: dateTime,
        location: location,
        houseSystem: houseSystem,
        includeOuterPlanets: includeOuterPlanets,
        flags: flags,
      );
    } catch (e) {
      throw JyotishException(
        'Failed to calculate Vedic chart: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // ============================================================
  // DIVISIONAL CHART CALCULATIONS
  // ============================================================

  /// Calculates a specific Divisional Chart (Varga) from a Rashi chart.
  ///
  /// [rashiChart] - The base Rashi chart (D1) calculated using [calculateVedicChart]
  /// [type] - The type of divisional chart to calculate (e.g. [DivisionalChartType.d9])
  ///
  /// Returns a new [VedicChart] representing the divisional chart.
  /// NOTE: The 'longitude' values in the returned chart are the PROJECTED longitudes
  /// into the 0-360 zodiac. For example, if a planet is in the middle of Aries in D9,
  /// its longitude will be around 15°.
  /// The [HouseSystem] in the returned chart is typically a Whole Sign system
  /// based on the D-Chart Ascendant.
  VedicChart getDivisionalChart({
    required VedicChart rashiChart,
    required DivisionalChartType type,
  }) {
    // _ensureInitialized(); // Not needed for pure math
    _divisionalChartService ??= DivisionalChartService();
    return _divisionalChartService!.calculateDivisionalChart(rashiChart, type);
  }

  // ============================================================
  // ASPECT CALCULATIONS
  // ============================================================

  /// Calculates all Vedic aspects between planets at a given time.
  ///
  /// Vedic aspects (Graha Drishti) include:
  /// - All planets aspect the 7th house (opposition)
  /// - Mars has special aspects on 4th and 8th houses
  /// - Jupiter has special aspects on 5th and 9th houses
  /// - Saturn has special aspects on 3rd and 10th houses
  ///
  /// [dateTime] - Date and time for the calculation
  /// [location] - Geographic location
  /// [config] - Optional aspect calculation configuration
  ///
  /// Returns a list of all aspects found.
  ///
  /// Example:
  /// ```dart
  /// final aspects = await jyotish.getAspects(
  ///   dateTime: DateTime.now(),
  ///   location: location,
  /// );
  /// for (final aspect in aspects) {
  ///   print(aspect.description);
  /// }
  /// ```
  Future<List<AspectInfo>> getAspects({
    required DateTime dateTime,
    required GeographicLocation location,
    AspectConfig config = AspectConfig.vedic,
  }) async {
    _ensureInitialized();

    try {
      final positions = await getMultiplePlanetPositions(
        planets: [...Planet.traditionalPlanets, Planet.meanNode],
        dateTime: dateTime,
        location: location,
      );

      return _aspectService!.calculateAspects(positions, config: config);
    } catch (e) {
      throw JyotishException(
        'Failed to calculate aspects: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Gets all aspects involving a specific planet.
  ///
  /// [planet] - The planet to get aspects for
  /// [dateTime] - Date and time for the calculation
  /// [location] - Geographic location
  ///
  /// Returns aspects where the planet is either aspecting or being aspected.
  Future<List<AspectInfo>> getAspectsForPlanet({
    required Planet planet,
    required DateTime dateTime,
    required GeographicLocation location,
  }) async {
    _ensureInitialized();

    try {
      final positions = await getMultiplePlanetPositions(
        planets: [...Planet.traditionalPlanets, Planet.meanNode],
        dateTime: dateTime,
        location: location,
      );

      return _aspectService!.getAspectsForPlanet(planet, positions);
    } catch (e) {
      throw JyotishException(
        'Failed to calculate aspects for planet: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Calculates aspects within a Vedic chart.
  ///
  /// [chart] - A previously calculated Vedic chart
  /// [config] - Optional aspect configuration
  ///
  /// Returns list of all aspects in the chart.
  List<AspectInfo> getChartAspects(
    VedicChart chart, {
    AspectConfig config = AspectConfig.vedic,
  }) {
    _ensureInitialized();

    final positions = <Planet, PlanetPosition>{};
    for (final entry in chart.planets.entries) {
      positions[entry.key] = entry.value.position;
    }

    return _aspectService!.calculateAspects(positions, config: config);
  }

  // ============================================================
  // TRANSIT CALCULATIONS
  // ============================================================

  /// Calculates transit positions relative to a natal chart.
  ///
  /// [natalChart] - The birth chart to compare transits against
  /// [transitDateTime] - Date/time for transit positions (default: now)
  /// [location] - Geographic location for calculations
  ///
  /// Returns a map of planets to their transit information including
  /// which natal house they're transiting and aspects to natal planets.
  ///
  /// Example:
  /// ```dart
  /// final chart = await jyotish.calculateVedicChart(...);
  /// final transits = await jyotish.getTransitPositions(
  ///   natalChart: chart,
  ///   location: location,
  /// );
  /// print('Saturn transiting house ${transits[Planet.saturn]?.transitHouse}');
  /// ```
  Future<Map<Planet, TransitInfo>> getTransitPositions({
    required VedicChart natalChart,
    DateTime? transitDateTime,
    required GeographicLocation location,
  }) async {
    _ensureInitialized();

    try {
      return await _transitService!.calculateTransits(
        natalChart: natalChart,
        transitDateTime: transitDateTime ?? DateTime.now(),
        location: location,
      );
    } catch (e) {
      throw JyotishException(
        'Failed to calculate transits: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Finds significant transit events within a date range.
  ///
  /// [natalChart] - The birth chart
  /// [startDate] - Start of the date range
  /// [endDate] - End of the date range
  /// [location] - Geographic location
  /// [planets] - Optional list of planets to track (default: all traditional + Rahu)
  ///
  /// Returns list of transit events sorted by date.
  ///
  /// Example:
  /// ```dart
  /// final events = await jyotish.getTransitEvents(
  ///   natalChart: chart,
  ///   startDate: DateTime.now(),
  ///   endDate: DateTime.now().add(Duration(days: 365)),
  ///   location: location,
  /// );
  /// for (final event in events) {
  ///   print('${event.exactDate}: ${event.description}');
  /// }
  /// ```
  Future<List<TransitEvent>> getTransitEvents({
    required VedicChart natalChart,
    required DateTime startDate,
    required DateTime endDate,
    required GeographicLocation location,
    List<Planet>? planets,
  }) async {
    _ensureInitialized();

    try {
      final config = TransitConfig(
        startDate: startDate,
        endDate: endDate,
        planets: planets,
      );

      return await _transitService!.findTransitEvents(
        natalChart: natalChart,
        config: config,
        location: location,
      );
    } catch (e) {
      throw JyotishException(
        'Failed to find transit events: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // ============================================================
  // DASHA CALCULATIONS
  // ============================================================

  /// Calculates Vimshottari Dasha from a birth chart.
  ///
  /// Vimshottari is the most commonly used dasha system in Vedic astrology,
  /// with a 120-year cycle based on the Moon's nakshatra at birth.
  ///
  /// [natalChart] - The birth chart (Moon's position is used)
  /// [levels] - Number of dasha levels to calculate:
  ///   - 1 = Mahadasha only
  ///   - 2 = Mahadasha + Antardasha
  ///   - 3 = Mahadasha + Antardasha + Pratyantardasha (default)
  /// [birthTimeUncertainty] - Uncertainty in birth time (minutes) for warning
  ///
  /// Returns complete Vimshottari dasha calculation.
  ///
  /// Example:
  /// ```dart
  /// final dasha = await jyotish.getVimshottariDasha(natalChart: chart);
  /// print('Current dasha: ${dasha.getCurrentPeriodString(DateTime.now())}');
  /// print('Birth nakshatra: ${dasha.birthNakshatra}');
  /// ```
  /// 
  /// [yearLength] - Optional year length in days. Default is 365.25 (sidereal).
  /// Use 360.0 for traditional Savana year calculations.
  Future<DashaResult> getVimshottariDasha({
    required VedicChart natalChart,
    int levels = 3,
    int? birthTimeUncertainty,
    double yearLength = 365.25,
  }) async {
    _ensureInitialized();

    try {
      // Get Moon's position from the chart
      final moonInfo = natalChart.planets[Planet.moon];
      if (moonInfo == null) {
        throw JyotishException('Moon position not found in natal chart');
      }

      return _dashaService!.calculateVimshottariDasha(
        moonLongitude: moonInfo.position.longitude,
        birthDateTime: natalChart.dateTime,
        levels: levels,
        birthTimeUncertainty: birthTimeUncertainty,
        yearLength: yearLength,
      );
    } catch (e) {
      if (e is JyotishException) rethrow;
      throw JyotishException(
        'Failed to calculate Vimshottari dasha: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Calculates Yogini Dasha from a birth chart.
  ///
  /// Yogini is an alternate dasha system with a 36-year cycle,
  /// using 8 yoginis instead of 9 planets.
  ///
  /// [natalChart] - The birth chart (Moon's position is used)
  /// [levels] - Number of dasha levels to calculate (1-3)
  /// [birthTimeUncertainty] - Uncertainty in birth time (minutes) for warning
  ///
  /// Returns complete Yogini dasha calculation.
  Future<DashaResult> getYoginiDasha({
    required VedicChart natalChart,
    int levels = 3,
    int? birthTimeUncertainty,
  }) async {
    _ensureInitialized();

    try {
      final moonInfo = natalChart.planets[Planet.moon];
      if (moonInfo == null) {
        throw JyotishException('Moon position not found in natal chart');
      }

      return _dashaService!.calculateYoginiDasha(
        moonLongitude: moonInfo.position.longitude,
        birthDateTime: natalChart.dateTime,
        levels: levels,
        birthTimeUncertainty: birthTimeUncertainty,
      );
    } catch (e) {
      if (e is JyotishException) rethrow;
      throw JyotishException(
        'Failed to calculate Yogini dasha: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Gets the current dasha period at a specific date.
  ///
  /// [natalChart] - The birth chart
  /// [targetDate] - Date to find the current period for (default: now)
  /// [type] - Dasha system to use (default: Vimshottari)
  ///
  /// Returns list of active periods (mahadasha, antardasha, pratyantardasha).
  ///
  /// Example:
  /// ```dart
  /// final periods = await jyotish.getCurrentDasha(natalChart: chart);
  /// for (final period in periods) {
  ///   print('${period.levelName}: ${period.lord.displayName}');
  /// }
  /// ```
  Future<List<DashaPeriod>> getCurrentDasha({
    required VedicChart natalChart,
    DateTime? targetDate,
    DashaType type = DashaType.vimshottari,
  }) async {
    _ensureInitialized();

    try {
      final DashaResult result;
      if (type == DashaType.vimshottari) {
        result = await getVimshottariDasha(natalChart: natalChart);
      } else {
        result = await getYoginiDasha(natalChart: natalChart);
      }

      return result.getActivePeriodsAt(targetDate ?? DateTime.now());
    } catch (e) {
      if (e is JyotishException) rethrow;
      throw JyotishException(
        'Failed to get current dasha: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Calculates Ashtottari Dasha.
  ///
  /// Ashtottari Dasha is a 108-year cycle system used in specific conditions.
  ///
  /// [natalChart] - The Vedic birth chart
  /// [scheme] - Calculation scheme (Ardra-adi or Krittika-adi)
  ///
  /// Returns [DashaResult] with Ashtottari periods.
  Future<DashaResult> getAshtottariDasha({
    required VedicChart natalChart,
    AshtottariScheme scheme = AshtottariScheme.ardraAdi,
  }) async {
    _ensureInitialized();
    return _dashaService!.getAshtottariDasha(natalChart, scheme: scheme);
  }

  /// Calculates Kalachakra Dasha.
  ///
  /// Kalachakra Dasha is known as the "Wheel of Time" dasha.
  ///
  /// [natalChart] - The Vedic birth chart
  ///
  /// Returns [DashaResult] with Kalachakra periods.
  Future<DashaResult> getKalachakraDasha({
    required VedicChart natalChart,
  }) async {
    _ensureInitialized();
    return _dashaService!.getKalachakraDasha(natalChart);
  }

  // ============================================================
  // VARSHAPAL (ANNUAL CHART) CALCULATIONS
  // ============================================================

  /// Calculates the Varshapal (Annual Chart) for a given year.
  ///
  /// Varshapal is an annual chart calculated from the birthday each year.
  /// It shows the planetary influences for the entire year based on the
  /// solar return chart (when the Sun returns to the birth Sun position).
  ///
  /// The Varshapal has its own period system (Dasa):
  /// - Varsha Dasa: Year-long periods ruled by planets
  /// - Maas Dasa: Monthly periods
  /// - Dina Dasa: Daily periods
  /// - Hora Dasa: Hourly periods
  ///
  /// [birthDateTime] - Original birth date and time
  /// [varshaDateTime] - The birthday date/time for the year to calculate
  /// [location] - Birth location for chart calculation
  /// [houseSystem] - House system to use (default: Whole Sign 'W')
  /// [checkDate] - Optional date to check current periods (defaults to now)
  ///
  /// Returns [Varshapal] with chart and all period calculations.
  ///
  /// Example:
  /// ```dart
  /// final varshapal = await jyotish.getVarshapal(
  ///   birthDateTime: DateTime(1990, 5, 15, 10, 30),
  ///   varshaDateTime: DateTime(2025, 5, 15, 10, 30),
  ///   location: location,
  /// );
  /// print('Varsha Lord: ${varshapal.varshaLord.displayName}');
  /// print('Current Period: ${varshapal.getCurrentPeriodString(DateTime.now())}');
  /// ```
  Future<Varshapal> getVarshapal({
    required DateTime birthDateTime,
    required DateTime varshaDateTime,
    required GeographicLocation location,
    String houseSystem = 'W',
    DateTime? checkDate,
  }) async {
    _ensureInitialized();

    try {
      return await _varshapalService!.calculateVarshapal(
        birthDateTime: birthDateTime,
        varshaDateTime: varshaDateTime,
        location: location,
        houseSystem: houseSystem,
        checkDate: checkDate,
      );
    } catch (e) {
      if (e is JyotishException) rethrow;
      throw JyotishException(
        'Failed to calculate Varshapal: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Calculates the current Varshapal for this year.
  ///
  /// This calculates the annual chart from this year's birthday and
  /// determines the current periods.
  ///
  /// [birthDateTime] - Original birth date and time
  /// [location] - Birth location for chart calculation
  /// [houseSystem] - House system to use (default: Whole Sign 'W')
  /// [checkDate] - Optional date to check current periods (defaults to now)
  ///
  /// Returns [Varshapal] with chart and current period calculations.
  ///
  /// Example:
  /// ```dart
  /// final varshapal = await jyotish.getCurrentVarshapal(
  ///   birthDateTime: DateTime(1990, 5, 15, 10, 30),
  ///   location: location,
  /// );
  /// print('Samvatsara: ${varshapal.samvatsaraName}');
  /// print('Current Period: ${varshapal.getCurrentPeriodString(DateTime.now())}');
  /// ```
  Future<Varshapal> getCurrentVarshapal({
    required DateTime birthDateTime,
    required GeographicLocation location,
    String houseSystem = 'W',
    DateTime? checkDate,
  }) async {
    _ensureInitialized();

    try {
      return await _varshapalService!.calculateCurrentVarshapal(
        birthDateTime: birthDateTime,
        location: location,
        houseSystem: houseSystem,
        checkDate: checkDate,
      );
    } catch (e) {
      if (e is JyotishException) rethrow;
      throw JyotishException(
        'Failed to calculate current Varshapal: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // ============================================================
  // PANCHANGA CALCULATIONS
  // ============================================================

  /// Calculates the complete Panchanga (five limbs) for a given date.
  ///
  /// The Panchanga includes:
  /// - Tithi: Lunar phase (30 divisions)
  /// - Yoga: 27 lunar-solar combinations
  /// - Karana: 60 half-tithis
  /// - Vara: Weekday with planetary lord
  ///
  /// [dateTime] - The date and time for calculation
  /// [location] - The geographic location
  ///
  /// Returns a [Panchanga] with all five elements.
  ///
  /// Example:
  /// ```dart
  /// final panchanga = await jyotish.calculatePanchanga(
  ///   dateTime: DateTime.now(),
  ///   location: location,
  /// );
  /// print('Tithi: ${panchanga.tithi.name}');
  /// ```
  Future<Panchanga> calculatePanchanga({
    required DateTime dateTime,
    required GeographicLocation location,
  }) async {
    _ensureInitialized();

    try {
      return await _panchangaService!.calculatePanchanga(
        dateTime: dateTime,
        location: location,
      );
    } catch (e) {
      throw JyotishException(
        'Failed to calculate Panchanga: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Gets only the Tithi for a specific date.
  Future<TithiInfo> getTithi({
    required DateTime dateTime,
    required GeographicLocation location,
  }) async {
    _ensureInitialized();

    try {
      return await _panchangaService!.getTithi(
        dateTime: dateTime,
        location: location,
      );
    } catch (e) {
      throw JyotishException(
        'Failed to get Tithi: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Gets only the Nakshatra for a specific date.
  ///
  /// The Nakshatra is determined by the Moon's position and is one of the
  /// five limbs of the Panchanga. There are 27 nakshatras, each spanning
  /// 13°20' of the zodiac.
  ///
  /// [dateTime] - The date and time for calculation
  /// [location] - The geographic location
  ///
  /// Returns [NakshatraInfo] with name, number (1-27), ruling planet, and pada.
  ///
  /// Example:
  /// ```dart
  /// final nakshatra = await jyotish.getNakshatra(
  ///   dateTime: DateTime.now(),
  ///   location: location,
  /// );
  /// print('Nakshatra: ${nakshatra.name}');
  /// print('Ruler: ${nakshatra.rulingPlanet}');
  /// print('Pada: ${nakshatra.pada}');
  /// ```
  Future<NakshatraInfo> getNakshatra({
    required DateTime dateTime,
    required GeographicLocation location,
  }) async {
    _ensureInitialized();

    try {
      return await _panchangaService!.getNakshatra(
        dateTime: dateTime,
        location: location,
      );
    } catch (e) {
      throw JyotishException(
        'Failed to get Nakshatra: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Gets only the Yoga for a specific date.
  Future<YogaInfo> getYoga({
    required DateTime dateTime,
    required GeographicLocation location,
  }) async {
    _ensureInitialized();

    try {
      return await _panchangaService!.getYoga(
        dateTime: dateTime,
        location: location,
      );
    } catch (e) {
      throw JyotishException(
        'Failed to get Yoga: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Gets only the Karana for a specific date.
  Future<KaranaInfo> getKarana({
    required DateTime dateTime,
    required GeographicLocation location,
  }) async {
    _ensureInitialized();

    try {
      return await _panchangaService!.getKarana(
        dateTime: dateTime,
        location: location,
      );
    } catch (e) {
      throw JyotishException(
        'Failed to get Karana: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Gets the Vara (weekday lord) for a specific date and location.
  Future<VaraInfo> getVara({
    required DateTime dateTime,
    required GeographicLocation location,
  }) async {
    _ensureInitialized();
    return await _panchangaService!.getVara(dateTime, location);
  }

  /// Finds the exact end time of the current Tithi.
  Future<DateTime> getTithiEndTime({
    required DateTime dateTime,
    required GeographicLocation location,
  }) async {
    _ensureInitialized();
    return await _panchangaService!.getTithiEndTime(
      dateTime: dateTime,
      location: location,
    );
  }

  // ============================================================
  // MUHURTA EXTENSIONS (Hora, Choghadiya, Gowri)
  // ============================================================

  /// Gets the current planetary Hora (hour).
  Future<HoraPeriod> getCurrentHora({
    required DateTime dateTime,
    required GeographicLocation location,
  }) async {
    _ensureInitialized();
    return await _horaService!
        .getCurrentHora(dateTime: dateTime, location: location);
  }

  /// Gets all 24 Horas for a complete day.
  Future<List<HoraPeriod>> getHorasForDay({
    required DateTime date,
    required GeographicLocation location,
  }) async {
    _ensureInitialized();
    return await _horaService!.getHorasForDay(date: date, location: location);
  }

  /// Gets the current Choghadiya.
  Future<Choghadiya> getCurrentChoghadiya({
    required DateTime dateTime,
    required GeographicLocation location,
  }) async {
    _ensureInitialized();
    return await _choghadiyaService!
        .getCurrentChoghadiya(dateTime: dateTime, location: location);
  }

  /// Gets the current Gowri Panchangam.
  Future<GowriPanchangamInfo> getCurrentGowriPanchangam({
    required DateTime dateTime,
    required GeographicLocation location,
  }) async {
    _ensureInitialized();
    return await _gowriPanchangamService!
        .getCurrentGowriPanchangam(dateTime: dateTime, location: location);
  }

  // ============================================================
  // JAIMINI ASTROLOGY (Arudha, Argala, Karakamsa, Drishti)
  // ============================================================

  /// Gets the Atmakaraka (planet with highest degree).
  Planet getAtmakaraka(VedicChart chart) {
    _ensureInitialized();
    return _jaiminiService!.getAtmakaraka(chart);
  }

  /// Gets Karakamsa (Atmakaraka in Navamsa).
  KarakamsaInfo getKarakamsa({
    required VedicChart rashiChart,
    required VedicChart navamsaChart,
  }) {
    _ensureInitialized();
    return _jaiminiService!.getKarakamsa(
      rashiChart: rashiChart,
      navamsaChart: navamsaChart,
    );
  }

  /// Calculates Jaimini Rashi Drishti (Sign Aspects).
  List<RashiDrishtiInfo> getRashiDrishti(VedicChart chart) {
    _ensureInitialized();
    return _jaiminiService!.calculateRashiDrishti(chart);
  }

  /// Calculates Arudha Padas for a given chart.
  ArudhaPadaResult getArudhaPadas(VedicChart chart) {
    _ensureInitialized();
    return _arudhaPadaService!.calculateArudhaPadas(chart);
  }

  /// Calculates Arudha Lagna (AL).
  ArudhaPadaInfo getArudhaLagna(VedicChart chart) {
    _ensureInitialized();
    return _arudhaPadaService!.calculateArudhaLagna(chart);
  }

  /// Calculates Upapada (UL).
  ArudhaPadaInfo getUpapada(VedicChart chart) {
    _ensureInitialized();
    return _arudhaPadaService!.calculateUpapada(chart);
  }

  /// Calculates all Argalas for all houses.
  Map<int, List<ArgalaInfo>> getAllArgalas(VedicChart chart) {
    _ensureInitialized();
    return _argalaService!.calculateAllArgalas(chart);
  }

  /// Calculates Argalas for a specific house.
  List<ArgalaInfo> getArgalaForHouse(VedicChart chart, int house) {
    _ensureInitialized();
    return _argalaService!.calculateArgalaForHouse(chart, house);
  }

  /// Calculates only active Rashi Drishti (from occupied signs).
  List<RashiDrishtiInfo> getActiveRashiDrishti(VedicChart chart) {
    _ensureInitialized();
    return _jaiminiService!.calculateActiveRashiDrishti(chart);
  }

  /// Calculates high-precision sunrise and sunset times.
  ///
  /// Uses Swiss Ephemeris' swe_rise_trans function for professional-grade
  /// accuracy, accounting for geographic location, atmospheric refraction,
  /// altitude, and the Sun's disc size.
  ///
  /// [date] - The date to calculate for
  /// [location] - Geographic location
  /// [atpress] - Atmospheric pressure in mbar (default: 0 = standard)
  /// [attemp] - Atmospheric temperature in Celsius (default: 0 = standard)
  ///
  /// Returns a tuple (sunrise, sunset) in local timezone.
  /// Note: May return null for sunrise/sunset in polar regions during
  /// periods of midnight sun or polar night.
  ///
  /// Example:
  /// ```dart
  /// final (sunrise, sunset) = await jyotish.getSunriseSunset(
  ///   date: DateTime.now(),
  ///   location: location,
  /// );
  /// print('Sunrise: ${sunrise?.toLocal()}');
  /// print('Sunset: ${sunset?.toLocal()}');
  /// ```
  Future<(DateTime? sunrise, DateTime? sunset)> getSunriseSunset({
    required DateTime date,
    required GeographicLocation location,
    double atpress = 0.0,
    double attemp = 0.0,
  }) async {
    _ensureInitialized();

    try {
      return await _ephemerisService!.getSunriseSunset(
        date: date,
        location: location,
        atpress: atpress,
        attemp: attemp,
      );
    } catch (e) {
      throw JyotishException(
        'Failed to calculate sunrise/sunset: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Calculates high-precision rise or set time for any planet.
  ///
  /// Uses Swiss Ephemeris' swe_rise_trans function for professional-grade
  /// accuracy.
  ///
  /// [planet] - The planet to calculate (use Planet.sun for sunrise/sunset)
  /// [date] - The date to search
  /// [location] - Geographic location
  /// [rsmi] - Calculation flag:
  ///   - SwissEphConstants.calcRise (1) for rise time
  ///   - SwissEphConstants.calcSet (2) for set time
  ///   - SwissEphConstants.bitHinduRising for Hindu rising method
  ///
  /// Returns the DateTime of the event in UTC, or null if event doesn't occur.
  Future<DateTime?> getRiseSet({
    required Planet planet,
    required DateTime date,
    required GeographicLocation location,
    required int rsmi,
    double atpress = 0.0,
    double attemp = 0.0,
  }) async {
    _ensureInitialized();

    try {
      final result = await _ephemerisService!.getRiseSet(
        planet: planet,
        date: date,
        location: location,
        rsmi: rsmi,
        atpress: atpress,
        attemp: attemp,
      );
      return result;
    } catch (e) {
      throw JyotishException(
        'Failed to calculate rise/set: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // ============================================================
  // ASHTAKAVARGA CALCULATIONS
  // ============================================================

  /// Calculates the complete Ashtakavarga system for a birth chart.
  ///
  /// Ashtakavarga evaluates planetary strength by counting bindus
  /// contributed by each planet in each sign.
  ///
  /// [natalChart] - The birth chart
  ///
  /// Returns [Ashtakavarga] with Bhinnashtakavarga and Sarvashtakavarga.
  ///
  /// Example:
  /// ```dart
  /// final ashtakavarga = jyotish.calculateAshtakavarga(natalChart);
  /// print('1st House Points: ${ashtakavarga.getTotalBindusForHouse(1)}');
  /// ```
  Ashtakavarga calculateAshtakavarga(VedicChart natalChart) {
    _ensureInitialized();

    try {
      return _ashtakavargaService!.calculateAshtakavarga(natalChart);
    } catch (e) {
      throw JyotishException(
        'Failed to calculate Ashtakavarga: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Analyzes transit favorability using Ashtakavarga scores.
  ///
  /// [ashtakavarga] - Pre-calculated Ashtakavarga
  /// [transitPlanet] - The planet in transit
  /// [transitSign] - The sign being transited (0-11)
  /// [transitDate] - Optional transit date
  AshtakavargaTransit analyzeAshtakavargaTransit({
    required Ashtakavarga ashtakavarga,
    required Planet transitPlanet,
    required int transitSign,
    DateTime? transitDate,
  }) {
    _ensureInitialized();

    try {
      return _ashtakavargaService!.analyzeTransit(
        ashtakavarga: ashtakavarga,
        transitPlanet: transitPlanet,
        transitSign: transitSign,
        transitDate: transitDate,
      );
    } catch (e) {
      throw JyotishException(
        'Failed to analyze Ashtakavarga transit: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Gets favorable transit signs based on Ashtakavarga.
  ///
  /// Returns signs with more than 28 bindus in Sarvashtakavarga.
  List<int> getFavorableTransitSigns(
    Ashtakavarga ashtakavarga,
    Planet planet,
  ) {
    _ensureInitialized();
    return _ashtakavargaService!.getFavorableTransitSigns(ashtakavarga, planet);
  }

  // ============================================================
  // KP (KRISHNAMURTI PADDHATI) CALCULATIONS
  // ============================================================

  /// Calculates complete KP (Krishnamurti Paddhati) data for a chart.
  ///
  /// Includes Sub-Lord and Sub-Sub-Lord calculations for planets
  /// and house cusps, along with ABCD significators.
  ///
  /// [natalChart] - The birth chart
  /// [useNewAyanamsa] - Use KP New VP291 (true) or old KP (false)
  ///
  /// Returns [KPCalculations] with all KP-specific data.
  ///
  /// Example:
  /// ```dart
  /// final kpData = jyotish.calculateKPData(natalChart);
  /// final subLord = kpData.getPlanetSubLord(Planet.sun);
  /// print('Sun Sub-Lord: ${subLord?.subLord.displayName}');
  /// ```
  Future<KPCalculations> calculateKPData(
    VedicChart natalChart, {
    bool useNewAyanamsa = true,
  }) async {
    _ensureInitialized();

    try {
      return await _kpService!.calculateKPData(
        natalChart,
        useNewAyanamsa: useNewAyanamsa,
      );
    } catch (e) {
      throw JyotishException(
        'Failed to calculate KP data: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Gets the Sub-Lord for a specific longitude.
  Planet? getSubLord(double longitude) {
    _ensureInitialized();
    return _kpService!.getSubLord(longitude);
  }

  /// Gets the Sub-Sub-Lord for a specific longitude.
  Planet? getSubSubLord(double longitude) {
    _ensureInitialized();
    return _kpService!.getSubSubLord(longitude);
  }

  // ============================================================
  // SPECIAL TRANSIT FEATURES
  // ============================================================

  /// Calculates special transit features for a birth chart.
  ///
  /// Includes:
  /// - Sade Sati (7.5-year Saturn transit relative to Moon)
  /// - Dhaiya (2.5-year Panoti periods)
  /// - Panchak (inauspicious 5-day periods)
  ///
  /// [natalChart] - The birth chart
  /// [checkDate] - Date to check transits for (default: now)
  /// [location] - Geographic location
  Future<SpecialTransits> calculateSpecialTransits({
    required VedicChart natalChart,
    DateTime? checkDate,
    required GeographicLocation location,
  }) async {
    _ensureInitialized();

    try {
      return await _specialTransitService!.calculateSpecialTransits(
        natalChart: natalChart,
        checkDate: checkDate,
        location: location,
      );
    } catch (e) {
      throw JyotishException(
        'Failed to calculate special transits: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Predicts Sade Sati periods for a birth chart.
  ///
  /// Returns past and future Sade Sati periods with dates.
  List<Map<String, dynamic>> predictSadeSatiPeriods(
    VedicChart natalChart, {
    int yearsBefore = 30,
    int yearsAfter = 30,
  }) {
    _ensureInitialized();
    return _specialTransitService!.predictSadeSatiPeriods(
      natalChart,
      yearsBefore: yearsBefore,
      yearsAfter: yearsAfter,
    );
  }

  // ============================================================
  // MUHURTA (AUSPICIOUS PERIODS)
  // ============================================================

  /// Calculates complete Muhurta for a day.
  ///
  /// Includes:
  /// - Hora (planetary hours)
  /// - Choghadiya (auspicious/inauspicious periods)
  /// - Rahukalam, Gulikalam, Yamagandam (inauspicious times)
  ///
  /// [date] - The date for calculation
  /// [sunrise] - Sunrise time
  /// [sunset] - Sunset time
  /// [location] - Geographic location
  Muhurta calculateMuhurta({
    required DateTime date,
    required DateTime sunrise,
    required DateTime sunset,
    required GeographicLocation location,
  }) {
    _ensureInitialized();

    try {
      return _muhurtaService!.calculateMuhurta(
        date: date,
        sunrise: sunrise,
        sunset: sunset,
        location: location,
      );
    } catch (e) {
      throw JyotishException(
        'Failed to calculate Muhurta: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Gets Hora (planetary hour) periods for a day.
  List<HoraPeriod> getHoraPeriods({
    required DateTime date,
    required DateTime sunrise,
    required DateTime sunset,
  }) {
    _ensureInitialized();
    return _muhurtaService!.getHoraPeriods(
      date: date,
      sunrise: sunrise,
      sunset: sunset,
    );
  }

  /// Gets Choghadiya periods for a day.
  ChoghadiyaPeriods getChoghadiya({
    required DateTime date,
    required DateTime sunrise,
    required DateTime sunset,
  }) {
    _ensureInitialized();
    return _muhurtaService!.getChoghadiya(
      date: date,
      sunrise: sunrise,
      sunset: sunset,
    );
  }

  /// Gets inauspicious periods (Rahukalam, Gulikalam, Yamagandam) for a day.
  InauspiciousPeriods getInauspiciousPeriods({
    required DateTime date,
    required DateTime sunrise,
    required DateTime sunset,
  }) {
    _ensureInitialized();
    return _muhurtaService!.getInauspiciousPeriods(
      date: date,
      sunrise: sunrise,
      sunset: sunset,
    );
  }

  /// Finds the best Muhurta for a specific activity.
  ///
  /// [muhurta] - Pre-calculated Muhurta
  /// [activity] - The activity to find favorable time for
  List<MuhurtaPeriod> findBestMuhurta({
    required Muhurta muhurta,
    required String activity,
  }) {
    _ensureInitialized();
    return _muhurtaService!.findBestMuhurta(
      muhurta: muhurta,
      activity: activity,
    );
  }

  /// Disposes of resources used by the library.
  ///
  /// Call this method when you're done using the library to free up resources.
  void dispose() {
    _ephemerisService?.dispose();
    _isInitialized = false;
  }

  /// Calculates Chara Dasha from a birth chart.
  ///
  /// Chara Dasha is a Jaimini-style sign-based dasha system where signs (rashis)
  /// become the dasha lords instead of planets. The sequence and duration depend
  /// on the Lagna (Ascendant) and the positions of the sign lords.
  ///
  /// This implementation includes:
  /// - Multi-level sub-periods (antardasha, pratyantardasha)
  /// - Advanced sign-lord logic for dual-owned signs (Scorpio/Aquarius)
  /// - Proper odd/even sign sequence handling
  ///
  /// [natalChart] - The birth chart to use
  /// [levels] - Number of dasha levels (1 = mahadasha only, 2 = + antardasha,
  ///            3 = + pratyantardasha, etc.). Default is 3.
  ///
  /// Example:
  /// ```dart
  /// final charaDasha = await jyotish.getCharaDasha(
  ///   natalChart: chart,
  ///   levels: 3, // Get mahadasha, antardasha, and pratyantardasha
  /// );
  ///
  /// for (final mahadasha in charaDasha.allMahadashas) {
  ///   print('${mahadasha.rashi?.name}: ${mahadasha.startDate} - ${mahadasha.endDate}');
  ///   for (final antardasha in mahadasha.subPeriods) {
  ///     print('  ${antardasha.rashi?.name}: ${antardasha.startDate} - ${antardasha.endDate}');
  ///   }
  /// }
  /// ```
  Future<DashaResult> getCharaDasha({
    required VedicChart natalChart,
    int levels = 3,
  }) async {
    _ensureInitialized();
    return _dashaService!.calculateCharaDasha(natalChart, levels: levels);
  }

  /// Calculates Narayana Dasha (Jaimini Rashi Dasha).
  ///
  /// [chart] - The Vedic chart
  /// [levels] - Number of dasha levels
  Future<DashaResult> getNarayanaDasha({
    required VedicChart chart,
    int levels = 3,
  }) async {
    _ensureInitialized();
    return _dashaService!.getNarayanaDasha(chart, levels: levels);
  }

  /// Calculates complete planetary relationships (Panchadha Maitri).
  ///
  /// Includes Natural (Naisargika) and Temporary (Tatkalika) relationships.
  ///
  /// [natalChart] - The birth chart to calculate temporary relationships from.
  List<PlanetaryRelationship> getPlanetaryRelationships({
    required VedicChart natalChart,
  }) {
    _ensureInitialized();
    final results = <PlanetaryRelationship>[];
    final traditional = Planet.traditionalPlanets;

    for (var i = 0; i < traditional.length; i++) {
      final p1 = traditional[i];
      final info1 = natalChart.planets[p1];
      if (info1 == null) continue;

      for (var j = 0; j < traditional.length; j++) {
        if (i == j) continue;
        final p2 = traditional[j];
        final info2 = natalChart.planets[p2];
        if (info2 == null) continue;

        final natural = RelationshipCalculator.naturalRelationships[p1]?[p2] ??
            RelationshipType.neutral;

        final temporary =
            RelationshipCalculator.calculateTemporary(info1.house, info2.house);

        final compound =
            RelationshipCalculator.calculateCompound(natural, temporary);

        results.add(PlanetaryRelationship(
          planet: p1,
          otherPlanet: p2,
          natural: natural,
          temporary: temporary,
          compound: compound,
        ));
      }
    }
    return results;
  }

  /// Applies reductions to an Ashtakavarga.
  ///
  /// [ashtakavarga] - The base Ashtakavarga to reduce
  /// [trikonaReduction] - Whether to apply Trikona Shodhana
  /// [ekadhipatiReduction] - Whether to apply Ekadhipati Shodhana
  Ashtakavarga getAshtakavargaReductions(
    Ashtakavarga ashtakavarga, {
    bool trikonaReduction = true,
    bool ekadhipatiReduction = true,
  }) {
    _ensureInitialized();
    _ashtakavargaService ??= AshtakavargaService();

    var result = ashtakavarga;
    if (trikonaReduction) {
      result = _ashtakavargaService!.applyTrikonaShodhana(result);
    }
    if (ekadhipatiReduction) {
      result = _ashtakavargaService!.applyEkadhipatiShodhana(result);
    }
    return result;
  }

  /// Ensures that the library has been initialized.
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw JyotishException(
          'Jyotish library not initialized. Call initialize() first.');
    }
  }

  /// Calculates Shadbala (six-fold strength) for all planets in a chart.
  ///
  /// [chart] - The Vedic birth chart
  /// Returns a map of planets to their Shadbala results.
  Future<Map<Planet, ShadbalaResult>> getShadbala(VedicChart chart) async {
    _ensureInitialized();
    return await _shadbalaService!.calculateShadbala(chart);
  }

  // ============================================================
  // LUNAR MONTH (MASA) CALCULATIONS
  // ============================================================

  /// Calculates the lunar month (Masa) for a given date and location.
  ///
  /// Supports both Amanta (month starts from Amavasya/New Moon) and
  /// Purnimanta (month starts from Purnima/Full Moon) systems.
  ///
  /// [dateTime] - The date and time for calculation
  /// [location] - The geographic location
  /// [type] - The lunar month system to use (default: Amanta)
  ///
  /// Returns [MasaInfo] with month details including:
  /// - Month name (Chaitra, Vaishakha, etc.)
  /// - Month number (1-12)
  /// - System type (Amanta/Purnimanta)
  /// - Adhika Masa status (extra lunar month)
  ///
  /// Example:
  /// ```dart
  /// final masa = await jyotish.getMasa(
  ///   dateTime: DateTime.now(),
  ///   location: location,
  ///   type: MasaType.amanta,
  /// );
  /// print('Current month: ${masa.displayName}');
  /// ```
  Future<MasaInfo> getMasa({
    required DateTime dateTime,
    required GeographicLocation location,
    MasaType type = MasaType.amanta,
  }) async {
    _ensureInitialized();

    try {
      return await _masaService!.calculateMasa(
        dateTime: dateTime,
        location: location,
        type: type,
      );
    } catch (e) {
      throw JyotishException(
        'Failed to calculate Masa: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Calculates lunar month using Amanta system.
  ///
  /// Amanta: The lunar month starts from Amavasya (New Moon).
  /// Used in Southern India, Gujarat, and some other regions.
  Future<MasaInfo> getAmantaMasa({
    required DateTime dateTime,
    required GeographicLocation location,
  }) async {
    return getMasa(
        dateTime: dateTime, location: location, type: MasaType.amanta);
  }

  /// Calculates lunar month using Purnimanta system.
  ///
  /// Purnimanta: The lunar month starts from Purnima (Full Moon).
  /// Used in Northern India.
  Future<MasaInfo> getPurnimantaMasa({
    required DateTime dateTime,
    required GeographicLocation location,
  }) async {
    return getMasa(
        dateTime: dateTime, location: location, type: MasaType.purnimanta);
  }

  /// Gets Sudarshan Chakra strength.
  ///
  /// [chart] - The calculated Vedic birth chart
  ///
  /// Returns [SudarshanChakraResult] with strength analysis.
  SudarshanChakraResult getSudarshanChakra(VedicChart chart) {
    _ensureInitialized();
    return _sudarshanChakraService!.calculateSudarshanChakra(chart);
  }

  // ============================================================
  // STRENGTH CALCULATIONS (SHADBALA, BHAVA BALA, ETC.)
  // ============================================================

  /// Calculates Bhava Bala (House Strength).
  ///
  /// [chart] - The Vedic birth chart
  ///
  /// Returns map of house number (1-12) to [BhavaBalaResult].
  Future<Map<int, BhavaBalaResult>> getBhavaBala(VedicChart chart) async {
    _ensureInitialized();
    return await _bhavaBalaService!.calculateBhavaBala(chart);
  }

  /// Calculates Vimshopak Bala (20-fold strength) for a planet.
  ///
  /// [planet] - Planet to calculate strength for
  /// [chart] - Vedic chart
  ///
  /// Returns strength score (0-20).
  double getVimshopakBala(Planet planet, VedicChart chart) {
    _ensureInitialized();
    final planetInfo = chart.planets[planet];
    if (planetInfo == null) return 0.0;

    return _shadbalaService!.calculateVimshopakaBala(
      planet,
      chart,
    );
  }

  /// Calculates Ishtaphala (auspicious potential) for a planet.
  ///
  /// [planet] - Planet to calculate
  /// [chart] - Vedic chart
  /// [shadbala] - Pre-calculated Shadbala result for the planet
  ///
  /// Returns score (0.0-60.0).
  double getIshtaphala(
    Planet planet,
    VedicChart chart,
    ShadbalaResult shadbala,
  ) {
    _ensureInitialized();
    final planetInfo = chart.planets[planet];
    if (planetInfo == null) return 0.0;

    return _strengthAnalysisService!.getIshtaphala(
      planet: planet,
      chart: chart,
      shadbalaStrength: shadbala.totalBala,
    );
  }

  /// Calculates Bhava Bala (House Strength).
  ///
  /// [chart] - The Vedic birth chart
  ///
  /// Returns map of house number (1-12) to [BhavaBalaResult].

  /// Calculates Kashtaphala (inauspicious potential) for a planet.
  ///
  /// [planet] - Planet to calculate
  /// [chart] - Vedic chart
  /// [shadbala] - Pre-calculated Shadbala result
  ///
  /// Returns score (0.0-60.0).
  double getKashtaphala(
    Planet planet,
    VedicChart chart,
    ShadbalaResult shadbala,
  ) {
    _ensureInitialized();
    final planetInfo = chart.planets[planet];
    if (planetInfo == null) return 0.0;

    return _strengthAnalysisService!.getKashtaphala(
      planet: planet,
      chart: chart,
      shadbalaStrength: shadbala.totalBala,
    );
  }

  // ============================================================
  // GOCHARA VEDHA (TRANSIT OBSTRUCTION)
  // ============================================================

  /// Calculates Gochara Vedha for a specific transit planet.
  ///
  /// [transitPlanet] - The planet in transit
  /// [houseFromMoon] - House position from natal Moon (1-12)
  /// [moonNakshatra] - Current Moon's nakshatra (1-27)
  /// [otherTransits] - Map of other planets to their house from Moon
  ///
  /// Returns [VedhaResult] with obstruction details.
  VedhaResult calculateGocharaVedha({
    required Planet transitPlanet,
    required int houseFromMoon,
    required int moonNakshatra,
    required Map<Planet, int> otherTransits,
  }) {
    _ensureInitialized();
    return _gocharaVedhaService!.calculateVedha(
      transitPlanet: transitPlanet,
      houseFromMoon: houseFromMoon,
      moonNakshatra: moonNakshatra,
      otherTransits: otherTransits,
    );
  }

  /// Calculates Gochara Vedha for multiple planets needed for a chart.
  ///
  /// [transits] - Map of planets to their house positions from Moon
  /// [moonNakshatra] - Current Moon's nakshatra
  ///
  /// Returns list of [VedhaResult].
  List<VedhaResult> calculateMultipleGocharaVedha({
    required Map<Planet, int> transits,
    required int moonNakshatra,
  }) {
    _ensureInitialized();
    return _gocharaVedhaService!.calculateMultipleVedha(
      transits: transits,
      moonNakshatra: moonNakshatra,
    );
  }

  /// Gets the Samvatsara (60-year Jupiter cycle) name for a given year.
  ///
  /// The Samvatsara is based on the 60-year cycle of Jupiter's transit
  /// through the zodiac.
  ///
  /// [dateTime] - The date to calculate for
  /// [location] - Geographic location
  ///
  /// Returns the Samvatsara name (e.g., 'Prabhava', 'Vibhava', etc.)
  Future<String> getSamvatsara({
    required DateTime dateTime,
    required GeographicLocation location,
  }) async {
    _ensureInitialized();

    try {
      return await _masaService!.getSamvatsara(
        dateTime: dateTime,
        location: location,
      );
    } catch (e) {
      throw JyotishException(
        'Failed to get Samvatsara: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Gets a list of all lunar months for a given year.
  ///
  /// Useful for generating a lunar calendar or displaying month transitions.
  ///
  /// [year] - The Gregorian year
  /// [location] - Geographic location
  /// [type] - Lunar month system to use
  Future<List<MasaInfo>> getMasaListForYear({
    required int year,
    required GeographicLocation location,
    MasaType type = MasaType.amanta,
  }) async {
    _ensureInitialized();

    try {
      return await _masaService!.getMasaListForYear(
        year: year,
        location: location,
        type: type,
      );
    } catch (e) {
      throw JyotishException(
        'Failed to get Masa list: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // ============================================================
  // ABHIJIT NAKSHATRA
  // ============================================================

  /// Gets Nakshatra information including Abhijit (28th Nakshatra).
  ///
  /// Abhijit is the intercalary 28th nakshatra that spans from
  /// 6°40' to 10°53'20" in Capricorn (Uttara Ashadha).
  /// It's considered highly auspicious and ruled by Lord Brahma.
  ///
  /// [dateTime] - The date and time for calculation
  /// [location] - Geographic location
  ///
  /// Returns [NakshatraInfo] with:
  /// - Nakshatra name (0-27 for standard, 28 for Abhijit)
  /// - Ruling planet
  /// - Pada (1-4)
  /// - Whether it's Abhijit
  /// - Abhijit portion (0.0-1.0 if in Abhijit)
  ///
  /// Example:
  /// ```dart
  /// final nakshatra = await jyotish.getNakshatraWithAbhijit(
  ///   dateTime: DateTime.now(),
  ///   location: location,
  /// );
  /// print('Nakshatra: ${nakshatra.name}');
  /// if (nakshatra.isAbhijit) {
  ///   print('In auspicious Abhijit Nakshatra!');
  /// }
  /// ```
  Future<NakshatraInfo> getNakshatraWithAbhijit({
    required DateTime dateTime,
    required GeographicLocation location,
  }) async {
    _ensureInitialized();

    try {
      return await _masaService!.getNakshatraWithAbhijit(
        dateTime: dateTime,
        location: location,
      );
    } catch (e) {
      throw JyotishException(
        'Failed to get Nakshatra with Abhijit: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Checks if a given longitude is within Abhijit Nakshatra.
  ///
  /// Abhijit spans from 276°40' to 286°40' (6°40' to 10°40' Capricorn).
  ///
  /// [longitude] - The longitude in degrees (0-360)
  ///
  /// Returns true if the longitude falls within Abhijit's range.
  bool isInAbhijitNakshatra(double longitude) {
    var normalized = longitude % 360;
    if (normalized < 0) normalized += 360;
    return normalized >= NakshatraInfo.abhijitStart &&
        normalized < NakshatraInfo.abhijitEnd;
  }

  /// Gets the Abhijit Nakshatra boundaries.
  ///
  /// Returns a tuple with (startLongitude, endLongitude) in degrees.
  (double start, double end) getAbhijitBoundaries() {
    return (NakshatraInfo.abhijitStart, NakshatraInfo.abhijitEnd);
  }

  /// Calculates Nakshatra information for any planet at a given date/time.
  ///
  /// This is a general method that can calculate nakshatra for any planet,
  /// not just the Moon. Useful for analyzing planetary positions in nakshatras.
  ///
  /// [planet] - The planet to calculate nakshatra for
  /// [dateTime] - The date and time for calculation
  /// [location] - Geographic location
  ///
  /// Returns [NakshatraInfo] with:
  /// - Nakshatra name and number (1-27)
  /// - Ruling planet (deity)
  /// - Pada (quarter, 1-4)
  /// - Longitude within nakshatra
  ///
  /// Example:
  /// ```dart
  /// final sunNakshatra = await jyotish.getNakshatraForPlanet(
  ///   planet: Planet.sun,
  ///   dateTime: DateTime.now(),
  ///   location: location,
  /// );
  /// print('Sun in ${sunNakshatra.name}, Pada ${sunNakshatra.pada}');
  /// ```
  Future<NakshatraInfo> getNakshatraForPlanet({
    required Planet planet,
    required DateTime dateTime,
    required GeographicLocation location,
  }) async {
    _ensureInitialized();

    try {
      final position = await _ephemerisService!.calculatePlanetPosition(
        planet: planet,
        dateTime: dateTime,
        location: location,
        flags: CalculationFlags.defaultFlags(),
      );

      return _masaService!.calculateNakshatraFromLongitude(position.longitude);
    } catch (e) {
      throw JyotishException(
        'Failed to get Nakshatra for ${planet.displayName}: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Gets whether library has been initialized.
  bool get isInitialized => _isInitialized;

  /// Gets the PanchangaService for advanced Panchanga calculations.
  ///
  /// Use this to access advanced Panchanga methods like:
  /// - calculateAbhijitMuhurta()
  /// - calculateBrahmaMuhurta()
  /// - calculateNighttimeInauspicious()
  /// - getTithiJunction()
  /// - getMoonPhaseDetails()
  ///
  /// Example:
  /// ```dart
  /// final jyotish = Jyotish();
  /// await jyotish.initialize();
  ///
  /// final abhijit = await jyotish.panchangaService.calculateAbhijitMuhurta(
  ///   date: DateTime.now(),
  ///   location: location,
  /// );
  /// ```
  PanchangaService get panchangaService {
    _ensureInitialized();
    return _panchangaService!;
  }

  // ============================================================
  // SUDARSHAN CHAKRA ANALYSIS
  // ============================================================

  /// Calculates Sudarshan Chakra strength analysis.
  ///
  /// Sudarshan Chakra evaluates houses and planets from three perspectives:
  /// 1. Lagna (Ascendant) - The rising sign at birth
  /// 2. Chandra (Moon) - The Moon's sign position
  /// 3. Surya (Sun) - The Sun's sign position
  ///
  /// A house or planet is considered strong if it holds favorable positions
  /// across all three reference points.
  ///
  /// [chart] - A pre-calculated Vedic birth chart
  ///
  /// Returns a [SudarshanChakraResult] containing strength analysis
  /// for all 12 houses and all planets.
  ///
  /// Example:
  /// ```dart
  /// final chart = await jyotish.calculateVedicChart(
  ///   dateTime: DateTime(1990, 5, 15, 14, 30),
  ///   location: location,
  /// );
  ///
  /// final sudarshan = jyotish.calculateSudarshanChakra(chart);
  /// print('Overall Strength: ${sudarshan.overallStrength}%');
  /// print('Strong Houses: ${sudarshan.strongHouses}');
  ///
  /// for (final entry in sudarshan.planetStrengths.entries) {
  ///   print('${entry.key.displayName}: ${entry.value.category.name}');
  /// }
  /// ```
  SudarshanChakraResult calculateSudarshanChakra(VedicChart chart) {
    _ensureInitialized();
    return _sudarshanChakraService!.calculateSudarshanChakra(chart);
  }
  // ============================================================
  // PRASHNA (HORARY) ASTROLOGY
  // ============================================================

  /// Calculates Arudha Lagna for Prashna based on seed.
  Rashi calculatePrashnaArudha(int seed) {
    _ensureInitialized();
    return _prashnaService!.calculatePrashnaArudha(seed);
  }

  /// Calculates special Prashna Sphutas (Trisphuta, etc.).
  Future<PrashnaSphutas> calculatePrashnaSphutas(VedicChart chart) async {
    _ensureInitialized();
    return await _prashnaService!.calculateSphutas(chart);
  }

  /// Calculates Gulika Sphuta for Prashna.
  Future<double> calculateGulikaSphuta(VedicChart chart) async {
    _ensureInitialized();
    return await _prashnaService!.calculateGulikaSphuta(chart);
  }

  // ============================================================
  // HOUSE STRENGTH (VIMSOPAKA BALA)
  // ============================================================

  /// Calculates enhanced Bhava Bala with Vimsopaka integration.
  Future<Map<int, EnhancedBhavaBalaResult>> getEnhancedBhavaBala(VedicChart chart) async {
    _ensureInitialized();
    return await _houseStrengthService!.calculateEnhancedBhavaBala(chart);
  }

  /// Calculates Vimsopaka Bala (divisional chart strength).
  Map<Planet, VimsopakaBalaResult> getVimsopakaBala(VedicChart chart) {
    _ensureInitialized();
    return _houseStrengthService!.calculateVimsopakaBala(chart);
  }

  // ============================================================
  // NADI ASTROLOGY
  // ============================================================

  /// Calculates the Nadi chart for a given Vedic chart.
  NadiChart calculateNadiChart(VedicChart chart) {
    _ensureInitialized();
    return _nadiService!.calculateNadiChart(chart);
  }

  /// Gets Nadi information from a specific longitude.
  NadiInfo getNadiFromLongitude(double longitude) {
    _ensureInitialized();
    return _nadiService!.getNadiFromLongitude(longitude);
  }

  /// Gets the Nadi interpretation for a given Nadi number.
  String getNadiInterpretation(int nadiNumber) {
    _ensureInitialized();
    return _nadiService!.getNadiInterpretation(nadiNumber);
  }

  /// Identifies the Nadi seed based on Nakshatra and Pada.
  NadiSeedResult identifyNadiSeed(int nakshatraNumber, int pada) {
    _ensureInitialized();
    return _nadiService!.identifyNadiSeed(nakshatraNumber, pada);
  }

  // ============================================================
  // PROGENY (CHILD) ANALYSIS
  // ============================================================

  /// Analyzes progeny prospects based on the chart.
  ProgenyResult analyzeProgeny(VedicChart chart) {
    _ensureInitialized();
    return _progenyService!.analyzeProgeny(chart);
  }

  /// Analyzes the strength of the 5th house for children.
  FifthHouseStrength analyzeFifthHouse(VedicChart chart) {
    _ensureInitialized();
    return _progenyService!.analyzeFifthHouse(chart);
  }

  /// Analyzes Jupiter's condition for child prospects.
  JupiterCondition analyzeJupiterCondition(VedicChart chart) {
    _ensureInitialized();
    return _progenyService!.analyzeJupiterCondition(chart);
  }

  /// Detects favorable child yogas in the chart.
  List<ChildYoga> detectChildYogas(VedicChart chart) {
    _ensureInitialized();
    return _progenyService!.detectChildYogas(chart);
  }

  // ============================================================
  // MARRIAGE COMPATIBILITY (KUNDLI MILAN)
  // ============================================================

  /// Calculates compatibility between two charts.
  CompatibilityResult calculateCompatibility(VedicChart boyChart, VedicChart girlChart) {
    _ensureInitialized();
    return _compatibilityService!.calculateCompatibility(boyChart, girlChart);
  }

  /// Calculates Guna Milan (Ashtakoota) scores.
  GunaScores calculateGunaMilan(VedicChart boyChart, VedicChart girlChart) {
    _ensureInitialized();
    return _compatibilityService!.calculateGunaMilan(boyChart, girlChart);
  }

  /// Checks for Manglik Dosha in a chart.
  ManglikDoshaResult checkManglikDosha(VedicChart chart) {
    _ensureInitialized();
    return _compatibilityService!.checkManglikDosha(chart);
  }

  /// Checks for Nadi Dosha between two charts.
  NadiDoshaResult checkNadiDosha(VedicChart boyChart, VedicChart girlChart) {
    _ensureInitialized();
    return _compatibilityService!.checkNadiDosha(boyChart, girlChart);
  }

  /// Checks for Bhakoot Dosha between two charts.
  BhakootDoshaResult checkBhakootDosha(VedicChart boyChart, VedicChart girlChart) {
    _ensureInitialized();
    return _compatibilityService!.checkBhakootDosha(boyChart, girlChart);
  }
}
