import 'package:jyotish/src/models/planet.dart';
import 'package:jyotish/src/models/rashi.dart';
import 'package:jyotish/src/models/vedic_chart.dart';
import 'package:jyotish/src/models/divisional_chart_type.dart';
import 'package:jyotish/src/analysis/progeny.dart';
import 'package:jyotish/src/analysis/divisional_chart_service.dart';

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
      analysis.add(
        '5th house needs attention (${fifthHouseStrength.score} pts)',
      );
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
    final planetsInHouse = chart.getPlanetsInHouse(5);
    final fifthLord = _getHouseLord(chart, 5);

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

    final aspectsOnHouse = _getPlanetsAspectingHouse(chart, 5);
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
      return const JupiterCondition(
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

    // Check actual angular distance to the Sun for combustion (limit ~11 degrees)
    final sunInfo = chart.getPlanet(Planet.sun);
    double diff = sunInfo != null
        ? (jupiterInfo.longitude - sunInfo.longitude).abs()
        : 0.0;
    while (diff > 180) {
      diff = 360 - diff;
    }
    final isCombust = sunInfo != null && diff < 11.0;

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
    var score = 15; // Start with a baseline score of 15 (neutral)
    final d7Chart = _divisionalChartService.calculateDivisionalChart(
      chart,
      DivisionalChartType.d7,
    );

    // 1. D7 Lagna Lord placement in D7
    final d7LagnaSign = Rashi.fromLongitude(d7Chart.ascendant);
    final d7LagnaLord = d7LagnaSign.lord;
    final d7LagnaLordInfo = d7Chart.getPlanet(d7LagnaLord);
    if (d7LagnaLordInfo != null) {
      final house = d7LagnaLordInfo.house;
      if (house == 1 ||
          house == 4 ||
          house == 7 ||
          house == 10 ||
          house == 5 ||
          house == 9) {
        score += 5;
      } else if (house == 6 || house == 8 || house == 12) {
        score -= 5;
      }
      if (d7LagnaLordInfo.dignity == PlanetaryDignity.exalted) {
        score += 5;
      } else if (d7LagnaLordInfo.dignity == PlanetaryDignity.debilitated) {
        score -= 5;
      }
    }

    // 2. D7 5th Lord placement in D7
    final d7FifthLord = _getHouseLord(d7Chart, 5);
    final d7FifthLordInfo = d7Chart.getPlanet(d7FifthLord);
    if (d7FifthLordInfo != null) {
      final house = d7FifthLordInfo.house;
      if (house == 1 ||
          house == 4 ||
          house == 7 ||
          house == 10 ||
          house == 5 ||
          house == 9) {
        score += 5;
      } else if (house == 6 || house == 8 || house == 12) {
        score -= 5;
      }
      if (d7FifthLordInfo.dignity == PlanetaryDignity.exalted) {
        score += 5;
      } else if (d7FifthLordInfo.dignity == PlanetaryDignity.debilitated) {
        score -= 5;
      }
    }

    // 3. Planets in the 5th house of D7
    final d7PlanetsIn5 = d7Chart.getPlanetsInHouse(5);
    for (final p in d7PlanetsIn5) {
      if (_isBenefic(p.position.planet)) {
        score += 3;
      } else {
        score -= 3;
      }
    }

    // 4. Jupiter condition in D7
    final jupiterD7 = d7Chart.getPlanet(Planet.jupiter);
    if (jupiterD7 != null) {
      final house = jupiterD7.house;
      if (house == 1 ||
          house == 4 ||
          house == 7 ||
          house == 10 ||
          house == 5 ||
          house == 9) {
        score += 5;
      } else if (house == 6 || house == 8 || house == 12) {
        score -= 5;
      }
      if (jupiterD7.dignity == PlanetaryDignity.exalted) {
        score += 5;
      } else if (jupiterD7.dignity == PlanetaryDignity.debilitated) {
        score -= 5;
      }
    }

    return D7Analysis(
      score: score.clamp(0, 30),
      isStrong: score >= 20,
      fifthLordD7: d7FifthLord,
      jupiterD7: Planet.jupiter,
      venusD7: Planet.venus,
      moonD7: Planet.moon,
    );
  }

  List<ChildYoga> detectChildYogas(VedicChart chart) {
    final yogas = <ChildYoga>[];

    final jupiterInfo = chart.getPlanet(Planet.jupiter);
    final planetsInFifth = chart.getPlanetsInHouse(5);

    yogas.add(
      ChildYoga(
        name: 'Jupiter in 5th',
        description:
            'Jupiter in the 5th house is highly auspicious for children',
        isPresent: planetsInFifth.any((p) => p.planet == Planet.jupiter),
      ),
    );

    yogas.add(
      ChildYoga(
        name: 'Santanada Yoga',
        description: 'When Jupiter aspects the 5th house or its lord',
        isPresent: jupiterInfo != null &&
            (_doesPlanetAspectHouse(jupiterInfo, 5) ||
                _doesPlanetAspectHouse(
                  jupiterInfo,
                  chart.getPlanet(_getHouseLord(chart, 5))?.house ?? 999,
                )),
      ),
    );

    yogas.add(
      ChildYoga(
        name: 'Kalyana Vimsopaka Yoga',
        description:
            'Venus in 5th house indicates intelligent and beautiful children',
        isPresent: planetsInFifth.any((p) => p.planet == Planet.venus),
      ),
    );

    // Find Atmakaraka (traditional planet with highest longitude % 30)
    Planet? atmakaraka;
    double maxDeg = -1.0;
    for (final p in Planet.traditionalPlanets) {
      final info = chart.getPlanet(p);
      if (info == null) continue;
      final deg = info.longitude % 30;
      if (deg > maxDeg) {
        maxDeg = deg;
        atmakaraka = p;
      }
    }

    final d9Chart = _divisionalChartService.calculateDivisionalChart(
      chart,
      DivisionalChartType.d9,
    );
    final jupD9Info = d9Chart.getPlanet(Planet.jupiter);

    final bool isJupAtmakaraka = atmakaraka == Planet.jupiter;
    final bool jupIn5thRashi = jupiterInfo?.house == 5;
    final bool jupIn5thD9 = jupD9Info?.house == 5;

    yogas.add(
      ChildYoga(
        name: 'Putra Karaka',
        description: 'Jupiter as Atmakaraka in 5th house or Navamsa',
        isPresent: isJupAtmakaraka && (jupIn5thRashi || jupIn5thD9),
      ),
    );

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
    return [
      Planet.jupiter,
      Planet.venus,
      Planet.moon,
      Planet.mercury,
    ].contains(planet);
  }

  List<Planet> _getPlanetsAspectingHouse(VedicChart chart, int houseNumber) {
    final aspects = <Planet>[];
    for (final planet in Planet.traditionalPlanets) {
      final info = chart.getPlanet(planet);
      if (info == null) continue;
      if (_doesPlanetAspectHouse(info, houseNumber)) {
        aspects.add(planet);
      }
    }
    return aspects;
  }

  bool _doesPlanetAspectHouse(VedicPlanetInfo planetInfo, int targetHouse) {
    final h = planetInfo.house;
    final h0 = h - 1;
    final planet = planetInfo.position.planet;

    final List<int> aspectedHouses0 = [];
    aspectedHouses0.add((h0 + 6) % 12);

    if (planet == Planet.mars) {
      aspectedHouses0.add((h0 + 3) % 12);
      aspectedHouses0.add((h0 + 7) % 12);
    } else if (planet == Planet.jupiter) {
      aspectedHouses0.add((h0 + 4) % 12);
      aspectedHouses0.add((h0 + 8) % 12);
    } else if (planet == Planet.saturn) {
      aspectedHouses0.add((h0 + 2) % 12);
      aspectedHouses0.add((h0 + 9) % 12);
    }

    return aspectedHouses0.contains(targetHouse - 1);
  }

  ProgenyStrength _getProgenyStrength(int score) {
    if (score >= 60) return ProgenyStrength.strong;
    if (score >= 40) return ProgenyStrength.moderate;
    if (score >= 20) return ProgenyStrength.weak;
    return ProgenyStrength.veryWeak;
  }
}
