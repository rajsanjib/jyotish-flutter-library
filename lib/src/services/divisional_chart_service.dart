import '../models/divisional_chart_type.dart';
import '../models/planet.dart';
import '../models/planet_position.dart';
import '../models/vedic_chart.dart';

/// Service for calculating Divisional Charts (Varga).
class DivisionalChartService {
  /// Calculates a specific divisional chart from a base Rashi chart.
  VedicChart calculateDivisionalChart(
    VedicChart rashiChart,
    DivisionalChartType type,
  ) {
    if (type == DivisionalChartType.d1) {
      return rashiChart;
    }

    // Calculate D-Chart Ascendant
    final newAscendantDegree = _calculateVargaLongitude(
      rashiChart.ascendant,
      type,
    );

    // Create new House System (Whole Sign based on D-Ascendant)
    final dHouses = _createWholeSignHouses(newAscendantDegree);

    final finalPlanets = <Planet, VedicPlanetInfo>{};

    for (final entry in rashiChart.planets.entries) {
      final planet = entry.key;
      final originalInfo = entry.value;

      final newInfo = _calculatePlanetVarga(
        originalInfo: originalInfo,
        type: type,
        dHouses: dHouses,
      );
      finalPlanets[planet] = newInfo;
    }

    // Handle Rahu/Ketu special
    final rahuInfo = _calculatePlanetVarga(
      originalInfo: rashiChart.rahu,
      type: type,
      dHouses: dHouses,
    );

    final ketuInfo = KetuPosition(rahuPosition: rahuInfo.position);

    return VedicChart(
      dateTime: rashiChart.dateTime,
      location: rashiChart.location,
      latitude: rashiChart.latitude,
      longitudeCoord: rashiChart.longitudeCoord,
      houses: dHouses,
      planets: finalPlanets,
      rahu: rahuInfo,
      ketu: ketuInfo,
    );
  }

  VedicPlanetInfo _calculatePlanetVarga({
    required VedicPlanetInfo originalInfo,
    required DivisionalChartType type,
    required HouseSystem dHouses,
  }) {
    double newLongitude;
    double? vPositionInSign;
    double? vSubSpan;

    if (type == DivisionalChartType.d249) {
      final signIndex = (originalInfo.longitude / 30).floor();
      final degreeInSign = originalInfo.longitude % 30;
      final isOdd = (signIndex + 1) % 2 != 0;
      final details = _calculateD249Details(signIndex, degreeInSign, isOdd);
      newLongitude = details.longitude;
      vPositionInSign = details.posInSub;
      vSubSpan = details.span;
    } else {
      newLongitude = _calculateVargaLongitude(originalInfo.longitude, type);
      vPositionInSign = newLongitude % 30;
    }

    final newPosition = PlanetPosition(
      planet: originalInfo.position.planet,
      dateTime: originalInfo.position.dateTime,
      longitude: newLongitude,
      latitude: originalInfo.position.latitude,
      distance: originalInfo.position.distance,
      longitudeSpeed: originalInfo.position.longitudeSpeed,
      latitudeSpeed: originalInfo.position.latitudeSpeed,
      distanceSpeed: originalInfo.position.distanceSpeed,
    );

    final house = dHouses.getHouseForLongitude(newLongitude);

    // Calculate dignity in the D-Chart context
    final dignity = _calculateDignityForVarga(
      originalInfo.position.planet,
      newLongitude,
    );

    return VedicPlanetInfo(
      position: newPosition,
      house: house,
      dignity: dignity,
      isCombust: false,
      positionInSign: vPositionInSign,
      subSpan: vSubSpan,
    );
  }

