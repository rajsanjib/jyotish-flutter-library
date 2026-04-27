import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    AstrologyTimeService.initialize();
  });

  group('AstrologyTimeService', () {
    test('localToUtc for Asia/Kolkata (UTC+5:30)', () {
      final localDt = DateTime(2024, 6, 15, 12, 0, 0);
      final utc = AstrologyTimeService.localToUtc(localDt, 'Asia/Kolkata');

      expect(utc, isNotNull);
      expect(utc.hour, equals(6));
      expect(utc.minute, equals(30));
      expect(utc.isUtc, isTrue);
    });

    test('localToUtc for America/New_York', () {
      final localDt = DateTime(2024, 7, 15, 14, 0, 0);
      final utc = AstrologyTimeService.localToUtc(localDt, 'America/New_York');

      expect(utc, isNotNull);
      expect(utc.isUtc, isTrue);
      expect(utc.hour, equals(18));
    });

    test('getOffset returns correct Duration', () {
      final date = DateTime(2024, 1, 15);
      final offset = AstrologyTimeService.getOffset(date, 'Asia/Kolkata');

      expect(offset, isNotNull);
      expect(offset, equals(const Duration(hours: 5, minutes: 30)));
    });

    test('availableTimezones returns non-empty list', () {
      final timezones = AstrologyTimeService.availableTimezones;

      expect(timezones, isNotNull);
      expect(timezones, isNotEmpty);
      expect(timezones, contains('Asia/Kolkata'));
      expect(timezones, contains('America/New_York'));
      expect(timezones, contains('UTC'));
    });

    test('DST transition handling', () {
      final beforeDST = DateTime(2024, 3, 10, 1, 30, 0);
      final afterDST = DateTime(2024, 3, 10, 3, 30, 0);

      final offsetBefore =
          AstrologyTimeService.getOffset(beforeDST, 'America/New_York');
      final offsetAfter =
          AstrologyTimeService.getOffset(afterDST, 'America/New_York');

      expect(offsetBefore, isNotNull);
      expect(offsetAfter, isNotNull);
      expect(offsetAfter.inMinutes, equals(offsetBefore.inMinutes + 60));
    });

    test('invalid timezone falls back gracefully', () {
      final localDt = DateTime(2024, 1, 1, 12, 0, 0);

      final utc =
          AstrologyTimeService.localToUtc(localDt, 'Invalid/Timezone');

      expect(utc, isNotNull);
      expect(utc.isUtc, isTrue);
    });
  });
}
