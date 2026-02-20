import '../models/planet.dart';

enum NadiType {
  agasthiya('Agasthiya', 'Sage Agastya', 'Most comprehensive Nadi system'),
  bhrigu('Bhrigu', 'Sage Bhrigu', 'Focuses on past life karma'),
  saptarshi('Saptarshi', 'Seven Sages', 'General predictions'),
  nandi('Nandi', 'Sage Nandi', 'Dharma and righteousness'),
  bharga('Bharga', 'Sun-based', 'Energy and vitality'),
  chandra('Chandra', 'Moon-based', 'Mind and emotions');

  const NadiType(this.name, this.ruler, this.description);
  final String name;
  final String ruler;
  final String description;
}

class NadiInfo {
  const NadiInfo({
    required this.nadiNumber,
    required this.nadiName,
    required this.nadiType,
    required this.startLongitude,
    required this.endLongitude,
    required this.rulingPlanet,
    required this.element,
    required this.characteristics,
  });

  final int nadiNumber;
  final String nadiName;
  final NadiType nadiType;
  final double startLongitude;
  final double endLongitude;
  final Planet rulingPlanet;
  final String element;
  final List<String> characteristics;

  @override
  String toString() => '$nadiName ($nadiType)';
}

class NadiChart {
  const NadiChart({
    required this.moonNadi,
    required this.sunNadi,
    required this.ascendantNadi,
    required this.planetNadis,
    required this.nadiSeed,
  });

  final NadiInfo moonNadi;
  final NadiInfo sunNadi;
  final NadiInfo ascendantNadi;
  final Map<Planet, NadiInfo> planetNadis;
  final int nadiSeed;

  NadiInfo? getPlanetNadi(Planet planet) => planetNadis[planet];
}

class NakshatraNadiMapping {
  const NakshatraNadiMapping({
    required this.nakshatra,
    required this.pada,
    required this.nadiNumber,
    this.nadiName = '',
  });

  final String nakshatra;
  final int pada;
  final int nadiNumber;
  final String nadiName;
}

class NadiPrediction {
  const NadiPrediction({
    required this.nadiInfo,
    required this.predictionType,
    required this.prediction,
    this.remedies = const [],
  });

  final NadiInfo nadiInfo;
  final NadiPredictionType predictionType;
  final String prediction;
  final List<String> remedies;
}

enum NadiPredictionType {
  general('General'),
  career('Career'),
  wealth('Wealth'),
  health('Health'),
  education('Education'),
  marriage('Marriage'),
  children('Children'),
  spirituality('Spirituality');

  const NadiPredictionType(this.name);
  final String name;
}

class NadiSeedResult {
  const NadiSeedResult({
    required this.seedNumber,
    required this.nadiType,
    required this.primaryNadi,
    required this.relatedNadis,
  });

  final int seedNumber;
  final NadiType nadiType;
  final NadiInfo primaryNadi;
  final List<NadiInfo> relatedNadis;
}
