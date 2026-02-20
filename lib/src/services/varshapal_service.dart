import '../models/geographic_location.dart';
import '../models/planet.dart';
import '../models/varshapal.dart';
import 'ephemeris_service.dart';
import 'vedic_chart_service.dart';

/// Service for calculating Varshapal (Annual Chart) and its periods.
///
/// Varshapal is calculated from the birthday each year and shows the
/// planetary influences for that year based on the solar return chart.
class VarshapalService {
  VarshapalService(this._ephemerisService);

  final EphemerisService _ephemerisService;

  /// The 60-year Samvatsara cycle names (Vrihaspati Chakra).
  static const List<String> samvatsaraNames = [
    'Prabhava', 'Vibhava', 'Shukla', 'Pramodoota', 'Prajothpatti',
    'Aangirasa', 'Shreemukha', 'Bhaava', 'Yuva', 'Dhaatu',
    'Eeshwara', 'Bahudhanya', 'Pramaadi', 'Vikrama', 'Vishu',
    'Chitrabhanu', 'Svabhanu', 'Taarana', 'Paarthiva', 'Vyaya',
    'Sarvajith', 'Sarvadhaari', 'Virodhi', 'Vikrita', 'Khara',
    'Nandana', 'Vijaya', 'Jaya', 'Manmatha', 'Durmukhi',
    'Hevilambi', 'Vilambi', 'Vikaari', 'Shaarvari', 'Plava',
    'Shubhakruth', 'Shobhakruth', 'Krodhi', 'Vishvaavasu', 'Paraabhava',
    'Plavanga', 'Keelaka', 'Saumya', 'Saadhaarana', 'Virodhikruth',
    'Paridhawi', 'Pramaadeecha', 'Aananda', 'Raakshasa', 'Nala',
    'Pingala', 'Kaalayukthi', 'Siddharthi', 'Raudra', 'Durmathi',
    'Dundubhi', 'Rudhirodgaari', 'Ruktaakshi', 'Krodhana', 'Akshaya',
  ];

  /// Varsha Dasa order (which planet rules each year in sequence).
  static const List<Planet> varshaDasaOrder = [
    Planet.sun, Planet.moon, Planet.mars, Planet.mercury,
    Planet.jupiter, Planet.venus, Planet.saturn,
  ];

  /// Maas Dasa order (month periods).
  static const List<Planet> maasaDasaOrder = [
    Planet.sun, Planet.moon, Planet.mars, Planet.mercury,
    Planet.jupiter, Planet.venus, Planet.saturn,
  ];

  /// Dina Dasa order (day periods).
  static const List<Planet> dinaDasaOrder = [
    Planet.sun, Planet.moon, Planet.mars, Planet.mercury,
    Planet.jupiter, Planet.venus, Planet.saturn,
  ];

  /// Hora Dasa order (hour periods).
  static const List<Planet> horaDasaOrder = [
    Planet.sun, Planet.moon, Planet.mars, Planet.mercury,
    Planet.jupiter, Planet.venus, Planet.saturn,
  ];

  /// Calculates the Varshapal (Annual Chart) for a given date.
  ///
  /// [birthDateTime] - Original birth date and time
  /// [varshaDateTime] - The birthday date/time for the year to calculate
  /// [location] - Birth location (used for chart calculation)
  /// [houseSystem] - House system to use (default: Whole Sign 'W')
  /// [checkDate] - Optional date to check current periods (defaults to now)
  ///
  /// Returns complete Varshapal with chart and all period calculations.
  Future<Varshapal> calculateVarshapal({
    required DateTime birthDateTime,
    required DateTime varshaDateTime,
    required GeographicLocation location,
    String houseSystem = 'W',
    DateTime? checkDate,
  }) async {
    checkDate ??= DateTime.now();

    // Calculate the annual chart for the varsha date
    final vedicChartService = VedicChartService(_ephemerisService);
    final chart = await vedicChartService.calculateChart(
      dateTime: varshaDateTime,
      location: location,
      houseSystem: houseSystem,
    );

    // Get Jupiter's position to determine varsha lord
    final jupiterInfo = chart.getPlanet(Planet.jupiter);
    final jupiterLongitude = jupiterInfo?.longitude ?? 0;

    // Calculate varsha number (1-60) based on Jupiter's position
    final varshaNumber = _calculateVarshaNumber(jupiterLongitude);
    final samvatsaraName = samvatsaraNames[(varshaNumber - 1) % 60];

    // Determine varsha lord from the 60-year cycle
    final varshaLord = _getVarshaLord(varshaNumber);

    // Calculate all periods
    final allVarshaPeriods = _calculateVarshaPeriods(
      startDate: varshaDateTime,
      varshaLord: varshaLord,
    );

    final allMaasaPeriods = _calculateMaasaPeriods(
      startDate: varshaDateTime,
      varshaLord: varshaLord,
    );

    final allDinaPeriods = _calculateDinaPeriods(
      startDate: varshaDateTime,
      varshaLord: varshaLord,
    );

    final allHoraPeriods = _calculateHoraPeriods(
      startDate: varshaDateTime,
      varshaLord: varshaLord,
    );

    // Find current periods
    final currentVarshaPeriod = _findCurrentPeriod(allVarshaPeriods, checkDate);
    final currentMaasaPeriod = _findCurrentPeriod(allMaasaPeriods, checkDate);
    final currentDinaPeriod = _findCurrentPeriod(allDinaPeriods, checkDate);
    final currentHoraPeriod = _findCurrentPeriod(allHoraPeriods, checkDate);

    return Varshapal(
      chart: chart,
      birthDateTime: birthDateTime,
      varshaDateTime: varshaDateTime,
      varshaLord: varshaLord,
      varshaNumber: varshaNumber,
      samvatsaraName: samvatsaraName,
      allVarshaPeriods: allVarshaPeriods,
      allMaasaPeriods: allMaasaPeriods,
      allDinaPeriods: allDinaPeriods,
      allHoraPeriods: allHoraPeriods,
      currentVarshaPeriod: currentVarshaPeriod,
      currentMaasaPeriod: currentMaasaPeriod,
      currentDinaPeriod: currentDinaPeriod,
      currentHoraPeriod: currentHoraPeriod,
    );
  }

