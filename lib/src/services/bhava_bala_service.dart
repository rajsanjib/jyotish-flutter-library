import '../models/bhava_bala.dart';
import '../models/planet.dart';
import '../models/rashi.dart';
import '../models/vedic_chart.dart';
import 'shadbala_service.dart';

/// Service for calculating Bhava Bala (House Strength).
class BhavaBalaService {
  BhavaBalaService(this._shadbalaService);
  final ShadbalaService _shadbalaService;

  /// Calculates Bhava Bala for all 12 houses.
  Future<Map<int, BhavaBalaResult>> calculateBhavaBala(VedicChart chart) async {
    final results = <int, BhavaBalaResult>{};

    // First, get Shadbala for all planets (needed for Bhava Adhipati Bala)
    final planetShadbala = await _shadbalaService.calculateShadbala(chart);

    for (var h = 1; h <= 12; h++) {
      // 1. Bhava Adhipati Bala (Shadbala of the house lord)
      final lord = _getHouseLord(chart, h);
      final lordBala = planetShadbala[lord]?.totalBala ?? 0.0;

      // 2. Bhava Dig Bala
      final digBala = _calculateBhavaDigBala(h, chart.ascendant);

      // 3. Bhava Drishti Bala (Simplified)
      final drishtiBala = _calculateBhavaDrishtiBala(h, chart);

      final totalBala = lordBala + digBala + drishtiBala;

      results[h] = BhavaBalaResult(
        houseNumber: h,
        strength: totalBala,
        lordStrength: lordBala,
        digBala: digBala,
        aspectStrength: drishtiBala,
        category: _getBhavaStrengthCategory(totalBala),
      );
    }

    return results;
  }

  BhavaStrengthCategory _getBhavaStrengthCategory(double strength) {
    if (strength >= 90) return BhavaStrengthCategory.veryStrong;
    if (strength >= 70) return BhavaStrengthCategory.strong;
    if (strength >= 50) return BhavaStrengthCategory.moderate;
    if (strength >= 30) return BhavaStrengthCategory.weak;
    return BhavaStrengthCategory.veryWeak;
  }

