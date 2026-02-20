import 'rashi.dart';

/// Represents a Jaimini Arudha Pada.
class ArudhaPadaInfo {
  const ArudhaPadaInfo({
    required this.houseNumber,
    required this.name,
    required this.sign,
    required this.houseFromLagna,
  });

  /// The house number (1-12) for which this is the Arudha.
  /// e.g. 1 for Lagna Pada (AL), 12 for Upapada (UL).
  final int houseNumber;

  /// Name of the Arudha (e.g., "AL", "UL", "A3").
  final String name;

  /// The sign (Rashi) where the Arudha falls.
  final Rashi sign;

  /// The house number from Lagna where the Arudha falls (1-12).
  final int houseFromLagna;
}

/// Result of Arudha Pada calculations.
class ArudhaPadaResult {
  const ArudhaPadaResult({
    required this.arudhaLagna,
    required this.upapada,
    required this.allPadas,
  });

  /// Arudha Lagna (AL) - Arudha of the 1st House.
  final ArudhaPadaInfo arudhaLagna;

  /// Upapada Lagna (UL) - Arudha of the 12th House.
  final ArudhaPadaInfo upapada;

  /// All 12 Arudha Padas keyed by house number (1-12).
  final Map<int, ArudhaPadaInfo> allPadas;

  /// Gets the Arudha Pada for a specific house number.
  ArudhaPadaInfo? getPada(int houseNumber) => allPadas[houseNumber];
}
