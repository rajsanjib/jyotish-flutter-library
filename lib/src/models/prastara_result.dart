import 'dart:typed_data';
import 'package:jyotish/src/models/planet.dart';

/// Represents the Prastara Ashtakavarga grid for a planet.
class PrastaraResult {
  const PrastaraResult({required this.planet, required this.grid});

  /// The target planet this grid is calculated for.
  final Planet planet;

  /// Flat 96-element binary contribution grid (8 rows × 12 columns).
  ///
  /// Rows are the 8 contributing points in order:
  /// 0: Sun, 1: Moon, 2: Mars, 3: Mercury, 4: Jupiter, 5: Venus, 6: Saturn, 7: Lagna (Ascendant).
  ///
  /// Columns are the 12 signs:
  /// 0: Aries (Mesha), 1: Taurus (Vrishabha), ..., 11: Pisces (Meena).
  ///
  /// Value is 1 (bindu present) or 0 (rekha).
  final Uint8List grid;

  /// Gets the contribution for a specific point and sign.
  /// Point: 0-7, Sign: 0-11.
  int getContribution(int pointIndex, int signIndex) {
    if (pointIndex < 0 || pointIndex > 7) {
      throw ArgumentError('Point index must be between 0 and 7');
    }
    if (signIndex < 0 || signIndex > 11) {
      throw ArgumentError('Sign index must be between 0 and 11');
    }
    return grid[pointIndex * 12 + signIndex];
  }
}
