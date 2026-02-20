enum CompatibilityLevel {
  excellent('Excellent', 33, 36, 'Highly compatible'),
  veryGood('Very Good', 25, 32, 'Very good compatibility'),
  good('Good', 18, 24, 'Good compatibility'),
  average('Average', 12, 17, 'Average - needs work'),
  poor('Poor', 0, 11, 'Not recommended');

  const CompatibilityLevel(this.name, this.minScore, this.maxScore, this.description);
  final String name;
  final int minScore;
  final int maxScore;
  final String description;
}

class CompatibilityResult {
  const CompatibilityResult({
    required this.totalScore,
    required this.level,
    required this.gunaScores,
    required this.doshaCheck,
    required this.dashaCompatibility,
    required this.analysis,
  });

  final int totalScore;
  final CompatibilityLevel level;
  final GunaScores gunaScores;
  final DoshaCheck doshaCheck;
  final DashaCompatibility? dashaCompatibility;
  final List<String> analysis;

  @override
  String toString() => 'Compatibility: $level ($totalScore/36)';
}

class GunaScores {
  const GunaScores({
    required this.varna,
    required this.vashya,
    required this.tara,
    required this.yoni,
    required this.grahaMaitri,
    required this.gana,
    required this.bhakoot,
    required this.nadi,
  });

  final int varna;
  final int vashya;
  final int tara;
  final int yoni;
  final int grahaMaitri;
  final int gana;
  final int bhakoot;
  final int nadi;

  int get total => varna + vashya + tara + yoni + grahaMaitri + gana + bhakoot + nadi;
}

class DoshaCheck {
  const DoshaCheck({
    required this.hasManglikDosha,
    required this.hasNadiDosha,
    required this.hasBhakootDosha,
    required this.manglikSeverity,
    required this.cancellations,
  });

  final bool hasManglikDosha;
  final bool hasNadiDosha;
  final bool hasBhakootDosha;
  final String manglikSeverity;
  final List<String> cancellations;
}

class ManglikDoshaResult {
  const ManglikDoshaResult({
    required this.isManglik,
    required this.housesAffected,
    required this.severity,
    required this.remedies,
  });

  final bool isManglik;
  final List<int> housesAffected;
  final String severity;
  final List<String> remedies;
}

class NadiDoshaResult {
  const NadiDoshaResult({
    required this.hasDosha,
    required this.boyNadi,
    required this.girlNadi,
  });

  final bool hasDosha;
  final String boyNadi;
  final String girlNadi;
}

class BhakootDoshaResult {
  const BhakootDoshaResult({
    required this.hasDosha,
    required this.boyRashi,
    required this.girlRashi,
    required this.description,
  });

  final bool hasDosha;
  final String boyRashi;
  final String girlRashi;
  final String description;
}

class DashaCompatibility {
  const DashaCompatibility({
    required this.score,
    required this.analysis,
  });

  final int score;
  final List<String> analysis;
}

class AshtakootaResult {
  const AshtakootaResult({
    required this.gunaScores,
    required this.totalScore,
    required this.level,
    required this.details,
  });

  final GunaScores gunaScores;
  final int totalScore;
  final CompatibilityLevel level;
  final Map<String, String> details;
}
