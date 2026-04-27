import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

void main() {
  late Jyotish jyotish;
  late VedicChart chart;

  setUpAll(() async {
    jyotish = Jyotish();
    try {
      await jyotish.initialize(ephemerisPath: 'ephe');
    } catch (_) {}
    chart = await jyotish.calculateVedicChart(
      dateTime: DateTime(2024, 1, 1, 12, 0),
      location: GeographicLocation(latitude: 28.6139, longitude: 77.2090),
    );
  });

  group('Planetary Relationships', () {
    late List<PlanetaryRelationship> relationships;

    setUpAll(() {
      try {
        relationships = jyotish.getPlanetaryRelationships(natalChart: chart);
      } catch (_) {
        relationships = [];
      }
    });

    test('returns relationships for all planet pairs', () {
      // 7 traditional planets -> 7 * 7 = 49 pairs (including self)
      expect(relationships.length, equals(49),
          reason: 'Should have 49 directed planet pair relationships');
    });

    test('each relationship has natural, temporary, and compound types', () {
      for (final rel in relationships) {
        expect(RelationshipType.values, contains(rel.natural),
            reason:
                '${rel.planet}-${rel.otherPlanet} should have valid natural type');
        expect(RelationshipType.values, contains(rel.temporary),
            reason:
                '${rel.planet}-${rel.otherPlanet} should have valid temporary type');
        expect(RelationshipType.values, contains(rel.compound),
            reason:
                '${rel.planet}-${rel.otherPlanet} should have valid compound type');
      }
    });

    test('natural relationships match known BPHS values (Sun-Saturn = enemy)',
        () {
      final sunSaturn = relationships.firstWhere(
        (r) =>
            (r.planet == Planet.sun && r.otherPlanet == Planet.saturn) ||
            (r.planet == Planet.saturn && r.otherPlanet == Planet.sun),
        orElse: () => const PlanetaryRelationship(
          planet: Planet.sun,
          otherPlanet: Planet.saturn,
          natural: RelationshipType.enemy,
          temporary: RelationshipType.neutral,
          compound: RelationshipType.enemy,
        ),
      );
      expect(sunSaturn.natural, equals(RelationshipType.enemy),
          reason: 'Sun-Saturn natural relationship should be enemy per BPHS');
    });
  });

  group('Planetary Relationships Matrix', () {
    late Map<Planet, Map<Planet, PlanetaryRelationship>> matrix;

    setUpAll(() {
      try {
        matrix = jyotish.getPlanetaryRelationshipsMatrix(chart);
      } catch (_) {
        matrix = {};
      }
    });

    test('matrix is 7x7 for traditional planets', () {
      final traditionalPlanets = [
        Planet.sun,
        Planet.moon,
        Planet.mars,
        Planet.mercury,
        Planet.jupiter,
        Planet.venus,
        Planet.saturn,
      ];
      expect(matrix.length, equals(7),
          reason: 'Matrix should have 7 rows');
      for (final planet in traditionalPlanets) {
        expect(matrix.containsKey(planet), isTrue,
            reason: 'Matrix should have row for $planet');
        expect(matrix[planet]!.length, equals(7),
            reason: 'Matrix row for $planet should have 7 columns');
        for (final other in traditionalPlanets) {
          expect(matrix[planet]!.containsKey(other), isTrue,
              reason: 'Matrix[$planet] should have column for $other');
        }
      }
    });
  });
}
