import '../models/geographic_location.dart';
import '../models/planet.dart';
import '../models/prashna.dart';
import '../models/rashi.dart';
import '../models/vedic_chart.dart';
import 'ephemeris_service.dart';
import 'vedic_chart_service.dart';

/// Service for Prashna (Horary) astrology calculations.
class PrashnaService {
  PrashnaService(this._ephemerisService)
      : _chartService = VedicChartService(_ephemerisService);
  final EphemerisService _ephemerisService;
  final VedicChartService _chartService;

  /// Calculates Arudha Lagna for Prashna based on a seed number (1-108 or 1-249).
  Rashi calculatePrashnaArudha(int seed) {
    // Standard rule: (seed - 1) % 12 + 1 gives the sign index
    final signIndex = (seed - 1) % 12;
    return Rashi.values[signIndex];
  }

  /// Calculates special Sphutas for a Prashna chart.
  Future<PrashnaSphutas> calculateSphutas(VedicChart chart) async {
    final moon = chart.getPlanet(Planet.moon);
    final sun = chart.getPlanet(Planet.sun);
    final rahu =
        chart.getPlanet(Planet.meanNode) ?? chart.getPlanet(Planet.trueNode);

    if (moon == null || sun == null || rahu == null) {
      throw Exception('Missing planetary data for Sphuta calculation');
    }

    // 1. Calculate Gulika Sphuta
    final gulikaLong = await calculateGulikaSphuta(chart);

    // 2. Trisphuta = Lagna + Moon + Gulika
    final trisphuta = (chart.ascendant + moon.longitude + gulikaLong) % 360;

    // 3. Chatursphuta = Trisphuta + Sun
    final chatursphuta = (trisphuta + sun.longitude) % 360;

    // 4. Panchasphuta = Chatursphuta + Rahu
    final panchasphuta = (chatursphuta + rahu.longitude) % 360;

    return PrashnaSphutas(
      trisphuta: trisphuta,
      chatursphuta: chatursphuta,
      panchasphuta: panchasphuta,
    );
  }

  /// Calculates Gulika Sphuta (Ascendant at the start of Saturn's segment).
  Future<double> calculateGulikaSphuta(VedicChart chart) async {
    final location = GeographicLocation(
      latitude: chart.latitude,
      longitude: chart.longitudeCoord,
      altitude: 0,
    );

    final sunriseSunset = await _ephemerisService.getSunriseSunset(
      date: chart.dateTime,
      location: location,
    );

    final sunrise = sunriseSunset.$1;
    final sunset = sunriseSunset.$2;

    if (sunrise == null || sunset == null) return chart.ascendant; // Fallback

    final birthTime = chart.dateTime.toUtc();
    final isDay = birthTime.isAfter(sunrise) && birthTime.isBefore(sunset);
    final weekday = chart.dateTime.weekday % 7; // 0=Sun, 1=Mon...

    int saturnPart;
    DateTime startTime;
    double partDurationSec;

    if (isDay) {
      // Daytime Gulika parts (1-indexed start point for Saturn)
      // Sun: 7, Mon: 6, Tue: 5, Wed: 4, Thu: 3, Fri: 2, Sat: 1
      saturnPart = (7 - weekday + 7) % 7;
      if (saturnPart == 0)
        saturnPart = 7; // Saturday is 1st part, Sunday is 7th
      if (weekday == 6) saturnPart = 1; // Explicit Saturday correction

      final dayDuration = sunset.difference(sunrise).inSeconds;
      partDurationSec = dayDuration / 8.0;
      startTime = sunrise
          .add(Duration(seconds: (partDurationSec * (saturnPart - 1)).round()));
    } else {
      // Nighttime Gulika starts from 5th day lord
      // Sun night starts from Thu lord sequence
      // Thu night: Thu: 1, Fri: 2, Sat: 3, Sun: 4, Mon: 5, Tue: 6, Wed: 7
      // Wait, simpler: saturnPart for night is (saturnPartDay + 4) % 7
      saturnPart = (3 - weekday + 7) % 7;
      if (saturnPart == 0) saturnPart = 7;

      final nextSunrise = sunrise.add(const Duration(days: 1));
      final nightDuration = nextSunrise.difference(sunset).inSeconds;
      partDurationSec = nightDuration / 8.0;
      startTime = sunset
          .add(Duration(seconds: (partDurationSec * (saturnPart - 1)).round()));
    }

    // Calculate Ascendant at the Gulika start time
    final gulikaChart = await _chartService.calculateChart(
      dateTime: startTime.toLocal(),
      location: location,
    );

    return gulikaChart.ascendant;
  }
}
