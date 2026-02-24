import '../models/planet.dart';
import '../models/rashi.dart';
import '../models/vedic_chart.dart';
import '../models/compatibility.dart';

class CompatibilityService {
  CompatibilityService();

  CompatibilityResult calculateCompatibility(
      VedicChart boyChart, VedicChart girlChart) {
    final gunaScores = calculateGunaMilan(boyChart, girlChart);
    final doshaCheck = checkDoshas(boyChart, girlChart);
    final dashaCompatibility = calculateDashaCompatibility(boyChart, girlChart);

    var totalScore = gunaScores.total;
    final analysis = <String>[];

    if (doshaCheck.hasNadiDosha) {
      totalScore -= 8;
      analysis.add('Nadi Dosha reduces compatibility');
    }
    if (doshaCheck.hasBhakootDosha) {
      totalScore -= 7;
      analysis.add('Bhakoot Dosha present');
    }
    if (doshaCheck.hasManglikDosha) {
      totalScore -= doshaCheck.manglikSeverity == 'High' ? 5 : 3;
      analysis.add('Manglik Dosha needs consideration');
    }

    if (doshaCheck.cancellations.isNotEmpty) {
      analysis.addAll(doshaCheck.cancellations);
    }

    final level = _getCompatibilityLevel(totalScore);

    return CompatibilityResult(
      totalScore: totalScore.clamp(0, 36),
      level: level,
      gunaScores: gunaScores,
      doshaCheck: doshaCheck,
      dashaCompatibility: dashaCompatibility,
      analysis: analysis,
    );
  }

  GunaScores calculateGunaMilan(VedicChart boyChart, VedicChart girlChart) {
    final boyMoonInfo = boyChart.getPlanet(Planet.moon);
    final girlMoonInfo = girlChart.getPlanet(Planet.moon);

    final boyNakshatra = boyMoonInfo?.nakshatra ?? 'Ashwini';
    final girlNakshatra = girlMoonInfo?.nakshatra ?? 'Ashwini';
    final boyPada = boyMoonInfo?.pada ?? 1;
    final girlPada = girlMoonInfo?.pada ?? 1;

    return GunaScores(
      varna: calculateVarna(boyNakshatra, girlNakshatra),
      vashya: calculateVashya(boyNakshatra, girlNakshatra),
      tara: calculateTara(boyNakshatra, girlNakshatra, boyPada, girlPada),
      yoni: calculateYoni(boyNakshatra, girlNakshatra),
      grahaMaitri: calculateGrahaMaitri(boyChart, girlChart),
      gana: calculateGana(boyNakshatra, girlNakshatra),
      bhakoot: calculateBhakoot(boyChart, girlChart),
      nadi: calculateNadi(boyChart, girlChart),
    );
  }

  // ─── Varna Koota (max 1 point) ──────────────────────────────────────────────
  // Per standard Vedic texts (Muhurta Chintamani / Jataka Parijata):
  // Brahmin > Kshatriya > Vaishya > Shudra
  // Score 1 if boy's varna >= girl's varna, 0 otherwise.

  int calculateVarna(String boyNakshatra, String girlNakshatra) {
    const varnaOrder = ['Brahmin', 'Kshatriya', 'Vaishya', 'Shudra'];
    final boyVarna = _getNakshatraVarna(boyNakshatra);
    final girlVarna = _getNakshatraVarna(girlNakshatra);

    if (boyVarna == girlVarna) return 1;
    if (varnaOrder.indexOf(boyVarna) < varnaOrder.indexOf(girlVarna)) return 1;
    return 0;
  }

  /// Returns the Varna for a given nakshatra per standard classification.
  ///
  /// Sources: Muhurta Chintamani, Brihat Parashara Hora Shastra
  String _getNakshatraVarna(String nakshatra) {
    // Brahmin: Krittika, Pushya, Ashlesha, Magha, U. Phalguni, Hasta,
    //          Swati, Anuradha, Shravana, P. Ashadha, P. Bhadrapada, Revati
    if ([
      'Krittika',
      'Pushya',
      'Ashlesha',
      'Magha',
      'Uttara Phalguni',
      'Hasta',
      'Swati',
      'Anuradha',
      'Shravana',
      'Purva Ashadha',
      'Purva Bhadrapada',
      'Revati',
    ].contains(nakshatra)) {
      return 'Brahmin';
    }
    // Kshatriya: Ashwini, Bharani, P. Phalguni, Chitra, Vishakha, Jyeshtha,
    //            U. Ashadha, Dhanishta, Shatabhisha, U. Bhadrapada
    if ([
      'Ashwini',
      'Bharani',
      'Purva Phalguni',
      'Chitra',
      'Vishakha',
      'Jyeshtha',
      'Uttara Ashadha',
      'Dhanishta',
      'Shatabhisha',
      'Uttara Bhadrapada',
    ].contains(nakshatra)) {
      return 'Kshatriya';
    }
    // Vaishya: Rohini, Mrigashira, Ardra, Punarvasu
    if ([
      'Rohini',
      'Mrigashira',
      'Ardra',
      'Punarvasu',
    ].contains(nakshatra)) {
      return 'Vaishya';
    }
    // Shudra: Mula (remaining)
    return 'Shudra';
  }

