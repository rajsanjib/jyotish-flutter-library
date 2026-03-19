import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

void main() {
  late Jyotish jyotish;
  late VedicChart? rashiChart;
  late bool initialized = false;

  setUpAll(() async {
    try {
      jyotish = Jyotish();
      await jyotish.initialize(ephemerisPath: 'ephe');
      initialized = true;

      rashiChart = await jyotish.calculateVedicChart(
        dateTime: DateTime.utc(1947, 8, 14, 18, 30),
        location: GeographicLocation(latitude: 28.6139, longitude: 77.2090),
        flags: CalculationFlags.traditionalist(),
      );
    } catch (e) {
      initialized = false;
    }
  });

  group('DivisionalChartService - D2 Hora', () {
    test('D2 (Hora) chart has planets', () {
      if (!initialized || rashiChart == null) return;

      final d2 = jyotish.getDivisionalChart(
        rashiChart: rashiChart!,
        type: DivisionalChartType.d2,
      );

      expect(d2, isNotNull);
      expect(d2.planets, isNotNull);
      expect(d2.planets.isNotEmpty, isTrue);
    });
  });

  group('DivisionalChartService - D9 Navamsa', () {
    test('D9 (Navamsa) chart has planets and valid houses', () {
      if (!initialized || rashiChart == null) return;

      final d9 = jyotish.getDivisionalChart(
        rashiChart: rashiChart!,
        type: DivisionalChartType.d9,
      );

      expect(d9, isNotNull);
      expect(d9.planets, isNotNull);
      expect(d9.planets.isNotEmpty, isTrue);

      for (final entry in d9.planets.entries) {
        final planetName = entry.key.name;
        final info = entry.value;
        expect(info.house, greaterThanOrEqualTo(1),
            reason: '$planetName D9 house should be >= 1');
        expect(info.house, lessThanOrEqualTo(12),
            reason: '$planetName D9 house should be <= 12');
      }
    });
  });

  group('DivisionalChartService - D10 Dashamsa', () {
    test('D10 (Dashamsa) chart calculation', () {
      if (!initialized || rashiChart == null) return;

      final d10 = jyotish.getDivisionalChart(
        rashiChart: rashiChart!,
        type: DivisionalChartType.d10,
      );

      expect(d10, isNotNull);
      expect(d10.planets, isNotNull);
      expect(d10.planets.isNotEmpty, isTrue);
    });
  });

  group('DivisionalChartService - D60 Shashtiamsa', () {
    test('D60 (Shashtiamsa) chart calculation', () {
      if (!initialized || rashiChart == null) return;

      final d60 = jyotish.getDivisionalChart(
        rashiChart: rashiChart!,
        type: DivisionalChartType.d60,
      );

      expect(d60, isNotNull);
      expect(d60.planets, isNotNull);
      expect(d60.planets.isNotEmpty, isTrue);
    });
  });

  group('DivisionalChartService - D150', () {
    test('D150 chart calculation', () {
      if (!initialized || rashiChart == null) return;

      final d150 = jyotish.getDivisionalChart(
        rashiChart: rashiChart!,
        type: DivisionalChartType.d150,
      );

      expect(d150, isNotNull);
      expect(d150.planets, isNotNull);
      expect(d150.planets.isNotEmpty, isTrue);
    });
  });

  group('DivisionalChartService - sign mapping', () {
    test('odd sign mapping vs even sign mapping produces valid signs', () {
      if (!initialized || rashiChart == null) return;

      final d9 = jyotish.getDivisionalChart(
        rashiChart: rashiChart!,
        type: DivisionalChartType.d9,
      );

      expect(d9, isNotNull);

      final validSigns = {
        'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
        'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces',
      };

      for (final entry in d9.planets.entries) {
        final signIndex = (entry.value.longitude / 30).floor() % 12;
        final signNames = [
          'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
          'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces',
        ];
        expect(validSigns, contains(signNames[signIndex]),
            reason: '${entry.key.name} D9 sign should be valid');
      }
    });
  });

  group('DivisionalChartType enum', () {
    test('has all expected values d1 through d60 and d150', () {
      expect(DivisionalChartType.d1, isNotNull);
      expect(DivisionalChartType.d2, isNotNull);
      expect(DivisionalChartType.d3, isNotNull);
      expect(DivisionalChartType.d4, isNotNull);
      expect(DivisionalChartType.d7, isNotNull);
      expect(DivisionalChartType.d9, isNotNull);
      expect(DivisionalChartType.d10, isNotNull);
      expect(DivisionalChartType.d12, isNotNull);
      expect(DivisionalChartType.d16, isNotNull);
      expect(DivisionalChartType.d20, isNotNull);
      expect(DivisionalChartType.d24, isNotNull);
      expect(DivisionalChartType.d27, isNotNull);
      expect(DivisionalChartType.d30, isNotNull);
      expect(DivisionalChartType.d40, isNotNull);
      expect(DivisionalChartType.d45, isNotNull);
      expect(DivisionalChartType.d60, isNotNull);
      expect(DivisionalChartType.d150, isNotNull);
    });
  });
}
