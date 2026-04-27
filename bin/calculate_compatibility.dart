import 'dart:io';

import 'package:jyotish/jyotish.dart';

void main() async {
  final jyotish = Jyotish();
  // Using a custom path if needed, but usually default works if dll is in root
  await jyotish.initialize();

  final location = GeographicLocation(
    latitude: 31.1048,
    longitude: 77.1734,
    timezone: 'Asia/Kolkata',
  );

  // Groom: 01/11/1998 5:15 am
  final groomChart = await jyotish.calculateVedicChart(
    dateTime: DateTime(1998, 11, 1, 5, 15),
    location: location,
  );

  // Bride: 24/07/1998 4:40 am
  final brideChart = await jyotish.calculateVedicChart(
    dateTime: DateTime(1998, 7, 24, 4, 40),
    location: location,
  );

  final result = jyotish.calculateCompatibility(groomChart, brideChart);

  stdout.writeln('--- Birth Particulars ---');
  stdout.writeln('Groom Moon: ${groomChart.getPlanet(Planet.moon)?.zodiacSign} (${groomChart.getPlanet(Planet.moon)?.nakshatra})');
  stdout.writeln('Bride Moon: ${brideChart.getPlanet(Planet.moon)?.zodiacSign} (${brideChart.getPlanet(Planet.moon)?.nakshatra})');

  stdout.writeln('\n--- Compatibility Result ---');
  stdout.writeln('Total Score: ${result.totalScore}/36');
  stdout.writeln('Level: ${result.level}');
  
  stdout.writeln('\n--- Guna Breakdown ---');
  stdout.writeln('Varna: ${result.gunaScores.varna}/1');
  stdout.writeln('Vashya: ${result.gunaScores.vashya}/2');
  stdout.writeln('Tara: ${result.gunaScores.tara}/3');
  stdout.writeln('Yoni: ${result.gunaScores.yoni}/4');
  stdout.writeln('Graha Maitri: ${result.gunaScores.grahaMaitri}/5');
  stdout.writeln('Gana: ${result.gunaScores.gana}/6');
  stdout.writeln('Bhakoot: ${result.gunaScores.bhakoot}/7');
  stdout.writeln('Nadi: ${result.gunaScores.nadi}/8');

  stdout.writeln('\n--- Dosha Check ---');
  stdout.writeln('Manglik: ${result.doshaCheck.hasManglikDosha}');
  stdout.writeln('Bhakoot Dosha: ${result.doshaCheck.hasBhakootDosha}');
  stdout.writeln('Nadi Dosha: ${result.doshaCheck.hasNadiDosha}');
  
  if (result.analysis.isNotEmpty) {
    stdout.writeln('\n--- Analysis ---');
    for (var note in result.analysis) {
      stdout.writeln('- $note');
    }
  }

  jyotish.dispose();
}