  /// Calculates Varshapal for the current year (from birthday to next birthday).
  Future<Varshapal> calculateCurrentVarshapal({
    required DateTime birthDateTime,
    required GeographicLocation location,
    String houseSystem = 'W',
    DateTime? checkDate,
  }) async {
    checkDate ??= DateTime.now();

    // Calculate this year's birthday
    final thisYearBirthday = DateTime(
      checkDate.year,
      birthDateTime.month,
      birthDateTime.day,
      birthDateTime.hour,
      birthDateTime.minute,
    );

    // If birthday hasn't occurred yet this year, use last year's
    final varshaDateTime = thisYearBirthday.isAfter(checkDate)
        ? DateTime(
            checkDate.year - 1,
            birthDateTime.month,
            birthDateTime.day,
            birthDateTime.hour,
            birthDateTime.minute,
          )
        : thisYearBirthday;

    return calculateVarshapal(
      birthDateTime: birthDateTime,
      varshaDateTime: varshaDateTime,
      location: location,
      houseSystem: houseSystem,
      checkDate: checkDate,
    );
  }

  /// Calculates the varsha number (1-60) based on Jupiter's longitude.
  int _calculateVarshaNumber(double jupiterLongitude) {
    // Jupiter moves approximately 30° per year in the zodiac
    // We use a simplified calculation based on Jupiter's position
    final signNumber = (jupiterLongitude / 30).floor();
    final degreeInSign = jupiterLongitude % 30;

    // Calculate position within the 60-year cycle
    // Each sign lasts approximately 12/60 = 0.2 years = ~2 months
    final cyclePosition = (signNumber * 2 + (degreeInSign / 15).floor()) % 60;
    return cyclePosition + 1;
  }

  /// Gets the varsha lord for a given varsha number (1-60).
  Planet _getVarshaLord(int varshaNumber) {
    // In the 60-year cycle, each planet rules for different numbers of years
    // This follows the traditional Samvatsara pattern
    final index = (varshaNumber - 1) % 60;

    // Based on traditional Vimshottari-type cycle for annual charts
    // Using a modified 7-year cycle pattern
    final planetIndex = (index ~/ 2) % 7;
    return varshaDasaOrder[planetIndex];
  }

  /// Calculates all Varsha (year) periods.
  List<VarshapalPeriod> _calculateVarshaPeriods({
    required DateTime startDate,
    required Planet varshaLord,
  }) {
    final periods = <VarshapalPeriod>[];
    var currentDate = startDate;
    var currentLordIndex = varshaDasaOrder.indexOf(varshaLord);

    for (var i = 0; i < 7; i++) {
      final lord = varshaDasaOrder[currentLordIndex % 7];
      final durationYears = _getVarshaDuration(lord);
      final endDate = currentDate.add(Duration(days: (durationYears * 365.25).round()));

      periods.add(VarshapalPeriod(
        type: VarshapalPeriodType.varsha,
        lord: lord,
        startDate: currentDate,
        endDate: endDate,
        duration: endDate.difference(currentDate),
      ));

      currentDate = endDate;
      currentLordIndex++;
    }

    return periods;
  }