  /// Calculates planetary dignity in a divisional chart.
  PlanetaryDignity _calculateDignityForVarga(Planet planet, double longitude) {
    final signIndex = (longitude / 30).floor() % 12;

    // Exaltation and debilitation
    final exaltationSign = _getExaltationSign(planet);
    final debilitationSign = _getDebilitationSign(planet);

    if (exaltationSign != null && signIndex == exaltationSign) {
      return PlanetaryDignity.exalted;
    }

    if (debilitationSign != null && signIndex == debilitationSign) {
      return PlanetaryDignity.debilitated;
    }

    // Own signs
    final ownSigns = _getOwnSigns(planet);
    if (ownSigns.contains(signIndex)) {
      return PlanetaryDignity.ownSign;
    }

    // Moola Trikona
    final moolaTrikona = _getMoolaTrikona(planet);
    if (moolaTrikona != null && signIndex == moolaTrikona) {
      return PlanetaryDignity.moolaTrikona;
    }

    // Friend/enemy/neutral based on sign lord
    final signLord = _getSignLord(signIndex);
    if (signLord != null) {
      return _calculateFriendshipDignity(planet, signLord);
    }

    return PlanetaryDignity.neutralSign;
  }

  /// Calculates friendship-based dignity.
  PlanetaryDignity _calculateFriendshipDignity(Planet planet, Planet signLord) {
    final relationships = _getPlanetaryRelationships();
    final relationship = relationships[planet]?[signLord] ?? 0;

    if (relationship == 1) {
      final reverseRelationship = relationships[signLord]?[planet] ?? 0;
      if (reverseRelationship == 1) {
        return PlanetaryDignity.greatFriend;
      }
      return PlanetaryDignity.friendSign;
    } else if (relationship == -1) {
      final reverseRelationship = relationships[signLord]?[planet] ?? 0;
      if (reverseRelationship == -1) {
        return PlanetaryDignity.greatEnemy;
      }
      return PlanetaryDignity.enemySign;
    }

    return PlanetaryDignity.neutralSign;
  }

  /// Gets planetary relationships map.
  Map<Planet, Map<Planet, int>> _getPlanetaryRelationships() {
    return {
      Planet.sun: {
        Planet.moon: 1,
        Planet.mars: 1,
        Planet.jupiter: 1,
        Planet.mercury: 0,
        Planet.venus: -1,
        Planet.saturn: -1,
      },
      Planet.moon: {
        Planet.sun: 0,
        Planet.mercury: 0,
        Planet.venus: 0,
        Planet.mars: 0,
        Planet.jupiter: 0,
        Planet.saturn: 0,
      },
      Planet.mars: {
        Planet.sun: 1,
        Planet.moon: 1,
        Planet.jupiter: 1,
        Planet.mercury: -1,
        Planet.venus: -1,
        Planet.saturn: 0,
      },
      Planet.mercury: {
        Planet.sun: 1,
        Planet.venus: 1,
        Planet.saturn: 1,
        Planet.mars: 0,
        Planet.jupiter: 0,
        Planet.moon: 0,
      },
      Planet.jupiter: {
        Planet.sun: 1,
        Planet.moon: 1,
        Planet.mars: 1,
        Planet.mercury: -1,
        Planet.venus: 0,
        Planet.saturn: 0,
      },
      Planet.venus: {
        Planet.mercury: 1,
        Planet.saturn: 1,
        Planet.mars: 0,
        Planet.jupiter: 0,
        Planet.sun: -1,
        Planet.moon: 0,
      },
      Planet.saturn: {
        Planet.mercury: 1,
        Planet.venus: 1,
        Planet.jupiter: 0,
        Planet.mars: -1,
        Planet.sun: -1,
        Planet.moon: -1,
      },
    };
  }

  /// Gets exaltation sign for a planet.
  int? _getExaltationSign(Planet planet) {
    const exaltations = {
      Planet.sun: 0, // Aries
      Planet.moon: 1, // Taurus
      Planet.mercury: 5, // Virgo
      Planet.venus: 11, // Pisces
      Planet.mars: 9, // Capricorn
      Planet.jupiter: 3, // Cancer
      Planet.saturn: 6, // Libra
    };
    return exaltations[planet];
  }

  /// Gets debilitation sign for a planet.
  int? _getDebilitationSign(Planet planet) {
    const debilitations = {
      Planet.sun: 6, // Libra
      Planet.moon: 7, // Scorpio
      Planet.mercury: 11, // Pisces
      Planet.venus: 5, // Virgo
      Planet.mars: 3, // Cancer
      Planet.jupiter: 9, // Capricorn
      Planet.saturn: 0, // Aries
    };
    return debilitations[planet];
  }

