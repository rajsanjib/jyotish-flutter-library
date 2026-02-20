import 'dart:io';
// ignore_for_file: avoid_print
import 'package:jyotish/jyotish.dart';

/// Example demonstrating Vedic astrology chart calculation
/// For the date: July 28, 1994 at 12:00 PM UTC
/// Location: New Delhi, India (28.6139°N, 77.2090°E)
void main() async {
  print('🔮 Jyotish - Vedic Chart Calculation Example\n');

  // Get the ephemeris path
  final currentDir = Directory.current.path;
  final ephePath = '$currentDir/native/swisseph/swisseph-master/ephe';

  try {
    // Initialize the library
    final jyotish = Jyotish();
    await jyotish.initialize(ephemerisPath: ephePath);
    print('✅ Swiss Ephemeris initialized\n');

    // Set the date and location
    final dateTime = DateTime.utc(2000, 6, 19, 12, 0);
    final location = GeographicLocation(
      latitude: 28.6139, // New Delhi latitude
      longitude: 77.2090, // New Delhi longitude
      altitude: 216.0, // meters above sea level
    );

    print('📅 Date: ${dateTime.toLocal()}');
    print('📍 Location: New Delhi, India');
    print('   Latitude: ${location.latitudeDMS}');
    print('   Longitude: ${location.longitudeDMS}\n');

    // Calculate the Vedic chart
    print('⏳ Calculating Vedic chart...\n');
    final chart = await jyotish.calculateVedicChart(
      dateTime: dateTime,
      location: location,
      includeOuterPlanets:
          false, // Traditional Vedic astrology uses only 7 planets
    );

    // Display chart information
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('                    VEDIC BIRTH CHART                  ');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    // Ascendant (Lagna)
    print('🌅 ASCENDANT (LAGNA)');
    print('   Sign: ${chart.ascendantSign}');
    print('   Degree: ${chart.houses.ascendant.toStringAsFixed(2)}°\n');

    // Display all planets
    print('🌟 PLANETARY POSITIONS\n');

    final planetOrder = [
      Planet.sun,
      Planet.moon,
      Planet.mars,
      Planet.mercury,
      Planet.jupiter,
      Planet.venus,
      Planet.saturn,
    ];

    for (final planet in planetOrder) {
      final planetInfo = chart.getPlanet(planet);
      if (planetInfo != null) {
        _displayPlanetInfo(planet.name, planetInfo);
      }
    }

    // Rahu and Ketu
    print('   ${_formatPlanetName('Rahu')}');
    print(
        '      Position: ${chart.rahu.position.zodiacSign} ${chart.rahu.position.longitude.toStringAsFixed(2)}°');
    print('      House: ${chart.rahu.house}');
    print('      Nakshatra: ${chart.rahu.nakshatra} (Pada ${chart.rahu.pada})');
    print(
        '      Retrograde: ${chart.rahu.position.isRetrograde ? 'Yes ⟲' : 'No'}');
    print('      Dignity: ${chart.rahu.dignity.english}');
    print('');

    print('   ${_formatPlanetName('Ketu')}');
    print(
        '      Position: ${chart.ketu.zodiacSign} ${chart.ketu.longitude.toStringAsFixed(2)}°');
    print(
        '      House: ${chart.houses.getHouseForLongitude(chart.ketu.longitude)}');
    print(
        '      Nakshatra: ${chart.ketu.nakshatra} (Pada ${chart.ketu.nakshatraPada})');
    print('      Retrograde: ${chart.ketu.isRetrograde ? 'Yes ⟲' : 'No'}');

    print('');

    // House cusps
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    print('🏠 HOUSE CUSPS\n');
    for (int i = 0; i < 12; i++) {
      final houseNum = i + 1;
      final cusp = chart.houses.cusps[i];
      final sign = _getZodiacSign(cusp);
      print('   House $houseNum: ${cusp.toStringAsFixed(2)}° ($sign)');
    }

    // Planetary strengths summary
    print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    print('💪 PLANETARY DIGNITIES SUMMARY\n');

    final exaltedPlanets = chart.exaltedPlanets;
    final debilitatedPlanets = chart.debilitatedPlanets;
    final combustPlanets = chart.combustPlanets;

    if (exaltedPlanets.isNotEmpty) {
      print(
          '   ⭐ Exalted: ${exaltedPlanets.map((p) => p.planet.name).join(', ')}');
    }
    if (debilitatedPlanets.isNotEmpty) {
      print(
          '   ⬇️  Debilitated: ${debilitatedPlanets.map((p) => p.planet.name).join(', ')}');
    }
    if (combustPlanets.isNotEmpty) {
      print(
          '   🔥 Combust: ${combustPlanets.map((p) => p.planet.name).join(', ')}');
    }
    if (exaltedPlanets.isEmpty &&
        debilitatedPlanets.isEmpty &&
        combustPlanets.isEmpty) {
      print('   No planets in exaltation, debilitation, or combustion.');
    }

    print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    print('✨ Chart calculation completed successfully!\n');
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}

void _displayPlanetInfo(String name, VedicPlanetInfo info) {
  print('   ${_formatPlanetName(name)}');
  print(
      '      Position: ${info.position.zodiacSign} ${info.position.longitude.toStringAsFixed(2)}°');
  print('      House: ${info.house}');
  print('      Nakshatra: ${info.nakshatra} (Pada ${info.pada})');
  print('      Retrograde: ${info.position.isRetrograde ? 'Yes ⟲' : 'No'}');
  print('      Dignity: ${info.dignity.english}');
  if (info.isCombust) {
    print(
        '      ⚠️  Combust (within ${_getCombustionDegrees(info.planet)}° of Sun)');
  }
  print('');
}

String _formatPlanetName(String name) {
  final emoji = _getPlanetEmoji(name);
  return '$emoji $name'.toUpperCase();
}

String _getPlanetEmoji(String name) {
  switch (name.toLowerCase()) {
    case 'sun':
      return '☉';
    case 'moon':
      return '☽';
    case 'mars':
      return '♂';
    case 'mercury':
      return '☿';
    case 'jupiter':
      return '♃';
    case 'venus':
      return '♀';
    case 'saturn':
      return '♄';
    case 'rahu':
      return '☊';
    case 'ketu':
      return '☋';
    default:
      return '🌟';
  }
}

double _getCombustionDegrees(Planet planet) {
  switch (planet) {
    case Planet.moon:
      return 12.0;
    case Planet.mars:
      return 17.0;
    case Planet.mercury:
      return 14.0;
    case Planet.jupiter:
      return 11.0;
    case Planet.venus:
      return 10.0;
    case Planet.saturn:
      return 15.0;
    default:
      return 0.0;
  }
}

String _getZodiacSign(double longitude) {
  final signs = [
    'Aries',
    'Taurus',
    'Gemini',
    'Cancer',
    'Leo',
    'Virgo',
    'Libra',
    'Scorpio',
    'Sagittarius',
    'Capricorn',
    'Aquarius',
    'Pisces'
  ];
  final signIndex = (longitude / 30).floor() % 12;
  return signs[signIndex];
}
