import 'package:jyotish/jyotish.dart';
import 'package:jyotish/src/muhurta/ritual_elements.dart';
import 'package:jyotish/src/muhurta/ritual_service.dart';
import 'package:test/test.dart';

void main() {
  late Jyotish jyotish;

  setUpAll(() async {
    jyotish = Jyotish();
    try {
      await jyotish.initialize(ephemerisPath: 'ephe');
    } catch (_) {}
  });

  final location = GeographicLocation(latitude: 28.6139, longitude: 77.2090);

  group('RitualService', () {
    test('exists and can be instantiated', () {
      final service = RitualService();
      expect(service, isNotNull);
      expect(service, isA<RitualService>());
    });

    test('calculateRitualElements returns valid RitualElements', () async {
      final now = DateTime(2025, 3, 15, 10, 0);
      final panchanga = await jyotish.calculatePanchanga(
        dateTime: now,
        location: location,
      );

      final service = RitualService();
      final elements = service.calculateRitualElements(panchanga: panchanga);

      expect(elements, isNotNull);
      expect(elements.homahuti, isNotNull);
      expect(elements.agnivasa, isNotEmpty);
      expect(elements.shivavasa, isNotEmpty);
      expect(elements.kumbhaChakra, isNotNull);
    });
  });

  group('RitualElements properties', () {
    test('homahuti is a valid HomahutiLevel', () async {
      final now = DateTime(2025, 3, 15, 10, 0);
      final panchanga = await jyotish.calculatePanchanga(
        dateTime: now,
        location: location,
      );

      final service = RitualService();
      final elements = service.calculateRitualElements(panchanga: panchanga);

      final validLevels = {
        HomahutiLevel.siddha,
        HomahutiLevel.auspicious,
        HomahutiLevel.inauspicious,
      };

      expect(validLevels, contains(elements.homahuti));
      expect(elements.homahuti.description, isNotEmpty);
    });

    test('agnivasa indicates auspiciousness', () async {
      final now = DateTime(2025, 3, 15, 10, 0);
      final panchanga = await jyotish.calculatePanchanga(
        dateTime: now,
        location: location,
      );

      final service = RitualService();
      final elements = service.calculateRitualElements(panchanga: panchanga);

      expect(
          elements.agnivasa.contains('Auspicious') ||
              elements.agnivasa.contains('Inauspicious'),
          isTrue);
    });

    test('shivavasa contains a known residence', () async {
      final now = DateTime(2025, 3, 15, 10, 0);
      final panchanga = await jyotish.calculatePanchanga(
        dateTime: now,
        location: location,
      );

      final service = RitualService();
      final elements = service.calculateRitualElements(panchanga: panchanga);

      final knownResidences = [
        'Mount Kailash',
        'With Gauri',
        'Mount Nandi',
        'In Assembly',
        'Eating',
        'Playing',
        'Cremation Ground',
      ];

      expect(
          knownResidences
              .any((r) => elements.shivavasa.contains(r)),
          isTrue,
          reason: 'shivavasa "${elements.shivavasa}" not a known residence');
    });

    test('kumbhaChakra is a valid KumbhaChakraLevel', () async {
      final now = DateTime(2025, 3, 15, 10, 0);
      final panchanga = await jyotish.calculatePanchanga(
        dateTime: now,
        location: location,
      );

      final service = RitualService();
      final elements = service.calculateRitualElements(panchanga: panchanga);

      final validLevels = {
        KumbhaChakraLevel.excellent,
        KumbhaChakraLevel.good,
        KumbhaChakraLevel.neutral,
        KumbhaChakraLevel.bad,
      };

      expect(validLevels, contains(elements.kumbhaChakra));
      expect(elements.kumbhaChakra.description, isNotEmpty);
    });
  });

  group('HomahutiLevel enum', () {
    test('all values have description', () {
      for (final level in HomahutiLevel.values) {
        expect(level.description, isNotEmpty);
      }
    });
  });

  group('KumbhaChakraLevel enum', () {
    test('all values have description', () {
      for (final level in KumbhaChakraLevel.values) {
        expect(level.description, isNotEmpty);
      }
    });

    test('has 4 levels', () {
      expect(KumbhaChakraLevel.values.length, equals(4));
    });
  });
}
