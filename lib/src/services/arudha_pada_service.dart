import '../models/arudha_pada.dart';
import '../models/planet.dart';
import '../models/rashi.dart';
import '../models/vedic_chart.dart';

/// Service for calculating Jaimini Arudha Padas.
class ArudhaPadaService {
  /// Calculates all Arudha Padas for a given chart.
  ArudhaPadaResult calculateArudhaPadas(VedicChart chart) {
    final allPadas = <int, ArudhaPadaInfo>{};

    for (var i = 1; i <= 12; i++) {
      final pada = _calculateArudhaForHouse(chart, i);
      allPadas[i] = pada;
    }

    return ArudhaPadaResult(
      arudhaLagna: allPadas[1]!,
      upapada: allPadas[12]!,
      allPadas: allPadas,
    );
  }

  /// Calculates Arudha Lagna (AL).
  ArudhaPadaInfo calculateArudhaLagna(VedicChart chart) {
    return _calculateArudhaForHouse(chart, 1);
  }

  /// Calculates Upapada (UL).
  ArudhaPadaInfo calculateUpapada(VedicChart chart) {
    return _calculateArudhaForHouse(chart, 12);
  }

  ArudhaPadaInfo _calculateArudhaForHouse(VedicChart chart, int houseNumber) {
    // 1. Identify Sign of the House
    // chart.houses.cusps gives cusp degrees.
    // For Vedic, typically Whole Sign or Equal House is used for Rashi based calculations (like Arudha).
    // If using Whole Sign, the sign of the house is simply (AscendantSign + HouseNum - 1).
    // If using Placidus/etc, we take the sign of the cusp.
    // Given the context of Jaimini, it strongly implies Rashi-based houses (Whole Sign).
    // But let's use the cusp to be generic? No, Jaimini is sign-based.
    // If charts are generated with Placidus, using cusp sign is safer?
    // Actually, Jaimini mostly uses Whole Sign houses (Rashi Dasha etc).
    // Let's deduce the sign from the cusp longitude.
    // Note: If using Placidus, cusp 1 might be 29 deg Aries. Sign is Aries.
    // House 2 cusp might be 25 deg Taurus. Sign is Taurus.
    // Intercepted signs are tricky.
    // BUT Arudha logic counts Signs. "Signs" are the houses in Jaimini.
    // So we should assume House 1 = Sign containing Ascendant.
    // House 2 = Next Sign.
    // Irrespective of house system used for Bhava Chalit?
    // Strictly speaking, Arudha is calculated on Rashi Chart (D1). Rashi Chart IS Whole Sign by definition (House 1 = Ascendant Sign).
    // So better logic: Identify Ascendant Sign. House N Sign = (AscendantSign + N - 1) % 12.

    // Let's use Ascendant from chart.
    final ascendantDegree = chart.ascendant;
    final lagnaSign = Rashi.fromLongitude(ascendantDegree);

    // House N Sign
    // houseNumber is 1-based.
    // index = (lagnaSign.index + houseNumber - 1) % 12
    final houseSignIndex = (lagnaSign.index + houseNumber - 1) % 12;
    final houseSign = Rashi.values[houseSignIndex];

    // 2. Identify Lord of that Sign and its position
    final lordSign = _getLordPosition(chart, houseSign);

    // 4. Calculate Distance (in signs) from House Sign to Lord Sign
    // Standard inclusive count.
    // e.g. Aries(1) to Cancer(4) = 4.
    // Formula: (Lord - House + 12) % 12 + 1
    // Note: Rashi index? Rashi enum usually doesn't expose index directly 1-12 easily unless we map it.
    // Rashi.aries ...
    // Let's assume Rashi has index 0-11 or we helper it.
    final houseSignIdx = _getRashiIndex(houseSign); // 1-12
    final lordSignIdx = _getRashiIndex(lordSign); // 1-12

    int dist = (lordSignIdx - houseSignIdx + 12) % 12;
    // Modulo 12 gives 0-11.
    // If indices are 1-based:
    // (4 - 1 + 12) % 12 = 3. count is 4. So +1.
    // (1 - 1 + 12) % 12 = 0. count is 1. So +1.
    dist += 1; // Distance is 1-12.

    // 5. Count Same Distance from Lord Sign
    // New index = (LordIndex + (dist - 1) - 1) % 12 + 1
    // Wait: LordIndex is 1-based.
    // (L - 1) converts to 0-based.
    // + (dist - 1) moves that many steps.
    // % 12 wraps.
    // + 1 converts back to 1-based.
    int arudhaIndex = (lordSignIdx - 1 + (dist - 1)) % 12 + 1;

    // 6. Exceptions
    // If Arudha falls in Same House (1st) or 7th from House?
    // Let's check the calculated arudha against the original house sign.

    // Check distance between Original House and Calculated Arudha
    // (Arudha - House + 12) % 12 + 1
    int distFromHouse = (arudhaIndex - houseSignIdx + 12) % 12 + 1;

    // Exception 1: Arudha falls in the House itself (Dist 1)
    if (distFromHouse == 1) {
      // Move to 10th from Arudha (which is 10th from House)
      arudhaIndex = (arudhaIndex - 1 + (10 - 1)) % 12 + 1;
    }
    // Exception 2: Arudha falls in 7th from House (Dist 7)
    else if (distFromHouse == 7) {
      // Move to 10th from Arudha (which is 4th from House effectively)
      arudhaIndex = (arudhaIndex - 1 + (10 - 1)) % 12 + 1;
    }

    // Determine Rashi from index
    final arudhaSign = _getRashiFromIndex(arudhaIndex);

    // Determine House from Lagna
    // Lagna sign index (1-based for math)
    final lagnaSignIdx = _getRashiIndex(lagnaSign);

    // House num = (Arudha - Lagna + 12) % 12 + 1
    final houseFromLagna = (arudhaIndex - lagnaSignIdx + 12) % 12 + 1;

    // Name
    String name;
    if (houseNumber == 1)
      name = 'AL';
    else if (houseNumber == 12)
      name = 'UL';
    else
      name = 'A$houseNumber';

    return ArudhaPadaInfo(
      houseNumber: houseNumber,
      name: name,
      sign: arudhaSign,
      houseFromLagna: houseFromLagna,
    );
  }

