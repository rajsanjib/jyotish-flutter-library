import 'package:jyotish/jyotish.dart';
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

  group('getCurrentChoghadiya', () {
    test('returns a valid Choghadiya', () async {
      final now = DateTime(2025, 3, 15, 10, 0);
      final choghadiya =
          await jyotish.getCurrentChoghadiya(dateTime: now, location: location);

      expect(choghadiya, isNotNull);
      expect(choghadiya.type, isNotNull);
      expect(choghadiya.startTime, isNotNull);
      expect(choghadiya.endTime, isNotNull);
      expect(choghadiya.periodNumber, greaterThanOrEqualTo(1));
      expect(choghadiya.periodNumber, lessThanOrEqualTo(8));
    });

    test('has a valid type from the 7 ChoghadiyaType values', () async {
      final now = DateTime(2025, 3, 15, 10, 0);
      final choghadiya =
          await jyotish.getCurrentChoghadiya(dateTime: now, location: location);

      final validTypes = {
        ChoghadiyaType.amrit,
        ChoghadiyaType.shubh,
        ChoghadiyaType.labh,
        ChoghadiyaType.char,
        ChoghadiyaType.rog,
        ChoghadiyaType.kaal,
        ChoghadiyaType.udveg,
      };

      expect(validTypes, contains(choghadiya.type),
          reason:
              'Choghadiya type ${choghadiya.type} is not a valid ChoghadiyaType');
    });

    test('isAuspicious matches type definition', () async {
      final now = DateTime(2025, 3, 15, 10, 0);
      final choghadiya =
          await jyotish.getCurrentChoghadiya(dateTime: now, location: location);

      expect(choghadiya.isAuspicious, equals(choghadiya.type.isAuspicious));
    });

    test('startTime is before endTime', () async {
      final now = DateTime(2025, 3, 15, 10, 0);
      final choghadiya =
          await jyotish.getCurrentChoghadiya(dateTime: now, location: location);

      expect(choghadiya.startTime.isBefore(choghadiya.endTime), isTrue,
          reason:
              'startTime ${choghadiya.startTime} is not before endTime ${choghadiya.endTime}');
    });

    test('auspicious types are Amrit, Shubh, Labh, Char', () async {
      final auspiciousTypes = {
        ChoghadiyaType.amrit,
        ChoghadiyaType.shubh,
        ChoghadiyaType.labh,
        ChoghadiyaType.char,
      };

      for (final type in ChoghadiyaType.values) {
        expect(type.isAuspicious, equals(auspiciousTypes.contains(type)),
            reason: '${type.name} auspiciousness mismatch');
      }
    });
  });

  group('ChoghadiyaType enum', () {
    test('all values have name and meaning', () {
      for (final type in ChoghadiyaType.values) {
        expect(type.name, isNotEmpty);
        expect(type.meaning, isNotEmpty);
        expect(type.nature, isNotEmpty);
      }
    });

    test('favorableActivities is non-empty for each type', () {
      for (final type in ChoghadiyaType.values) {
        expect(type.favorableActivities, isNotEmpty);
      }
    });
  });
}
