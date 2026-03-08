import 'package:jyotish/src/models/geographic_location.dart';
import 'package:jyotish/src/models/planet.dart';
import 'package:jyotish/src/models/vedic_chart.dart';

enum TimingQuality {
  veryFavorable('Very Favorable', 'Excellent period for this event'),
  favorable('Favorable', 'Good period with supportive factors'),
  neutral('Neutral', 'Mixed influences, depends on effort'),
  unfavorable('Unfavorable', 'Challenging time, delays possible'),
  challenging('Challenging', 'Strong malefic influence, better avoided');

  const TimingQuality(this.name, this.description);
  final String name;
  final String description;
}

enum EventCategory {
  marriage('Marriage / Relationship'),
  career('Career / Profession'),
  health('Health / Wellness'),
  travel('Travel / Relocation'),
  finance('Finance / Wealth'),
  spiritual('Spiritual / Initiations'),
  education('Education / Learning');

  const EventCategory(this.displayName);
  final String displayName;
}

class EventTimingRequest {
  const EventTimingRequest({
    required this.natalChart,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.eventType,
    this.granularity = const Duration(days: 1),
  });

  final VedicChart natalChart;
  final DateTime startDate;
  final DateTime endDate;
  final GeographicLocation location;
  final EventCategory eventType;
  final Duration granularity;
}

/// Represents a specific window of time (e.g. 1 day or 1 week) and its suitability for an event.
class EventTimingWindow {
  const EventTimingWindow({
    required this.start,
    required this.end,
    required this.quality,
    required this.dashaLord,
    required this.dashaContext,
    required this.reasons,
    required this.score,
  });

  /// The start of this timing window
  final DateTime start;

  /// The end of this timing window
  final DateTime end;

  /// The overarching quality classification
  final TimingQuality quality;

  /// The Mahadasha or Antardasha lord governing this period
  final Planet dashaLord;

  /// String context of the Dasha (e.g., "Jupiter Mahadasha / Venus Antardasha")
  final String dashaContext;

  /// Interpretive reasons why this window got its score
  final List<String> reasons;

  /// A composite score from 0.0 to 1.0 evaluating the window.
  /// 1.0 is the best possible timing.
  final double score;
}
