import '../models/jaimini.dart';
import '../models/planet.dart';
import '../models/rashi.dart';
import '../models/vedic_chart.dart';

/// Service for Jaimini astrology calculations (Karakamsa, Rashi Drishti).
class JaiminiService {
  /// Gets the Atmakaraka (planet with highest degree in its sign).
  ///
  /// Per Jaimini, Atmakaraka is the planet with the highest degree
  /// in its sign (excluding the Sun). Traditionally includes 7 planets + Rahu.
  ///
  /// Special rule for Rahu: Since Rahu moves in reverse direction,
  /// its degrees are measured as 30° minus its longitude within the sign.
  /// This gives Rahu a chance to be Atmakaraka.
  Planet getAtmakaraka(VedicChart chart) {
    Planet? atmakaraka;
    double highestDegree = -1;

    // Consider 8 planets per Jaimini tradition (Sun to Saturn + Rahu)
    // Ketu is not typically considered as it co-locates with Rahu
    const planets = [
      Planet.sun,
      Planet.moon,
      Planet.mars,
      Planet.mercury,
      Planet.jupiter,
      Planet.venus,
      Planet.saturn,
      Planet.meanNode, // Rahu
    ];

    for (final planet in planets) {
      final info = chart.getPlanet(planet);
      if (info == null) continue;

      // Degree within sign (0-30)
      var degreeInSign = info.longitude % 30;

      // Special handling for Rahu (and Ketu): 
      // Since they move backwards, their effective degree is reversed
      // This gives them a chance to be Atmakaraka
      if (planet == Planet.meanNode || planet == Planet.ketu) {
        degreeInSign = 30.0 - degreeInSign;
      }

      // Skip Sun per traditional Jaimini rules
      if (planet == Planet.sun) continue;

      if (degreeInSign > highestDegree) {
        highestDegree = degreeInSign;
        atmakaraka = planet;
      }
    }

    return atmakaraka ?? Planet.moon; // Fallback to Moon
  }

  /// Gets Karakamsa information.
  /// Requires both Rashi (D1) and Navamsa (D9) charts.
  KarakamsaInfo getKarakamsa({
    required VedicChart rashiChart,
    required VedicChart navamsaChart,
  }) {
    final ak = getAtmakaraka(rashiChart);

    // Find AK's position in Navamsa
    final akInNavamsa = navamsaChart.getPlanet(ak);
    if (akInNavamsa == null) {
      throw Exception('Atmakaraka not found in Navamsa chart');
    }

    final karakamsaSign = Rashi.fromLongitude(akInNavamsa.longitude);
    final karakamsaHouse = akInNavamsa.house;

    return KarakamsaInfo(
      atmakaraka: ak,
      karakamsaSign: karakamsaSign,
      karakamsaHouse: karakamsaHouse,
    );
  }

  /// Calculates all Rashi Drishti (sign aspects) for a chart.
  ///
  /// Jaimini Rashi Drishti rules:
  /// - Movable signs (1, 4, 7, 10) aspect Fixed signs except the adjacent one.
  /// - Fixed signs (2, 5, 8, 11) aspect Movable signs except the adjacent one.
  /// - Dual signs (3, 6, 9, 12) aspect each other.
  List<RashiDrishtiInfo> calculateRashiDrishti(VedicChart chart) {
    final drishtiList = <RashiDrishtiInfo>[];

    for (final aspectingRashi in Rashi.values) {
      final aspectedSigns = _getAspectedSigns(aspectingRashi);

      for (final aspectedRashi in aspectedSigns) {
        final planetsInAspecting = _getPlanetsInSign(chart, aspectingRashi);
        final planetsInAspected = _getPlanetsInSign(chart, aspectedRashi);

        drishtiList.add(RashiDrishtiInfo(
          aspectingSign: aspectingRashi,
          aspectedSign: aspectedRashi,
          planetsInAspectingSign: planetsInAspecting,
          planetsInAspectedSign: planetsInAspected,
        ));
      }
    }

    return drishtiList;
  }

  /// Gets Rashi Drishti specifically for houses containing planets.
  List<RashiDrishtiInfo> calculateActiveRashiDrishti(VedicChart chart) {
    final drishtiList = <RashiDrishtiInfo>[];

    for (final aspectingRashi in Rashi.values) {
      final planetsInAspecting = _getPlanetsInSign(chart, aspectingRashi);
      if (planetsInAspecting.isEmpty) continue; // Only consider occupied signs

      final aspectedSigns = _getAspectedSigns(aspectingRashi);

      for (final aspectedRashi in aspectedSigns) {
        final planetsInAspected = _getPlanetsInSign(chart, aspectedRashi);

        drishtiList.add(RashiDrishtiInfo(
          aspectingSign: aspectingRashi,
          aspectedSign: aspectedRashi,
          planetsInAspectingSign: planetsInAspecting,
          planetsInAspectedSign: planetsInAspected,
        ));
      }
    }

    return drishtiList;
  }

  List<Rashi> _getAspectedSigns(Rashi rashi) {
    final quality = _getSignQuality(rashi);
    final result = <Rashi>[];

    switch (quality) {
      case _SignQuality.movable:
        // Aspects all Fixed signs except the one adjacent (next sign)
        for (final r in Rashi.values) {
          if (_getSignQuality(r) == _SignQuality.fixed) {
            // Check if adjacent (difference of 1 sign)
            final diff = ((r.index - rashi.index).abs());
            if (diff != 1 && diff != 11) {
              result.add(r);
            }
          }
        }
        break;
      case _SignQuality.fixed:
        // Aspects all Movable signs except the one adjacent (previous sign)
        for (final r in Rashi.values) {
          if (_getSignQuality(r) == _SignQuality.movable) {
            final diff = ((r.index - rashi.index).abs());
            if (diff != 1 && diff != 11) {
              result.add(r);
            }
          }
        }
        break;
      case _SignQuality.dual:
        // Aspects all other Dual signs
        for (final r in Rashi.values) {
          if (_getSignQuality(r) == _SignQuality.dual && r != rashi) {
            result.add(r);
          }
        }
        break;
    }

    return result;
  }

  _SignQuality _getSignQuality(Rashi rashi) {
    // Movable: 0=Aries, 3=Cancer, 6=Libra, 9=Capricorn
    // Fixed: 1=Taurus, 4=Leo, 7=Scorpio, 10=Aquarius
    // Dual: 2=Gemini, 5=Virgo, 8=Sagittarius, 11=Pisces
    final idx = rashi.index;
    if (idx % 3 == 0) return _SignQuality.movable;
    if (idx % 3 == 1) return _SignQuality.fixed;
    return _SignQuality.dual;
  }

  List<Planet> _getPlanetsInSign(VedicChart chart, Rashi sign) {
    final result = <Planet>[];
    for (final entry in chart.planets.entries) {
      final planetSign = Rashi.fromLongitude(entry.value.longitude);
      if (planetSign == sign) {
        result.add(entry.key);
      }
    }
    return result;
  }
}

enum _SignQuality { movable, fixed, dual }
