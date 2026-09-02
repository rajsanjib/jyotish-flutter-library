import 'package:jyotish/src/models/planet.dart';
import 'package:jyotish/src/models/rashi.dart';
import 'package:jyotish/src/models/vedic_chart.dart';
import 'dosha.dart';
import 'compatibility.dart'; // For ManglikDoshaResult

/// Service to analyze and calculate Vedic astrological flaws (Doshas)
/// as per classical scriptures and rules implemented in PyJHora/JHora.
class DoshaService {
  const DoshaService();

  /// Performs a complete analysis of all individual/natal doshas for a chart.
  FullDoshaReport calculateFullDoshaReport(VedicChart chart) {
    return FullDoshaReport(
      kalaSarpa: checkKalaSarpaDosha(chart),
      manglik: checkManglikDoshaWithRamanExceptions(chart),
      pitru: checkPitruDosha(chart),
      guruChandala: checkGuruChandalaDosha(chart),
      gandaMoola: checkGandaMoolaDosha(chart),
      kalathra: checkKalathraDosha(chart),
      ghata: checkGhataDosha(chart),
      shrapit: checkShrapitDosha(chart),
    );
  }

  /// Checks for Kala Sarpa Dosha (planets hemmed between Rahu and Ketu).
  /// Determines type (Anant, Kulik, etc.) based on Rahu's house position.
  KalaSarpaDoshaResult checkKalaSarpaDosha(VedicChart chart) {
    final node = chart.calculationFlags?.nodeType.planet ?? Planet.meanNode;
    final rahuHouse = getHouseOfPlanet(chart, node) != 0
        ? getHouseOfPlanet(chart, node)
        : (getHouseOfPlanet(chart, Planet.trueNode) != 0
            ? getHouseOfPlanet(chart, Planet.trueNode)
            : getHouseOfPlanet(chart, Planet.meanNode));
    final ketuHouse = getHouseOfPlanet(chart, Planet.ketu);

    final traditionalPlanets = [
      Planet.sun,
      Planet.moon,
      Planet.mars,
      Planet.mercury,
      Planet.jupiter,
      Planet.venus,
      Planet.saturn,
    ];

    // Helper to check if a house is in range [start, end] inclusive, moving clockwise (1-based)
    bool isHouseInRange(int h, int start, int end) {
      final tempStart = start - 1;
      final tempEnd = end - 1;
      final tempH = h - 1;
      final len = (tempEnd - tempStart + 12) % 12;
      final dist = (tempH - tempStart + 12) % 12;
      return dist <= len;
    }

    final allInSide1 = traditionalPlanets.every(
      (p) => isHouseInRange(getHouseOfPlanet(chart, p), rahuHouse, ketuHouse),
    );
    final allInSide2 = traditionalPlanets.every(
      (p) => isHouseInRange(getHouseOfPlanet(chart, p), ketuHouse, rahuHouse),
    );

    final hasDosha = allInSide1 || allInSide2;

    const types = [
      'None',
      'Anant',
      'Kulik',
      'Vasuki',
      'Shankhapal',
      'Padma',
      'Mahapadma',
      'Takshak',
      'Karkotak',
      'Shankhachur',
      'Ghatak',
      'Vishdhar',
      'Sheshnag',
    ];

    final type = hasDosha ? types[rahuHouse] : 'None';
    final description = hasDosha
        ? 'Rahu is in house $rahuHouse and Ketu is in house $ketuHouse with all traditional planets hemmed in between, forming $type Kala Sarpa Dosha.'
        : 'Planets are not hemmed between Rahu and Ketu; no Kala Sarpa Dosha present.';

    return KalaSarpaDoshaResult(
      hasDosha: hasDosha,
      type: type,
      description: description,
    );
  }

