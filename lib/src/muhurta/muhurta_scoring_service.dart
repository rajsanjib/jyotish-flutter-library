import 'package:jyotish/src/models/geographic_location.dart';
import 'package:jyotish/src/panchanga/panchanga_service.dart';
import 'package:jyotish/src/strength/panchang_strength_service.dart';
import 'package:jyotish/src/muhurta/tarabalam.dart';
import 'package:jyotish/src/muhurta/chandrabalam.dart';
import 'package:jyotish/src/panchanga/panchanga.dart';

/// Service for scanning and scoring time suitability (Muhurta) based on Panchanga and native factors.
class MuhurtaScoringService {
  const MuhurtaScoringService(
      this._panchangaService, this._panchangStrengthService);

  final PanchangaService _panchangaService;
  final PanchangStrengthService _panchangStrengthService;

  /// Calculates a comprehensive suitability score (0-100) for a given date/time and location.
  ///
  /// Incorporates:
  /// - Tithi (20% weight)
  /// - Nakshatra (20% weight)
  /// - Weekday (Vara) (15% weight)
  /// - Yoga (10% weight)
  /// - Karana (10% weight)
  /// - Native Tarabalam (15% weight, optional)
  /// - Native Chandrabalam (10% weight, optional)
  Future<MuhurtaScoreResult> calculateMuhurtaScore({
    required DateTime dateTime,
    required GeographicLocation location,
    int? birthNakshatraIndex,
    int? birthRashiIndex,
  }) async {
    final panchanga = await _panchangaService.calculatePanchanga(
      dateTime: dateTime,
      location: location,
    );

    final tithiScore = _scoreTithi(panchanga.tithi.number);
    final nakshatraScore = _scoreNakshatra(panchanga.nakshatra.number);
    final varaScore = _scoreVara(panchanga.vara.weekday);
    final yogaScore = _scoreYoga(panchanga.yoga.number);
    final karanaScore = _scoreKarana(panchanga.karana.name);

    double? tarabalamScore;
    double? chandrabalamScore;

    if (birthNakshatraIndex != null) {
      final tara = _panchangStrengthService.calculateTarabalam(
        birthNakshatraIndex: birthNakshatraIndex,
        currentNakshatra: panchanga.nakshatra,
      );
      tarabalamScore = tara.taraType.isAuspicious
          ? 15.0
          : (tara.taraType == TaraType.janma ? 8.0 : 0.0);
    }

    if (birthRashiIndex != null) {
      final chandra = _panchangStrengthService.calculateChandrabalam(
        currentMoonNakshatra: panchanga.nakshatra,
      );
      final entry = chandra.entries.firstWhere(
        (e) => e.rashiIndex == birthRashiIndex,
        orElse: () => const ChandrabalamEntry(
          rashiIndex: -1,
          level: ChandrabalamLevel.weak,
          position: 12,
        ),
      );
      if (entry.level == ChandrabalamLevel.strong) {
        chandrabalamScore = 10.0;
      } else if (entry.level == ChandrabalamLevel.moderate) {
        chandrabalamScore = 6.0;
      } else {
        chandrabalamScore = 0.0;
      }
    }

    double maxPossibleScore = 75.0;
    double earnedScore =
        tithiScore + nakshatraScore + varaScore + yogaScore + karanaScore;

    if (tarabalamScore != null) {
      maxPossibleScore += 15.0;
      earnedScore += tarabalamScore;
    }
    if (chandrabalamScore != null) {
      maxPossibleScore += 10.0;
      earnedScore += chandrabalamScore;
    }

    final finalScore = (earnedScore / maxPossibleScore) * 100.0;

    return MuhurtaScoreResult(
      dateTime: dateTime,
      panchanga: panchanga,
      tithiScore: tithiScore,
      nakshatraScore: nakshatraScore,
      varaScore: varaScore,
      yogaScore: yogaScore,
      karanaScore: karanaScore,
      tarabalamScore: tarabalamScore,
      chandrabalamScore: chandrabalamScore,
      finalScore: finalScore,
    );
  }

  /// Scans a given time window using the specified steps to find and rank the most auspicious Muhurtas.
  Future<List<MuhurtaScoreResult>> scanMuhurtaSuitability({
    required DateTime startDateTime,
    required DateTime endDateTime,
    required GeographicLocation location,
    required Duration step,
    int? birthNakshatraIndex,
    int? birthRashiIndex,
  }) async {
    final results = <MuhurtaScoreResult>[];
    var current = startDateTime;
    while (current.isBefore(endDateTime)) {
      final res = await calculateMuhurtaScore(
        dateTime: current,
        location: location,
        birthNakshatraIndex: birthNakshatraIndex,
        birthRashiIndex: birthRashiIndex,
      );
      results.add(res);
      current = current.add(step);
    }
    results.sort((a, b) => b.finalScore.compareTo(a.finalScore));
    return results;
  }

  double _scoreTithi(int tithiNum) {
    if (const [4, 9, 14, 19, 24, 29].contains(tithiNum)) {
      return 5.0;
    }
    if (tithiNum == 30) {
      return 0.0;
    }
    if (const [2, 3, 5, 7, 10, 11, 13, 15].contains(tithiNum)) {
      return 20.0;
    }
    return 12.0;
  }

  double _scoreNakshatra(int nakshatraNum) {
    const auspicious = {1, 4, 5, 8, 12, 13, 14, 17, 21, 22, 23, 24, 26, 27};
    const inauspicious = {2, 3, 6, 9, 10, 16, 18, 19, 20, 25};

    if (auspicious.contains(nakshatraNum)) {
      return 20.0;
    }
    if (inauspicious.contains(nakshatraNum)) {
      return 5.0;
    }
    return 12.0;
  }

  double _scoreVara(int weekday) {
    if (const [4, 5, 3, 1].contains(weekday)) {
      return 15.0;
    }
    if (weekday == 0) {
      return 10.0;
    }
    return 5.0;
  }

  double _scoreYoga(int yogaNum) {
    const inauspicious = {1, 6, 9, 10, 13, 15, 17, 19, 27};
    if (inauspicious.contains(yogaNum)) {
      return 2.0;
    }
    return 10.0;
  }

  double _scoreKarana(String karanaName) {
    if (karanaName == 'Vishti') {
      return 2.0;
    }
    const auspicious = {
      'Bava',
      'Balava',
      'Kaulava',
      'Taitila',
      'Garaja',
      'Vanija'
    };
    if (auspicious.contains(karanaName)) {
      return 10.0;
    }
    return 6.0;
  }
}

/// The result returned by the Muhurta suitability scoring engine.
class MuhurtaScoreResult {
  const MuhurtaScoreResult({
    required this.dateTime,
    required this.panchanga,
    required this.tithiScore,
    required this.nakshatraScore,
    required this.varaScore,
    required this.yogaScore,
    required this.karanaScore,
    this.tarabalamScore,
    this.chandrabalamScore,
    required this.finalScore,
  });

  final DateTime dateTime;
  final Panchanga panchanga;
  final double tithiScore;
  final double nakshatraScore;
  final double varaScore;
  final double yogaScore;
  final double karanaScore;
  final double? tarabalamScore;
  final double? chandrabalamScore;
  final double finalScore;
}
