import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

void main() {
  late Jyotish jyotish;

  setUpAll(() async {
    jyotish = Jyotish();
    await jyotish.initialize(ephemerisPath: 'ephe');
  });

  group('KP House System Automation', () {
    final location = GeographicLocation(
      latitude: 28.6139,
      longitude: 77.2090,
      timezone: 'Asia/Kolkata',
    );
    final dateTime = DateTime.utc(1947, 8, 14, 18, 30, 0);

    test('Automatically selects Placidus when KP flags are used', () async {
      // Even if we pass 'W' (Whole Sign) manually, it should be overridden to 'P'
      final chart = await jyotish.calculateVedicChart(
        dateTime: dateTime,
        location: location,
        houseSystem: 'W',
        flags: CalculationFlags.kp(),
      );

      expect(chart.houses.system, equals('Placidus'));
      expect(chart.flags.isKP, isTrue);
    });

    test(
        'Defaults to traditionalist and Whole Sign if no flags/houseSystem provided',
        () async {
      final chart = await jyotish.calculateVedicChart(
        dateTime: dateTime,
        location: location,
      );

      expect(chart.houses.system, equals('Whole Sign'));
      expect(chart.flags.isTraditional, isTrue);
    });

    test('Respects explicit house system when traditional flags are used',
        () async {
      final chart = await jyotish.calculateVedicChart(
        dateTime: dateTime,
        location: location,
        houseSystem: 'E', // Equal
        flags: CalculationFlags.traditionalist(),
      );

      expect(chart.houses.system, equals('Equal'));
      expect(chart.flags.isTraditional, isTrue);
    });
  });
}
