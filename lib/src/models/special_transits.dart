/// Represents special transit features in Vedic astrology.
///
/// Includes Sade Sati (Saturn's 7.5 year transit),
/// Dhaiya (2.5 year Panoti), and Panchak (inauspicious periods).
class SpecialTransits {
  const SpecialTransits({
    required this.sadeSati,
    required this.dhaiya,
    this.panchak,
    required this.activeTransits,
  });

  /// Sade Sati status
  final SadeSatiStatus sadeSati;

  /// Dhaiya (Panoti) status
  final DhaiyaStatus dhaiya;

  /// Panchak status
  final PanchakStatus? panchak;

  /// List of all active special transits
  final List<SpecialTransitInfo> activeTransits;

  /// Checks if any challenging transit is active
  bool get hasChallengingTransit {
    return sadeSati.isActive || dhaiya.isActive || (panchak?.isActive ?? false);
  }

  /// Gets a summary of all active transits
  String get summary {
    final parts = <String>[];
    if (sadeSati.isActive) parts.add(sadeSati.description);
    if (dhaiya.isActive) parts.add(dhaiya.description);
    if (panchak?.isActive ?? false) parts.add('Panchak active');

    return parts.isEmpty ? 'No challenging transits' : parts.join('; ');
  }
}

/// Sade Sati (7.5 year Saturn transit) status.
///
/// Sade Sati occurs when Saturn transits:
/// 1. 12th house from Moon (Rising) - 2.5 years
/// 2. 1st house from Moon (Peak) - 2.5 years
/// 3. 2nd house from Moon (Setting) - 2.5 years
class SadeSatiStatus {
  const SadeSatiStatus({
    required this.isActive,
    this.phase,
    this.phaseProgress,
    required this.natalMoonLongitude,
    required this.transitSaturnLongitude,
    this.startDate,
    this.endDate,
  });

  /// Whether Sade Sati is currently active
  final bool isActive;

  /// Current phase of Sade Sati
  final SadeSatiPhase? phase;

  /// Progress through current phase (0.0 - 1.0)
  final double? phaseProgress;

  /// Natal Moon position
  final double natalMoonLongitude;

  /// Transit Saturn position
  final double transitSaturnLongitude;

  /// Start date of current Sade Sati period
  final DateTime? startDate;

  /// End date of current Sade Sati period
  final DateTime? endDate;

  /// Gets a description of the current status
  String get description {
    if (!isActive) return 'Sade Sati not active';

    final phaseName = phase?.name ?? 'Unknown';
    final intensity = phase == SadeSatiPhase.peak
        ? 'Peak intensity'
        : phase == SadeSatiPhase.rising
            ? 'Beginning'
            : 'Ending';

    return 'Sade Sati - $phaseName phase ($intensity)';
  }

  /// Gets the house relative to natal Moon that Saturn is transiting
  int? get transitedHouse {
    if (!isActive) return null;

    final moonSign = (natalMoonLongitude / 30).floor();
    final saturnSign = (transitSaturnLongitude / 30).floor();

    // Calculate house from Moon
    var house = (saturnSign - moonSign + 12) % 12;
    if (house == 0) house = 12;

    return house;
  }
}

/// Sade Sati phases
enum SadeSatiPhase {
  rising('Rising', 'First 2.5 years (12th from Moon)'),
  peak('Peak', 'Middle 2.5 years (1st from Moon)'),
  setting('Setting', 'Last 2.5 years (2nd from Moon)');

  const SadeSatiPhase(this.name, this.description);

  final String name;
  final String description;
}

/// Dhaiya (2.5 year Saturn transit/Panoti) status.
///
/// Dhaiya (also called Small Panoti or Kantaka Shani) occurs when
/// Saturn transits the 4th or 8th house from the natal Moon.
class DhaiyaStatus {
  const DhaiyaStatus({
    required this.isActive,
    this.type,
    required this.natalMoonLongitude,
    required this.transitSaturnLongitude,
    this.startDate,
    this.endDate,
  });

  /// Whether Dhaiya is currently active
  final bool isActive;

  /// Type of Dhaiya
  final DhaiyaType? type;

  /// Natal Moon position
  final double natalMoonLongitude;

  /// Transit Saturn position
  final double transitSaturnLongitude;

  /// Start date of current Dhaiya
  final DateTime? startDate;

