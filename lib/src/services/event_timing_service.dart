import '../models/planet.dart';
import '../models/rashi.dart';
import '../models/vedic_chart.dart';
import '../models/dasha.dart';
import '../models/gochara.dart';
import '../models/event_timing.dart';

import 'dasha_service.dart';
import 'gochara_vedha_service.dart';
import 'ephemeris_service.dart';

/// Service to analyze and combine Dasha periods and Planetary Transits
/// to find favorable timing windows for specific events.
class EventTimingService {
  EventTimingService({
    required DashaService dashaService,
    required GocharaVedhaService gocharaVedhaService,
    required EphemerisService ephemerisService,
  })  : _dashaService = dashaService,
        _gocharaVedhaService = gocharaVedhaService,
        _ephemerisService = ephemerisService;

  final DashaService _dashaService;
  final GocharaVedhaService _gocharaVedhaService;
  final EphemerisService _ephemerisService;

  Future<List<EventTimingWindow>> findEventTimingWindows(
      EventTimingRequest request) async {
    final windows = <EventTimingWindow>[];
    
    // Default to Vimshottari Dasha for timing 
    final dashaResult = _dashaService.getVimshottariDasha(request.natalChart);
    
    final moonSign = request.natalChart.planets[Planet.moon]!.sign;
    final rashiWidth = 360.0 / 12;
    final moonNakshatra = (request.natalChart.planets[Planet.moon]!.longitude / (360.0 / 27)).floor() % 27;

    var current = request.startDate;
    while (current.isBefore(request.endDate)) {
      final end = current.add(request.granularity);
      
      // 1. Identify active dasha period
      final mahadasha = dashaResult.getMahadashaAt(current);
      final antardasha = dashaResult.getAndardashaAt(current);
      
      final dashaLord = antardasha?.lord ?? mahadasha?.lord ?? Planet.jupiter;
      final dashaContext = antardasha != null
          ? '${mahadasha?.lordDisplayName} MD / ${antardasha.lordDisplayName} AD'
          : '${mahadasha?.lordDisplayName} MD';

      // 2. Fetch all transit positions for the current step
      final transits = <Planet, int>{};
      final transitPositions = <Planet, PlanetPosition>{};
      
      for (final planet in Planet.values) {
        if (planet == Planet.uranus || planet == Planet.neptune || planet == Planet.pluto) continue;
        
        final pos = await _ephemerisService.calculatePlanetPosition(
          planet: planet,
          dateTime: current,
          location: request.location,
        );
        transitPositions[planet] = pos;
        
        // Calculate house from natal Moon
        int houseFromMoon = ((pos.sign.index - moonSign.index) % 12) + 1;
        if (houseFromMoon <= 0) houseFromMoon += 12;
        transits[planet] = houseFromMoon;
      }

      // 3. Analyze Gochara Vedha for the Dasha Lord
      final gocharaHouse = transits[dashaLord] ?? 1;
      final vedhaResult = _gocharaVedhaService.calculateVedha(
        transitPlanet: dashaLord,
        houseFromMoon: gocharaHouse,
        moonNakshatra: moonNakshatra,
        otherTransits: transits,
      );

      // 4. Rate Quality based on Gochara favorability and Vedha
      final reasons = <String>[];
      double score = 0.5;
      
      if (vedhaResult.isFavorable) {
        score += 0.3;
        reasons.add('$dashaLord is transiting favorable house $gocharaHouse from Moon.');
        if (vedhaResult.hasVedha) {
          score -= 0.2;
          reasons.add('But favorable effects are obstructed (Vedha) by ${vedhaResult.obstructingPlanet}.');
        } else {
          score += 0.1;
          reasons.add('No Vedha obstruction.');
        }
      } else {
        score -= 0.2;
        reasons.add('$dashaLord is transiting unfavorable house $gocharaHouse from Moon.');
        if (vedhaResult.hasVedha) {
          score += 0.1;
          reasons.add('Harmful effects are mitigated (Vama Vedha) by ${vedhaResult.obstructingPlanet}.');
        }
      }

      // Optional step: Check relevant event houses
      final relevantHouses = _getRelevantHousesForEvent(request.eventType);
      for (final house in relevantHouses) {
        if (gocharaHouse == house) {
          score += 0.15;
          reasons.add('Dasha lord transiting key event house ($house).');
        }
      }
      
      score = score.clamp(0.0, 1.0);
      
      TimingQuality quality;
      if (score >= 0.8) {
        quality = TimingQuality.veryFavorable;
      } else if (score >= 0.6) {
        quality = TimingQuality.favorable;
      } else if (score >= 0.4) {
        quality = TimingQuality.neutral;
      } else if (score >= 0.2) {
        quality = TimingQuality.unfavorable;
      } else {
        quality = TimingQuality.challenging;
      }

      windows.add(EventTimingWindow(
        start: current,
        end: end,
        quality: quality,
        dashaLord: dashaLord,
        dashaContext: dashaContext,
        reasons: reasons,
        score: score,
      ));

      current = end;
    }
    
    return windows;
  }

  List<int> _getRelevantHousesForEvent(EventCategory category) {
    return switch (category) {
      EventCategory.marriage => const [7, 2, 11],
      EventCategory.career => const [10, 2, 6, 11],
      EventCategory.health => const [1, 6, 8],
      EventCategory.travel => const [3, 9, 12],
      EventCategory.finance => const [2, 11, 5, 9],
      EventCategory.spiritual => const [9, 12, 5, 8],
      EventCategory.education => const [4, 5, 9],
    };
  }
}
