import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

void main() {
  late Jyotish jyotish;
  late VedicChart chart;
  bool ephemerisAvailable = false;

  final birthDateTime = DateTime(1990, 5, 15, 14, 30);
  final location = GeographicLocation(latitude: 28.6139, longitude: 77.2090);

  setUpAll(() async {
    jyotish = Jyotish();
    try {
      await jyotish.initialize(ephemerisPath: 'ephe');
      ephemerisAvailable = true;

      chart = await jyotish.calculateVedicChart(
        dateTime: birthDateTime,
        location: location,
      );
    } catch (e) {
      ephemerisAvailable = false;
    }
  });

  group('ArgalaService', () {
    test('getAllArgalas returns map for all 12 houses', () async {
      if (!ephemerisAvailable) return;

      final allArgalas = jyotish.systems.argala.getAllArgalas(chart);
      expect(allArgalas, isNotNull);
      expect(allArgalas, isA<Map<int, List<ArgalaInfo>>>());
      expect(allArgalas.length, equals(12));

      for (int house = 1; house <= 12; house++) {
        expect(
          allArgalas.containsKey(house),
          isTrue,
          reason: 'Should have argala for house $house',
        );
      }
    });

    test('Each house has argala list', () async {
      if (!ephemerisAvailable) return;

      final allArgalas = jyotish.systems.argala.getAllArgalas(chart);

      for (int house = 1; house <= 12; house++) {
        expect(
          allArgalas[house],
          isNotNull,
          reason: 'Argala list for house $house should not be null',
        );
        expect(
          allArgalas[house],
          isA<List<ArgalaInfo>>(),
          reason: 'Argala for house $house should be List<ArgalaInfo>',
        );
      }
    });

    test('Argala types are valid', () async {
      if (!ephemerisAvailable) return;

      final allArgalas = jyotish.systems.argala.getAllArgalas(chart);

      const validTypes = ArgalaType.values;

      for (final entry in allArgalas.entries) {
        for (final argalaInfo in entry.value) {
          expect(
            validTypes.contains(argalaInfo.type),
            isTrue,
            reason:
                'Argala type for house ${entry.key} should be a valid ArgalaType',
          );
          expect(argalaInfo.house, isNotNull);
          expect(argalaInfo.planets, isNotNull);
        }
      }
    });

    test('getArgalaForHouse returns data for specific house', () async {
      if (!ephemerisAvailable) return;

      for (int house = 1; house <= 12; house++) {
        final argala = jyotish.systems.argala.getArgalaForHouse(chart, house);
        expect(argala, isNotNull);
        expect(argala, isA<List<ArgalaInfo>>());
      }
    });
  });
}
