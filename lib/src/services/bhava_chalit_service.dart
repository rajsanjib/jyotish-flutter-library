import '../models/bhava_chalit.dart';
import '../models/planet.dart';
import '../models/vedic_chart.dart';

/// Service for computing the Bhava Chalit (Cuspal) chart.
///
/// This service uses the existing sidereal house cusps from a [VedicChart]
/// and computes mid-cusp boundaries to redistribute planets into their
/// correct Bhava positions.
///
/// See [BhavaChalit] for full documentation of what Bhava Chalit means
/// and when it differs from the Rashi chart.
class BhavaChalitService {
  /// Computes the Bhava Chalit chart from an existing [VedicChart].
  ///
  /// [chart] — The Rashi chart to derive the Bhava Chalit from.
  ///           Must include valid house cusps (any house system).
  ///
  /// Returns a [BhavaChalit] with 12 bhavas and their planet lists.
  BhavaChalit calculateBhavaChalit(VedicChart chart) {
    final cusps = chart.houses.cusps; // 12 sidereal cusp degrees

    // Compute mid-cusp boundaries.
    // The boundary ENTERING bhava N is the midpoint between cusp[N-1] and cusp[N]
    // (using angular midpoint to handle the 0°/360° wrap).
    final midCusps = <double>[];
    for (var i = 0; i < 12; i++) {
      final current = cusps[i];
      final next = cusps[(i + 1) % 12];
      midCusps.add(_angularMidpoint(current, next));
    }

    // Build the 12 BhavaInfo objects.
    // BhavaInfo for house N:
    //   - midCuspStart = midCusps[N-1]  (i.e. midpoint of cusp[N-1] and cusp[N])
    //   - midCuspEnd   = midCusps[N]    (i.e. midpoint of cusp[N] and cusp[N+1])
    //   - cusp = cusps[N-1]             (the actual cusp of this house)
    final allPlanetLongitudes = <Planet, double>{};
    for (final entry in chart.planets.entries) {
      allPlanetLongitudes[entry.key] = entry.value.position.longitude;
    }
    // Also add Rahu
    allPlanetLongitudes[Planet.meanNode] = chart.rahu.position.longitude;
    // Add Ketu
    allPlanetLongitudes[Planet.ketu] = chart.ketu.longitude;

    final bhavas = <BhavaInfo>[];
    for (var i = 0; i < 12; i++) {
      final houseNumber = i + 1;
      final midStart = midCusps[i]; // entering this bhava
      final midEnd =
          midCusps[(i + 1) % 12]; // exiting this bhava / entering next

      // Collect planets in this bhava
      final planetsInBhava = <Planet>[];
      for (final entry in allPlanetLongitudes.entries) {
        if (_isInBhava(entry.value, midStart, midEnd)) {
          planetsInBhava.add(entry.key);
        }
      }

      bhavas.add(BhavaInfo(
        houseNumber: houseNumber,
        midCuspStart: midStart,
        midCuspEnd: midEnd,
        cusp: cusps[i],
        planets: planetsInBhava,
      ));
    }

    return BhavaChalit(bhavas: bhavas, chart: chart);
  }

  /// Checks whether a longitude falls within [start, end) accounting for
  /// the 0°/360° wrap-around.
  bool _isInBhava(double longitude, double start, double end) {
    if (start < end) {
      return longitude >= start && longitude < end;
    } else {
      // Bhava spans the 0° point
      return longitude >= start || longitude < end;
    }
  }

  /// Computes the angular midpoint of two degrees on a circle [0, 360).
  ///
  /// Handles the wrap-around correctly: midpoint of 350° and 10° is 0°,
  /// not 180°.
  double _angularMidpoint(double a, double b) {
    var diff = (b - a + 360) % 360;
    return (a + diff / 2) % 360;
  }
}