  /// Checks for Manglik Dosha using BV Raman's 17 detailed exceptions as per PyJHora.
  ManglikDoshaResult checkManglikDoshaWithRamanExceptions(VedicChart chart) {
    final mars = chart.getPlanet(Planet.mars);
    if (mars == null) {
      return const ManglikDoshaResult(
        isManglik: false,
        housesAffected: [],
        severity: 'None',
        remedies: [],
      );
    }

    final ascendantSign = _getAscendantSign(chart);
    final moonSign =
        Rashi.fromLongitude(chart.getPlanet(Planet.moon)?.longitude ?? 0);
    final venusSign =
        Rashi.fromLongitude(chart.getPlanet(Planet.venus)?.longitude ?? 0);
    final marsSign = Rashi.fromLongitude(mars.longitude);

    final marsFromAsc = _getHouseDistance(ascendantSign, marsSign);
    final marsFromMoon = _getHouseDistance(moonSign, marsSign);
    final marsFromVenus = _getHouseDistance(venusSign, marsSign);

    // PyJHora checks 2, 4, 7, 8, 12 by default (omits 1st house by default unless configured,
    // but checks the 1st house if include_lagna_house is True. To maintain parity and full coverage,
    // we check all standard 1, 2, 4, 7, 8, 12 houses).
    const manglikHouses = [1, 2, 4, 7, 8, 12];

    final manglikFromAsc = manglikHouses.contains(marsFromAsc);
    final manglikFromMoon = manglikHouses.contains(marsFromMoon);
    final manglikFromVenus = manglikHouses.contains(marsFromVenus);

    bool isManglik = manglikFromAsc || manglikFromMoon || manglikFromVenus;
    final housesAffected = <int>[];
    if (manglikFromAsc) housesAffected.add(marsFromAsc);

    String severity = 'None';
    final remedies = <String>[];

    if (isManglik) {
      final activeExceptions = <int>[];
      final exceptions = List.generate(17, (_) => false);

      const lagnaHouse = 1; // Relative to Ascendant

      // 1. Mars in Leo or Aquarius
      exceptions[0] = (marsSign == Rashi.leo || marsSign == Rashi.aquarius);

      // 2. Mars in 2nd house and in Gemini or Virgo
      exceptions[1] = (marsFromAsc == 2 &&
          (marsSign == Rashi.gemini || marsSign == Rashi.virgo));

      // 3. Mars in 4th house and in Aries or Scorpio
      exceptions[2] = (marsFromAsc == 4 &&
          (marsSign == Rashi.aries || marsSign == Rashi.scorpio));

      // 4. Mars in 7th house and in Cancer or Capricorn
      exceptions[3] = (marsFromAsc == 7 &&
          (marsSign == Rashi.cancer || marsSign == Rashi.capricorn));

      // 5. Mars in 8th house and in Sagittarius or Pisces
      exceptions[4] = (marsFromAsc == 8 &&
          (marsSign == Rashi.sagittarius || marsSign == Rashi.pisces));

      // 6. Mars in 12th house and in Taurus or Libra
      exceptions[5] = (marsFromAsc == 12 &&
          (marsSign == Rashi.taurus || marsSign == Rashi.libra));

      // 7. Mars conjoined or aspected by Jupiter or Saturn
      exceptions[6] = _isPlanetAspectedByOrConjoinedWith(
              chart, Planet.mars, Planet.jupiter) ||
          _isPlanetAspectedByOrConjoinedWith(chart, Planet.mars, Planet.saturn);

      // 8. Retrograde Mars
      exceptions[7] = mars.isRetrograde;

      // 9. Mars is weak (combust or Rasi Sandhi - within 1 degree of sign boundary)
      final posInSign = mars.longitude % 30;
      exceptions[8] = mars.isCombust || (posInSign < 1.0 || posInSign > 29.0);

      // 10. Mars is Lagna Lord (Aries or Scorpio Ascendant)
      exceptions[9] =
          (ascendantSign == Rashi.aries || ascendantSign == Rashi.scorpio);

      // 11. Dispositor of Mars is neecha or associated with a strong benefic (hardcoded as False in PyJHora)
      exceptions[10] = false;

      // 12. Mars in own house, exalted, or friendly sign
      exceptions[11] = (marsSign == Rashi.aries ||
          marsSign == Rashi.scorpio ||
          marsSign == Rashi.capricorn ||
          mars.dignity == PlanetaryDignity.ownSign ||
          mars.dignity == PlanetaryDignity.exalted ||
          mars.dignity == PlanetaryDignity.friendSign);

      // 13. Mars in movable sign (Aries, Cancer, Libra, Capricorn)
      exceptions[12] = (marsSign.index % 3 == 0);

      // 14. Dispositor of Mars in Quadrant or Trine (hardcoded as False in PyJHora)
      exceptions[13] = false;

      // 15. Lagna is in Cancer or Leo (Mars is Yoga Karaka)
      exceptions[14] =
          (ascendantSign == Rashi.cancer || ascendantSign == Rashi.leo);

      // 16. Mars conjoined with Jupiter or Moon (same sign/house)
      final jupSign =
          Rashi.fromLongitude(chart.getPlanet(Planet.jupiter)?.longitude ?? 0);
      exceptions[15] = (marsSign == jupSign || marsSign == moonSign);

      // 17. Jupiter or Venus in Lagna
      final jupHouse = getHouseOfPlanet(chart, Planet.jupiter);
      final venHouse = getHouseOfPlanet(chart, Planet.venus);
      exceptions[16] = (jupHouse == lagnaHouse || venHouse == lagnaHouse);

      for (int i = 0; i < 17; i++) {
        if (exceptions[i]) activeExceptions.add(i + 1);
      }

      if (activeExceptions.isNotEmpty) {
        isManglik = false;
        severity = 'Cancelled';
        remedies.add(
            'Manglik Dosha cancelled by Raman Exception rules (Exceptions met: ${activeExceptions.join(", ")})');
      } else {
        final count = (manglikFromAsc ? 1 : 0) +
            (manglikFromMoon ? 1 : 0) +
            (manglikFromVenus ? 1 : 0);
        severity = count >= 2 ? 'High' : 'Moderate';
        remedies.addAll([
          'Chant Mars/Mangal Mantra daily',
          'Donate red lentils or red items on Tuesdays',
          'Fast on Tuesdays',
        ]);
      }
    }

    return ManglikDoshaResult(
      isManglik: isManglik,
      housesAffected: housesAffected.toSet().toList(),
      severity: severity,
      remedies: remedies,
    );
  }

