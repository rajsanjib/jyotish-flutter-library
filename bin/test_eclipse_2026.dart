import 'package:jyotish/jyotish.dart';

void main() async {
  final jyotish = Jyotish();
  print('Initializing Jyotish library...');
  await jyotish.initialize(ephemerisPath: 'ephe');

  // New Delhi Coordinates
  final delhi = GeographicLocation(
    latitude: 28.6139,
    longitude: 77.2090,
    altitude: 216,
  );

  // Date: March 3, 2026
  final eclipseDate = DateTime(2026, 3, 3);

  print('\nSearching for Lunar Eclipse on 2026-03-03 in New Delhi...');

  // Note: EphemerisService needs to be accessed.
  // Based on jyotish_test.dart, we might need to use the service directly or via jyotish.
  // Looking at jyotish.dart might help.

  try {
    // Attempt to get eclipse data
    // We'll use the service directly if possible, or see if Jyotish exposes it.
    final ephemService = EphemerisService();
    await ephemService.initialize(ephemerisPath: 'ephe');
    // Re-initialize service just in case if needed, but it should be initialized by Jyotish

    final eclipse = await ephemService.getEclipseData(
      date: eclipseDate,
      location: delhi,
      eclipseType: EclipseType.lunar,
    );

    if (eclipse == null) {
      print('No lunar eclipse found on this date.');
    } else {
      print('Eclipse Found!');
      print('Type: ${eclipse.eclipseType.name}');
      print('Peak Time: ${eclipse.date.toLocal()}');
      print('Magnitude: ${eclipse.magnitude.toStringAsFixed(4)}');
      print(
          'Penumbral Magnitude: ${eclipse.penumbralMagnitude?.toStringAsFixed(4)}');
      print('Is Visible: ${eclipse.isVisible}');

      print('\nPhase Timings (Local IST):');
      if (eclipse.penumbralStartTime != null) {
        print(
            'P1 (Penumbral Starts):  ${eclipse.penumbralStartTime!.toLocal()}');
      }
      if (eclipse.partialStartTime != null) {
        print('U1 (Umbral Starts):     ${eclipse.partialStartTime!.toLocal()}');
      }
      if (eclipse.totalStartTime != null) {
        print('U2 (Total Phase Begins): ${eclipse.totalStartTime!.toLocal()}');
      }
      print('Maximum Eclipse:        ${eclipse.maxEclipseTime!.toLocal()}');
      if (eclipse.totalEndTime != null) {
        print('U3 (Total Phase Ends):   ${eclipse.totalEndTime!.toLocal()}');
      }
      if (eclipse.partialEndTime != null) {
        print('U4 (Umbral Ends):       ${eclipse.partialEndTime!.toLocal()}');
      }
      if (eclipse.penumbralEndTime != null) {
        print('P4 (Penumbral Ends):    ${eclipse.penumbralEndTime!.toLocal()}');
      }

      print('\nSutak (Religious Timings):');
      print('Sutak Begins:           ${eclipse.sutakStartTime?.toLocal()}');
      print('Sutak Ends:             ${eclipse.sutakEndTime?.toLocal()}');

      print('\nDuration: ${eclipse.duration}');
      print('Description: ${eclipse.description}');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    jyotish.dispose();
  }
}
