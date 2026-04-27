import 'dart:io';

import 'package:jyotish/jyotish.dart';

void main() async {
  final jyotish = Jyotish();
  await jyotish.initialize(ephemerisPath: 'ephe');

  final chart = await jyotish.calculateVedicChart(
    dateTime: DateTime.utc(1947, 8, 14, 18, 30),
    location: GeographicLocation(latitude: 28.6139, longitude: 77.2090),
    flags: CalculationFlags.traditionalist(),
  );

  final aspects = jyotish.getChartAspects(chart);
  
  stdout.writeln('Total aspects: ${aspects.length}');
  for (final a in aspects) {
    if (a.aspectingPlanet == Planet.mars || a.aspectingPlanet == Planet.saturn || a.aspectingPlanet == Planet.jupiter) {
      stdout.writeln('${a.aspectingPlanet.displayName} -> ${a.aspectedPlanet.displayName}: ${a.type.english}');
    }
  }
}
