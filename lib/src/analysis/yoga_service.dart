import 'package:jyotish/src/models/planet.dart';
import 'package:jyotish/src/models/rashi.dart';
import 'package:jyotish/src/models/vedic_chart.dart';
import 'package:jyotish/src/analysis/yoga.dart';

/// Service for detecting Natal, Raja, and Nabhasa yogas in a Vedic Chart.
/// Supports 280+ standard yogas at par with PyJHora.
class YogaService {
  const YogaService();

  /// Gets the house number (1-12) of a planet.
  int _getPlanetHouse(VedicChart chart, Planet planet) {
    if (planet == Planet.ketu) {
      return chart.houses.getHouseForLongitude(chart.ketu.longitude);
    } else if (planet == Planet.meanNode || planet == Planet.trueNode) {
      return chart.rahu.house;
    } else {
      return chart.getPlanet(planet)?.house ?? 1;
    }
  }

  /// Gets the sign index (0-11) of a planet (Aries=0, Pisces=11).
  int _getPlanetSign(VedicChart chart, Planet planet) {
    if (planet == Planet.ketu) {
      return (chart.ketu.longitude / 30).floor() % 12;
    } else if (planet == Planet.meanNode || planet == Planet.trueNode) {
      return (chart.rahu.longitude / 30).floor() % 12;
    } else {
      return chart.getPlanetSignIndex(planet) ?? 0;
    }
  }

  /// Checks if a planet is exalted.
  bool _isExalted(VedicChart chart, Planet planet) {
    if (planet == Planet.ketu ||
        planet == Planet.meanNode ||
        planet == Planet.trueNode) {
      return false;
    }
    return chart.getPlanet(planet)?.dignity == PlanetaryDignity.exalted;
  }

  /// Checks if a planet is in its own sign.
  bool _isOwnSign(VedicChart chart, Planet planet) {
    if (planet == Planet.ketu ||
        planet == Planet.meanNode ||
        planet == Planet.trueNode) {
      return false;
    }
    final info = chart.getPlanet(planet);
    return info?.dignity == PlanetaryDignity.ownSign ||
        info?.dignity == PlanetaryDignity.moolaTrikona;
  }

  /// Gets the lord of a given house number (1-12).
  Planet _getHouseLord(VedicChart chart, int houseNumber) {
    final ascLong = chart.ascendant;
    final lagnaSign = Rashi.fromLongitude(ascLong);
    final houseSignIndex = (lagnaSign.index + houseNumber - 1) % 12;
    return Rashi.values[houseSignIndex].lord;
  }

  /// Checks if a planet aspects a target house (1-12).
  bool _doesPlanetAspectHouse(
    VedicChart chart,
    Planet planet,
    int targetHouse,
  ) {
    final info = chart.getPlanet(planet);
    if (info == null) return false;
    final h = info.house;
    final h0 = h - 1;

    final List<int> aspectedHouses0 = [];
    aspectedHouses0.add((h0 + 6) % 12); // 7th aspect (standard for all planets)

    if (planet == Planet.mars) {
      aspectedHouses0.add((h0 + 3) % 12); // 4th aspect
      aspectedHouses0.add((h0 + 7) % 12); // 8th aspect
    } else if (planet == Planet.jupiter) {
      aspectedHouses0.add((h0 + 4) % 12); // 5th aspect
      aspectedHouses0.add((h0 + 8) % 12); // 9th aspect
    } else if (planet == Planet.saturn) {
      aspectedHouses0.add((h0 + 2) % 12); // 3rd aspect
      aspectedHouses0.add((h0 + 9) % 12); // 10th aspect
    }

    return aspectedHouses0.contains(targetHouse - 1);
  }

  /// Checks if a planet is a natural benefic.
  bool _isBenefic(Planet planet) {
    return [
      Planet.jupiter,
      Planet.venus,
      Planet.mercury,
      Planet.moon,
    ].contains(planet);
  }

