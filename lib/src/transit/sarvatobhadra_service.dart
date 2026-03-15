import 'package:jyotish/src/models/planet.dart';
import 'package:jyotish/src/models/vedic_chart.dart';
import 'package:jyotish/src/transit/sarvatobhadra.dart';

/// Service to analyze transit effects using the Sarvatobhadra Chakra.
class SarvatobhadraService {
  /// Analyzes transits against a natal chart using Sarvatobhadra principles.
  SarvatobhadraAnalysis analyzeTransits({
    required VedicChart natalChart,
    required Map<Planet, double> transitPositions,
  }) {
    // Determine key natal nakshatras
    final moonLon = natalChart.planets[Planet.moon]?.longitude ?? 0.0;
    final sunLon = natalChart.planets[Planet.sun]?.longitude ?? 0.0;
    final ascLon = natalChart.houses.ascendant;

    final moonNak = _getNakshatra(moonLon);
    final sunNak = _getNakshatra(sunLon);
    final ascNak = _getNakshatra(ascLon);

    final transitVedhas = <Planet, SarvatobhadraVedha>{};
    final favorable = <Planet>[];
    final unfavorable = <Planet>[];

    for (final entry in transitPositions.entries) {
      final planet = entry.key;
      final lon = entry.value;
      if (planet == Planet.uranus ||
          planet == Planet.neptune ||
          planet == Planet.pluto) {
        continue;
      }

      final transitNak = _getNakshatra(lon);
      final aspectedNaks = _getVedhaNakshatras(transitNak);

      final hitsMoon = aspectedNaks.contains(moonNak);
      final hitsSun = aspectedNaks.contains(sunNak);
      final hitsAsc = aspectedNaks.contains(ascNak);

      final isMalefic = [
        Planet.sun,
        Planet.mars,
        Planet.saturn,
        Planet.meanNode,
        Planet.trueNode,
        Planet.ketu
      ].contains(planet);

      VedhaSeverity severity = VedhaSeverity.mild;
      if (hitsMoon || hitsSun || hitsAsc) {
        if (isMalefic) {
          severity = VedhaSeverity.severe;
          unfavorable.add(planet);
        } else {
          severity = VedhaSeverity.benefic;
          favorable.add(planet);
        }
      } else if (isMalefic) {
        severity = VedhaSeverity.moderate; // moderate unstructured obstruction
      } else {
        severity = VedhaSeverity.mild;
      }

      transitVedhas[planet] = SarvatobhadraVedha(
        transitPlanet: planet,
        transitNakshatra: transitNak,
        aspectedNakshatras: aspectedNaks,
        aspectsNatalMoon: hitsMoon,
        aspectsNatalAscendant: hitsAsc,
        aspectsNatalSun: hitsSun,
        severity: severity,
      );
    }

    return SarvatobhadraAnalysis(
      natalChart: natalChart,
      transitVedhas: transitVedhas,
      favorableTransits: favorable,
      unfavorableTransits: unfavorable,
    );
  }

  int _getNakshatra(double longitude) {
    return (longitude / (360.0 / 27.0)).floor() + 1;
  }

  /// Classical 27-star Sarvatobhadra Vedha (aspect) mapping.
  /// Returns frontal, left, and right aspected nakshatras.
  List<int> _getVedhaNakshatras(int nak) {
    // Lookup table for 27 nakshatra vedhas (Samudaya, Rashi, Tara Vedha approximation)
    const vedhaTable = {
      1: [14, 27, 2], // Ashwini
      2: [13, 26, 3], // Bharani
      3: [12, 25, 4], // Krittika
      4: [11, 24, 5],
      5: [10, 23, 6],
      6: [9, 22, 7],
      7: [8, 21, 8],
      8: [7, 20, 9],
      9: [6, 19, 10],
      10: [5, 18, 11],
      11: [4, 17, 12],
      12: [3, 16, 13],
      13: [2, 15, 14],
      14: [1, 27, 15],
      15: [27, 13, 16],
      16: [26, 12, 17],
      17: [25, 11, 18],
      18: [24, 10, 19],
      19: [23, 9, 20],
      20: [22, 8, 21],
      21: [21, 7, 22],
      22: [20, 6, 23],
      23: [19, 5, 24],
      24: [18, 4, 25],
      25: [17, 3, 26],
      26: [16, 2, 27],
      27: [15, 1, 1],
    };

    return vedhaTable[nak] ?? [];
  }
}
