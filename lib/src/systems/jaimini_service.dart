import 'package:jyotish/src/systems/jaimini.dart';
import 'package:jyotish/src/models/planet.dart';
import 'package:jyotish/src/models/rashi.dart';
import 'package:jyotish/src/models/vedic_chart.dart';
import 'package:dartx/dartx.dart';

/// Service for Jaimini astrology calculations (Karakamsa, Rashi Drishti).
class JaiminiService {
  /// Returns all Chara Karakas ranked from highest to lowest degree.
  ///
  /// [useEightKarakaScheme] - if true (default), uses 8 candidates including Rahu.
  /// If false, uses 7 classical planets (Sun through Saturn) without Rahu.
  CharaKarakaResult getCharaKarakas(
    VedicChart chart, {
    bool useEightKarakaScheme = true, // Default to 8-karaka per user decision
  }) {
    final candidates = useEightKarakaScheme
        ? [
            Planet.sun,
            Planet.moon,
            Planet.mars,
            Planet.mercury,
            Planet.jupiter,
            Planet.venus,
            Planet.saturn,
            Planet.meanNode
          ]
        : [
            Planet.sun,
            Planet.moon,
            Planet.mars,
            Planet.mercury,
            Planet.jupiter,
            Planet.venus,
            Planet.saturn
          ];

    final ranked = candidates.where((p) => chart.getPlanet(p) != null).toList()
      ..sort((a, b) {
        double degA = chart.getPlanet(a)!.longitude % 30;
        double degB = chart.getPlanet(b)!.longitude % 30;
        // Rahu's degree is measured in reverse
        if (a == Planet.meanNode || a == Planet.trueNode) degA = 30.0 - degA;
        if (b == Planet.meanNode || b == Planet.trueNode) degB = 30.0 - degB;
        return degB.compareTo(degA); // descending
      });

    return CharaKarakaResult(
      karakas: ranked.take(useEightKarakaScheme ? 8 : 7).toList(),
      scheme: useEightKarakaScheme,
    );
  }

  /// Convenience - returns only the Atmakaraka.
  Planet getAtmakaraka(VedicChart chart, {bool useEightKarakaScheme = true}) =>
      getCharaKarakas(chart, useEightKarakaScheme: useEightKarakaScheme)
          .atmakaraka;

  /// Gets Karakamsa information.
  /// Requires both Rashi (D1) and Navamsa (D9) charts.
  KarakamsaInfo getKarakamsa({
    required VedicChart rashiChart,
    required VedicChart navamsaChart,
  }) {
    final ak = getAtmakaraka(rashiChart);

    // Find AK's position in Navamsa
    final akInNavamsa = navamsaChart.getPlanet(ak);
    if (akInNavamsa == null) {
      throw Exception('Atmakaraka not found in Navamsa chart');
    }

    final karakamsaSign = Rashi.fromLongitude(akInNavamsa.longitude);
    final karakamsaHouse = akInNavamsa.house;

    return KarakamsaInfo(
      atmakaraka: ak,
      karakamsaSign: karakamsaSign,
      karakamsaHouse: karakamsaHouse,
    );
  }

  /// Calculates all Rashi Drishti (sign aspects) for a chart.
  ///
  /// Jaimini Rashi Drishti rules:
  /// - Movable signs (1, 4, 7, 10) aspect Fixed signs except the adjacent one.
  /// - Fixed signs (2, 5, 8, 11) aspect Movable signs except the adjacent one.
  /// - Dual signs (3, 6, 9, 12) aspect each other.
  List<RashiDrishtiInfo> calculateRashiDrishti(VedicChart chart) {
    final drishtiList = <RashiDrishtiInfo>[];

    for (final aspectingRashi in Rashi.values) {
      final aspectedSigns = _getAspectedSigns(aspectingRashi);

      for (final aspectedRashi in aspectedSigns) {
        final planetsInAspecting = _getPlanetsInSign(chart, aspectingRashi);
        final planetsInAspected = _getPlanetsInSign(chart, aspectedRashi);

        drishtiList.add(RashiDrishtiInfo(
          aspectingSign: aspectingRashi,
          aspectedSign: aspectedRashi,
          planetsInAspectingSign: planetsInAspecting,
          planetsInAspectedSign: planetsInAspected,
        ));
      }
    }

    return drishtiList;
  }

  /// Alias for [calculateRashiDrishti] to support legacy tests.
  List<RashiDrishtiInfo> getRashiDrishtiList(VedicChart chart) =>
      calculateRashiDrishti(chart);

  /// Returns signs aspected by a specific sign OR all sign aspects.
  /// Modified to support both legacy test signatures.
  dynamic getRashiDrishti(VedicChart chart, [Rashi? rashi]) {
    if (rashi != null) {
      return _getAspectedSigns(rashi);
    }
    return calculateRashiDrishti(chart);
  }

  /// Gets Rashi Drishti specifically for houses containing planets.
  List<RashiDrishtiInfo> calculateActiveRashiDrishti(VedicChart chart) {
    final drishtiList = <RashiDrishtiInfo>[];

    for (final aspectingRashi in Rashi.values) {
      final planetsInAspecting = _getPlanetsInSign(chart, aspectingRashi);
      if (planetsInAspecting.isEmpty) continue; // Only consider occupied signs

      final aspectedSigns = _getAspectedSigns(aspectingRashi);

      for (final aspectedRashi in aspectedSigns) {
        final planetsInAspected = _getPlanetsInSign(chart, aspectedRashi);

        drishtiList.add(RashiDrishtiInfo(
          aspectingSign: aspectingRashi,
          aspectedSign: aspectedRashi,
          planetsInAspectingSign: planetsInAspecting,
          planetsInAspectedSign: planetsInAspected,
        ));
      }
    }

    return drishtiList;
  }

  /// Alias for [calculateActiveRashiDrishti] to support legacy tests.
  List<RashiDrishtiInfo> getActiveRashiDrishti(VedicChart chart) =>
      calculateActiveRashiDrishti(chart);

  List<Rashi> _getAspectedSigns(Rashi rashi) {
    final quality = _getSignQuality(rashi);

    switch (quality) {
      case _SignQuality.movable:
        return Rashi.values.where((r) {
          if (_getSignQuality(r) != _SignQuality.fixed) return false;
          final diff = (r.index - rashi.index).abs();
          return diff != 1 && diff != 11;
        }).toList();
      case _SignQuality.fixed:
        return Rashi.values.where((r) {
          if (_getSignQuality(r) != _SignQuality.movable) return false;
          final diff = (r.index - rashi.index).abs();
          return diff != 1 && diff != 11;
        }).toList();
      case _SignQuality.dual:
        return Rashi.values
            .where((r) => _getSignQuality(r) == _SignQuality.dual && r != rashi)
            .toList();
    }
  }

  _SignQuality _getSignQuality(Rashi rashi) {
    // Movable: 0=Aries, 3=Cancer, 6=Libra, 9=Capricorn
    // Fixed: 1=Taurus, 4=Leo, 7=Scorpio, 10=Aquarius
    // Dual: 2=Gemini, 5=Virgo, 8=Sagittarius, 11=Pisces
    final idx = rashi.index;
    if (idx % 3 == 0) return _SignQuality.movable;
    if (idx % 3 == 1) return _SignQuality.fixed;
    return _SignQuality.dual;
  }

  List<Planet> _getPlanetsInSign(VedicChart chart, Rashi sign) {
    return chart.planets.entries
        .filter((e) => Rashi.fromLongitude(e.value.longitude) == sign)
        .map((e) => e.key)
        .toList();
  }
}

enum _SignQuality { movable, fixed, dual }
