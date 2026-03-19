/// Levels of marriage compatibility based on the total Guna score (out of 36).
enum CompatibilityLevel {
  /// Excellent compatibility (33-36 points).
  excellent('Excellent', 33, 36, 'Highly compatible'),

  /// Very good compatibility (25-32 points).
  veryGood('Very Good', 25, 32, 'Very good compatibility'),

  /// Good compatibility (18-24 points).
  good('Good', 18, 24, 'Good compatibility'),

  /// Average compatibility (12-17 points).
  average('Average', 12, 17, 'Average - needs work'),

  /// Poor compatibility (0-11 points).
  poor('Poor', 0, 11, 'Not recommended');

  const CompatibilityLevel(
      this.name, this.minScore, this.maxScore, this.description);

  /// Display name of the compatibility level.
  final String name;

  /// Minimum score for this level.
  final int minScore;

  /// Maximum score for this level.
  final int maxScore;

  /// Human-readable description of the compatibility.
  final String description;
}

/// The final result of a marriage compatibility analysis (Ashtakoota Milan).
class CompatibilityResult {
  const CompatibilityResult({
    required this.totalScore,
    required this.level,
    required this.gunaScores,
    required this.doshaCheck,
    required this.dashaCompatibility,
    required this.analysis,
  });

  /// The total score out of 36.
  final double totalScore;

  /// The overall compatibility level based on the score.
  final CompatibilityLevel level;

  /// Individual scores for each of the 8 Kootas.
  final GunaScores gunaScores;

  /// Results of critical Dosha checks (Manglik, Nadi, etc.).
  final DoshaCheck doshaCheck;

  /// Compatibility based on the current and future Dasha periods of both partners.
  final DashaCompatibility? dashaCompatibility;

  /// Detailed textual analysis and recommendations.
  final List<String> analysis;

  @override
  String toString() => 'Compatibility: $level ($totalScore/36)';
}

/// Scores for the eight categories (Kootas) in Ashtakoota Milan.
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

  /// Spiritual/Work compatibility (Max score: 1).
  final int varna;

  /// Power/Dominance compatibility (Max score: 2).
  final int vashya;

  /// Destiny/Longevity compatibility (Max score: 3).
  final double tara;

  /// Biological/Instinctual compatibility (Max score: 4).
  final int yoni;

  /// Psychological/Friendship compatibility (Max score: 5).
  final int grahaMaitri;

  /// Temperament compatibility (Deva, Manushya, Rakshasa) (Max score: 6).
  final int gana;

  /// Constructive/Emotional compatibility (Max score: 7).
  final int bhakoot;

  /// Health/Progeny compatibility (Max score: 8).
  final int nadi;

  /// Total sum of all Guna scores.
  double get total =>
      varna + vashya + tara + yoni + grahaMaitri + gana + bhakoot + nadi;
}

/// A summary of astrological flaws (Doshas) found during compatibility analysis.
class DoshaCheck {
  const DoshaCheck({
    required this.hasManglikDosha,
    required this.hasNadiDosha,
    required this.hasBhakootDosha,
    required this.manglikSeverity,
    required this.cancellations,
  });

  /// True if Manglik Dosha (Kuja Dosha) is present in either chart.
  final bool hasManglikDosha;

  /// True if Nadi Dosha is present (most critical Ashtakoota flaw).
  final bool hasNadiDosha;

  /// True if Bhakoot Dosha (Rashi Dosha) is present.
  final bool hasBhakootDosha;

  /// Descriptive severity of Manglik Dosha (e.g., "None", "Low", "High").
  final String manglikSeverity;

  /// List of factors that cancel or mitigate the identified Doshas.
  final List<String> cancellations;
}

/// Detailed result of Manglik Dosha (Kuja Dosha) analysis.
class ManglikDoshaResult {
  const ManglikDoshaResult({
    required this.isManglik,
    required this.housesAffected,
    required this.severity,
    required this.remedies,
  });

  /// True if the person is Manglik.
  final bool isManglik;

  /// The houses (1, 2, 4, 7, 8, 12) where Mars is placed causing the Dosha.
  final List<int> housesAffected;

  /// Severity level of the Dosha.
  final String severity;

  /// Suggested remedies if the Dosha is present.
  final List<String> remedies;
}

/// Result of Nadi Dosha check.
class NadiDoshaResult {
  const NadiDoshaResult({
    required this.hasDosha,
    required this.boyNadi,
    required this.girlNadi,
  });

  /// True if Nadi Dosha is present (same Nadi).
  final bool hasDosha;

  /// The Nadi of the boy (Adi, Madhya, or Antya).
  final String boyNadi;

  /// The Nadi of the girl (Adi, Madhya, or Antya).
  final String girlNadi;
}

/// Result of Bhakoot (Rashi) Dosha check.
class BhakootDoshaResult {
  const BhakootDoshaResult({
    required this.hasDosha,
    required this.boyRashi,
    required this.girlRashi,
    required this.description,
  });

  /// True if Bhakoot Dosha is present (e.g., 2/12, 6/8, 5/9 relationships).
  final bool hasDosha;

  /// The Moon sign (Rashi) of the boy.
  final String boyRashi;

  /// The Moon sign (Rashi) of the girl.
  final String girlRashi;

  /// Detailed description of the Rashi relationship.
  final String description;
}

/// Compatibility analysis based on planetary periods (Dashas).
class DashaCompatibility {
  const DashaCompatibility({
    required this.score,
    required this.analysis,
  });

  /// A numeric score representing Dasha synchronization.
  final int score;

  /// Textual analysis of overlapping Dasha periods.
  final List<String> analysis;
}

/// Result object for the Ashtakoota calculation process.
class AshtakootaResult {
  const AshtakootaResult({
    required this.gunaScores,
    required this.totalScore,
    required this.level,
    required this.details,
  });

  /// Individual Guna scores.
  final GunaScores gunaScores;

  /// Final score out of 36.
  final double totalScore;

  /// Compatibility level description.
  final CompatibilityLevel level;

  /// A map of detailed explanations for each Koota result.
  final Map<String, String> details;
}