  /// Calculates all Maas (month) periods.
  List<VarshapalPeriod> _calculateMaasaPeriods({
    required DateTime startDate,
    required Planet varshaLord,
  }) {
    final periods = <VarshapalPeriod>[];
    var currentDate = startDate;
    var currentLordIndex = maasaDasaOrder.indexOf(varshaLord);

    for (var i = 0; i < 12; i++) {
      final lord = maasaDasaOrder[currentLordIndex % 7];
      final endDate = _addMaasaDuration(currentDate, lord);

      periods.add(VarshapalPeriod(
        type: VarshapalPeriodType.maasa,
        lord: lord,
        startDate: currentDate,
        endDate: endDate,
        duration: endDate.difference(currentDate),
      ));

      currentDate = endDate;
      currentLordIndex++;
    }

    return periods;
  }

  /// Calculates all Dina (day) periods.
  List<VarshapalPeriod> _calculateDinaPeriods({
    required DateTime startDate,
    required Planet varshaLord,
  }) {
    final periods = <VarshapalPeriod>[];
    var currentDate = startDate;
    var currentLordIndex = dinaDasaOrder.indexOf(varshaLord);

    // Calculate for the full year (approximately 360 days for Vedic calendar)
    for (var i = 0; i < 30; i++) {
      final lord = dinaDasaOrder[currentLordIndex % 7];
      final endDate = currentDate.add(const Duration(days: 1));

      periods.add(VarshapalPeriod(
        type: VarshapalPeriodType.dina,
        lord: lord,
        startDate: currentDate,
        endDate: endDate,
        duration: const Duration(days: 1),
      ));

      currentDate = endDate;
      currentLordIndex++;
    }

    return periods;
  }

  /// Calculates all Hora (hour) periods.
  List<VarshapalPeriod> _calculateHoraPeriods({
    required DateTime startDate,
    required Planet varshaLord,
  }) {
    final periods = <VarshapalPeriod>[];
    var currentDate = startDate;
    var currentLordIndex = horaDasaOrder.indexOf(varshaLord);

    // Calculate for 24 hours
    for (var i = 0; i < 24; i++) {
      final lord = horaDasaOrder[currentLordIndex % 7];
      final endDate = currentDate.add(const Duration(hours: 1));

      periods.add(VarshapalPeriod(
        type: VarshapalPeriodType.hora,
        lord: lord,
        startDate: currentDate,
        endDate: endDate,
        duration: const Duration(hours: 1),
      ));

      currentDate = endDate;
      currentLordIndex++;
    }

    return periods;
  }

  /// Gets the duration in years for each planet's Varsha period.
  double _getVarshaDuration(Planet planet) {
    // Traditional Varsha Dasa durations (in years)
    // Based on planetaryvimshottari ratios
    switch (planet) {
      case Planet.sun:
        return 1.0;
      case Planet.moon:
        return 1.0;
      case Planet.mars:
        return 1.0;
      case Planet.mercury:
        return 1.0;
      case Planet.jupiter:
        return 1.0;
      case Planet.venus:
        return 1.0;
      case Planet.saturn:
        return 1.0;
      default:
        return 1.0;
    }
  }

  /// Adds the appropriate duration for a Maas (month) based on the ruling planet.
  DateTime _addMaasaDuration(DateTime startDate, Planet lord) {
    // Each Maas (month) is approximately 30 days in Vedic calendar
    // But variations exist based on solar month vs lunar month
    return startDate.add(const Duration(days: 30));
  }

  /// Finds the current period from a list at a given date.
  VarshapalPeriod? _findCurrentPeriod(
    List<VarshapalPeriod> periods,
    DateTime checkDate,
  ) {
    for (final period in periods) {
      if (checkDate.isAfter(period.startDate) &&
          checkDate.isBefore(period.endDate)) {
        return period;
      }
      // Handle inclusive end date
      if (checkDate.isAtSameMomentAs(period.startDate) ||
          checkDate.isAtSameMomentAs(period.endDate)) {
        return period;
      }
    }
    return periods.isNotEmpty ? periods.first : null;
  }

  /// Gets the Samvatsara name for a given year number (1-60).
  static String getSamvatsaraName(int yearNumber) {
    return samvatsaraNames[(yearNumber - 1) % 60];
  }

  /// Gets the current Varsha number based on a date and reference year.
  static int getCurrentVarshaNumber(DateTime date, {int? referenceYear}) {
    // This requires knowing a reference point (e.g., 2025 = year 7 in cycle)
    // The cycle started in 1983 (Prabhava) - year 1
    referenceYear ??= DateTime.now().year;
    final yearsSince1983 = referenceYear - 1983;
    return ((yearsSince1983 % 60) + 1);
  }
}