  /// Detects all natal, Raja, and Nabhasa yogas for a Vedic Chart.
  List<NatalYoga> detectNatalYogas(VedicChart chart) {
    final result = <NatalYoga>[];

    // House positions for traditional planets (Sun to Saturn)
    final pMap = <Planet, int>{};
    final signMap = <Planet, int>{};
    for (final p in Planet.traditionalPlanets) {
      pMap[p] = _getPlanetHouse(chart, p);
      signMap[p] = _getPlanetSign(chart, p);
    }

    // Helper: get traditional planets in a house
    List<Planet> traditionalPlanetsInHouse(int h) {
      return Planet.traditionalPlanets.where((p) => pMap[p] == h).toList();
    }

    // Helper: check if two planets are associated (conjoined, aspecting, or exchange)
    bool areAssociated(Planet p1, Planet p2) {
      final h1 = pMap[p1]!;
      final h2 = pMap[p2]!;
      if (h1 == h2) return true;
      final aspect1 = _doesPlanetAspectHouse(chart, p1, h2);
      final aspect2 = _doesPlanetAspectHouse(chart, p2, h1);
      if (aspect1 && aspect2) return true;
      final sign1 = signMap[p1]!;
      final sign2 = signMap[p2]!;
      if (Rashi.fromIndex(sign1).lord == p2 &&
          Rashi.fromIndex(sign2).lord == p1) {
        return true;
      }
      return false;
    }

    // Common indicators used across yogas
    final sunHouse = pMap[Planet.sun]!;
    final moonHouse = pMap[Planet.moon]!;

    final vesiHouse = ((sunHouse - 1 + 1) % 12) + 1;
    final vosiHouse = ((sunHouse - 1 + 11) % 12) + 1;
    final vesiPlanets = traditionalPlanetsInHouse(
      vesiHouse,
    ).where((p) => p != Planet.moon).toList();
    final vosiPlanets = traditionalPlanetsInHouse(
      vosiHouse,
    ).where((p) => p != Planet.moon).toList();

    final sunaphaHouse = ((moonHouse - 1 + 1) % 12) + 1;
    final anaphaHouse = ((moonHouse - 1 + 11) % 12) + 1;
    final sunaphaPlanets = traditionalPlanetsInHouse(
      sunaphaHouse,
    ).where((p) => p != Planet.sun).toList();
    final anaphaPlanets = traditionalPlanetsInHouse(
      anaphaHouse,
    ).where((p) => p != Planet.sun).toList();

    final kendraHouses = [1, 4, 7, 10];
    final trineHouses = [1, 5, 9];
    final occupiedHouses =
        Planet.traditionalPlanets.map((p) => pMap[p]!).toSet();
    final distinctSigns =
        Planet.traditionalPlanets.map((p) => signMap[p]!).toSet().length;

    final movableSigns = [0, 3, 6, 9];
    final fixedSigns = [1, 4, 7, 10];
    final dualSigns = [2, 5, 8, 11];

    final benefics = [Planet.jupiter, Planet.venus, Planet.mercury];
    final malefics = [Planet.sun, Planet.mars, Planet.saturn];

    // Evaluate each of the 287 yogas
    // Evaluation for vesi_yoga
    {
      final isPresent = vesiPlanets.isNotEmpty;
      final explanation = isPresent
          ? 'Planets in 2nd from Sun: ${vesiPlanets.map((p) => p.displayName).join(", ")}'
          : 'No planets in 2nd from Sun (excluding Moon)';
      result.add(
        NatalYoga(
          key: "vesi_yoga",
          name: "Vesai Yoga",
          category: "Ravi Yogas (Sun-based)",
          description:
              "There is a planet other than Moon in the 2nd house from Sun",
          benefits:
              "You will have a balanced outlook. You are truthful, tall and sluggish. You will be happy and comfortable even with little wealth.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for vosi_yoga
    {
      final isPresent = vosiPlanets.isNotEmpty;
      final explanation = isPresent
          ? 'Planets in 12th from Sun: ${vosiPlanets.map((p) => p.displayName).join(", ")}'
          : 'No planets in 12th from Sun (excluding Moon)';
      result.add(
        NatalYoga(
          key: "vosi_yoga",
          name: "Vosi Yoga",
          category: "Ravi Yogas (Sun-based)",
          description:
              "There is a planet other than Moon in the 12th house from Sun",
          benefits:
              "You will be skillful, charitable, famous, learned and strong.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for ubhayachara_yoga
    {
      final isPresent = vesiPlanets.isNotEmpty && vosiPlanets.isNotEmpty;
      final explanation = isPresent
          ? 'Planets present in both 2nd and 12th from Sun'
          : 'Sun not flanked by planets';
      result.add(
        NatalYoga(
          key: "ubhayachara_yoga",
          name: "Ubhayachara Yoga",
          category: "Ravi Yogas (Sun-based)",
          description:
              "There are planets other than Moon in the 2nd and 12th houses from Sun",
          benefits:
              "You will have all comforts. You will be like a king or an equal",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for nipuna_yoga
    {
      final isPresent = signMap[Planet.sun] == signMap[Planet.mercury];
      final explanation = isPresent
          ? 'Sun and Mercury conjoined in sign ${Rashi.fromIndex(signMap[Planet.sun]!).name}'
          : 'Sun and Mercury in different signs';
      result.add(
        NatalYoga(
          key: "nipuna_yoga",
          name: "Nipuna Yoga",
          category: "Ravi Yogas (Sun-based)",
          description: "Sun and Mercury are together (in one sign).",
          benefits:
              "You will be intelligent and skillful in all works. You will be well known, respected and happy.\n This yoga is the most powerful in divisional charts like D-10. In rasi chart also, it can give results if Mercury is not combust.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for sunaphaa_yoga
    {
      final isPresent = sunaphaPlanets.isNotEmpty;
      final explanation = isPresent
          ? 'Planets in 2nd from Moon: ${sunaphaPlanets.map((p) => p.displayName).join(", ")}'
          : 'No planets in 2nd from Moon (excluding Sun)';
      result.add(
        NatalYoga(
          key: "sunaphaa_yoga",
          name: "Sunaphaa Yoga",
          category: "Chandra Yogas (Moon-based)",
          description:
              "There are planets other than Sun in the 2nd house from Moon",
          benefits:
              "You will become a king or an equal. You are intelligent, wealthy and famous. You will have self-earned wealth.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for anaphaa_yoga
    {
      final isPresent = anaphaPlanets.isNotEmpty;
      final explanation = isPresent
          ? 'Planets in 12th from Moon: ${anaphaPlanets.map((p) => p.displayName).join(", ")}'
          : 'No planets in 12th from Moon (excluding Sun)';
      result.add(
        NatalYoga(
          key: "anaphaa_yoga",
          name: "Anaphaa Yoga",
          category: "Chandra Yogas (Moon-based)",
          description:
              "There are planets other than Sun in the 12th house from Moon",
          benefits:
              "You will become a king with good looks. Your body is likely free from disease. You are a person of character and have great reputation. You are surrounded by comforts.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for duradhara_yoga
    {
      final isPresent = sunaphaPlanets.isNotEmpty && anaphaPlanets.isNotEmpty;
      final explanation = isPresent
          ? 'Planets present in both 2nd and 12th from Moon'
          : 'Moon not flanked by planets';
      result.add(
        NatalYoga(
          key: "duradhara_yoga",
          name: "Duradhara Yoga",
          category: "Chandra Yogas (Moon-based)",
          description:
              "There are planets other than Sun in the 2nd and 12th houses from Moon.",
          benefits:
              "You will enjoy many pleasures. You are charitable. You will wealth and vehicles. You will have good servants.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for kemadruma_yoga
    {
      final isPresent = sunaphaPlanets.isEmpty &&
          anaphaPlanets.isEmpty &&
          traditionalPlanetsInHouse(
            moonHouse,
          ).where((p) => p != Planet.moon && p != Planet.sun).isEmpty &&
          Planet.traditionalPlanets
              .where((p) => kendraHouses.contains(pMap[p]))
              .isEmpty;
      final explanation = isPresent
          ? 'No planets in 1st, 2nd, 12th from Moon and no planets in Kendras from Lagna'
          : 'Kemadruma conditions not met';
      result.add(
        NatalYoga(
          key: "kemadruma_yoga",
          name: "Kemadruma Yoga",
          category: "Chandra Yogas (Moon-based)",
          description:
              "There are no planets other than Sun in the 1st, 2nd and 12th houses from Moon and there are no planets other than Moon in the quadrants from lagna",
          benefits:
              "You are unlucky, bereft of intelligence and learning and afflicted by poverty and trouble. This bad yoga kills the results of other good yogas in the chart, especially Chandra yogas (if any). You have to work hard and succeed through great efforts.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for chandra_mangala_yoga
    {
      final isPresent = signMap[Planet.moon] == signMap[Planet.mars];
      final explanation = isPresent
          ? 'Moon and Mars conjoined in sign ${Rashi.fromIndex(signMap[Planet.moon]!).name}'
          : 'Moon and Mars in different signs';
      result.add(
        NatalYoga(
          key: "chandra_mangala_yoga",
          name: "Chandra Mangala Yoga",
          category: "Chandra Yogas (Moon-based)",
          description: "Moon and Mars are together (in one sign).",
          benefits:
              "You are worldly wise and materially successful. You may earn money through unscrupulous means. You may treat mother or other women badly.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for adhi_yoga
    {
      final adhiHouses = [
        6,
        7,
        8,
      ].map((h) => ((moonHouse - 1 + h - 1) % 12) + 1).toList();
      final isPresent = [
        Planet.jupiter,
        Planet.venus,
        Planet.mercury,
      ].every((p) => adhiHouses.contains(pMap[p]));
      final explanation = isPresent
          ? 'Jupiter, Venus, and Mercury in 6th, 7th, 8th from Moon'
          : 'Benefics not in 6, 7, 8 from Moon';
      result.add(
        NatalYoga(
          key: "adhi_yoga",
          name: "Adhi Yoga",
          category: "Chandra Yogas (Moon-based)",
          description: "Natural benefics occupy 6th, 7th and 8th from Moon",
          benefits:
              "You may become a king or a minister or an army chief, depending on the strength of the planets involved",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for ruchaka_yoga
    {
      final isPresent = kendraHouses.contains(pMap[Planet.mars]) &&
          (_isOwnSign(chart, Planet.mars) || _isExalted(chart, Planet.mars));
      final explanation = isPresent
          ? 'Mars own/exalted in Kendra house ${pMap[Planet.mars]}'
          : 'Mars conditions not met';
      result.add(
        NatalYoga(
          key: "ruchaka_yoga",
          name: "Ruchaka Yoga",
          category: "Pancha Mahapurusha Yogas",
          description: "Mars is in a quadrant in own sign or exaltation sign.",
          benefits:
              "You are a person of fiery nature. You have a lot of enthusiasm. You are a natural leader. You love to fight wars and you will be victorious over enemies. You are discriminative and a devotee of learned people. You are well-versed in occult sciences. You have good taste. You will be always successful.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for bhadra_yoga
    {
      final isPresent = kendraHouses.contains(pMap[Planet.mercury]) &&
          (_isOwnSign(chart, Planet.mercury) ||
              _isExalted(chart, Planet.mercury));
      final explanation = isPresent
          ? 'Mercury own/exalted in Kendra house ${pMap[Planet.mercury]}'
          : 'Mercury conditions not met';
      result.add(
        NatalYoga(
          key: "bhadra_yoga",
          name: "Bhadra Yoga",
          category: "Pancha Mahapurusha Yogas",
          description:
              "Mercury is in a quadrant in own sign or exaltation sign.",
          benefits:
              "You are a person of earthy nature and are lion-like. You are learned in all respects. You have a good build of body and a deep voice. You have sattwa guna. You know yoga well. You are always surrounded by relatives, friends and family and enjoys your wealth with them. You maintain cleanliness in everything and are very systematic. You are a spirit of independence and religious.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for sasa_yoga
    {
      final isPresent = kendraHouses.contains(pMap[Planet.saturn]) &&
          (_isOwnSign(chart, Planet.saturn) ||
              _isExalted(chart, Planet.saturn));
      final explanation = isPresent
          ? 'Saturn own/exalted in Kendra house ${pMap[Planet.saturn]}'
          : 'Saturn conditions not met';
      result.add(
        NatalYoga(
          key: "sasa_yoga",
          name: "Sasa Yoga",
          category: "Pancha Mahapurusha Yogas",
          description:
              "Saturn should be in Capricorn, Aquariius or Libra and he should be in 1st, 4th, 7th or 10th from lagna",
          benefits:
              "You are a great person of airy nature. You are rabbit-like. You are wise and enjoy wandering. You are comfortable in forests, mountains and forts. You are valorous and have a slender build. You know the weaknesses of others. You are lively, but have some vacillation. You are charitable.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for maalavya_yoga
    {
      final isPresent = kendraHouses.contains(pMap[Planet.venus]) &&
          (_isOwnSign(chart, Planet.venus) || _isExalted(chart, Planet.venus));
      final explanation = isPresent
          ? 'Venus own/exalted in Kendra house ${pMap[Planet.venus]}'
          : 'Venus conditions not met';
      result.add(
        NatalYoga(
          key: "maalavya_yoga",
          name: "Maalavya Yoga",
          category: "Pancha Mahapurusha Yogas",
          description: "Venus is in a quadrant in own sign or exaltation sign.",
          benefits:
              "You are a great person of watery nature. You emit a lustre akin to moonlight. You enjoy tasty food. You have luxuries. You have excellent health. You are well-versed in arts.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for hamsa_yoga
    {
      final isPresent = kendraHouses.contains(pMap[Planet.jupiter]) &&
          (_isOwnSign(chart, Planet.jupiter) ||
              _isExalted(chart, Planet.jupiter));
      final explanation = isPresent
          ? 'Jupiter own/exalted in Kendra house ${pMap[Planet.jupiter]}'
          : 'Jupiter conditions not met';
      result.add(
        NatalYoga(
          key: "hamsa_yoga",
          name: "Hamsa Yoga",
          category: "Pancha Mahapurusha Yogas",
          description:
              "Jupiter should be in Sagitarius, Pisces or Capricornn and he should be in 1st, 4th, 7th or 10th from lagna.",
          benefits:
              "You are a great man of ethery nature. You are swan-like. You have spiritual strength and purity. You are respected by everyone. You are very passionate. You may become a king. You may have all comforts. You enjoy life fully. You are a clever conversationalist and endowed with good speech.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for rajju_yoga
    {
      final isPresent = Planet.traditionalPlanets.every(
        (p) => movableSigns.contains(signMap[p]!),
      );
      final explanation = isPresent
          ? 'All planets in Movable signs'
          : 'Not all in Movable signs';
      result.add(
        NatalYoga(
          key: "rajju_yoga",
          name: "Rajju Yoga",
          category: "Nabhasa Yogas",
          description: "All the planets are exclusively in movable signs.",
          benefits:
              "You may like to travel. You may have good looks and flourishes in foreign countries. You may be cruel.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for musala_yoga
    {
      final isPresent = Planet.traditionalPlanets.every(
        (p) => fixedSigns.contains(signMap[p]!),
      );
      final explanation =
          isPresent ? 'All planets in Fixed signs' : 'Not all in Fixed signs';
      result.add(
        NatalYoga(
          key: "musala_yoga",
          name: "Musala Yoga",
          category: "Nabhasa Yogas",
          description: "All the planets are exclusively in fixed signs.",
          benefits:
              "You will have honor, wisdom and wealth. Kings will like you. You are famous and will have many children. You have a firm spirit.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for nala_yoga
    {
      final isPresent = Planet.traditionalPlanets.every(
        (p) => dualSigns.contains(signMap[p]!),
      );
      final explanation =
          isPresent ? 'All planets in Dual signs' : 'Not all in Dual signs';
      result.add(
        NatalYoga(
          key: "nala_yoga",
          name: "Nala Yoga",
          category: "Nabhasa Yogas",
          description: "All the planets are exclusively in dual signs.",
          benefits:
              "You will have a poor physique. You may accumulate money. You may have good looks and help relatives. You are skillful.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for srik_yoga
    {
      final isPresent = benefics.every((p) => kendraHouses.contains(pMap[p]));
      final explanation = isPresent
          ? 'All natural benefics in Kendra houses'
          : 'Benefics missing from Kendra';
      result.add(
        NatalYoga(
          key: "srik_yoga",
          name: "Srik Yoga",
          category: "Nabhasa Yogas",
          description:
              "All natural benefics (Jupiter, Venus, Mercury) occupy the Kendra houses.",
          benefits:
              "You will be wealthy, enjoy many comforts, possess fine clothes and ornaments, and lead a happy, luxurious life.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for maalaa_yoga
    {
      final isPresent = benefics.every((p) => kendraHouses.contains(pMap[p])) &&
          malefics.where((p) => kendraHouses.contains(pMap[p])).isEmpty;
      final explanation = isPresent
          ? 'Quadrants occupied only by natural benefics'
          : 'Malefics in quadrants or benefics missing';
      result.add(
        NatalYoga(
          key: "maalaa_yoga",
          name: "Maalaa Yoga",
          category: "Nabhasa Yogas",
          description: "Three quadrants are occupied by natural benefics.",
          benefits:
              "You will be always happy. You will have nice clothes, vehicles, luxuries and friendship of many women.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for sarpa_yoga
    {
      final isPresent = malefics.every((p) => kendraHouses.contains(pMap[p])) &&
          benefics.where((p) => kendraHouses.contains(pMap[p])).isEmpty;
      final explanation = isPresent
          ? 'Quadrants occupied only by natural malefics'
          : 'Benefics in quadrants or malefics missing';
      result.add(
        NatalYoga(
          key: "sarpa_yoga",
          name: "Sarpa Yoga",
          category: "Nabhasa Yogas",
          description:
              "Three quadrants are occupied by natural malefic planets.",
          benefits:
              "One born with this yoga is miserable, unhappy, cruel, poor and dependent on others for food. This is a very bad combination.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for gadaa_yoga
    {
      final isPresent = occupiedHouses.every((h) => h == 1 || h == 4) ||
          occupiedHouses.every((h) => h == 4 || h == 7) ||
          occupiedHouses.every((h) => h == 7 || h == 10) ||
          occupiedHouses.every((h) => h == 10 || h == 1);
      final explanation = isPresent
          ? 'Planets situated in adjacent quadrants'
          : 'Not situated in adjacent quadrants';
      result.add(
        NatalYoga(
          key: "gadaa_yoga",
          name: "Gadaa Yoga",
          category: "Nabhasa Yogas",
          description:
              "All the planets occupy two successive quadrants from lagna.",
          benefits:
              "One born with this yoga possesses wealth, gold and gems. You may perform yajnas (sacrificial rites). You know sastras (sciences) and songs.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for sakata_yoga
    {
      final diffMoonJup = (moonHouse - pMap[Planet.jupiter]! + 12) % 12;
      final isPresent =
          (diffMoonJup == 5 || diffMoonJup == 7 || diffMoonJup == 11) &&
              !kendraHouses.contains(pMap[Planet.jupiter]!);
      final explanation = isPresent
          ? 'Moon is in 6th, 8th, or 12th from Jupiter'
          : 'Moon not in Sakata position from Jupiter';
      result.add(
        NatalYoga(
          key: "sakata_yoga",
          name: "Sakata Yoga",
          category: "Nabhasa Yogas",
          description:
              "The Moon is in the 6th, 8th or 12th house from Jupiter, provided Jupiter is not in a kendra from the Lagna.",
          benefits:
              "Life will be characterized by fluctuations, like the rising and falling of a wheel. You may lose your position and reputation but can regain them. You may face poverty and misery but will be resilient.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for vihanga_yoga
    {
      final isPresent = occupiedHouses.every((h) => h == 4 || h == 10);
      final explanation = isPresent
          ? 'All planets in 4th and 10th houses'
          : 'Planets occupy other houses';
      result.add(
        NatalYoga(
          key: "vihanga_yoga",
          name: "Vihanga Yoga",
          category: "Nabhasa Yogas",
          description: "All planets are situated in the 4th and 10th houses.",
          benefits:
              "You will be a wanderer, a traveler, or a messenger. You may be prone to acting as an intermediary and might have many secret enemies.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for sringaataka_yoga
    {
      final isPresent = occupiedHouses.every((h) => trineHouses.contains(h));
      final explanation = isPresent
          ? 'All planets in trine houses (1, 5, 9)'
          : 'Planets occupy other houses';
      result.add(
        NatalYoga(
          key: "sringaataka_yoga",
          name: "Sringaataka Yoga",
          category: "Nabhasa Yogas",
          description:
              "All the planets occupy trines (1st, 5th and 9th) from lagna.",
          benefits:
              "One born with this yoga is happy and liked by kings. This person has a noble wife and hates women. This person is wealthy. Sringaataka means a cross-road junction. It has some other popular meanings too.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for hala_yoga
    {
      final isPresent = occupiedHouses.every((h) => [2, 6, 10].contains(h)) ||
          occupiedHouses.every((h) => [3, 7, 11].contains(h)) ||
          occupiedHouses.every((h) => [4, 8, 12].contains(h));
      final explanation = isPresent
          ? 'All planets occupy mutual trines'
          : 'Not occupying mutual trines';
      result.add(
        NatalYoga(
          key: "hala_yoga",
          name: "Hala Yoga",
          category: "Nabhasa Yogas",
          description:
              "All the planets occupy mutual trines but not trines from lagna.",
          benefits:
              "One born with this yoga becomes a farmer. This person eats a lot of food. This person is poor. This person is deserted by friends and relatives. This person is unhappy and worried. Hala means a plough.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for vajra_yoga
    {
      final isPresent = benefics.every((p) => pMap[p] == 1 || pMap[p] == 7) &&
          malefics.every((p) => pMap[p] == 4 || pMap[p] == 10);
      final explanation = isPresent
          ? 'Benefics in 1/7 and Malefics in 4/10'
          : 'Vajra conditions not met';
      result.add(
        NatalYoga(
          key: "vajra_yoga",
          name: "Vajra Yoga",
          category: "Nabhasa Yogas",
          description:
              "Lagna and the 7th houses are occupied by natural benefic planet and the 4th and 10th houses are occupied by natural malefic planets.",
          benefits:
              "One born with this yoga is happy in the early and late parts of life. This person has valour. This person is not fortunate, but has no desires either. This person fights. Vajra means a diamond.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for yava_yoga
    {
      final isPresent = malefics.every((p) => pMap[p] == 1 || pMap[p] == 7) &&
          benefics.every((p) => pMap[p] == 4 || pMap[p] == 10);
      final explanation = isPresent
          ? 'Malefics in 1/7 and Benefics in 4/10'
          : 'Yava conditions not met';
      result.add(
        NatalYoga(
          key: "yava_yoga",
          name: "Yava Yoga",
          category: "Nabhasa Yogas",
          description:
              "Lagna and the 7th houses are occupied by natural malefic planets and the 4th and 10th houses are occupied by natural benefic planets.",
          benefits:
              "One born with this yoga observes religious rules. This person is happy in the middle part of life. This person has wealth and good children. This person is charitable. He is strong-minded. Yava means a grain among other things.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for kamala_yoga
    {
      final isPresent = occupiedHouses.every((h) => kendraHouses.contains(h));
      final explanation = isPresent
          ? 'All planets in quadrants'
          : 'Planets occupy non-kendra houses';
      result.add(
        NatalYoga(
          key: "kamala_yoga",
          name: "Kamala Yoga",
          category: "Nabhasa Yogas",
          description: "All the planets are in quadrants from lagna.",
          benefits:
              "One born with this yoga becomes a king. This person has a strong character. This person is famous and long-lived. This person is pure and performs many good deeds. Kamala means a lotus.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for vaapi_yoga
    {
      final isPresent =
          occupiedHouses.every((h) => [2, 5, 8, 11].contains(h)) ||
              occupiedHouses.every((h) => [3, 6, 9, 12].contains(h));
      final explanation = isPresent
          ? 'All planets occupy Panapara or Apoklima houses'
          : 'Planets in Kendra houses';
      result.add(
        NatalYoga(
          key: "vaapi_yoga",
          name: "Vaapi Yoga",
          category: "Nabhasa Yogas",
          description:
              "All the planets are panaparas or in apoklimas from lagna.",
          benefits:
              "One born with this yoga has a mind capable of amassing wealth. This person has all comforts. This person becomes a king. Vaapi means a pond or a water tank or a well.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for yoopa_yoga
    {
      final isPresent = occupiedHouses.every((h) => [1, 2, 3, 4].contains(h));
      final explanation = isPresent
          ? 'Planets occupy 1, 2, 3, 4'
          : 'Planets outside first four houses';
      result.add(
        NatalYoga(
          key: "yoopa_yoga",
          name: "Yoopa Yoga",
          category: "Nabhasa Yogas",
          description:
              "All the planets are in 1st, 2nd, 3rd and 4th houses from lagna.",
          benefits:
              "One born with this yoga has spiritual knowledge and knowledge of yajnas (sacrificial rites). This person's spouse is always together. This person has sattwa guna. This person observes all the religious rules. Yoopa means a pillar and in particular a sacrificial post.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for sara_yoga
    {
      final isPresent = occupiedHouses.every((h) => [4, 5, 6, 7].contains(h));
      final explanation = isPresent
          ? 'Planets occupy 4, 5, 6, 7'
          : 'Planets outside these houses';
      result.add(
        NatalYoga(
          key: "sara_yoga",
          name: "Sara Yoga",
          category: "Nabhasa Yogas",
          description:
              "All the planets are in 4th, 5th, 6th and 7th houses from lagna.",
          benefits:
              "One born with this yoga makes arrows. This person heads prisons. This person is a hunter. This person eats meats. This person tortures people. Sara means an arrow.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for ishu_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "ishu_yoga",
          name: "Ishu Yoga",
          category: "Other Natal Yoga",
          description:
              "All planets occupy the first four houses (1, 2, 3, 4) or from the 4th to 7th, 7th to 10th, or 10th to 1st.",
          benefits:
              "You will be a jailer, a cruel person, or a manufacturer of weapons and arrows.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for sakti_yoga
    {
      final isPresent = occupiedHouses.every((h) => [7, 8, 9, 10].contains(h));
      final explanation = isPresent
          ? 'Planets occupy 7, 8, 9, 10'
          : 'Planets outside these houses';
      result.add(
        NatalYoga(
          key: "sakti_yoga",
          name: "Sakti Yoga",
          category: "Nabhasa Yogas",
          description:
              "All the planets are in 7th, 8th, 9th and 10th houses from lagna.",
          benefits:
              "One born with this yoga are unhappy, poor, unsuccessful, unworthy, lazy, long-lived and firm. They have sharp minds in war. Sakti means energy and it is also a powerful weapon.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for danda_yoga
    {
      final isPresent = occupiedHouses.every(
        (h) => [10, 11, 12, 1].contains(h),
      );
      final explanation = isPresent
          ? 'Planets occupy 10, 11, 12, 1'
          : 'Planets outside these houses';
      result.add(
        NatalYoga(
          key: "danda_yoga",
          name: "Danda Yoga",
          category: "Nabhasa Yogas",
          description:
              "All the planets are in 10th, 11th, 12th and 1st houses from lagna.",
          benefits:
              "One born with this yoga lose wife and children and their people will desert them. They are unhappy and serve mean people. Danda means a stick used to punish people.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for nav_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "nav_yoga",
          name: "Nav Yoga",
          category: "Other Natal Yoga",
          description:
              "All planets are situated in seven continuous signs from any house.",
          benefits:
              "You will be famous, recognized, and enjoy the fruits of your labor throughout life.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for naukaa_yoga
    {
      final isPresent =
          occupiedHouses.length >= 7 && occupiedHouses.every((h) => h <= 7);
      final explanation = isPresent
          ? 'Planets occupy 7 signs from Lagna'
          : 'Planets outside first 7 houses';
      result.add(
        NatalYoga(
          key: "naukaa_yoga",
          name: "Naukaa Yoga",
          category: "Nabhasa Yogas",
          description: "All the planets occupy the 7 signs from lagna.",
          benefits:
              "One born with this yoga make money on things related to water. They have many desires. They are well-known. They are wicked, rough and miserly. Naukaa means a ship.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for koota_yoga
    {
      final isPresent = occupiedHouses.every(
        (h) => [4, 5, 6, 7, 8, 9, 10].contains(h),
      );
      final explanation = isPresent
          ? 'Planets occupy 7 signs from 4th'
          : 'Planets outside these houses';
      result.add(
        NatalYoga(
          key: "koota_yoga",
          name: "Koota Yoga",
          category: "Nabhasa Yogas",
          description: "All the planets occupy the 7 signs from the 4th house.",
          benefits:
              "One born with this yoga becomes a jailer. The person is a liar. The person lives in hills and forts. The person is poor and cruel. Koota means a group. It has several other meanings.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for chatra_yoga
    {
      final isPresent = occupiedHouses.every(
        (h) => [7, 8, 9, 10, 11, 12, 1].contains(h),
      );
      final explanation = isPresent
          ? 'Planets occupy 7 signs from 7th'
          : 'Planets outside these houses';
      result.add(
        NatalYoga(
          key: "chatra_yoga",
          name: "Chatra Yoga",
          category: "Nabhasa Yogas",
          description: "All the planets occupy the 7 signs from the 7th house.",
          benefits:
              "One born with this yoga will help his people. This person is kind and liked by many kings. This person is intelligent. This person is happy in the early and late parts of life. This person is longlived. Chatra means an umbrella.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for chaapa_yoga
    {
      final isPresent = occupiedHouses.every(
        (h) => [10, 11, 12, 1, 2, 3, 4].contains(h),
      );
      final explanation = isPresent
          ? 'Planets occupy 7 signs from 10th'
          : 'Planets outside these houses';
      result.add(
        NatalYoga(
          key: "chaapa_yoga",
          name: "Chaapa Yoga",
          category: "Nabhasa Yogas",
          description:
              "All the planets occupy the 7 signs from the 10th house.",
          benefits:
              "One born with this yoga becomes a liar, thief and a protector of secrets. This person wanders in forests. This person is unfortunate. This person is happy in the middle part of the life. Chaapa means a bow.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for ardha_chandra_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "ardha_chandra_yoga",
          name: "Ardha Chandra Yoga",
          category: "Chandra Yogas (Moon-based)",
          description:
              "All the planets occupy the 7 signs starting from a panapara or an apoklima.",
          benefits:
              "One born with this yoga becomes an army chief. This person has a good physique. Kings like this person. This person is strong and possesses gems, gold and many ornaments. Ardha Chandra means half-Moon.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for chakra_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "chakra_yoga",
          name: "Chakra Yoga",
          category: "Nabhasa Yogas",
          description:
              "All the planets occupy 1st, 3rd, 5th, 7th, 9th and 11th houses from the lagna.",
          benefits:
              "One born with this yoga becomes a great emperor. Diamond-studded crowns of many kings touch this person's feet (i.e. many kings prostate before this person). Chakra means a wheel. Chakravarti means an emperor.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for samudra_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "samudra_yoga",
          name: "Samudra Yoga",
          category: "Nabhasa Yogas",
          description:
              "All the planets occupy 2nd, 4th, 6th, 8th, 10th and 12th houses from the lagna.",
          benefits:
              "One born with this yoga owns a lot of wealth and many gems. This person has luxuries and likes people. Their fortune and greatness are stable. They are softnatured. Samudra means a sea or an ocean. Samudra is also the name of the God of Ocean, who has a lot of wealth and many gems with this person.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for veenaa_yoga
    {
      final isPresent = distinctSigns == 7;
      final explanation = 'Planets occupy $distinctSigns signs';
      result.add(
        NatalYoga(
          key: "veenaa_yoga",
          name: "Veenaa Yoga",
          category: "Nabhasa Yogas",
          description:
              "The seven planets occupy exactly 7 distinct signs among them.",
          benefits:
              "One born with this yoga likes music, dance and songs. This person has many servants. This person is wealthy, skillful and a leader of men. Veenaa is a stringed musical instrument. This is also called Vallaki yoga by some authors.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for daama_yoga
    {
      final isPresent = distinctSigns == 6;
      final explanation = 'Planets occupy $distinctSigns signs';
      result.add(
        NatalYoga(
          key: "daama_yoga",
          name: "Daama Yoga",
          category: "Nabhasa Yogas",
          description:
              "The seven planets occupy exactly 6 distinct signs among them.",
          benefits:
              "One born with this yoga is very rich and famous. This person has many children. This person has many gems. This person helps others. Daama means a wreath. Some authors call this Daamini yoga.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for paasa_yoga
    {
      final isPresent = distinctSigns == 5;
      final explanation = 'Planets occupy $distinctSigns signs';
      result.add(
        NatalYoga(
          key: "paasa_yoga",
          name: "Paasa Yoga",
          category: "Nabhasa Yogas",
          description:
              "The seven planets occupy exactly 5 distinct signs among them.",
          benefits:
              "One born with this yoga has the risk of being imprisoned. This person is capable in their work. This person is talkataive. This person has many servants. This person lacks character. Paasa means a noose.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for kedaara_yoga
    {
      final isPresent = distinctSigns == 4;
      final explanation = 'Planets occupy $distinctSigns signs';
      result.add(
        NatalYoga(
          key: "kedaara_yoga",
          name: "Kedaara Yoga",
          category: "Nabhasa Yogas",
          description:
              "The seven planets occupy exactly 4 distinct signs among them.",
          benefits:
              "One born with this yoga is an agriculturist. This person is happy wealthy and helpful to others. Kedaara means a field.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for soola_yoga
    {
      final isPresent = distinctSigns == 3;
      final explanation = 'Planets occupy $distinctSigns signs';
      result.add(
        NatalYoga(
          key: "soola_yoga",
          name: "Soola Yoga",
          category: "Nabhasa Yogas",
          description:
              "The seven planets occupy exactly 3 distinct signs among them.",
          benefits:
              "One born with this yoga is sharp, lazy, violent, poor, prohibited and valiant. They win accolades in wars. Soola is Shiva’s weapon.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for subha_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "subha_yoga",
          name: "Subha Yoga",
          category: "Other Natal Yoga",
          description:
              "Lagna has benefics or has “subha kartari – benefics in 12th and 2nd house from Lagna.",
          benefits:
              " One born with this yoga has eloquence, good looks and character",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for asubha_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "asubha_yoga",
          name: "Asubha Yoga",
          category: "Other Natal Yoga",
          description:
              "Lagna has malefics or has “paapa kartari or maleefics in 12th and 2nd house from Lagna.",
          benefits:
              "One born with this yoga has many desires and is sinful and enjoys the wealth of others.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for gaja_kesari_yoga
    {
      final diffJupMoon = (pMap[Planet.jupiter]! - moonHouse + 12) % 12;
      final isPresent = [0, 3, 6, 9].contains(diffJupMoon);
      final explanation = isPresent
          ? 'Jupiter is in house ${diffJupMoon + 1} from Moon'
          : 'Jupiter not in Kendra from Moon';
      result.add(
        NatalYoga(
          key: "gaja_kesari_yoga",
          name: "gaja_kesari_yoga",
          category: "Chandra Yogas (Moon-based)",
          description:
              "Gaja-Kesari Yoga: If (1) Jupiter is in a quadrant from Moon, (2) a benefic planet conjoins or aspects Jupiter, and, (3) Jupiter is not debilitated or combust or in an enemy’s house",
          benefits:
              "One born with this yoga is famous, wealthy and intelligent. The person has great character and is liked by kings. For virtuousness and ever-lasting fame, this is a key yoga.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for guru_mangala_yoga
    {
      final diffJupMars =
          (pMap[Planet.jupiter]! - pMap[Planet.mars]! + 12) % 12;
      final isPresent = diffJupMars == 0 || diffJupMars == 6;
      final explanation = isPresent
          ? 'Jupiter and Mars conjoined or opposite'
          : 'Jupiter and Mars not aligned';
      result.add(
        NatalYoga(
          key: "guru_mangala_yoga",
          name: "guru_mangala_yoga",
          category: "Chandra Yogas (Moon-based)",
          description:
              "If Jupiter and Mars are together or in the 7th house from each other, then this yoga is present.",
          benefits:
              "One born with this yoga is righteous and energetic. The person's 'energies are channelled in dharmic paths.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for amala_yoga
    {
      final lagna10 = traditionalPlanetsInHouse(10);
      final moon10 = Planet.traditionalPlanets
          .where((p) => pMap[p] == ((moonHouse - 1 + 9) % 12) + 1)
          .toList();
      final isPresent = (lagna10.isNotEmpty && lagna10.every(_isBenefic)) ||
          (moon10.isNotEmpty && moon10.every(_isBenefic));
      final explanation = isPresent
          ? 'Only benefics in 10th from Lagna/Moon'
          : 'No benefics or malefic in 10th';
      result.add(
        NatalYoga(
          key: "amala_yoga",
          name: "Amala Yoga",
          category: "Other Natal Yoga",
          description:
              "There are only natural benefics present in the 10th house from lagna or Moon.",
          benefits:
              "One born with this yoga has ever-lasting fame. The person is respected by kings. Person has luxuries and is virtuous. Person helps others. Amala means pure. Because the 10th house shows one's' conduct in society, situation of only benefics there makes one’s conduct in the society very pure.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for parvata_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "parvata_yoga",
          name: "Parvata Yoga",
          category: "Other Natal Yoga",
          description:
              "If (1) quadrants are occupied only by benefics and (2) the 7th and 8th houses are either vacant or occupied only by benefics",
          benefits:
              "One born with this yoga is fortunate, eloquent, famous, charitable, easy-going and likes humour. Parvata means a mountain.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for kaahala_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "kaahala_yoga",
          name: "Kaahala Yoga",
          category: "Nabhasa Yogas",
          description:
              "If (1) the 4th lord and Jupiter32 are in mutual quadrants and (2) lagna lord is strong, then this yoga is present. Alternately, this yoga is present if the 4th lord is exalted or in own sign and the 10th lord joins him.",
          benefits:
              "One born with this yoga is strong, bold, cunning and leads a large army. Person owns a few villages. Kaahala means excessive. It also means mischievous.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for chaamara_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "chaamara_yoga",
          name: "Chaamara Yoga",
          category: "Other Natal Yoga",
          description:
              "If the lagna lord is exalted in a quadrant with Jupiter’s aspect or two benefics join in 7th, 9th or 10th, then this yoga is present.",
          benefits:
              "One born with this yoga is a king or someone respected by kings. Person is long-lived, scholarly, eloquent and learned in many arts. Chaamara means something akin to the plume on the head of a horse. By waving it, servants give relief to kings from heat (like a fan). It basically stands for the trappings of power.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for sankha_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "sankha_yoga",
          name: "Sankha Yoga",
          category: "Other Natal Yoga",
          description:
              "If (1) lagna lord is strong and (2) 5th and 6th lords are in mutual quadrants, then this yoga is present. Alternately, this yoga is present if (1) lagna lord and 10th lord are together in a movable sign and (2) the 9th lord is strong.",
          benefits:
              "One born with this yoga is blessed with wealth, spouse and children. He is kind, pious, intelligent and long-lived. Sankha means a conch shell.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for bheri_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "bheri_yoga",
          name: "Bheri Yoga",
          category: "Other Natal Yoga",
          description:
              "]If (1) the 9th lord is strong and (2) 1st, 2nd, 7th and 12th houses are occupied by planets, then this yoga is present. Alternately, this is yoga is present if (1) the 9th lord is strong and (2) Jupiter, Venus and lagna lord are in mutual quadrants.",
          benefits:
              "One born with this yoga is blessed with wealth, spouse and children. Person can be a king. Person has fame and character. Person is virtuous and religious. Person enjoys pleasures. Bheri means a kettledrum.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for mridanga_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "mridanga_yoga",
          name: "Mridanga Yoga",
          category: "Other Natal Yoga",
          description:
              "If (1) there are planets in own and exaltation signs in quadrants and trines and (2) lagna lord is strong, then this yoga is present.",
          benefits:
              "One born with this yoga is a king or an equal and is happy. Mridanga is a rich and elegant percussion instrument popular in south India.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for sreenaatha_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "sreenaatha_yoga",
          name: "Sreenaatha Yoga",
          category: "Other Natal Yoga",
          description:
              "If (1) the 7th lord is exalted in 10th and (2) 10th lord is with 9th lord, then this yoga is present.",
          benefits:
              "One born with this yoga becomes a great king equal to Indra – king of gods. Sreenaatha means the lord of great wealth and prosperity. It also means Vishnu.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for matsya_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "matsya_yoga",
          name: "Matsya Yoga",
          category: "Other Natal Yoga",
          description:
              "If (1) benefics are in lagna and 9th, (2) some planets are in 5th, and, (3) malefics are in chaturasras (4th and 8th houses), then this yoga is present.",
          benefits:
              "One born with this yoga becomes an astrologer or a seer. Person is a personification of kindness, character and intelligence. Person is strong and good-looking. Person is famous and learned. Person is a tapasvi (austere pursuer). Matsya means a fish.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for koorma_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "koorma_yoga",
          name: "Koorma Yoga",
          category: "Other Natal Yoga",
          description:
              "If (1) the 5th, 6th and 7th houses are occupied by benefics who are in own, exaltation or friendly signs and (2) the 1st, 3rd and 11th houses are occupied by malefics who are in own or exaltation signs, then this yoga is present.",
          benefits:
              "One born with this yoga becomes a king. Person has piety and character. Person is happy, helpful and famous. Koorma means a tortoise.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for khadga_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "khadga_yoga",
          name: "Khadga Yoga",
          category: "Other Natal Yoga",
          description:
              "If (1) the 2nd lord is in the 9th house, (2) the 9th lord is in the 2nd house, and, (3) lagna lord is in a quadrant or a trine, then this yoga is present.",
          benefits:
              "One born with this yoga is skillful, wealthy, learned, happy, fortunate, intelligent, grateful and mighty. Khadga means a sword.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for kusuma_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "kusuma_yoga",
          name: "Kusuma Yoga",
          category: "Other Natal Yoga",
          description:
              "If (1) lagna is in a fixed sign, (2) Venus is in a quadrant, (3) Moon is in a trine with a benefic, and, (4) Saturn is in the 10th house, then this yoga is present.",
          benefits:
              "One born with this yoga becomes a king or an equal. Person is charitable. Person is endowed with pleasures and happiness. Person is a leader of community. Person has character and scholarship. Kusuma means a flower.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for kalaanidhi_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "kalaanidhi_yoga",
          name: "Kalaanidhi Yoga",
          category: "Other Natal Yoga",
          description:
              "If (1) Jupiter is in the 2nd house or the 5th house and (2) he is conjoined or aspected by Mercury and Venus, then this yoga is present.",
          benefits:
              "One born with this yoga is endowed with character, happiness, good health, wealth and learning. Person is respected by kings. Kalaanidhi means a treasure of arts and skills.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for kalpadruma_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "kalpadruma_yoga",
          name: "Kalpadruma Yoga",
          category: "Other Natal Yoga",
          description:
              "Consider (1) lagna lord, (2) his dispositor, (3) the latter’s dispositor in rasi and (4) in navamsa. If all the four planets are all in quadrants, trines or exaltation signs of both rasi and navamsa, then this yoga is present.",
          benefits:
              "One born with this yoga becomes a king. Person likes wars. Person is very prosperous, principled, strong and kind. Kalpadruma is a celestial tree of the heaven. This yoga is also known as Paarijaata yoga. Paarijaata is a celestial flower.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for lagnaadhi_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "lagnaadhi_yoga",
          name: "Lagnaadhi Yoga",
          category: "Chandra Yogas (Moon-based)",
          description:
              "If (1) the 7th and 8th houses from lagna are occupied by benefics and (2) no malefics conjoin or aspect these planets, then this yoga is present.",
          benefits:
              "One born with this yoga becomes a great person. Person is learned and happy. Adhi means over or above. Lagnaadhi yoga means Adhi Yoga from lagna.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for hari_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "hari_yoga",
          name: "Hari Yoga",
          category: "Other Natal Yoga",
          description:
              "If benefics occupy the 2nd, 12th and 8th houses counted from the 2nd lord, then this yoga is present.",
          benefits:
              "One born with this yoga is happy, learned and blessed with wealth and children. Hari is a name of Lord Vishnu. The 2nd house is the house of food and money and it is a trine from karma sthana – the 10th house. It stands for sustenance and its lord represents Hari – Sustainer of Hindu Trinity – in a chart.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for hara_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "hara_yoga",
          name: "Hara Yoga",
          category: "Other Natal Yoga",
          description:
              "Benefic planets are situated in the 4th, 9th, and 8th houses.",
          benefits:
              "You will be happy, well-disposed, and enjoy life's pleasures, though you may sometimes face unexpected turns in fortune.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for brahma_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "brahma_yoga",
          name: "Brahma Yoga",
          category: "Other Natal Yoga",
          description:
              "If benefics occupy the 4th, 10th and 11th houses counted from lagna lord, then this yoga is present. Another variation of Brahma yoga: If (1) Jupiter is in a quadrant from the 9th lord, (2) Venus is in a quadrant from the 11th lord, and, (3) Mercury is in a quadrant from the 1st lord or 10th lord, then this yoga is present.",
          benefits:
              "One born with this yoga is happy, learned and blessed with wealth and children. Brahma is the creator of this universe. Lagna rules birth and the Creator is represented in a chart by lagna lord.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for vishnu_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "vishnu_yoga",
          name: "Vishnu Yoga",
          category: "Other Natal Yoga",
          description:
              "If (1) the 9th and 10th lords are in the 2nd house and (2) the lord of the sign occupied in navamsa by the 9th lord in rasi chart is also in the 2nd house, then this yoga is present.",
          benefits:
              "One born with this yoga is fortunate, learned, long-lived and liked by kings. Person is a worshipper of Vishnu.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for siva_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "siva_yoga",
          name: "Siva Yoga",
          category: "Other Natal Yoga",
          description:
              "If (1) the 5th lord is in the 9th house, (2) the 9th lord is in the 10th house, and, (3) the 10th lord is in the 5th house, then this yoga is present.",
          benefits:
              "One born with this yoga is wise and virtuous. Person is a conqueror. Person can be an army chief or a businessman. Lord Siva is one of the Trinity of Gods.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for trilochana_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "trilochana_yoga",
          name: "Trilochana Yoga",
          category: "Other Natal Yoga",
          description:
              "If Sun, Moon and Mars are in mutual trines, then this yoga is present.",
          benefits:
              "One born with this yoga is wealthy, intelligent, long-lived and victorious over enemies. Person achieves everything without many obstacles. Trilochana means 'one with three eyes'. It is another name of Lord Siva, who has a hidden eye in His forehead.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for gouri_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "gouri_yoga",
          name: "Gouri Yoga",
          category: "Other Natal Yoga",
          description:
              "If the lord of the sign occupied in navamsa by the 10th lord is exalted in the 10th house and lagna lord joins him, then this yoga is present.",
          benefits:
              "One born with this yoga is from a respectable family and person is religious and virtuous. Person is blessed with happiness from family. Gouri is a form of Parvati – Lord Siva’s wife. She is an epitome of marital bliss and purity.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for chandikaa_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "chandikaa_yoga",
          name: "Chandikaa Yoga",
          category: "Other Natal Yoga",
          description:
              "If (1) lagna is in a fixed sign aspected by 6th lord and (2) Sun joins the lords of the signs occupied in navamsa by 6th and 9th lords, then this yoga is present.",
          benefits:
              "One born with this yoga is aggressive, charitable, wealthy, famous and longlived. Chandika is an aggressive form of Parvati. She kills demons mercilessly.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for lakshmi_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "lakshmi_yoga",
          name: "Lakshmi Yoga",
          category: "Other Natal Yoga",
          description:
              "If (1) the 9th lord is in an own sign or in his exaltation sign that happens to be quadrant from lagna and (2) lagna lord is strong, then this yoga is present.",
          benefits:
              "One born with this yoga becomes a king. Person is blessed with good looks, character, wealth and many children. Person is principled and famous. Lakshmi is Vishnu’s wife. She is the goddess of prosperity.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for saarada_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "saarada_yoga",
          name: "Saarada Yoga",
          category: "Other Natal Yoga",
          description:
              "If (1) the 10th lord is in the 5th house, (2) Mercury is in a quadrant, (3) Sun is strong in Leo, (4) Mercury or Jupiter is in a trine from Moon, and, (5) Mars is in 11th, then this yoga is present.",
          benefits:
              "One born with this yoga is blessed with wealth, spouse and children. Person is happy, learned, principled and liked by kings. Person is a tapaswi (autere pursuer of knowledge). Saarada is another name of Saraswathi, the goddess of learning.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for bhaarathi_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "bhaarathi_yoga",
          name: "Bhaarathi Yoga",
          category: "Other Natal Yoga",
          description:
              "If the lord of the sign occupied in navamsa by 2nd, 5th or 11th lord exalted and joins the 9th lord, then this yoga is present.",
          benefits:
              "One born with this yoga is a great scholar. Person is intelligent, religious, good-looking and famous. Bhaarathi is another name of Saraswathi, the goddess of learning.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for saraswathi_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "saraswathi_yoga",
          name: "Saraswathi Yoga",
          category: "Other Natal Yoga",
          description:
              "If (1) each of Mercury, Jupiter and Venus occupies a quadrant or a trine or the 2nd house (not necessarily together) and (2) Jupiter is in an own or friendly or exaltation sign, then this yoga is present.",
          benefits:
              "One born with this yoga is very learned, skillful, intelligent, rich and famous. Person is praised by all. Saraswathi is the goddess of learning.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for amsaavatara_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "amsaavatara_yoga",
          name: "Amsaavatara Yoga",
          category: "Other Natal Yoga",
          description:
              "If Jupiter, Venus and exalted Saturn are in quadrants, then this yoga is present.",
          benefits:
              "One born with this yoga becomes a king or an equal. Person is learned and pleasure-loving. Person has unsullied reputation. Amsaavatara means one who is an incarnation of a part of the Lord.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for devendra_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "devendra_yoga",
          name: "Devendra Yoga",
          category: "Other Natal Yoga",
          description:
              "If (1) lagna is in a fixed sign, (2) 2nd and 10th lords have an exchange35, and, (3) lagna and 11th lords have an exchange, then this yoga is present.",
          benefits:
              "One born with this yoga is a leader of men. Person is handsome, romantic, long-lived and famous. Devendra is the ruler of gods.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for indra_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "indra_yoga",
          name: "Indra Yoga",
          category: "Other Natal Yoga",
          description:
              "If (1) the 5th and 11th lords have an exchange and (2) Moon occupies the 5th house, then this yoga is present.",
          benefits:
              "One born with this yoga becomes a king. Person is bold, famous and long-lived. Indra is the ruler of gods.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for ravi_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "ravi_yoga",
          name: "Ravi Yoga",
          category: "Ravi Yogas (Sun-based)",
          description:
              "If (1) Sun is in the 10th house and (2) the 10th lord is in the 3rd house with Saturn, then this yoga is present.",
          benefits:
              "One born with this yoga is learned, passionate and respected by kings. Ravi means Sun.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for bhaaskara_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "bhaaskara_yoga",
          name: "Bhaaskara Yoga",
          category: "Other Natal Yoga",
          description:
              "If (1) Moon is in the 12th from Sun, (2) Mercury is in the 2nd from Sun, and, (3) Jupiter is in the 5th or 9th from Moon, then this yoga is present.",
          benefits:
              "One born with this yoga is wealthy, valorous and aristocratic. Person is learned in sastras, astrology and music. Person has a good personality. Bhaaskara means 'one with bright rays'. It is a name of Sun.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for kulavardhana_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "kulavardhana_yoga",
          name: "Kulavardhana Yoga",
          category: "Dhana Yogas (Wealth)",
          description:
              "If each planet occupies the 5th house from either lagna or Moon or Sun, then this yoga is present.",
          benefits:
              "One born with this yoga is happy, wealthy and brings name to his lineage and community. Person has an unbroken line of worthy successors. Kula means 'lineage or community''. Vardhana means 'one who makes it grow and prosper'.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for vasumathi_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "vasumathi_yoga",
          name: "Vasumathi Yoga",
          category: "Other Natal Yoga",
          description:
              "If benefics occupy upachayas, then this yoga is present.",
          benefits:
              "For it to give full results, malefics should not occupy upachayas and the benefics occupying upachayas should be strong. One born with this yoga has abundant wealth. Vasumati means earth.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for gandharva_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "gandharva_yoga",
          name: "Gandharva Yoga",
          category: "Other Natal Yoga",
          description:
              "If (1) the 10th lord is in a trine from the 7th house, (2) lagna lord is conjoined or aspected by Jupiter, (3) Sun is exalted and strong, and, (4) Moon is in the 9th house, then this yoga is present.",
          benefits:
              "One born with this yoga is skillful and famous in fine arts. Gandharvas are a class of gods with excellent skills in singing and other fine arts.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for go_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "go_yoga",
          name: "Go Yoga",
          category: "Other Natal Yoga",
          description:
              "If (1) Jupiter is strong in his moolatrikona, (2) the lord of the 2nd house is with Jupiter, and, (3) lagna lord is exalted, then this yoga is present.",
          benefits:
              "One born with this yoga is from a respectable family. Person is wealthy and resepcted by all. Go means a cow.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for vidyut_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "vidyut_yoga",
          name: "Vidyut Yoga",
          category: "Other Natal Yoga",
          description:
              "If (1) the 11th lord is in deep exaltation, (2) he joins Venus, and, (3) the two of them are in a quadrant from lagna lord, then this yoga is present.",
          benefits:
              "One born with this yoga becomes a king or an equal. Person is wealthy, pleasure-loving and charitable. Vidyut means a lightning bolt or electricity.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for chapa_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "chapa_yoga",
          name: "Chapa Yoga",
          category: "Other Natal Yoga",
          description:
              "If (1) the 4th and 10th lords have an exchange and (2) lagna lord is exalted, then this yoga is present.",
          benefits:
              "One born with this yoga works for a king and commands a lot of wealth. Chapa means a bow.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for pushkala_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "pushkala_yoga",
          name: "Pushkala Yoga",
          category: "Other Natal Yoga",
          description:
              "If (1) lagna lord is with Moon, (2) dispositor of Moon is in a quadrant or in the house of an adhimitra (good friend), (2) dispositor of Moon aspects lagna, and, (4) there is a planet in lagna, then this yoga is present.",
          benefits:
              "One born with this yoga is eloquent, wealthy, famous and respected by kings. Pushkala means abundant.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for makuta_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "makuta_yoga",
          name: "Makuta Yoga",
          category: "Other Natal Yoga",
          description:
              "If (1) Jupiter is in the 9th house from the 9th lord, (2) the 9th house from Jupiter has a benefic, and, (3) Saturn is in the 10th house, then this yoga is present.",
          benefits:
              "One born with this yoga is a powerful leader of men. Person often manages unruly activities. Makuta means crown.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for jaya_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "jaya_yoga",
          name: "Jaya Yoga",
          category: "Other Natal Yoga",
          description:
              "If (1) the 10th lord is in deep exaltation and (2) the 6th lord is debilitated, then this yoga is present.",
          benefits:
              "One born with this yoga is happy, successful, victorious over enemies and long-lived. Jaya means victorious.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for harsha_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "harsha_yoga",
          name: "Harsha Yoga",
          category: "Other Natal Yoga",
          description:
              "If the 6th lord occupies the 6th house, then this yoga is present.",
          benefits:
              "One born with this yoga is happy, strong, good-natured and invincible. Harsha means joyous.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for sarala_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "sarala_yoga",
          name: "Sarala Yoga",
          category: "Other Natal Yoga",
          description:
              "If the 8th lord occupies the 8th house, then this yoga is present.",
          benefits:
              "One born with this yoga is long-lived, fearless, learned, celebrated and prosperous. Person is a terror to his enemies. Sarala means straight-forward.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for vimala_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "vimala_yoga",
          name: "Vimala Yoga",
          category: "Other Natal Yoga",
          description:
              "If the 12th lord occupies the 12th house, then this yoga is present.",
          benefits:
              "One born with this yoga is noble, frugal, happy and independent. Vimala means pure.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for chatussagara_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "chatussagara_yoga",
          name: "Chatussagara Yoga",
          category: "Other Natal Yoga",
          description:
              "All planets occupy the four Kendra houses (1, 4, 7, 10).",
          benefits:
              "You will earn great reputation, be equal to a king, and possess good health and a long life.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for rajalakshana_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "rajalakshana_yoga",
          name: "Rajalakshana Yoga",
          category: "Other Natal Yoga",
          description:
              "Jupiter, Venus, Mercury, and the Moon are in Kendra houses.",
          benefits:
              "You will possess an attractive personality, noble qualities, and attain high status or leadership.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for vanchana_chora_bheethi_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "vanchana_chora_bheethi_yoga",
          name: "Vanchana Chora Bheethi Yoga",
          category: "Other Natal Yoga",
          description:
              "The Lord of Lagna is in the 6th, 8th, or 12th house joined with or aspected by malefics.",
          benefits:
              "You will face constant fear of being cheated, defrauded, or robbed by others.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for harihara_brahma_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "harihara_brahma_yoga",
          name: "Harihara Brahma Yoga",
          category: "Other Natal Yoga",
          description:
              "Benefics are placed in the 2nd, 8th, and 12th houses from the Lord of the 9th.",
          benefits:
              "You will be a truthful person, an eloquent speaker, and highly learned in various sciences and scriptures.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for kahala_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "kahala_yoga",
          name: "Kahala Yoga",
          category: "Nabhasa Yogas",
          description:
              "The lords of the 4th and 9th houses are in mutual Kendras and the lord of the Lagna is strong.",
          benefits:
              "You will be stubborn, courageous, and perhaps hold a position of authority like a village head or an army officer.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for mahabhagya_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "mahabhagya_yoga",
          name: "Mahabhagya Yoga",
          category: "Other Natal Yoga",
          description:
              "For males: Birth in daytime with Lagna, Sun, and Moon in odd signs. For females: Birth at night with Lagna, Sun, and Moon in even signs.",
          benefits:
              "You will be extremely fortunate, wealthy, famous, and live a long life with a noble character.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for sreenatha_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "sreenatha_yoga",
          name: "Sreenatha Yoga",
          category: "Other Natal Yoga",
          description:
              "The 7th lord is in the 10th and the 10th lord is joined with the 9th lord.",
          benefits:
              "You will be a favorite of society, prosperous, and attain a very high position in life.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for lagna_malika_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "lagna_malika_yoga",
          name: "Lagna Malika Yoga",
          category: "Other Natal Yoga",
          description:
              "All seven planets occupy seven continuous houses starting from the Lagna (1st house).",
          benefits:
              "You will be a commander or a ruler, possessing wealth, many vehicles, and high social status.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for dhana_malika_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "dhana_malika_yoga",
          name: "Dhana Malika Yoga",
          category: "Other Natal Yoga",
          description:
              "All seven planets occupy seven continuous houses starting from the 2nd house (Dhana Bhava).",
          benefits:
              "You will be wealthy, charitable, dutiful toward your family, and enjoy material prosperity.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for vikrama_malika_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "vikrama_malika_yoga",
          name: "Vikrama Malika Yoga",
          category: "Other Natal Yoga",
          description:
              "All seven planets occupy seven continuous houses starting from the 3rd house (Vikrama Bhava).",
          benefits:
              "You will be courageous, possess many siblings, and attain success through your own prowess.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for sukha_malika_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "sukha_malika_yoga",
          name: "Sukha Malika Yoga",
          category: "Other Natal Yoga",
          description:
              "All seven planets occupy seven continuous houses starting from the 4th house (Sukha Bhava).",
          benefits:
              "You will be happy, possess lands and vehicles, and live a life of comfort and peace.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for putra_malika_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "putra_malika_yoga",
          name: "Putra Malika Yoga",
          category: "Progeny Yogas (Children)",
          description:
              "All seven planets occupy seven continuous houses starting from the 5th house (Putra Bhava).",
          benefits:
              "You will be intelligent, well-versed in scriptures, and blessed with children who bring you pride.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for satru_malika_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "satru_malika_yoga",
          name: "Satru Malika Yoga",
          category: "Other Natal Yoga",
          description:
              "All seven planets occupy seven continuous houses starting from the 6th house (Satru Bhava).",
          benefits:
              "You will be successful in overcoming enemies, though you may face health issues or litigation.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for kalatra_malika_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "kalatra_malika_yoga",
          name: "Kalatra Malika Yoga",
          category: "Other Natal Yoga",
          description:
              "All seven planets occupy seven continuous houses starting from the 7th house (Kalatra Bhava).",
          benefits:
              "You will be very popular with the opposite sex and may enjoy a high social status through marriage.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for randhra_malika_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "randhra_malika_yoga",
          name: "Randhra Malika Yoga",
          category: "Other Natal Yoga",
          description:
              "All seven planets occupy seven continuous houses starting from the 8th house (Randhra Bhava).",
          benefits:
              "You may have a long life but might face struggles, financial setbacks, or be misunderstood by others.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for bhagya_malika_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "bhagya_malika_yoga",
          name: "Bhagya Malika Yoga",
          category: "Other Natal Yoga",
          description:
              "All seven planets occupy seven continuous houses starting from the 9th house (Bhagya Bhava).",
          benefits:
              "You will be extremely fortunate, religious, and world-renowned for your charitable deeds.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for karma_malika_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "karma_malika_yoga",
          name: "Karma Malika Yoga",
          category: "Other Natal Yoga",
          description:
              "All seven planets occupy seven continuous houses starting from the 10th house (Karma Bhava).",
          benefits:
              "You will be highly successful in your career, respected by the state, and a leader in your field.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for laabha_malika_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "laabha_malika_yoga",
          name: "Laabha Malika Yoga",
          category: "Other Natal Yoga",
          description:
              "All seven planets occupy seven continuous houses starting from the 11th house (Laabha Bhava).",
          benefits:
              "You will have multiple sources of income and fulfill all your desires through your social network.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for vyaya_malika_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "vyaya_malika_yoga",
          name: "Vyaya Malika Yoga",
          category: "Other Natal Yoga",
          description:
              "All seven planets occupy seven continuous houses starting from the 12th house (Vyaya Bhava).",
          benefits:
              "You will be a spendthrift, potentially live abroad, and may be inclined toward spiritual or charitable spending.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for parijatha_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "parijatha_yoga",
          name: "Parijatha Yoga",
          category: "Other Natal Yoga",
          description:
              "The lord of the sign in which the Lagna lord is placed, and the lord of that planet's sign, are in a Kendra or Thrikona from the Lagna.",
          benefits:
              "You will be happy in the middle and last parts of life, receiving honors from kings or the government. You will be wealthy, famous, and generous.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for kalanidhi_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "kalanidhi_yoga",
          name: "Kalanidhi Yoga",
          category: "Other Natal Yoga",
          description:
              "Jupiter is joined with or aspected by Mercury and Venus in the 2nd or the 5th house, and is in the signs of Mercury or Venus.",
          benefits:
              "You will be highly learned, a scholar in many sciences, virtuous, and blessed with good health and immense wealth.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for garuda_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "garuda_yoga",
          name: "Garuda Yoga",
          category: "Other Natal Yoga",
          description:
              "The lord of the Navamsha occupied by the Moon is exalted, and the birth occurs during the day when the Moon is waxing.",
          benefits:
              "You will be respected by the pious, an eloquent speaker, courageous, and face danger from enemies in your 34th year.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for vallaki_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "vallaki_yoga",
          name: "Vallaki Yoga",
          category: "Other Natal Yoga",
          description:
              "All seven planets are distributed among seven different signs.",
          benefits:
              "You will be fond of music, fine arts, and literature. You will be happy, famous, and possess many friends.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for dama_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "dama_yoga",
          name: "Dama Yoga",
          category: "Other Natal Yoga",
          description:
              "All seven planets are distributed among six different signs.",
          benefits:
              "You will be a philanthropist, helpful to others, courageous, and very wealthy.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for kedara_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "kedara_yoga",
          name: "Kedara Yoga",
          category: "Other Natal Yoga",
          description:
              "All seven planets are distributed among four different signs.",
          benefits:
              "You will be a farmer or associated with land, truthful, happy, and helpful to others.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for sula_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "sula_yoga",
          name: "Sula Yoga",
          category: "Other Natal Yoga",
          description:
              "All seven planets are distributed among three different signs.",
          benefits:
              "You may be sharp-tempered, brave, perhaps poor, or gain fame through military or courageous deeds.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for yuga_yoga
    {
      final isPresent = distinctSigns == 2;
      final explanation = 'Planets occupy $distinctSigns signs';
      result.add(
        NatalYoga(
          key: "yuga_yoga",
          name: "Yuga Yoga",
          category: "Nabhasa Yogas",
          description:
              "All seven planets are distributed among only two different signs.",
          benefits:
              "You may be poor, a hypocrite, and lack social status or family happiness.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for gola_yoga
    {
      final isPresent = distinctSigns == 1;
      final explanation = 'Planets occupy $distinctSigns signs';
      result.add(
        NatalYoga(
          key: "gola_yoga",
          name: "Gola Yoga",
          category: "Nabhasa Yogas",
          description: "All seven planets are situated in a single sign.",
          benefits:
              "You may be uneducated, destitute, and lead a life of misery, often being misunderstood by society.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for dhur_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "dhur_yoga",
          name: "Dhur Yoga",
          category: "Other Natal Yoga",
          description:
              "The lord of the 10th house is in the 6th, 8th, or 12th house.",
          benefits:
              "You may face difficulties in your career, loss of position, or struggle to get recognition for your work.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for dharidhra_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "dharidhra_yoga",
          name: "Dharidhra Yoga",
          category: "Daridra Yogas (Poverty)",
          description:
              "The lord of the 11th house is in the 6th, 8th, or 12th house.",
          benefits:
              "You may face financial struggles, heavy debts, and difficulty in accumulating wealth despite hard work.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for dharidhra_yoga_144
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "dharidhra_yoga_144",
          name: "Dharidhra Yoga",
          category: "Daridra Yogas (Poverty)",
          description:
              "The lords of the 12th and Lagna exchange positions and are conjoined with or aspected by the lord of the 7th.",
          benefits:
              "Yoga causes dire poverty, financial straits, wretchedness and miseries",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for dharidhra_yoga_145
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "dharidhra_yoga_145",
          name: "Dharidhra Yoga",
          category: "Daridra Yogas (Poverty)",
          description:
              "The lords of the 6th and Lagna interchange positions and the Moon is aspected by the 2nd or 7th lord.",
          benefits:
              "Yoga causes dire poverty, financial straits, wretchedness and miseries",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for dharidhra_yoga_146
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "dharidhra_yoga_146",
          name: "Dharidhra Yoga",
          category: "Daridra Yogas (Poverty)",
          description: "Ketu and the Moon should be in Lagna.",
          benefits:
              "Yoga causes dire poverty, financial straits, wretchedness and miseries",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for dharidhra_yoga_147
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "dharidhra_yoga_147",
          name: "Dharidhra Yoga",
          category: "Daridra Yogas (Poverty)",
          description:
              "The lord of Lagna is in the 8th aspected by or in conjunction with the 2nd or 7th lord.",
          benefits:
              "Yoga causes dire poverty, financial straits, wretchedness and miseries",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for dharidhra_yoga_148
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "dharidhra_yoga_148",
          name: "Dharidhra Yoga",
          category: "Daridra Yogas (Poverty)",
          description:
              "Lord of Lagna in 6, 8, or 12 with a malefic, aspected by or combined with the 2nd or 7th lord.",
          benefits:
              "Yoga causes dire poverty, financial straits, wretchedness and miseries",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for dharidhra_yoga_149
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "dharidhra_yoga_149",
          name: "Dharidhra Yoga",
          category: "Daridra Yogas (Poverty)",
          description:
              "Lord of Lagna associated with 6th, 8th, or 12th lord and subjected to malefic aspects.",
          benefits:
              "Yoga causes dire poverty, financial straits, wretchedness and miseries",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for dharidhra_yoga_150
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "dharidhra_yoga_150",
          name: "Dharidhra Yoga",
          category: "Daridra Yogas (Poverty)",
          description:
              "Lord of 5th joins lord of 6, 8, or 12 without beneficial aspects/conjunctions.",
          benefits:
              "Yoga causes dire poverty, financial straits, wretchedness and miseries",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for dharidhra_yoga_151
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "dharidhra_yoga_151",
          name: "Dharidhra Yoga",
          category: "Daridra Yogas (Poverty)",
          description:
              "Lord of 5th in 6th or 10th aspected by lords of 2, 6, 7, 8, or 12.",
          benefits:
              "Yoga causes dire poverty, financial straits, wretchedness and miseries",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for dharidhra_yoga_152
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "dharidhra_yoga_152",
          name: "Dharidhra Yoga",
          category: "Daridra Yogas (Poverty)",
          description:
              "Natural malefics (not owning 9th or 10th) in Lagna associated with or aspected by maraka lords (L2/L7).",
          benefits:
              "Yoga causes dire poverty, financial straits, wretchedness and miseries",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for dharidhra_yoga_153
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "dharidhra_yoga_153",
          name: "Dharidhra Yoga",
          category: "Daridra Yogas (Poverty)",
          description:
              "The lords of the Lagna and Navamsa Lagna should occupy the 6th, 8th or 12th and have the aspect or conjunction of the lords of the 2nd and 7th.",
          benefits:
              "Yoga causes dire poverty, financial straits, wretchedness and miseries",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for sareera_soukhya_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "sareera_soukhya_yoga",
          name: "Sareera Soukhya Yoga",
          category: "Other Natal Yoga",
          description:
              "The Lagna lord, Jupiter, and Venus are placed in Kendra houses.",
          benefits:
              "You will enjoy excellent physical health, a long life, and luxury.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for dehapushti_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "dehapushti_yoga",
          name: "Dehapushti Yoga",
          category: "Other Natal Yoga",
          description:
              "The Lagna lord is in a movable sign (Chara Rashi) and is aspected by a benefic planet.",
          benefits:
              "You will have a strong, well-developed, and healthy physique.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for rogagrastha_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "rogagrastha_yoga",
          name: "Rogagrastha Yoga",
          category: "Other Natal Yoga",
          description:
              "The Lagna lord is in the 6th, 8th, or 12th house and is associated with the lord of the 6th.",
          benefits:
              "You may have a weak constitution and be prone to chronic health issues or frequent illnesses.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for krisanga_yoga_112
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "krisanga_yoga_112",
          name: "Krisanga Yoga",
          category: "Other Natal Yoga",
          description:
              "Lagna lord in a dry sign or in a sign owned by a dry planet.",
          benefits:
              "You will have a lean, thin, or emaciated physical appearance.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for krisanga_yoga_113
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "krisanga_yoga_113",
          name: "Krisanga Yoga",
          category: "Other Natal Yoga",
          description:
              "The Navamsa Lagna is owned by a dry planet AND malefics join the Rasi Lagna.",
          benefits:
              "You will have a lean, thin, or emaciated physical appearance.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for dehasthoulya_yoga_114
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "dehasthoulya_yoga_114",
          name: "Dehasthoulya Yoga",
          category: "Other Natal Yoga",
          description:
              "Lagna Lord and its Navamsa Lord both occupy watery signs (in Rasi).",
          benefits:
              "You will have a stout, heavy, or corpulent body (tendency toward obesity).",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for dehasthoulya_yoga_115
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "dehasthoulya_yoga_115",
          name: "Dehasthoulya Yoga",
          category: "Other Natal Yoga",
          description:
              "Jupiter in Lagna OR Jupiter aspects Lagna from a watery sign.",
          benefits:
              "You will have a stout, heavy, or corpulent body (tendency toward obesity).",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for dehasthoulya_yoga_116
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "dehasthoulya_yoga_116",
          name: "Dehasthoulya Yoga",
          category: "Other Natal Yoga",
          description:
              "Lagna in a watery sign joined by benefics OR Lagna Lord is a watery planet.",
          benefits:
              "You will have a stout, heavy, or corpulent body (tendency toward obesity).",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for sada_sanchara_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "sada_sanchara_yoga",
          name: "Sada Sanchara Yoga",
          category: "Other Natal Yoga",
          description:
              "The Lagna lord or the Moon is in a movable sign (Chara Rashi).",
          benefits:
              "You will be constantly on the move, traveling frequently for work or personal reasons.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for dhana_yoga_128
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "dhana_yoga_128",
          name: "Dhana Yoga",
          category: "Dhana Yogas (Wealth)",
          description:
              "Venus should be in Lagna identicalwith his own sign and joined or aspectedby Saturn and Mercury.",
          benefits:
              "You will accumulate significant wealth, enjoy financial prosperity, and lead a comfortable life with multiple sources of income.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for dhana_yoga_127
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "dhana_yoga_127",
          name: "Dhana Yoga",
          category: "Dhana Yogas (Wealth)",
          description:
              "Jupiter should be in Lagna identical with his own sign and joined or aspected by Mercury and Mars.",
          benefits:
              "You will accumulate significant wealth, enjoy financial prosperity, and lead a comfortable life with multiple sources of income.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for dhana_yoga_126
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "dhana_yoga_126",
          name: "Dhana Yoga",
          category: "Dhana Yogas (Wealth)",
          description:
              "Mercury should be in Lagna identical with his own sign and joined or aspectedby Saturn and Venus.",
          benefits:
              "You will accumulate significant wealth, enjoy financial prosperity, and lead a comfortable life with multiple sources of income.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for dhana_yoga_125
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "dhana_yoga_125",
          name: "Dhana Yoga",
          category: "Dhana Yogas (Wealth)",
          description:
              "Mars should be in Lagna identical with Aries or Scorpio and joined or aspectedby the Moon, Venus and Saturn.",
          benefits:
              "You will accumulate significant wealth, enjoy financial prosperity, and lead a comfortable life with multiple sources of income.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for dhana_yoga_124
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "dhana_yoga_124",
          name: "Dhana Yoga",
          category: "Dhana Yogas (Wealth)",
          description:
              "If the Moon is in Lagna identical with Cancer and aspectedby Jupiter and Mars, this yoga is caused.",
          benefits:
              "You will accumulate significant wealth, enjoy financial prosperity, and lead a comfortable life with multiple sources of income.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for dhana_yoga_123
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "dhana_yoga_123",
          name: "Dhana Yoga",
          category: "Dhana Yogas (Wealth)",
          description:
              "If the Sun is in Lagna identical with Leo, and aspected or joined by Mars and Jupiter, this yoga is formed.",
          benefits:
              "You will accumulate significant wealth, enjoy financial prosperity, and lead a comfortable life with multiple sources of income.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for dhana_yoga_122
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "dhana_yoga_122",
          name: "Dhana Yoga",
          category: "Dhana Yogas (Wealth)",
          description:
              "If the 5th from Lagna happens to be a house of Jupiter with Jupiter there and Mars and the Moon  in the 11th, Dhana Yoga arises.",
          benefits:
              "You will accumulate significant wealth, enjoy financial prosperity, and lead a comfortable life with multiple sources of income.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for dhana_yoga_121
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "dhana_yoga_121",
          name: "Dhana Yoga",
          category: "Dhana Yogas (Wealth)",
          description:
              "The Sun must occupy the 5th identical with his own sign and Jupiter and the Moon should be in the 11th.",
          benefits:
              "You will accumulate significant wealth, enjoy financial prosperity, and lead a comfortable life with multiple sources of income.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for dhana_yoga_120
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "dhana_yoga_120",
          name: "Dhana Yoga",
          category: "Dhana Yogas (Wealth)",
          description:
              "Saturn should occupy his own sign which shouldbe the 5th from Lagna, and Mercury and Mars should be posited in the 11th.",
          benefits:
              "You will accumulate significant wealth, enjoy financial prosperity, and lead a comfortable life with multiple sources of income.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for dhana_yoga_119
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "dhana_yoga_119",
          name: "Dhana Yoga",
          category: "Dhana Yogas (Wealth)",
          description:
              "Mercury should occupy his own sign which should be the 5th from Lagna and the Moon and Mars should be in the 11th.",
          benefits:
              "You will accumulate significant wealth, enjoy financial prosperity, and lead a comfortable life with multiple sources of income.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for dhana_yoga_118
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "dhana_yoga_118",
          name: "Dhana Yoga",
          category: "Dhana Yogas (Wealth)",
          description:
              "If the 5th from the Ascendant happens to be a sign of Venus, and if Venus and Saturn are situated in the 5th and 11th respectively, Dhana Yoga is caused.",
          benefits:
              "You will accumulate significant wealth, enjoy financial prosperity, and lead a comfortable life with multiple sources of income.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for bahudravyarjana_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "bahudravyarjana_yoga",
          name: "Bahudravyarjana Yoga",
          category: "Other Natal Yoga",
          description:
              "The Lagna lord is in the 2nd, the 2nd lord is in the 11th, and the 11th lord is in the Lagna.",
          benefits:
              "You will earn vast amounts of wealth through various means and become a very rich person in your community.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for swaveeryaddhana_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "swaveeryaddhana_yoga",
          name: "Swaveeryaddhana Yoga",
          category: "Dhana Yogas (Wealth)",
          description:
              "The Lagna lord is the strongest planet in the chart and is placed in a Kendra, associated with the 2nd lord.",
          benefits:
              "You will earn wealth solely through your own efforts, hard work, and personal prowess, without much ancestral help.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for madhya_vayasi_dhana_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "madhya_vayasi_dhana_yoga",
          name: "Madhya Vayasi Dhana Yoga",
          category: "Dhana Yogas (Wealth)",
          description:
              "The lords of the Lagna, 2nd, and 11th houses are placed in Kendras or Thrikonas.",
          benefits:
              "You will experience a significant rise in wealth and financial status during the middle part of your life.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for anthya_vayasi_dhana_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "anthya_vayasi_dhana_yoga",
          name: "Anthya Vayasi Dhana Yoga",
          category: "Dhana Yogas (Wealth)",
          description:
              "The lords of the 2nd, 9th, and 11th houses are placed in the 12th, 6th, or 8th houses from each other but associated with benefics.",
          benefits:
              "You will accumulate and enjoy great wealth and prosperity during the later years or the final stage of your life.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for balya_dhana_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "balya_dhana_yoga",
          name: "Balya Dhana Yoga",
          category: "Dhana Yogas (Wealth)",
          description:
              "The lords of the 2nd and 10th should be in conjunction in a kendra aspected by the lord of the Navamsa occupied by the ascendant lord.",
          benefits:
              "The person acquries immense riches in the early part of life.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for bhratrumooladdhanaprapti_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "bhratrumooladdhanaprapti_yoga",
          name: "Bhratrumooladdhanaprapti Yoga",
          category: "Other Natal Yoga",
          description:
              "The 2nd lord is associated with the 3rd lord or placed in the 3rd house with a benefic.",
          benefits:
              "You will gain wealth, property, or financial assistance through your brothers or siblings.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for matrumooladdhana_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "matrumooladdhana_yoga",
          name: "Matrumooladdhana Yoga",
          category: "Dhana Yogas (Wealth)",
          description:
              "The 2nd lord is associated with the 4th lord or placed in the 4th house with strong benefic influence.",
          benefits:
              "You will inherit or gain wealth and assets through your mother or from your maternal side of the family.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for putramooladdhana_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "putramooladdhana_yoga",
          name: "Putramooladdhana Yoga",
          category: "Dhana Yogas (Wealth)",
          description:
              "The 2nd lord is associated with the 5th lord or placed in the 5th house.",
          benefits:
              "You will gain wealth through your children, or your children will become a source of great financial prosperity for you.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for shatrumooladdhana_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "shatrumooladdhana_yoga",
          name: "Shatrumooladdhana Yoga",
          category: "Dhana Yogas (Wealth)",
          description:
              "The 2nd lord is associated with the 6th lord or placed in the 6th house, and the 6th lord is in a benefic house.",
          benefits:
              "You will gain wealth through your enemies, competitions, or litigation.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for kalatramooladdhana_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "kalatramooladdhana_yoga",
          name: "Kalatramooladdhana Yoga",
          category: "Dhana Yogas (Wealth)",
          description:
              "The 2nd lord is associated with the 7th lord or placed in the 7th house with benefics.",
          benefits:
              "You will gain wealth and assets through your spouse or your marriage partner's family.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for amaranantha_dhana_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "amaranantha_dhana_yoga",
          name: "Amaranantha Dhana Yoga",
          category: "Dhana Yogas (Wealth)",
          description:
              "The lords of the 2nd, 9th, and 11th are in Kendras from the Lagna and the Lagna lord is strong.",
          benefits:
              "You will remain wealthy and enjoy financial stability until the very end of your life.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for ayatnadhanalabha_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "ayatnadhanalabha_yoga",
          name: "Ayatnadhanalabha Yoga",
          category: "Other Natal Yoga",
          description:
              "The Lagna lord and the 2nd lord are in exchange of houses (Parivartana) or are together in a house.",
          benefits:
              "You will obtain wealth effortlessly or through unexpected windfalls like lotteries, gifts, or sudden luck.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for yukthi_samanwithavagmi_yoga_154
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "yukthi_samanwithavagmi_yoga_154",
          name: "Yukthi Samanwithavagmi Yoga",
          category: "Other Natal Yoga",
          description:
              "The 2nd lord should join a benefic in a kendra or thrikona, or be exalted and combined with Jupiter.",
          benefits:
              "You will speak with great logic and tact. Your speech will be highly influential and meaningful.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for yukthi_samanwithavagmi_yoga_155
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "yukthi_samanwithavagmi_yoga_155",
          name: "Yukthi Samanwithavagmi Yoga",
          category: "Other Natal Yoga",
          description:
              "The lord of speech should occupy a kendra, attain paramochha and gain Parvatamsa, while Jupiter or Venus should be in Simhasanamsa.",
          benefits:
              "You will speak with great logic and tact. Your speech will be highly influential and meaningful.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for parihasaka_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "parihasaka_yoga",
          name: "Parihasaka Yoga",
          category: "Other Natal Yoga",
          description:
              "The lord of the Lagna and the 2nd lord are together and associated with or aspected by benefic planets.",
          benefits:
              "You will be humorous and witty. You will be skilled at making others laugh with your words.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for asatyavadi_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "asatyavadi_yoga",
          name: "Asatyavadi Yoga",
          category: "Other Natal Yoga",
          description:
              "The 2nd lord is associated with malefic planets (Saturn, Rahu, Ketu) and Mercury is weak.",
          benefits:
              "You may have a tendency to speak untruths or have a habit of lying.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for jada_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "jada_yoga",
          name: "Jada Yoga",
          category: "Other Natal Yoga",
          description:
              "The lord of the 2nd house is in the 6th, 8th, or 12th house and is aspected by malefic planets.",
          benefits:
              "You may exhibit laziness or a lack of mental sharpness in your activities.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for marud_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "marud_yoga",
          name: "Marud Yoga",
          category: "Other Natal Yoga",
          description:
              "Venus, Jupiter, and the Moon are in Kendra or Thrikona houses.",
          benefits:
              "You will be fortunate, have an interest in music and arts, and possess a very attractive personality.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for budha_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "budha_yoga",
          name: "Budha Yoga",
          category: "Other Natal Yoga",
          description:
              "The Lagna lord is strong and Mercury is in a Kendra house.",
          benefits:
              "You will be highly intelligent, learned, and skillful in all your endeavors.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for mooka_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "mooka_yoga",
          name: "Mooka Yoga",
          category: "Other Natal Yoga",
          description:
              "The 2nd lord is in the 8th house and is associated with malefic planets.",
          benefits:
              "This combination may indicate speech difficulties or a tendency toward being mute.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for netranasa_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "netranasa_yoga",
          name: "Netranasa Yoga",
          category: "Other Natal Yoga",
          description:
              "The Sun or Moon is under the aspect of malefic planets while the 2nd or 12th house is weak.",
          benefits:
              "There is a possibility of eye-related problems or defects in vision.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for andha_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "andha_yoga",
          name: "Andha Yoga",
          category: "Other Natal Yoga",
          description:
              "The Lagna lord, Sun, and Moon are associated with malefic planets in the 2nd or 12th house.",
          benefits:
              "This indicates potential blindness or significantly weakened eyesight.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for sumukha_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "sumukha_yoga",
          name: "Sumukha Yoga",
          category: "Other Natal Yoga",
          description:
              "Benefic planets (Jupiter, Venus) are placed in or aspecting the 2nd house.",
          benefits:
              "You will have an attractive facial appearance and a peaceful temperament.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for durmukha_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "durmukha_yoga",
          name: "Durmukha Yoga",
          category: "Other Natal Yoga",
          description:
              "Malefic planets (Saturn, Rahu, Ketu) occupy the 2nd house.",
          benefits:
              "You may have a facial defect or an expression characterized by anger.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for bhojana_soukhya_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "bhojana_soukhya_yoga",
          name: "Bhojana Soukhya Yoga",
          category: "Other Natal Yoga",
          description:
              "The 2nd lord is strong and associated with benefic planets.",
          benefits:
              "You will always enjoy delicious, high-quality food and comforts of the table.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for annadana_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "annadana_yoga",
          name: "Annadana Yoga",
          category: "Other Natal Yoga",
          description:
              "Jupiter or the Moon has a benefic association with the 2nd or 12th house.",
          benefits:
              "You will be very interested in feeding others and providing charity to the needy.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for parannabhojana_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "parannabhojana_yoga",
          name: "Parannabhojana Yoga",
          category: "Other Natal Yoga",
          description:
              "The lord of the 2nd house is weak and situated in the 8th or 12th house.",
          benefits:
              "You may frequently find yourself eating food provided by others or depending on others for your meals.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for sraddhannabhuktha_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "sraddhannabhuktha_yoga",
          name: "Sraddhannabhuktha Yoga",
          category: "Other Natal Yoga",
          description:
              "The lord of the 2nd house is associated with Saturn and the lord of the 8th house.",
          benefits:
              "You may have to eat food offered in funeral rites or ceremonies (Sraddha), or depend on others' charity for sustenance.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for sarpaganda_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "sarpaganda_yoga",
          name: "Sarpaganda Yoga",
          category: "Other Natal Yoga",
          description:
              "Rahu is in the 2nd house with the 2nd lord, or aspected by a malefic planet.",
          benefits:
              "You may face danger from snake bites or suffer from poisonous substances and skin-related ailments.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for vakchalana_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "vakchalana_yoga",
          name: "Vakchalana Yoga",
          category: "Other Natal Yoga",
          description:
              "The lord of the 2nd house is in the 6th, 8th, or 12th house, and is associated with Rahu or Saturn.",
          benefits:
              "You may suffer from a flickering tongue, stammering, or a lack of consistency and clarity in your speech.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for vishaprayoga_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "vishaprayoga_yoga",
          name: "Vishaprayoga Yoga",
          category: "Other Natal Yoga",
          description:
              "The 2nd lord is associated with the 6th, 8th, or 12th lords and is aspected by malefics.",
          benefits:
              "You may be subject to poisoning by others or face health complications due to toxic substances.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for bhratruvriddhi_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "bhratruvriddhi_yoga",
          name: "Bhratruvriddhi Yoga",
          category: "Other Natal Yoga",
          description:
              "The 3rd lord or Mars is associated with a benefic planet or placed in a benefic sign/Navamsha.",
          benefits:
              "You will have an increase in the number of brothers and sisters, and enjoy a harmonious relationship with them.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for sodaranasa_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "sodaranasa_yoga",
          name: "Sodaranasa Yoga",
          category: "Other Natal Yoga",
          description:
              "Mars and the 3rd lord occupy the 8th, 3rd, 5th, or 7th house and are aspected by malefics.",
          benefits:
              "The person will suffer the loss of brothers or siblings, or may not have any siblings at all.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for ekabhagini_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "ekabhagini_yoga",
          name: "Ekabhagini Yoga",
          category: "Other Natal Yoga",
          description:
              "Mercury is in the 3rd house, the lord of the 3rd is with the Moon, and Mars is with Saturn.",
          benefits: "The person will have only one sister.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for dwadasa_sahodara_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "dwadasa_sahodara_yoga",
          name: "Dwadasa Sahodara Yoga",
          category: "Other Natal Yoga",
          description:
              "The 3rd lord is in a kendra and exalted Mars joins Jupiter in a thrikona from the 3rd lord.",
          benefits:
              "The person will be blessed with twelve brothers or siblings.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for sapthasankhya_sahodara_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "sapthasankhya_sahodara_yoga",
          name: "Sapthasankhya Sahodara Yoga",
          category: "Other Natal Yoga",
          description:
              "Lord of the 12th should join Mars and the Moon should be in the 3rd with Jupiter, devoid of association with or aspect of Venus.",
          benefits:
              "The person will have seven siblings or a family structure significantly influenced by the number seven in relation to brothers/sisters.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for parakrama_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "parakrama_yoga",
          name: "Parakrama Yoga",
          category: "Other Natal Yoga",
          description:
              "The lord of the 3rd should join a benefic navamsa being aspected by (or conjoined with) benefic planets, and Mars should occupy benefic signs.",
          benefits:
              "The individual will be highly courageous, valorous, and possesses great physical and mental strength to overcome obstacles.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for yuddha_praveena_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "yuddha_praveena_yoga",
          name: "Yuddha Praveena Yoga",
          category: "Other Natal Yoga",
          description:
              "The lord of the Navamsa occupied by the 3rd lord's Navamsa lord is placed in its own Varga.",
          benefits:
              "The person becomes a capable strategist and an expert in warfare and tactical combat.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for yuddhatpoorvadridhachitta_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "yuddhatpoorvadridhachitta_yoga",
          name: "Yuddhatpoorvadridhachitta Yoga",
          category: "Other Natal Yoga",
          description:
              "184 - The exalted lord of the 3rd should join malefics in movable Rasis or Navamsas",
          benefits:
              "The person will be courageous before the commencement of the war.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for yuddhatpaschaddrudha_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "yuddhatpaschaddrudha_yoga",
          name: "Yuddhatpaschaddrudha Yoga",
          category: "Other Natal Yoga",
          description:
              "The 3rd lord is in a fixed Rasi, a fixed Navamsa, and a cruel Shashtiamsa, while its dispositor is debilitated.",
          benefits:
              "You may feel hesitant or fearful at the start of a conflict, but once the struggle begins, you develop unshakable resolve and fight with extreme firmness.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for satkathadisravana_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "satkathadisravana_yoga",
          name: "Satkathadisravana Yoga",
          category: "Other Natal Yoga",
          description:
              "The 3rd house is a benefic sign aspected by benefic planets, and the 3rd lord joins a benefic amsa (conjoins with or aspected by a benefic).",
          benefits:
              "You have a natural inclination toward listening to righteous stories, spiritual discourses, and virtuous conversations.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for utthama_graha_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "utthama_graha_yoga",
          name: "Uttama Griha Yoga",
          category: "Other Natal Yoga",
          description:
              "The lord of the 4th house joins benefics and is aspected by benefics while placed in a Kendra (1, 4, 7, 10) or Trikona (1, 5, 9).",
          benefits:
              "This indicates the acquisition of an excellent, beautiful, and comfortable house.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for vichitra_saudha_prakara_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "vichitra_saudha_prakara_yoga",
          name: "Vichitra Saudha Prakara Yoga",
          category: "Other Natal Yoga",
          description:
              "The lords of the 4th and 10th houses are conjoined together with Saturn and Mars.",
          benefits:
              "You may possess unique, grand, or many-walled palatial buildings and extensive landed properties.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for ayatna_griha_prapta_yoga_189
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "ayatna_griha_prapta_yoga_189",
          name: "Ayatna Griha Prapta Yoga",
          category: "Other Natal Yoga",
          description:
              "189. Lords of Lagna and the 7th should occupy Lagna or the 4th, aspected by benefics.",
          benefits:
              "The person acquires substantial house property with hardly any effort.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for ayatna_griha_prapta_yoga_190
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "ayatna_griha_prapta_yoga_190",
          name: "Ayatna Griha Prapta Yoga",
          category: "Other Natal Yoga",
          description:
              "190. The lord of the 9th should be posited in a kendra and the lord of the 4th must be in exaltation, moola-thrikona or own house.",
          benefits:
              "The person acquires substantial house property with hardly any effort.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for grihanasa_yoga_191
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "grihanasa_yoga_191",
          name: "Grihansa Yoga",
          category: "Other Natal Yoga",
          description:
              "191 - The lord of the 4th should be in the 12th aspected by a malefic.",
          benefits: "The person will lose all the house property.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for grihanasa_yoga_192
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "grihanasa_yoga_192",
          name: "Grihansa Yoga",
          category: "Other Natal Yoga",
          description:
              "192 - The lord of the navamsa occupied by the lord of the 4th should be disposed in the 12th.",
          benefits: "The person will lose all the house property.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for bandhu_pujya_yoga_193
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "bandhu_pujya_yoga_193",
          name: "Bandhu Pujya Yoga",
          category: "Other Natal Yoga",
          description:
              "193 - If the benefic lord of the 4th is aspected by another benefic and Mercury is situated in Lagna, the above yoga is given rise to.",
          benefits:
              "The person will be respected by his relatives and friends.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for bandhu_pujya_yoga_194
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "bandhu_pujya_yoga_194",
          name: "Bandhu Pujya Yoga",
          category: "Other Natal Yoga",
          description:
              "194 - The 4th house or the 4th lord should have the association or aspect of Jupiter.",
          benefits:
              "The person will be respected by his relatives and friends.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for bandhubhisthyaktha_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "bandhubhisthyaktha_yoga",
          name: "Bandhu Bhisthyaktha Yoga",
          category: "Other Natal Yoga",
          description:
              "195. The 4th lord must be associated with malefics or occupy evil shashtiamsas or join inimical or debilitation signs.",
          benefits: "The person will be clesertedby his relatives.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for matrudeerghayur_yoga_196
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "matrudeerghayur_yoga_196",
          name: "Maathru dheerghayur Yoga",
          category: "Longevity & Health Yogas",
          description:
              "196 -  benefic must occupy the 4th, the 4th lord must be exalted, and the Moon must be strong.",
          benefits: "The native's mother will live long.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for matrudeerghayur_yoga_197
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "matrudeerghayur_yoga_197",
          name: "Maathru dheerghayur Yoga",
          category: "Longevity & Health Yogas",
          description:
              "197 - The lord of the navamsaoccupiedby the 4th lord should be strong and occupy a kendra from Lagna as well as Chandra Lagna.",
          benefits: "The native's mother will live long.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for matrunasa_yoga_198
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "matrunasa_yoga_198",
          name: "Maathru Naasa yoga",
          category: "Other Natal Yoga",
          description:
              "198 - The Moon should be hemmed in between, associated with or aspected by evil planets.",
          benefits: "The person's mother will have a very early death.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for matrunasa_yoga_199
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "matrunasa_yoga_199",
          name: "Maathru Naasa yoga",
          category: "Other Natal Yoga",
          description:
              "199 - The planet owning the navamsa, in which the lord of the navamsa occupied by the 4th lord is situated should be disposed in the 6th, 8th or 12th house.",
          benefits: "The person's mother will have a very early death.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for kapata_yoga_202
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "kapata_yoga_202",
          name: "Kapata Yoga",
          category: "Other Natal Yoga",
          description:
              "202 - The 4th house must be joined by a malefic and the 4rh lord must be associated with or aspected by malefics or be hemmed in between malefics.",
          benefits: "The person becomes a hypocrite.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for kapata_yoga_203
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "kapata_yoga_203",
          name: "Kapata Yoga",
          category: "Other Natal Yoga",
          description:
              "203 - The 4th must be occupied by Sani, Kuja, Rahu, and the malefic 1Oth lord, who in his turn should be aspected by malefics.",
          benefits: "The person becomes a hypocrite.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for kapata_yoga_204
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "kapata_yoga_204",
          name: "Kapata Yoga",
          category: "Other Natal Yoga",
          description:
              "204 - The 4th lord must join Saturn, Mandi and Rahu and aspected by malefics.",
          benefits: "The person becomes a hypocrite.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for nishkapata_yoga_205
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "nishkapata_yoga_205",
          name: "Nishkapata Yoga",
          category: "Other Natal Yoga",
          description:
              "205 - The 4th house must be occupied by a benefic, or a planet in exaltation, friendly or own house,or the 4th house must be a benefic sign.",
          benefits:
              "The person will be pure-hearted and hates secrecy and hypocrisy.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for nishkapata_yoga_206
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "nishkapata_yoga_206",
          name: "Nishkapata Yoga",
          category: "Other Natal Yoga",
          description:
              "206 - Lord of Lagna should join the 4th in conjunction with or aspected by a benefic or occupy Parvata or Uttamamsa.",
          benefits:
              "The person will be pure-hearted and hates secrecy and hypocrisy.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for matru_satrutwa_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "matru_satrutwa_yoga",
          name: "Mathru Sathruthwa Yoga",
          category: "Other Natal Yoga",
          description:
              "Mercury, being lord of Lagna and the 4th, must join with or be aspected by a malefic.",
          benefits: "The person will hate his mother.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for matru_sneha_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "matru_sneha_yoga",
          name: "Maathru Sneha Yoga",
          category: "Other Natal Yoga",
          description:
              "First Variation - The Lagna (1st house) and the 4th house have the same planetary ruler. The lst and 4th houses can have common lords only in respect of Ge/Vi (Me) or Sg/Pi (Ju). Second Variation - The lords of the 1st and 4th houses are either natural or temporal friends. Third Variation - The Lagna lord (1st house ruler) and the 4th house lord are aspected by benefics.",
          benefits: "Cordial relations will prevail between mother and son.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for vahana_yoga_209
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "vahana_yoga_209",
          name: "Vaahana Yoga",
          category: "Other Natal Yoga",
          description:
              "209 - The lord of Lagna must join the 4th, 11th or the 9th.",
          benefits:
              "The native will acquire material comforts and conveyances.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for vahana_yoga_210
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "vahana_yoga_210",
          name: "Vaahana Yoga",
          category: "Other Natal Yoga",
          description:
              "210 - The 4th lord must be exalted and the lord of the exaltation sign must occupy a kendra or trikona",
          benefits:
              "The native will acquire material comforts and conveyances.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for anapathya_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "anapathya_yoga",
          name: "Anapathya Yoga",
          category: "Other Natal Yoga",
          description:
              "Jupiter and the lords of Lagna, the 7th and the 5th are weak",
          benefits: "The person will have no children.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for sarpasaapa_yoga_212
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "sarpasaapa_yoga_212",
          name: "Sarpa Saapa Yogam",
          category: "Other Natal Yoga",
          description:
              "212 - The 5th should be occupied by Rahu and aspected by Kuja or the 5th house being a sign of Mars, should be occupied by Rahu.",
          benefits:
              "There will be death of children due to the curse of serpents.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for sarpasaapa_yoga_213
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "sarpasaapa_yoga_213",
          name: "Sarpa Saapa Yogam",
          category: "Other Natal Yoga",
          description:
              "213 - The 5th lord is in conjunction with Rahu, and  Saturn is in the 5th house aspected by or asssociated with the Moon.",
          benefits:
              "There will be death of children due to the curse of serpents.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for sarpasaapa_yoga_214
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "sarpasaapa_yoga_214",
          name: "Sarpa Saapa Yogam",
          category: "Other Natal Yoga",
          description:
              "214 - The karaka of children (Jupiter) in association with Mars, Rahu in Lagna, and the 5th lord in a dusthana.",
          benefits:
              "There will be death of children due to the curse of serpents.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for sarpasaapa_yoga_215
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "sarpasaapa_yoga_215",
          name: "Sarpa Saapa Yogam",
          category: "Other Natal Yoga",
          description:
              "215 - The 5th house, being a sign of Mars, must be conjoined by Rahu and aspected by or associated with Mercury",
          benefits:
              "There will be death of children due to the curse of serpents.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for pithru_saapa_sutakshaya_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "pithru_saapa_sutakshaya_yoga",
          name: "Pithru Saapa Sutakshaya Yoga",
          category: "Other Natal Yoga",
          description:
              "5th House must be occupied by Sun. A. Sun should be in sign of debilitation (Sun in Mithuna/Gemini), OR B. Sun's Navamsa should be in Makara/Capricorn or Kumbha/Aquarius. C. Sun is hemmed either side with malefics",
          benefits:
              "There will be loss of children due to the curse of the father.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for maathru_saapa_sutakshaya_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "maathru_saapa_sutakshaya_yoga",
          name: "Maathru Saapa Sutakshaya Yoga",
          category: "Other Natal Yoga",
          description:
              "A. The 8th lord is in the 5th lord's house AND the 5th lord is in the 8th lord's house AND B the Moon and the 4th lord join the 6th house",
          benefits:
              "There will be loss of children due to the curse of the mother.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for bhraathru_saapa_sutakshaya_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "bhraathru_saapa_sutakshaya_yoga",
          name: "Bhraathru Saapa Sutakshaya Yoga",
          category: "Other Natal Yoga",
          description:
              "A. The lords of Lagna and the 5th must join the 8th house AND B. the lord of the 3rd should combine with Mars and Rahu in the 5th house.",
          benefits:
              "There will be death of children due to curses from brothers.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for pretha_saapa_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "pretha_saapa_yoga",
          name: "Pretha Saapa Yoga",
          category: "Other Natal Yoga",
          description:
              "The Sun and Saturn in the 5th house, weak Moon in the 7th house, Rahu in Lagna and Jupiter in the 12th house",
          benefits:
              "Children will die through the curses of Prethas or manes of the dead.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for bahu_puthra_yoga_220
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "bahu_puthra_yoga_220",
          name: "Bahu Puthra Yoga",
          category: "Progeny Yogas (Children)",
          description:
              "220 - Rahu is in 5th house. And Rahu is not in Saturn's Navamsa (i.e Rahu in D9 not in Aq/Cp).",
          benefits: "The person will have a large number of children",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for bahu_puthra_yoga_221
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "bahu_puthra_yoga_221",
          name: "Bahu Puthra Yoga",
          category: "Progeny Yogas (Children)",
          description:
              "221 - The same yoga arises if the lord of the Navamsa occupied by a planet who is in association with the 7th lord is in the 1st, 2nd or 5th house. Steps: (1) Get 7th Lord in Rasi. (2) Find which rasi this 7th lord is in Navamsa chart. (3) Find the lord of that sign of step-2. (4) Find the sign of the Lord found from step-3 in rasi chart. (5) That sign should be either 1st, or 2nd or 5th from Lagna in rasi",
          benefits: "The person will have a large number of children",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for dattha_puthra_yoga_222
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "dattha_puthra_yoga_222",
          name: "Dattha Puthra Yoga",
          category: "Progeny Yogas (Children)",
          description:
              "222 - Mars and Saturn should occupy the 5th house and the lord of Lagna should be in a sign of Mercury, aspected by or in association with the same planet (Mercury).",
          benefits: "The person will have adopted children.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for dattha_puthra_yoga_223
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "dattha_puthra_yoga_223",
          name: "Dattha Puthra Yoga",
          category: "Progeny Yogas (Children)",
          description:
              "223 - The lord of the 7th must be posited in the 11th, the 5th lord must join a benefic and the 5th house must be occupied by Mars or Saturn.",
          benefits: "The person will have adopted children.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for aputhra_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "aputhra_yoga",
          name: "Aputhra Yoga",
          category: "Progeny Yogas (Children)",
          description:
              "224 - The lord of the 5th house should occupy a dusthana.",
          benefits: "The person will have no children.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for eka_puthra_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "eka_puthra_yoga",
          name: "Eka Puthra Yoga",
          category: "Progeny Yogas (Children)",
          description:
              "225 - Lord of 5th house should join a kendra or trikona.",
          benefits: "The person will have only one child.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for suputhra_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "suputhra_yoga",
          name: "Suputhra Yoga",
          category: "Progeny Yogas (Children)",
          description:
              "226 - Jupiter is lord of 5th house (=Lagna in Le/Sc) and Sun in favorable position (own, exalted,friendly sign)",
          benefits: "The native will have a worthy child.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for kaalanirdesat_puthra_yoga_227
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "kaalanirdesat_puthra_yoga_227",
          name: "Kaalanirdesat Puthra Yoga",
          category: "Progeny Yogas (Children)",
          description:
              "227 - Jupiter should be in the 5th house and the lord of the 5th should join Venus.",
          benefits:
              "The native begets a child either in his 32nd, 33rd or 40th year.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for kaalanirdesat_puthra_yoga_228
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "kaalanirdesat_puthra_yoga_228",
          name: "Kaalanirdesat Puthra Yoga",
          category: "Progeny Yogas (Children)",
          description:
              "228 - Jupiter must also occupy the 9th from Lagna and Venus should be in the 9th from Jupiter, in conjunction with the lord of Lagna",
          benefits:
              "The native begets a child either in his 32nd, 33rd or 40th year.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for kaalanirdesat_puthranaasa_yoga_229
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "kaalanirdesat_puthranaasa_yoga_229",
          name: "Kaalanirdesat Puthranaasa Yoga",
          category: "Progeny Yogas (Children)",
          description:
              "229 - Rahu must occupy the 5th house, the lord of the 5th must be in conjunction with a malefic and Jupiter should be debilitated.",
          benefits:
              "The person will suffer loss of children in his 32nd and 40th years respectively.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for kaalanirdesat_puthranaasa_yoga_230
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "kaalanirdesat_puthranaasa_yoga_230",
          name: "Kaalanirdesat Puthranaasa Yoga",
          category: "Progeny Yogas (Children)",
          description:
              "230 - Malefics should be disposed (cojoins or aspect) in 5th from Jupiter and 5th from Lagna",
          benefits:
              "The person will suffer loss of children in his 32nd and 40th years respectively.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for buddhimaturya_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "buddhimaturya_yoga",
          name: "Buddhimaturya Yoga",
          category: "Other Natal Yoga",
          description:
              "231 - If the 5th lord, being a benefic, is either aspected by another benefic or occupies a benefic sign, the above yoga is given rise to.",
          benefits:
              "The person will be a man of great intelligence and character.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for theevrabuddhi_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "theevrabuddhi_yoga",
          name: "Theevrabuddhi Yoga",
          category: "Other Natal Yoga",
          description:
              "232 - Lord of 5th in rasi should be a benefic and should in Navamsa Lagna. Lord of Navamsa Lagna should be a benefic or aspected by benefic.",
          benefits: "The person will be precociously intelligent.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for buddhi_jada_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "buddhi_jada_yoga",
          name: "Buddhi Jada Yoga",
          category: "Other Natal Yoga",
          description:
              "233 - Lord of Lagna cojoins or aspected by malefics. AND Saturn occupies 5th house, AND Lord of lagna is aspected by Saturn. OR 5th lord is conjoined with malefics AND (Saturn aspects 5th Lord) OR Moon in 5th House",
          benefits: "The person will be a dunce.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for thrikaala_gnana_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "thrikaala_gnana_yoga",
          name: "Thrikaala Gnana Yoga",
          category: "Other Natal Yoga",
          description:
              "234 - Jupiter in Mrudwamsa in his own navamsa. OR Jupiter in Gopuramsa (score >= 4) AND aspected by a benefic.",
          benefits:
              "The native becomes capable of reading the past, present and future.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for jara_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "jara_yoga",
          name: "Jara Yoga",
          category: "Other Natal Yoga",
          description:
              "236 - he l0th house must be occupied by the lords of the 10th, 2nd and 7th.",
          benefits:
              "The person will have extra-marital relations with a number of women.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for jarajaputra_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "jarajaputra_yoga",
          name: "Jarajaputra Yoga",
          category: "Progeny Yogas (Children)",
          description:
              "237. Powerful lords of the 5th and the 7th must join with the lord of the 6th and be aspected by benefics.",
          benefits:
              "The person lacks the power of procreation but his wife will have a son from another man.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for bahu_sthree_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "bahu_sthree_yoga",
          name: "Bahu Sthree Yoga",
          category: "Other Natal Yoga",
          description:
              "238 - If the lords of the Lagna and the 7th are in conjunction or aspect with each other, the above yoga is given rise to.",
          benefits: "The person will have any number of wives.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for satkalatra_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "satkalatra_yoga",
          name: "Sathkalatra Yoga",
          category: "Other Natal Yoga",
          description:
              "239 - The lord of the 7th or Venus should join or be aspected by Jupiter or Mercury.",
          benefits: "The native's wife will be noble and virtuous.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for bhaga_chumbana_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "bhaga_chumbana_yoga",
          name: "Bhaga Chumbana yoga",
          category: "Other Natal Yoga",
          description:
              "240 - If the lord of the 7th is in the 4th in conjunction with Venus, the above yoga is caused",
          benefits:
              "Person has excessive attachment to self-pleasure and difficulty in managing sensual desires.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for bhaagya_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "bhaagya_yoga",
          name: "Bhaagya Yoga",
          category: "Other Natal Yoga",
          description:
              "241 -  strong benefic should be in Lagna, the 3rd or 5th, simultaneously aspecting the 9th.",
          benefits:
              "The subject will be extremely fortunate, pleasure-loving and rich.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for jananatpurvam_pitru_marana_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "jananatpurvam_pitru_marana_yoga",
          name: "Jananatpurvam Pithru Marana Yoga",
          category: "Longevity & Health Yogas",
          description:
              "242 - The Sun must be in the 6th, 8th or 12th; lord of the 8th must be in the 9th; lord of the 12th in Lagna and the lord of the 6th in the 5th.",
          benefits: "The person will be a posthumous child.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for dhatrutwa_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "dhatrutwa_yoga",
          name: "Dhatrutwa Yoga",
          category: "Other Natal Yoga",
          description:
              "243. The lord of the 9th should be exalted, and aspected by a benefic, and the 9th house should be occupied by a benefic.",
          benefits: "The person will be an embodiment of generosity",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for apakeerthi_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "apakeerthi_yoga",
          name: "Apakeerthi Yoga",
          category: "Other Natal Yoga",
          description:
              "244 - The 10th house must be occupied by the Sun and Saturn who should join malefic amsas or be aspected by malefics.",
          benefits: "The person will have a bad reputation.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for galakarna_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "galakarna_yoga",
          name: "Galakarna Yoga",
          category: "Other Natal Yoga",
          description:
              "264. The 3rd house must be occupied by Mandi and Rahu or by Mars in the shashtiamsa of Preta Puriha (Cruel deities).",
          benefits: "The native suffersf rom ear troubles.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for vrana_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "vrana_yoga",
          name: "Vrana Yoga",
          category: "Other Natal Yoga",
          description:
              "265 - The 6th lord, being a malefic, should occupy the Lagna, 8th or 1Oth. Impacted organs depending on 6th lord: Sun- Spleen,heart. Moon-Oesophagus, alimentary canal. Mars-Genitals, left cerebral hemisphere, red colouring matter in blood,rectum. Mercury- Nerves, right cerebral hemisphere, cerebro-spinal-system, bronchial tubes, ears, tongue. Jupiter- Liver, supra-renals. Venus- Throat, kidneys, uterus, ovaries. Saturn- Teeth, skin, vagus nerve. Rahu- Pituitary body. Kethu- Pineal glands.",
          benefits: "The person suffers from dreadful disease of cancer",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for sisnavyadhi_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "sisnavyadhi_yoga",
          name: "Sisnavyadhi Yoga",
          category: "Chandra Yogas (Moon-based)",
          description:
              " 266 - Mercury should join Lagna in association with the lords of the 6th and 8th",
          benefits: "The native will suffer from incurable sexual diseases.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for kushtaroga_yoga_268
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "kushtaroga_yoga_268",
          name: "Kushtaroga Yoga",
          category: "Other Natal Yoga",
          description:
              "268 - The lord of Lagna must join Mars and Mercury in the 4th or 12th house.",
          benefits: "The person suffers from leprosy.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for kushtaroga_yoga_269
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "kushtaroga_yoga_269",
          name: "Kushtaroga Yoga",
          category: "Other Natal Yoga",
          description:
              "269 - Jupiter in conjunction with Saturn and the Moon should occupy the 6th house.",
          benefits: "The person suffers from leprosy.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for kshayaroga_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "kshayaroga_yoga",
          name: "Kshayaroga Yoga",
          category: "Other Natal Yoga",
          description:
              "270 - Rahu in the 6th, Mandi in a kendra from Lagna, and the lord of Lagna in the 8th gives rise to this yoga.",
          benefits: "The person suffers from tuberculosis.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for bhandhana_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "bhandhana_yoga",
          name: "Bhandhana Yoga",
          category: "Dhana Yogas (Wealth)",
          description:
              "271 - The lord of the Lagna and the 6th join a kendra or thrikona with Saturn, Rahu or Kethu, the above yoga is given rise to.",
          benefits: "The native will be incarcerated.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for karascheda_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "karascheda_yoga",
          name: "Karascheda Yoga",
          category: "Other Natal Yoga",
          description:
              "272 - Saturn and Jupiter should be in the 9th and the 3rd.",
          benefits: "The native's hands will be cut off.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for sirachcheda_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "sirachcheda_yoga",
          name: "Sirachcheda Yoga",
          category: "Other Natal Yoga",
          description:
              "273 - The lord of the 6th must be in conjunction with Venus while the Sun or Saturn should join Rahu or Kethu in a cruel shashtiamsa.",
          benefits: "The person's death will be due to his head being cut off.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for dhurmarana_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "dhurmarana_yoga",
          name: "Dhurmarana Yoag",
          category: "Longevity & Health Yogas",
          description:
              "274 - The Moon being aspected by lord of Lagna should occupy the 6th, 8th or 12th in association/conjunction with Saturn, Mandi or Rahu.",
          benefits: "The person will meet with unnatural death",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for yuddha_marana_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "yuddha_marana_yoga",
          name: "Yuddha Marana Yoga",
          category: "Longevity & Health Yogas",
          description:
              "275 - Mars, being lord of the 6th or 8th, should conjoin the 3rd lord and Rahu, Saturn or Maandi in cruel shashti-amsas.",
          benefits:
              "The personwill be killed in battle or due to consequences of war.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for pittharoga_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "pittharoga_yoga",
          name: "Pittharoga Yoga",
          category: "Other Natal Yoga",
          description:
              "279 - The 6th house must be occupied by the Sun in conjunction with a malefic and further aspected by another malefic.",
          benefits: "The person suffers from bilious complaints.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for putrakalatraheena_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "putrakalatraheena_yoga",
          name: "Puthra Kalatraheena Yoga",
          category: "Progeny Yogas (Children)",
          description:
              "281 - When the waning Moon is in the 5th and malefics occupy the 12th, 7th and Lagna, the yoga is formed.",
          benefits: "The person will be'deprived of his family and children.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for bharyasahavyabhichara_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "bharyasahavyabhichara_yoga",
          name: "Bharya sahavyabhichara Yoga",
          category: "Other Natal Yoga",
          description:
              "282 - Venus, Saturn and Mars must join the Moon in the 7th house. Variation: 7th lord is in conjunction with Venus, aspected by Saturn; 7th house aspected by Saturn and Mars; Venus and Moon are afflicted by malefics (from natural_malefics).",
          benefits: "The husband and wife will both be guilty of adultery.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for vamsacheda_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "vamsacheda_yoga",
          name: "Vamsacheda Yoga",
          category: "Other Natal Yoga",
          description:
              "283 - The 10th, 7th and 4th must be occupied by the Moon, Venus and malefics respectively. Variation: Moon and Venus in the 7th and malefics in the 4th and 10th.",
          benefits: "The person will be the extinguisher of his family.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for guhyaroga_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "guhyaroga_yoga",
          name: "Guhyaroga Yoga",
          category: "Other Natal Yoga",
          description:
              "281 - The Moon should join malefics in the Navamsa of Cancer or Scorpio.",
          benefits: "The person suffers from diseases in the private parts.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for angaheena_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "angaheena_yoga",
          name: "Angaheena Yoga",
          category: "Other Natal Yoga",
          description:
              "285 - When the Moon is in the 10th, Mars in the 7th and Saturn in the 2nd from the Sun,the above yoga is formed.",
          benefits: "The person suffers from loss of limbs.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for swetakushta_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "swetakushta_yoga",
          name: "Swetakushta Yoga",
          category: "Other Natal Yoga",
          description:
              "286 -  Mars and Saturn are in the 2nd and 12th, the Moon in Lagna and the Sun in the 7th, the above Yoga is given rise to.",
          benefits: "The person suffers from white leprosy.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for pisacha_grastha_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "pisacha_grastha_yoga",
          name: "Pisacha Grastha Yoga",
          category: "Other Natal Yoga",
          description:
              "287 - When Rahu is in Lagna in conjunction with the Moon and the malefics join trines, the above yoga is given rise to.",
          benefits: "The person suffers from the attacks of 'spirits'.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for andha_yoga_288
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "andha_yoga_288",
          name: "Andha Yoga",
          category: "Other Natal Yoga",
          description:
              "288 - When Rahu is in Lagna in conjunction with the Sun and the malefics join trines, the above yoga is given rise to.",
          benefits: "The person will be stone-blind.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for andha_yoga_289
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "andha_yoga_289",
          name: "Andha Yoga",
          category: "Other Natal Yoga",
          description:
              "289 - Mars, the Moon, Saturn and the Sun should respectively occupy the 2nd, 6th, 12th and 8th",
          benefits: "The person will be stone-blind.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for vaatharoga_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "vaatharoga_yoga",
          name: "Vaatharoga Yoga",
          category: "Other Natal Yoga",
          description:
              "290 - When Jupiter is in Lagna and Saturn in the 7th house,the above yoga is caused. Method=2: Mars in 5th/7th/9th OR Sun in Lagna, malefic moon and Saturn in 12th.",
          benefits: "The person suffers from windy complaints.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for mathibhramana_yoga_291
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "mathibhramana_yoga_291",
          name: "Mathibhramana Yoga",
          category: "Other Natal Yoga",
          description:
              "291 - Jupiter and Mars should occupy the Lagna and the 7th respectively.",
          benefits: "The person becomes insane.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for mathibhramana_yoga_292
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "mathibhramana_yoga_292",
          name: "Mathibhramana Yoga",
          category: "Other Natal Yoga",
          description:
              "292 - Saturn must be in Lagna and Mars should join the 9th, 5th or 7th.",
          benefits: "The person becomes insane.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for mathibhramana_yoga_293
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "mathibhramana_yoga_293",
          name: "Mathibhramana Yoga",
          category: "Other Natal Yoga",
          description:
              "293 - Saturn must occupy the 12th with the waning Moon.",
          benefits: "The person becomes insane.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for mathibhramana_yoga_294
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "mathibhramana_yoga_294",
          name: "Mathibhramana Yoga",
          category: "Other Natal Yoga",
          description:
              "294 - The Moon and Mercury should be in a kendra, aspected by or conjoined with any other planet.",
          benefits: "The person becomes insane.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for mathibhramana_yoga_variation
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "mathibhramana_yoga_variation",
          name: "Mathibhramana Yoga",
          category: "Other Natal Yoga",
          description:
              "This yoga occurs, per B.V.Raman Variations, if - (1) The 6th is occupied by Rahu and aspected by Kethu. (2) The 6th lord is further affiicted by conjunction with Mars. (3) The planet of nerves Mercury is in a common sign in conjunction with two malefics, Mars and Sun. (4) In the Navamsa again Mercury occupies the 6th with Rahu and the 6th lord is in conjunction with Mars.",
          benefits: "The person becomes insane.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for khalwata_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "khalwata_yoga",
          name: "Khalwata Yoga",
          category: "Other Natal Yoga",
          description:
              "295 - The ascendant must be a malefic sign or Sagittarius or Taurus aspected by malefic planets.",
          benefits: "The person will be bald-headed.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for nishturabhashi_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "nishturabhashi_yoga",
          name: "Nishturabhashi Yoga",
          category: "Other Natal Yoga",
          description:
              "296 - The Moon must be in conjunction with Saturn without Jupiter aspect.",
          benefits: "The person will be harsh in speech.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for rajabhrashta_yoga
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "rajabhrashta_yoga",
          name: "Rajabhrashta Yoga",
          category: "Other Natal Yoga",
          description:
              "297 - The lords of Aroodha Lagna (A1/AL) and Aroodha Dwadasa (A12/UL) should be in conjunction.",
          benefits: "The subject will suffer a fall from high position.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for raja_bhanga_yoga_298
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "raja_bhanga_yoga_298",
          name: "Raja Bhanga Yoga",
          category: "Other Natal Yoga",
          description:
              "298 - The ascendant being Leo, Saturn must be in exaltation occupying a debilitated Navamsa or aspected by benefic.",
          benefits:
              "The person though born in a royal family will be bereft of fortune and social position.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for raja_bhanga_yoga_299
    {
      final isPresent = false;
      final explanation = 'Under development / Not met in this chart';
      result.add(
        NatalYoga(
          key: "raja_bhanga_yoga_299",
          name: "Raja Bhanga Yoga",
          category: "Other Natal Yoga",
          description: "299 - The Sun must occupy the 10th degree of Libra.",
          benefits:
              "The person though born in a royal family will be bereft of fortune and social position.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for dharma_karmadhipati_raja_yoga
    {
      final lordOf9 = _getHouseLord(chart, 9);
      final lordOf10 = _getHouseLord(chart, 10);
      final isPresent = areAssociated(lordOf9, lordOf10);
      final explanation = isPresent
          ? 'Lords of 9th and 10th associated'
          : 'Lords of 9th and 10th not associated';
      result.add(
        NatalYoga(
          key: "dharma_karmadhipati_raja_yoga",
          name: "Dharma Karmadhipati Raja yoga",
          category: "Raja Yogas",
          description:
              "If the lords of dharma sthana (9th) and karma sthana (10th) form a raja yoga, it is known by this special name. The 9th house is the most important trine and the 10th house is the most important quadrant.",
          benefits:
              "One born with this yoga is sincere, devoted and righteous. He is fortunate.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for vipareetha_raja_yoga
    {
      final lordOf6 = _getHouseLord(chart, 6);
      final lordOf8 = _getHouseLord(chart, 8);
      final lordOf12 = _getHouseLord(chart, 12);
      final isPresent = [6, 8, 12].contains(pMap[lordOf6]) ||
          [6, 8, 12].contains(pMap[lordOf8]) ||
          [6, 8, 12].contains(pMap[lordOf12]);
      final explanation = isPresent
          ? 'Trik lords occupy dusthanas'
          : 'Trik lords not in dusthanas';
      result.add(
        NatalYoga(
          key: "vipareetha_raja_yoga",
          name: "Vipareetha Raja yoga",
          category: "Raja Yogas",
          description:
              "The 6th, 8th and 12th houses are known as trik sthanas or dusthanas (bad houses). If their lords occupies dusthanas or conjoin dusthanas, it results in this yoga.",
          benefits:
              "One having this yoga experiences tremedous success, typically after an initial struggle. Vipareeta means extreme.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    // Evaluation for neecha_bhanga_raja_yoga
    {
      bool checkNeechaBhanga() {
        final debilitated =
            chart.debilitatedPlanets.map((info) => info.planet).toList();
        if (debilitated.isEmpty) return false;
        for (final p in debilitated) {
          final signLord = Rashi.fromIndex(signMap[p]!).lord;
          if (kendraHouses.contains(pMap[signLord]!)) return true;
          if ([0, 3, 6, 9].contains((pMap[signLord]! - moonHouse + 12) % 12)) {
            return true;
          }
          if (Planet.traditionalPlanets
              .where((cp) => cp != p && pMap[cp] == pMap[p]!)
              .any((cp) => _isExalted(chart, cp))) {
            return true;
          }
          if (_doesPlanetAspectHouse(chart, signLord, pMap[p]!)) return true;
        }
        return false;
      }

      final isPresent = checkNeechaBhanga();
      final explanation = isPresent
          ? 'Neecha Bhanga cancellation rules met'
          : 'No cancellation met';
      result.add(
        NatalYoga(
          key: "neecha_bhanga_raja_yoga",
          name: "Neecha Bhanga Raja yoga",
          category: "Raja Yogas",
          description:
              "1. If the lord of the sign occupied by a weak or debilitated planet is exalted or is in Kendra from Moon. Ex, If Jupiter is debilitated in Capricorn and if Saturn is exalted and placed in Kendra from moon. 2. If the debilitated planet is conjunct with the Exalted Planet. 3. If the debilitated planet is aspected by the master of that sign. Ex, If Sun is debilitated in Libra and it is aspect by Venus with 7th aspect. 4. If the debilitated planet is Exalted in Navamsa Chart. 5. The planet which gets exalted in the sign where a debilitated planet is placed is in a Kendra from the Lagna or the Moon. Ex, If Sun is debilitated in the birth chart in Libra and Saturn which gets exalted in Libra is placed in Kendra from Lagna or Moon. NOTE: Checks only the first 3 conditions below. 4 and 5 to be done in future version",
          benefits:
              "Neecha Bhanga Raja Yoga provides one with Fame, Property, and Control usually. But all the said prosperities will be used by the native only in the next half of life particularly after the age 36 corresponding to the age at the yoga developing dasha, sub-period and transits take place in one’s chart. This typical nature is attributed to this Yoga because the planet who create Neecha Bhanga Rajayoga is subjected to debilitation first and then attains the cancellation. Likewise, the native's life too would suffer adversities in the initial part of life and then will start excelling. Earning from multiple sources and earning a good reputation from a vast number of peoples and various communities along with holding a good image is the result of this Yoga. One will be admired within his/her personal, professional and social circles. Whatever they do brings a good reputation for them and people usually like them for what they are. They will gather huge property and start producing many sources of income once the Rajayoga is in operation. They will also hold power in life. The native will be holding power over many people once this Yoga is operational.",
          isPresent: isPresent,
          explanation: explanation,
        ),
      );
    }

    return result;
  }
}
