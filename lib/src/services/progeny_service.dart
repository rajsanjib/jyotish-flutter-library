import '../models/planet.dart';
import '../models/rashi.dart';
import '../models/vedic_chart.dart';
import '../models/divisional_chart_type.dart';
import '../models/progeny.dart';
import 'divisional_chart_service.dart';

class ProgenyService {
  ProgenyService();
  final DivisionalChartService _divisionalChartService =
      DivisionalChartService();

  ProgenyResult analyzeProgeny(VedicChart chart) {
    final fifthHouseStrength = analyzeFifthHouse(chart);
    final jupiterCondition = analyzeJupiterCondition(chart);
    final d7Analysis = analyzeD7Chart(chart);
    final childYogas = detectChildYogas(chart);
    final kalatrakaraka = analyzeKalatrakaraka(chart);

    var totalScore = 0;
    final analysis = <String>[];

    totalScore += fifthHouseStrength.score;
    if (fifthHouseStrength.isStrong) {
      analysis.add('5th house is strong (${fifthHouseStrength.score} pts)');
    } else {
      analysis
          .add('5th house needs attention (${fifthHouseStrength.score} pts)');
    }

    totalScore += jupiterCondition.score;
    if (jupiterCondition.isStrong) {
      analysis.add('Jupiter is well placed (${jupiterCondition.score} pts)');
    } else {
      analysis.add('Jupiter needs attention (${jupiterCondition.score} pts)');
    }

    totalScore += d7Analysis.score;
    if (d7Analysis.isStrong) {
      analysis.add('D7 chart is favorable (${d7Analysis.score} pts)');
    } else {
      analysis.add('D7 chart needs attention (${d7Analysis.score} pts)');
    }

    totalScore += kalatrakaraka.score;

    if (childYogas.any((y) => y.isPresent)) {
      totalScore += 20;
      analysis.add('Favorable child yogas present');
    }

    final strength = _getProgenyStrength(totalScore);

    return ProgenyResult(
      strength: strength,
      score: totalScore.clamp(0, 100),
      fifthHouseStrength: fifthHouseStrength,
      jupiterCondition: jupiterCondition,
      d7Analysis: d7Analysis,
      childYogas: childYogas,
      analysis: analysis,
    );
  }

  FifthHouseStrength analyzeFifthHouse(VedicChart chart) {
    var score = 0;
    final ascLong = chart.ascendant;
    final fifthHouse = (4 * 30 + ascLong) % 360;
    final fifthHouseNumber = ((fifthHouse / 30).floor() + 1);

    final planetsInHouse = chart.getPlanetsInHouse(fifthHouseNumber);
    final fifthLord = _getHouseLord(chart, fifthHouseNumber);

    final lordInfo = chart.getPlanet(fifthLord);
    final lordStrength = lordInfo != null ? 30.0 : 0.0;

    if (lordInfo != null) {
      if (lordInfo.dignity == PlanetaryDignity.exalted ||
          lordInfo.dignity == PlanetaryDignity.moolaTrikona) {
        score += 25;
      } else if (lordInfo.dignity == PlanetaryDignity.ownSign) {
        score += 20;
      } else if (lordInfo.dignity == PlanetaryDignity.friendSign) {
        score += 15;
      } else if (lordInfo.dignity == PlanetaryDignity.debilitated) {
        score -= 15;
      }
    }

    for (final planet in planetsInHouse) {
      if (_isBenefic(planet.position.planet)) {
        score += 10;
      } else {
        score -= 10;
      }
    }

    final aspectsOnHouse = _getPlanetsAspectingHouse(chart, fifthHouseNumber);
    for (final planet in aspectsOnHouse) {
      if (_isBenefic(planet)) {
        score += 5;
      } else {
        score -= 5;
      }
    }

    final isAfflicted = score < 15;

    return FifthHouseStrength(
      score: score.clamp(0, 40),
      isStrong: score >= 20,
      lordStrength: lordStrength,
      planetsInHouse: planetsInHouse.map((p) => p.planet).toList(),
      aspectsOnHouse: aspectsOnHouse,
      isAfflicted: isAfflicted,
    );
  }

  JupiterCondition analyzeJupiterCondition(VedicChart chart) {
    var score = 20;
    final jupiterInfo = chart.getPlanet(Planet.jupiter);
    if (jupiterInfo == null) {
      return JupiterCondition(
        score: 0,
        isStrong: false,
        isExalted: false,
        isOwnSign: false,
        isDebilitated: false,
        house: 0,
        isCombust: false,
      );
    }

    final house = jupiterInfo.house;
    final dignity = jupiterInfo.dignity;

    if (dignity == PlanetaryDignity.exalted) {
      score += 30;
    } else if (dignity == PlanetaryDignity.moolaTrikona) {
      score += 25;
    } else if (dignity == PlanetaryDignity.ownSign) {
      score += 20;
    } else if (dignity == PlanetaryDignity.debilitated) {
      score -= 25;
    }

    if (house == 1 || house == 5 || house == 9) {
      score += 15;
    }

    final isCombust = jupiterInfo.position.longitude < 10.0;
    if (isCombust) {
      score -= 10;
    }

    return JupiterCondition(
      score: score.clamp(0, 50),
      isStrong: score >= 30,
      isExalted: dignity == PlanetaryDignity.exalted,
      isOwnSign: dignity == PlanetaryDignity.ownSign,
      isDebilitated: dignity == PlanetaryDignity.debilitated,
      house: house,
      isCombust: isCombust,
    );
  }

