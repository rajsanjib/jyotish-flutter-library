import '../models/planet.dart';
import '../models/vedic_chart.dart';
import '../models/sarvatobhadra.dart';

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
      if (planet == Planet.uranus || planet == Planet.neptune || planet == Planet.pluto) {
        continue;
      }

      final transitNak = _getNakshatra(lon);
      final aspectedNaks = _getVedhaNakshatras(transitNak);

      final hitsMoon = aspectedNaks.contains(moonNak);
      final hitsSun = aspectedNaks.contains(sunNak);
      final hitsAsc = aspectedNaks.contains(ascNak);

      final isMalefic = [Planet.sun, Planet.mars, Planet.saturn, Planet.meanNode, Planet.trueNode, Planet.ketu].contains(planet);
      
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

  /// Simplified 27-star Sarvatobhadra Vedha (aspect) mapping.
  /// Returns frontal, left, and right aspected nakshatras.
  List<int> _getVedhaNakshatras(int transitingNakshatra) {
    // Frontal Vedha is exactly opposite in 28-star, roughly 14 away in 27-star.
    final front = ((transitingNakshatra + 13) % 27) + 1;
    
    // Left and Right depend on the varga/column in the grid.
    // For a simple implementation, we add +/- 7.
    final left = ((transitingNakshatra + 6) % 27) + 1;
    final right = ((transitingNakshatra + 19) % 27) + 1;

    return [front, left, right];
  }
}
