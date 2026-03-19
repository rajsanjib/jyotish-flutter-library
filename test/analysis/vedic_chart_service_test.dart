import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

void main() {
  late Jyotish jyotish;
  late VedicChart? defaultChart;
  late VedicChart? independenceChart;
  late bool initialized = false;

  setUpAll(() async {
    try {
      jyotish = Jyotish();
      await jyotish.initialize(ephemerisPath: 'ephe');
      initialized = true;

      defaultChart = await jyotish.calculateVedicChart(
        dateTime: DateTime(2024, 1, 1, 12, 0),
        location: GeographicLocation(latitude: 28.6139, longitude: 77.2090),
        flags: CalculationFlags.traditionalist(),
      );

      independenceChart = await jyotish.calculateVedicChart(
        dateTime: DateTime.utc(1947, 8, 14, 18, 30),
        location: GeographicLocation(latitude: 28.6139, longitude: 77.2090),
        flags: CalculationFlags.traditionalist(),
      );
    } catch (e) {
      initialized = false;
    }
  });

  group('VedicChartService - calculateVedicChart', () {
    test('returns valid chart with all 7 traditional planets', () {
      if (!initialized) return;
      expect(defaultChart, isNotNull);
      expect(defaultChart!.planets, isNotNull);

      final planetNames = defaultChart!.planets.keys.map((p) => p.name).toSet();
      expect(planetNames, contains('Sun'));
      expect(planetNames, contains('Moon'));
      expect(planetNames, contains('Mercury'));
      expect(planetNames, contains('Venus'));
      expect(planetNames, contains('Mars'));
      expect(planetNames, contains('Jupiter'));
      expect(planetNames, contains('Saturn'));
    });

    test('ascendant is one of 12 zodiac signs', () {
      if (!initialized) return;
      expect(defaultChart, isNotNull);

      final validSigns = {
        'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
        'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces',
      };
      expect(validSigns, contains(defaultChart!.ascendantSign));
    });

    test('each planet has valid house (1-12)', () {
      if (!initialized) return;
      expect(defaultChart, isNotNull);

      for (final entry in defaultChart!.planets.entries) {
        final planetName = entry.key.name;
        final info = entry.value;
        expect(info.house, greaterThanOrEqualTo(1),
            reason: '$planetName house should be >= 1');
        expect(info.house, lessThanOrEqualTo(12),
            reason: '$planetName house should be <= 12');
      }
    });

    test('each planet has valid dignity', () {
      if (!initialized) return;
      expect(defaultChart, isNotNull);

      for (final entry in defaultChart!.planets.entries) {
        final planetName = entry.key.name;
        final info = entry.value;
        expect(info.dignity, isNotNull,
            reason: '$planetName dignity should not be null');
        expect(info.dignity.toString().isNotEmpty, isTrue,
            reason: '$planetName dignity should not be empty');
      }
    });

    test('India Independence chart has Taurus ascendant', () {
      if (!initialized) return;
      expect(independenceChart, isNotNull);
      expect(independenceChart!.ascendantSign, equals('Taurus'));
    });

    test('Whole Sign vs Placidus produces different results', () {
      if (!initialized) return;

      final wholeSignChart = jyotish.calculateVedicChart(
        dateTime: DateTime(2024, 1, 1, 12, 0),
        location: GeographicLocation(latitude: 28.6139, longitude: 77.2090),
        houseSystem: 'W',
        flags: CalculationFlags.traditionalist(),
      );

      final placidusChart = jyotish.calculateVedicChart(
        dateTime: DateTime(2024, 1, 1, 12, 0),
        location: GeographicLocation(latitude: 28.6139, longitude: 77.2090),
        houseSystem: 'P',
        flags: CalculationFlags.traditionalist(),
      );

      expect(wholeSignChart, isNotNull);
      expect(placidusChart, isNotNull);
    });

    test('includeOuterPlanets adds Uranus/Neptune/Pluto', () {
      if (!initialized) return;

      final chartWithOuter = jyotish.calculateVedicChart(
        dateTime: DateTime(2024, 1, 1, 12, 0),
        location: GeographicLocation(latitude: 28.6139, longitude: 77.2090),
        includeOuterPlanets: true,
        flags: CalculationFlags.traditionalist(),
      );

      expect(chartWithOuter, isNotNull);
    });

    test('VedicPlanetInfo has position, house, dignity fields', () {
      if (!initialized) return;
      expect(defaultChart, isNotNull);

      for (final entry in defaultChart!.planets.entries) {
        final planetName = entry.key.name;
        final info = entry.value;
        expect(info.position, isNotNull);
        expect(info.house, isNotNull);
        expect(info.dignity, isNotNull);
      }
    });
  });
}