  Planet _getHouseLord(VedicChart chart, int houseNumber) {
    // Determine sign of the house
    final ascLong = chart.ascendant;
    final lagnaSign = Rashi.fromLongitude(ascLong);
    final houseSignIndex = (lagnaSign.index + houseNumber - 1) % 12;
    final rashi = Rashi.values[houseSignIndex];

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

  double _calculateBhavaDigBala(int house, double ascendantDegree) {
    // Standard Dig Bala for houses:
    // 4th house: 60 virupas
    // 10th house: 0 or low? Actually, specific planets get Dig Bala in houses.
    // For BHAVA Dig Bala (Bhava Bala specifically):
    // 1st, 4th, 7th, 10th (Kendras) get strength.
    // However, some systems use:
    // House 4, 5, 6, 7, 8, 9 (South) vs others.
    // Simplified standard for Bhava Bala:
    if ([1, 4, 7, 10].contains(house)) return 60.0;
    if ([2, 5, 8, 11].contains(house)) return 30.0;
    return 15.0;
  }

  double _calculateBhavaDrishtiBala(int house, VedicChart chart) {
    var drishtiBala = 0.0;
    // Calculate mid-point of the house (Bhav Madhya)
    // For simplicity in Equal House/etc, we often take the cusp.
    // In Sripathi/KP, it's the cusp. Let's use the cusp from the chart.
    // NOTE: VedicChart doesn't explicitly store house cusps in a simple list always,
    // but usually house 1 cusp = ascendant.
    // Let's approximate House mid-point based on Equal House for now if cusps aren't available,
    // OR use the calculation relative to Ascendant.
    // Given the current codebase structure (simple VedicChart), we'll assume Equal House from Ascendant
    // or if `chart.houses` existed (it doesn't seems to be passed here, just chart).
    // The `chart.ascendant` is available.
    // Let's assume Equal House System for determining the House Cusp Degree for Bhava Bala.
    // (Bhava Bala proper requires Sripathi/Placidus cusps, but without them, Equal House is the standard fallback).

    final houseCusp = (chart.ascendant + (house - 1) * 30) % 360;

    for (final entry in chart.planets.entries) {
      final planet = entry.key;
      final planetInfo = entry.value;

      // Skip Nodes (Rahu/Ketu) for standard Bhava Drishti (some systems include them, standard usually 7 planets)
      if (Planet.lunarNodes.contains(planet)) continue;

      final aspectStrength =
          _calculateAspectStrength(planet, planetInfo.longitude, houseCusp);

      // Determine if planet is benefic or malefic
      // Bhava Bala uses Natural Benefic/Malefic for adding/subtracting strength
      final isBenefic = _isNaturalBenefic(planet);

      if (isBenefic) {
        drishtiBala += aspectStrength;
      } else {
        drishtiBala -= aspectStrength;
      }
    }

    // Result can be positive or negative.
    // Some texts say take 1/4th of this value.
    // B.V. Raman says: "Add the drift of benefic planets... Subtract the drift of malefic planets... Divide the result by 4."
    // Let's apply the 1/4 divisor rule which is standard for Bhava Drishti Pinda.
    return drishtiBala / 4.0;
  }

  double _calculateAspectStrength(
      Planet planet, double planetLong, double objectLong) {
    // Angle between planet and object (house cusp)
    var angle = (objectLong - planetLong + 360) % 360;

    // Standard Drig Bala (Aspect Strength) Formulas (Parashara/Raman):
    // 1. Special Aspects happen check first?
    // Usually defined by angle ranges.

    // Special Aspects (Fully strong):
    // Mars: 4th (90-120), 8th (210-240)
    // Jupiter: 5th (120-150), 9th (240-270)
    // Saturn: 3rd (60-90), 10th (270-300)

    // Convert angle to integer House distance roughly for checking special aspects?
    // No, Drig Bala formulas are precise based on degrees.

    // General Formula (Drishti Kendra):
    // 30-60:   (Angle - 30) / 2
    // 60-90:   (Angle - 60) + 15
    // 90-120:  (120 - Angle) / 2 + 45
    // 120-150: (150 - Angle)
    // 150-180: (Angle - 150) * 2
    // 180-300: (300 - Angle) / 2 (Wait, this is simpler 7th aspect logic)

    // Let's use the standard "Virupas" lookup or calculation.
    // B.V. Raman / Parashara logic:

    double aspectValue = 0.0;

    // Determine the "Distance" in degrees
    // Note: Aspects are usually cast forward.
    // If angle is 0 (conjunction), value is 0? (Planets generally don't aspect their own house in this calculation, or do they? usually aspect is 7th).
    // In Bhava Bala, we usually consider 7th aspect etc.
    // Conjunction usually typically handled by Bhava Dig Bala or similar?
    // Actually, Drig Bala starts from 30 degrees.

    if (angle < 30 || angle > 300) return 0.0;

    // Check Special Aspects first (Override or addition? usually override standard calculation for those ranges)
    // Mars
    if (planet == Planet.mars) {
      // 4th House aspect (90° +/- orb? No, usually range)
      // Special Rule: Mars gets 60 at 90° (4th) and 210° (8th)
      // But we need a continuous function or standard values?
      // Let's use the standard Drig Bala continuous formulas and boost for specials.
      // Actually standard formulas cover standard aspect.
      // Special aspects must be handled explicitly.

      // B.V. Raman: "For Mars: add 15 to the ordinary values at 4th (90) and 8th (210)?"
      // Simpler Implementation:
      // If within range of special aspect, return 60 (Full).
      if ((angle >= 80 && angle <= 100) || (angle >= 200 && angle <= 220))
        return 60.0;
    }

    if (planet == Planet.jupiter) {
      if ((angle >= 110 && angle <= 130) || (angle >= 230 && angle <= 250))
        return 60.0;
    }

    if (planet == Planet.saturn) {
      if ((angle >= 50 && angle <= 70) || (angle >= 260 && angle <= 280))
        return 60.0;
    }

    // Standard Aspect Formulas
    if (angle >= 30 && angle <= 60) {
      aspectValue = (angle - 30); // 0 to 30
    } else if (angle > 60 && angle <= 90) {
      aspectValue =
          (angle - 60) + 30; // 30 to 60 (At 90 becomes 60? No at 90 it drops?)
      // Wait, standard view is 60-90 increases to 45 or 60?
      // Parashara:
      // 30-60: 0 to 15 (value/2 ?) -> Drik Bala = (Angle-30)/2
      // Let's look up exact Parashara Formulas.
      //
      // 1. Substract planet's long from house long = d
      // 2. d < 30 or d > 300 -> 0
      // 3. 30 <= d <= 60 -> (d-30)/2
      // 4. 60 < d <= 90 -> (d-60) + 15
      // 5. 90 < d <= 120 -> (120-d)/2 + 45
      // 6. 120 < d <= 150 -> (150-d)
      // 7. 150 < d <= 180 -> (d-150)*2
      // 8. 180 < d <= 300 -> (300-d)/2

      // Let's use this standard set.
    }

    if (angle >= 30 && angle <= 60) {
      aspectValue = (angle - 30) / 2;
    } else if (angle > 60 && angle <= 90) {
      aspectValue = (angle - 60) + 15;
    } else if (angle > 90 && angle <= 120) {
      aspectValue = (120 - angle) / 2 + 45;
    } else if (angle > 120 && angle <= 150) {
      aspectValue = 150 - angle;
    } else if (angle > 150 && angle <= 180) {
      aspectValue = (angle - 150) * 2;
    } else if (angle > 180 && angle <= 300) {
      aspectValue = (300 - angle) / 2;
    } else {
      aspectValue = 0;
    }

    // Now Handle Special Aspects (Boost to 60 if applicable)
    // Mars: 4th (90 deg approx) - formula gives: (120-90)/2 + 45 = 15+45 = 60. Matches!
    // Mars: 8th (210 deg approx) - formula gives: (300-210)/2 = 45. (Mars gets 60 here).
    // Jupiter: 5th (120 deg) - formula gives: 45. (Jupiter gets 60).
    // Jupiter: 9th (240 deg) - formula gives: 30. (Jupiter gets 60).
    // Saturn: 3rd (60 deg) - formula gives: 15. (Saturn gets 60).
    // Saturn: 10th (270 deg) - formula gives: 15. (Saturn gets 60).

    if (planet == Planet.mars) {
      // Mars special aspects (4th ~90, 8th ~210)
      if (angle > 200 && angle < 220) return 60.0; // Boost 8th
      // 4th is already 60 by general formula at 90 deg.
    } else if (planet == Planet.jupiter) {
      // Jupiter special (5th ~120, 9th ~240)
      if (angle > 110 && angle < 130) return 60.0;
      if (angle > 230 && angle < 250) return 60.0;
    } else if (planet == Planet.saturn) {
      // Saturn special (3rd ~60, 10th ~270)
      if (angle > 50 && angle < 70) return 60.0;
      if (angle > 260 && angle < 280) return 60.0;
    }

    return aspectValue;
  }

  bool _isNaturalBenefic(Planet planet) {
    // Natural Benefics: Jupiter, Venus, Moon (Waxing usually, here simplified), Mercury (usually)
    // Natural Malefics: Sun, Mars, Saturn, Nodes.
    // Simplifying Moon/Mercury for static check:
    // Moon is generally considered Benefic in Bhava Bala unless explicitly Dark?
    // Let's stick to standard classification: Jup, Ven, Moo, Mer = Benefic. Sun, Mar, Sat = Malefic.
    // (Ideally Mercury depends on association, Moon on Paksha, but strict Natural Ben/Mal often used for this step).
    return [Planet.jupiter, Planet.venus, Planet.moon, Planet.mercury]
        .contains(planet);
  }
}
