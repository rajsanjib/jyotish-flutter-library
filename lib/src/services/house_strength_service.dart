import '../models/planet.dart';
import '../models/rashi.dart';
import '../models/vedic_chart.dart';
import '../models/divisional_chart_type.dart';
import '../models/house_strength.dart';
import 'shadbala_service.dart';
import 'divisional_chart_service.dart';

class HouseStrengthService {
  HouseStrengthService(this._shadbalaService);
  final ShadbalaService _shadbalaService;
  final DivisionalChartService _divisionalChartService = DivisionalChartService();

  static const Map<int, KendraType> _houseToKendraType = {
    1: KendraType.kendra,
    2: KendraType.panaphara,
    3: KendraType.apoklima,
    4: KendraType.kendra,
    5: KendraType.panaphara,
    6: KendraType.apoklima,
    7: KendraType.kendra,
    8: KendraType.panaphara,
    9: KendraType.apoklima,
    10: KendraType.kendra,
    11: KendraType.panaphara,
    12: KendraType.apoklima,
  };

  static const Map<KendraType, double> _kendraStrengthValues = {
    KendraType.kendra: 60.0,
    KendraType.panaphara: 30.0,
    KendraType.apoklima: 15.0,
  };

  Future<Map<int, EnhancedBhavaBalaResult>> calculateEnhancedBhavaBala(
      VedicChart chart) async {
    final shadbala = await _shadbalaService.calculateShadbala(chart);
    final vimsopakaBala = calculateVimsopakaBala(chart);
    final results = <int, EnhancedBhavaBalaResult>{};

    for (var house = 1; house <= 12; house++) {
      final kendraType = _houseToKendraType[house]!;
      final kendradiStrength = _kendraStrengthValues[kendraType]!;
      final lordStrength = _getHouseLordStrength(chart, house, shadbala);
      final drishtiStrength = _calculateBhavaDrishtiStrength(chart, house);
      final vimsopakaStrength = _getHouseVimsopakaStrength(chart, house, vimsopakaBala);

      final totalStrength = lordStrength + kendradiStrength + drishtiStrength + vimsopakaStrength;
      final category = _getEnhancedCategory(totalStrength);

      results[house] = EnhancedBhavaBalaResult(
        houseNumber: house,
        totalStrength: totalStrength,
        category: category,
        lordStrength: lordStrength,
        kendradiStrength: kendradiStrength,
        drishtiStrength: drishtiStrength,
        vimsopakaStrength: vimsopakaStrength,
        kendraType: kendraType,
      );
    }

    return results;
  }

  double _getHouseLordStrength(VedicChart chart, int house, Map<Planet, ShadbalaResult> shadbala) {
    final lord = _getHouseLord(chart, house);
    final lordBala = shadbala[lord];
    return lordBala?.totalBala ?? 0.0;
  }

  Planet _getHouseLord(VedicChart chart, int houseNumber) {
    final ascLong = chart.ascendant;
    final lagnaSign = Rashi.fromLongitude(ascLong);
    final houseSignIndex = (lagnaSign.index + houseNumber - 1) % 12;
    final rashi = Rashi.values[houseSignIndex];

    switch (rashi) {
      case Rashi.aries:
      case Rashi.scorpio:
        return Planet.mars;
      case Rashi.taurus:
      case Rashi.libra:
        return Planet.venus;
      case Rashi.gemini:
      case Rashi.virgo:
        return Planet.mercury;
      case Rashi.cancer:
        return Planet.moon;
      case Rashi.leo:
        return Planet.sun;
      case Rashi.sagittarius:
      case Rashi.pisces:
        return Planet.jupiter;
      case Rashi.capricorn:
      case Rashi.aquarius:
        return Planet.saturn;
    }
  }

  double _calculateBhavaDrishtiStrength(VedicChart chart, int house) {
    var strength = 0.0;
    final houseCusp = (chart.ascendant + (house - 1) * 30) % 360;

    for (final entry in chart.planets.entries) {
      final planet = entry.key;
      final planetInfo = entry.value;

      if (Planet.lunarNodes.contains(planet)) continue;

      final angle = (planetInfo.longitude - houseCusp + 360) % 360;
      final aspectStrength = _calculateAspectStrength(angle);

      if (_isBenefic(planet)) {
        strength += aspectStrength;
      } else {
        strength -= aspectStrength;
      }
    }

    return strength / 4.0;
  }

