import 'planet.dart';
import 'rashi.dart';

/// Type of dasha system used in Vedic astrology.
enum DashaType {
  /// Vimshottari Dasha - 120 year cycle, most commonly used
  vimshottari('Vimshottari', 120),

  /// Yogini Dasha - 36 year cycle, uses 8 yoginis
  yogini('Yogini', 36),

  /// Chara Dasha - Jaimini system using signs
  chara('Chara', 96),

  /// Narayana Dasha - Jaimini sign-based dasha
  narayana('Narayana', 120),

  /// Ashtottari Dasha - 108 year cycle
  ashtottari('Ashtottari', 108),

  /// Kalachakra Dasha - Nakshatra-based system
  kalachakra('Kalachakra', 100),

  /// Tribhagi Dasha - Fractional Vimshottari (40 year cycle)
  tribhagi('Tribhagi', 40);

  const DashaType(this.displayName, this.totalYears);

  /// Display name of the dasha system
  final String displayName;

  /// Total cycle length in years
  final int totalYears;

  @override
  String toString() => displayName;
}

/// Schemes for Ashtottari Dasha calculation.
enum AshtottariScheme {
  /// Standard starting from Ardra (Ardra-adi)
  ardraAdi('Ardra-adi'),

  /// Alternative starting from Krittika (Krittika-adi)
  krittikaAdi('Krittika-adi');

  const AshtottariScheme(this.displayName);
  final String displayName;

  @override
  String toString() => displayName;
}

/// Types of jumps (Gati) in Kalachakra Dasha sequence.
enum KalachakraGati {
  /// Normal movement
  normal('Normal'),

  /// Frog Jump (skipping signs)
  manduka('Manduka Gati (Frog Jump)'),

  /// Lion's Gaze (jumping across signs)
  simhavalokana('Simhavalokana Gati (Lion\'s Gaze)'),

  /// Return movement
  aprati('Aprati Gati (Return Jump)');

  const KalachakraGati(this.displayName);
  final String displayName;

  @override
  String toString() => displayName;
}

/// Represents a dasha period (major, sub, or sub-sub period).
///
/// Dasha periods are planetary periods in Vedic astrology that indicate
/// which planet's influence is dominant during that time.
class DashaPeriod {
  /// Creates a dasha period.
  const DashaPeriod({
    this.lord,
    required this.startDate,
    required this.endDate,
    required this.duration,
    required this.level,
    this.subPeriods = const [],
    this.parent,
    this.lordName,
    this.rashi,
  });

  /// The ruling planet (lord) of this dasha period (optional for sign-based dashas)
  final Planet? lord;

  /// The ruling sign (rashi) of this dasha period (used for Chara Dasha)
  final Rashi? rashi;

  /// Custom name for the lord (used to distinguish Rahu/Ketu which both use Planet.meanNode)
  final String? lordName;

  /// Start date of the period
  final DateTime startDate;

  /// End date of the period
  final DateTime endDate;

  /// Duration of the period
  final Duration duration;

  /// Level of the period:
  /// - 0 = Mahadasha (major period)
  /// - 1 = Antardasha (sub-period)
  /// - 2 = Pratyantardasha (sub-sub-period)
  /// - 3 = Sookshma dasha
  /// - 4 = Prana dasha
  final int level;

  /// Child periods (sub-periods within this period)
  final List<DashaPeriod> subPeriods;

  /// Parent period (null for mahadasha)
  final DashaPeriod? parent;

  /// Display name for the level
  String get levelName {
    switch (level) {
      case 0:
        return 'Mahadasha';
      case 1:
        return 'Antardasha';
      case 2:
        return 'Pratyantardasha';
      case 3:
        return 'Sookshma';
      case 4:
        return 'Prana';
      default:
        return 'Level $level';
    }
  }

  /// Duration in years (approximate)
  double get durationYears => duration.inDays / 365.25;

  /// Duration in months (approximate)
  double get durationMonths => duration.inDays / 30.44;

  /// Duration in days
  int get durationDays => duration.inDays;

  /// Whether this period is currently active
  bool isActiveAt(DateTime date) =>
      date.isAfter(startDate) && date.isBefore(endDate);

  /// Whether this is a mahadasha (major period)
  bool get isMahadasha => level == 0;

  /// Whether this is an antardasha (sub-period)
  bool get isAntardasha => level == 1;

  /// Whether this is a pratyantardasha (sub-sub-period)
  bool get isPratyantardasha => level == 2;

  /// Gets the display name for the lord (uses lordName if available, otherwise lord.displayName)
  String get lordDisplayName =>
      lordName ?? rashi?.name ?? lord?.displayName ?? 'Unknown';

  /// Gets the full path name (e.g., "Sun-Moon-Mars")
  String get fullName {
    if (parent == null) {
      return lordDisplayName;
    }
    return '${parent!.fullName}-$lordDisplayName';
  }

  /// Finds the active sub-period at a given date
  DashaPeriod? findActiveSubPeriod(DateTime date) {
    for (final sub in subPeriods) {
      if (sub.isActiveAt(date)) {
        return sub;
      }
    }
    return null;
  }

