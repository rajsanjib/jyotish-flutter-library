import 'package:jyotish/src/models/planet.dart';
import 'package:jyotish/src/models/vedic_chart.dart';

/// Varshapal (Annual Chart) period types.
enum VarshapalPeriodType {
  /// Annual year period ruled by Varsha lord
  varsha,

  /// Monthly period ruled by Maas lord
  maasa,

  /// Daily period ruled by Dina lord
  dina,

  /// Hourly period ruled by Hora lord
  hora,
}

/// Represents a period in the Varshapal (annual chart).
class VarshapalPeriod {
  const VarshapalPeriod({
    required this.type,
    required this.lord,
    required this.startDate,
    required this.endDate,
    required this.duration,
    this.subPeriods = const [],
  });

  /// The type of period (Varsha, Maasa, Dina, Hora)
  final VarshapalPeriodType type;

  /// The ruling planet of this period
  final Planet lord;

  /// Start date of this period
  final DateTime startDate;

  /// End date of this period
  final DateTime endDate;

  /// Duration of this period
  final Duration duration;

  /// Sub-periods within this period
  final List<VarshapalPeriod> subPeriods;

  /// Gets the formatted period string
  String get periodString {
    return '${lord.displayName} - ${startDate.day}/${startDate.month} to ${endDate.day}/${endDate.month}';
  }

  /// Converts this period to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'lord': lord.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'duration': duration.inMilliseconds,
      'subPeriods': subPeriods.map((s) => s.toJson()).toList(),
    };
  }
}

/// Represents the Varshapal (Annual Chart) in Vedic astrology.
///
/// Varshapal is an annual chart calculated from the birthday each year.
/// It shows the influences for the entire year based on planetary positions
/// at the time of the solar return (birthday).
///
/// The Varshapal has its own system of periods (Dasa):
/// - Varsha Dasa: Year-long periods ruled by planets
/// - Maas Dasa: Monthly periods
/// - Dina Dasa: Daily periods
/// - Hora Dasa: Hourly periods
class Varshapal {
  const Varshapal({
    required this.chart,
    required this.birthDateTime,
    required this.varshaDateTime,
    required this.varshaLord,
    required this.varshaNumber,
    required this.samvatsaraName,
    required this.allVarshaPeriods,
    required this.allMaasaPeriods,
    required this.allDinaPeriods,
    required this.allHoraPeriods,
    required this.currentVarshaPeriod,
    required this.currentMaasaPeriod,
    required this.currentDinaPeriod,
    required this.currentHoraPeriod,
    this.panchavargiyaBala = const {},
    this.muddaDasha = const [],
  });

  /// The annual chart for this Varshapal year
  final VedicChart chart;

  /// The original birth date/time
  final DateTime birthDateTime;

  /// The date/time when the Varshapal year starts (birthday)
  final DateTime varshaDateTime;

  /// The ruling planet of this Varshapal year (based on Jupiter's position)
  final Planet varshaLord;

  /// The Varshapal year number (1-60 in the Samvatsara cycle)
  final int varshaNumber;

  /// The traditional name of the Samvatsara (60-year cycle year)
  final String samvatsaraName;

  /// All Varsha (year) periods in this Varshapal
  final List<VarshapalPeriod> allVarshaPeriods;

  /// All Maas (month) periods in this Varshapal year
  final List<VarshapalPeriod> allMaasaPeriods;

  /// All Dina (day) periods in this Varshapal year
  final List<VarshapalPeriod> allDinaPeriods;

  /// All Hora (hour) periods in this Varshapal year
  final List<VarshapalPeriod> allHoraPeriods;

  /// Current active Varsha period at the given date
  final VarshapalPeriod? currentVarshaPeriod;

  /// Current active Maas period at the given date
  final VarshapalPeriod? currentMaasaPeriod;

  /// Current active Dina period at the given date
  final VarshapalPeriod? currentDinaPeriod;

  /// Current active Hora period at the given date
  final VarshapalPeriod? currentHoraPeriod;

  /// Panchavargiya Bala (5-fold strength) for each traditional planet
  final Map<Planet, PanchavargiyaBalaResult> panchavargiyaBala;

