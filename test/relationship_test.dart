import 'package:flutter_test/flutter_test.dart';
import 'package:jyotish_flutter_library_fork/jyotish.dart';

void main() {
  group('Planetary Relationships (Panchadha Maitri)', () {
    test('Moon and Venus natural relationship is Neutral', () {
      final relationship = RelationshipCalculator
          .naturalRelationships[Planet.moon]?[Planet.venus];
      expect(relationship, RelationshipType.neutral);
    });

    test('Rahu and Ketu natural relationships are defined', () {
      final rahuMer = RelationshipCalculator
          .naturalRelationships[Planet.meanNode]?[Planet.mercury];
      expect(rahuMer, RelationshipType.friend);

      final ketuSun =
          RelationshipCalculator.naturalRelationships[Planet.ketu]?[Planet.sun];
      expect(ketuSun, RelationshipType.friend);
    });

    test('Compound calculation maps correctly', () {
      expect(
          RelationshipCalculator.calculateCompound(
              RelationshipType.friend, RelationshipType.friend),
          RelationshipType.greatFriend);
      expect(
          RelationshipCalculator.calculateCompound(
              RelationshipType.neutral, RelationshipType.enemy),
          RelationshipType.enemy);
      expect(
          RelationshipCalculator.calculateCompound(
              RelationshipType.enemy, RelationshipType.enemy),
          RelationshipType.greatEnemy);
    });
  });
}
