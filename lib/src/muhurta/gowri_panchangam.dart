/// Enum representing the 8 types of Gowri Panchangam periods.
enum GowriType {
  amrit('Amrit', true, 'Auspicious, success in all endeavours'),
  rogam('Rogam', false, 'Inauspicious, disease, suffering'),
  uthi('Uthi', true, 'Auspicious, progress, upliftment'),
  labhamu('Labhamu', true, 'Auspicious, gain, profit'),
  dhana('Dhana', true, 'Auspicious, wealth, prosperity'),
  nirkku('Nirkku', false,
      'Inauspicious, obstacles, impediments'), // Also spelled 'Sor'
  visham('Visham', false, 'Inauspicious, poison, danger'),
  soolai('Soolai', false, 'Inauspicious, distress, pain');

  const GowriType(this.name, this.isAuspicious, this.description);

  final String name;
  final bool isAuspicious;
  final String description;
}

/// Represents a Gowri Panchangam period.
class GowriPanchangamInfo {
  const GowriPanchangamInfo({
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.isDaytime,
    required this.periodNumber,
  });

  /// The type of Gowri period.
  final GowriType type;

  /// Start time of the period.
  final DateTime startTime;

  /// End time of the period.
  final DateTime endTime;

  /// True if daytime period, False if nighttime.
  final bool isDaytime;

  /// The sequence number of the period (1-8).
  final int periodNumber;

  String get description =>
      '${type.name} ($periodNumber) - ${type.isAuspicious ? "Good" : "Bad"}';
}
