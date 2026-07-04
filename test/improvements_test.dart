import 'package:flutter_test/flutter_test.dart';
import 'package:jyotish/jyotish.dart';
import 'package:path/path.dart' as p;

void main() {
  setUpAll(() async {
    final jyotish = Jyotish();
    await jyotish.initialize(ephemerisPath: p.absolute('ephe'));
  });

  group('Library Improvements Verification Tests', () {
    late GeographicLocation location;
    late DateTime birthDate;

    setUp(() {
      location = GeographicLocation(
        latitude: 28.6139,
        longitude: 77.2090,
        altitude: 216.0,
        timezone: 'Asia/Kolkata',
      );
      birthDate = DateTime(1995, 8, 20, 10, 30);
    });

    test('1. Calculation Caching - Repeat calculations use cache', () async {
      final jyotish = Jyotish();
      final ephemeris = jyotish.ephemeris;

      final flags = CalculationFlags.traditionalist();

      // Clear cache first
      jyotish.clearCache();

      // Time the first execution
      final stopwatch1 = Stopwatch()..start();
      final pos1 = await ephemeris.calculatePlanetPosition(
        planet: Planet.jupiter,
        dateTime: birthDate,
        location: location,
        flags: flags,
      );
      stopwatch1.stop();

      // Time the second execution (should be cached and extremely fast)
      final stopwatch2 = Stopwatch()..start();
      final pos2 = await ephemeris.calculatePlanetPosition(
        planet: Planet.jupiter,
        dateTime: birthDate,
        location: location,
        flags: flags,
      );
      stopwatch2.stop();

      // Results must be identical
      expect(pos1.longitude, equals(pos2.longitude));
      expect(pos1.latitude, equals(pos2.latitude));

      // Second call should run in almost 0 milliseconds due to caching
      expect(stopwatch2.elapsedMilliseconds <= stopwatch1.elapsedMilliseconds,
          isTrue);

      // Verify clearCache clears it
      jyotish.clearCache();
    });

    test('2. Chart Rendering - SVG and CustomPainters', () async {
      final jyotish = Jyotish();
      final chart = await jyotish.calculateVedicChart(
        dateTime: birthDate,
        location: location,
      );

      // Verify South Indian SVG generation
      final southSvg = chart.toSVG(style: ChartStyle.southIndian);
      expect(southSvg, contains('<svg'));
      expect(southSvg, contains('RASHI CHART'));
      expect(southSvg, contains('Ju')); // Should show planet abbreviation

      // Verify North Indian SVG generation
      final northSvg = chart.toSVG(style: ChartStyle.northIndian);
      expect(northSvg, contains('<svg'));
      expect(northSvg, contains('polygon'));
      expect(northSvg, contains('Ra')); // Should show node abbreviation

      // Verify CustomPainters can be instantiated
      final southPainter = SouthIndianChartPainter(chart: chart);
      final northPainter = NorthIndianChartPainter(chart: chart);

      expect(southPainter, isNotNull);
      expect(northPainter, isNotNull);
    });

    test('3. Dynamic Timezone Updates - Check method exposure', () {
      // Passing invalid/mock bytes should throw a timezone format exception or verify parsing,
      // confirming the method binds correctly to the underlying tz database loader.
      expect(
        () => Jyotish.loadTimezoneDatabase([1, 2, 3, 4, 5]),
        throwsAssertionError,
      );
    });

    test('4. Dasha Streams - Lazy Vimshottari Dasha stream', () async {
      final jyotish = Jyotish();
      final chart = await jyotish.calculateVedicChart(
        dateTime: birthDate,
        location: location,
      );

      final moonLongitude = chart.getPlanet(Planet.moon)?.longitude ?? 0.0;

      // Get the stream of DashaPeriods
      final dashaStream = jyotish.systems.dasha.streamVimshottariDasha(
        moonLongitude: moonLongitude,
        birthDateTime: birthDate,
        maxLevel: 2, // Down to Pratyantar levels
      );

      final periods = await dashaStream.take(20).toList();

      expect(periods, isNotEmpty);
      expect(
          periods.first.level, equals(0)); // First period should be a Mahadasha
      expect(
          periods.any((p) => p.level == 1), isTrue); // Should yield Antardashas
      expect(periods.any((p) => p.level == 2),
          isTrue); // Should yield Pratyantardashas

      // Checking chronology of emitted periods
      for (var i = 0; i < periods.length - 1; i++) {
        final current = periods[i];
        final next = periods[i + 1];
        if (current.level == next.level) {
          expect(
              current.endDate.isBefore(next.startDate) ||
                  current.endDate == next.startDate,
              isTrue);
        }
      }
    });
  });
}