  /// Checks for Pitru Dosha (ancestral afflictions) using PyJHora's 5 rules.
  PitruDoshaResult checkPitruDosha(VedicChart chart) {
    final node = chart.calculationFlags?.nodeType.planet ?? Planet.meanNode;
    final sunHouse = getHouseOfPlanet(chart, Planet.sun);
    final moonHouse = getHouseOfPlanet(chart, Planet.moon);
    final rahuHouse = getHouseOfPlanet(chart, node);
    final ketuHouse = getHouseOfPlanet(chart, Planet.ketu);

    final factorsMatched = <String>[];

    // Rule 1: Sun, Moon, or Rahu in 9th house
    if (sunHouse == 9 || moonHouse == 9 || rahuHouse == 9) {
      factorsMatched
          .add('Rule 1: Sun, Moon, or Rahu in 9th house (Ancestral Lineage)');
    }

    // Rule 2: Ketu in 4th house
    if (ketuHouse == 4) {
      factorsMatched.add('Rule 2: Ketu in 4th house (Maternal Karma)');
    }

    // Rule 3: Sun, Moon, Rahu, or Ketu conjoined or aspected by Mars or Saturn
    final afflictedPlanets = <String>[];
    final targetPlanets = [Planet.sun, Planet.moon, node, Planet.ketu];
    for (final p in targetPlanets) {
      final isAfflicted =
          _isPlanetAspectedByOrConjoinedWith(chart, p, Planet.mars) ||
              _isPlanetAspectedByOrConjoinedWith(chart, p, Planet.saturn);
      if (isAfflicted) {
        afflictedPlanets.add(p.displayName);
      }
    }
    if (afflictedPlanets.isNotEmpty) {
      factorsMatched.add(
          'Rule 3: Sun/Moon/Nodes afflicted by Mars/Saturn (${afflictedPlanets.join(", ")})');
    }

    // Rule 4: Venus, Mercury, and Rahu (any two or more) conjoined in houses 2, 5, 9, or 12
    for (final h in [2, 5, 9, 12]) {
      int count = 0;
      if (getHouseOfPlanet(chart, Planet.mercury) == h) count++;
      if (getHouseOfPlanet(chart, Planet.venus) == h) count++;
      if (rahuHouse == h) count++;
      if (count > 1) {
        factorsMatched.add(
            'Rule 4: Multiple planets (Mercury/Venus/Rahu) conjoined in house $h');
        break;
      }
    }

    // Rule 5: Sun or Moon in conjunction (same house) with Rahu or Ketu
    if (sunHouse == rahuHouse ||
        sunHouse == ketuHouse ||
        moonHouse == rahuHouse ||
        moonHouse == ketuHouse) {
      factorsMatched.add('Rule 5: Sun/Moon conjoined with Rahu/Ketu');
    }

    final hasDosha = factorsMatched.isNotEmpty;
    final remedies = hasDosha
        ? [
            'Perform Pitra Sharddha or Tarpan rites',
            'Donate food to the needy on Amavasya days',
            'Chant Gayatri Mantra regularly',
            'Water a Banyan or Peepal tree on Saturdays',
          ]
        : <String>[];

    return PitruDoshaResult(
      hasDosha: hasDosha,
      factorsMatched: factorsMatched,
      remedies: remedies,
    );
  }