  // ─── Vashya Koota (max 2 points) ────────────────────────────────────────────
  // Traditional 5-category Vashya: Manava (human), Vanachara (wild),
  // Chatushpada (quadruped), Jalachara (aquatic), Keeta (insect).
  // Score 2 = same category, 1 = compatible, 0 = incompatible.

  int calculateVashya(String boyNakshatra, String girlNakshatra) {
    final boyVashya = _getNakshatraVashya(boyNakshatra);
    final girlVashya = _getNakshatraVashya(girlNakshatra);

    if (boyVashya == girlVashya) return 2;
    // Compatible pairs per tradition
    if ((boyVashya == 'Manava' && girlVashya == 'Vanachara') ||
        (boyVashya == 'Vanachara' && girlVashya == 'Manava')) return 1;
    if ((boyVashya == 'Chatushpada' && girlVashya == 'Keeta') ||
        (boyVashya == 'Keeta' && girlVashya == 'Chatushpada')) return 1;
    return 0;
  }

  String _getNakshatraVashya(String nakshatra) {
    // Manava (human): Bharani, Ardra, Punarvasu, Hasta, Swati, Jyeshtha,
    //                 Shravana, Dhanishta, Shatabhisha, P. Bhadrapada, U. Bhadrapada, Revati
    if ([
      'Bharani',
      'Ardra',
      'Punarvasu',
      'Hasta',
      'Swati',
      'Jyeshtha',
      'Shravana',
      'Dhanishta',
      'Shatabhisha',
      'Purva Bhadrapada',
      'Uttara Bhadrapada',
      'Revati',
    ].contains(nakshatra)) return 'Manava';

    // Vanachara (forest-dwelling): Ashwini, Mrigashira, Pushya, Chitra,
    //                              Vishakha, Mula, Uttara Ashadha
    if ([
      'Ashwini',
      'Mrigashira',
      'Pushya',
      'Chitra',
      'Vishakha',
      'Mula',
      'Uttara Ashadha',
    ].contains(nakshatra)) return 'Vanachara';

    // Chatushpada (quadruped): Krittika, Rohini, Magha, U. Phalguni,
    //                           Anuradha, P. Ashadha
    if ([
      'Krittika',
      'Rohini',
      'Magha',
      'Uttara Phalguni',
      'Anuradha',
      'Purva Ashadha',
    ].contains(nakshatra)) return 'Chatushpada';

    // Jalajiva (aquatic): Ashlesha, Purva Phalguni
    if (['Ashlesha', 'Purva Phalguni'].contains(nakshatra)) return 'Jalajiva';

    // Keeta (insect/reptile): Krittika (some texts), default
    return 'Keeta';
  }

  // ─── Tara Koota (max 3 points) ──────────────────────────────────────────────

  int calculateTara(
      String boyNakshatra, String girlNakshatra, int boyPada, int girlPada) {
    final boyNakshatraNum = _getNakshatraNumber(boyNakshatra);
    final girlNakshatraNum = _getNakshatraNumber(girlNakshatra);

    // Count from boy's nakshatra to girl's, forward
    final taraCount = ((girlNakshatraNum - boyNakshatraNum) % 27 + 27) % 27;
    // Which group of 9? (1=birth, 2=sampat, 3=vipat, 4=kshema, 5=pratyak,
    //                    6=sadhaka, 7=vadha, 8=mitra, 9=atimitra)
    final taraGroup = (taraCount ~/ 9) + 1;

    // Auspicious: 1 (birth), 3 (vipat—avoid), 5 (pratyak—avoid), 7 (vadha—avoid)
    // Inauspicious: 3, 5, 7
    if (taraGroup == 3 || taraGroup == 5 || taraGroup == 7) return 0;
    if (taraGroup == 1 ||
        taraGroup == 2 ||
        taraGroup == 4 ||
        taraGroup == 6 ||
        taraGroup == 8 ||
        taraGroup == 9) return 3;
    return 1;
  }

