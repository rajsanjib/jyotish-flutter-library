import 'package:jyotish/src/models/planet.dart';

/// Details of a planetary war (Graha Yuddha) between two true planets.
class WarDetails {
  const WarDetails({
    required this.planet1,
    required this.planet2,
    required this.planet1Magnitude,
    required this.planet2Magnitude,
    required this.planet1Declination,
    required this.planet2Declination,
    required this.longitudeDifference,
    required this.winnerId,
  });

  /// The first participating planet.
  final Planet planet1;

  /// The second participating planet.
  final Planet planet2;

  /// Apparent astronomical magnitude of planet 1.
  final double planet1Magnitude;

  /// Apparent astronomical magnitude of planet 2.
  final double planet2Magnitude;

  /// Astronomical declination (latitude) of planet 1.
  final double planet1Declination;

  /// Astronomical declination (latitude) of planet 2.
  final double planet2Declination;

  /// Exact longitudinal difference in degrees.
  final double longitudeDifference;

  /// The planet that wins the war based on traditional and astronomical calculations.
  final Planet winnerId;

  Map<String, dynamic> toJson() => {
        'planet1': planet1.displayName,
        'planet2': planet2.displayName,
        'planet1Magnitude': planet1Magnitude,
        'planet2Magnitude': planet2Magnitude,
        'planet1Declination': planet1Declination,
        'planet2Declination': planet2Declination,
        'longitudeDifference': longitudeDifference,
        'winnerId': winnerId.displayName,
      };
}
