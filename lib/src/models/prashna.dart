import 'rashi.dart';

/// Represents special points (Sphutas) in Prashna astrology.
class PrashnaSphutas {
  const PrashnaSphutas({
    required this.trisphuta,
    required this.chatursphuta,
    required this.panchasphuta,
    this.pranaSphuta,
    this.dehaSphuta,
    this.mrityuSphuta,
  });

  /// Lagna + Moon + Gulika
  final double trisphuta;

  /// Trisphuta + Sun
  final double chatursphuta;

  /// Chatursphuta + Rahu
  final double panchasphuta;

  /// Breath point
  final double? pranaSphuta;

  /// Body point
  final double? dehaSphuta;

  /// Death point
  final double? mrityuSphuta;

  @override
  String toString() {
    return 'Trisphuta: ${trisphuta.toStringAsFixed(2)}°, Chatursphuta: ${chatursphuta.toStringAsFixed(2)}°';
  }
}

/// Result of a Prashna (Horary) analysis.
class PrashnaResult {
  const PrashnaResult({
    required this.arudhaLagna,
    required this.sphutas,
    required this.isAuspicious,
    required this.summary,
  });

  /// The Arudha Lagna calculated from seed
  final Rashi arudhaLagna;

  /// Special points
  final PrashnaSphutas sphutas;

  /// Overall assessment
  final bool isAuspicious;

  /// Brief analysis text
  final String summary;
}
