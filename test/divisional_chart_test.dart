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

    test('D60 - Aries (Odd Sign) at 015 (Part 0) starts from Aries', () {
      // Aries is index 0. Degree 0.25 (15 min) -> Part 0.
      // Rule (Odd): signIndex (0) + part (0) = 0 (Aries)
      final chart = createMockChart(0.25, signIndex: 0);
      final d60 = jyotish.getDivisionalChart(
          rashiChart: chart, type: DivisionalChartType.d60);

      expect(d60.planets[Planet.sun]!.zodiacSign, 'Aries');
    });

    test('D60 - Aries (Odd Sign) at 2945 (Part 59) mapping to Pisces', () {
      // Aries is index 0. Degree 29.75 -> Part 59.
      // Rule (Odd): (0 + 59) % 12 = 11 (Pisces)
      final chart = createMockChart(29.75, signIndex: 0);
      final d60 = jyotish.getDivisionalChart(
          rashiChart: chart, type: DivisionalChartType.d60);

      expect(d60.planets[Planet.sun]!.zodiacSign, 'Pisces');
    });

    test(
        'D60 - Taurus (Even Sign) at 015 (Part 0) starts from 9th sign (Capricorn)',
        () {
      // Taurus is index 1. Degree 0.25 -> Part 0.
      // Rule (Even): signIndex (1) + 8 (9th from self) + part (0) = 9 (Capricorn)
      final chart = createMockChart(0.25, signIndex: 1);
      final d60 = jyotish.getDivisionalChart(
          rashiChart: chart, type: DivisionalChartType.d60);

      expect(d60.planets[Planet.sun]!.zodiacSign, 'Capricorn');
    });

    test('D60 - Taurus (Even Sign) at 2945 (Part 59) mapping to Sagittarius',
        () {
      // Taurus is index 1. Degree 29.75 -> Part 59.
      // Rule (Even): signIndex (1) + 8 + part (59) = 68. 68 % 12 = 8 (Sagittarius)
      final chart = createMockChart(29.75, signIndex: 1);
      final d60 = jyotish.getDivisionalChart(
          rashiChart: chart, type: DivisionalChartType.d60);

      expect(d60.planets[Planet.sun]!.zodiacSign, 'Sagittarius');
    });

    test(
        'D60 - Cancer (Even Sign) at 015 (Part 0) starts from 9th sign (Pisces)',
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

    // Helper to create a mock chart with Sun at a given absolute longitude
    // Uses CalculationFlags with KP ayanamsa (required by D249)
    VedicChart createD249MockChart(
      double sunLongitude, {
      SiderealMode siderealMode = SiderealMode.krishnamurtiVP291,
    }) {
      final houses = HouseSystem(
        system: 'Whole Sign',
        cusps: List.generate(12, (i) => i * 30.0),
        ascendant: 0.0,
        midheaven: 270.0,
      );
      final sunPos = PlanetPosition(
        planet: Planet.sun,
        dateTime: DateTime(1990, 5, 15),
        longitude: sunLongitude,
        latitude: 0,
        distance: 1,
        longitudeSpeed: 1,
        latitudeSpeed: 0,
        distanceSpeed: 0,
      );
      final sunInfo = VedicPlanetInfo(
        position: sunPos,
        house: (sunLongitude / 30).floor() + 1,
        dignity: PlanetaryDignity.neutralSign,
      );
      return VedicChart(
        dateTime: DateTime(1990, 5, 15),
        location: 'Test',
        latitude: 0,
        longitudeCoord: 0,
        houses: houses,
        planets: {Planet.sun: sunInfo},
        rahu: sunInfo,
        ketu: KetuPosition(rahuPosition: sunPos),
        calculationFlags: CalculationFlags(siderealMode: siderealMode),
      );
    }

    setUpAll(() async {
      jyotish = Jyotish();
      await jyotish.initialize(ephemerisPath: 'ephe');
    });

    tearDownAll(() {
      jyotish.dispose();
    });

    // D249 subdivision ranges for ODD sign (Aries, signIndex=0, startSign=0):
    // Ketu:    0.00 -  1.75  Aries (0)
    // Venus:   1.75 -  6.75  Taurus (1)
    // Sun:     6.75 -  8.25  Gemini (2)
    // Moon:    8.25 - 10.75  Cancer (3)
    // Mars:   10.75 - 12.50  Leo (4)
    // Rahu:   12.50 - 17.00  Virgo (5)
    // Jupiter:17.00 - 21.00  Libra (6)
    // Saturn: 21.00 - 25.75  Scorpio (7)
    // Mercury:25.75 - 30.00  Sagittarius (8)

    test('D249: Ketu subdivision at 0.5 maps to Aries', () {
      final d249 = jyotish.getDivisionalChart(
        rashiChart: createD249MockChart(0.5),
        type: DivisionalChartType.d249,
      );
      expect(d249.planets[Planet.sun]!.zodiacSign, 'Aries');
    });

    test('D249: Venus subdivision at 2.0 maps to Taurus', () {
      final d249 = jyotish.getDivisionalChart(
        rashiChart: createD249MockChart(2.0),
        type: DivisionalChartType.d249,
      );
      expect(d249.planets[Planet.sun]!.zodiacSign, 'Taurus');
    });

    test('D249: Sun subdivision at 7.0 maps to Gemini', () {
      final d249 = jyotish.getDivisionalChart(
        rashiChart: createD249MockChart(7.0),
        type: DivisionalChartType.d249,
      );
      expect(d249.planets[Planet.sun]!.zodiacSign, 'Gemini');
    });

    test('D249: Moon subdivision at 9.0 maps to Cancer', () {
      final d249 = jyotish.getDivisionalChart(
        rashiChart: createD249MockChart(9.0),
        type: DivisionalChartType.d249,
      );
      expect(d249.planets[Planet.sun]!.zodiacSign, 'Cancer');
    });

    test('D249: Mars subdivision at 11.0 maps to Leo', () {
      final d249 = jyotish.getDivisionalChart(
        rashiChart: createD249MockChart(11.0),
        type: DivisionalChartType.d249,
      );
      expect(d249.planets[Planet.sun]!.zodiacSign, 'Leo');
    });

    test('D249: Rahu subdivision at 13.0 maps to Virgo', () {
      final d249 = jyotish.getDivisionalChart(
        rashiChart: createD249MockChart(13.0),
        type: DivisionalChartType.d249,
      );
      expect(d249.planets[Planet.sun]!.zodiacSign, 'Virgo');
    });

    test('D249: Jupiter subdivision at 17.5 maps to Libra', () {
      final d249 = jyotish.getDivisionalChart(
        rashiChart: createD249MockChart(17.5),
        type: DivisionalChartType.d249,
      );
      expect(d249.planets[Planet.sun]!.zodiacSign, 'Libra');
    });

    test('D249: Saturn subdivision at 22.0 maps to Scorpio', () {
      final d249 = jyotish.getDivisionalChart(
        rashiChart: createD249MockChart(22.0),
        type: DivisionalChartType.d249,
      );
      expect(d249.planets[Planet.sun]!.zodiacSign, 'Scorpio');
    });

    test('D249: Mercury subdivision at 26.0 maps to Sagittarius', () {
      final d249 = jyotish.getDivisionalChart(
        rashiChart: createD249MockChart(26.0),
        type: DivisionalChartType.d249,
      );
      expect(d249.planets[Planet.sun]!.zodiacSign, 'Sagittarius');
    });

    test('D249: All 9 subdivision spans sum to exactly 30 degrees', () {
      // Ketu=1.75, Venus=5.0, Sun=1.5, Moon=2.5, Mars=1.75,
      // Rahu=4.5, Jupiter=4.0, Saturn=4.75, Mercury=4.25
      const expectedSpans = [1.75, 5.0, 1.5, 2.5, 1.75, 4.5, 4.0, 4.75, 4.25];
      final total = expectedSpans.reduce((a, b) => a + b);
      expect(total, closeTo(30.0, 0.01));

      // Verify subSpan reported correctly for each subdivision
      final testPositions = [0.5, 2.0, 7.0, 9.0, 11.0, 13.0, 17.5, 22.0, 26.0];
      for (var i = 0; i < testPositions.length; i++) {
        final d249 = jyotish.getDivisionalChart(
          rashiChart: createD249MockChart(testPositions[i]),
          type: DivisionalChartType.d249,
        );
        expect(
          d249.planets[Planet.sun]!.subSpan,
          closeTo(expectedSpans[i], 0.01),
          reason: 'SubSpan mismatch at position ${testPositions[i]}',
        );
      }
    });

    test('D249: Rahu subdivision has correct 4.5 span', () {
      final d249 = jyotish.getDivisionalChart(
        rashiChart: createD249MockChart(13.0),
        type: DivisionalChartType.d249,
      );
      expect(d249.planets[Planet.sun]!.subSpan, closeTo(4.5, 0.01));
    });

    test('D249: Throws AyanamsaMismatchException if not KP Ayanamsa', () async {
      final location =
          GeographicLocation(latitude: 28.6139, longitude: 77.2090);
      final wrongChart = await jyotish.calculateVedicChart(
        dateTime: DateTime(1990, 5, 15, 14, 30),
        location: location,
        flags: const CalculationFlags(siderealMode: SiderealMode.lahiri),
      );
      expect(
        () => jyotish.getDivisionalChart(
          rashiChart: wrongChart,
          type: DivisionalChartType.d249,
        ),
        throwsA(isA<AyanamsaMismatchException>()),
      );
    });
  });
}
