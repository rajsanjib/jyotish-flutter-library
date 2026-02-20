import '../models/geographic_location.dart';
import '../models/gowri_panchangam.dart';
import 'ephemeris_service.dart';

/// Service for calculating Gowri Panchangam.
///
/// Traditional South Indian electional logic dividing day and night into 8 parts each.
/// Each part is ruled by a specific quality (Gowri).
class GowriPanchangamService {
  GowriPanchangamService(this._ephemerisService);

  final EphemerisService _ephemerisService;

  // Day Sequences
  static const Map<int, List<GowriType>> _daySequences = {
    7: [
      // Sunday
      GowriType.uthi, GowriType.amrit, GowriType.rogam, GowriType.labhamu,
      GowriType.dhana, GowriType.soolai, GowriType.visham, GowriType.nirkku
    ],
    1: [
      // Monday
      GowriType.amrit, GowriType.rogam, GowriType.labhamu, GowriType.dhana,
      GowriType.soolai, GowriType.visham, GowriType.nirkku, GowriType.uthi
    ],
    2: [
      // Tuesday
      GowriType.rogam, GowriType.labhamu, GowriType.dhana, GowriType.soolai,
      GowriType.visham, GowriType.nirkku, GowriType.uthi, GowriType.amrit
    ],
    3: [
      // Wednesday
      GowriType.labhamu, GowriType.dhana, GowriType.soolai, GowriType.visham,
      GowriType.nirkku, GowriType.uthi, GowriType.amrit, GowriType.rogam
    ],
    4: [
      // Thursday
      GowriType.dhana, GowriType.soolai, GowriType.visham, GowriType.nirkku,
      GowriType.uthi, GowriType.amrit, GowriType.rogam, GowriType.labhamu
    ],
    5: [
      // Friday
      GowriType.soolai, GowriType.visham, GowriType.nirkku, GowriType.uthi,
      GowriType.amrit, GowriType.rogam, GowriType.labhamu, GowriType.dhana
    ],
    6: [
      // Saturday
      GowriType.visham, GowriType.nirkku, GowriType.uthi, GowriType.amrit,
      GowriType.rogam, GowriType.labhamu, GowriType.dhana, GowriType.soolai
    ],
  };

  // Night sequence starts with the 6th Gowri of the Day sequence.
  // We can dynamically generate this rather than hardcoding.
  List<GowriType> _getNightSequence(int weekday) {
    final daySeq = _daySequences[weekday];
    if (daySeq == null) return [];

    // 6th element is at index 5.
    // Night sequence is the same cycle, just starting from that element?
    // OR is it a completely different order?
    // Re-verified sources: The order of Gowris is fixed/cyclical?
    // Actually, looking at the Day Sequences:
    // Sun: Uthi, Amrit, Rogam, Labham, Dhana, Soolai, Visham, Nirkku
    // Mon: Amrit, Rogam... (Shifted by 1?)
    // Sun(Uthi) -> Mon(Amrit) -> Tue(Rogam) -> Wed(Labham) -> Thu(Dhana) -> Fri(Soolai) -> Sat(Visham).
    // Yes, it's a cyclic shift of the SAME standard list:
    // Standard List: Uthi, Amrit, Rogam, Labham, Dhana, Soolai, Visham, Nirkku.

    // So Night sequence is just the same Standard List, starting at a specific offset.
    // Rule: Night starts with 6th from Day start.
    // Example Sunday: Day starts Uthi (Index 0). 6th is Soolai (Index 5).
    // Sunday Night should start with Soolai.
    // Let's verify standard list order:
    // Uthi, Amrit, Rogam, Labham, Dhana, Soolai, Visham, Nirkku.

    final standardList = [
      GowriType.uthi,
      GowriType.amrit,
      GowriType.rogam,
      GowriType.labhamu,
      GowriType.dhana,
      GowriType.soolai,
      GowriType.visham,
      GowriType.nirkku
    ];

    // Determine Day Start Index
    final dayStarts = {
      7: GowriType.uthi, // Sun
      1: GowriType.amrit, // Mon
      2: GowriType.rogam, // Tue
      3: GowriType.labhamu, // Wed
      4: GowriType.dhana, // Thu
      5: GowriType.soolai, // Fri
      6: GowriType.visham // Sat
    };

    final dayStartGowri = dayStarts[weekday];
    int dayStartIndex = standardList.indexOf(dayStartGowri!);

    // Night starts at (DayStart + 5) % 8  (6th item)
    int nightStartIndex = (dayStartIndex + 5) % 8;

    // Construct the sequence
    return List.generate(8, (i) => standardList[(nightStartIndex + i) % 8]);
  }

