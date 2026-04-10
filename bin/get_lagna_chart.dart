// ignore_for_file: avoid_print
import 'package:jyotish/jyotish.dart';

void main() async {
  final jyotish = Jyotish();
  
  try {
    // Initialize the library with the path to ephemeris data
    await jyotish.initialize(ephemerisPath: 'e:/jyotish-flutter-library-fork/ephe');

    // Define the birth details (Updated to 24/07/1998)
    final dob = DateTime(1998, 7, 24, 4, 40);
    final location = GeographicLocation(
      latitude: 31.1048, // Shimla
      longitude: 77.1734,
    );

    // Convert local time to UTC for higher precision
    final utcTime = Jyotish.localToUtc(dob, 'Asia/Kolkata');

    // Explicitly use Lahiri Ayanamsa
    final flags = CalculationFlags.traditionalist();

    // Calculate the Vedic Chart (D1)
    final chart = await jyotish.calculateVedicChart(
      dateTime: utcTime,
      location: location,
      flags: flags,
    );

    // Get Ayanamsa for the date
    final ephemerisService = EphemerisService();
    await ephemerisService.initialize(ephemerisPath: 'e:/jyotish-flutter-library-fork/ephe');
    final ayanamsa = await ephemerisService.getAyanamsa(
      dateTime: utcTime,
      mode: SiderealMode.lahiri,
    );

    print('\n--- Lagna (D1) Chart (Lahiri Ayanamsa) ---');
    print('Birth Date: 24/07/1998');
    print('Birth Time: 4:40 AM (IST)');
    print('Location: Shimla, Himachal Pradesh');
    print('Ayanamsa used: ${ayanamsa.toStringAsFixed(4)}°');
    print('--------------------------------------------------');
    print('Ascendant (Lagna): ${chart.ascendantSign} (${(chart.ascendant % 30).toStringAsFixed(2)}°)');
    print('Total Longitude: ${chart.ascendant.toStringAsFixed(2)}°');
    print('--------------------------------------------------');
    print('Planetary Positions:');
    print('--------------------------------------------------');
    print('Planet\t\tSign\t\tDegree\t\tHouse\t\tNakshatra');
    print('--------------------------------------------------');

    final planets = [
      Planet.sun,
      Planet.moon,
      Planet.mars,
      Planet.mercury,
      Planet.jupiter,
      Planet.venus,
      Planet.saturn,
    ];

    for (final planet in planets) {
      final info = chart.getPlanet(planet);
      if (info != null) {
        final planetName = planet.displayName.padRight(12);
        final sign = info.zodiacSign.padRight(12);
        final degree = (info.position.longitude % 30).toStringAsFixed(2).padRight(10);
        final house = info.house.toString().padRight(10);
        final nakshatra = info.nakshatra;
        print('$planetName\t$sign\t$degree\t$house\t$nakshatra');
      }
    }

    // Handle Rahu/Ketu
    final rahuInfo = chart.rahu;
    print('${Planet.meanNode.displayName.padRight(12)}\t${rahuInfo.zodiacSign.padRight(12)}\t${(rahuInfo.position.longitude % 30).toStringAsFixed(2).padRight(10)}\t${rahuInfo.house.toString().padRight(10)}\t${rahuInfo.nakshatra}');
    
    final ketuInfo = chart.ketu;
    print('Ketu\t\t${ketuInfo.zodiacSign.padRight(12)}\t${(ketuInfo.longitude % 30).toStringAsFixed(2).padRight(10)}\t${chart.houses.getHouseForLongitude(ketuInfo.longitude).toString().padRight(10)}\t${ketuInfo.nakshatra}');

    print('--------------------------------------------------');
  } catch (e, stackTrace) {
    print('Error: $e');
    print('Stack trace: $stackTrace');
  }
}
