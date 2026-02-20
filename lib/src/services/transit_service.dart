import '../models/aspect.dart';
import '../models/calculation_flags.dart';
import '../models/geographic_location.dart';
import '../models/planet.dart';
import '../models/planet_position.dart';
import '../models/transit.dart';
import '../models/vedic_chart.dart';
import 'ephemeris_service.dart';

/// Service for calculating planetary transits.
///
/// Transits show the current positions of planets relative to a natal chart,
/// identifying significant aspects between transit and natal positions.
class TransitService {
  TransitService(this._ephemerisService);
  final EphemerisService _ephemerisService;

  /// Calculates transit positions for all planets at a given time.
  ///
  /// [natalChart] - The birth chart to compare transits against
  /// [transitDateTime] - Date/time for transit positions
  /// [location] - Geographic location for calculations
  ///
  /// Returns a map of planets to their transit info.
  Future<Map<Planet, TransitInfo>> calculateTransits({
    required VedicChart natalChart,
    required DateTime transitDateTime,
    required GeographicLocation location,
  }) async {
    final flags = CalculationFlags.defaultFlags();
    final transits = <Planet, TransitInfo>{};

    // Calculate transit positions for traditional planets + nodes
    final planetsToCalculate = [
      ...Planet.traditionalPlanets,
      Planet.meanNode,
    ];

    for (final planet in planetsToCalculate) {
      final transitPosition = await _ephemerisService.calculatePlanetPosition(
        planet: planet,
        dateTime: transitDateTime,
        location: location,
        flags: flags,
      );

      // Get natal position for this planet
      final natalInfo = natalChart.planets[planet];
      final natalPosition = natalInfo?.position;

      // Determine which house the transit planet is in (natal chart houses)
      final transitHouse =
          natalChart.houses.getHouseForLongitude(transitPosition.longitude);
      final transitSignIndex = (transitPosition.longitude / 30).floor() % 12;

      // Calculate aspects to natal planets
      final aspectsToNatal = _calculateTransitAspects(
        transitPosition,
        natalChart,
      );

      transits[planet] = TransitInfo(
        planet: planet,
        transitPosition: transitPosition,
        natalPosition: natalPosition,
        transitHouse: transitHouse,
        transitSignIndex: transitSignIndex,
        aspectsToNatal: aspectsToNatal,
      );
    }

    return transits;
  }

  /// Calculates aspects from a single transit planet to all natal positions.
  List<AspectInfo> _calculateTransitAspects(
    PlanetPosition transitPos,
    VedicChart natalChart,
  ) {
    final aspects = <AspectInfo>[];
    const config = AspectConfig.vedic;

    for (final entry in natalChart.planets.entries) {
      final natalPlanet = entry.key;
      final natalInfo = entry.value;
      final natalPos = natalInfo.position;

      // Calculate angular difference
      var angularDiff = (natalPos.longitude - transitPos.longitude) % 360;
      if (angularDiff < 0) angularDiff += 360;

      // Check conjunction
      if (angularDiff.abs() <= 10 || (360 - angularDiff).abs() <= 10) {
        final orb = angularDiff <= 180 ? angularDiff : 360 - angularDiff;
        aspects.add(AspectInfo(
          aspectingPlanet: transitPos.planet,
          aspectedPlanet: natalPlanet,
          type: AspectType.conjunction,
          exactOrb: orb,
          isApplying: transitPos.longitudeSpeed > 0,
          strength: 1.0 - (orb / 10).clamp(0.0, 1.0),
          aspectingLongitude: transitPos.longitude,
          aspectedLongitude: natalPos.longitude,
        ));
      }

      // Check opposition (180°)
      final oppDiff = (angularDiff - 180).abs();
      if (oppDiff <= 10) {
        aspects.add(AspectInfo(
          aspectingPlanet: transitPos.planet,
          aspectedPlanet: natalPlanet,
          type: AspectType.opposition,
          exactOrb: oppDiff,
          isApplying: transitPos.longitudeSpeed > 0,
          strength: 1.0 - (oppDiff / 10).clamp(0.0, 1.0),
          aspectingLongitude: transitPos.longitude,
          aspectedLongitude: natalPos.longitude,
        ));
      }

      // Check special aspects for Mars, Jupiter, Saturn transits
      if (config.includeSpecialAspects) {
        aspects.addAll(_checkTransitSpecialAspects(
          transitPos,
          natalPlanet,
          natalPos,
          angularDiff,
        ));
      }
    }

    return aspects;
  }

