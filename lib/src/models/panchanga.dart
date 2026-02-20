import '../models/planet.dart';
import '../models/nakshatra.dart';

/// Represents the five limbs (Panchanga) of a day in Vedic astrology.
/// Panchanga consists of Tithi, Nakshatra, Yoga, Karana, and Vara (weekday).
class Panchanga {
  const Panchanga({
    required this.dateTime,
    required this.location,
    required this.tithi,
    required this.nakshatra,
    required this.yoga,
    required this.karana,
    required this.vara,
    required this.sunrise,
    required this.sunset,
  });

  /// Date and time for which the Panchanga was calculated
  final DateTime dateTime;

  /// Location information
  final String location;

  /// Tithi (lunar phase)
  final TithiInfo tithi;

  /// Nakshatra (Moon's lunar mansion)
  final NakshatraInfo nakshatra;

  /// Yoga (27 lunar-solar combinations)
  final YogaInfo yoga;

  /// Karana (half-tithi, 60 total)
  final KaranaInfo karana;

  /// Vara (weekday/planetary day lord)
  final VaraInfo vara;

  /// Sunrise time
  final DateTime sunrise;

  /// Sunset time
  final DateTime sunset;

  /// Gets whether it's daytime
  bool get isDaytime {
    final now = dateTime;
    return now.isAfter(sunrise) && now.isBefore(sunset);
  }

  /// Gets the day length in hours
  double get dayLengthHours {
    return sunset.difference(sunrise).inMinutes / 60.0;
  }

  /// Formatted string representation
  @override
  String toString() {
    return 'Panchanga(${dateTime.toIso8601String()}): '
        '${tithi.name} (${tithi.paksha}), '
        '${nakshatra.name} (Pada ${nakshatra.pada}), '
        '${yoga.name}, ${karana.name}, ${vara.name}';
  }
}

/// Tithi information
class TithiInfo {
  const TithiInfo({
    required this.number,
    required this.name,
    required this.paksha,
    required this.elapsed,
  });

  /// Tithi number (1-30)
  final int number;

  /// Tithi name
  final String name;

  /// Paksha (lunar fortnight)
  final Paksha paksha;

  /// Elapsed portion of the tithi (0.0 - 1.0)
  final double elapsed;

  /// Remaining portion of the tithi (0.0 - 1.0)
  double get remaining => 1.0 - elapsed;

  /// Whether the tithi is complete (> 0.9)
  bool get isComplete => elapsed > 0.9;

  static const List<String> tithiNames = [
    'Pratipada',
    'Dwitiya',
    'Tritiya',
    'Chaturthi',
    'Panchami',
    'Shashthi',
    'Saptami',
    'Ashtami',
    'Navami',
    'Dashami',
    'Ekadashi',
    'Dwadashi',
    'Trayodashi',
    'Chaturdashi',
    'Purnima/Amavasya',
  ];
}

/// Lunar fortnight (Paksha)
enum Paksha {
  shukla('Shukla Paksha', 'Waxing Moon'),
  krishna('Krishna Paksha', 'Waning Moon');

  const Paksha(this.sanskrit, this.description);

  final String sanskrit;
  final String description;

  /// Gets paksha from tithi number (1-15 = Shukla, 16-30 = Krishna)
  static Paksha fromTithiNumber(int tithiNumber) {
    return tithiNumber <= 15 ? Paksha.shukla : Paksha.krishna;
  }
}

/// Yoga information
class YogaInfo {
  const YogaInfo({
    required this.number,
    required this.name,
    required this.elapsed,
  });

  /// Yoga number (1-27)
  final int number;

  /// Yoga name
  final String name;

  /// Elapsed portion of the yoga (0.0 - 1.0)
  final double elapsed;

  /// Remaining portion of the yoga (0.0 - 1.0)
  double get remaining => 1.0 - elapsed;

  static const List<String> yogaNames = [
    'Vishkumbha',
    'Priti',
    'Ayushman',
    'Saubhagya',
    'Shobhana',
    'Atiganda',
    'Sukarma',
    'Dhriti',
    'Shula',
    'Ganda',
    'Vriddhi',
    'Dhruva',
    'Vyaghata',
    'Harshana',
    'Vajra',
    'Siddhi',
    'Vyatipata',
    'Variyana',
    'Parigha',
    'Shiva',
    'Siddha',
    'Sadhyaya',
    'Shubha',
    'Shukla',
    'Brahma',
    'Indra',
    'Vaidhriti',
  ];

