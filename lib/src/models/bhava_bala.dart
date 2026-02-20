/// Represents Bhava Bala (house strength) result.
class BhavaBalaResult {
  const BhavaBalaResult({
    required this.houseNumber,
    required this.strength,
    required this.category,
    this.lordStrength = 0,
    this.placementStrength = 0,
    this.aspectStrength = 0,
    this.digBala = 0,
  });

  /// House number (1-12)
  final int houseNumber;

  /// Total strength value
  final double strength;

  /// Strength category
  final BhavaStrengthCategory category;

  /// Components of Bhava Bala
  final double lordStrength;
  final double placementStrength;
  final double aspectStrength;
  final double digBala;

  @override
  String toString() {
    return 'House $houseNumber: ${strength.toStringAsFixed(1)} (${category.name})';
  }
}

/// Bhava strength categories
enum BhavaStrengthCategory {
  veryStrong('Very Strong', 90, 100),
  strong('Strong', 70, 90),
  moderate('Moderate', 50, 70),
  weak('Weak', 30, 50),
  veryWeak('Very Weak', 0, 30);

  const BhavaStrengthCategory(this.name, this.minStrength, this.maxStrength);
  final String name;
  final double minStrength;
  final double maxStrength;
}
