import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

void main() {
  late Jyotish jyotish;
  late RashiChart natalChart;
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
      natalChart = calc.rashiChart;
    } catch (e) {
      ephemerisAvailable = false;
    }
  });

  group('VarshapalService', () {
    test('getVarshapal returns valid Varshapal', () async {
      if (!ephemerisAvailable) return;

      final varshapal = await jyotish.systems.varshapal.getVarshapal(
        birthDateTime: birthDateTime,
        varshaDateTime: DateTime(2025, 5, 15, 14, 30),
        location: location,
      );
      expect(varshapal, isNotNull);
      expect(varshapal, isA<Varshapal>());
    });

    test('varshapal chart has planets', () async {
      if (!ephemerisAvailable) return;

      final varshapal = await jyotish.systems.varshapal.getVarshapal(
        birthDateTime: birthDateTime,
        varshaDateTime: DateTime(2025, 5, 15, 14, 30),
        location: location,
      );
      expect(varshapal.chart, isNotNull);
      expect(varshapal.chart, isA<RashiChart>());
      expect(varshapal.varshaLord, isNotNull);
      expect(varshapal.varshaLord, isA<Planet>());
    });

    test('getCurrentVarshapal works', () async {
      if (!ephemerisAvailable) return;

      final varshapal = await jyotish.systems.varshapal.getCurrentVarshapal(
        birthDateTime: birthDateTime,
        location: location,
      );
      expect(varshapal, isNotNull);
      expect(varshapal, isA<Varshapal>());
      expect(varshapal.chart, isNotNull);
      expect(varshapal.varshaLord, isNotNull);
      expect(varshapal.maasLord, isNotNull);
      expect(varshapal.varshesha, isNotNull);
    });
  });
}