  double _calculateAspectStrength(double angle) {
    if (angle < 30 || angle > 300) return 0.0;
    if (angle >= 30 && angle <= 60) return (angle - 30) / 2;
    if (angle > 60 && angle <= 90) return (angle - 60) + 15;
    if (angle > 90 && angle <= 120) return (120 - angle) / 2 + 45;
    if (angle > 120 && angle <= 150) return 150 - angle;
    if (angle > 150 && angle <= 180) return (angle - 150) * 2;
    if (angle > 180 && angle <= 300) return (300 - angle) / 2;
    return 0.0;
  }

  bool _isBenefic(Planet planet) {
    return [Planet.jupiter, Planet.venus, Planet.moon, Planet.mercury]
        .contains(planet);
  }

  double _getHouseVimsopakaStrength(
      VedicChart chart, int house, Map<Planet, VimsopakaBalaResult> vimsopakaBala) {
    final lord = _getHouseLord(chart, house);
    final vimsopaka = vimsopakaBala[lord];
    if (vimsopaka == null) return 0.0;
    return vimsopaka.totalScore * 3;
  }

  EnhancedBhavaStrengthCategory _getEnhancedCategory(double strength) {
    if (strength >= 150) return EnhancedBhavaStrengthCategory.atiShadbalapurna;
    if (strength >= 120) return EnhancedBhavaStrengthCategory.shadbalapurna;
    if (strength >= 90) return EnhancedBhavaStrengthCategory.shadbalardha;
    if (strength >= 60) return EnhancedBhavaStrengthCategory.madhyama;
    if (strength >= 30) return EnhancedBhavaStrengthCategory.krishna;
    return EnhancedBhavaStrengthCategory.atiKrishna;
  }

  Map<Planet, VimsopakaBalaResult> calculateVimsopakaBala(VedicChart chart) {
    final results = <Planet, VimsopakaBalaResult>{};

    final relevantCharts = [
      DivisionalChartType.d1,
      DivisionalChartType.d2,
      DivisionalChartType.d3,
      DivisionalChartType.d9,
      DivisionalChartType.d12,
      DivisionalChartType.d30,
    ];

    for (final entry in chart.planets.entries) {
      final planet = entry.key;
      if (Planet.lunarNodes.contains(planet)) continue;

      final vargaScore = _calculateVargaScore(planet, chart, relevantCharts);
      final sambandhaScore = _calculateSambandhaScore(planet, chart, relevantCharts);
      final totalScore = (vargaScore * sambandhaScore / 20.0).clamp(5.0, 20.0);
      final category = _getVimsopakaCategory(totalScore);

      results[planet] = VimsopakaBalaResult(
        planet: planet,
        totalScore: totalScore,
        vargaScore: vargaScore,
        sambandhaScore: sambandhaScore,
        category: category,
      );
    }

    return results;
  }

  double _calculateVargaScore(
      Planet planet, VedicChart chart, List<DivisionalChartType> charts) {
    var totalWeight = 0.0;
    var weightedScore = 0.0;

    for (final chartType in charts) {
      final weight = chartType.vimsopakaWeight;
      if (weight <= 0) continue;

      final vargaChart = _divisionalChartService.calculateDivisionalChart(chart, chartType);

      final planetInfo = vargaChart.getPlanet(planet);
      if (planetInfo == null) continue;

      final dignityScore = _getDignityScore(planetInfo.dignity);
      weightedScore += dignityScore * weight;
      totalWeight += weight;
    }

    return totalWeight > 0 ? weightedScore / totalWeight * 20 : 0;
  }

  double _getDignityScore(PlanetaryDignity dignity) {
    return switch (dignity) {
      PlanetaryDignity.exalted => 20.0,
      PlanetaryDignity.moolaTrikona => 18.0,
      PlanetaryDignity.ownSign => 15.0,
      PlanetaryDignity.greatFriend => 12.0,
      PlanetaryDignity.friendSign => 10.0,
      PlanetaryDignity.neutralSign => 8.0,
      PlanetaryDignity.enemySign => 5.0,
      PlanetaryDignity.greatEnemy => 3.0,
      PlanetaryDignity.debilitated => 1.0,
    };
  }

