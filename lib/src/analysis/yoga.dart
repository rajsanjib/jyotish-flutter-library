/// Represents a Natal Yoga detected in a Vedic Chart.
class NatalYoga {
  const NatalYoga({
    required this.key,
    required this.name,
    required this.category,
    required this.description,
    required this.benefits,
    required this.isPresent,
    this.explanation = '',
    this.divisionalChart = 'D1',
  });

  /// Unique key of the yoga (e.g. 'gaja_kesari_yoga')
  final String key;

  /// Display name of the yoga (e.g. 'Gaja-Kesari Yoga')
  final String name;

  /// Astrological category of the yoga (e.g. 'Chandra Yogas', 'Raja Yogas')
  final String category;

  /// Astrological criteria/rule definition
  final String description;

  /// Effects / benefits of the yoga
  final String benefits;

  /// Whether the yoga is present in the chart
  final bool isPresent;

  /// Detailed explanation of why it is present in the specific chart
  final String explanation;

  /// Divisional chart in which the yoga was detected (default: D1)
  final String divisionalChart;

  /// Converts this NatalYoga to a JSON map.
  Map<String, dynamic> toJson() => {
        'key': key,
        'name': name,
        'category': category,
        'description': description,
        'benefits': benefits,
        'isPresent': isPresent,
        'explanation': explanation,
        'divisionalChart': divisionalChart,
      };

  @override
  String toString() => '$name: ${isPresent ? "Present" : "Absent"}';
}