  /// Calculates current Gowri Panchangam period.
  Future<GowriPanchangamInfo> getCurrentGowriPanchangam({
    required DateTime dateTime,
    required GeographicLocation location,
  }) async {
    final sunriseSunset = await _ephemerisService.getSunriseSunset(
      date: dateTime,
      location: location,
    );

    var sunrise = sunriseSunset.$1;
    var sunset = sunriseSunset.$2;
    if (sunrise == null || sunset == null) throw Exception('No sunrise data');

    DateTime effectiveSunrise = sunrise;
    DateTime effectiveSunset = sunset;

    // Handle previous day logic if before sunrise
    if (dateTime.isBefore(sunrise)) {
      final prevDate = dateTime.subtract(const Duration(days: 1));
      final prevInfo = await _ephemerisService.getSunriseSunset(
          date: prevDate, location: location);
      if (prevInfo.$1 != null) {
        effectiveSunrise = prevInfo.$1!;
        effectiveSunset = prevInfo.$2!;
      }
    }

    if (dateTime.isAfter(effectiveSunset) ||
        dateTime.isBefore(effectiveSunrise)) {
      // Nighttime
      final nextDate = effectiveSunrise.add(const Duration(days: 1));
      final nextInfo = await _ephemerisService.getSunriseSunset(
          date: nextDate, location: location);
      final nextSunrise =
          nextInfo.$1 ?? effectiveSunrise.add(const Duration(hours: 24));

      final nightDuration = nextSunrise.difference(effectiveSunset);
      final segmentLength = nightDuration.inMicroseconds / 8;
      final timeSinceSunset =
          dateTime.difference(effectiveSunset).inMicroseconds;
      final segmentIndex = (timeSinceSunset / segmentLength).floor();

      final adjustedIndex = segmentIndex >= 8 ? 7 : segmentIndex;
      final weekday = effectiveSunrise.weekday;

      // Use dynamically generated night sequence
      final nightSequence = _getNightSequence(weekday);
      final type = nightSequence[adjustedIndex];

      final startTime = effectiveSunset
          .add(Duration(microseconds: (segmentLength * adjustedIndex).round()));
      final endTime = effectiveSunset.add(Duration(
          microseconds: (segmentLength * (adjustedIndex + 1)).round()));

      return GowriPanchangamInfo(
        type: type,
        startTime: startTime,
        endTime: endTime,
        isDaytime: false,
        periodNumber: adjustedIndex + 1,
      );
    } else {
      // Daytime
      final dayDuration = effectiveSunset.difference(effectiveSunrise);
      final segmentLength = dayDuration.inMicroseconds / 8;
      final timeSinceSunrise =
          dateTime.difference(effectiveSunrise).inMicroseconds;
      final segmentIndex = (timeSinceSunrise / segmentLength).floor();

      final adjustedIndex = segmentIndex >= 8 ? 7 : segmentIndex;
      final weekday = effectiveSunrise.weekday;
      final type = _daySequences[weekday]![adjustedIndex];

      final startTime = effectiveSunrise
          .add(Duration(microseconds: (segmentLength * adjustedIndex).round()));
      final endTime = effectiveSunrise.add(Duration(
          microseconds: (segmentLength * (adjustedIndex + 1)).round()));

      return GowriPanchangamInfo(
        type: type,
        startTime: startTime,
        endTime: endTime,
        isDaytime: true,
        periodNumber: adjustedIndex + 1,
      );
    }
  }
}
