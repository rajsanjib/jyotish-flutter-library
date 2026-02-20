import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

void main() {
  group('Chara Dasha', () {
    test('calculateCharaDasha returns correct sequence and duration', () {
      final service = DashaService();

      // Mock chart: Ascendant in Aries (Odd) -> Direct sequence
      final chart = _createMockChart(
        ascendant: 15.0, // Aries
        planetPositions: {
          Planet.sun:
              45.0, // Taurus (Lord Venus in Gemini?) No, lord of Aries is Mars
          Planet.mars: 75.0, // Gemini (3rd sign from Aries)
        },
      );

      final result = service.calculateCharaDasha(chart);

      expect(result.type, DashaType.chara);
      expect(result.allMahadashas.length, 12);

      // First dasha should be Aries
      expect(result.allMahadashas[0].rashi, Rashi.aries);

      // Years for Aries: Lord Mars is in Gemini (3rd from Aries).
      // Distance = 3. Years = 3 - 1 = 2.
      expect(result.allMahadashas[0].durationYears, closeTo(2.0, 0.1));

      // Second dasha should be Taurus (Direct sequence since Aries is Odd)
      expect(result.allMahadashas[1].rashi, Rashi.taurus);
    });

    test('calculateCharaDasha handles Even Ascendant (Indirect sequence)', () {
      final service = DashaService();

      // Mock chart: Ascendant in Taurus (Even) -> Indirect sequence
      final chart = _createMockChart(
        ascendant: 45.0, // Taurus
      );

      final result = service.calculateCharaDasha(chart);

      // Sequence from Taurus: Taurus, Aries, Pisces, etc.
      expect(result.allMahadashas[0].rashi, Rashi.taurus);
      expect(result.allMahadashas[1].rashi, Rashi.aries);
      expect(result.allMahadashas[2].rashi, Rashi.pisces);
    });
  });

  group('Planetary Relationships', () {
    test('getPlanetaryRelationships calculates Tatkalika Friendship correctly',
        () {
      // Testing RelationshipCalculator.calculateTemporary
      expect(RelationshipCalculator.calculateTemporary(1, 2),
          RelationshipType.friend);
      expect(RelationshipCalculator.calculateTemporary(1, 7),
          RelationshipType.enemy);

      // Testing Compound Relationship
      // Sun natural friend to Moon
      final compound = RelationshipCalculator.calculateCompound(
          RelationshipType.friend, // Natural
          RelationshipType.friend // Temporary
          );
      expect(compound, RelationshipType.greatFriend);
    });
  });

  group('Ashtakavarga Reductions', () {
    test('applyTrikonaShodhana reduces bindus correctly', () {
      final service = AshtakavargaService();

      final bav = Bhinnashtakavarga(
        planet: Planet.sun,
        bindus: [4, 5, 2, 3, 4, 1, 6, 2, 4, 3, 1, 5],
        contributions: List.filled(12, 0),
      );

      final av = Ashtakavarga(
        natalChart: _createMockChart(),
        bhinnashtakavarga: {Planet.sun: bav},
        sarvashtakavarga: Sarvashtakavarga(bindus: bav.bindus),
        samudayaAshtakavarga: bav.bindus,
      );

      final reduced = service.applyTrikonaShodhana(av);

      // Trikona 1: Aries(0), Leo(4), Sag(8)
      // Original: 4, 4, 4. Min is 4. Reduced: 4, 4, 4.
      expect(reduced.bhinnashtakavarga[Planet.sun]!.bindus[0], 4);

      // Trikona 2: Taurus(1), Virgo(5), Cap(9)
      // Original: 5, 1, 3. Min is 1. Reduced: 1, 1, 1.
      expect(reduced.bhinnashtakavarga[Planet.sun]!.bindus[1], 1);
      expect(reduced.bhinnashtakavarga[Planet.sun]!.bindus[5], 1);
      expect(reduced.bhinnashtakavarga[Planet.sun]!.bindus[9], 1);
    });
  });
}

VedicChart _createMockChart({
  double ascendant = 0.0,
  Map<Planet, double> planetPositions = const {},
  List<double>? houses,
}) {
  final now = DateTime.now();
  final houseSystem = HouseSystem(
    system: 'Whole Sign',
    cusps: houses ?? List.generate(12, (i) => (i * 30.0) % 360),
    ascendant: ascendant,
    midheaven: (ascendant + 270) % 360,
  );

  final planets = <Planet, VedicPlanetInfo>{};
  planetPositions.forEach((planet, long) {
    final pos = PlanetPosition(
      planet: planet,
      dateTime: now,
      longitude: long,
      latitude: 0,
      distance: 1.0,
      longitudeSpeed: 1.0,
      latitudeSpeed: 0,
      distanceSpeed: 0,
    );
    planets[planet] = VedicPlanetInfo(
      position: pos,
      house: houseSystem.getHouseForLongitude(long),
      dignity: PlanetaryDignity.neutralSign,
    );
  });

  // Add default positions for mandatory planets if missing
  for (final p in Planet.traditionalPlanets) {
    if (!planets.containsKey(p)) {
      final pos = PlanetPosition(
        planet: p,
        dateTime: now,
        longitude: 0,
        latitude: 0,
        distance: 1.0,
        longitudeSpeed: 1.0,
        latitudeSpeed: 0,
        distanceSpeed: 0,
      );
      planets[p] = VedicPlanetInfo(
        position: pos,
        house: 1,
        dignity: PlanetaryDignity.neutralSign,
      );
    }
  }

  final rahuPos = PlanetPosition(
    planet: Planet.meanNode,
    dateTime: now,
    longitude: 0,
    latitude: 0,
    distance: 1.0,
    longitudeSpeed: -0.05,
    latitudeSpeed: 0,
    distanceSpeed: 0,
  );

  final rahu = VedicPlanetInfo(
    position: rahuPos,
    house: 1,
    dignity: PlanetaryDignity.neutralSign,
  );

  return VedicChart(
    dateTime: now,
    location: 'Test',
    latitude: 0,
    longitudeCoord: 0,
    houses: houseSystem,
    planets: planets,
    rahu: rahu,
    ketu: KetuPosition(rahuPosition: rahuPos),
  );
}