  int _getNakshatraNumber(String nakshatra) {
    const nakshatras = [
      'Ashwini',
      'Bharani',
      'Krittika',
      'Rohini',
      'Mrigashira',
      'Ardra',
      'Punarvasu',
      'Pushya',
      'Ashlesha',
      'Magha',
      'Purva Phalguni',
      'Uttara Phalguni',
      'Hasta',
      'Chitra',
      'Swati',
      'Vishakha',
      'Anuradha',
      'Jyeshtha',
      'Mula',
      'Purva Ashadha',
      'Uttara Ashadha',
      'Shravana',
      'Dhanishta',
      'Shatabhisha',
      'Purva Bhadrapada',
      'Uttara Bhadrapada',
      'Revati'
    ];
    final index = nakshatras.indexOf(nakshatra);
    return index >= 0 ? index + 1 : 1;
  }

  // ─── Yoni Koota (max 4 points) ──────────────────────────────────────────────
  // Per BPHS / standard texts: each nakshatra has an animal symbol (male/female).
  // Scoring: same animal = 4, friendly = 2, neutral = 1, enemy = 0.

  int calculateYoni(String boyNakshatra, String girlNakshatra) {
    // Standard Yoni animal per nakshatra (27 nakshatras)
    const yoniAnimals = {
      'Ashwini': 'Horse',
      'Bharani': 'Elephant',
      'Krittika': 'Goat',
      'Rohini': 'Serpent',
      'Mrigashira': 'Snake',
      'Ardra': 'Dog',
      'Punarvasu': 'Cat',
      'Pushya': 'Goat',
      'Ashlesha': 'Cat',
      'Magha': 'Rat',
      'Purva Phalguni': 'Rat',
      'Uttara Phalguni': 'Cow',
      'Hasta': 'Buffalo',
      'Chitra': 'Tiger',
      'Swati': 'Buffalo',
      'Vishakha': 'Tiger',
      'Anuradha': 'Deer',
      'Jyeshtha': 'Deer',
      'Mula': 'Dog',
      'Purva Ashadha': 'Monkey',
      'Uttara Ashadha': 'Mongoose',
      'Shravana': 'Monkey',
      'Dhanishta': 'Lion',
      'Shatabhisha': 'Horse',
      'Purva Bhadrapada': 'Lion',
      'Uttara Bhadrapada': 'Cow',
      'Revati': 'Elephant',
    };

    final boyAnimal = yoniAnimals[boyNakshatra] ?? 'Unknown';
    final girlAnimal = yoniAnimals[girlNakshatra] ?? 'Unknown';

    if (boyAnimal == girlAnimal) return 4;
    if (_areYoniFriends(boyAnimal, girlAnimal)) return 2;
    if (_areYoniEnemies(boyAnimal, girlAnimal)) return 0;
    return 1; // Neutral
  }

  bool _areYoniFriends(String a1, String a2) {
    const friendlyPairs = [
      ['Horse', 'Elephant'],
      ['Goat', 'Cow'],
      ['Serpent', 'Mongoose'],
      ['Dog', 'Cat'],
      ['Rat', 'Monkey'],
      ['Tiger', 'Deer'],
      ['Buffalo', 'Lion'],
    ];
    return friendlyPairs.any((pair) =>
        (pair[0] == a1 && pair[1] == a2) || (pair[0] == a2 && pair[1] == a1));
  }

  bool _areYoniEnemies(String a1, String a2) {
    const enemyPairs = [
      ['Serpent', 'Mongoose'],
      ['Dog', 'Deer'],
      ['Cat', 'Rat'],
      ['Goat', 'Tiger'],
      ['Elephant', 'Lion'],
      ['Horse', 'Buffalo'],
      ['Monkey', 'Cow'],
    ];
    return enemyPairs.any((pair) =>
        (pair[0] == a1 && pair[1] == a2) || (pair[0] == a2 && pair[1] == a1));
  }

  // ─── Graha Maitri / Rashyadhipati Maitri Koota (max 5 points) ───────────────
  // Based on friendship between Moon sign lords of bride and groom.
  // Planet friendship table from Brihat Parashara Hora Shastra.

