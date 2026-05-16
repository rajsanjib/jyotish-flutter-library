import 'package:jyotish/src/models/planet.dart';
import 'package:jyotish/src/models/rashi.dart';

/// Represents the Karakamsa (Atmakaraka's sign in Navamsa).
class KarakamsaInfo {
  const KarakamsaInfo({
    required this.atmakaraka,
    required this.karakamsaSign,
    required this.karakamsaHouse,
  });

  /// The Atmakaraka planet (planet with highest degree).
  final Planet atmakaraka;

  /// The sign where Atmakaraka is placed in the Navamsa chart.
  final Rashi karakamsaSign;

  /// The house number from Navamsa Lagna where Karakamsa falls.
  final int karakamsaHouse;
}

/// Represents Rashi Drishti (Sign aspects in Jaimini system).
class RashiDrishtiInfo {
  const RashiDrishtiInfo({
    required this.aspectingSign,
    required this.aspectedSign,
    this.planetsInAspectingSign = const [],
    this.planetsInAspectedSign = const [],
  });

  /// The sign casting the aspect.
  final Rashi aspectingSign;

  /// Alias for [aspectingSign] for legacy tests.
  Rashi get sourceSign => aspectingSign;

  /// The sign receiving the aspect.
  final Rashi aspectedSign;

  /// Alias for [aspectedSign] for legacy tests.
  Rashi get targetSign => aspectedSign;

  /// Planets in the aspecting sign.
  final List<Planet> planetsInAspectingSign;

  /// Planets in the aspected sign.
  final List<Planet> planetsInAspectedSign;
}

/// Represents the full Chara Karaka ranking for a chart.
///
/// Karaka order: AK (1st) -> AmK (2nd) -> BK (3rd) -> MK (4th)
///              -> PK (5th) -> GK (6th) -> DK (7th).
/// In the 8-karaka scheme, all 8 are used. In the 7-karaka scheme,
/// the 8th slot (if any) is empty or ignored.
class CharaKarakaResult {
  const CharaKarakaResult({required this.karakas, required this.scheme});

  /// Planets ranked highest-degree-first.
  final List<Planet> karakas;

  /// Whether the 8-karaka scheme (with Rahu) was used.
  final bool scheme; // true = 8-karaka, false = 7-karaka

  Planet get atmakaraka => karakas[0];
  Planet get amatyakaraka => karakas[1];
  Planet get bhratrukaraka => karakas[2];
  Planet get matrukaraka => karakas[3];
  Planet get putrukaraka => karakas[4];
  Planet get gnatikaraka => karakas[5];
  Planet get darakaraka => karakas[6];
  Planet? get apoklima =>
      karakas.length > 7 ? karakas[7] : null; // 8th karaka if applicable
}
