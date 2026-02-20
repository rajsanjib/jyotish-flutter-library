import '../models/planet.dart';

/// Represents special periods and Muhurta calculations.
///
/// Includes Hora (planetary hours), Choghadiya (daily periods),
/// and Rahukalam/Gulikalam/Yamagandam (inauspicious periods).
class Muhurta {
  const Muhurta({
    required this.date,
    required this.location,
    required this.horaPeriods,
    required this.choghadiya,
    required this.inauspiciousPeriods,
    required this.currentPeriods,
  });

  /// Date for which Muhurta is calculated
  final DateTime date;

  /// Location information
  final String location;

  /// Hora periods for the day
  final List<HoraPeriod> horaPeriods;

  /// Choghadiya periods
  final ChoghadiyaPeriods choghadiya;

  /// Inauspicious periods
  final InauspiciousPeriods inauspiciousPeriods;

  /// Current active periods
  final List<MuhurtaPeriod> currentPeriods;

  /// Gets favorable periods for a specific activity
  List<MuhurtaPeriod> getFavorablePeriods(String activity) {
    return currentPeriods.where((p) => p.isFavorableFor(activity)).toList();
  }

  /// Gets the current Hora lord
  Planet? get currentHoraLord {
    final now = DateTime.now();
    for (final hora in horaPeriods) {
      if (hora.contains(now)) {
        return hora.lord;
      }
    }
    return null;
  }

  /// Checks if current time is inauspicious
  bool get isCurrentlyInauspicious {
    final now = DateTime.now();
    return inauspiciousPeriods.isInauspicious(now);
  }
}

/// Hora (planetary hour) period.
///
/// Each day is divided into planetary hours ruled by different planets.
/// Daytime and nighttime have separate sequences.
class HoraPeriod implements MuhurtaPeriod {
  const HoraPeriod({
    required this.startTime,
    required this.endTime,
    required this.lord,
    required this.hourNumber,
    required this.isDaytime,
  });

  /// Start time of the period
  @override
  final DateTime startTime;

  /// End time of the period
  @override
  final DateTime endTime;

  /// Ruling planet of this hour
  final Planet lord;

  /// Hour number (0-11 for day, 0-11 for night)
  final int hourNumber;

  /// Whether it's a daytime hour
  final bool isDaytime;

  @override
  String get name => '${lord.displayName} Hora';

  @override
  bool get isAuspicious => _auspiciousPlanets.contains(lord);

  @override
  String get nature => isAuspicious ? 'Auspicious' : 'Neutral';

  /// Checks if a given time falls within this period
  bool contains(DateTime time) {
    return time.isAfter(startTime) && time.isBefore(endTime);
  }

  @override
  bool isFavorableFor(String activity) {
    final favorableActivities = _favorableActivities[lord];
    return favorableActivities?.contains(activity.toLowerCase()) ?? false;
  }

  static final List<Planet> _auspiciousPlanets = [
    Planet.sun,
    Planet.moon,
    Planet.jupiter,
    Planet.mercury,
    Planet.venus,
  ];

  static final Map<Planet, List<String>> _favorableActivities = {
    Planet.sun: ['health', 'authority', 'government', 'father'],
    Planet.moon: ['emotions', 'mother', 'fluids', 'travel'],
    Planet.mars: ['surgery', 'mechanical', 'sports', 'military'],
    Planet.mercury: ['business', 'education', 'writing', 'communication'],
    Planet.jupiter: [
      'worship',
      'marriage',
      'children',
      'education',
      'religion'
    ],
    Planet.venus: ['love', 'marriage', 'art', 'beauty', 'luxury'],
    Planet.saturn: ['labor', 'construction', 'iron', 'oil'],
  };
}

/// Choghadiya (auspicious/inauspicious daily periods).
///
/// Each day is divided into 16 Choghadiya periods (8 day + 8 night).
/// Each period has specific auspiciousness qualities.
class ChoghadiyaPeriods {
  const ChoghadiyaPeriods({
    required this.daytimePeriods,
    required this.nighttimePeriods,
  });

  /// Daytime Choghadiya periods
  final List<Choghadiya> daytimePeriods;