  /// Gets a formatted duration string
  String get formattedDuration {
    if (durationYears >= 1) {
      final years = durationYears.floor();
      final months = ((durationYears - years) * 12).round();
      if (months > 0) {
        return '$years years, $months months';
      }
      return '$years years';
    } else if (durationMonths >= 1) {
      final months = durationMonths.floor();
      final days = ((durationMonths - months) * 30).round();
      if (days > 0) {
        return '$months months, $days days';
      }
      return '$months months';
    } else {
      return '$durationDays days';
    }
  }

  @override
  String toString() =>
      '$levelName: $lordDisplayName (${startDate.toIso8601String().substring(0, 10)} to ${endDate.toIso8601String().substring(0, 10)})';

  /// Converts to JSON map (without circular references)
  Map<String, dynamic> toJson() => {
        'lord': lord?.displayName,
        'rashi': rashi?.name,
        'lordDisplayName': lordDisplayName,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'durationDays': durationDays,
        'level': level,
        'levelName': levelName,
        'subPeriods': subPeriods.map((p) => p.toJson()).toList(),
      };
}

/// Complete dasha calculation result.
///
/// Contains the full dasha sequence from birth, current periods,
/// and methods to query periods at any date.
class DashaResult {
  /// Creates a dasha result.
  const DashaResult({
    required this.type,
    required this.birthDateTime,
    required this.moonLongitude,
    required this.birthNakshatra,
    required this.birthPada,
    required this.balanceOfFirstDasha,
    required this.allMahadashas,
    this.precisionWarning,
  });

  /// Type of dasha system used
  final DashaType type;

  /// Birth date and time
  final DateTime birthDateTime;

  /// Moon's longitude at birth (used for Vimshottari)
  final double moonLongitude;

  /// Birth nakshatra name
  final String birthNakshatra;

  /// Birth nakshatra pada (1-4)
  final int birthPada;

  /// Balance of first dasha at birth (in days)
  final double balanceOfFirstDasha;

  /// All mahadasha periods from birth
  final List<DashaPeriod> allMahadashas;

  /// Calculation precision warning (if birth time uncertain)
  final String? precisionWarning;

  /// Gets the current mahadasha at a given date
  DashaPeriod? getMahadashaAt(DateTime date) {
    for (final dasha in allMahadashas) {
      if (dasha.isActiveAt(date)) {
        return dasha;
      }
    }
    return null;
  }

  /// Gets the current antardasha at a given date
  DashaPeriod? getAndardashaAt(DateTime date) {
    final maha = getMahadashaAt(date);
    return maha?.findActiveSubPeriod(date);
  }

  /// Gets the current pratyantardasha at a given date
  DashaPeriod? getPratyantardashaAt(DateTime date) {
    final antar = getAndardashaAt(date);
    return antar?.findActiveSubPeriod(date);
  }

  /// Gets all active periods at a given date (mahadasha, antardasha, etc.)
  List<DashaPeriod> getActivePeriodsAt(DateTime date) {
    final periods = <DashaPeriod>[];

    final maha = getMahadashaAt(date);
    if (maha != null) {
      periods.add(maha);

      final antar = maha.findActiveSubPeriod(date);
      if (antar != null) {
        periods.add(antar);

        final pratyantar = antar.findActiveSubPeriod(date);
        if (pratyantar != null) {
          periods.add(pratyantar);
        }
      }
    }

    return periods;
  }

  /// Gets the current period string (e.g., "Sun-Moon-Mars")
  String getCurrentPeriodString(DateTime date) {
    final periods = getActivePeriodsAt(date);
    if (periods.isEmpty) return 'Unknown';
    return periods.map((p) => p.lordDisplayName).join('-');
  }

  /// Gets the current mahadasha (convenience for current time)
  DashaPeriod? get currentMahadasha => getMahadashaAt(DateTime.now());

  /// Gets the current antardasha (convenience for current time)
  DashaPeriod? get currentAntardasha => getAndardashaAt(DateTime.now());

  /// Gets the current pratyantardasha (convenience for current time)
  DashaPeriod? get currentPratyantardasha =>
      getPratyantardashaAt(DateTime.now());

  @override
  String toString() =>
      '${type.displayName} Dasha: ${getCurrentPeriodString(DateTime.now())}';

  /// Converts to JSON map
  Map<String, dynamic> toJson() => {
        'type': type.displayName,
        'birthDateTime': birthDateTime.toIso8601String(),
        'moonLongitude': moonLongitude,
        'birthNakshatra': birthNakshatra,
        'birthPada': birthPada,
        'balanceOfFirstDasha': balanceOfFirstDasha,
        'precisionWarning': precisionWarning,
        'mahadashas': allMahadashas.map((d) => d.toJson()).toList(),
      };
}

/// Yogini dasha specific information.
///
/// Used for the Yogini dasha system which has 8 yoginis
/// instead of the 9 planets used in Vimshottari.
enum Yogini {
  mangala(Planet.moon, 'Mangala', 1),
  pingala(Planet.sun, 'Pingala', 2),
  dhanya(Planet.jupiter, 'Dhanya', 3),
  bhramari(Planet.mars, 'Bhramari', 4),
  bhadrika(Planet.mercury, 'Bhadrika', 5),
  ulka(Planet.saturn, 'Ulka', 6),
  siddha(Planet.venus, 'Siddha', 7),
  sankata(Planet.meanNode, 'Sankata', 8);

  const Yogini(this.planet, this.name, this.years);

  /// The associated planet
  final Planet planet;

  /// Name of the yogini
  final String name;

  /// Duration in years
  final int years;

  @override
  String toString() => name;
}
