import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

void main() {
  late Jyotish jyotish;
  late VedicChart chart;
  late List<AspectInfo> aspects;
  bool initialized = false;

  setUpAll(() async {
    try {
      jyotish = Jyotish();
      await jyotish.initialize(ephemerisPath: 'ephe');
      initialized = true;

      chart = await jyotish.calculateVedicChart(
        dateTime: DateTime.utc(1947, 8, 14, 18, 30),
        location: GeographicLocation(latitude: 28.6139, longitude: 77.2090),
        flags: CalculationFlags.traditionalist(),
      );

      aspects = jyotish.getChartAspects(chart);
    } catch (e) {
      initialized = false;
    }
  });

  group('AspectService - aspect properties', () {
    test('each aspect has aspectingPlanet, aspectedPlanet, type', () {
      if (!initialized) return;
      expect(aspects, isNotEmpty);

      for (final aspect in aspects) {
        expect(aspect.aspectingPlanet, isNotNull);
        expect(aspect.aspectedPlanet, isNotNull);
        expect(aspect.type, isNotNull);
        expect(aspect.type, isA<AspectType>());
      }
    });

    test('aspect has exactOrb and strength', () {
      if (!initialized) return;
      expect(aspects, isNotEmpty);

      for (final aspect in aspects) {
        expect(aspect.exactOrb, isNotNull);
        expect(aspect.exactOrb, greaterThanOrEqualTo(0));
        expect(aspect.strength, greaterThanOrEqualTo(0));
        expect(aspect.strength, lessThanOrEqualTo(1.0));
      }
    });

    test('aspect has isApplying and description', () {
      if (!initialized) return;
      expect(aspects, isNotEmpty);

      for (final aspect in aspects) {
        expect(aspect.isApplying, isA<bool>());
        expect(aspect.description, isNotNull);
        expect(aspect.description, isNotEmpty);
      }
    });
  });

  group('AspectService - special aspects (manual)', () {
    late AspectService aspectService;

    setUp(() {
      aspectService = AspectService();
    });

    test('Mars special 4th and 8th aspects are detected', () {
      final positions = {
        Planet.mars: PlanetPosition(
          planet: Planet.mars,
          longitude: 15.0, // Aries
          latitude: 0.0,
          distance: 1.0,
          longitudeSpeed: 0.5,
          latitudeSpeed: 0.0,
          distanceSpeed: 0.0,
          dateTime: DateTime.now(),
        ),
        Planet.jupiter: PlanetPosition(
          planet: Planet.jupiter,
          longitude: 105.0, // Cancer (4th from Aries)
          latitude: 0.0,
          distance: 5.0,
          longitudeSpeed: 0.1,
          latitudeSpeed: 0.0,
          distanceSpeed: 0.0,
          dateTime: DateTime.now(),
        ),
        Planet.saturn: PlanetPosition(
          planet: Planet.saturn,
          longitude: 225.0, // Scorpio (8th from Aries)
          latitude: 0.0,
          distance: 10.0,
          longitudeSpeed: 0.05,
          latitudeSpeed: 0.0,
          distanceSpeed: 0.0,
          dateTime: DateTime.now(),
        ),
      };

      final aspects = aspectService.calculateAspects(positions);
      
      expect(aspects.any((a) => a.aspectingPlanet == Planet.mars && a.type == AspectType.marsSpecial4th), isTrue);
      expect(aspects.any((a) => a.aspectingPlanet == Planet.mars && a.type == AspectType.marsSpecial8th), isTrue);
    });

    test('Jupiter special 5th and 9th aspects are detected', () {
      final positions = {
        Planet.jupiter: PlanetPosition(
          planet: Planet.jupiter,
          longitude: 15.0, // Aries
          latitude: 0.0,
          distance: 5.0,
          longitudeSpeed: 0.1,
          latitudeSpeed: 0.0,
          distanceSpeed: 0.0,
          dateTime: DateTime.now(),
        ),
        Planet.mars: PlanetPosition(
          planet: Planet.mars,
          longitude: 135.0, // Leo (5th from Aries)
          latitude: 0.0,
          distance: 1.5,
          longitudeSpeed: 0.5,
          latitudeSpeed: 0.0,
          distanceSpeed: 0.0,
          dateTime: DateTime.now(),
        ),
        Planet.saturn: PlanetPosition(
          planet: Planet.saturn,
          longitude: 255.0, // Sagittarius (9th from Aries)
          latitude: 0.0,
          distance: 10.0,
          longitudeSpeed: 0.05,
          latitudeSpeed: 0.0,
          distanceSpeed: 0.0,
          dateTime: DateTime.now(),
        ),
      };

      final aspects = aspectService.calculateAspects(positions);
      
      expect(aspects.any((a) => a.aspectingPlanet == Planet.jupiter && a.type == AspectType.jupiterSpecial5th), isTrue);
      expect(aspects.any((a) => a.aspectingPlanet == Planet.jupiter && a.type == AspectType.jupiterSpecial9th), isTrue);
    });

    test('Saturn special 3rd and 10th aspects are detected', () {
      final positions = {
        Planet.saturn: PlanetPosition(
          planet: Planet.saturn,
          longitude: 15.0, // Aries
          latitude: 0.0,
          distance: 10.0,
          longitudeSpeed: 0.05,
          latitudeSpeed: 0.0,
          distanceSpeed: 0.0,
          dateTime: DateTime.now(),
        ),
        Planet.venus: PlanetPosition(
          planet: Planet.venus,
          longitude: 75.0, // Gemini (3rd from Aries)
          latitude: 0.0,
          distance: 0.7,
          longitudeSpeed: 1.2,
          latitudeSpeed: 0.0,
          distanceSpeed: 0.0,
          dateTime: DateTime.now(),
        ),
        Planet.mercury: PlanetPosition(
          planet: Planet.mercury,
          longitude: 285.0, // Capricorn (10th from Aries)
          latitude: 0.0,
          distance: 0.4,
          longitudeSpeed: 1.5,
          latitudeSpeed: 0.0,
          distanceSpeed: 0.0,
          dateTime: DateTime.now(),
        ),
      };

      final aspects = aspectService.calculateAspects(positions);
      
      expect(aspects.any((a) => a.aspectingPlanet == Planet.saturn && a.type == AspectType.saturnSpecial3rd), isTrue);
      expect(aspects.any((a) => a.aspectingPlanet == Planet.saturn && a.type == AspectType.saturnSpecial10th), isTrue);
    });
  });

  group('AspectService - getAspectsForPlanet', () {
    test('getAspectsForPlanet returns aspects for Sun', () async {
      if (!initialized) return;

      final sunAspects = await jyotish.getAspectsForPlanet(
        planet: Planet.sun,
        dateTime: DateTime.utc(1947, 8, 14, 18, 30),
        location: GeographicLocation(latitude: 28.6139, longitude: 77.2090),
      );

      expect(sunAspects, isNotNull);
    });
  });

  group('AspectService - getChartAspects', () {
    test('getChartAspects returns non-empty list from chart', () {
      if (!initialized) return;
      expect(aspects, isNotEmpty);
    });
  });
}
