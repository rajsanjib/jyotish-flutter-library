import 'package:test/test.dart';
import 'package:jyotish/jyotish.dart';

void main() {
  group('Samvat Calculations', () {
    late EphemerisService ephemerisService;
    late MasaService masaService;
    final delhi = GeographicLocation(
      latitude: 28.6139,
      longitude: 77.2090,
      timezone: 'Asia/Kolkata',
    );

    setUpAll(() async {
      ephemerisService = EphemerisService();
      await ephemerisService.initialize();
      masaService = MasaService(ephemerisService);
    });

    test('Vikram and Shaka Samvat for known dates (March 4, 2026)', () async {
      final date = DateTime(2026, 3, 4, 12, 0); // After Chaitra start roughly
      final samvatInfo = await masaService.getSamvatInfo(
        dateTime: date,
        location: delhi,
      );

      // Verify Vikram Samvat (2082 Kalayukta), Shaka (1947 Vishvavasu)
      expect(samvatInfo.vikramSamvat, 2082); // VS 2082
      expect(samvatInfo.shakaSamvat, 1947); // SS 1947
    });

    test('Ayana and Pravishte calculation', () async {
      final date = DateTime(2026, 3, 4, 12, 0);

      final ayana = await masaService.getAyana(
        dateTime: date,
        location: delhi,
      );

      final pravishte = await masaService.getPravishte(
        dateTime: date,
        location: delhi,
      );

      // March is Uttarayana
      expect(ayana, Ayana.uttarayana);

      // March 4 is generally around Kumbha 20th
      expect(pravishte.monthName, 'Kumbha');
    });
  });
}