  /// Determines the Rashi where the lord of the sign is placed,
  /// considering dual lordship for Scorpio and Aquarius.
  Rashi _getLordPosition(VedicChart chart, Rashi rashi) {
    if (rashi == Rashi.scorpio) {
      return _getStrongerLord(chart, Planet.mars, Planet.ketu, rashi);
    } else if (rashi == Rashi.aquarius) {
      return _getStrongerLord(
          chart, Planet.saturn, Planet.meanNode, rashi); // Rahu
    } else {
      final lord = _getSignLord(rashi);
      final lordInfo = chart.getPlanet(lord);
      if (lordInfo == null)
        throw Exception('Lord position not found for $lord');
      return Rashi.fromLongitude(lordInfo.longitude);
    }
  }

  /// Jaimini Strength rules to find stronger of two lords:
  /// 1. Planet with more planets in its sign is stronger.
  /// 2. If one is in the sign itself and other is not, the one NOT in sign is stronger (for Arudha).
  /// 3. If still equal, the one with more degrees is stronger.
  Rashi _getStrongerLord(
      VedicChart chart, Planet p1, Planet p2, Rashi ownSign) {
    final info1 = chart.getPlanet(p1);
    final info2 = chart.getPlanet(p2);

    if (info1 == null && info2 == null) throw Exception('Lords not found');
    if (info1 == null) return Rashi.fromLongitude(info2!.longitude);
    if (info2 == null) return Rashi.fromLongitude(info1.longitude);

    final sign1 = Rashi.fromLongitude(info1.longitude);
    final sign2 = Rashi.fromLongitude(info2.longitude);

    // Rule 2: If one is in own sign, other is stronger
    if (sign1 == ownSign && sign2 != ownSign) return sign2;
    if (sign2 == ownSign && sign1 != ownSign) return sign1;

    // Rule 1: More planets in sign
    final planets1 = chart.planets.values
        .where((p) => Rashi.fromLongitude(p.longitude) == sign1)
        .length;
    final planets2 = chart.planets.values
        .where((p) => Rashi.fromLongitude(p.longitude) == sign2)
        .length;

    if (planets1 > planets2) return sign1;
    if (planets2 > planets1) return sign2;

    // Rule 3: More degrees
    final deg1 = info1.longitude % 30;
    final deg2 = info2.longitude % 30;

    return deg1 >= deg2 ? sign1 : sign2;
  }

  // Helpers

  int _getRashiIndex(Rashi rashi) {
    // Assuming Rashi enum order matches zodiac order (Aries=0, etc.)
    return rashi.index + 1;
  }

  Rashi _getRashiFromIndex(int index) {
    // 1-based index to 0-based enum
    return Rashi.values[(index - 1) % 12];
  }

  Planet _getSignLord(Rashi rashi) {
    // Standard lords.
    // Dual lordship (Scorpio/Aquarius) is handled in _getLordPosition.
    switch (rashi) {
      case Rashi.aries:
      case Rashi.scorpio:
        return Planet.mars;
      case Rashi.taurus:
      case Rashi.libra:
        return Planet.venus;
      case Rashi.gemini:
      case Rashi.virgo:
        return Planet.mercury;
      case Rashi.cancer:
        return Planet.moon;
      case Rashi.leo:
        return Planet.sun;
      case Rashi.sagittarius:
      case Rashi.pisces:
        return Planet.jupiter;
      case Rashi.capricorn:
      case Rashi.aquarius:
        return Planet.saturn;
    }
  }
}
