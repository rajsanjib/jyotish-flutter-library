import '../models/planet.dart';

/// Represents information about Nakshatras including Abhijit (28th).
class NakshatraInfo {
  const NakshatraInfo({
    required this.number,
    required this.name,
    required this.rulingPlanet,
    required this.longitude,
    required this.pada,
    this.isAbhijit = false,
    this.abhijitPortion = 0.0,
  });

  final int number;
  final String name;
  final Planet rulingPlanet;
  final double longitude;
  final int pada;
  final bool isAbhijit;
  final double abhijitPortion;

  static const List<String> nakshatraNames = [
    'Ashwini',
    'Bharani',
    'Krittika',
    'Rohini',
    'Mrigashira',
    'Ardra',
    'Punarvasu',
    'Pushya',
    'Ashlesha',
    'Magha',
    'Purva Phalguni',
    'Uttara Phalguni',
    'Hasta',
    'Chitra',
    'Swati',
    'Vishakha',
    'Anuradha',
    'Jyeshtha',
    'Mula',
    'Purva Ashadha',
    'Uttara Ashadha',
    'Shravana',
    'Dhanishta',
    'Shatabhisha',
    'Purva Bhadrapada',
    'Uttara Bhadrapada',
    'Revati',
    'Abhijit',
  ];

  static final List<Planet> nakshatraLords = [
    Planet.ketu,
    Planet.venus,
    Planet.sun,
    Planet.moon,
    Planet.mars,
    Planet.meanNode,
    Planet.jupiter,
    Planet.saturn,
    Planet.mercury,
    Planet.ketu,
    Planet.venus,
    Planet.sun,
    Planet.moon,
    Planet.mars,
    Planet.meanNode,
    Planet.jupiter,
    Planet.saturn,
    Planet.mercury,
    Planet.ketu,
    Planet.venus,
    Planet.sun,
    Planet.moon,
    Planet.mars,
    Planet.meanNode,
    Planet.jupiter,
    Planet.saturn,
    Planet.mercury,
  ];

  static const double abhijitStart = 276.6666667;
  static const double abhijitEnd = 286.6666667;

  static final Map<int, Planet> nakshatraDashaLords = {
    1: Planet.ketu,
    2: Planet.venus,
    3: Planet.sun,
    4: Planet.moon,
    5: Planet.mars,
    6: Planet.meanNode,
    7: Planet.jupiter,
    8: Planet.saturn,
    9: Planet.mercury,
    10: Planet.ketu,
    11: Planet.venus,
    12: Planet.sun,
    13: Planet.moon,
    14: Planet.mars,
    15: Planet.meanNode,
    16: Planet.jupiter,
    17: Planet.saturn,
    18: Planet.mercury,
    19: Planet.ketu,
    20: Planet.venus,
    21: Planet.sun,
    22: Planet.moon,
    23: Planet.mars,
    24: Planet.meanNode,
    25: Planet.jupiter,
    26: Planet.saturn,
    27: Planet.mercury,
  };

  @override
  String toString() {
    return 'NakshatraInfo($name #$number, Pada $pada, Ruler: ${rulingPlanet.displayName})';
  }
}