  /// Check special aspects for transit planets.
  List<AspectInfo> _checkTransitSpecialAspects(
    PlanetPosition transitPos,
    Planet natalPlanet,
    PlanetPosition natalPos,
    double angularDiff,
  ) {
    final aspects = <AspectInfo>[];
    const orb = 10.0;

    // Mars special aspects
    if (transitPos.planet == Planet.mars) {
      if ((angularDiff - 90).abs() <= orb) {
        aspects.add(_createTransitAspect(
          transitPos,
          natalPlanet,
          natalPos,
          AspectType.marsSpecial4th,
          angularDiff - 90,
        ));
      }
      if ((angularDiff - 210).abs() <= orb) {
        aspects.add(_createTransitAspect(
          transitPos,
          natalPlanet,
          natalPos,
          AspectType.marsSpecial8th,
          angularDiff - 210,
        ));
      }
    }

    // Jupiter special aspects
    if (transitPos.planet == Planet.jupiter) {
      if ((angularDiff - 120).abs() <= orb) {
        aspects.add(_createTransitAspect(
          transitPos,
          natalPlanet,
          natalPos,
          AspectType.jupiterSpecial5th,
          angularDiff - 120,
        ));
      }
      if ((angularDiff - 240).abs() <= orb) {
        aspects.add(_createTransitAspect(
          transitPos,
          natalPlanet,
          natalPos,
          AspectType.jupiterSpecial9th,
          angularDiff - 240,
        ));
      }
    }

    // Saturn special aspects
    if (transitPos.planet == Planet.saturn) {
      if ((angularDiff - 60).abs() <= orb) {
        aspects.add(_createTransitAspect(
          transitPos,
          natalPlanet,
          natalPos,
          AspectType.saturnSpecial3rd,
          angularDiff - 60,
        ));
      }
      if ((angularDiff - 270).abs() <= orb) {
        aspects.add(_createTransitAspect(
          transitPos,
          natalPlanet,
          natalPos,
          AspectType.saturnSpecial10th,
          angularDiff - 270,
        ));
      }
    }

    return aspects;
  }

  AspectInfo _createTransitAspect(
    PlanetPosition transitPos,
    Planet natalPlanet,
    PlanetPosition natalPos,
    AspectType type,
    double orb,
  ) {
    return AspectInfo(
      aspectingPlanet: transitPos.planet,
      aspectedPlanet: natalPlanet,
      type: type,
      exactOrb: orb,
      isApplying: transitPos.longitudeSpeed > 0,
      strength: 1.0 - (orb.abs() / type.defaultOrb).clamp(0.0, 1.0),
      aspectingLongitude: transitPos.longitude,
      aspectedLongitude: natalPos.longitude,
    );
  }

  /// Finds significant transit events within a date range.
  ///
  /// [natalChart] - Birth chart
  /// [config] - Transit configuration with date range
  /// [location] - Geographic location
  ///
  /// Returns list of transit events sorted by date.
  Future<List<TransitEvent>> findTransitEvents({
    required VedicChart natalChart,
    required TransitConfig config,
    required GeographicLocation location,
  }) async {
    final events = <TransitEvent>[];
    final planets = config.planets ??
        [
          ...Planet.traditionalPlanets,
          Planet.meanNode,
        ];

    var currentDate = config.startDate;

    while (currentDate.isBefore(config.endDate)) {
      final transits = await calculateTransits(
        natalChart: natalChart,
        transitDateTime: currentDate,
        location: location,
      );

      // Check for new exact aspects
      for (final planet in planets) {
        final transit = transits[planet];
        if (transit == null) continue;

        for (final aspect in transit.aspectsToNatal) {
          // Check if aspect is becoming exact (transitioning from applying)
          if (aspect.isExact) {
            final event = TransitEvent(
              transitPlanet: planet,
              natalPlanet: aspect.aspectedPlanet,
              aspectType: aspect.type,
              exactDate: currentDate,
              startDate:
                  currentDate.subtract(Duration(days: config.intervalDays * 3)),
              endDate: currentDate.add(Duration(days: config.intervalDays * 3)),
              isRetrograde: transit.isRetrograde,
              description:
                  _generateTransitDescription(aspect, transit.isRetrograde),
              significance: _calculateSignificance(aspect),
            );
            events.add(event);
          }
        }
      }

      currentDate = currentDate.add(Duration(days: config.intervalDays));
    }

    // Sort by date and remove duplicates
    events.sort((a, b) => a.exactDate.compareTo(b.exactDate));
    return _deduplicateEvents(events);
  }

  List<TransitEvent> _deduplicateEvents(List<TransitEvent> events) {
    final unique = <TransitEvent>[];
    for (final event in events) {
      final isDuplicate = unique.any((e) =>
          e.transitPlanet == event.transitPlanet &&
          e.natalPlanet == event.natalPlanet &&
          e.aspectType == event.aspectType &&
          e.exactDate.difference(event.exactDate).inDays.abs() < 7);
      if (!isDuplicate) {
        unique.add(event);
      }
    }
    return unique;
  }

  String _generateTransitDescription(AspectInfo aspect, bool isRetrograde) {
    final retro = isRetrograde ? ' (retrograde)' : '';
    return '${aspect.aspectingPlanet.displayName}$retro ${aspect.type.english} natal ${aspect.aspectedPlanet.displayName}';
  }

  int _calculateSignificance(AspectInfo aspect) {
    var significance = 3;

    // Increase for tight aspects
    if (aspect.isExact) significance++;
    if (aspect.isTight) significance++;

    // Increase for major planets
    if (aspect.aspectingPlanet == Planet.saturn ||
        aspect.aspectingPlanet == Planet.jupiter) {
      significance++;
    }

    // Increase for conjunctions and oppositions
    if (aspect.type == AspectType.conjunction ||
        aspect.type == AspectType.opposition) {
      significance++;
    }

    return significance.clamp(1, 5);
  }
}
