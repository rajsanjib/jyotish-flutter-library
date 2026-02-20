import '../models/planet.dart';

enum VimsopakaCategory {
  atipoorna('Atipoorna', 18, 20, 'Exceptional - Best results'),
  poorna('Poorna', 16, 18, 'Very Good'),
  atimadhya('Atimadhya', 14, 16, 'Above Average'),
  madhya('Madhya', 12, 14, 'Average'),
  adhama('Adhama', 10, 12, 'Below Average'),
  durga('Durga', 8, 10, 'Weak'),
  sangatDurga('Sangat Durga', 5, 8, 'Very Weak');

  const VimsopakaCategory(this.name, this.minScore, this.maxScore, this.description);
  final String name;
  final double minScore;
  final double maxScore;
  final String description;
}

class VimsopakaBalaResult {
  const VimsopakaBalaResult({
    required this.planet,
    required this.totalScore,
    required this.vargaScore,
    required this.sambandhaScore,
    required this.category,
  });

  final Planet planet;
  final double totalScore;
  final double vargaScore;
  final double sambandhaScore;
  final VimsopakaCategory category;

  @override
  String toString() {
    return '${planet.displayName}: ${totalScore.toStringAsFixed(1)}/20 (${category.name})';
  }
}

class EnhancedBhavaBalaResult {
  const EnhancedBhavaBalaResult({
    required this.houseNumber,
    required this.totalStrength,
    required this.category,
    required this.lordStrength,
    required this.kendradiStrength,
    required this.drishtiStrength,
    required this.vimsopakaStrength,
    this.kendraType,
  });

  final int houseNumber;
  final double totalStrength;
  final EnhancedBhavaStrengthCategory category;
  final double lordStrength;
  final double kendradiStrength;
  final double drishtiStrength;
  final double vimsopakaStrength;
  final KendraType? kendraType;

  @override
  String toString() {
    return 'House $houseNumber: ${totalStrength.toStringAsFixed(1)} (${category.name})';
  }
}

enum EnhancedBhavaStrengthCategory {
  atiShadbalapurna('Ati-Shadbalapurna', 150, 200, 'Exceptionally Strong'),
  shadbalapurna('Shadbalapurna', 120, 150, 'Very Strong'),
  shadbalardha('Shadbalardha', 90, 120, 'Strong'),
  madhyama('Madhyama', 60, 90, 'Moderate'),
  krishna('Krishna', 30, 60, 'Weak'),
  atiKrishna('Ati-Krishna', 0, 30, 'Very Weak');

  const EnhancedBhavaStrengthCategory(this.name, this.minStrength, this.maxStrength, this.description);
  final String name;
  final double minStrength;
  final double maxStrength;
  final String description;
}

enum KendraType {
  kendra('Kendra', 1, 'Angular - Most Strong'),
  panaphara('Panaphara', 2, 'Succedent - Moderate'),
  apoklima('Apoklima', 3, 'Cadent - Weakest');

  const KendraType(this.name, this.rank, this.description);
  final String name;
  final int rank;
  final String description;
}

class HouseStrengthSummary {
  const HouseStrengthSummary({
    required this.houseResults,
    required this.averageStrength,
    required this.strongestHouse,
    required this.weakestHouse,
  });

  final Map<int, EnhancedBhavaBalaResult> houseResults;
  final double averageStrength;
  final int strongestHouse;
  final int weakestHouse;
}