  /// Gets the yoga nature (benefic or malefic)
  YogaNature get nature {
    final maleficYogas = [
      6,
      9,
      10,
      13,
      17,
      27
    ]; // Atiganda, Shula, Ganda, Vyaghata, Vyatipata, Vaidhriti
    return maleficYogas.contains(number)
        ? YogaNature.malefic
        : YogaNature.benefic;
  }
}

/// Yoga nature
enum YogaNature {
  benefic('Benefic', true),
  malefic('Malefic', false);

  const YogaNature(this.name, this.isAuspicious);

  final String name;
  final bool isAuspicious;
}

/// Detailed information about the 27 Nitya Yogas.
class YogaDetails {
  const YogaDetails({
    required this.number,
    required this.name,
    required this.nature,
    required this.rulingPlanet,
    required this.description,
    required this.effects,
    required this.recommendations,
  });

  /// Yoga number (1-27)
  final int number;

  /// Yoga name
  final String name;

  /// Nature (benefic/malefic)
  final YogaNature nature;

  /// Ruling planet
  final Planet rulingPlanet;

  /// Detailed description
  final String description;

  /// Effects/interpretation
  final String effects;

  /// Activity recommendations
  final List<String> recommendations;

  /// Get details for a specific yoga number
  static YogaDetails getDetails(int yogaNumber) {
    if (yogaNumber < 1 || yogaNumber > 27) {
      throw ArgumentError('Yoga number must be between 1 and 27');
    }
    return _yogaDetails[yogaNumber - 1];
  }

  /// Check if the yoga is favorable for specific activities
  bool isFavorableFor(String activity) {
    return recommendations.contains(activity);
  }

