import 'dart:io';
// ignore_for_file: avoid_print
import 'package:jyotish/jyotish.dart';

void main() async {
  print(' Jyotish - Divisional Charts CLI Quick Check\n');

  final currentDir = Directory.current.path;
  final ephePath = '$currentDir/native/swisseph/swisseph-master/ephe';

  try {
    final jyotish = Jyotish();
    await jyotish.initialize(ephemerisPath: ephePath);
    print(' Swiss Ephemeris initialized\n');

    final dateTime = DateTime.now();
    final location = GeographicLocation(
      latitude: 28.6139,
      longitude: 77.2090,
    );

    print(' Time: $dateTime');
    print(' Calculating D1 and D9 Charts...\n');

    final rashi = await jyotish.calculateVedicChart(
      dateTime: dateTime,
      location: location,
    );

    print(
        ' D1 Ascendant: ${rashi.ascendantSign} (${rashi.ascendant.toStringAsFixed(2)})');
    print(
        '  D1 Sun: ${rashi.getPlanet(Planet.sun)?.zodiacSign} ${rashi.getPlanet(Planet.sun)?.position.positionInSign.toStringAsFixed(2)}\n');

    final d9 = jyotish.getDivisionalChart(
      rashiChart: rashi,
      type: DivisionalChartType.d9,
    );

    print('  D9 (Navamsa) Chart:');
    print(
        ' D9 Ascendant: ${d9.ascendantSign} (${d9.ascendant.toStringAsFixed(2)})');
    print('  D9 Sun: ${d9.getPlanet(Planet.sun)?.zodiacSign}');
    print(' D9 Moon: ${d9.getPlanet(Planet.moon)?.zodiacSign}\n');

    final d10 = jyotish.getDivisionalChart(
      rashiChart: rashi,
      type: DivisionalChartType.d10,
    );

    print(' D10 (Dasamsa) Chart:');
    print(' D10 Ascendant: ${d10.ascendantSign}');
    print('  D10 Sun: ${d10.getPlanet(Planet.sun)?.zodiacSign}\n');

    print(' CLI Test Successful!');
    jyotish.dispose();
  } catch (e) {
    print(' Error: $e');
    exit(1);
  }
}
