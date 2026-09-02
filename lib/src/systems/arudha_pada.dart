import 'package:jyotish/src/models/rashi.dart';

/// Represents a Jaimini Arudha Pada.
class ArudhaPadaInfo {
  const ArudhaPadaInfo({
    required this.houseNumber,
    required this.name,
    required this.sign,
    required this.houseFromLagna,
  });

  /// e.g. 1 for Lagna Pada (AL), 12 for Upapada (UL).
  final int houseNumber;

  /// Alias for [houseNumber] for legacy tests.
  int get house => houseNumber;

  /// Name of the Arudha (e.g., "AL", "UL", "A3").
  final String name;

  /// The sign (Rashi) where the Arudha falls.
  final Rashi sign;

  /// Alias for [sign] for legacy tests.
  Rashi get lord => sign;

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

  /// Alias for [allPadas] for legacy tests.
  Map<int, ArudhaPadaInfo> get arudhas => allPadas;

  /// Gets the Arudha Pada for a specific house number.
  ArudhaPadaInfo? getPada(int houseNumber) => allPadas[houseNumber];
}
