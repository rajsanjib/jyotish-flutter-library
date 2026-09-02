import 'package:jyotish/src/analysis/compatibility.dart';

/// Complete, zero-dependency data structure representing a marriage compatibility report.
class CompatibilityReport {
  const CompatibilityReport({
    required this.totalScore,
    required this.gunaScores,
    required this.compatibilityPercentage,
    required this.hasNadiDosha,
    required this.hasBhakootDosha,
    required this.boyManglik,
    required this.girlManglik,
    required this.boyManglikCancellations,
    required this.girlManglikCancellations,
    required this.analysis,
  });

  /// The total Guna Milan score out of 36.
  final double totalScore;

  /// Detailed scores for each of the 8 Kootas.
  final GunaScores gunaScores;

  /// The overall compatibility percentage (0 - 100).
  final double compatibilityPercentage;

  /// True if Nadi Dosha is active.
  final bool hasNadiDosha;

  /// True if Bhakoot Dosha is active.
  final bool hasBhakootDosha;

  /// True if the boy has Manglik Dosha.
  final bool boyManglik;

  /// True if the girl has Manglik Dosha.
  final bool girlManglik;

  /// Cancellation factors for the boy's Manglik Dosha.
  final List<String> boyManglikCancellations;

  /// Cancellation factors for the girl's Manglik Dosha.
  final List<String> girlManglikCancellations;

  /// Textual analysis and recommendations.
  final List<String> analysis;

  Map<String, dynamic> toJson() => {
        'totalScore': totalScore,
        'gunaScores': {
          'varna': gunaScores.varna,
          'vashya': gunaScores.vashya,
          'tara': gunaScores.tara,
          'yoni': gunaScores.yoni,
          'grahaMaitri': gunaScores.grahaMaitri,
          'gana': gunaScores.gana,
          'bhakoot': gunaScores.bhakoot,
          'nadi': gunaScores.nadi,
        },
        'compatibilityPercentage': compatibilityPercentage,
        'hasNadiDosha': hasNadiDosha,
        'hasBhakootDosha': hasBhakootDosha,
        'boyManglik': boyManglik,
        'girlManglik': girlManglik,
        'boyManglikCancellations': boyManglikCancellations,
        'girlManglikCancellations': girlManglikCancellations,
        'analysis': analysis,
      };
}