  static const List<YogaDetails> _yogaDetails = [
    // 1. Vishkumbha
    YogaDetails(
      number: 1,
      name: 'Vishkumbha',
      nature: YogaNature.malefic,
      rulingPlanet: Planet.sun,
      description: 'Supported or Pillar Yoga - Indication of support and foundation',
      effects: 'Good for laying foundations, starting enterprises. Avoid confrontations.',
      recommendations: ['Construction', 'Business start', 'Planting', 'Marriage'],
    ),
    // 2. Priti
    YogaDetails(
      number: 2,
      name: 'Priti',
      nature: YogaNature.benefic,
      rulingPlanet: Planet.moon,
      description: 'Love or Affection Yoga - Indicates harmony and love',
      effects: 'Excellent for relationships, artistic pursuits, and social activities.',
      recommendations: ['Marriage', 'Social events', 'Art', 'Reconciliation'],
    ),
    // 3. Ayushman
    YogaDetails(
      number: 3,
      name: 'Ayushman',
      nature: YogaNature.benefic,
      rulingPlanet: Planet.mars,
      description: 'Longevity or Life-span Yoga - Promotes health and long life',
      effects: 'Good for health matters, physical activities, and longevity.',
      recommendations: ['Health treatments', 'Exercise', 'Construction', 'Investment'],
    ),
    // 4. Saubhagya
    YogaDetails(
      number: 4,
      name: 'Saubhagya',
      nature: YogaNature.benefic,
      rulingPlanet: Planet.mercury,
      description: 'Good Fortune Yoga - Indicates luck and prosperity',
      effects: 'Excellent for starting new ventures, signing contracts, and education.',
      recommendations: ['New beginnings', 'Education', 'Commerce', 'Travel'],
    ),
    // 5. Shobhana
    YogaDetails(
      number: 5,
      name: 'Shobhana',
      nature: YogaNature.benefic,
      rulingPlanet: Planet.jupiter,
      description: 'Splendor or Brilliance Yoga - Promotes beauty and success',
      effects: 'Very auspicious for all activities, especially ceremonies and celebrations.',
      recommendations: ['Marriage', 'Ceremonies', 'Business', 'Education', 'Travel'],
    ),
    // 6. Atiganda
    YogaDetails(
      number: 6,
      name: 'Atiganda',
      nature: YogaNature.malefic,
      rulingPlanet: Planet.saturn,
      description: 'Great Danger Yoga - Caution required',
      effects: 'Avoid risky activities, conflicts, and important decisions.',
      recommendations: ['Rest', 'Spiritual practice', 'Avoid: new ventures', 'Avoid: conflicts'],
    ),
    // 7. Sukarma
    YogaDetails(
      number: 7,
      name: 'Sukarma',
      nature: YogaNature.benefic,
      rulingPlanet: Planet.mercury,
      description: 'Good Work Yoga - Excellent for positive actions',
      effects: 'Very favorable for all good works, charity, and virtuous activities.',
      recommendations: ['Charity', 'Religious acts', 'Good deeds', 'Learning'],
    ),
    // 8. Dhriti
    YogaDetails(
      number: 8,
      name: 'Dhriti',
      nature: YogaNature.benefic,
      rulingPlanet: Planet.jupiter,
      description: 'Determination or Firmness Yoga - Promotes stability',
      effects: 'Good for perseverance, completing tasks, and long-term projects.',
      recommendations: ['Long-term projects', 'Research', 'Study', 'Building'],
    ),
    // 9. Shula
    YogaDetails(
      number: 9,
      name: 'Shula',
      nature: YogaNature.malefic,
      rulingPlanet: Planet.mars,
      description: 'Spear or Pain Yoga - Indicates difficulties',
      effects: 'Challenging period. Avoid confrontations and risky activities.',
      recommendations: ['Caution', 'Spiritual practice', 'Avoid: conflicts', 'Avoid: travel'],
    ),
    // 10. Ganda
    YogaDetails(
      number: 10,
      name: 'Ganda',
      nature: YogaNature.malefic,
      rulingPlanet: Planet.saturn,
      description: 'Knot or Obstacle Yoga - Indicates obstacles',
      effects: 'Difficult period. Patience required. Avoid major decisions.',
      recommendations: ['Patience', 'Meditation', 'Avoid: new ventures', 'Avoid: disputes'],
    ),
    // 11. Vriddhi
    YogaDetails(
      number: 11,
      name: 'Vriddhi',
      nature: YogaNature.benefic,
      rulingPlanet: Planet.mercury,
      description: 'Growth or Increase Yoga - Promotes expansion',
      effects: 'Excellent for growth, learning, and accumulation of wealth.',
      recommendations: ['Investment', 'Education', 'Business expansion', 'Learning'],
    ),
    // 12. Dhruva
    YogaDetails(
      number: 12,
      name: 'Dhruva',
      nature: YogaNature.benefic,
      rulingPlanet: Planet.jupiter,
      description: 'Fixed or Constant Yoga - Promotes stability',
      effects: 'Very favorable for permanent arrangements and long-term commitments.',
      recommendations: ['Marriage', 'Property purchase', 'Permanent settlement', 'Oaths'],
    ),
    // 13. Vyaghata
    YogaDetails(
      number: 13,
      name: 'Vyaghata',
      nature: YogaNature.malefic,
      rulingPlanet: Planet.mars,
      description: 'Obstacle or Hindrance Yoga - Indicates setbacks',
      effects: 'Challenging period with potential obstacles. Proceed with caution.',
      recommendations: ['Caution', 'Patience', 'Avoid: new ventures', 'Avoid: risks'],
    ),
    // 14. Harshana
    YogaDetails(
      number: 14,
      name: 'Harshana',
      nature: YogaNature.benefic,
      rulingPlanet: Planet.moon,
      description: 'Joy or Delight Yoga - Promotes happiness',
      effects: 'Very auspicious for celebrations, social gatherings, and enjoyment.',
      recommendations: ['Celebrations', 'Social events', 'Marriage', 'Entertainment'],
    ),
    // 15. Vajra
    YogaDetails(
      number: 15,
      name: 'Vajra',
      nature: YogaNature.benefic,
      rulingPlanet: Planet.jupiter,
      description: 'Thunderbolt or Diamond Yoga - Indicates strength',
      effects: 'Good for overcoming obstacles and achieving success through effort.',
      recommendations: ['Overcoming obstacles', 'Legal matters', 'Disputes', 'Competition'],
    ),
    // 16. Siddhi
    YogaDetails(
      number: 16,
      name: 'Siddhi',
      nature: YogaNature.benefic,
      rulingPlanet: Planet.mercury,
      description: 'Success or Accomplishment Yoga - Promotes achievement',
      effects: 'Excellent for completing tasks and achieving goals.',
      recommendations: ['Completing projects', 'Exams', 'Competitions', 'Business'],
    ),
    // 17. Vyatipata
    YogaDetails(
      number: 17,
      name: 'Vyatipata',
      nature: YogaNature.malefic,
      rulingPlanet: Planet.sun,
      description: 'Calamity or Disaster Yoga - Caution required',
      effects: 'Very challenging period. Avoid all important activities.',
      recommendations: ['Spiritual practice', 'Rest', 'Avoid: all major activities', 'Caution'],
    ),
    // 18. Variyana
    YogaDetails(
      number: 18,
      name: 'Variyana',
      nature: YogaNature.benefic,
      rulingPlanet: Planet.venus,
      description: 'Comfort or Luxury Yoga - Promotes enjoyment',
      effects: 'Good for comfort, luxury, and enjoying life\'s pleasures.',
      recommendations: ['Comfortable activities', 'Art', 'Entertainment', 'Social gatherings'],
    ),
    // 19. Parigha
    YogaDetails(
      number: 19,
      name: 'Parigha',
      nature: YogaNature.malefic,
      rulingPlanet: Planet.saturn,
      description: 'Obstacle or Barrier Yoga - Indicates blockages',
      effects: 'Difficult period with obstacles. Patience and perseverance needed.',
      recommendations: ['Patience', 'Persistence', 'Avoid: new ventures', 'Planning'],
    ),
    // 20. Shiva
    YogaDetails(
      number: 20,
      name: 'Shiva',
      nature: YogaNature.benefic,
      rulingPlanet: Planet.jupiter,
      description: 'Auspicious Yoga - Highly favorable',
      effects: 'One of the best yogas. Excellent for all auspicious activities.',
      recommendations: ['All auspicious activities', 'Marriage', 'Ceremonies', 'Spiritual practice'],
    ),
    // 21. Siddha
    YogaDetails(
      number: 21,
      name: 'Siddha',
      nature: YogaNature.benefic,
      rulingPlanet: Planet.mercury,
      description: 'Perfection or Completion Yoga - Promotes success',
      effects: 'Very favorable for achieving perfection and completing tasks.',
      recommendations: ['Perfection in work', 'Mastery', 'Learning', 'Teaching'],
    ),
    // 22. Sadhya
    YogaDetails(
      number: 22,
      name: 'Sadhya',
      nature: YogaNature.benefic,
      rulingPlanet: Planet.mars,
      description: 'Attainable or Possible Yoga - Success achievable',
      effects: 'Good for pursuing goals and achieving what is desired.',
      recommendations: ['Goal setting', 'Pursuing ambitions', 'Competition', 'Effort'],
    ),
    // 23. Shubha
    YogaDetails(
      number: 23,
      name: 'Shubha',
      nature: YogaNature.benefic,
      rulingPlanet: Planet.venus,
      description: 'Auspicious Yoga - Highly favorable',
      effects: 'Very auspicious for beauty, arts, and pleasant activities.',
      recommendations: ['Beauty treatments', 'Art', 'Marriage', 'Social events'],
    ),
    // 24. Shukla
    YogaDetails(
      number: 24,
      name: 'Shukla',
      nature: YogaNature.benefic,
      rulingPlanet: Planet.moon,
      description: 'Bright or Pure Yoga - Promotes clarity',
      effects: 'Excellent for clarity, purity, and spiritual activities.',
      recommendations: ['Spiritual practice', 'Purification', 'Study', 'Teaching'],
    ),
    // 25. Brahma
    YogaDetails(
      number: 25,
      name: 'Brahma',
      nature: YogaNature.benefic,
      rulingPlanet: Planet.jupiter,
      description: 'Creator or Knowledge Yoga - Highly spiritual',
      effects: 'Excellent for spiritual growth, knowledge, and creative activities.',
      recommendations: ['Spiritual practice', 'Study', 'Teaching', 'Creative work'],
    ),
    // 26. Indra
    YogaDetails(
      number: 26,
      name: 'Indra',
      nature: YogaNature.benefic,
      rulingPlanet: Planet.sun,
      description: 'King or Leader Yoga - Promotes authority',
      effects: 'Good for leadership, authority, and gaining recognition.',
      recommendations: ['Leadership', 'Authority matters', 'Public activities', 'Government'],
    ),
    // 27. Vaidhriti
    YogaDetails(
      number: 27,
      name: 'Vaidhriti',
      nature: YogaNature.malefic,
      rulingPlanet: Planet.saturn,
      description: 'Supporting or Holding Yoga - Requires caution',
      effects: 'Challenging period. Best for rest and spiritual practice.',
      recommendations: ['Rest', 'Spiritual practice', 'Avoid: new ventures', 'Patience'],
    ),
  ];
}

