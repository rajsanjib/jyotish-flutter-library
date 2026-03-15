/// The physical or age-based state of a planet according to Baladi Avastha.
enum BaladiAvastha {
  bala('Bala', 'Infant'),
  kumara('Kumara', 'Youth'),
  yuva('Yuva', 'Adult'),
  vriddha('Vriddha', 'Old'),
  mrita('Mrita', 'Dead');

  const BaladiAvastha(this.sanskrit, this.english);
  final String sanskrit;
  final String english;
}

/// The consciousness or awareness state of a planet according to Jagratadi Avastha.
enum JagratadiAvastha {
  jagrata('Jagrata', 'Awake'),
  svapna('Svapna', 'Dreaming'),
  sushupti('Sushupti', 'Sleeping');

  const JagratadiAvastha(this.sanskrit, this.english);
  final String sanskrit;
  final String english;
}

/// The condition or mood of a planet based on dignity and other factors according to Deeptadi Avastha.
enum DeeptadiAvastha {
  deepta('Deepta', 'Radiant/Exalted'),
  swastha('Swastha', 'Comfortable/Own Sign'),
  mudita('Mudita', 'Happy/Great Friend Sign'),
  shanta('Shanta', 'Peaceful/Friend Sign'),
  dina('Dina', 'Humble/Neutral Sign'),
  dukhita('Dukhita', 'Distressed/Enemy Sign'),
  vikala('Vikala', 'Crippled/Debilitated'),
  khala('Khala', 'Mischievous/Combust'),
  kopa('Kopa', 'Angry/Defeated');

  const DeeptadiAvastha(this.sanskrit, this.english);
  final String sanskrit;
  final String english;
}

/// Represents the combined Avastha (states) of a planet.
///
/// Avasthas provide deeper insight into how effectively a planet can manifest
/// its results. A planet might be well-placed by dignity (e.g., Exalted)
/// but in a Mrita (Dead) state, limiting its physical capacity to deliver.
class GrahaAvastha {
  const GrahaAvastha({
    required this.baladi,
    required this.jagratadi,
    required this.deeptadi,
    required this.effectStrength,
    required this.description,
  });

  /// The physical/age state of the planet based on degrees in the sign.
  final BaladiAvastha baladi;

  /// The consciousness/awareness state based on dignity and placement.
  final JagratadiAvastha jagratadi;

  /// The mood/condition of the planet based on dignity and combustion.
  final DeeptadiAvastha deeptadi;

  /// The resulting effect strength proportion (0.0 to 1.0) derived from Jagratadi.
  final double effectStrength;

  /// A human readable description of the planetary state.
  final String description;
}
