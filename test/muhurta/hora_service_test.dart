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

  group('getCurrentHora', () {
    test('returns a valid HoraPeriod', () async {
      final now = DateTime(2025, 3, 15, 10, 0);
      final hora = await jyotish.getCurrentHora(dateTime: now, location: location);

      expect(hora, isNotNull);
      expect(hora.hourNumber, greaterThanOrEqualTo(1));
      expect(hora.hourNumber, lessThanOrEqualTo(12));
      expect(hora.lord, isNotNull);
      expect(hora.startTime, isNotNull);
      expect(hora.endTime, isNotNull);
      expect(hora.isDaytime, isTrue);
    });
  });

  group('getHorasForDay', () {
    test('returns 24 periods', () async {
      final date = DateTime(2025, 3, 15);
      final horas = await jyotish.getHorasForDay(date: date, location: location);

      expect(horas, isNotNull);
      expect(horas.length, equals(24));
    });

    test('hora lords follow Chaldean order sequence', () async {
      final date = DateTime(2025, 3, 15);
      final horas = await jyotish.getHorasForDay(date: date, location: location);

      final chaldeanOrder = [
        Planet.saturn,
        Planet.jupiter,
        Planet.mars,
        Planet.sun,
        Planet.venus,
        Planet.mercury,
        Planet.moon,
      ];

      for (final hora in horas) {
        expect(chaldeanOrder, contains(hora.lord),
            reason:
                'Hora ${hora.hourNumber} lord ${hora.lord} not in Chaldean order');
      }

      for (int i = 0; i < 7 && i + 7 < horas.length; i++) {
        final firstCycle = chaldeanOrder.indexOf(horas[i].lord);
        final secondCycle = chaldeanOrder.indexOf(horas[i + 7].lord);
        expect(firstCycle, equals(secondCycle),
            reason: 'Chaldean order cycle broken at hora ${i + 1}');
      }
    });

    test('first 12 are daytime, last 12 are nighttime', () async {
      final date = DateTime(2025, 3, 15);
      final horas = await jyotish.getHorasForDay(date: date, location: location);

      for (int i = 0; i < 12; i++) {
        expect(horas[i].isDaytime, isTrue,
            reason: 'Hora ${i + 1} should be daytime');
      }
      for (int i = 12; i < 24; i++) {
        expect(horas[i].isDaytime, isFalse,
            reason: 'Hora ${i + 1} should be nighttime');
      }
    });
  });

  group('HoraPeriod timing', () {
    test('each hora has startTime before endTime', () async {
      final date = DateTime(2025, 3, 15);
      final horas = await jyotish.getHorasForDay(date: date, location: location);

      for (final hora in horas) {
        expect(hora.startTime.isBefore(hora.endTime), isTrue,
            reason:
                'Hora ${hora.hourNumber}: startTime is not before endTime');
      }
    });

    test('consecutive horas have contiguous time ranges', () async {
      final date = DateTime(2025, 3, 15);
      final horas = await jyotish.getHorasForDay(date: date, location: location);

      for (int i = 0; i < horas.length - 1; i++) {
        expect(
            horas[i].endTime.isAtSameMomentAs(horas[i + 1].startTime) ||
                horas[i].endTime
                    .isBefore(horas[i + 1].startTime.add(Duration(seconds: 2))),
            isTrue,
            reason: 'Gap between hora ${i + 1} and ${i + 2}');
      }
    });
  });

  group('HoraPeriod properties', () {
    test('has correct isAuspicious based on lord planet', () async {
      final now = DateTime(2025, 3, 15, 10, 0);
      final hora = await jyotish.getCurrentHora(dateTime: now, location: location);

      final auspiciousPlanets = [
        Planet.sun,
        Planet.moon,
        Planet.jupiter,
        Planet.mercury,
        Planet.venus,
      ];

      final expectedAuspicious = auspiciousPlanets.contains(hora.lord);
      expect(hora.isAuspicious, equals(expectedAuspicious));
    });

    test('name contains lord display name', () async {
      final now = DateTime(2025, 3, 15, 10, 0);
      final hora = await jyotish.getCurrentHora(dateTime: now, location: location);

      expect(hora.name, contains(hora.lord.displayName));
    });
  });
}