  /// Gets own signs for a planet.
  List<int> _getOwnSigns(Planet planet) {
    const ownSigns = {
      Planet.sun: [4], // Leo
      Planet.moon: [3], // Cancer
      Planet.mercury: [2, 5], // Gemini, Virgo
      Planet.venus: [1, 6], // Taurus, Libra
      Planet.mars: [0, 7], // Aries, Scorpio
      Planet.jupiter: [8, 11], // Sagittarius, Pisces
      Planet.saturn: [9, 10], // Capricorn, Aquarius
    };
    return ownSigns[planet] ?? [];
  }

  /// Gets Moola Trikona sign for a planet.
  int? _getMoolaTrikona(Planet planet) {
    const moolaTrikona = {
      Planet.sun: 4, // Leo
      Planet.moon: 1, // Taurus
      Planet.mercury: 5, // Virgo
      Planet.venus: 6, // Libra
      Planet.mars: 0, // Aries
      Planet.jupiter: 8, // Sagittarius
      Planet.saturn: 10, // Aquarius
    };
    return moolaTrikona[planet];
  }

  /// Gets the lord of a zodiac sign.
  Planet? _getSignLord(int signIndex) {
    const signLords = {
      0: Planet.mars, // Aries
      1: Planet.venus, // Taurus
      2: Planet.mercury, // Gemini
      3: Planet.moon, // Cancer
      4: Planet.sun, // Leo
      5: Planet.mercury, // Virgo
      6: Planet.venus, // Libra
      7: Planet.mars, // Scorpio
      8: Planet.jupiter, // Sagittarius
      9: Planet.saturn, // Capricorn
      10: Planet.saturn, // Aquarius
      11: Planet.jupiter, // Pisces
    };
    return signLords[signIndex];
  }

  HouseSystem _createWholeSignHouses(double ascendantLongitude) {
    final ascSignIndex = (ascendantLongitude / 30).floor();

    final cusps = List<double>.generate(12, (i) {
      return ((ascSignIndex + i) % 12) * 30.0;
    });

    final mc = (ascendantLongitude + 270) % 360;

    return HouseSystem(
      system: 'Whole Sign (Varga)',
      cusps: cusps,
      ascendant: ascendantLongitude,
      midheaven: mc,
    );
  }

  /// Calculates the absolute longitude (0-360) of a point in a divisional chart.
  double _calculateVargaLongitude(double longitude, DivisionalChartType type) {
    // 1. Get current sign and position in sign
    final signIndex = (longitude / 30).floor(); // 0-11
    final degreeInSign = longitude % 30;

    // 2. Determine the "Varga Sign Index" (0-11)
    final vargaSignIndex = _getVargaSign(signIndex, degreeInSign, type);

    // 3. Determine degrees in the new sign
    // Typically: (degreeInSign * N) % 30
    final parts = type.divisions;
    final degreesInNewSign = (degreeInSign * parts) % 30;

    return (vargaSignIndex * 30) + degreesInNewSign;
  }

