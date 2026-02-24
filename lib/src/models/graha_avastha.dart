import 'rashi.dart';

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

/// Represents the combined Avastha (states) of a planet.
///
/// Avasthas provide deeper insight into how effectively a planet can manifest
/// its results. A planet might be well-placed by dignity (e.g., Exalted)
/// but in a Mrita (Dead) state, limiting its physical capacity to deliver.
class GrahaAvastha {
  const GrahaAvastha({
    required this.baladi,
    required this.jagratadi,
    required this.effectStrength,
    required this.description,
  });

  /// The physical/age state of the planet based on degrees in the sign.
  final BaladiAvastha baladi;

  /// The consciousness/awareness state based on dignity and placement.
  final JagratadiAvastha jagratadi;

  /// The resulting effect strength proportion (0.0 to 1.0) derived from Jagratadi.
  final double effectStrength;

  /// A human readable description of the planetary state.
  final String description;
}