  /// Nighttime Choghadiya periods
  final List<Choghadiya> nighttimePeriods;

  /// Gets all periods as a single list
  List<Choghadiya> get allPeriods => [...daytimePeriods, ...nighttimePeriods];

  /// Gets favorable periods only
  List<Choghadiya> get favorablePeriods {
    return allPeriods.where((p) => p.isFavorable).toList();
  }

  /// Gets the Choghadiya for a specific time
  Choghadiya? getPeriodForTime(DateTime time) {
    for (final period in allPeriods) {
      if (period.contains(time)) {
        return period;
      }
    }
    return null;
  }
}

/// Individual Choghadiya period.
class Choghadiya implements MuhurtaPeriod {
  const Choghadiya({
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.isDaytime,
    required this.periodNumber,
    this.rulingPlanet,
  });
  @override
  final DateTime startTime;

  @override
  final DateTime endTime;

  /// Type of Choghadiya
  final ChoghadiyaType type;

  /// Ruling planet
  final Planet? rulingPlanet;

  /// Whether it's a daytime Choghadiya
  final bool isDaytime;

  /// Period number (1-8)
  final int periodNumber;

  @override
  String get name => type.name;

  @override
  bool get isAuspicious => type.isAuspicious;

  @override
  String get nature => type.nature;

  bool get isFavorable => type.isAuspicious;

  bool contains(DateTime time) {
    return time.isAfter(startTime) && time.isBefore(endTime);
  }

  @override
  bool isFavorableFor(String activity) {
    final favorable = type.favorableActivities;
    return favorable.any((a) => a.toLowerCase() == activity.toLowerCase());
  }
}

/// Choghadiya types.
enum ChoghadiyaType {
  amrit('Amrit', 'Nectar', true, ['all', 'auspicious']),
  shubh('Shubh', 'Auspicious', true, ['auspicious', 'beginnings', 'travel']),
  labh('Labh', 'Gain', true, ['business', 'investment', 'learning']),
  char('Char', 'Moving', true, ['travel', 'relocation', 'journey']),
  udveg('Udveg', 'Anxiety', false, ['routine work', 'avoid decisions']),
  kaal('Kaal', 'Death', false, ['avoid all auspicious activities']),
  rog('Rog', 'Disease', false, ['avoid medical procedures', 'avoid travel']);

  const ChoghadiyaType(
    this.name,
    this.meaning,
    this.isAuspicious,
    this.favorableActivities,
  );

  final String name;
  final String meaning;
  final bool isAuspicious;
  final List<String> favorableActivities;

  String get nature => isAuspicious ? 'Auspicious' : 'Inauspicious';
}

/// Inauspicious periods (Rahukalam, Gulikalam, Yamagandam).
class InauspiciousPeriods {
  const InauspiciousPeriods({
    this.rahukalam,
    this.gulikalam,
    this.yamagandam,
  });

  /// Rahukalam (Rahu period)
  final TimePeriod? rahukalam;

  /// Gulikalam (Gulika/Maandi period)
  final TimePeriod? gulikalam;

  /// Yamagandam (Yama period)
  final TimePeriod? yamagandam;

  /// Checks if a given time is inauspicious
  bool isInauspicious(DateTime time) {
    return (rahukalam?.contains(time) ?? false) ||
        (gulikalam?.contains(time) ?? false) ||
        (yamagandam?.contains(time) ?? false);
  }

  /// Gets which inauspicious period is active
  String? getActivePeriod(DateTime time) {
    if (rahukalam?.contains(time) ?? false) return 'Rahukalam';
    if (gulikalam?.contains(time) ?? false) return 'Gulikalam';
    if (yamagandam?.contains(time) ?? false) return 'Yamagandam';
    return null;
  }