  D7Analysis analyzeD7Chart(VedicChart chart) {
    var score = 0;
    final d7Chart = _divisionalChartService.calculateDivisionalChart(
        chart, DivisionalChartType.d7);

    final fifthLord = _getHouseLord(chart, 5);
    final fifthLordD7 = d7Chart.getPlanet(fifthLord);
    if (fifthLordD7 != null) {
      if (fifthLordD7.dignity == PlanetaryDignity.exalted ||
          fifthLordD7.dignity == PlanetaryDignity.ownSign) {
        score += 15;
      }
    }

    final jupiterD7 = d7Chart.getPlanet(Planet.jupiter);
    if (jupiterD7 != null) {
      if (jupiterD7.dignity == PlanetaryDignity.exalted ||
          jupiterD7.dignity == PlanetaryDignity.ownSign) {
        score += 15;
      }
    }

    return D7Analysis(
      score: score.clamp(0, 30),
      isStrong: score >= 20,
      fifthLordD7: fifthLord,
      jupiterD7: Planet.jupiter,
      venusD7: Planet.venus,
      moonD7: Planet.moon,
    );
  }

  List<ChildYoga> detectChildYogas(VedicChart chart) {
    final yogas = <ChildYoga>[];

    final jupiterInfo = chart.getPlanet(Planet.jupiter);
    final fifthHouse = (4 * 30 + chart.ascendant) % 360;
    final fifthHouseNumber = ((fifthHouse / 30).floor() + 1);
    final planetsInFifth = chart.getPlanetsInHouse(fifthHouseNumber);

    yogas.add(ChildYoga(
      name: 'Jupiter in 5th',
      description: 'Jupiter in the 5th house is highly auspicious for children',
      isPresent: planetsInFifth.any((p) => p.planet == Planet.jupiter),
    ));

    yogas.add(ChildYoga(
      name: 'Santanada Yoga',
      description: 'When Jupiter aspects the 5th house or its lord',
      isPresent: jupiterInfo != null &&
          _doesPlanetAspectHouse(jupiterInfo, fifthHouseNumber),
    ));

    yogas.add(ChildYoga(
      name: 'Kalyana Vimsopaka Yoga',
      description:
          'Venus in 5th house indicates intelligent and beautiful children',
      isPresent: planetsInFifth.any((p) => p.planet == Planet.venus),
    ));

    yogas.add(ChildYoga(
      name: 'Putra Karaka',
      description: 'Jupiter as Atmakaraka in 5th house or Navamsa',
      isPresent: false,
    ));

    return yogas;
  }

  KalatrakarakaResult analyzeKalatrakaraka(VedicChart chart) {
    final planetsInFifth = chart.getPlanetsInHouse(5);
    var score = 10;

    final jupiterScore =
        planetsInFifth.any((p) => p.planet == Planet.jupiter) ? 20 : 0;
    final venusScore =
        planetsInFifth.any((p) => p.planet == Planet.venus) ? 15 : 0;
    final moonScore =
        planetsInFifth.any((p) => p.planet == Planet.moon) ? 15 : 0;

    score += jupiterScore + venusScore + moonScore;

    return KalatrakarakaResult(
      primaryKaraka: Planet.jupiter,
      secondaryKaraka: Planet.venus,
      planetsInFifth: planetsInFifth.map((p) => p.planet).toList(),
      score: score.clamp(0, 30),
    );
  }

  Planet _getHouseLord(VedicChart chart, int houseNumber) {
    final ascLong = chart.ascendant;
    final lagnaSign = Rashi.fromLongitude(ascLong);
    final houseSignIndex = (lagnaSign.index + houseNumber - 1) % 12;
    final rashi = Rashi.values[houseSignIndex];

    return switch (rashi) {
      Rashi.aries => Planet.mars,
      Rashi.taurus => Planet.venus,
      Rashi.gemini => Planet.mercury,
      Rashi.cancer => Planet.moon,
      Rashi.leo => Planet.sun,
      Rashi.virgo => Planet.mercury,
      Rashi.libra => Planet.venus,
      Rashi.scorpio => Planet.mars,
      Rashi.sagittarius => Planet.jupiter,
      Rashi.capricorn => Planet.saturn,
      Rashi.aquarius => Planet.saturn,
      Rashi.pisces => Planet.jupiter,
    };
  }

  bool _isBenefic(Planet planet) {
    return [Planet.jupiter, Planet.venus, Planet.moon, Planet.mercury]
        .contains(planet);
  }

  List<Planet> _getPlanetsAspectingHouse(VedicChart chart, int houseNumber) {
    final aspects = <Planet>[];
    final houseCusp = (chart.ascendant + (houseNumber - 1) * 30) % 360;

    for (final entry in chart.planets.entries) {
      final planet = entry.key;
      final planetInfo = entry.value;
      final angle = (planetInfo.longitude - houseCusp + 360) % 360;

      if ((angle >= 60 && angle <= 120) ||
          (angle >= 240 && angle <= 300) ||
          angle == 180) {
        aspects.add(planet);
      }
    }

    return aspects;
  }

  bool _doesPlanetAspectHouse(VedicPlanetInfo planet, int houseNumber) {
    return true;
  }

  ProgenyStrength _getProgenyStrength(int score) {
    if (score >= 60) return ProgenyStrength.strong;
    if (score >= 40) return ProgenyStrength.moderate;
    if (score >= 20) return ProgenyStrength.weak;
    return ProgenyStrength.veryWeak;
  }
}