  int calculateGrahaMaitri(VedicChart boyChart, VedicChart girlChart) {
    final boyMoonSign =
        Rashi.fromLongitude(boyChart.getPlanet(Planet.moon)?.longitude ?? 0);
    final girlMoonSign =
        Rashi.fromLongitude(girlChart.getPlanet(Planet.moon)?.longitude ?? 0);

    final boyLord = _getSignLord(boyMoonSign);
    final girlLord = _getSignLord(girlMoonSign);

    // Mutual friendship between lords determines score
    final boyToGirl = _planetFriendship(boyLord, girlLord);
    final girlToBoy = _planetFriendship(girlLord, boyLord);

    // Both friends = 5, one friend (mutual) = 4, friend+neutral = 4,
    // both neutral = 3, friend+enemy = 2, both enemy = 0
    if (boyToGirl == 2 && girlToBoy == 2) return 5; // Mutual friends
    if (boyToGirl == 2 && girlToBoy == 1) return 4;
    if (boyToGirl == 1 && girlToBoy == 2) return 4;
    if (boyToGirl == 1 && girlToBoy == 1) return 3; // Both neutral
    if (boyToGirl == 2 && girlToBoy == -1) return 2;
    if (boyToGirl == -1 && girlToBoy == 2) return 2;
    if (boyToGirl == 1 && girlToBoy == -1) return 1;
    if (boyToGirl == -1 && girlToBoy == 1) return 1;
    return 0; // Both enemies
  }

  /// Returns the sign lord (planet) for a given Rashi per standard rules.
  Planet _getSignLord(Rashi rashi) {
    return switch (rashi) {
      Rashi.aries || Rashi.scorpio => Planet.mars,
      Rashi.taurus || Rashi.libra => Planet.venus,
      Rashi.gemini || Rashi.virgo => Planet.mercury,
      Rashi.cancer => Planet.moon,
      Rashi.leo => Planet.sun,
      Rashi.sagittarius || Rashi.pisces => Planet.jupiter,
      Rashi.capricorn || Rashi.aquarius => Planet.saturn,
    };
  }

  /// Returns the natural friendship level between two planets.
  /// 2 = friend, 1 = neutral, -1 = enemy
  /// Source: BPHS natural friendship table.
  int _planetFriendship(Planet p1, Planet p2) {
    // Natural friends of each planet
    const friends = {
      Planet.sun: [Planet.moon, Planet.mars, Planet.jupiter],
      Planet.moon: [Planet.sun, Planet.mercury],
      Planet.mars: [Planet.sun, Planet.moon, Planet.jupiter],
      Planet.mercury: [Planet.sun, Planet.venus],
      Planet.jupiter: [Planet.sun, Planet.moon, Planet.mars],
      Planet.venus: [Planet.mercury, Planet.saturn],
      Planet.saturn: [Planet.mercury, Planet.venus],
    };
    // Natural enemies
    const enemies = {
      Planet.sun: [Planet.saturn, Planet.venus],
      Planet.moon: [Planet.saturn, Planet.mars, Planet.venus, Planet.jupiter],
      Planet.mars: [Planet.mercury],
      Planet.mercury: [Planet.moon],
      Planet.jupiter: [Planet.mercury, Planet.venus],
      Planet.venus: [Planet.sun, Planet.moon],
      Planet.saturn: [Planet.sun, Planet.moon, Planet.mars],
    };

    if (friends[p1]?.contains(p2) == true) return 2;
    if (enemies[p1]?.contains(p2) == true) return -1;
    return 1; // neutral
  }

  // ─── Gana Koota (max 6 points) ──────────────────────────────────────────────
  // Per BPHS / standard Jyotish:
  // Deva (divine), Manushya (human), Rakshasa (demon)
  // Scoring: same Gana = 6, compatible pairs = 3, incompatible = 0.