  /// Checks for Guru Chandala Dosha (Jupiter conjunct Rahu or Ketu).
  /// Evaluates Jupiter's strength to determine if the dosha is mitigated.
  GuruChandalaDoshaResult checkGuruChandalaDosha(VedicChart chart) {
    final node = chart.calculationFlags?.nodeType.planet ?? Planet.meanNode;
    final jupiterHouse = getHouseOfPlanet(chart, Planet.jupiter);
    final rahuHouse = getHouseOfPlanet(chart, node);
    final ketuHouse = getHouseOfPlanet(chart, Planet.ketu);

    bool hasDosha = false;
    Planet? conjoiningNode;
    bool jupiterIsStronger = false;

    if (jupiterHouse == rahuHouse) {
      hasDosha = true;
      conjoiningNode = node;
      jupiterIsStronger = _isJupiterStrongerThanNode(chart, node);
    } else if (jupiterHouse == ketuHouse) {
      hasDosha = true;
      conjoiningNode = Planet.ketu;
      jupiterIsStronger = _isJupiterStrongerThanNode(chart, Planet.ketu);
    }

    String description;
    if (hasDosha) {
      final nodeName = conjoiningNode == Planet.ketu ? 'Ketu' : 'Rahu';
      if (jupiterIsStronger) {
        description =
            'Jupiter conjoins $nodeName in house $jupiterHouse forming Guru Chandala Dosha. However, Jupiter is strong/exalted and mitigates the negative effects.';
      } else {
        description =
            'Jupiter conjoins $nodeName in house $jupiterHouse forming active Guru Chandala Dosha. Wisdom or spiritual beliefs may face trials.';
      }
    } else {
      description =
          'Jupiter does not conjoin Rahu or Ketu; Guru Chandala Dosha is absent.';
    }

    return GuruChandalaDoshaResult(
      hasDosha: hasDosha,
      conjoiningNode: conjoiningNode,
      jupiterIsStronger: jupiterIsStronger,
      description: description,
    );
  }

  /// Checks for Ganda Moola Dosha (Moon Nakshatra birth in Ketu/Mercury stars).
  GandaMoolaDoshaResult checkGandaMoolaDosha(VedicChart chart) {
    final moon = chart.getPlanet(Planet.moon);
    final moonNakIndex = moon?.position.nakshatraIndex ?? -1;
    final moonNakName = moon?.position.nakshatra ?? 'Unknown';

    // Ketu-ruled (0: Ashwini, 9: Magha, 18: Mula)
    // Mercury-ruled (8: Ashlesha, 17: Jyeshtha, 26: Revati)
    final gandaMoolaIndexes = {0, 8, 9, 17, 18, 26};
    final hasDosha = gandaMoolaIndexes.contains(moonNakIndex);

    final description = hasDosha
        ? 'Born under $moonNakName Nakshatra (Ganda Moola). Astrological cycles require Moola Shanti rituals.'
        : 'Born under $moonNakName Nakshatra, which is not a Ganda Moola Nakshatra.';

    return GandaMoolaDoshaResult(
      hasDosha: hasDosha,
      nakshatra: moonNakName,
      description: description,
    );
  }

