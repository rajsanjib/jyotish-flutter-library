import 'package:jyotish/src/models/planet.dart';
import 'package:jyotish/src/models/vedic_chart.dart';
import 'package:jyotish/src/models/graha_yuddha.dart';

/// Service for scanning and evaluating Graha Yuddha (Planetary War).
class GrahaYuddhaService {
  const GrahaYuddhaService();

  /// Scans the chart for any tight conjunctions (within 1 degree) between true planets
  /// (Mars, Mercury, Jupiter, Venus, Saturn) and returns the details of the planetary war if found.
  /// Returns null if no planetary war is occurring.
  WarDetails? checkGrahaYuddha(VedicChart chart) {
    final truePlanets = [
      Planet.mars,
      Planet.mercury,
      Planet.jupiter,
      Planet.venus,
      Planet.saturn,
    ];

    final sunInfo = chart.getPlanet(Planet.sun);
    if (sunInfo == null) return null;

    // Scan all pairs of true planets
    for (var i = 0; i < truePlanets.length; i++) {
      final p1 = truePlanets[i];
      final p1Info = chart.getPlanet(p1);
      if (p1Info == null) continue;

      for (var j = i + 1; j < truePlanets.length; j++) {
        final p2 = truePlanets[j];
        final p2Info = chart.getPlanet(p2);
        if (p2Info == null) continue;

        final lon1 = p1Info.longitude;
        final lon2 = p2Info.longitude;

        var diff = (lon1 - lon2).abs();
        if (diff > 180) {
          diff = 360 - diff;
        }

        if (diff <= 1.0) {
          // Planetary war is occurring!
          // 1. Calculate apparent magnitudes based on elongation from Sun
          final elon1 = _calculateElongation(lon1, sunInfo.longitude);
          final elon2 = _calculateElongation(lon2, sunInfo.longitude);

          final mag1 = _calculateMagnitude(p1, elon1);
          final mag2 = _calculateMagnitude(p2, elon2);

          // 2. Latitudes (declination proxy)
          final lat1 = p1Info.position.latitude;
          final lat2 = p2Info.position.latitude;

          // 3. Determine winner
          Planet winner;
          if (p1 == Planet.venus) {
            winner = p1;
          } else if (p2 == Planet.venus) {
            winner = p2;
          } else {
            // Brighter planet wins (lower magnitude is brighter)
            if ((mag1 - mag2).abs() > 0.05) {
              winner = mag1 < mag2 ? p1 : p2;
            } else {
              // If brightness is very similar, the one with greater northern latitude wins
              if ((lat1 - lat2).abs() > 0.01) {
                winner = lat1 > lat2 ? p1 : p2;
              } else {
                // Otherwise, the planet with lower longitude wins
                winner = lon1 < lon2 ? p1 : p2;
              }
            }
          }

          return WarDetails(
            planet1: p1,
            planet2: p2,
            planet1Magnitude: mag1,
            planet2Magnitude: mag2,
            planet1Declination: lat1,
            planet2Declination: lat2,
            longitudeDifference: diff,
            winnerId: winner,
          );
        }
      }
    }

    return null;
  }

  double _calculateElongation(double lon, double sunLon) {
    var elon = (lon - sunLon).abs();
    if (elon > 180) {
      elon = 360 - elon;
    }
    return elon;
  }

  double _calculateMagnitude(Planet planet, double elongation) {
    const baseMagnitudes = {
      Planet.mercury: -0.4,
      Planet.venus: -4.4,
      Planet.mars: -2.0,
      Planet.jupiter: -2.9,
      Planet.saturn: -0.3,
    };

    final baseMag = baseMagnitudes[planet] ?? 0.0;
    final phaseFactor = (elongation / 180.0).clamp(0.0, 1.0);
    return baseMag + (2.5 * (1 - phaseFactor));
  }
}