  int calculateGana(String boyNakshatra, String girlNakshatra) {
    // Standard Gana classification per BPHS
    const ganaTypes = {
      'Deva': [
        'Ashwini', // 1
        'Mrigashira', // 5
        'Punarvasu', // 7
        'Pushya', // 8
        'Hasta', // 13
        'Swati', // 15
        'Anuradha', // 17
        'Shravana', // 22
        'Revati', // 27
      ],
      'Manushya': [
        'Bharani', // 2
        'Rohini', // 4
        'Ardra', // 6
        'Purva Phalguni', // 11
        'Uttara Phalguni', // 12
        'Purva Ashadha', // 20
        'Uttara Ashadha', // 21
        'Purva Bhadrapada', // 25
        'Uttara Bhadrapada', // 26
      ],
      'Rakshasa': [
        'Krittika', // 3
        'Ashlesha', // 9
        'Magha', // 10
        'Chitra', // 14
        'Vishakha', // 16
        'Jyeshtha', // 18
        'Mula', // 19
        'Dhanishta', // 23
        'Shatabhisha', // 24
      ],
    };

    final boyGana = _getGanaType(boyNakshatra, ganaTypes);
    final girlGana = _getGanaType(girlNakshatra, ganaTypes);

    if (boyGana == girlGana) return 6;
    // Deva+Manushya is compatible (3 pts), Manushya+Deva also 3 pts
    if ((boyGana == 'Deva' && girlGana == 'Manushya') ||
        (boyGana == 'Manushya' && girlGana == 'Deva')) return 3;
    // All combinations with Rakshasa score 0
    return 0;
  }

  String _getGanaType(String nakshatra, Map<String, List<String>> ganaTypes) {
    for (final entry in ganaTypes.entries) {
      if (entry.value.contains(nakshatra)) return entry.key;
    }
    return 'Manushya'; // default
  }

  // ─── Bhakoot Koota (max 7 points) ───────────────────────────────────────────
  // Score 7 if Moon signs have no problematic inter-sign relationship.
  // Bhakoot Dosha occurs for sign differences of 2/12, 5/9, or 6/8.
  // Score 0 if dosha, 7 otherwise.

  int calculateBhakoot(VedicChart boyChart, VedicChart girlChart) {
    final boyMoonSign =
        Rashi.fromLongitude(boyChart.getPlanet(Planet.moon)?.longitude ?? 0);
    final girlMoonSign =
        Rashi.fromLongitude(girlChart.getPlanet(Planet.moon)?.longitude ?? 0);

    final boySignNum = boyMoonSign.index + 1; // 1-based
    final girlSignNum = girlMoonSign.index + 1;

    // Forward distance from boy to girl (1–12)
    final fwd = ((girlSignNum - boySignNum) % 12 + 12) % 12;
    // Reverse distance (complement)
    final rev = fwd == 0 ? 0 : 12 - fwd;

    // Dosha-forming pairs: 2/12, 5/9, 6/8
    // fwd==0 (same sign) is fine (no dosha)
    if (fwd == 0) return 7;

    final pair = {fwd, rev}; // set of both directions
    if (pair.containsAll({2, 12}) ||
        pair.containsAll({5, 9}) ||
        pair.containsAll({6, 8})) {
      return 0; // Bhakoot Dosha
    }
    return 7;
  }

  // ─── Nadi Koota (max 8 points) ──────────────────────────────────────────────
  // Nadi is determined by CYCLIC grouping of nakshatras (1,4,7,10... = Adi;
  // 2,5,8,11... = Madhya; 3,6,9,12... = Antya).
  // NOT sequential blocks of 9.
  // Score 0 if same Nadi (Nadi Dosha), 8 if different.

  int calculateNadi(VedicChart boyChart, VedicChart girlChart) {
    final boyMoonInfo = boyChart.getPlanet(Planet.moon);
    final girlMoonInfo = girlChart.getPlanet(Planet.moon);

    final boyNadi =
        _getNadiFromNakshatraIndex(boyMoonInfo?.position.nakshatraIndex ?? 0);
    final girlNadi =
        _getNadiFromNakshatraIndex(girlMoonInfo?.position.nakshatraIndex ?? 0);

    if (boyNadi == girlNadi) return 0; // Nadi Dosha
    return 8;
  }

  /// Returns Nadi (0=Adi, 1=Madhya, 2=Antya) using cyclic nakshatra grouping.
  ///
  /// Nakshatras 1,4,7,10,13,16,19,22,25 = Adi (index % 3 == 0)
  /// Nakshatras 2,5,8,11,14,17,20,23,26 = Madhya (index % 3 == 1)
  /// Nakshatras 3,6,9,12,15,18,21,24,27 = Antya (index % 3 == 2)
  int _getNadiFromNakshatraIndex(int zeroBasedIndex) {
    return zeroBasedIndex % 3;
  }