  /// End date of current Dhaiya
  final DateTime? endDate;

  /// Gets a description of the current status
  String get description {
    if (!isActive) return 'Dhaiya not active';

    final typeName = type?.name ?? 'Unknown';
    return 'Dhaiya (Panoti) - $typeName';
  }

  /// Gets the house relative to natal Moon that Saturn is transiting
  int? get transitedHouse {
    if (!isActive) return null;

    final moonSign = (natalMoonLongitude / 30).floor();
    final saturnSign = (transitSaturnLongitude / 30).floor();

    var house = (saturnSign - moonSign + 12) % 12;
    if (house == 0) house = 12;

    return house;
  }
}

/// Dhaiya types
enum DhaiyaType {
  fourth('4th House Dhaiya', 'Dhaiya when Saturn transits 4th from Moon'),
  eighth('8th House Dhaiya', 'Ashtama Shani - Most challenging Dhaiya');

  const DhaiyaType(this.name, this.description);

  final String name;
  final String description;
}

/// Panchak status.
///
/// Panchak is a period of approximately 5 days when the Moon
/// transits through the last 5 nakshatras (Dhanishta to Revati).
/// Considered inauspicious for certain activities.
class PanchakStatus {
  const PanchakStatus({
    required this.isActive,
    required this.currentNakshatra,
    this.startDate,
    this.endDate,
    this.daysRemaining,
  });

  /// Whether Panchak is currently active
  final bool isActive;

  /// Current nakshatra number (should be 22-27 during Panchak)
  final int currentNakshatra;

  /// Start date of current Panchak period
  final DateTime? startDate;

  /// End date of current Panchak period
  final DateTime? endDate;

  /// Days remaining in Panchak
  final int? daysRemaining;

  /// Gets a description of the current status
  String get description {
    if (!isActive) return 'Panchak not active';

    return 'Panchak active - Moon in ${_nakshatras[currentNakshatra - 1]}'
        '${daysRemaining != null ? ' ($daysRemaining days remaining)' : ''}';
  }

  /// Gets recommended precautions during Panchak
  List<String> get precautions {
    if (!isActive) return [];

    return [
      'Avoid starting new ventures',
      'Avoid traveling in certain directions (South)',
      'Avoid constructing roof of house',
      'Avoid buying land',
      'Be cautious with fire and sharp objects',
    ];
  }

  static const List<String> _nakshatras = [
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
    'Revati'
  ];
}

/// Information about a specific special transit.
class SpecialTransitInfo {
  const SpecialTransitInfo({
    required this.type,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.intensity,
    required this.remedies,
  });

  /// Type of transit
  final SpecialTransitType type;

  /// Description
  final String description;

  /// Start date
  final DateTime startDate;

  /// End date
  final DateTime endDate;

  /// Intensity level (1-10)
  final int intensity;

  /// Remedial measures
  final List<String> remedies;

  /// Checks if transit is active on a specific date
  bool isActiveOn(DateTime date) {
    return date.isAfter(startDate) && date.isBefore(endDate);
  }
}

/// Types of special transits
enum SpecialTransitType {
  sadeSati,
  dhaiya,
  panchak,
  kantakaShani,
  ashtamaShani,
}

/// Saturn transit constants.
class SaturnTransitConstants {
  /// Saturn stays in one sign for approximately 2.5 years
  static const double yearsPerSign = 2.5;

  /// Days per sign (approximate)
  static const int daysPerSign = 912; // 2.5 * 365

  /// Sade Sati houses from Moon (12th, 1st, 2nd)
  static const List<int> sadeSatiHouses = [12, 1, 2];

  /// Dhaiya houses from Moon (4th, 8th)
  static const List<int> dhaiyaHouses = [4, 8];

  /// Most challenging house (8th from Moon - Ashtama Shani)
  static const int ashtamaShaniHouse = 8;

  /// Panchak traditionally starts from 300° (middle of Dhanishta nakshatra)
  /// and ends at 360° (end of Revati). Dhanishta spans 293°20' to 306°40',
  /// so the 2nd half of Dhanishta is 300° to 306°40'.
  static const double panchakStartLongitude = 300.0; // Middle of Dhanishta
  static const double panchakEndLongitude = 360.0; // End of Revati
  static const List<int> panchakNakshatras = [22, 23, 24, 25, 26, 27];
}
