// ignore_for_file: avoid_print
import 'dart:io';
import 'package:jyotish/jyotish.dart';

/// Calculate planetary positions for July 28, 1994 using Lahiri ayanamsa.
///
/// Run with: dart run scripts/calculate_1994.dart
Future<void> main() async {
  print('🌟 Calculating Planetary Positions');
  print('📅 Date: July 28, 1994');
  print('🔮 Ayanamsa: Lahiri (Sidereal/Vedic)');
  print('=' * 70);

  // Set library path for macOS
  const dylibPath =
      '/Users/sanjibacharya/Developer/jyotish/native/swisseph/swisseph-master/libswisseph.dylib';
  if (!File(dylibPath).existsSync()) {
    print('❌ Error: Swiss Ephemeris library not found at: $dylibPath');
    print('Please run the installation steps first.');
    exit(1);
  }

  // Note: The library path is now handled in the bindings automatically

  final jyotish = Jyotish();

  try {
    print('\n📚 Initializing Swiss Ephemeris...');

    // Set ephemeris path
    const ephePath =
        '/Users/sanjibacharya/Developer/jyotish/native/swisseph/swisseph-master/ephe';
    await jyotish.initialize(ephemerisPath: ephePath);

    print('✅ Initialization successful!\n');

    // Date: July 28, 1994, 10:50 AM Kathmandu Time (NPT = UTC+5:45)
    // Converting to UTC: 10:50 - 5:45 = 5:05 AM UTC
    final dateTime = DateTime.utc(1994, 7, 28, 5, 5);

    // Location: Kathmandu, Nepal
    final location = GeographicLocation(
      latitude: 27.7172, // Kathmandu latitude
      longitude: 85.3240, // Kathmandu longitude
      altitude: 1400, // Kathmandu altitude (meters above sea level)
    );

    print('Date/Time: ${dateTime.toIso8601String()} (UTC)');
    print('           1994-07-28 10:50:00 (Kathmandu Local Time)');
    print('Location: Kathmandu, Nepal');
    print('          ${location.toString()}\n');
    print('=' * 70);

    // Calculate Vedic chart to get ascendant
    print('ASCENDANT (LAGNA)');
    print('=' * 70);
    print('');

    final chart = await jyotish.calculateVedicChart(
      dateTime: dateTime,
      location: location,
    );

    print('Ascendant Sign:   ${chart.ascendantSign}');
    print('Ascendant Degree: ${chart.ascendant.toStringAsFixed(6)}°');
    print('');
    print('=' * 70);
    print('');

    // Calculate all planetary positions (sidereal with Lahiri ayanamsa by default)
    final positions = await jyotish.getAllPlanetPositions(
      dateTime: dateTime,
      location: location,
    );

    print('PLANETARY POSITIONS (Sidereal - Lahiri Ayanamsa)');
    print('=' * 70);
    print('');
    print('${'Planet'.padRight(12)} ${'Sign & Position'.padRight(28)} '
        '${'Nakshatra'.padRight(18)} ${'Pada'.padRight(4)} ${'Retro'}');
    print('-' * 70);

    for (final entry in positions.entries) {
      final planet = entry.key;
      final pos = entry.value;
      final retro = pos.isRetrograde ? ' (R)' : '    ';

      print('${planet.displayName.padRight(12)} '
          '${pos.formattedPosition.padRight(28)} '
          '${pos.nakshatra.padRight(18)} '
          '${pos.nakshatraPada.toString().padRight(4)} '
          '$retro');
    }

    print('\n${'=' * 70}');
    print('DETAILED INFORMATION');
    print('=' * 70);
    print('');

    for (final entry in positions.entries) {
      final planet = entry.key;
      final pos = entry.value;

      print('${planet.displayName}:');
      print('  Longitude:        ${pos.longitude.toStringAsFixed(6)}°');
      print('  Latitude:         ${pos.latitude.toStringAsFixed(6)}°');
      print('  Distance:         ${pos.distance.toStringAsFixed(6)} AU');
      print('  Zodiac Sign:      ${pos.zodiacSign}');
      print('  Position in Sign: ${pos.positionInSign.toStringAsFixed(4)}°');
      print('  Nakshatra:        ${pos.nakshatra} (Pada ${pos.nakshatraPada})');
      print(
          '  Speed:            ${pos.longitudeSpeed.toStringAsFixed(4)}°/day');
      print('  Retrograde:       ${pos.isRetrograde ? 'Yes' : 'No'}');
      print('');
    }

    print('=' * 70);
    print('✅ Calculation completed successfully!');
    print('=' * 70);
  } catch (e, stackTrace) {
    print('\n❌ Error: $e');
    print('Stack trace: $stackTrace');
    print('\n⚠️  Make sure Swiss Ephemeris library is properly installed!');
    exit(1);
  } finally {
    jyotish.dispose();
  }
}
