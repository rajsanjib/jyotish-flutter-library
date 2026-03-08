import 'package:jyotish/src/muhurta/chandrabalam.dart';
import 'package:jyotish/src/panchanga/nakshatra.dart';
import 'package:jyotish/src/muhurta/tarabalam.dart';

/// Service for calculating astrological strength metrics (Chandrabalam, Tarabalam).
class PanchangStrengthService {
  /// Calculates Chandrabalam (Moon strength) for all 12 Rashis based on current Moon's Nakshatra.
  ChandrabalamInfo calculateChandrabalam({
    required NakshatraInfo currentMoonNakshatra,
  }) {
    // Determine Moon's Rashi (0-11) based on longitude
    final rashiIndex = (currentMoonNakshatra.longitude / 30).floor();

    final entries = <ChandrabalamEntry>[];
    for (int i = 0; i < 12; i++) {
      // Calculate position of the Moon's Rashi relative to the evaluated Rashi
      // Formula difference logic: From evaluator Rashi (i) to Moon's Rashi
      final position = ((rashiIndex - i + 12) % 12) + 1;

      ChandrabalamLevel level;
      // Depending on the tradition, Chandrabalam is considered strong if Moon is in the
      // 1st, 3rd, 6th, 7th, 10th, or 11th house from the natal Moon / native's Rashi.
      if (const [1, 3, 6, 7, 10, 11].contains(position)) {
        level = ChandrabalamLevel.strong;
      } else if (const [2, 5, 9].contains(position)) {
        level = ChandrabalamLevel.moderate;
      } else {
        level = ChandrabalamLevel.weak;
      }

      entries.add(ChandrabalamEntry(
        rashiIndex: i,
        level: level,
        position: position,
      ));
    }

    return ChandrabalamInfo(
      moonRashiIndex: rashiIndex,
      entries: entries,
    );
  }

  /// Calculates Tarabalam (Star strength) for a specific birth Nakshatra.
  TarabalamInfo calculateTarabalam({
    required int birthNakshatraIndex,
    required NakshatraInfo currentNakshatra,
  }) {
    final currentIndex = currentNakshatra.number - 1; // 0-26

    // Position count from birth nakshatra to current (1-27)
    final count = ((currentIndex - birthNakshatraIndex + 27) % 27) + 1;

    // Group into 9 types (modulo 9, mapped to 0-8)
    final taraIndex = (count - 1) % 9;

    final taraType = TaraType.values[taraIndex];

    return TarabalamInfo(
      currentNakshatraIndex: currentIndex,
      birthNakshatraIndex: birthNakshatraIndex,
      taraType: taraType,
    );
  }
}