  int _getVargaSign(
      int signIndex, double degreeInSign, DivisionalChartType type) {
    final sign = signIndex + 1; // 1-12
    final isOdd = sign % 2 != 0;
    final isMoveable = [1, 4, 7, 10].contains(sign);
    final isFixed = [2, 5, 8, 11].contains(sign);
    // final isDual = [3, 6, 9, 12].contains(sign);

    final element = (sign - 1) % 4; // 0=Fire, 1=Earth, 2=Air, 3=Water

    switch (type) {
      case DivisionalChartType.d1:
        return signIndex;

      case DivisionalChartType.d2: // Hora
        // Parashara Hora
        if (isOdd) {
          // 0-15 Sun (Leo/5), 15-30 Moon (Cancer/4)
          return (degreeInSign < 15) ? 4 : 3; // Index 4=Leo, 3=Can
        } else {
          // 0-15 Moon (Cancer/4), 15-30 Sun (Leo/5)
          return (degreeInSign < 15) ? 3 : 4;
        }

      case DivisionalChartType.d3: // Drekkana
        final part = (degreeInSign / 10).floor(); // 0, 1, 2
        // 1st part: same, 2nd: 5th, 3rd: 9th
        if (part == 0) return signIndex;
        if (part == 1) return (signIndex + 4) % 12;
        return (signIndex + 8) % 12;

      case DivisionalChartType.d4: // Chaturthamsa
        final part = (degreeInSign / (30 / 4)).floor(); // 0-3
        // 1: Same, 2: 4th, 3: 7th, 4: 10th (Kendra count) => Not exactly?
        // Rule:
        // 1st part: Same sign
        // 2nd part: 4th from sign
        // 3rd part: 7th from sign
        // 4th part: 10th from sign
        final offset = part * 3;
        return (signIndex + offset) % 12;

      case DivisionalChartType.d5: // Panchamsa
        // D5 rules:
        // For odd signs (Aries, Gemini, Leo, Libra, Sagittarius, Aquarius):
        //   Start from Aries (0)
        // For even signs (Taurus, Cancer, Virgo, Scorpio, Capricorn, Pisces):
        //   Start from Libra (6)
        final part = (degreeInSign / (30 / 5)).floor(); // 0-4
        if (isOdd) {
          // Start from Aries for odd signs
          return (0 + part) % 12;
        } else {
          // Start from Libra for even signs
          return (6 + part) % 12;
        }

      case DivisionalChartType.d6: // Shashthamsa
        // D6 rules:
        // For odd signs: Start from Aries (0)
        // For even signs: Start from Libra (6)
        final part = (degreeInSign / (30 / 6)).floor(); // 0-5
        if (isOdd) {
          return (0 + part) % 12;
        } else {
          return (6 + part) % 12;
        }

      case DivisionalChartType.d7: // Saptamsa
        final part = (degreeInSign / (30 / 7)).floor(); // 0-6
        if (isOdd) {
          // Start from same sign
          return (signIndex + part) % 12;
        } else {
          // Start from 7th sign
          return (signIndex + 6 + part) % 12;
        }

      case DivisionalChartType.d8: // Ashtamsa
        // D8 rules:
        // For movable signs (Aries, Cancer, Libra, Capricorn): Start from Aries
        // For fixed signs (Taurus, Leo, Scorpio, Aquarius): Start from Leo
        // For dual signs (Gemini, Virgo, Sagittarius, Pisces): Start from Sagittarius
        final part = (degreeInSign / (30 / 8)).floor(); // 0-7
        if (isMoveable) {
          return (0 + part) % 12;
        } else if (isFixed) {
          return (4 + part) % 12;
        } else {
          // Dual signs
          return (8 + part) % 12;
        }

      case DivisionalChartType.d9: // Navamsa
        final part = (degreeInSign / (30 / 9)).floor(); // 0-8

        // Fire (1,5,9): Start Aries (0)
        // Earth (2,6,10): Start Capricorn (9)
        // Air (3,7,11): Start Libra (6)
        // Water (4,8,12): Start Cancer (3)
        final startMap = {
          0: 0, // Fire -> Aries
          1: 9, // Earth -> Cap
          2: 6, // Air -> Libra
          3: 3, // Water -> Can
        };
        final startSignIndex = startMap[element]!;
        return (startSignIndex + part) % 12;

      case DivisionalChartType.d10: // Dasamsa
        final part = (degreeInSign / (30 / 10)).floor(); // 0-9
        if (isOdd) {
          // Start same
          return (signIndex + part) % 12;
        } else {
          // Start 9th
          return (signIndex + 8 + part) % 12;
        }

      case DivisionalChartType.d11: // Rudramsa
        // D11 rules:
        // For movable signs: Start from Aries
        // For fixed signs: Start from Leo
        // For dual signs: Start from Sagittarius
        final part = (degreeInSign / (30 / 11)).floor(); // 0-10
        if (isMoveable) {
          return (0 + part) % 12;
        } else if (isFixed) {
          return (4 + part) % 12;
        } else {
          // Dual signs
          return (8 + part) % 12;
        }

      case DivisionalChartType.d12: // Dwadasamsa
        final part = (degreeInSign / (30 / 12)).floor(); // 0-11
        // Starts from same sign
        return (signIndex + part) % 12;

      case DivisionalChartType.d16: // Shodasamsa
        final part = (degreeInSign / (30 / 16)).floor(); // 0-15
        if (isMoveable) {
          // Start Aries
          return (0 + part) % 12;
        } else if (isFixed) {
          // Start Leo
          return (4 + part) % 12;
        } else {
          // Start Sag
          return (8 + part) % 12;
        }

      case DivisionalChartType.d20: // Vimsamsa
        final part = (degreeInSign / (30 / 20)).floor(); // 0-19
        if (isMoveable) {
          // Start Aries
          return (0 + part) % 12;
        } else if (isFixed) {
          // Start Sag (Note: D16 was Leo/Sag, D20 is Sag/Leo? Verify!)
          // Standard: Moveable->Aries, Fixed->Sagittarius, Dual->Leo
          return (8 + part) % 12;
        } else {
          // Start Leo
          return (4 + part) % 12;
        }

      case DivisionalChartType.d24: // Chaturvimshamsha
        final part = (degreeInSign / (30 / 24)).floor(); // 0-23
        if (isOdd) {
          // Start Leo
          return (4 + part) % 12;
        } else {
          // Start Cancer
          return (3 + part) % 12;
        }

      case DivisionalChartType.d27: // Saptavimsamsa
        final part = (degreeInSign / (30 / 27)).floor(); // 0-26
        // Like Navamsa starts: Fire->Aries, Earth->Cancer, Air->Libra, Water->Cap
        // Wait, standard D27:
        // Fire signs: Start Aries
        // Earth signs: Start Cancer
        // Air signs: Start Libra
        // Water signs: Start Capricorn
        // This is 1, 4, 7, 10
        final startMap = {
          0: 0, // Fire -> Aries
          1: 3, // Earth -> Cancer
          2: 6, // Air -> Libra
          3: 9, // Water -> Cap
        };
        return (startMap[element]! + part) % 12;

      case DivisionalChartType.d30:
        return _calculateD30Sign(signIndex, degreeInSign);

      case DivisionalChartType.d40: // Khavedamsa
        final part = (degreeInSign / (30 / 40)).floor();
        if (isOdd) {
          // Start Aries
          return (0 + part) % 12;
        } else {
          // Start Libra
          return (6 + part) % 12;
        }

      case DivisionalChartType.d45: // Akshavedamsa
        final part = (degreeInSign / (30 / 45)).floor();
        if (isMoveable) {
          // Start Aries
          return (0 + part) % 12;
        } else if (isFixed) {
          // Start Leo
          return (4 + part) % 12;
        } else {
          // Start Sagittarius
          return (8 + part) % 12;
        }

      case DivisionalChartType.d60: // Shashtiamsa (60 divisions)
        // Traditional D60 calculation (Shashtiamsa)
        // Each sign is divided into 60 parts of 0.5° each
        //
        // Per BPHS and classical sources:
        // - For odd signs (Aries, Gemini, Leo, Libra, Sagittarius, Aquarius):
        //   Count forward: Part 0 = same sign, Part 59 = 11th sign ahead
        // - For even signs (Taurus, Cancer, Virgo, Scorpio, Capricorn, Pisces):
        //   Count backward: Part 0 = 9th sign from current (traditional method)
        //
        // Alternative simpler method (also valid): Continuous count for all
        final part = (degreeInSign / (30 / 60)).floor(); // 0-59
        
        // Using the sign-based approach (most traditional):
        if (isOdd) {
          // Odd signs: forward count from sign
          return (signIndex + part) % 12;
        } else {
          // Even signs: backward from 9th sign (traditional)
          // 9th from current sign = (signIndex + 8) % 12
          return (signIndex + 8 - part) % 12;
        }

      case DivisionalChartType.d150: // Nadi Amsa
        // D150: 150th division for micro-level analysis
        // Rules:
        // For odd signs: Count forward from Aries
        // For even signs: Count backward from Pisces
        final part = (degreeInSign / (30 / 150)).floor(); // 0-149
        if (isOdd) {
          // Count forward from Aries for odd signs
          return (0 + part) % 12;
        } else {
          // Count backward from Pisces for even signs
          return (11 - part) % 12;
        }

      case DivisionalChartType.d249: // 249 Subdivisions (KP Micro-Analysis)
        // D249 uses Vimshottari Dasha proportions, NOT equal divisions
        // Each of the 249 subdivisions is proportional to dasha years (total 120 years)
        // The sequence repeats: Ketu(7), Venus(20), Sun(6), Moon(10), Mars(7),
        //                        Rahu(18), Jupiter(16), Saturn(19), Mercury(17)
        return _calculateD249Sign(signIndex, degreeInSign, isOdd);
    }
  }

