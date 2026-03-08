import 'package:jyotish/src/models/planet.dart';
import 'package:jyotish/src/models/rashi.dart';

enum TajakaYogaType {
  itthasala('Itthasala', 'Mutual applying aspect between faster and slower planets.'),
  ishrafa('Ishrafa', 'Separating aspect, indicating a past event.'),
  nakta('Nakta', 'Transfer of light by a swifter third planet.'),
  yamaya('Yamaya', 'Transfer of light by a slower third planet.'),
  manaau('Manaau', 'Yoga broken by debilitation or combustion.');

  const TajakaYogaType(this.name, this.description);
  final String name;
  final String description;
}

class TajakaYoga {
  const TajakaYoga({
    required this.type,
    required this.planet1,
    required this.planet2,
    this.mediator,
    required this.isApplying,
    required this.interpretation,
  });

  final TajakaYogaType type;
  final Planet planet1;
  final Planet planet2;
  final Planet? mediator;
  final bool isApplying;
  final String interpretation;
}

class TajakaEnhancement {
  const TajakaEnhancement({
    required this.munthaSign,
    required this.munthaHouse,
    required this.munthaLord,
    required this.sahams,
    required this.yogas,
  });

  /// The sign where Muntha is placed for the year
  final Rashi munthaSign;

  /// The house where Muntha is placed (1-12)
  final int munthaHouse;

  /// The lord of the Muntha sign (Munthesh)
  final Planet munthaLord;

  /// Calculated Arabic Parts / Sahams (e.g., 'Punya': 120.5 degrees)
  final Map<String, double> sahams;

  /// Important Tajaka Yogas between annual chart planets
  final List<TajakaYoga> yogas;
}
