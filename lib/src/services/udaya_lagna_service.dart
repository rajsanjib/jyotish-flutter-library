import '../models/geographic_location.dart';
import '../services/ephemeris_service.dart';

/// Represents a period ruled by a specific Zodiac sign (Lagna/Ascendant).
class UdayaLagnaPeriod {
  const UdayaLagnaPeriod({
    required this.rashiIndex,
    required this.rashiName,
    required this.startTime,
    required this.endTime,
  });

  /// The zodiac sign index (0 = Aries, 11 = Pisces)
  final int rashiIndex;

  /// The Sanskrit name of the Rashi
  final String rashiName;

  /// Period start time
  final DateTime startTime;

  /// Period end time
  final DateTime endTime;
}

class UdayaLagnaService {
  UdayaLagnaService(this._ephemerisService);
  final EphemerisService _ephemerisService;

  static const List<String> rashiNames = [
    'Mesha',
    'Vrishabha',
    'Mithuna',
    'Karka',
    'Simha',
    'Kanya',
    'Tula',
    'Vrishchika',
    'Dhanu',
    'Makara',
    'Kumbha',
    'Meena'
  ];

  /// Calculates the 12 Udaya Lagna periods for a full day,
  /// starting from sunrise and ending at the next sunrise.
  Future<List<UdayaLagnaPeriod>> calculateUdayaLagnas({
    required DateTime date,
    required GeographicLocation location,
    required DateTime sunrise,
  }) async {
    final periods = <UdayaLagnaPeriod>[];
    final nextSunrise = sunrise.add(const Duration(days: 1));

    var currentTime = sunrise;

    while (currentTime.isBefore(nextSunrise)) {
      final houses = await _ephemerisService.calculateHouses(
        dateTime: currentTime,
        location: location,
      );

      final ascendant = houses['ascmc']![0];
      final currentRashiIndex = (ascendant / 30).floor();

      // Estimate minutes until next sign (approx 4 mins per degree)
      // We aim slightly before the transition (using 3.8 mins for safety)
      final degreesRemaining = 30.0 - (ascendant % 30);
      int estimatedMinsToChange = (degreesRemaining * 3.8).floor();
      if (estimatedMinsToChange < 2) estimatedMinsToChange = 2;

      var nextTime = currentTime.add(Duration(minutes: estimatedMinsToChange));

      // Step forward by 1 minute until the sign changes
      while (true) {
        if (nextTime.isAfter(nextSunrise.add(const Duration(hours: 3)))) {
          // Safety fallback if something goes wrong (should not happen)
          nextTime = nextSunrise;
          break;
        }

        final checkHouses = await _ephemerisService.calculateHouses(
          dateTime: nextTime,
          location: location,
        );
        final nextAsc = checkHouses['ascmc']![0];
        final nextRashiIndex = (nextAsc / 30).floor();

        if (nextRashiIndex != currentRashiIndex) {
          // We found the transition time
          break;
        }

        nextTime = nextTime.add(const Duration(minutes: 1));
      }

      if (nextTime.isAfter(nextSunrise)) {
        // Cap the last period at next sunrise
        nextTime = nextSunrise;
      }

      periods.add(UdayaLagnaPeriod(
        rashiIndex: currentRashiIndex,
        rashiName: rashiNames[currentRashiIndex],
        startTime: currentTime,
        endTime: nextTime,
      ));

      currentTime = nextTime;
    }

    return periods;
  }
}