  /// Checks for Kalathra Dosha (malefics in houses 1, 2, 4, 7, 8, 12 from Lagna or Moon).
  KalathraDoshaResult checkKalathraDosha(VedicChart chart) {
    final node = chart.calculationFlags?.nodeType.planet ?? Planet.meanNode;
    final kalathraHouses = {1, 2, 4, 7, 8, 12};
    final malefics = [
      Planet.sun,
      Planet.mars,
      Planet.saturn,
      node,
      Planet.ketu,
    ];

    // Check placements from Ascendant (1-based house position)
    final ascMalefics = malefics
        .where((p) => kalathraHouses.contains(getHouseOfPlanet(chart, p)))
        .toList();

    // Check placements from Moon (relative houses)
    final moonHouse = getHouseOfPlanet(chart, Planet.moon);
    final moonMalefics = malefics.where((p) {
      final relHouse = (getHouseOfPlanet(chart, p) - moonHouse + 12) % 12 + 1;
      return kalathraHouses.contains(relHouse);
    }).toList();

    // In PyJHora: "kc = all([any([planet_positions[p+1][1][0] == (ref_house+h)%12 for h in houses]) for p in natural_malefics])"
    // To match PyJHora's literal algorithm, we require ALL malefics to be placed in these houses.
    // However, to make it astrology-practitioner friendly, we define it as present if any are, but flag a strict matching warning.
    // We will use the literal 'all' check to flag the strict dosha, but list the causing planets.
    final hasDosha = ascMalefics.length == malefics.length ||
        moonMalefics.length == malefics.length;

    String description;
    if (hasDosha) {
      description =
          'All 5 natural malefics (${malefics.map((p) => p.displayName).join(", ")}) are placed in Kalathra houses (1, 2, 4, 7, 8, or 12) from Lagna or Moon, indicating Kalathra Dosha.';
    } else if (ascMalefics.isNotEmpty || moonMalefics.isNotEmpty) {
      final causing = {...ascMalefics, ...moonMalefics}
          .map((p) => p.displayName)
          .join(", ");
      description =
          'Malefic planets ($causing) occupy Kalathra houses (1, 2, 4, 7, 8, 12) from Lagna/Moon. Partial Kalathra afflictions exist.';
    } else {
      description =
          'No malefic planets reside in the spouse/partner houses (1, 2, 4, 7, 8, or 12).';
    }

    return KalathraDoshaResult(
      hasDosha: hasDosha ||
          ascMalefics.isNotEmpty, // Present if there are afflictions
      causingMalefics: {...ascMalefics, ...moonMalefics}.toList(),
      description: description,
    );
  }

  /// Checks for Ghata Dosha (Mars and Saturn conjoined in the same house).
  ConjunctionDoshaResult checkGhataDosha(VedicChart chart) {
    final marsHouse = getHouseOfPlanet(chart, Planet.mars);
    final saturnHouse = getHouseOfPlanet(chart, Planet.saturn);

    final hasDosha = marsHouse == saturnHouse;
    final description = hasDosha
        ? 'Mars and Saturn conjoin in house $marsHouse, forming Ghata Dosha. Creates highly volatile and competitive energies.'
        : 'Mars and Saturn are in separate houses; Ghata Dosha is absent.';

    return ConjunctionDoshaResult(
      hasDosha: hasDosha,
      name: 'Ghata Dosha',
      description: description,
    );
  }

