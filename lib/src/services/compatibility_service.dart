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

  int calculateVarna(String boyNakshatra, String girlNakshatra) {
    const varnaOrder = ['Brahmin', 'Kshatriya', 'Vaishya', 'Shudra'];
    final boyVarna = _getNakshatraVarna(boyNakshatra);
    final girlVarna = _getNakshatraVarna(girlNakshatra);

    if (boyVarna == girlVarna) return 1;
    if (varnaOrder.indexOf(boyVarna) > varnaOrder.indexOf(girlVarna)) return 1;
    return 0;
  }

  String _getNakshatraVarna(String nakshatra) {
    if ([
      'Ashwini',
      'Bharani',
      'Krittika',
      'Pushya',
      'Hasta',
      'Chitra',
      'Swati',
      'Anuradha',
      'Mula',
      'Shravana',
      'Dhanishtha',
      'Purva Bhadrapada'
    ].contains(nakshatra)) {
      return 'Brahmin';
    }
    if ([
      'Rohini',
      'Mrigashirsha',
      'Punarvasu',
      'Ashlesha',
      'Magha',
      'Purva Phalguni',
      'Vishakha',
      'Jyeshtha',
      'Purva Ashadha',
      'Uttara Ashadha',
      'Shatabhisha',
      'Revati'
    ].contains(nakshatra)) {
      return 'Kshatriya';
    }
    return 'Vaishya';
  }

  int calculateVashya(String boyNakshatra, String girlNakshatra) {
    final boyVashya = _getNakshatraVashya(boyNakshatra);
    final girlVashya = _getNakshatraVashya(girlNakshatra);

    if (boyVashya == girlVashya) return 2;
    return 1;
  }

  String _getNakshatraVashya(String nakshatra) {
    if ([
      'Mrigashirsha',
      'Ashlesha',
      'Chitra',
      'Anuradha',
      'Mula',
      'Shravana',
      'Dhanishtha',
      'Purva Bhadrapada'
    ].contains(nakshatra)) {
      return 'Wild';
    }
    return 'Human';
  }

  int calculateTara(
      String boyNakshatra, String girlNakshatra, int boyPada, int girlPada) {
    final boyNakshatraNum = _getNakshatraNumber(boyNakshatra);
    final girlNakshatraNum = _getNakshatraNumber(girlNakshatra);

    final taraCount = ((girlNakshatraNum - boyNakshatraNum) % 27 + 27) % 27;
    final taraNumber = taraCount ~/ 9 + 1;

    if (taraNumber == 1 ||
        taraNumber == 3 ||
        taraNumber == 5 ||
        taraNumber == 7) {
      return 3;
    } else if (taraNumber == 2 || taraNumber == 4 || taraNumber == 6) {
      return 2;
    }
    return 1;
  }

  int _getNakshatraNumber(String nakshatra) {
    const nakshatras = [
      'Ashwini',
      'Bharani',
      'Krittika',
      'Rohini',
      'Mrigashirsha',
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
      'Dhanishtha',
      'Shatabhisha',
      'Purva Bhadrapada',
      'Uttara Bhadrapada',
      'Revati'
    ];
    final index = nakshatras.indexOf(nakshatra);
    return index >= 0 ? index + 1 : 1;
  }

  int calculateYoni(String boyNakshatra, String girlNakshatra) {
    const yoniAnimals = {
      'Ashwini': 'Horse',
      'Bharani': 'Elephant',
      'Krittika': 'Goat',
      'Rohini': 'Serpent',
      'Mrigashirsha': 'Snake',
      'Ardra': 'Dog',
      'Punarvasu': 'Cat',
      'Pushya': 'Goat',
      'Ashlesha': 'Cat',
      'Magha': 'Rat',
      'Purva Phalguni': 'Rat',
      'Uttara Phalguni': 'Cow',
      'Hasta': 'Buffalo',
      'Chitra': 'Tiger',
      'Swati': 'Tiger',
      'Vishakha': 'Tiger',
      'Anuradha': 'Tiger',
      'Jyeshtha': 'Tiger',
      'Mula': 'Tiger',
      'Purva Ashadha': 'Tiger',
      'Uttara Ashadha': 'Tiger',
      'Shravana': 'Tiger',
      'Dhanishtha': 'Tiger',
      'Shatabhisha': 'Tiger',
      'Purva Bhadrapada': 'Tiger',
      'Uttara Bhadrapada': 'Tiger',
      'Revati': 'Tiger'
    };

    final boyAnimal = yoniAnimals[boyNakshatra] ?? 'Unknown';
    final girlAnimal = yoniAnimals[girlNakshatra] ?? 'Unknown';

    if (boyAnimal == girlAnimal) return 4;
    if (_areFriendlyAnimals(boyAnimal, girlAnimal)) return 2;
    return 1;
  }

  bool _areFriendlyAnimals(String animal1, String animal2) {
    const friendlyPairs = [
      ['Horse', 'Elephant'],
      ['Goat', 'Cow'],
      ['Serpent', 'Snake'],
      ['Dog', 'Cat']
    ];
    return friendlyPairs.any((pair) =>
        (pair[0] == animal1 && pair[1] == animal2) ||
        (pair[0] == animal2 && pair[1] == animal1));
  }

  int calculateGrahaMaitri(VedicChart boyChart, VedicChart girlChart) {
    final boyMoonSign =
        Rashi.fromLongitude(boyChart.getPlanet(Planet.moon)?.longitude ?? 0);
    final girlMoonSign =
        Rashi.fromLongitude(girlChart.getPlanet(Planet.moon)?.longitude ?? 0);

    final friendship = _getFriendship(boyMoonSign, girlMoonSign);
    return switch (friendship) {
      2 => 5,
      1 => 4,
      0 => 3,
      -1 => 2,
      _ => 1,
    };
  }

  int _getFriendship(Rashi rashi1, Rashi rashi2) {
    return 0;
  }

  int calculateGana(String boyNakshatra, String girlNakshatra) {
    const ganaTypes = {
      'Divine': [
        'Bharani',
        'Pushya',
        'Hasta',
        'Chitra',
        'Anuradha',
        'Shravana'
      ],
      'Human': [
        'Ashwini',
        'Rohini',
        'Mrigashirsha',
        'Punarvasu',
        'Magha',
        'Purva Phalguni',
        'Uttara Phalguni',
        'Swati',
        'Vishakha',
        'Uttara Ashadha',
        'Dhanishtha',
        'Shatabhisha',
        'Revati'
      ],
      'Demon': [
        'Krittika',
        'Ashlesha',
        'Jyeshtha',
        'Mula',
        'Purva Ashadha',
        'Purva Bhadrapada',
        'Uttara Bhadrapada'
      ],
    };

    final boyGana = _getGanaType(boyNakshatra, ganaTypes);
    final girlGana = _getGanaType(girlNakshatra, ganaTypes);

    if (boyGana == girlGana) return 6;
    if (boyGana == 'Divine' || girlGana == 'Divine') return 3;
    return 2;
  }

  String _getGanaType(String nakshatra, Map<String, List<String>> ganaTypes) {
    for (final entry in ganaTypes.entries) {
      if (entry.value.contains(nakshatra)) return entry.key;
    }
    return 'Human';
  }

  int calculateBhakoot(VedicChart boyChart, VedicChart girlChart) {
    final boyMoonSign =
        Rashi.fromLongitude(boyChart.getPlanet(Planet.moon)?.longitude ?? 0);
    final girlMoonSign =
        Rashi.fromLongitude(girlChart.getPlanet(Planet.moon)?.longitude ?? 0);

    final boySignNum = boyMoonSign.index;
    final girlSignNum = girlMoonSign.index;

    final diff = (girlSignNum - boySignNum).abs();

    if (diff == 0 || diff == 6 || diff == 12) return 7;
    if (diff == 2 || diff == 4 || diff == 8 || diff == 10) return 1;
    return 4;
  }

  int calculateNadi(VedicChart boyChart, VedicChart girlChart) {
    final boyMoonInfo = boyChart.getPlanet(Planet.moon);
    final girlMoonInfo = girlChart.getPlanet(Planet.moon);

    final boyNadi =
        boyMoonInfo != null ? ((boyMoonInfo.position.nakshatraIndex) ~/ 9) : 0;
    final girlNadi = girlMoonInfo != null
        ? ((girlMoonInfo.position.nakshatraIndex) ~/ 9)
        : 0;

    if (boyNadi == girlNadi) return 0;
    return 8;
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
        boyMoon != null ? ((boyMoon.position.nakshatraIndex) ~/ 9) : 0;
    final girlNadi =
        girlMoon != null ? ((girlMoon.position.nakshatraIndex) ~/ 9) : 0;

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

    final diff = (boyMoonSign.index - girlMoonSign.index).abs();

    return BhakootDoshaResult(
      hasDosha: diff == 6,
      boyRashi: boyMoonSign.name,
      girlRashi: girlMoonSign.name,
      description: diff == 6
          ? 'Moon signs are opposite - Bhakoot Dosha present'
          : 'No Bhakoot Dosha',
    );
  }

  DashaCompatibility calculateDashaCompatibility(
      VedicChart boyChart, VedicChart girlChart) {
    var score = 5;
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