  /// Gets warnings for the inauspicious periods
  List<String> get warnings {
    return [
      if (rahukalam != null)
        'Rahukalam (${_formatTime(rahukalam!.start)} - ${_formatTime(rahukalam!.end)}): Avoid new beginnings, auspicious activities',
      if (gulikalam != null)
        'Gulikalam (${_formatTime(gulikalam!.start)} - ${_formatTime(gulikalam!.end)}): Avoid travel, medical procedures',
      if (yamagandam != null)
        'Yamagandam (${_formatTime(yamagandam!.start)} - ${_formatTime(yamagandam!.end)}): Avoid important decisions, travel',
    ];
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

/// Simple time period.
class TimePeriod {
  const TimePeriod({required this.start, required this.end});
  final DateTime start;
  final DateTime end;

  bool contains(DateTime time) {
    return time.isAfter(start) && time.isBefore(end);
  }
}

/// Muhurta period interface.
abstract class MuhurtaPeriod {
  DateTime get startTime;
  DateTime get endTime;
  String get name;
  bool get isAuspicious;
  String get nature;
  bool isFavorableFor(String activity);
}

/// Muhurta constants.
class MuhurtaConstants {
  /// Duration of one Hora in minutes (approximate)
  static const int horaDurationMinutes = 60;

  /// Duration of Choghadiya in minutes during day (approximate)
  static const int choghadiyaDayDurationMinutes = 90;

  /// Duration of Choghadiya in minutes during night (approximate)
  static const int choghadiyaNightDurationMinutes = 90;

  /// Rahu Kalam duration in minutes (approximately 90 minutes)
  static const int rahuKalamDurationMinutes = 90;

  /// Gulika Kalam duration in minutes
  static const int gulikaKalamDurationMinutes = 90;

  /// Yama Gandam duration in minutes
  static const int yamaGandamDurationMinutes = 90;

  /// Rahu Kalam periods by weekday (in 8ths of daytime)
  /// Format: (start 8th, end 8th)
  static const Map<int, (int, int)> rahuKalamByWeekday = {
    0: (6, 8), // Sunday: 7th and 8th portion
    1: (4, 6), // Monday: 5th and 6th portion
    2: (2, 4), // Tuesday: 3rd and 4th portion
    3: (1, 2), // Wednesday: 1st and 2nd portion
    4: (5, 7), // Thursday: 6th and 7th portion
    5: (3, 5), // Friday: 4th and 5th portion
    6: (7, 1), // Saturday: 8th and 1st portion
  };

  /// Gulika Kalam periods by weekday
  static const Map<int, (int, int)> gulikaKalamByWeekday = {
    0: (4, 6), // Sunday
    1: (2, 4), // Monday
    2: (6, 8), // Tuesday
    3: (5, 7), // Wednesday
    4: (3, 5), // Thursday
    5: (7, 1), // Friday
    6: (1, 2), // Saturday
  };

  /// Yama Gandam periods by weekday
  static const Map<int, (int, int)> yamaGandamByWeekday = {
    0: (3, 5), // Sunday
    1: (6, 8), // Monday
    2: (5, 7), // Tuesday
    3: (4, 6), // Wednesday
    4: (7, 1), // Thursday
    5: (1, 2), // Friday
    6: (2, 4), // Saturday
  };

  /// Hora lords sequence
  static const List<Planet> horaLordsSequence = [
    Planet.sun,
    Planet.venus,
    Planet.mercury,
    Planet.moon,
    Planet.saturn,
    Planet.jupiter,
    Planet.mars,
  ];

  /// Choghadiya sequence for daytime (by weekday)
  static const Map<int, List<ChoghadiyaType>> daytimeChoghadiyaSequence = {
    0: [
      ChoghadiyaType.udveg,
      ChoghadiyaType.char,
      ChoghadiyaType.labh,
      ChoghadiyaType.amrit,
      ChoghadiyaType.kaal,
      ChoghadiyaType.shubh,
      ChoghadiyaType.rog,
      ChoghadiyaType.udveg
    ],
    1: [
      ChoghadiyaType.amrit,
      ChoghadiyaType.kaal,
      ChoghadiyaType.shubh,
      ChoghadiyaType.rog,
      ChoghadiyaType.udveg,
      ChoghadiyaType.char,
      ChoghadiyaType.labh,
      ChoghadiyaType.amrit
    ],
    2: [
      ChoghadiyaType.rog,
      ChoghadiyaType.udveg,
      ChoghadiyaType.char,
      ChoghadiyaType.labh,
      ChoghadiyaType.amrit,
      ChoghadiyaType.kaal,
      ChoghadiyaType.shubh,
      ChoghadiyaType.rog
    ],
    3: [
      ChoghadiyaType.labh,
      ChoghadiyaType.amrit,
      ChoghadiyaType.kaal,
      ChoghadiyaType.shubh,
      ChoghadiyaType.rog,
      ChoghadiyaType.udveg,
      ChoghadiyaType.char,
      ChoghadiyaType.labh
    ],
    4: [
      ChoghadiyaType.shubh,
      ChoghadiyaType.rog,
      ChoghadiyaType.udveg,
      ChoghadiyaType.char,
      ChoghadiyaType.labh,
      ChoghadiyaType.amrit,
      ChoghadiyaType.kaal,
      ChoghadiyaType.shubh
    ],
    5: [
      ChoghadiyaType.char,
      ChoghadiyaType.labh,
      ChoghadiyaType.amrit,
      ChoghadiyaType.kaal,
      ChoghadiyaType.shubh,
      ChoghadiyaType.rog,
      ChoghadiyaType.udveg,
      ChoghadiyaType.char
    ],
    6: [
      ChoghadiyaType.kaal,
      ChoghadiyaType.shubh,
      ChoghadiyaType.rog,
      ChoghadiyaType.udveg,
      ChoghadiyaType.char,
      ChoghadiyaType.labh,
      ChoghadiyaType.amrit,
      ChoghadiyaType.kaal
    ],
  };

  /// Choghadiya sequence for nighttime (by weekday)
  static const Map<int, List<ChoghadiyaType>> nighttimeChoghadiyaSequence = {
    0: [
      ChoghadiyaType.shubh,
      ChoghadiyaType.amrit,
      ChoghadiyaType.char,
      ChoghadiyaType.rog,
      ChoghadiyaType.kaal,
      ChoghadiyaType.labh,
      ChoghadiyaType.udveg,
      ChoghadiyaType.shubh
    ],
    1: [
      ChoghadiyaType.char,
      ChoghadiyaType.rog,
      ChoghadiyaType.kaal,
      ChoghadiyaType.labh,
      ChoghadiyaType.udveg,
      ChoghadiyaType.shubh,
      ChoghadiyaType.amrit,
      ChoghadiyaType.char
    ],
    2: [
      ChoghadiyaType.kaal,
      ChoghadiyaType.labh,
      ChoghadiyaType.udveg,
      ChoghadiyaType.shubh,
      ChoghadiyaType.amrit,
      ChoghadiyaType.char,
      ChoghadiyaType.rog,
      ChoghadiyaType.kaal
    ],
    3: [
      ChoghadiyaType.udveg,
      ChoghadiyaType.shubh,
      ChoghadiyaType.amrit,
      ChoghadiyaType.char,
      ChoghadiyaType.rog,
      ChoghadiyaType.kaal,
      ChoghadiyaType.labh,
      ChoghadiyaType.udveg
    ],
    4: [
      ChoghadiyaType.amrit,
      ChoghadiyaType.char,
      ChoghadiyaType.rog,
      ChoghadiyaType.kaal,
      ChoghadiyaType.labh,
      ChoghadiyaType.udveg,
      ChoghadiyaType.shubh,
      ChoghadiyaType.amrit
    ],
    5: [
      ChoghadiyaType.rog,
      ChoghadiyaType.kaal,
      ChoghadiyaType.labh,
      ChoghadiyaType.udveg,
      ChoghadiyaType.shubh,
      ChoghadiyaType.amrit,
      ChoghadiyaType.char,
      ChoghadiyaType.rog
    ],
    6: [
      ChoghadiyaType.labh,
      ChoghadiyaType.udveg,
      ChoghadiyaType.shubh,
      ChoghadiyaType.amrit,
      ChoghadiyaType.char,
      ChoghadiyaType.rog,
      ChoghadiyaType.kaal,
      ChoghadiyaType.labh
    ],
  };
}
