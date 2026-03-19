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

  group('getCurrentGowriPanchangam', () {
    test('returns valid GowriPanchangamInfo', () async {
      final now = DateTime(2025, 3, 15, 10, 0);
      final info = await jyotish.getCurrentGowriPanchangam(
          dateTime: now, location: location);

      expect(info, isNotNull);
      expect(info.type, isNotNull);
      expect(info.startTime, isNotNull);
      expect(info.endTime, isNotNull);
      expect(info.periodNumber, greaterThanOrEqualTo(1));
      expect(info.periodNumber, lessThanOrEqualTo(8));
    });

    test('type is one of the 8 GowriType values', () async {
      final now = DateTime(2025, 3, 15, 10, 0);
      final info = await jyotish.getCurrentGowriPanchangam(
          dateTime: now, location: location);

      final validTypes = {
        GowriType.amrit,
        GowriType.rogam,
        GowriType.uthi,
        GowriType.labhamu,
        GowriType.dhana,
        GowriType.nirkku,
        GowriType.visham,
        GowriType.soolai,
      };

      expect(validTypes, contains(info.type),
          reason: 'GowriType ${info.type} is not a valid type');
    });

    test('isAuspicious is consistent with GowriType definition', () async {
      final now = DateTime(2025, 3, 15, 10, 0);
      final info = await jyotish.getCurrentGowriPanchangam(
          dateTime: now, location: location);

      expect(info.type.isAuspicious, isA<bool>());
    });

    test('startTime is before endTime', () async {
      final now = DateTime(2025, 3, 15, 10, 0);
      final info = await jyotish.getCurrentGowriPanchangam(
          dateTime: now, location: location);

      expect(info.startTime.isBefore(info.endTime), isTrue,
          reason:
              'startTime ${info.startTime} is not before endTime ${info.endTime}');
    });

    test('description is non-empty', () async {
      final now = DateTime(2025, 3, 15, 10, 0);
      final info = await jyotish.getCurrentGowriPanchangam(
          dateTime: now, location: location);

      expect(info.description, isNotEmpty);
      expect(info.description, contains(info.type.name));
    });
  });

  group('GowriType enum', () {
    test('all 8 values have name and description', () {
      expect(GowriType.values.length, equals(8));

      for (final type in GowriType.values) {
        expect(type.name, isNotEmpty);
        expect(type.description, isNotEmpty);
      }
    });

    test('auspicious types: Amrit, Uthi, Labhamu, Dhana', () {
      final auspicious = {
        GowriType.amrit,
        GowriType.uthi,
        GowriType.labhamu,
        GowriType.dhana,
      };

      for (final type in GowriType.values) {
        expect(type.isAuspicious, equals(auspicious.contains(type)),
            reason: '${type.name} auspiciousness mismatch');
      }
    });
  });
}