  /// Mudda Dasha (scaled annual Vimshottari dasha) periods
  final List<VarshapalPeriod> muddaDasha;

  /// Alias for [currentMaasaPeriod?.lord] for legacy tests.
  Planet? get maasLord => currentMaasaPeriod?.lord;

  /// Alias for [varshaLord] for legacy tests.
  Planet get varshesha => varshaLord;

  /// Gets the current period at all levels for a given date
  VarshapalCurrentPeriods getCurrentPeriods(DateTime date) {
    return VarshapalCurrentPeriods(
      varsha: currentVarshaPeriod,
      maasa: currentMaasaPeriod,
      dina: currentDinaPeriod,
      hora: currentHoraPeriod,
    );
  }

  /// Gets the formatted current period string
  String getCurrentPeriodString(DateTime date) {
    final periods = getCurrentPeriods(date);
    final parts = <String>[];

    if (periods.varsha != null) {
      parts.add('Varsha: ${periods.varsha!.lord.displayName}');
    }
    if (periods.maasa != null) {
      parts.add('Maasa: ${periods.maasa!.lord.displayName}');
    }
    if (periods.dina != null) {
      parts.add('Dina: ${periods.dina!.lord.displayName}');
    }
    if (periods.hora != null) {
      parts.add('Hora: ${periods.hora!.lord.displayName}');
    }

    return parts.join(' | ');
  }

  /// Converts the Varshapal to JSON
  Map<String, dynamic> toJson() {
    return {
      'birthDateTime': birthDateTime.toIso8601String(),
      'varshaDateTime': varshaDateTime.toIso8601String(),
      'varshaLord': varshaLord.name,
      'varshaNumber': varshaNumber,
      'samvatsaraName': samvatsaraName,
      'panchavargiyaBala': panchavargiyaBala.map(
        (k, v) => MapEntry(k.name, v.toJson()),
      ),
      'muddaDasha': muddaDasha.map((v) => v.toJson()).toList(),
    };
  }
}

/// Represents the Panchavargiya Bala (5-fold strength) calculation result for a planet in a solar return (Varshapal) chart.
class PanchavargiyaBalaResult {
  const PanchavargiyaBalaResult({
    required this.planet,
    required this.kshetraBala,
    required this.haddaBala,
    required this.drekkanaBala,
    required this.navamsaBala,
    required this.ucchaBala,
    required this.totalBala,
    required this.vishwaBala,
  });

  /// The planet evaluated
  final Planet planet;

  /// Kshetra Bala (0 - 30 points)
  final double kshetraBala;

  /// Hadda Bala (0 - 15 points)
  final double haddaBala;

  /// Drekkana Bala (0 - 10 points)
  final double drekkanaBala;

  /// Navamsa Bala (0 - 5 points)
  final double navamsaBala;

  /// Uccha Bala (0 - 20 points)
  final double ucchaBala;

  /// Total combined strength (sum of the five strengths, 0 - 80 points)
  final double totalBala;

  /// Vishwa Bala score (totalBala / 4, 0 - 20 points)
  final double vishwaBala;

  /// Converts this result to a JSON map
  Map<String, dynamic> toJson() => {
        'planet': planet.displayName,
        'kshetraBala': kshetraBala,
        'haddaBala': haddaBala,
        'drekkanaBala': drekkanaBala,
        'navamsaBala': navamsaBala,
        'ucchaBala': ucchaBala,
        'totalBala': totalBala,
        'vishwaBala': vishwaBala,
      };

  @override
  String toString() {
    return '${planet.displayName}: Total $totalBala (Vishwa: $vishwaBala)';
  }
}

/// Holds the current periods at all levels.
class VarshapalCurrentPeriods {
  const VarshapalCurrentPeriods({
    this.varsha,
    this.maasa,
    this.dina,
    this.hora,
  });

  /// Current Varsha period
  final VarshapalPeriod? varsha;

  /// Current Maas period
  final VarshapalPeriod? maasa;

  /// Current Dina period
  final VarshapalPeriod? dina;

  /// Current Hora period
  final VarshapalPeriod? hora;
}
