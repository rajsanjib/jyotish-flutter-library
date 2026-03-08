import 'package:jyotish/src/strength/graha_avastha.dart';
import 'package:jyotish/src/models/planet.dart';
import 'package:jyotish/src/models/vedic_chart.dart';

/// Service for calculating planetary states (Graha Avasthas).
///
/// Implements Baladi Avastha (age-based) and Jagratadi Avastha (consciousness).
class GrahaAvasthaService {
  /// Calculates all avasthas for a given chart.
  Map<Planet, GrahaAvastha> calculateAllAvasthas(VedicChart chart) {
    final results = <Planet, GrahaAvastha>{};
    for (final entry in chart.planets.entries) {
      if (!Planet.lunarNodes.contains(entry.key)) {
        results[entry.key] = calculateAvastha(entry.value);
      }
    }
    return results;
  }

  /// Calculates the Avastha for a single Vedic planet.
  GrahaAvastha calculateAvastha(VedicPlanetInfo planetInfo) {
    final baladi = _calculateBaladi(planetInfo.longitude);
    final jagratadi = _calculateJagratadi(planetInfo.dignity);
    final deeptadi = _calculateDeeptadi(planetInfo);

    double effectStrength;
    switch (jagratadi) {
      case JagratadiAvastha.jagrata:
        effectStrength = 1.0;
        break;
      case JagratadiAvastha.svapna:
        effectStrength = 0.5;
        break;
      case JagratadiAvastha.sushupti:
        effectStrength = 0.25;
        break;
    }

    final description =
        '${baladi.sanskrit}, ${jagratadi.sanskrit}, ${deeptadi.sanskrit}';

    return GrahaAvastha(
      baladi: baladi,
      jagratadi: jagratadi,
      deeptadi: deeptadi,
      effectStrength: effectStrength,
      description: description,
    );
  }

  /// Calculates Baladi (Age) Avastha based on sign parity and degree.
  BaladiAvastha _calculateBaladi(double longitude) {
    final signIndex = (longitude / 30).floor();
    final degreeInSign = longitude % 30;

    // Aries is 0 (1st sign -> odd). So even index = odd sign.
    final isOddSign = (signIndex % 2 == 0);

    if (isOddSign) {
      if (degreeInSign < 6) return BaladiAvastha.bala;
      if (degreeInSign < 12) return BaladiAvastha.kumara;
      if (degreeInSign < 18) return BaladiAvastha.yuva;
      if (degreeInSign < 24) return BaladiAvastha.vriddha;
      return BaladiAvastha.mrita;
    } else {
      if (degreeInSign < 6) return BaladiAvastha.mrita;
      if (degreeInSign < 12) return BaladiAvastha.vriddha;
      if (degreeInSign < 18) return BaladiAvastha.yuva;
      if (degreeInSign < 24) return BaladiAvastha.kumara;
      return BaladiAvastha.bala;
    }
  }

  /// Calculates Jagratadi (Consciousness) Avastha based on dignity.
  JagratadiAvastha _calculateJagratadi(PlanetaryDignity dignity) {
    switch (dignity) {
      case PlanetaryDignity.exalted:
      case PlanetaryDignity.moolaTrikona:
      case PlanetaryDignity.ownSign:
        return JagratadiAvastha.jagrata;

      case PlanetaryDignity.greatFriend:
      case PlanetaryDignity.friendSign:
      case PlanetaryDignity.neutralSign:
        return JagratadiAvastha.svapna;

      case PlanetaryDignity.enemySign:
      case PlanetaryDignity.greatEnemy:
      case PlanetaryDignity.debilitated:
        return JagratadiAvastha.sushupti;
    }
  }

  /// Calculates Deeptadi (Mood/Condition) Avastha based on dignity and state.
  DeeptadiAvastha _calculateDeeptadi(VedicPlanetInfo planetInfo) {
    if (planetInfo.isCombust) {
      return DeeptadiAvastha.khala;
    }

    // Check for retrograde status using negative longitude speed
    if (planetInfo.position.longitudeSpeed < 0) {
      // For retrogrades in enemy/debilitated signs, they are considered agitated/Kopa
      if (planetInfo.dignity == PlanetaryDignity.enemySign ||
          planetInfo.dignity == PlanetaryDignity.greatEnemy ||
          planetInfo.dignity == PlanetaryDignity.debilitated) {
        return DeeptadiAvastha.kopa;
      }
    }

    switch (planetInfo.dignity) {
      case PlanetaryDignity.exalted:
        return DeeptadiAvastha.deepta;
      case PlanetaryDignity.moolaTrikona:
      case PlanetaryDignity.ownSign:
        return DeeptadiAvastha.swastha;
      case PlanetaryDignity.greatFriend:
        return DeeptadiAvastha.mudita;
      case PlanetaryDignity.friendSign:
        return DeeptadiAvastha.shanta;
      case PlanetaryDignity.neutralSign:
        return DeeptadiAvastha.dina;
      case PlanetaryDignity.enemySign:
      case PlanetaryDignity.greatEnemy:
        return DeeptadiAvastha.dukhita;
      case PlanetaryDignity.debilitated:
        return DeeptadiAvastha.vikala;
    }
  }
}
