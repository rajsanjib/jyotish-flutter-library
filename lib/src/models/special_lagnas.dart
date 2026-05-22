/// Represents the calculated mathematical points (Lagnas) of wealth, power, and prosperity.
class SpecialLagnas {
  const SpecialLagnas({
    required this.horaLagna,
    required this.ghatiLagna,
    required this.sreeLagna,
  });

  /// Hora Lagna degree (0-360) used for financial prosperity and Jaimini longevity.
  final double horaLagna;

  /// Ghati Lagna degree (0-360) used for assessing power, authority, and fame.
  final double ghatiLagna;

  /// Sree Lagna degree (0-360), the point of Lakshmi (prosperity) based on the Moon's exact nakshatra fraction.
  final double sreeLagna;

  Map<String, dynamic> toJson() => {
        'horaLagna': horaLagna,
        'ghatiLagna': ghatiLagna,
        'sreeLagna': sreeLagna,
      };
}