  ({double longitude, double posInSub, double span}) _calculateD249Details(
      int signIndex, double degreeInSign, bool isOdd) {
    final dashaData = [
      (planet: Planet.ketu, years: 7, degrees: 1.75),
      (planet: Planet.venus, years: 20, degrees: 5.0),
      (planet: Planet.sun, years: 6, degrees: 1.5),
      (planet: Planet.moon, years: 10, degrees: 2.5),
      (planet: Planet.mars, years: 7, degrees: 1.75),
      (planet: Planet.meanNode, years: 18, degrees: 4.5),
      (planet: Planet.jupiter, years: 16, degrees: 4.0),
      (planet: Planet.saturn, years: 19, degrees: 4.75),
      (planet: Planet.mercury, years: 17, degrees: 4.25),
    ];

    var cumulativeDegrees = 0.0;
    final startSign = isOdd ? signIndex : (signIndex + 8) % 12;

    for (var cycle = 0; cycle < 27; cycle++) {
      for (var i = 0; i < 9; i++) {
        final span = dashaData[i].degrees;
        if (degreeInSign < cumulativeDegrees + span) {
          final subIndex = cycle * 9 + i;
          final posPercent = (degreeInSign - cumulativeDegrees) / span;
          final vargaSignIndex = (startSign + subIndex) % 12;
          final degreesInSign = posPercent * 30.0;
          return (
            longitude: (vargaSignIndex * 30.0) + degreesInSign,
            posInSub: degreesInSign,
            span: span,
          );
        }
        cumulativeDegrees += span;
      }
    }

    for (var i = 0; i < 6; i++) {
      final span = dashaData[i].degrees;
      if (degreeInSign < cumulativeDegrees + span) {
        final subIndex = 243 + i;
        final posPercent = (degreeInSign - cumulativeDegrees) / span;
        final vargaSignIndex = (startSign + subIndex) % 12;
        final degreesInSign = posPercent * 30.0;
        return (
          longitude: (vargaSignIndex * 30.0) + degreesInSign,
          posInSub: degreesInSign,
          span: span,
        );
      }
      cumulativeDegrees += span;
    }

    return (longitude: (startSign * 30.0), posInSub: 0.0, span: 1.75);
  }

