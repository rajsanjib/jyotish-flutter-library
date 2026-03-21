import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

void main() {
  group('Phase 1 & 2 Accuracy Corrections', () {
    late CompatibilityService compatService;

    setUp(() {
      compatService = CompatibilityService();
    });

    test('4A: Full Yoni Matrix Implementation', () {
      // 4 points: Same Animal (Serpent & Serpent)
      expect(compatService.calculateYoni('Rohini', 'Mrigashira'), 4);

      // 0 points: Sworn Enemies (Serpent & Mongoose)
      expect(compatService.calculateYoni('Rohini', 'Uttara Ashadha'), 0);

      // 0 points: Sworn Enemies (Cow & Tiger)
      expect(compatService.calculateYoni('Uttara Phalguni', 'Chitra'), 0);

      // 3 points: Friendly (Horse & Elephant => Ashwini & Bharani)
      expect(compatService.calculateYoni('Ashwini', 'Bharani'), 3);

      // 2 points: Neutral (Horse & Goat => Ashwini & Krittika)
      expect(compatService.calculateYoni('Ashwini', 'Krittika'), 2);
    });

    test('2A: Bhakoot Dosha Cancellation', () {
      // 6/8 Relationship: Aries (Mars) vs Scorpio (Mars)
      // Should be cancelled due to same lord
      final ariesChart = _createMockChart(Rashi.aries, 'Ashwini', 1);
      final scorpioChart = _createMockChart(Rashi.scorpio, 'Anuradha', 1);

      final bhakootScore =
          compatService.calculateBhakoot(ariesChart, scorpioChart);
      expect(bhakootScore, 7); // Cancelled

      final doshaCheck =
          compatService.checkBhakootDosha(ariesChart, scorpioChart);
      expect(doshaCheck.hasDosha, false);
      expect(doshaCheck.description, 'No Bhakoot Dosha');

      // 6/8 Relationship without cancellation: Aries (Mars) vs Virgo (Mercury)
      final virgoChart = _createMockChart(Rashi.virgo, 'Hasta', 1);
      final bhakootDosha =
          compatService.calculateBhakoot(ariesChart, virgoChart);
      expect(bhakootDosha, 0); // Not cancelled

      final doshaCheck2 =
          compatService.checkBhakootDosha(ariesChart, virgoChart);
      expect(doshaCheck2.hasDosha, true);
    });

    test('2B: Nadi Dosha Cancellation', () {
      // Same Nakshatra (Ashwini/Adi), Different Pada (1 vs 4)
      final boyChart1 = _createMockChart(Rashi.aries, 'Ashwini', 1);
      final girlChart1 = _createMockChart(Rashi.aries, 'Ashwini', 4);

      final nadiScore = compatService.calculateNadi(boyChart1, girlChart1);
      expect(nadiScore, 8); // Cancelled

      // Same Nakshatra, Same Pada -> Dosha
      final girlChart2 = _createMockChart(Rashi.aries, 'Ashwini', 1);
      final nadiScoreDosha = compatService.calculateNadi(boyChart1, girlChart2);
      expect(nadiScoreDosha, 0); // Not cancelled

      // Same Rashi (Aries), Different Nakshatra (Ashwini vs Bharani) -> Adi vs Madhya (no Dosha natively, checked below)
      final girlChart3 = _createMockChart(Rashi.aries, 'Bharani', 1);
      expect(compatService.calculateNadi(boyChart1, girlChart3), 8);
    });

    test('2C: Vashya Koota Rashi-based classification', () {
      // Aries vs Aries -> Same Vashya (Chatushpada) -> 2 points
      final ariesBoy = _createMockChart(Rashi.aries, 'Ashwini', 1);
      final ariesGirl = _createMockChart(Rashi.aries, 'Bharani', 1);

      expect(compatService.calculateVashya(ariesBoy, ariesGirl), 2);

      // Leo (Vanachara) vs Gemini (Manava) -> Compatible -> 1 point
      final leoBoy = _createMockChart(Rashi.leo, 'Magha', 1);
      final geminiGirl = _createMockChart(Rashi.gemini, 'Ardra', 1);

      expect(compatService.calculateVashya(leoBoy, geminiGirl), 1);

      // Leo (Vanachara) vs Cancer (Jalachara) -> Incompatible -> 0 points
      final cancerGirl = _createMockChart(Rashi.cancer, 'Pushya', 1);
      expect(compatService.calculateVashya(leoBoy, cancerGirl), 0);
    });
  });
}

VedicChart _createMockChart(Rashi sign, String nakshatra, int pada) {
  final now = DateTime.now();
  final planets = <Planet, VedicPlanetInfo>{};

  const nakshatrasList = [
    'Ashwini',
    'Bharani',
    'Krittika',
    'Rohini',
    'Mrigashira',
    'Ardra',
    'Punarvasu',
    'Pushya',
    'Ashlesha',
    'Magha',
    'Purva Phalguni',
    'Uttara Phalguni',
    'Hasta',
    'Chitra',
    'Swati',
    'Vishakha',
    'Anuradha',
    'Jyeshtha',
    'Mula',
    'Purva Ashadha',
    'Uttara Ashadha',
    'Shravana',
    'Dhanishta',
    'Shatabhisha',
    'Purva Bhadrapada',
    'Uttara Bhadrapada',
    'Revati',
  ];

  final nakIndex = nakshatrasList.indexOf(nakshatra);
  final nakshatraStart = nakIndex * (360.0 / 27.0);
  const padaWidth = (360.0 / 27.0) / 4.0;
  final padaStart = nakshatraStart + ((pada - 1) * padaWidth);

  // Position the moon perfectly in the middle of the requested Pada.
  // This guarantees that all Rashi, Nakshatra, and Pada derivations in the models
  // accurately reflect the test inputs.
  final moonLongitude = padaStart + (padaWidth / 2.0);

  planets[Planet.moon] = VedicPlanetInfo(
    position: PlanetPosition(
      planet: Planet.moon,
      dateTime: now,
      longitude: moonLongitude,
      latitude: 0.0,
      distance: 1.0,
      longitudeSpeed: 13.0,
      latitudeSpeed: 0.0,
      distanceSpeed: 0.0,
    ),
    house: 1,
    dignity: PlanetaryDignity.ownSign,
  );

  return VedicChart(
    dateTime: now,
    location: 'Test',
    latitude: 0.0,
    longitudeCoord: 0.0,
    houses: HouseSystem(
      system: 'W',
      cusps: List<double>.generate(12, (i) => i * 30.0),
      ascendant: 0.0,
      midheaven: 270.0,
    ),
    planets: planets,
    rahu: VedicPlanetInfo(
      position: PlanetPosition(
        planet: Planet.meanNode,
        dateTime: now,
        longitude: 180.0,
        latitude: 0.0,
        distance: 1.0,
        longitudeSpeed: -0.05,
        latitudeSpeed: 0.0,
        distanceSpeed: 0.0,
      ),
      house: 7,
      dignity: PlanetaryDignity.neutralSign,
    ),
    ketu: KetuPosition(
      rahuPosition: PlanetPosition(
        planet: Planet.meanNode,
        dateTime: now,
        longitude: 180.0,
        latitude: 0.0,
        distance: 1.0,
        longitudeSpeed: -0.05,
        latitudeSpeed: 0.0,
        distanceSpeed: 0.0,
      ),
    ),
  );
}