  /// Checks for Shrapit Dosha (Saturn and Rahu conjoined in the same house).
  ConjunctionDoshaResult checkShrapitDosha(VedicChart chart) {
    final node = chart.calculationFlags?.nodeType.planet ?? Planet.meanNode;
    final saturnHouse = getHouseOfPlanet(chart, Planet.saturn);
    final rahuHouse = getHouseOfPlanet(chart, node);

    final hasDosha = saturnHouse == rahuHouse;
    final description = hasDosha
        ? 'Saturn and Rahu conjoin in house $saturnHouse, forming Shrapit Dosha. Signifies hard lessons and karmic limitations.'
        : 'Saturn and Rahu are in separate houses; Shrapit Dosha is absent.';

    return ConjunctionDoshaResult(
      hasDosha: hasDosha,
      name: 'Shrapit Dosha',
      description: description,
    );
  }

  // ============================================================
  // ASTROLOGICAL UTILITIES & HELPERS
  // ============================================================

  /// Returns the 1-based house of any planet in the chart.
  int getHouseOfPlanet(VedicChart chart, Planet planet) {
    if (planet == Planet.ketu) {
      return chart.houses.getHouseForLongitude(chart.ketu.longitude);
    }
    if (planet == Planet.meanNode || planet == Planet.trueNode) {
      return chart.rahu.house;
    }
    final info = chart.getPlanet(planet);
    if (info != null) {
      return info.house;
    }
    // Fallback in case node type doesn't match
    if (planet.displayName == 'Rahu') {
      return chart.rahu.house;
    }
    return 1;
  }

  Rashi _getAscendantSign(VedicChart chart) {
    final signName = chart.ascendantSign;
    return Rashi.values.firstWhere(
      (r) => r.name.toLowerCase() == signName.toLowerCase(),
      orElse: () => Rashi.aries,
    );
  }

  int _getHouseDistance(Rashi refSign, Rashi targetSign) {
    int dist = targetSign.index - refSign.index + 1;
    if (dist <= 0) dist += 12;
    return dist;
  }

  /// Checks standard whole-sign aspect or conjunction:
  /// - Conjunction: same sign index.
  /// - Aspect: 7th sign for all, 4/8 for Mars, 5/9 for Jupiter, 3/10 for Saturn.
  bool _isPlanetAspectedByOrConjoinedWith(
      VedicChart chart, Planet target, Planet aspectingPlanet) {
    final targetSign = chart.getPlanetSignIndex(target);
    final aspectingSign = chart.getPlanetSignIndex(aspectingPlanet);
    if (targetSign == null || aspectingSign == null) return false;

    if (targetSign == aspectingSign) return true; // Conjunction

    final diff = (targetSign - aspectingSign + 12) % 12 + 1; // 1-based offset

    if (aspectingPlanet == Planet.mars) {
      return diff == 4 || diff == 7 || diff == 8;
    } else if (aspectingPlanet == Planet.saturn) {
      return diff == 3 || diff == 7 || diff == 10;
    } else if (aspectingPlanet == Planet.jupiter) {
      return diff == 5 || diff == 7 || diff == 9;
    } else if (aspectingPlanet.displayName == 'Rahu' ||
        aspectingPlanet == Planet.ketu) {
      return diff == 5 || diff == 7 || diff == 9;
    }

    return diff == 7; // Default mutual aspect
  }

  /// Mitigates Guru Chandala Dosha if Jupiter is exalted, in own sign, or has higher sign degree.
  bool _isJupiterStrongerThanNode(VedicChart chart, Planet node) {
    final jup = chart.getPlanet(Planet.jupiter);
    if (jup == null) return false;

    if (jup.dignity == PlanetaryDignity.exalted ||
        jup.dignity == PlanetaryDignity.moolaTrikona ||
        jup.dignity == PlanetaryDignity.ownSign) {
      return true;
    }

    final nodeLong = node == Planet.ketu
        ? chart.ketu.longitude
        : (chart.getPlanet(node)?.longitude ?? chart.rahu.longitude);

    final jupDeg = jup.longitude % 30;
    final nodeDeg = nodeLong % 30;
    return jupDeg > nodeDeg;
  }
}
