import 'package:jyotish/src/models/planet.dart';
import 'package:jyotish/src/models/vedic_chart.dart';

/// Represents a single Bhava (house) in the Bhava Chalit chart.
///
/// In Bhava Chalit, each house boundary is the midpoint between two
/// adjacent cusps, rather than the full 30 sign boundary used in
/// the Rashi chart.
class BhavaInfo {
  const BhavaInfo({
    required this.houseNumber,
    required this.midCuspStart,
    required this.midCuspEnd,
    required this.cusp,
    required this.planets,
  });

  /// House number (112)
  final int houseNumber;

  /// Start of this bhava (midpoint between previous and current cusp)
  final double midCuspStart;

  /// End of this bhava (midpoint between current and next cusp)
  final double midCuspEnd;

  /// The actual house cusp degree (sidereal) from the chart
  final double cusp;

  /// Planets placed in this bhava (may differ from Rashi chart placement)
  final List<Planet> planets;

  @override
  String toString() =>
      'Bhava $houseNumber: ${midCuspStart.toStringAsFixed(2)}  '
      '${midCuspEnd.toStringAsFixed(2)} | Cusp: ${cusp.toStringAsFixed(2)} | '
      'Planets: ${planets.map((p) => p.displayName).join(', ')}';
}

/// Represents the complete Bhava Chalit (Cuspal) chart.
///
/// ## What is Bhava Chalit?
///
/// The Bhava Chalit chart redistributes planets to houses based on
/// **mid-cusp boundaries** rather than fixed 30 sign boundaries.
/// This distinction is especially significant in non-Whole-Sign house
/// systems (Placidus, Koch, Porphyry, etc.) where cusps are unequal.
///
/// **Mid-cusp boundary rule:**
/// The boundary between two adjacent houses is the midpoint between
/// their cusps. A planet is placed in Bhava N if its longitude lies
/// between the mid-cusp of house N and the mid-cusp of house N+1.
///
/// ## Use in interpretation
///
/// - For **transit** analysis: whether a transiting planet has "entered"
///   the next bhava matters for result timing.
/// - For **dasha** interpretation: a planet near a cusp may yield results
///   belonging to the next bhava rather than the Rashi house.
///
/// ## When Bhava Chalit == Rashi
///
/// For **Whole Sign (W)** house systems, all cusps are exactly 30 apart,
/// so mid-cusp boundaries align exactly with sign boundaries. In that case,
/// the Bhava Chalit placement equals the Rashi placement for most planets.
class BhavaChalit {
  const BhavaChalit({
    required this.bhavas,
    required this.chart,
  });

  /// All 12 bhavas with their mid-cusp boundaries and planet lists
  final List<BhavaInfo> bhavas;

  /// The source Rashi chart this was computed from
  final VedicChart chart;

  /// Returns the bhava number (112) for a given ecliptic longitude.
  ///
  /// Uses mid-cusp boundaries. Returns 1 if no match is found.
  int getBhavaForLongitude(double longitude) {
    for (final bhava in bhavas) {
      final start = bhava.midCuspStart;
      final end = bhava.midCuspEnd;

      if (start <= end) {
        // Normal case: boundary doesn't cross 0
        if (longitude >= start && longitude < end) {
          return bhava.houseNumber;
        }
      } else {
        // Boundary crosses 0 Aries
        if (longitude >= start || longitude < end) {
          return bhava.houseNumber;
        }
      }
    }
    return 1;
  }

  /// Returns the list of planets whose Bhava Chalit house differs from
  /// their Rashi chart house.
  ///
  /// These are the "shifted" planets  the key deliverable of this analysis.
  List<({Planet planet, int rashiHouse, int bhavaHouse})> get shiftedPlanets {
    final shifted = <({Planet planet, int rashiHouse, int bhavaHouse})>[];

    for (final bhava in bhavas) {
      for (final planet in bhava.planets) {
        final rashiHouse = chart.planets[planet]?.house;
        if (rashiHouse != null && rashiHouse != bhava.houseNumber) {
          shifted.add((
            planet: planet,
            rashiHouse: rashiHouse,
            bhavaHouse: bhava.houseNumber,
          ));
        }
      }
    }

    // Also check Rahu
    final rahuBhava = getBhavaForLongitude(chart.rahu.position.longitude);
    if (rahuBhava != chart.rahu.house) {
      shifted.add((
        planet: Planet.meanNode, // Rahu
        rashiHouse: chart.rahu.house,
        bhavaHouse: rahuBhava,
      ));
    }

    return shifted;
  }

  /// Returns the bhava number for a specific planet.
  int? getBhavaForPlanet(Planet planet) {
    for (final bhava in bhavas) {
      if (bhava.planets.contains(planet)) return bhava.houseNumber;
    }
    return null;
  }

  @override
  String toString() {
    final sb = StringBuffer('BhavaChalit:\n');
    for (final bhava in bhavas) {
      sb.writeln('  $bhava');
    }
    return sb.toString();
  }
}
