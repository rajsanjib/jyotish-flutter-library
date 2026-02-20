import 'aspect.dart';
import 'planet.dart';
import 'planet_position.dart';

/// Transit position information for a planet.
///
/// Contains the current transit position of a planet along with
/// its relationship to the natal chart (house placement, aspects to natal planets).
class TransitInfo {
  /// Creates transit info.
  const TransitInfo({
    required this.planet,
    required this.transitPosition,
    this.natalPosition,
    required this.transitHouse,
    required this.transitSignIndex,
    this.aspectsToNatal = const [],
  });

  /// The planet being transited
  final Planet planet;

  /// Current transit position
  final PlanetPosition transitPosition;

  /// Natal position of the same planet (for comparison)
  final PlanetPosition? natalPosition;

  /// House number (1-12) in the natal chart where the transit planet is located
  final int transitHouse;

  /// Sign number (0-11) the transit planet is in
  final int transitSignIndex;

  /// Aspects from this transit planet to natal planets
  final List<AspectInfo> aspectsToNatal;

  /// Whether the transit planet is retrograde
  bool get isRetrograde => transitPosition.isRetrograde;

  /// Transit planet's zodiac sign
  String get transitSign => transitPosition.zodiacSign;

  /// Transit planet's nakshatra
  String get transitNakshatra => transitPosition.nakshatra;

  /// Gets the degree difference from natal position (if available)
  double? get degreesFromNatal {
    if (natalPosition == null) return null;
    final diff = transitPosition.longitude - natalPosition!.longitude;
    return ((diff + 180) % 360) - 180; // Normalize to -180 to 180
  }

  /// Whether the transit planet is in the same sign as natal
  bool get isInNatalSign =>
      natalPosition != null &&
      transitPosition.zodiacSignIndex == natalPosition!.zodiacSignIndex;

  /// Gets description of transit
  String get description {
    final retro = isRetrograde ? ' (R)' : '';
    return '${planet.displayName}$retro in $transitSign (House $transitHouse)';
  }

  @override
  String toString() => description;

  /// Converts to JSON map
  Map<String, dynamic> toJson() => {
        'planet': planet.displayName,
        'transitLongitude': transitPosition.longitude,
        'transitSign': transitSign,
        'transitHouse': transitHouse,
        'isRetrograde': isRetrograde,
        'natalLongitude': natalPosition?.longitude,
        'aspectsToNatal': aspectsToNatal.map((a) => a.toJson()).toList(),
      };
}

/// A significant transit event.
///
/// Represents a moment when a transiting planet forms an exact aspect
/// to a natal planet or point.
class TransitEvent {
  /// Creates a transit event.
  const TransitEvent({
    required this.transitPlanet,
    this.natalPlanet,
    this.natalPointName,
    required this.aspectType,
    required this.exactDate,
    required this.startDate,
    required this.endDate,
    this.isRetrograde = false,
    required this.description,
    this.significance = 3,
  });

  /// The transiting planet
  final Planet transitPlanet;

  /// The natal planet being aspected (null if aspecting a point like Ascendant)
  final Planet? natalPlanet;

  /// The name of the natal point if not a planet (e.g., "Ascendant", "MC")
  final String? natalPointName;

  /// Type of aspect formed
  final AspectType aspectType;

  /// Date when aspect becomes exact
  final DateTime exactDate;

  /// Date when aspect enters orb (begins to be effective)
  final DateTime startDate;

  /// Date when aspect leaves orb (ceases to be effective)
  final DateTime endDate;

  /// Whether the transit planet is retrograde at exact aspect
  final bool isRetrograde;

  /// Brief description of the transit event
  final String description;

  /// Significance level (1-5, where 5 is most significant)
  final int significance;

  /// Duration of the transit event
  Duration get duration => endDate.difference(startDate);

  /// Whether the event is currently active at a given date
  bool isActiveAt(DateTime date) =>
      date.isAfter(startDate) && date.isBefore(endDate);

  /// The target of the aspect (planet name or point name)
  String get targetName =>
      natalPlanet?.displayName ?? natalPointName ?? 'Unknown';

  @override
  String toString() =>
      '${transitPlanet.displayName} ${aspectType.english} $targetName on ${exactDate.toIso8601String().substring(0, 10)}';

  /// Converts to JSON map
  Map<String, dynamic> toJson() => {
        'transitPlanet': transitPlanet.displayName,
        'natalPlanet': natalPlanet?.displayName,
        'natalPointName': natalPointName,
        'aspectType': aspectType.english,
        'exactDate': exactDate.toIso8601String(),
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'isRetrograde': isRetrograde,
        'description': description,
        'significance': significance,
      };
}

/// Configuration for transit calculations
class TransitConfig {
  /// Creates transit configuration.
  const TransitConfig({
    required this.startDate,
    required this.endDate,
    this.intervalDays = 1,
    this.planets,
    this.includeAscendant = true,
    this.includeMidheaven = false,
    this.orb = 5.0,
  });

  /// Default configuration: 1 year from now, daily intervals
  factory TransitConfig.oneYear({DateTime? from}) {
    final start = from ?? DateTime.now();
    return TransitConfig(
      startDate: start,
      endDate: start.add(const Duration(days: 365)),
      intervalDays: 1,
    );
  }

  /// Monthly transit overview for 1 year
  factory TransitConfig.monthlyOverview({DateTime? from}) {
    final start = from ?? DateTime.now();
    return TransitConfig(
      startDate: start,
      endDate: start.add(const Duration(days: 365)),
      intervalDays: 30,
    );
  }

  /// Start date for transit calculation range
  final DateTime startDate;

  /// End date for transit calculation range
  final DateTime endDate;

  /// Interval for checking transits (in days)
  final int intervalDays;

  /// Which planets to include in transit calculations
  final List<Planet>? planets;

  /// Whether to include aspects to natal Ascendant
  final bool includeAscendant;

  /// Whether to include aspects to natal Midheaven
  final bool includeMidheaven;

  /// Orb for determining when transit enters/leaves effectiveness
  final double orb;
}
