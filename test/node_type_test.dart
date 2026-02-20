import 'package:jyotish/jyotish.dart';
import 'package:test/test.dart';

void main() {
  group('NodeType', () {
    test('NodeType enum has correct values', () {
      expect(NodeType.values, hasLength(2));
      expect(NodeType.meanNode.description, 'Mean Node');
      expect(NodeType.trueNode.description, 'True Node');
    });

    test('NodeType returns correct planet', () {
      expect(NodeType.meanNode.planet, Planet.meanNode);
      expect(NodeType.trueNode.planet, Planet.trueNode);
    });

    test('NodeType has technical descriptions', () {
      expect(NodeType.meanNode.technicalDescription, contains('Average'));
      expect(NodeType.trueNode.technicalDescription, contains('Actual'));
    });
  });

  group('CalculationFlags with NodeType', () {
    test('Default CalculationFlags uses Mean Node', () {
      final flags = CalculationFlags.defaultFlags();
      expect(flags.nodeType, NodeType.meanNode);
      expect(flags.nodeType.planet, Planet.meanNode);
    });

    test('Can create CalculationFlags with True Node', () {
      final flags = const CalculationFlags(
        nodeType: NodeType.trueNode,
      );
      expect(flags.nodeType, NodeType.trueNode);
      expect(flags.nodeType.planet, Planet.trueNode);
    });

    test('Can create CalculationFlags with custom node type', () {
      final flags = CalculationFlags(
        nodeType: NodeType.trueNode,
      );

      final updatedFlags = flags.copyWith(nodeType: NodeType.trueNode);
      expect(updatedFlags.nodeType, NodeType.trueNode);
      expect(updatedFlags.nodeType.planet, Planet.trueNode);
      expect(updatedFlags.siderealMode, flags.siderealMode);
      expect(updatedFlags.useTopocentric, false);
      expect(updatedFlags.useSwissEphemeris, true);
    });

    test('copyWith can change nodeType', () {
      final flags = CalculationFlags.defaultFlags();
      expect(flags.nodeType, NodeType.meanNode);

      final updatedFlags = flags.copyWith(nodeType: NodeType.trueNode);
      expect(updatedFlags.nodeType, NodeType.trueNode);
      expect(updatedFlags.siderealMode, flags.siderealMode);
    });

    test('toString includes nodeType', () {
      final flags = CalculationFlags.withNodeType(NodeType.trueNode);
      final str = flags.toString();
      expect(str, contains('nodeType'));
      expect(str, contains('trueNode'));
    });

    test('CalculationFlags preserves other settings when changing nodeType',
        () {
      final originalFlags = CalculationFlags(
        siderealMode: SiderealMode.krishnamurti,
        useTopocentric: true,
        nodeType: NodeType.meanNode,
      );

      final newFlags = originalFlags.copyWith(nodeType: NodeType.trueNode);

      expect(newFlags.nodeType, NodeType.trueNode);
      expect(newFlags.siderealMode, SiderealMode.krishnamurti);
      expect(newFlags.useTopocentric, true);
      expect(newFlags.useSwissEphemeris, true);
    });
  });

  group('Rahu Node Types are available', () {
    test('Planet.meanNode is available', () {
      expect(Planet.meanNode.swissEphId, equals(10));
      expect(Planet.meanNode.displayName, equals('Rahu'));
    });

    test('Planet.trueNode is available', () {
      expect(Planet.trueNode.swissEphId, equals(11));
      expect(Planet.trueNode.displayName, equals('Rahu (True)'));
    });

    test('Planet.lunarNodes contains both', () {
      expect(Planet.lunarNodes, contains(Planet.meanNode));
      expect(Planet.lunarNodes, contains(Planet.trueNode));
      expect(Planet.lunarNodes, contains(Planet.ketu));
    });
  });
}
