import 'planet.dart';

/// Types of relationships between planets.
enum RelationshipType {
  greatFriend('Great Friend'),
  friend('Friend'),
  neutral('Neutral'),
  enemy('Enemy'),
  greatEnemy('Great Enemy');

  const RelationshipType(this.displayName);
  final String displayName;

  @override
  String toString() => displayName;
}

/// Nature of a planetary relationship component.
enum RelationshipNature { natural, temporary, compound }

/// Represents the relationship between two planets.
class PlanetaryRelationship {
  const PlanetaryRelationship({
    required this.planet,
    required this.otherPlanet,
    required this.natural,
    required this.temporary,
    required this.compound,
  });

  final Planet planet;
  final Planet otherPlanet;
  final RelationshipType natural;
  final RelationshipType temporary;
  final RelationshipType compound;

  @override
  String toString() =>
      '${planet.displayName} to ${otherPlanet.displayName}: Compound: $compound (Natural: $natural, Temporary: $temporary)';
}

/// Helper for calculating planetary relationships.
class RelationshipCalculator {
  /// Natural relationships (Naisargika Maitri).
  static const Map<Planet, Map<Planet, RelationshipType>> naturalRelationships =
      {
    Planet.sun: {
      Planet.moon: RelationshipType.friend,
      Planet.mars: RelationshipType.friend,
      Planet.jupiter: RelationshipType.friend,
      Planet.venus: RelationshipType.enemy,
      Planet.saturn: RelationshipType.enemy,
      Planet.mercury: RelationshipType.neutral,
    },
    Planet.moon: {
      Planet.sun: RelationshipType.friend,
      Planet.mercury: RelationshipType.friend,
      Planet.mars: RelationshipType.neutral,
      Planet.jupiter: RelationshipType.neutral,
      Planet.venus: RelationshipType.neutral,
      Planet.saturn: RelationshipType.neutral,
    },
    Planet.mars: {
      Planet.sun: RelationshipType.friend,
      Planet.moon: RelationshipType.friend,
      Planet.jupiter: RelationshipType.friend,
      Planet.mercury: RelationshipType.enemy,
      Planet.venus: RelationshipType.neutral,
      Planet.saturn: RelationshipType.neutral,
    },
    Planet.mercury: {
      Planet.sun: RelationshipType.friend,
      Planet.venus: RelationshipType.friend,
      Planet.moon: RelationshipType.enemy,
      Planet.mars: RelationshipType.neutral,
      Planet.jupiter: RelationshipType.neutral,
      Planet.saturn: RelationshipType.neutral,
    },
    Planet.jupiter: {
      Planet.sun: RelationshipType.friend,
      Planet.moon: RelationshipType.friend,
      Planet.mars: RelationshipType.friend,
      Planet.mercury: RelationshipType.enemy,
      Planet.venus: RelationshipType.enemy,
      Planet.saturn: RelationshipType.neutral,
    },
    Planet.venus: {
      Planet.mercury: RelationshipType.friend,
      Planet.saturn: RelationshipType.friend,
      Planet.sun: RelationshipType.enemy,
      Planet.moon: RelationshipType.enemy,
      Planet.mars: RelationshipType.neutral,
      Planet.jupiter: RelationshipType.neutral,
    },
    Planet.saturn: {
      Planet.mercury: RelationshipType.friend,
      Planet.venus: RelationshipType.friend,
      Planet.sun: RelationshipType.enemy,
      Planet.moon: RelationshipType.enemy,
      Planet.mars: RelationshipType.enemy,
      Planet.jupiter: RelationshipType.neutral,
    },
  };

  /// Calculates the compound relationship (Panchadha Maitri).
  static RelationshipType calculateCompound(
      RelationshipType natural, RelationshipType temporary) {
    if (natural == RelationshipType.friend) {
      return temporary == RelationshipType.friend
          ? RelationshipType.greatFriend
          : RelationshipType.neutral;
    } else if (natural == RelationshipType.enemy) {
      return temporary == RelationshipType.friend
          ? RelationshipType.neutral
          : RelationshipType.greatEnemy;
    } else {
      // Neutral
      return temporary == RelationshipType.friend
          ? RelationshipType.friend
          : RelationshipType.enemy;
    }
  }

  /// Calculates temporary relationship (Tatkalika Maitri) based on positions.
  ///
  /// Planets in 2nd, 3rd, 4th, 10th, 11th, and 12th houses from a planet are friends.
  static RelationshipType calculateTemporary(int house1, int house2) {
    // House indices are 0-11 in this logic or 1-12.
    // Let's assume 1-based house numbers as in VedicChart.
    final relativeHouse = (house2 - house1 + 12) % 12;

    // Distances:
    // 1 (2nd house), 2 (3rd), 3 (4th), 9 (10th), 10 (11th), 11 (12th)
    if ([1, 2, 3, 9, 10, 11].contains(relativeHouse)) {
      return RelationshipType.friend;
    }
    return RelationshipType.enemy;
  }
}