  double _calculateSambandhaScore(
      Planet planet, VedicChart chart, List<DivisionalChartType> charts) {
    var totalScore = 0.0;
    var count = 0;

    for (final chartType in charts) {
      final vargaChart = _divisionalChartService.calculateDivisionalChart(chart, chartType);

      final planetInfo = vargaChart.getPlanet(planet);
      if (planetInfo == null) continue;

      final rashi = Rashi.fromLongitude(planetInfo.longitude);
      final relationship = _getPlanetaryRelationship(planet, rashi);
      totalScore += relationship;
      count++;
    }

    return count > 0 ? totalScore / count : 10.0;
  }

  double _getPlanetaryRelationship(Planet planet, Rashi rashi) {
    final lordOfRashi = _getRashiLord(rashi);
    if (lordOfRashi == planet) return 20.0;

    final friendship = _getFriendshipLevel(planet, lordOfRashi);
    return switch (friendship) {
      PlanetaryFriendship.own => 20.0,
      PlanetaryFriendship.greatFriend => 18.0,
      PlanetaryFriendship.friend => 15.0,
      PlanetaryFriendship.neutral => 10.0,
      PlanetaryFriendship.enemy => 7.0,
      PlanetaryFriendship.greatEnemy => 5.0,
    };
  }

  Planet _getRashiLord(Rashi rashi) {
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

  PlanetaryFriendship _getFriendshipLevel(Planet planet1, Planet planet2) {
    if (planet1 == planet2) return PlanetaryFriendship.own;

    const naturalFriends = {
      Planet.sun: [Planet.moon, Planet.mars, Planet.jupiter],
      Planet.moon: [Planet.sun, Planet.mercury, Planet.venus],
      Planet.mars: [Planet.sun, Planet.moon, Planet.jupiter],
      Planet.mercury: [Planet.sun, Planet.venus],
      Planet.jupiter: [Planet.sun, Planet.moon, Planet.mars],
      Planet.venus: [Planet.mercury, Planet.saturn],
      Planet.saturn: [Planet.mercury, Planet.venus],
    };

    const naturalEnemies = {
      Planet.sun: [Planet.venus, Planet.saturn],
      Planet.moon: [], // Moon has no natural enemies
      Planet.mars: [Planet.mercury],
      Planet.mercury: [Planet.moon],
      Planet.jupiter: [Planet.mercury, Planet.venus],
      Planet.venus: [Planet.sun, Planet.moon],
      Planet.saturn: [Planet.sun, Planet.moon, Planet.mars],
    };

    final p1Friends = naturalFriends[planet1] ?? [];
    final p1Enemies = naturalEnemies[planet1] ?? [];

    if (p1Friends.contains(planet2)) return PlanetaryFriendship.friend;
    if (p1Enemies.contains(planet2)) return PlanetaryFriendship.enemy;

    return PlanetaryFriendship.neutral;
  }

  VimsopakaCategory _getVimsopakaCategory(double score) {
    if (score >= 18) return VimsopakaCategory.atipoorna;
    if (score >= 16) return VimsopakaCategory.poorna;
    if (score >= 14) return VimsopakaCategory.atimadhya;
    if (score >= 12) return VimsopakaCategory.madhya;
    if (score >= 10) return VimsopakaCategory.adhama;
    if (score >= 8) return VimsopakaCategory.durga;
    return VimsopakaCategory.sangatDurga;
  }

  HouseStrengthSummary getHouseStrengthSummary(Map<int, EnhancedBhavaBalaResult> results) {
    var totalStrength = 0.0;
    var strongest = 1;
    var weakest = 1;
    var strongestValue = 0.0;
    var weakestValue = double.infinity;

    for (final entry in results.entries) {
      final house = entry.key;
      final strength = entry.value.totalStrength;
      totalStrength += strength;

      if (strength > strongestValue) {
        strongest = house;
        strongestValue = strength;
      }
      if (strength < weakestValue) {
        weakest = house;
        weakestValue = strength;
      }
    }

    return HouseStrengthSummary(
      houseResults: results,
      averageStrength: totalStrength / 12,
      strongestHouse: strongest,
      weakestHouse: weakest,
    );
  }
}

enum PlanetaryFriendship {
  own,
  greatFriend,
  friend,
  neutral,
  enemy,
  greatEnemy,
}
