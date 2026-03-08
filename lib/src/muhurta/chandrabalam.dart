/// Represents Chandrabalam (Moon strength) for each of the 12 Rashis.
class ChandrabalamInfo {
  const ChandrabalamInfo({
    required this.moonRashiIndex,
    required this.entries,
  });

  /// Moon's current Rashi index (0-11)
  final int moonRashiIndex;

  /// Chandrabalam for each of the 12 Rashis
  final List<ChandrabalamEntry> entries;
}

/// A single entry indicating the Chandrabalam for a specific Rashi.
class ChandrabalamEntry {
  const ChandrabalamEntry({
    required this.rashiIndex,
    required this.level,
    required this.position,
  });

  /// The Rashi index being evaluated (0-11)
  final int rashiIndex;

  /// The strength level (strong, moderate, weak)
  final ChandrabalamLevel level;

  /// Position count from Moon's current Rashi (1-12)
  final int position;
}

/// The levels of Chandrabalam auspiciousness.
enum ChandrabalamLevel {
  strong('Strong / Auspicious'),
  moderate('Moderate'),
  weak('Weak / Inauspicious');

  const ChandrabalamLevel(this.description);
  final String description;
}
