/// Represents Tarabalam (Star strength) for a given birth Nakshatra.
class TarabalamInfo {
  const TarabalamInfo({
    required this.currentNakshatraIndex,
    required this.birthNakshatraIndex,
    required this.taraType,
  });

  /// The current day's Nakshatra index (0-26)
  final int currentNakshatraIndex;

  /// The individual's birth Nakshatra index (0-26)
  final int birthNakshatraIndex;

  /// The Tara (star type) describing the relationship
  final TaraType taraType;

  /// Whether this Tarabalam is generally considered auspicious
  bool get isAuspicious => taraType.isAuspicious;
}

/// The 9 types of Tara (Star) in Vedic astrology.
enum TaraType {
  janma('Janma (Birth)', 'Danger to body', false),
  sampat('Sampat (Wealth)', 'Wealth and prosperity', true),
  vipat('Vipat (Danger)', 'Losses and accidents', false),
  kshema('Kshema (Well-being)', 'Prosperity', true),
  pratyak('Pratyak (Obstacles)', 'Obstacles', false),
  sadhana('Sadhana (Achievement)', 'Realisation of ambition', true),
  naidhana('Naidhana (Destruction)', 'Dangers', false),
  mitra('Mitra (Friend)', 'Good', true),
  paramMitra('Param Mitra (Great Friend)', 'Very favorable', true);

  const TaraType(this.name, this.meaning, this.isAuspicious);

  final String name;
  final String meaning;
  final bool isAuspicious;
}
