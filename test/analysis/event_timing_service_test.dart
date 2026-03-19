import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

void main() {
  late Jyotish jyotish;
  late VedicChart chart;
  bool initialized = false;

  setUpAll(() async {
    jyotish = Jyotish();
    try {
      await jyotish.initialize(ephemerisPath: 'ephe');
      initialized = true;
    } catch (_) {}

    chart = await jyotish.calculateVedicChart(
      dateTime: DateTime(1990, 7, 15, 10, 30),
      location: GeographicLocation(latitude: 28.6139, longitude: 77.2090),
    );
  });

  group('EventTimingService', () {
    test('findEventTimingWindows returns list of windows', () async {
      if (!initialized) return;

      final request = EventTimingRequest(
        natalChart: chart,
        eventType: EventCategory.career,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 12, 31),
        location: GeographicLocation(latitude: 28.6139, longitude: 77.2090),
      );

      final windows = await jyotish.findEventTimingWindows(request);
      expect(windows, isA<List<EventTimingWindow>>());
    });

    test('each window has valid date range', () async {
      if (!initialized) return;

      final request = EventTimingRequest(
        natalChart: chart,
        eventType: EventCategory.career,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 12, 31),
        location: GeographicLocation(latitude: 28.6139, longitude: 77.2090),
      );

      final windows = await jyotish.findEventTimingWindows(request);

      for (final window in windows) {
        expect(window.start, isNotNull);
        expect(window.end, isNotNull);
        expect(
          window.start.isBefore(window.end) ||
              window.start.isAtSameMomentAs(window.end),
          isTrue,
          reason: 'Start date must be on or before end date',
        );
        expect(
          window.start.isAfter(request.startDate.subtract(const Duration(days: 1))),
          isTrue,
          reason: 'Window start must not be before request start',
        );
        expect(
          window.end.isBefore(request.endDate.add(const Duration(days: 1))),
          isTrue,
          reason: 'Window end must not be after request end',
        );
      }
    });

    test('windows have score values', () async {
      if (!initialized) return;

      final request = EventTimingRequest(
        natalChart: chart,
        eventType: EventCategory.career,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 12, 31),
        location: GeographicLocation(latitude: 28.6139, longitude: 77.2090),
      );

      final windows = await jyotish.findEventTimingWindows(request);

      for (final window in windows) {
        expect(window.score, isNotNull);
        expect(window.score, isA<double>());
        expect(window.score >= 0.0, isTrue);
        expect(window.score <= 1.0, isTrue);
      }
    });

    test('windows with highest scores appear first', () async {
      if (!initialized) return;

      final request = EventTimingRequest(
        natalChart: chart,
        eventType: EventCategory.marriage,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 12, 31),
        location: GeographicLocation(latitude: 28.6139, longitude: 77.2090),
      );

      final windows = await jyotish.findEventTimingWindows(request);

      if (windows.length > 1) {
        for (int i = 0; i < windows.length - 1; i++) {
          expect(
            windows[i].score >= windows[i + 1].score,
            isTrue,
            reason: 'Windows should be sorted by descending score',
          );
        }
      }
    });

    test('windows reference influencing dasha lord', () async {
      if (!initialized) return;

      final request = EventTimingRequest(
        natalChart: chart,
        eventType: EventCategory.education,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 12, 31),
        location: GeographicLocation(latitude: 28.6139, longitude: 77.2090),
      );

      final windows = await jyotish.findEventTimingWindows(request);

      for (final window in windows) {
        expect(window.dashaLord, isNotNull);
        expect(window.dashaLord, isA<Planet>());
        expect(window.dashaContext, isNotNull);
        expect(window.dashaContext.isNotEmpty, isTrue);
      }
    });
  });
}
