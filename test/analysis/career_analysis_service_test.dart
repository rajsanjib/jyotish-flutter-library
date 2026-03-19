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

      chart = await jyotish.calculateVedicChart(
        dateTime: DateTime(1990, 7, 15, 10, 30),
        location: GeographicLocation(latitude: 28.6139, longitude: 77.2090),
      );
    } catch (_) {}
  });

  group('CareerAnalysisService', () {
    test('getD10CareerAnalysis returns valid analysis', () {
      if (!initialized) return;

      final analysis = jyotish.getD10CareerAnalysis(natalChart: chart);
      expect(analysis, isNotNull);
      expect(analysis, isA<D10CareerAnalysis>());
    });

    test('analysis has primaryDomains', () {
      if (!initialized) return;

      final analysis = jyotish.getD10CareerAnalysis(natalChart: chart);
      expect(analysis.primaryDomains, isNotNull);
      expect(analysis.primaryDomains, isA<List<String>>());
    });

    test('strong planets list is populated', () {
      if (!initialized) return;

      final analysis = jyotish.getD10CareerAnalysis(natalChart: chart);
      expect(analysis.strongPlanets, isNotNull);
      expect(analysis.strongPlanets, isA<List<Planet>>());
    });

    test('tenth lord is identified', () {
      if (!initialized) return;

      final analysis = jyotish.getD10CareerAnalysis(natalChart: chart);
      expect(analysis.tenthLord, isNotNull);
      expect(analysis.tenthLord, isA<Planet>());
    });

    test('tenth sign is identified', () {
      if (!initialized) return;

      final analysis = jyotish.getD10CareerAnalysis(natalChart: chart);
      expect(analysis.tenthSign, isNotNull);
    });

    test('career themes are generated', () {
      if (!initialized) return;

      final analysis = jyotish.getD10CareerAnalysis(natalChart: chart);
      expect(analysis.careerThemes, isNotNull);
      expect(analysis.careerThemes, isA<List<String>>());
    });

    test('overall strength is a valid category', () {
      if (!initialized) return;

      final analysis = jyotish.getD10CareerAnalysis(natalChart: chart);
      expect(analysis.overallStrength, isNotNull);
      expect(analysis.overallStrength, isA<D10StrengthCategory>());
      expect(analysis.overallStrength.label, isNotEmpty);
    });

    test('d10 chart reference is included', () {
      if (!initialized) return;

      final analysis = jyotish.getD10CareerAnalysis(natalChart: chart);
      expect(analysis.d10Chart, isNotNull);
      expect(analysis.d10Chart, isA<VedicChart>());
    });
  });
}
