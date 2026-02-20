import '../models/planet.dart';

enum ProgenyStrength {
  strong('Strong', 60, 100, 'High chance of children'),
  moderate('Moderate', 40, 60, 'Moderate chance with some challenges'),
  weak('Weak', 20, 40, 'Challenges in having children'),
  veryWeak('Very Weak', 0, 20, 'Significant challenges');

  const ProgenyStrength(this.name, this.minScore, this.maxScore, this.description);
  final String name;
  final int minScore;
  final int maxScore;
  final String description;
}

class ProgenyResult {
  const ProgenyResult({
    required this.strength,
    required this.score,
    required this.fifthHouseStrength,
    required this.jupiterCondition,
    required this.d7Analysis,
    required this.childYogas,
    required this.analysis,
  });

  final ProgenyStrength strength;
  final int score;
  final FifthHouseStrength fifthHouseStrength;
  final JupiterCondition jupiterCondition;
  final D7Analysis d7Analysis;
  final List<ChildYoga> childYogas;
  final List<String> analysis;

  @override
  String toString() => 'Progeny: $strength ($score points)';
}

class FifthHouseStrength {
  const FifthHouseStrength({
    required this.score,
    required this.isStrong,
    required this.lordStrength,
    required this.planetsInHouse,
    required this.aspectsOnHouse,
    required this.isAfflicted,
  });

  final int score;
  final bool isStrong;
  final double lordStrength;
  final List<Planet> planetsInHouse;
  final List<Planet> aspectsOnHouse;
  final bool isAfflicted;
}

class JupiterCondition {
  const JupiterCondition({
    required this.score,
    required this.isStrong,
    required this.isExalted,
    required this.isOwnSign,
    required this.isDebilitated,
    required this.house,
    required this.isCombust,
  });

  final int score;
  final bool isStrong;
  final bool isExalted;
  final bool isOwnSign;
  final bool isDebilitated;
  final int house;
  final bool isCombust;
}

class D7Analysis {
  const D7Analysis({
    required this.score,
    required this.isStrong,
    required this.fifthLordD7,
    required this.jupiterD7,
    required this.venusD7,
    required this.moonD7,
  });

  final int score;
  final bool isStrong;
  final Planet? fifthLordD7;
  final Planet? jupiterD7;
  final Planet? venusD7;
  final Planet? moonD7;
}

class ChildYoga {
  const ChildYoga({
    required this.name,
    required this.description,
    required this.isPresent,
    this.strength = '',
  });

  final String name;
  final String description;
  final bool isPresent;
  final String strength;
}

class ChildTimingPrediction {
  const ChildTimingPrediction({
    required this.dasha,
    required this.transit,
    required this.years,
    required this.description,
  });

  final String dasha;
  final String transit;
  final int years;
  final String description;
}

class KalatrakarakaResult {
  const KalatrakarakaResult({
    required this.primaryKaraka,
    required this.secondaryKaraka,
    required this.planetsInFifth,
    required this.score,
  });

  final Planet primaryKaraka;
  final Planet secondaryKaraka;
  final List<Planet> planetsInFifth;
  final int score;
}
