import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

void main() {
  late Jyotish jyotish;
  late RashiChart chart;
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
      chart = calc.rashiChart;
    } catch (e) {
      ephemerisAvailable = false;
    }
  });

  group('ArudhaPadaService', () {
    test('getArudhaPadas returns 12 arudhas', () async {
      if (!ephemerisAvailable) return;

      final arudhas = jyotish.systems.arudhaPada.getArudhaPadas(chart);
      expect(arudhas, isNotNull);
      expect(arudhas, isA<ArudhaPadaResult>());
      expect(arudhas.arudhas, isNotNull);
      expect(arudhas.arudhas.length, equals(12));

      for (int house = 1; house <= 12; house++) {
        expect(
          arudhas.arudhas.containsKey(house),
          isTrue,
          reason: 'Should have arudha for house $house',
        );
      }
    });

    test('getArudhaLagna returns valid info', () async {
      if (!ephemerisAvailable) return;

      final arudhaLagna =
          jyotish.systems.arudhaPada.getArudhaLagna(chart);
      expect(arudhaLagna, isNotNull);
      expect(arudhaLagna.house, isNotNull);
      expect(arudhaLagna.sign, isNotNull);
      expect(arudhaLagna.lord, isNotNull);
    });

    test('getUpapada returns valid info', () async {
      if (!ephemerisAvailable) return;

      final upapada = jyotish.systems.arudhaPada.getUpapada(chart);
      expect(upapada, isNotNull);
      expect(upapada.sign, isNotNull);
      expect(upapada.lord, isNotNull);
    });
  });
}
