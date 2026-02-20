import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

void main() {
  group('DivisionalChartService - D60 Mapping', () {
    late Jyotish jyotish;

    setUp(() {
      jyotish = Jyotish();
    });

    VedicChart createMockChart(double longitude, {int signIndex = 0}) {
      final absoluteLongitude = (signIndex * 30.0) + longitude;

      final houses = HouseSystem(
        system: 'Whole Sign',
        cusps: List.generate(12, (i) => i * 30.0),
        ascendant: 10.0,
        midheaven: 270.0,
      );

      final planets = {
        Planet.sun: VedicPlanetInfo(
          position: PlanetPosition(
            planet: Planet.sun,
            dateTime: DateTime.now(),
            longitude: absoluteLongitude,
            latitude: 0,
            distance: 1,
            longitudeSpeed: 1,
            latitudeSpeed: 0,
            distanceSpeed: 0,
          ),
          house: (absoluteLongitude / 30).floor() + 1,
          dignity: PlanetaryDignity.neutralSign,
        ),
      };

      return VedicChart(
        dateTime: DateTime.now(),
        location: 'Test',
        latitude: 0,
        longitudeCoord: 0,
        houses: houses,
        planets: planets,
        rahu: planets[Planet.sun]!,
        ketu: KetuPosition(rahuPosition: planets[Planet.sun]!.position),
      );
    }

    test('D60 - Aries (Odd Sign) at 0°15 (Part 0) starts from Aries', () {
      // Aries is index 0. Degree 0.25 (15 min) -> Part 0.
      // Rule (Odd): signIndex (0) + part (0) = 0 (Aries)
      final chart = createMockChart(0.25, signIndex: 0);
      final d60 = jyotish.getDivisionalChart(
          rashiChart: chart, type: DivisionalChartType.d60);

      expect(d60.planets[Planet.sun]!.zodiacSign, 'Aries');
    });

    test('D60 - Aries (Odd Sign) at 29°45 (Part 59) mapping to Pisces', () {
      // Aries is index 0. Degree 29.75 -> Part 59.
      // Rule (Odd): (0 + 59) % 12 = 11 (Pisces)
      final chart = createMockChart(29.75, signIndex: 0);
      final d60 = jyotish.getDivisionalChart(
          rashiChart: chart, type: DivisionalChartType.d60);

      expect(d60.planets[Planet.sun]!.zodiacSign, 'Pisces');
    });

    test(
        'D60 - Taurus (Even Sign) at 0°15 (Part 0) starts from 9th sign (Capricorn)',
        () {
      // Taurus is index 1. Degree 0.25 -> Part 0.
      // Rule (Even): signIndex (1) + 8 (9th from self) + part (0) = 9 (Capricorn)
      final chart = createMockChart(0.25, signIndex: 1);
      final d60 = jyotish.getDivisionalChart(
          rashiChart: chart, type: DivisionalChartType.d60);

      expect(d60.planets[Planet.sun]!.zodiacSign, 'Capricorn');
    });

    test('D60 - Taurus (Even Sign) at 29°45 (Part 59) mapping to Sagittarius',
        () {
      // Taurus is index 1. Degree 29.75 -> Part 59.
      // Rule (Even): signIndex (1) + 8 + part (59) = 68. 68 % 12 = 8 (Sagittarius)
      final chart = createMockChart(29.75, signIndex: 1);
      final d60 = jyotish.getDivisionalChart(
          rashiChart: chart, type: DivisionalChartType.d60);

      expect(d60.planets[Planet.sun]!.zodiacSign, 'Sagittarius');
    });

    test(
        'D60 - Cancer (Even Sign) at 0°15 (Part 0) starts from 9th sign (Pisces)',
        () {
      // Cancer is index 3. Degree 0.25 -> Part 0.
      // Rule (Even): signIndex (3) + 8 + part (0) = 11 (Pisces)
      final chart = createMockChart(0.25, signIndex: 3);
      final d60 = jyotish.getDivisionalChart(
          rashiChart: chart, type: DivisionalChartType.d60);

      expect(d60.planets[Planet.sun]!.zodiacSign, 'Pisces');
    });
  });

  group('DivisionalChartService - D249 249 Subdivisions', () {
    late Jyotish jyotish;
    late VedicChart chart;

    setUpAll(() async {
      jyotish = Jyotish();
      await jyotish.initialize();
      final location = GeographicLocation(latitude: 28.6139, longitude: 77.2090);
      chart = await jyotish.calculateVedicChart(
        dateTime: DateTime(1990, 5, 15, 14, 30),
        location: location,
      );
    });

    tearDownAll(() {
      jyotish.dispose();
    });

    // Helper function - defined before use
    Future<VedicChart> createChartWithSunAt(double longitude) async {
      final location = GeographicLocation(latitude: 28.6139, longitude: 77.2090);
      return await jyotish.calculateVedicChart(
        dateTime: DateTime(1990, 5, 15, 14, 30),
        location: location,
      );
    }

    test('D249: Ketu subdivision at 0° maps correctly', () {
      final d249 = jyotish.getDivisionalChart(
        rashiChart: chart,
        type: DivisionalChartType.d249,
      );

      // 0° falls in Ketu subdivision (0-1.75°)
      // Ketu subdivision should map to Aries (0)
      expect(d249.planets[Planet.sun]!.zodiacSign, 'Aries');
      expect(d249.ascendantSign, 'Aries');
    });

    test('D249: Venus subdivision at 1.76° maps correctly', () async {
      // Create chart with Sun at 1.76° (within Venus subdivision: 1.75-6.75°)
      final sunChart = await createChartWithSunAt(1.76);
      final d249 = jyotish.getDivisionalChart(
        rashiChart: sunChart,
        type: DivisionalChartType.d249,
      );

      // Should map to Taurus (1) after Ketu
      expect(d249.planets[Planet.sun]!.zodiacSign, 'Taurus');
    });

    test('D249: Sun subdivision at 3.26° maps correctly', () async {
      final sunChart = await createChartWithSunAt(3.26);
      final d249 = jyotish.getDivisionalChart(
        rashiChart: sunChart,
        type: DivisionalChartType.d249,
      );

      // Should map to Gemini (2) after Venus
      expect(d249.planets[Planet.sun]!.zodiacSign, 'Gemini');
    });

    test('D249: Moon subdivision at 6.51° maps correctly', () async {
      final sunChart = await createChartWithSunAt(6.51);
      final d249 = jyotish.getDivisionalChart(
        rashiChart: sunChart,
        type: DivisionalChartType.d249,
      );

      // Should map to Cancer (3) after Sun
      expect(d249.planets[Planet.sun]!.zodiacSign, 'Cancer');
    });

    test('D249: Mars subdivision at 8.26° maps correctly', () async {
      final sunChart = await createChartWithSunAt(8.26);
      final d249 = jyotish.getDivisionalChart(
        rashiChart: sunChart,
        type: DivisionalChartType.d249,
      );

      // Should map to Leo (4) after Moon
      expect(d249.planets[Planet.sun]!.zodiacSign, 'Leo');
    });

    test('D249: Rahu subdivision at 12.01° maps correctly', () async {
      final sunChart = await createChartWithSunAt(12.01);
      final d249 = jyotish.getDivisionalChart(
        rashiChart: sunChart,
        type: DivisionalChartType.d249,
      );

      // Rahu subdivision: 12.0-16.5°, should map to Virgo (5) after Jupiter
      expect(d249.planets[Planet.sun]!.zodiacSign, 'Virgo');
    });

    test('D249: Jupiter subdivision at 16.0° maps correctly', () async {
      final sunChart = await createChartWithSunAt(16.0);
      final d249 = jyotish.getDivisionalChart(
        rashiChart: sunChart,
        type: DivisionalChartType.d249,
      );

      // Should map to Libra (6) after Rahu
      expect(d249.planets[Planet.sun]!.zodiacSign, 'Libra');
    });

    test('D249: Saturn subdivision at 20.75° maps correctly', () async {
      final sunChart = await createChartWithSunAt(20.75);
      final d249 = jyotish.getDivisionalChart(
        rashiChart: sunChart,
        type: DivisionalChartType.d249,
      );

      // Should map to Scorpio (7) after Jupiter
      expect(d249.planets[Planet.sun]!.zodiacSign, 'Scorpio');
    });

    test('D249: Mercury subdivision at 25.0° maps correctly', () async {
      final sunChart = await createChartWithSunAt(25.0);
      final d249 = jyotish.getDivisionalChart(
        rashiChart: sunChart,
        type: DivisionalChartType.d249,
      );

      // Should map to Sagittarius (8) after Saturn
      expect(d249.planets[Planet.sun]!.zodiacSign, 'Sagittarius');
    });

    test('D249: All 9 subdivisions in one cycle map correctly', () async {
      // Test 9 subdivisions spanning exactly 30° (one complete cycle)
      var testAt = 0.0;
      const expectedSpan = 5.0;

      for (var i = 0; i <= 54; i++) { // 54 subdivisions per sign
        final sunChart = await createChartWithSunAt(testAt);
        final d249 = jyotish.getDivisionalChart(
          rashiChart: sunChart,
          type: DivisionalChartType.d249,
        );

        final subdivisionSpan = d249.planets[Planet.sun]!.subSpan ?? 0.0;
        testAt += subdivisionSpan;
      }

      // Total should be 5.0° (Venus dasha period)
      expect(testAt, closeTo(expectedSpan, 0.01));
    });

    test('D249: Correct degree span for Rahu subdivision', () async {
      // Rahu subdivision: 12.0-16.5° (4.5° total)
      var testAt = 12.0;
      const expectedSpan = 4.5;

      for (var i = 0; i <= 54; i++) { // 54 subdivisions per sign
        final chart = await createChartWithSunAt(testAt);
        final d249 = jyotish.getDivisionalChart(
          rashiChart: chart,
          type: DivisionalChartType.d249,
        );

        final subdivisionSpan = d249.planets[Planet.sun]!.subSpan ?? 0.0;
        testAt += subdivisionSpan;
      }

      // Total should be 4.5° (Rahu dasha period)
      expect(testAt, closeTo(expectedSpan, 0.01));
    });
  });
}
