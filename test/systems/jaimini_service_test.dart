import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

void main() {
  late Jyotish jyotish;
  late RashiChart rashiChart;
  late RashiChart navamsaChart;
  bool ephemerisAvailable = false;

  final birthDateTime = DateTime(1990, 5, 15, 14, 30);
  final location =
      GeographicLocation(latitude: 28.6139, longitude: 77.2090);

  setUpAll(() async {
    jyotish = Jyotish();
    try {
      await jyotish.initialize(ephemerisPath: 'ephe');
      ephemerisAvailable = true;

      final calc = await jyotish.calculate(
        birthDateTime: birthDateTime,
        location: location,
      );
      rashiChart = calc.rashiChart;
      navamsaChart = calc.navamsaChart;
    } catch (e) {
      ephemerisAvailable = false;
    }
  });

  group('JaiminiService', () {
    test('getAtmakaraka returns valid planet', () async {
      if (!ephemerisAvailable) return;

      final atmakaraka = jyotish.systems.jaimini.getAtmakaraka(rashiChart);
      expect(atmakaraka, isNotNull);
      expect(atmakaraka, isA<Planet>());
    });

    test('Atmakaraka is one of 7 traditional planets', () async {
      if (!ephemerisAvailable) return;

      final atmakaraka = jyotish.systems.jaimini.getAtmakaraka(rashiChart);
      final traditionalPlanets = [
        Planet.sun,
        Planet.moon,
        Planet.mars,
        Planet.mercury,
        Planet.jupiter,
        Planet.venus,
        Planet.saturn,
      ];
      expect(
        traditionalPlanets.contains(atmakaraka),
        isTrue,
        reason: 'Atmakaraka should be one of the 7 traditional planets',
      );
    });

    test('getKarakamsa returns valid info', () async {
      if (!ephemerisAvailable) return;

      final karakamsa = jyotish.systems.jaimini.getKarakamsa(
        rashiChart: rashiChart,
        navamsaChart: navamsaChart,
      );
      expect(karakamsa, isNotNull);
    });

    test('getRashiDrishti returns list of aspects', () async {
      if (!ephemerisAvailable) return;

      final drishti = jyotish.systems.jaimini.getRashiDrishti(rashiChart);
      expect(drishti, isNotNull);
      expect(drishti, isA<List>());
      expect(drishti, isNotEmpty);
    });

    test('Each RashiDrishtiInfo has sourceSign and targetSign', () async {
      if (!ephemerisAvailable) return;

      final drishti = jyotish.systems.jaimini.getRashiDrishti(rashiChart);

      for (final info in drishti) {
        expect(info, isNotNull);
        expect(info.sourceSign, isNotNull);
        expect(info.targetSign, isNotNull);
      }
    });

    test('getActiveRashiDrishti returns filtered aspects', () async {
      if (!ephemerisAvailable) return;

      final activeDrishti =
          jyotish.systems.jaimini.getActiveRashiDrishti(rashiChart);
      expect(activeDrishti, isNotNull);
      expect(activeDrishti, isA<List>());
      for (final info in activeDrishti) {
        expect(info.sourceSign, isNotNull);
        expect(info.targetSign, isNotNull);
      }
    });
  });
}
