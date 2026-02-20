import '../models/planet.dart';
import '../models/vedic_chart.dart';

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
    };
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
