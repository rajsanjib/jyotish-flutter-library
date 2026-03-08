import 'package:jyotish/src/models/planet.dart';
import 'package:jyotish/src/models/vedic_chart.dart';
import 'package:jyotish/src/analysis/career_analysis.dart';
import 'package:jyotish/src/models/rashi.dart';

class CareerAnalysisService {
  D10CareerAnalysis analyzeCareer(VedicChart d10Chart) {
    // Determine 10th sign (Ascendant sign index + 9)
    final ascendantRashi = Rashi.fromLongitude(d10Chart.ascendant);
    final tenthSignIndex = (ascendantRashi.number + 9) % 12;
    final tenthSign = Rashi.values[tenthSignIndex];
    final tenthLord = _getSignLord(tenthSign);

    final primaryDomains = <String>[];
    final strongPlanets = <Planet>[];
    final careerThemes = <String>[];

    // Evaluate 10th lord
    primaryDomains.addAll(_getPlanetDomains(tenthLord));
    careerThemes.add(
        'Career path is heavily influenced by ${tenthLord.displayName} (10th Lord).');

    // Evaluate D-10 Strong Planets
    int strengthScore = 0;
    for (final entry in d10Chart.planets.entries) {
      final planet = entry.key;
      final info = entry.value;

      if (info.dignity == PlanetaryDignity.exalted ||
          info.dignity == PlanetaryDignity.ownSign ||
          info.dignity == PlanetaryDignity.moolaTrikona) {
        strongPlanets.add(planet);
        strengthScore += 2;

        if (planet != tenthLord) {
          primaryDomains.addAll(_getPlanetDomains(planet));
        }
      } else if (info.dignity == PlanetaryDignity.debilitated) {
        strengthScore -= 2;
      }
    }

    if (strongPlanets.isNotEmpty) {
      careerThemes.add(
          'Strong placements in D-10 provide support: ${strongPlanets.map((p) => p.displayName).join(", ")}.');
    }

    // Determine category
    D10StrengthCategory category;
    if (strengthScore >= 4) {
      category = D10StrengthCategory.excellent;
    } else if (strengthScore >= 1) {
      category = D10StrengthCategory.good;
    } else if (strengthScore >= -2) {
      category = D10StrengthCategory.average;
    } else {
      category = D10StrengthCategory.challenging;
    }

    return D10CareerAnalysis(
      d10Chart: d10Chart,
      tenthLord: tenthLord,
      tenthSign: tenthSign,
      primaryDomains: primaryDomains.toSet().toList(), // deduplicate
      strongPlanets: strongPlanets,
      careerThemes: careerThemes,
      overallStrength: category,
    );
  }

  Planet _getSignLord(Rashi sign) {
    return switch (sign) {
      Rashi.aries || Rashi.scorpio => Planet.mars,
      Rashi.taurus || Rashi.libra => Planet.venus,
      Rashi.gemini || Rashi.virgo => Planet.mercury,
      Rashi.cancer => Planet.moon,
      Rashi.leo => Planet.sun,
      Rashi.sagittarius || Rashi.pisces => Planet.jupiter,
      Rashi.capricorn || Rashi.aquarius => Planet.saturn,
    };
  }

  List<String> _getPlanetDomains(Planet planet) {
    return switch (planet) {
      Planet.sun => ['Government', 'Authority', 'Management', 'Politics'],
      Planet.moon => [
          'Public Relations',
          'Caregiving',
          'Food/Hospitality',
          'Liquid matters'
        ],
      Planet.mars => [
          'Engineering',
          'Military/Police',
          'Surgeon',
          'Real Estate'
        ],
      Planet.mercury => [
          'Business',
          'Writing/Media',
          'IT/Programming',
          'Accounting'
        ],
      Planet.jupiter => [
          'Education/Teaching',
          'Law',
          'Finance/Banking',
          'Advisory'
        ],
      Planet.venus => ['Arts/Entertainment', 'Fashion', 'Luxury', 'Design'],
      Planet.saturn => [
          'Service Sector',
          'Labor',
          'Research',
          'Heavy Industry',
          'Agriculture'
        ],
      Planet.meanNode => [
          'Technology',
          'Foreign Affairs',
          'Unconventional paths'
        ], // Rahu
      Planet.trueNode => [
          'Technology',
          'Foreign Affairs',
          'Unconventional paths'
        ],
      Planet.meanApogee => [
          'Research',
          'Spirituality',
          'Occult',
          'Backend systems'
        ], // Ketu
      Planet.osculatingApogee => [
          'Research',
          'Spirituality',
          'Occult',
          'Backend systems'
        ],
      _ => [],
    };
  }
}
