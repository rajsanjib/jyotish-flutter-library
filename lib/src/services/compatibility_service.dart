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
      totalScore: totalScore.clamp(0.0, 36.0), // Clamped with doubles
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
      vashya: calculateVashya(boyChart, girlChart),
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

  int calculateVashya(VedicChart boyChart, VedicChart girlChart) {
    final boyMoonLong = boyChart.getPlanet(Planet.moon)?.longitude ?? 0;
    final girlMoonLong = girlChart.getPlanet(Planet.moon)?.longitude ?? 0;
    final boyMoonSign = Rashi.fromLongitude(boyMoonLong);
    final girlMoonSign = Rashi.fromLongitude(girlMoonLong);

    final boyVashya = _getRashiVashya(boyMoonSign, boyMoonLong);
    final girlVashya = _getRashiVashya(girlMoonSign, girlMoonLong);

    if (boyVashya == girlVashya) return 2;
    // Compatible pairs per tradition
    if ((boyVashya == 'Manava' && girlVashya == 'Vanachara') ||
        (boyVashya == 'Vanachara' && girlVashya == 'Manava')) return 1;
    if ((boyVashya == 'Chatushpada' && girlVashya == 'Keeta') ||
        (boyVashya == 'Keeta' && girlVashya == 'Chatushpada')) return 1;
    return 0;
  }

  /// Returns Vashya category for a Moon sign.
  ///
  /// Dual signs (Sagittarius, Capricorn) are split at the 15° boundary per
  /// classical texts to account for their mixed Vashya nature.
  String _getRashiVashya(Rashi rashi, double longitude) {
    final degreeInSign = longitude % 30; // 0–30° within the sign
    switch (rashi) {
      // Dual-Vashya signs: split at 15°
      case Rashi.sagittarius:
        // 0°–15° Sagittarius → Chatushpada (animal); 15°–30° → Manava (human)
        return degreeInSign < 15 ? 'Chatushpada' : 'Manava';
      case Rashi.capricorn:
        // 0°–15° Capricorn → Chatushpada; 15°–30° → Jalachara (aquatic)
        return degreeInSign < 15 ? 'Chatushpada' : 'Jalachara';
      // Standard single-Vashya signs
      case Rashi.gemini || Rashi.virgo || Rashi.libra || Rashi.aquarius:
        return 'Manava';
      case Rashi.leo:
        return 'Vanachara';
      case Rashi.aries || Rashi.taurus:
        return 'Chatushpada';
      case Rashi.cancer || Rashi.pisces:
        return 'Jalachara';
      case Rashi.scorpio:
        return 'Keeta';
    }
  }

  // ─── Tara Koota (max 3 points) ──────────────────────────────────────────────
  // Calculated in both directions (Boy -> Girl and Girl -> Boy).
  // Each direction yields 1.5 (auspicious) or 0 (inauspicious). Maximum score 3.

  double calculateTara(
      String boyNakshatra, String girlNakshatra, int boyPada, int girlPada) {
    final boyNakshatraNum = _getNakshatraNumber(boyNakshatra);
    final girlNakshatraNum = _getNakshatraNumber(girlNakshatra);

    double score = 0;

    // Boy to Girl
    final boyToGirlCount =
        ((girlNakshatraNum - boyNakshatraNum) % 27 + 27) % 27;
    final boyToGirlGroup = (boyToGirlCount ~/ 9) + 1;
    if (_isTaraAuspicious(boyToGirlGroup)) {
      score += 1.5;
    }

    // Girl to Boy
    final girlToBoyCount =
        ((boyNakshatraNum - girlNakshatraNum) % 27 + 27) % 27;
    final girlToBoyGroup = (girlToBoyCount ~/ 9) + 1;
    if (_isTaraAuspicious(girlToBoyGroup)) {
      score += 1.5;
    }

    return score;
  }

  bool _isTaraAuspicious(int taraGroup) {
    // Inauspicious: 3 (vipat), 5 (pratyak), 7 (vadha)
    return taraGroup != 3 && taraGroup != 5 && taraGroup != 7;
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
      'Mrigashira': 'Serpent',
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

    if (boyAnimal == 'Unknown' || girlAnimal == 'Unknown') return 1;

    const yoniNames = [
      'Horse',
      'Elephant',
      'Goat',
      'Serpent',
      'Dog',
      'Cat',
      'Rat',
      'Cow',
      'Buffalo',
      'Tiger',
      'Deer',
      'Monkey',
      'Mongoose',
      'Lion'
    ];

    const yoniScoreMatrix = [
      // Horse (0)
      [4, 3, 2, 3, 2, 2, 2, 2, 0, 2, 2, 3, 2, 2],
      // Elephant (1)
      [3, 4, 3, 3, 2, 2, 2, 2, 3, 2, 2, 3, 2, 0],
      // Goat (2) [Sheep]
      [2, 3, 4, 2, 2, 2, 2, 3, 3, 2, 2, 0, 3, 2],
      // Serpent (3) [Snake]
      [3, 3, 2, 4, 2, 3, 2, 2, 2, 2, 2, 2, 0, 2],
      // Dog (4)
      [2, 2, 2, 2, 4, 3, 3, 2, 2, 2, 0, 2, 2, 2],
      // Cat (5)
      [2, 2, 2, 3, 3, 4, 0, 2, 2, 2, 3, 3, 2, 2],
      // Rat (6)
      [2, 2, 2, 2, 3, 0, 4, 2, 2, 2, 2, 2, 2, 2],
      // Cow (7)
      [2, 2, 3, 2, 2, 2, 2, 4, 3, 0, 2, 2, 2, 2],
      // Buffalo (8)
      [0, 3, 3, 2, 2, 2, 2, 3, 4, 2, 2, 2, 2, 2],
      // Tiger (9)
      [2, 2, 2, 2, 2, 2, 2, 0, 2, 4, 2, 2, 2, 3],
      // Deer (10)
      [2, 2, 2, 2, 0, 3, 2, 2, 2, 2, 4, 2, 2, 2],
      // Monkey (11)
      [3, 3, 0, 2, 2, 3, 2, 2, 2, 2, 2, 4, 3, 2],
      // Mongoose (12)
      [2, 2, 3, 0, 2, 2, 2, 2, 2, 2, 2, 3, 4, 2],
      // Lion (13)
      [2, 0, 2, 2, 2, 2, 2, 2, 2, 3, 2, 2, 2, 4],
    ];

    final boyIdx = yoniNames.indexOf(boyAnimal);
    final girlIdx = yoniNames.indexOf(girlAnimal);

    if (boyIdx == -1 || girlIdx == -1) return 1; // Fallback

    return yoniScoreMatrix[boyIdx][girlIdx];
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

    if (boyLord == girlLord) return 5; // Same sign lord

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

    if (_isBhakootDoshaCancelled(boyMoonSign, girlMoonSign)) {
      return 7;
    }

    final boySignNum = boyMoonSign.index + 1; // 1-based
    final girlSignNum = girlMoonSign.index + 1;

    // Forward distance from boy to girl (1-based index)
    // Example: Aries(1) to Taurus(2) => fwd_dist = 2
    int fwdDist = girlSignNum - boySignNum + 1;
    if (fwdDist <= 0) fwdDist += 12;

    // Reverse distance (girl to boy)
    int revDist = boySignNum - girlSignNum + 1;
    if (revDist <= 0) revDist += 12;

    // Dosha-forming pairs: (2, 12), (5, 9), (6, 8)
    // If same sign (fwdDist == 1, revDist == 1), it's fine
    if (fwdDist == 1) return 7;

    final pair = {fwdDist, revDist};
    if (pair.containsAll({2, 12}) ||
        pair.containsAll({5, 9}) ||
        pair.containsAll({6, 8})) {
      return 0; // Bhakoot Dosha
    }
    return 7;
  }

  bool _isBhakootDoshaCancelled(Rashi boySign, Rashi girlSign) {
    final boyLord = _getSignLord(boySign);
    final girlLord = _getSignLord(girlSign);

    // Rule 1: Same lord cancels dosha
    if (boyLord == girlLord) return true;

    // Rule 2: Mutual friends cancel dosha
    final boyToGirl = _planetFriendship(boyLord, girlLord);
    final girlToBoy = _planetFriendship(girlLord, boyLord);
    if (boyToGirl == 2 && girlToBoy == 2) return true;

    return false;
  }

  // ─── Nadi Koota (max 8 points) ──────────────────────────────────────────────
  // Nadi is determined by CYCLIC grouping of nakshatras (1,4,7,10... = Adi;
  // 2,5,8,11... = Madhya; 3,6,9,12... = Antya).
  // NOT sequential blocks of 9.
  // Score 0 if same Nadi (Nadi Dosha), 8 if different.

  int calculateNadi(VedicChart boyChart, VedicChart girlChart) {
    final boyMoonInfo = boyChart.getPlanet(Planet.moon);
    final girlMoonInfo = girlChart.getPlanet(Planet.moon);

    if (_isNadiDoshaCancelled(boyChart, girlChart)) {
      return 8;
    }

    final boyNadi =
        _getNadiFromNakshatraIndex(boyMoonInfo?.position.nakshatraIndex ?? 0);
    final girlNadi =
        _getNadiFromNakshatraIndex(girlMoonInfo?.position.nakshatraIndex ?? 0);

    if (boyNadi == girlNadi) return 0; // Nadi Dosha
    return 8;
  }

  bool _isNadiDoshaCancelled(VedicChart boyChart, VedicChart girlChart) {
    final boyMoon = boyChart.getPlanet(Planet.moon);
    final girlMoon = girlChart.getPlanet(Planet.moon);
    if (boyMoon == null || girlMoon == null) return false;

    final boyNak = boyMoon.nakshatra;
    final girlNak = girlMoon.nakshatra;
    final boyPada = boyMoon.pada;
    final girlPada = girlMoon.pada;

    // Rule 1: Same Nakshatra, different Pada
    if (boyNak == girlNak && boyPada != girlPada) return true;

    // Rule 2: Same Rashi, different Nakshatra
    final boySign = Rashi.fromLongitude(boyMoon.longitude);
    final girlSign = Rashi.fromLongitude(girlMoon.longitude);
    if (boySign == girlSign && boyNak != girlNak) return true;

    return false;
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

  /// Checks for Manglik Dosha and its cancellations.
  ///
  /// Dosha is confirmed when Mars occupies houses 1, 2, 4, 7, 8, or 12
  /// from the Ascendant, Moon, or Venus charts.
  ///
  /// Cancellation rules per BPHS and Phaladeepika:
  /// 1. Mars in own sign (Aries, Scorpio) or exalted (Capricorn)
  /// 2. Mars conjunct Jupiter or Moon (benefic conjunction)
  /// 3. Mars in Leo or Aquarius (weakens the dosha in houses 7/8)
  /// 4. Mars aspected by Jupiter or Venus in the same chart
  /// 5. Mars is the lagna lord (chart has Aries or Scorpio Ascendant)
  /// 6. Both partners are Manglik — mutual cancellation (check at compatibility level)
  ManglikDoshaResult checkManglikDosha(VedicChart chart) {
    bool isManglik = false;
    final housesAffected = <int>[];
    String severity = 'Low';
    final remedies = <String>[];

    final mars = chart.getPlanet(Planet.mars);
    if (mars == null) {
      return ManglikDoshaResult(
        isManglik: false,
        housesAffected: [],
        severity: 'None',
        remedies: [],
      );
    }

    final ascendantSignStr = chart.ascendantSign;
    final ascendantSign = Rashi.values.firstWhere(
        (r) => r.name.toLowerCase() == ascendantSignStr.toLowerCase(),
        orElse: () => Rashi.aries);
    final moonSign =
        Rashi.fromLongitude(chart.getPlanet(Planet.moon)?.longitude ?? 0);
    final venusSign =
        Rashi.fromLongitude(chart.getPlanet(Planet.venus)?.longitude ?? 0);
    final marsSign = Rashi.fromLongitude(mars.longitude);

    // Get houses of Mars from Ascendant, Moon, and Venus
    final marsFromAsc = _getHouseDistance(ascendantSign, marsSign);
    final marsFromMoon = _getHouseDistance(moonSign, marsSign);
    final marsFromVenus = _getHouseDistance(venusSign, marsSign);

    const manglikHouses = [1, 2, 4, 7, 8, 12];

    final manglikFromAsc = manglikHouses.contains(marsFromAsc);
    final manglikFromMoon = manglikHouses.contains(marsFromMoon);
    final manglikFromVenus = manglikHouses.contains(marsFromVenus);

    if (manglikFromAsc || manglikFromMoon || manglikFromVenus) {
      isManglik = true;
      if (manglikFromAsc) housesAffected.add(marsFromAsc);

      // Determine severity
      final doshaCount = (manglikFromAsc ? 1 : 0) +
          (manglikFromMoon ? 1 : 0) +
          (manglikFromVenus ? 1 : 0);
      severity = doshaCount >= 2 ? 'High' : 'Moderate';

      // ─── Cancellation checks (Parihara) ──────────────────────────────────
      bool isCancelled = false;

      // Rule 1: Mars in own sign (Aries, Scorpio) or exalted (Capricorn)
      if (marsSign == Rashi.aries ||
          marsSign == Rashi.scorpio ||
          marsSign == Rashi.capricorn) {
        isCancelled = true;
        remedies.add('Mars in own/exalted sign — Dosha cancelled (Parihara 1)');
      }

      // Rule 2: Mars conjunct (same sign as) Jupiter or Moon
      final jupiter = chart.getPlanet(Planet.jupiter);
      final moon = chart.getPlanet(Planet.moon);
      final jupiterSign =
          jupiter != null ? Rashi.fromLongitude(jupiter.longitude) : null;
      final moonSignCurrent =
          moon != null ? Rashi.fromLongitude(moon.longitude) : null;
      if (jupiterSign == marsSign || moonSignCurrent == marsSign) {
        isCancelled = true;
        remedies
            .add('Mars conjunct Jupiter/Moon — Dosha cancelled (Parihara 2)');
      }

      // Rule 3: Mars in Leo or Aquarius (weakens dosha in houses 7 and 8)
      if (marsSign == Rashi.leo || marsSign == Rashi.aquarius) {
        isCancelled = true;
        remedies.add('Mars in Leo/Aquarius — Dosha cancelled (Parihara 3)');
      }

      // Rule 4: Mars aspected (same sign) by Jupiter or Venus
      final venus = chart.getPlanet(Planet.venus);
      final venusSignForAspect =
          venus != null ? Rashi.fromLongitude(venus.longitude) : null;
      // Whole-sign aspect: check if Jupiter or Venus is in a sign that
      // aspects Mars's sign (7th from each aspecting planet)
      bool marsAspectedByBenefic = false;
      if (jupiterSign != null) {
        final jupAspectsSign = Rashi.fromIndex((jupiterSign.index + 6) % 12);
        if (jupAspectsSign == marsSign) marsAspectedByBenefic = true;
      }
      if (venusSignForAspect != null) {
        final venAspectsSign =
            Rashi.fromIndex((venusSignForAspect.index + 6) % 12);
        if (venAspectsSign == marsSign) marsAspectedByBenefic = true;
      }
      if (marsAspectedByBenefic) {
        isCancelled = true;
        remedies.add(
            'Mars aspected by Jupiter or Venus — Dosha cancelled (Parihara 4)');
      }

      // Rule 5: Mars is the lagna lord (Aries or Scorpio Ascendant)
      if (ascendantSign == Rashi.aries || ascendantSign == Rashi.scorpio) {
        isCancelled = true;
        remedies.add('Mars rules the Ascendant — Dosha cancelled (Parihara 5)');
      }

      if (isCancelled) {
        isManglik = false;
        severity = 'Cancelled';
      } else {
        remedies.addAll([
          'Chant Mangal Mantra daily',
          'Donate red clothes or red lentils on Tuesdays',
          'Fast on Tuesdays',
          'Perform Mangal Shanti puja',
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

  int _getHouseDistance(Rashi refSign, Rashi targetSign) {
    int dist = targetSign.index - refSign.index + 1;
    if (dist <= 0) dist += 12;
    return dist;
  }

  NadiDoshaResult checkNadiDosha(VedicChart boyChart, VedicChart girlChart) {
    final boyMoonInfo = boyChart.getPlanet(Planet.moon);
    final girlMoonInfo = girlChart.getPlanet(Planet.moon);

    final boyNadi =
        _getNadiFromNakshatraIndex(boyMoonInfo?.position.nakshatraIndex ?? 0);
    final girlNadi =
        _getNadiFromNakshatraIndex(girlMoonInfo?.position.nakshatraIndex ?? 0);

    final hasDosha =
        boyNadi == girlNadi && !_isNadiDoshaCancelled(boyChart, girlChart);

    return NadiDoshaResult(
      hasDosha: hasDosha,
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
    int fwdDist = girlSignNum - boySignNum + 1;
    if (fwdDist <= 0) fwdDist += 12;

    int revDist = boySignNum - girlSignNum + 1;
    if (revDist <= 0) revDist += 12;

    final pair = {fwdDist, revDist};

    // Bhakoot Dosha: 2/12, 5/9, or 6/8 inter-sign relationships
    bool hasDosha = fwdDist != 1 &&
        (pair.containsAll({2, 12}) ||
            pair.containsAll({5, 9}) ||
            pair.containsAll({6, 8}));

    if (hasDosha && _isBhakootDoshaCancelled(boyMoonSign, girlMoonSign)) {
      hasDosha = false;
    }

    String description;
    if (!hasDosha) {
      description = 'No Bhakoot Dosha'; // Includes cancelled cases
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

  CompatibilityLevel _getCompatibilityLevel(double score) {
    if (score >= 33) return CompatibilityLevel.excellent;
    if (score >= 25) return CompatibilityLevel.veryGood;
    if (score >= 18) return CompatibilityLevel.good;
    if (score >= 12) return CompatibilityLevel.average;
    return CompatibilityLevel.poor;
  }
}
