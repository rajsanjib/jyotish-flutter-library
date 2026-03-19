import 'package:jyotish/jyotish.dart';

void main() async {
  final ephemerisService = EphemerisService();
  await ephemerisService.initialize(ephemerisPath: 'ephe');

  // New Delhi
  final location = GeographicLocation(
    latitude: 28.6139,
    longitude: 77.2090,
    timezone: 'Asia/Kolkata',
  );

  print(
      'Searching for visible solar eclipses in New Delhi around August 2, 2027...');

  final startDate = DateTime.utc(2027, 8, 1);
  final endDate = DateTime.utc(2027, 8, 5);

  DateTime current = startDate;
  int found = 0;

  while (current.isBefore(endDate)) {
    final eclipse = await ephemerisService.getEclipseData(
      date: current,
      location: location,
      eclipseType: EclipseType.solar,
    );

    if (eclipse != null && eclipse.isVisible) {
      final localTime = eclipse.date.toLocal();
      print('\nVisible Solar Eclipse Found:');
      print('Date (Max): ${localTime}');
      print('Magnitude:  ${eclipse.magnitude.toStringAsFixed(4)}');
      print('Description:${eclipse.description}');

      final dur = eclipse.duration;
      if (dur != null) {
        final h = dur.inHours.toString().padLeft(2, '0');
        final m = (dur.inMinutes % 60).toString().padLeft(2, '0');
        final s = (dur.inSeconds % 60).toString().padLeft(2, '0');
        print('Duration:   ${h}h ${m}m ${s}s');
      }
      print('Start Time: ${eclipse.startTime?.toLocal()}');
      print('End Time:   ${eclipse.endTime?.toLocal()}');

      print('--- Religious Timings (Sutak) ---');
      print('Sutak Begins:               ${eclipse.sutakStartTime?.toLocal()}');
      print('Sutak Ends:                 ${eclipse.sutakEndTime?.toLocal()}');
      print(
          'Sutak for Kids/Elderly/Sick:${eclipse.sutakForSensitive?.toLocal()}');

      found++;
    }

    current = current.add(const Duration(days: 1));
  }

  print('\nSearch complete. Found $found visible solar eclipses.');
  ephemerisService.dispose();
}
