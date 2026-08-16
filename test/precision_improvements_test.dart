// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:jyotish/jyotish.dart';
import 'package:path/path.dart' as p;

void main() {
  late EphemerisService ephemerisService;
  late PanchangaService panchangaService;
  late KPService kpService;

  setUpAll(() async {
    final ephemerisPath = p.absolute('ephe');
    await Jyotish().initialize(ephemerisPath: ephemerisPath);
    ephemerisService = Jyotish().ephemeris;
    panchangaService = PanchangaService(ephemerisService);
    kpService = KPService(ephemerisService);
  });

  group('Precision Improvements Tests', () {
    final location = GeographicLocation(
      latitude: 28.6139,
      longitude: 77.2090,
      altitude: 216.0,
      timezone: 'Asia/Kolkata',
    );

    test('Verify Obliquity calculation via Swiss Ephemeris', () async {
      final julianDay =
          ephemerisService.dateTimeToJulianDay(DateTime(2026, 6, 19, 12, 0));
      final (trueObliquity, meanObliquity) =
          await ephemerisService.getObliquity(julianDay);

      expect(trueObliquity, closeTo(23.436, 0.01));
      expect(meanObliquity, closeTo(23.436, 0.01));
      print('True Obliquity: $trueObliquity, Mean Obliquity: $meanObliquity');
    });

    test('Verify high-precision end times for Nakshatra and Yoga', () async {
      final dateTime = DateTime(2026, 6, 19, 12, 0);

      // Verify End Time calculations
      final nakshatraEnd = await panchangaService.getNakshatraEndTime(
        dateTime: dateTime,
        location: location,
      );
      final yogaEnd = await panchangaService.getYogaEndTime(
        dateTime: dateTime,
        location: location,
      );

      expect(nakshatraEnd, isNotNull);
      expect(yogaEnd, isNotNull);
      expect(nakshatraEnd.isAfter(dateTime), isTrue);
      expect(yogaEnd.isAfter(dateTime), isTrue);
      print('Nakshatra End Time: $nakshatraEnd, Yoga End Time: $yogaEnd');
    });

    test('Verify high-precision junctions for Nakshatra and Yoga', () async {
      final startDate = DateTime(2026, 6, 19, 0, 0);

      final panchanga = await panchangaService.calculatePanchanga(
        dateTime: startDate,
        location: location,
      );
      final currentNakshatra = panchanga.nakshatra.number;
      final currentYoga = panchanga.yoga.number;

      final nextNakshatra = (currentNakshatra % 27) + 1;
      final nextYoga = (currentYoga % 27) + 1;

      // Junction of next Nakshatra
      final nakshatraJunction = await panchangaService.getNakshatraJunction(
        targetNakshatraNumber: nextNakshatra,
        startDate: startDate,
        location: location,
      );

      // Junction of next Yoga
      final yogaJunction = await panchangaService.getYogaJunction(
        targetYogaNumber: nextYoga,
        startDate: startDate,
        location: location,
      );

      expect(nakshatraJunction, isNotNull);
      expect(yogaJunction, isNotNull);
      expect(nakshatraJunction.isAfter(startDate), isTrue);
      expect(yogaJunction.isAfter(startDate), isTrue);
      print(
          'Current Nakshatra: $currentNakshatra, Next Nakshatra Junction: $nakshatraJunction');
      print('Current Yoga: $currentYoga, Next Yoga Junction: $yogaJunction');
    });

    test('Verify KP Sub-Sub-Sub-Lord (SSSL) calculation', () async {
      // Test at a random longitude (e.g. 123.456)
      final subLord = kpService.getSubLord(123.456);
      final subSubLord = kpService.getSubSubLord(123.456);
      final subSubSubLord = kpService.getSubSubSubLord(123.456);

      expect(subLord, isNotNull);
      expect(subSubLord, isNotNull);
      expect(subSubSubLord, isNotNull);
      print(
          'Longitude 123.456 -> Sub-Lord: $subLord, Sub-Sub-Lord: $subSubLord, SSSL: $subSubSubLord');
    });

    test('Verify calculatePanchanga with atmospheric parameters', () async {
      final dateTime = DateTime(2026, 6, 19, 12, 0);
      final p1 = await panchangaService.calculatePanchanga(
        dateTime: dateTime,
        location: location,
        atmosphericPressure: 1013.25,
        atmosphericTemperature: 15.0,
      );

      expect(p1.sunrise, isNotNull);
      expect(p1.sunset, isNotNull);
      print(
          'Sunrise with standard refraction: ${p1.sunrise}, Sunset: ${p1.sunset}');
    });

    test('Verify polar region fallback for sunrise/sunset (Improvement 3)',
        () async {
      // Longyearbyen, Svalbard (Norway) - deep inside Arctic Circle
      final polarLocation = GeographicLocation(
        latitude: 78.22,
        longitude: 15.65,
        altitude: 0.0,
        timezone: 'Europe/Oslo',
      );

      // On June 21, the sun is always above the horizon (polar day)
      // Swiss Ephemeris getSunriseSunset would return null
      final date = DateTime(2026, 6, 21, 12, 0);
      final panchanga = await panchangaService.calculatePanchanga(
        dateTime: date,
        location: polarLocation,
      );

      expect(panchanga.sunrise, isNotNull);
      expect(panchanga.sunset, isNotNull);
      expect(panchanga.sunset.isAfter(panchanga.sunrise), isTrue);
      // It should be nominal 12-hour day split (6 hours before/after solar noon)
      final duration = panchanga.sunset.difference(panchanga.sunrise);
      expect(duration.inHours, equals(12));
      print(
          'Polar region fallback Sunrise: ${panchanga.sunrise}, Sunset: ${panchanga.sunset}');
    });

    test('Verify double-precision junction guardrails (Improvement 5)',
        () async {
      // Create a chart copy where Sun is extremely close to sign boundary
      final baseChart = await Jyotish().calculateVedicChart(
        dateTime: DateTime(1990, 5, 15, 14, 30),
        location: location,
        flags: CalculationFlags.kp(),
        houseSystem: 'P',
      );

      final sunInfo = baseChart.getPlanet(Planet.sun)!;
      final boundaryPos = PlanetPosition(
        planet: Planet.sun,
        dateTime: sunInfo.position.dateTime,
        longitude: 29.99999999999999, // extremely close to 30.0 (Taurus)
        latitude: sunInfo.position.latitude,
        distance: sunInfo.position.distance,
        longitudeSpeed: sunInfo.position.longitudeSpeed,
        latitudeSpeed: sunInfo.position.latitudeSpeed,
        distanceSpeed: sunInfo.position.distanceSpeed,
        declination: sunInfo.position.declination,
        isCombust: sunInfo.position.isCombust,
        isRetrograde: sunInfo.position.isRetrograde,
      );

      final boundaryPlanet = VedicPlanetInfo(
        position: boundaryPos,
        house: sunInfo.house,
        dignity: sunInfo.dignity,
        isCombust: sunInfo.isCombust,
        exaltationDegree: sunInfo.exaltationDegree,
        debilitationDegree: sunInfo.debilitationDegree,
        positionInSign: 29.99999999999999,
        subSpan: sunInfo.subSpan,
      );

      final modifiedChart = VedicChart(
        dateTime: baseChart.dateTime,
        location: baseChart.location,
        latitude: baseChart.latitude,
        longitudeCoord: baseChart.longitudeCoord,
        altitude: baseChart.altitude,
        houses: baseChart.houses,
        planets: Map<Planet, VedicPlanetInfo>.from(baseChart.planets)
          ..[Planet.sun] = boundaryPlanet,
        rahu: baseChart.rahu,
        ketu: baseChart.ketu,
        calculationFlags: baseChart.calculationFlags,
      );

      // 1. Divisional Chart D9 Navamsha test
      final divisionalChartService = DivisionalChartService();
      final d9 = divisionalChartService.calculateDivisionalChart(
        modifiedChart,
        DivisionalChartType.d9,
      );

      // Without guardrail, 29.999... would floor down to Aries, resulting in D9 sign Sagittarius (8).
      // With guardrail, it snaps to 30.0 (Taurus 0.0), resulting in D9 sign Leo (4).
      expect((d9.getPlanet(Planet.sun)!.longitude / 30).floor(), equals(9));

      // 2. KP Sign / Sign Lord transition test
      final kpData = await kpService.calculateKPData(modifiedChart);
      // Without guardrail, sign would be 1 (Aries) and signLord Mars.
      // With guardrail, it snaps to 2 (Taurus) and signLord Venus.
      expect(kpData.planetDivisions[Planet.sun]!.sign, equals(2));
      expect(
          kpData.planetDivisions[Planet.sun]!.signLord, equals(Planet.venus));
      print('Junction guardrails successfully snapped border coordinates.');
    });

    test(
        'Verify specialized dasha systems: Chara, Narayana, Kalachakra (Improvement 8)',
        () async {
      final baseChart = await Jyotish().calculateVedicChart(
        dateTime: DateTime(1990, 5, 15, 14, 30),
        location: location,
      );

      // 1. Chara Dasha
      final chara = await Jyotish().getCharaDasha(natalChart: baseChart);
      expect(chara, isNotNull);
      expect(chara.allMahadashas.length, equals(12));
      print('Chara Dasha first period: ${chara.allMahadashas.first.rashi}');

      // 2. Narayana Dasha
      final narayana = await Jyotish().getNarayanaDasha(chart: baseChart);
      expect(narayana, isNotNull);
      expect(narayana.allMahadashas.length, equals(12));
      print(
          'Narayana Dasha first period: ${narayana.allMahadashas.first.rashi}');

      // 3. Kalachakra Dasha
      final kalachakra =
          await Jyotish().getKalachakraDasha(natalChart: baseChart);
      expect(kalachakra, isNotNull);
      expect(kalachakra.allMahadashas, isNotEmpty);
      print(
          'Kalachakra Dasha first period: ${kalachakra.allMahadashas.first.rashi ?? kalachakra.allMahadashas.first.lord}');
    });

    test('Verify Muhurta suitability scoring engine (Improvement 10)',
        () async {
      final targetTime = DateTime(2026, 6, 20, 10, 0);
      final scoreResult = await Jyotish().calculateMuhurtaScore(
        dateTime: targetTime,
        location: location,
        birthNakshatraIndex: 2, // Krittika
        birthRashiIndex: 1, // Taurus
      );

      expect(scoreResult, isNotNull);
      expect(scoreResult.finalScore, greaterThanOrEqualTo(0.0));
      expect(scoreResult.finalScore, lessThanOrEqualTo(100.0));
      print(
          'Muhurta Score at $targetTime: ${scoreResult.finalScore.toStringAsFixed(1)}%');

      // Scan a 3-hour window
      final scanResults = await Jyotish().scanMuhurtaSuitability(
        startDateTime: targetTime,
        endDateTime: targetTime.add(const Duration(hours: 3)),
        location: location,
        step: const Duration(minutes: 30),
        birthNakshatraIndex: 2,
        birthRashiIndex: 1,
      );

      expect(scanResults, isNotEmpty);
      expect(scanResults.first.finalScore,
          greaterThanOrEqualTo(scanResults.last.finalScore));
      print(
          'Best Muhurta from scan: ${scanResults.first.dateTime} with score ${scanResults.first.finalScore.toStringAsFixed(1)}%');
    });
  });
}
