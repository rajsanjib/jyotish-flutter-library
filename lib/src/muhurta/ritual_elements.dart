/// Represents ceremonial and astrological ritual elements for a day.
class RitualElements {
  const RitualElements({
    required this.homahuti,
    required this.agnivasa,
    required this.shivavasa,
    required this.kumbhaChakra,
  });

  /// Auspiciousness of performing Homa (Fire Sacrifice)
  final HomahutiLevel homahuti;

  /// Agni Vasa - Where the Fire God resides today
  final String agnivasa;

  /// Shiva Vasa - Where Lord Shiva resides today
  final String shivavasa;

  /// Kumbha Chakra - Pot Placement auspiciousness format
  final KumbhaChakraLevel kumbhaChakra;
}

enum HomahutiLevel {
  siddha('Siddha (Perfect)'),
  auspicious('Auspicious'),
  inauspicious('Inauspicious');

  const HomahutiLevel(this.description);
  final String description;
}

enum KumbhaChakraLevel {
  excellent('Excellent / Top'),
  good('Good / Side'),
  neutral('Neutral / Below'),
  bad('Bad / Broken');

  const KumbhaChakraLevel(this.description);
  final String description;
}