/// Karana information
class KaranaInfo {
  const KaranaInfo({
    required this.number,
    required this.name,
    required this.isFixed,
    required this.elapsed,
  });

  /// Karana number (1-60, repeating pattern)
  final int number;

  /// Karana name
  final String name;

  /// Whether it's a fixed karana (first 7) or variable
  final bool isFixed;

  /// Elapsed portion of the karana (0.0 - 1.0)
  final double elapsed;

  static const List<String> fixedKaranaNames = [
    'Bava',
    'Balava',
    'Kaulava',
    'Taitila',
    'Garaja',
    'Vanija',
    'Vishti',
  ];

  static const List<String> variableKaranaNames = [
    'Shakuni',
    'Chatushpada',
    'Naga',
    'Kimstughna',
  ];

  /// Gets the karana nature
  KaranaNature get nature {
    if (name == 'Vishti') return KaranaNature.malefic;
    if (isFixed) return KaranaNature.benefic;
    return KaranaNature.mixed;
  }
}

/// Karana nature
enum KaranaNature {
  benefic('Benefic', true),
  malefic('Malefic', false),
  mixed('Mixed', null);

  const KaranaNature(this.name, this.isAuspicious);

  final String name;
  final bool? isAuspicious;
}

/// Vara (weekday/planetary day) information
class VaraInfo {
  const VaraInfo({
    required this.weekday,
    required this.name,
    required this.rulingPlanet,
  });