  int _calculateD249Sign(int signIndex, double degreeInSign, bool isOdd) {
    return _calculateD249Details(signIndex, degreeInSign, isOdd).longitude ~/
        30;
  }

  int _calculateD30Sign(int signIndex, double degree) {
    // Trimsamsa
    final sign = signIndex + 1;
    final isOdd = sign % 2 != 0;

    // Aries=0, Taurus=1, Gemini=2, Cancer=3, Leo=4, Virgo=5...
    // Mars=0,7; Sat=9,10; Jup=8,11; Merc=2,5; Ven=1,6

    if (isOdd) {
      // 0-5: Mars (Aries)
      if (degree < 5) return 0;
      // 5-10: Saturn (Aquarius)
      if (degree < 10) return 10;
      // 10-18: Jupiter (Sagittarius)
      if (degree < 18) return 8;
      // 18-25: Mercury (Gemini)
      if (degree < 25) return 2;
      // 25-30: Venus (Libra)
      return 6;
    } else {
      // 0-5: Venus (Taurus)
      if (degree < 5) return 1;
      // 5-12: Mercury (Virgo)
      if (degree < 12) return 5;
      // 12-20: Jupiter (Pisces)
      if (degree < 20) return 11;
      // 20-25: Saturn (Capricorn)
      if (degree < 25) return 9;
      // 25-30: Mars (Scorpio)
      return 7;
    }
  }
}
