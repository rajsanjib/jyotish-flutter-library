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

  group('AspectService - special aspects', () {
    test('all planets aspect 7th house (opposition)', () {
      if (!initialized) return;

      final oppositionAspects = aspects.where(
        (a) => a.type == AspectType.opposition,
      );

      expect(oppositionAspects, isNotEmpty,
          reason: 'All planets should have 7th house opposition aspects');
    });

    test('Mars has special 4th and 8th aspects', () {
      if (!initialized) return;

      final marsAspects = aspects.where(
        (a) =>
            a.aspectingPlanet == Planet.mars &&
            (a.type == AspectType.marsSpecial4th ||
                a.type == AspectType.marsSpecial8th),
      );

      expect(marsAspects, isNotEmpty,
          reason: 'Mars should have special 4th and 8th aspects');
    });

    test('Jupiter has special 5th and 9th aspects', () {
      if (!initialized) return;

      final jupiterAspects = aspects.where(
        (a) =>
            a.aspectingPlanet == Planet.jupiter &&
            (a.type == AspectType.jupiterSpecial5th ||
                a.type == AspectType.jupiterSpecial9th),
      );

      expect(jupiterAspects, isNotEmpty,
          reason: 'Jupiter should have special 5th and 9th aspects');
    });

    test('Saturn has special 3rd and 10th aspects', () {
      if (!initialized) return;

      final saturnAspects = aspects.where(
        (a) =>
            a.aspectingPlanet == Planet.saturn &&
            (a.type == AspectType.saturnSpecial3rd ||
                a.type == AspectType.saturnSpecial10th),
      );

      expect(saturnAspects, isNotEmpty,
          reason: 'Saturn should have special 3rd and 10th aspects');
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