  /// Weekday number (0 = Sunday, 1 = Monday, etc.)
  final int weekday;

  /// Weekday name
  final String name;

  /// Ruling planet of the day
  final Planet rulingPlanet;

  static const List<String> weekdayNames = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  /// Gets the planet ruling the weekday
  static Planet getRulingPlanet(int weekday) {
    switch (weekday) {
      case 0:
        return Planet.sun;
      case 1:
        return Planet.moon;
      case 2:
        return Planet.mars;
      case 3:
        return Planet.mercury;
      case 4:
        return Planet.jupiter;
      case 5:
        return Planet.venus;
      case 6:
        return Planet.saturn;
      default:
        throw ArgumentError('Invalid weekday: $weekday');
    }
  }

  /// Gets the Hora lord for a specific hour of the day.
  ///
  /// The Hora cycle follows the sequence: Sun, Venus, Mercury, Moon, Saturn,
  /// Jupiter, Mars. The first Hora of the day (at sunrise) is ruled by the
  /// lord of the weekday.
  ///
  /// [hourOfDay] - The zero-based hour index since sunrise (0-23).
  Planet getHoraLord(int hourOfDay) {
    // Hora cycle: Sun, Venus, Mercury, Moon, Saturn, Jupiter, Mars (repeat)
    final horaOrder = [
      Planet.sun,
      Planet.venus,
      Planet.mercury,
      Planet.moon,
      Planet.saturn,
      Planet.jupiter,
      Planet.mars,
    ];

    // Find the starting index based on the weekday
    int startIndex;
    switch (weekday) {
      case 0: // Sunday
        startIndex = 0; // Sun
        break;
      case 1: // Monday
        startIndex = 3; // Moon
        break;
      case 2: // Tuesday
        startIndex = 6; // Mars
        break;
      case 3: // Wednesday
        startIndex = 2; // Mercury
        break;
      case 4: // Thursday
        startIndex = 5; // Jupiter
        break;
      case 5: // Friday
        startIndex = 1; // Venus
        break;
      case 6: // Saturday
        startIndex = 4; // Saturn
        break;
      default:
        startIndex = 0;
    }

    return horaOrder[(startIndex + hourOfDay) % 7];
  }
}