  DoshaCheck checkDoshas(VedicChart boyChart, VedicChart girlChart) {
    final manglikBoy = checkManglikDosha(boyChart);
    final manglikGirl = checkManglikDosha(girlChart);
    final nadiDosha = checkNadiDosha(boyChart, girlChart);
    final bhakootDosha = checkBhakootDosha(boyChart, girlChart);

    final cancellations = <String>[];

    if (manglikBoy.isManglik && nadiDosha.hasDosha) {
      cancellations.add('Nadi Dosha cancels Manglik Dosha');
    }
    if (manglikGirl.isManglik && nadiDosha.hasDosha) {
      cancellations.add('Nadi Dosha cancels Manglik Dosha');
    }

    return DoshaCheck(
      hasManglikDosha: manglikBoy.isManglik || manglikGirl.isManglik,
      hasNadiDosha: nadiDosha.hasDosha,
      hasBhakootDosha: bhakootDosha.hasDosha,
      manglikSeverity: manglikBoy.severity,
      cancellations: cancellations,
    );
  }

  ManglikDoshaResult checkManglikDosha(VedicChart chart) {
    final houses = <int>[];
    for (final entry in chart.planets.entries) {
      final planet = entry.key;
      if (planet != Planet.mars) continue;

      final house = entry.value.house;
      if ([1, 2, 4, 7, 8, 12].contains(house)) {
        houses.add(house);
      }
    }

    return ManglikDoshaResult(
      isManglik: houses.isNotEmpty,
      housesAffected: houses,
      severity: houses.length > 2 ? 'High' : 'Low',
      remedies: houses.isNotEmpty
          ? [
              'Chant Mangal Mantra',
              'Donate red clothes on Tuesdays',
              'Fast on Tuesdays'
            ]
          : [],
    );
  }

  NadiDoshaResult checkNadiDosha(VedicChart boyChart, VedicChart girlChart) {
    final boyMoon = boyChart.getPlanet(Planet.moon);
    final girlMoon = girlChart.getPlanet(Planet.moon);

    final boyNadi =
        _getNadiFromNakshatraIndex(boyMoon?.position.nakshatraIndex ?? 0);
    final girlNadi =
        _getNadiFromNakshatraIndex(girlMoon?.position.nakshatraIndex ?? 0);

    return NadiDoshaResult(
      hasDosha: boyNadi == girlNadi,
      boyNadi: ['Adi', 'Madhya', 'Antya'][boyNadi],
      girlNadi: ['Adi', 'Madhya', 'Antya'][girlNadi],
    );
  }

  BhakootDoshaResult checkBhakootDosha(
      VedicChart boyChart, VedicChart girlChart) {
    final boyMoonSign =
        Rashi.fromLongitude(boyChart.getPlanet(Planet.moon)?.longitude ?? 0);
    final girlMoonSign =
        Rashi.fromLongitude(girlChart.getPlanet(Planet.moon)?.longitude ?? 0);

    final boySignNum = boyMoonSign.index + 1;
    final girlSignNum = girlMoonSign.index + 1;
    final fwd = ((girlSignNum - boySignNum) % 12 + 12) % 12;
    final rev = fwd == 0 ? 0 : 12 - fwd;
    final pair = {fwd, rev};

    // Bhakoot Dosha: 2/12, 5/9, or 6/8 inter-sign relationships
    final hasDosha = fwd != 0 &&
        (pair.containsAll({2, 12}) ||
            pair.containsAll({5, 9}) ||
            pair.containsAll({6, 8}));

    String description;
    if (!hasDosha) {
      description = 'No Bhakoot Dosha';
    } else if (pair.containsAll({6, 8})) {
      description =
          'Moon signs in 6/8 relationship — Bhakoot Dosha (most severe)';
    } else if (pair.containsAll({2, 12})) {
      description = 'Moon signs in 2/12 relationship — Bhakoot Dosha';
    } else {
      description = 'Moon signs in 5/9 relationship — Bhakoot Dosha';
    }

    return BhakootDoshaResult(
      hasDosha: hasDosha,
      boyRashi: boyMoonSign.name,
      girlRashi: girlMoonSign.name,
      description: description,
    );
  }

  DashaCompatibility calculateDashaCompatibility(
      VedicChart boyChart, VedicChart girlChart) {
    const score = 5;
    final analysis = <String>[];

    analysis.add('Dasha compatibility is an advanced feature');
    analysis.add('Further analysis requires detailed Dasha timing');

    return DashaCompatibility(
      score: score,
      analysis: analysis,
    );
  }

  CompatibilityLevel _getCompatibilityLevel(int score) {
    if (score >= 33) return CompatibilityLevel.excellent;
    if (score >= 25) return CompatibilityLevel.veryGood;
    if (score >= 18) return CompatibilityLevel.good;
    if (score >= 12) return CompatibilityLevel.average;
    return CompatibilityLevel.poor;
  }
}
