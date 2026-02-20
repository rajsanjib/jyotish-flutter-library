import '../models/divisional_chart_type.dart';
import '../models/geographic_location.dart';
import '../models/planet.dart';
import '../models/vedic_chart.dart';
import 'divisional_chart_service.dart';
import 'ephemeris_service.dart';

/// Service for calculating Shadbala (Six-fold Strength) of planets.
///
/// Shadbala consists of six types of strength:
/// 1. Sthana Bala (Positional Strength)
/// 2. Dig Bala (Directional Strength)
/// 3. Kala Bala (Temporal Strength)
/// 4. Chesta Bala (Motional Strength)
/// 5. Naisargika Bala (Natural Strength)
/// 6. Drik Bala (Aspectual Strength)
class ShadbalaService {
  ShadbalaService(this._ephemerisService);
  final EphemerisService _ephemerisService;
  final DivisionalChartService _divisionalChartService =
      DivisionalChartService();

  /// Calculates complete Shadbala for all planets in a chart.
  Future<Map<Planet, ShadbalaResult>> calculateShadbala(
      VedicChart chart) async {
    final results = <Planet, ShadbalaResult>{};

    for (final entry in chart.planets.entries) {
      final planet = entry.key;
      final planetInfo = entry.value;

      results[planet] = await _calculatePlanetShadbala(
        planet: planet,
        planetInfo: planetInfo,
        chart: chart,
      );
    }

    return results;
  }

  /// Calculates Shadbala for a single planet.
  Future<ShadbalaResult> _calculatePlanetShadbala({
    required Planet planet,
    required VedicPlanetInfo planetInfo,
    required VedicChart chart,
  }) async {
    // 1. Sthana Bala (Positional Strength)
    final sthanaBala = _calculateSthanaBala(planet, planetInfo, chart);

    // 2. Dig Bala (Directional Strength)
    final digBala = _calculateDigBala(planet, planetInfo);

    // 3. Kala Bala (Temporal Strength)
    final kalaBala = await _calculateKalaBala(planet, planetInfo, chart);

    // 4. Chesta Bala (Motional Strength)
    final chestaBala = _calculateChestaBala(planet, planetInfo);

    // 5. Naisargika Bala (Natural Strength)
    final naisargikaBala = _calculateNaisargikaBala(planet);

    // 6. Drik Bala (Aspectual Strength)
    final drikBala = _calculateDrikBala(planet, planetInfo, chart);

    // Calculate total Shadbala
    final totalBala = sthanaBala +
        digBala +
        kalaBala +
        chestaBala +
        naisargikaBala +
        drikBala;

    // Determine strength category
    final strengthCategory = _getStrengthCategory(totalBala);

    // 7. Uchcha Bala (Exaltation Strength - needed for Phala calculation)
    final uchchaBala =
        _calculateUchchaBala(planet, planetInfo.position.longitude);

    // 8. Ishta & Kashta Phala
    final ishtaPhala = (uchchaBala * chestaBala) / 60.0;
    final kashtaPhala = ((60.0 - uchchaBala) * (60.0 - chestaBala)) / 60.0;
    final netPhala = ishtaPhala - kashtaPhala;

    return ShadbalaResult(
      planet: planet,
      sthanaBala: sthanaBala,
      digBala: digBala,
      kalaBala: kalaBala,
      chestaBala: chestaBala,
      naisargikaBala: naisargikaBala,
      drikBala: drikBala,
      totalBala: totalBala,
      ishtaPhala: ishtaPhala,
      kashtaPhala: kashtaPhala,
      netPhala: netPhala,
      strengthCategory: strengthCategory,
    );
  }

  /// Calculates Uchcha Bala for external use.
  double getUchchaBalaOnly(Planet planet, double longitude) =>
      _calculateUchchaBala(planet, longitude);

  /// Calculates Vimshopaka Bala (Strength in 20/16/10/7 vargas).
  ///
  /// This is a skeleton implementation for Phase 3.
  double calculateVimshopakaBala(Planet planet, VedicChart chart) {
    // Vimshopaka Bala (20-point strength)
    // Using Shad Varga (6 charts) scheme as standard base:
    // Rashi (6), Hora (2), Drekkana (4), Navamsa (5), Dwadasamsa (2), Trimsamsa (1)
    // Total Weights = 20.

    // Check if Nodes (often excluded or treated differently, but usually calculated)
    if (Planet.lunarNodes.contains(planet))
      return 0.0; // Or standard default mid-range

    double totalWeightedScore = 0.0;
    // The weights themselves sum to 20.
    // If a planet is Exalted (20 points) in ALL vargas, it gets:
    // (6*20 + 2*20 + ... ) / 20 = 20.
    // So we sum (Weight * Points) / 20.

    final vargas = _getShadvargaCharts();

    for (final vargaType in vargas) {
      final weight = _getVimshopakaWeight(vargaType);

      // Calculate/Get the D-Chart
      final divChart =
          _divisionalChartService.calculateDivisionalChart(chart, vargaType);
      final planetInfo = divChart.getPlanet(planet);

      if (planetInfo != null) {
        final points = _getVimshopakaPoints(planetInfo.dignity);
        totalWeightedScore += (weight * points);
      }
    }

    return totalWeightedScore / 20.0;
  }

  List<DivisionalChartType> _getShadvargaCharts() {
    return [
      DivisionalChartType.d1, // Rashi
      DivisionalChartType.d2, // Hora
      DivisionalChartType.d3, // Drekkana
      DivisionalChartType.d9, // Navamsa
      DivisionalChartType.d12, // Dwadasamsa
      DivisionalChartType.d30, // Trimsamsa
    ];
  }

  double _getVimshopakaWeight(DivisionalChartType type) {
    return switch (type) {
      DivisionalChartType.d1 => 6.0,
      DivisionalChartType.d2 => 2.0,
      DivisionalChartType.d3 => 4.0,
      DivisionalChartType.d9 => 5.0,
      DivisionalChartType.d12 => 2.0,
      DivisionalChartType.d30 => 1.0,
      _ => 0.0,
    };
  }

  double _getVimshopakaPoints(PlanetaryDignity dignity) {
    return switch (dignity) {
      PlanetaryDignity.exalted => 20.0,
      PlanetaryDignity.ownSign =>
        20.0, // Or sometimes 18? usually 20 in Vimshopaka
      PlanetaryDignity.greatFriend => 18.0,
      PlanetaryDignity.friendSign => 15.0,
      PlanetaryDignity.neutralSign => 10.0,
      PlanetaryDignity.enemySign => 7.0,
      PlanetaryDignity.greatEnemy => 5.0,
      PlanetaryDignity.debilitated => 0.0,
      _ =>
        10.0, // Default for MoolaTrikona (usually treated as Own/Exalted or High) -> Let's map MoolaTrikona to 20 or 18? usually same as Own/Exalted in this scheme
    };
  }

  double _calculateSthanaBala(
      Planet planet, VedicPlanetInfo planetInfo, VedicChart chart) {
    var strength = 0.0;

    // 1. Precise Uchcha Bala (Exaltation Strength)
    strength += _calculateUchchaBala(planet, planetInfo.position.longitude);

    // 2. Saptavargaja Bala (Seven-fold divisional dignity)
    strength += _calculateSaptavargajaBala(planet, chart);

    // 3. Ojayugmarasyamsa Bala (Odd/Even sign and Navamsa)
    strength += _calculateOjayugmarasyamsaBala(
        planet, planetInfo.position.longitude, chart);

    // 4. Drekkana Bala
    strength += _calculateDrekkanaBala(planet, planetInfo.position.longitude);

    // 5. Kendra Bala (House placement)
    strength += _calculateKendraBala(planetInfo.house);

    return strength;
  }

  /// Calculates precise Uchcha Bala (Exaltation Strength).
  double _calculateUchchaBala(Planet planet, double longitude) {
    final deepExaltation = _deepExaltationPoints[planet];
    if (deepExaltation == null) return 0.0;

    final deepDebilitation = (deepExaltation + 180) % 360;
    final elongation = (longitude - deepDebilitation + 360) % 360;
    return (elongation > 180 ? (360 - elongation) : elongation) / 180.0 * 60.0;
  }

  /// Calculates Saptavargaja Bala (Strength in 7 divisional charts).
  double _calculateSaptavargajaBala(Planet planet, VedicChart rashiChart) {
    if (Planet.lunarNodes.contains(planet)) return 0.0;

    final charts = [
      DivisionalChartType.d1,
      DivisionalChartType.d2,
      DivisionalChartType.d3,
      DivisionalChartType.d7,
      DivisionalChartType.d9,
      DivisionalChartType.d12,
      DivisionalChartType.d30,
    ];

    var totalStrength = 0.0;
    for (final type in charts) {
      final vargaChart =
          _divisionalChartService.calculateDivisionalChart(rashiChart, type);
      final info = vargaChart.getPlanet(planet);
      if (info == null) continue;

      totalStrength += _getSaptavargajaScore(info.dignity);
    }

    return totalStrength;
  }

  double _getSaptavargajaScore(PlanetaryDignity dignity) {
    return switch (dignity) {
      PlanetaryDignity.moolaTrikona => 45.0,
      PlanetaryDignity.ownSign => 30.0,
      PlanetaryDignity.greatFriend => 22.5,
      PlanetaryDignity.friendSign => 15.0,
      PlanetaryDignity.neutralSign => 7.5,
      PlanetaryDignity.enemySign => 3.75,
      PlanetaryDignity.greatEnemy => 1.875,
      PlanetaryDignity.exalted => 60.0,
      PlanetaryDignity.debilitated => 0.0,
    };
  }

  double _calculateOjayugmarasyamsaBala(
      Planet planet, double rashiLong, VedicChart rashiChart) {
    final rashiSignIndex = (rashiLong / 30).floor() % 12;
    final rashiIsOdd = (rashiSignIndex + 1) % 2 != 0;

    final navamsaChart = _divisionalChartService.calculateDivisionalChart(
        rashiChart, DivisionalChartType.d9);
    final navamsaInfo = navamsaChart.getPlanet(planet);
    if (navamsaInfo == null) return 0.0;

    final navamsaSignIndex = (navamsaInfo.longitude / 30).floor() % 12;
    final navamsaIsOdd = (navamsaSignIndex + 1) % 2 != 0;

    final isFemale = [Planet.moon, Planet.venus].contains(planet);
    final isMale = [Planet.sun, Planet.mars, Planet.jupiter].contains(planet);

    var strength = 0.0;
    if (isMale) {
      if (rashiIsOdd) strength += 15.0;
      if (navamsaIsOdd) strength += 15.0;
    } else if (isFemale) {
      if (!rashiIsOdd) strength += 15.0;
      if (!navamsaIsOdd) strength += 15.0;
    }

    return strength;
  }

  double _calculateDrekkanaBala(Planet planet, double longitude) {
    final degInSign = longitude % 30;
    final decanate = (degInSign / 10).floor(); // 0, 1, 2

    final isMale = [Planet.sun, Planet.mars, Planet.jupiter].contains(planet);
    final isFemale = [Planet.moon, Planet.venus].contains(planet);
    final isNeutral = [Planet.mercury, Planet.saturn].contains(planet);

    if (isMale && decanate == 0) return 15.0;
    if (isNeutral && decanate == 1) return 15.0;
    if (isFemale && decanate == 2) return 15.0;

    return 0.0;
  }

  double _calculateKendraBala(int house) {
    if (_kendraHouses.contains(house)) return 60.0;
    if ([2, 5, 8, 11].contains(house)) return 30.0;
    return 15.0;
  }

  double _calculateDigBala(Planet planet, VedicPlanetInfo planetInfo) {
    final house = planetInfo.house;
    final optimalHouse = switch (planet) {
      Planet.sun || Planet.mars => 10,
      Planet.saturn => 7,
      Planet.moon || Planet.venus => 4,
      Planet.mercury || Planet.jupiter => 1,
      _ => 1,
    };

    var distance = (house - optimalHouse).abs();
    if (distance > 6) distance = 12 - distance;
    final strength = 60.0 * (1.0 - (distance / 6.0));
    return strength.clamp(0.0, 60.0);
  }

  Future<double> _calculateKalaBala(
      Planet planet, VedicPlanetInfo planetInfo, VedicChart chart) async {
    const strength = 0.0;
    final natonnata = await _calculateNatonnataBala(planet, chart);
    final paksha = _calculatePakshaBala(planet, planetInfo, chart);
    final tribhaga = await _calculateTribhagaBala(planet, chart);
    final vmdh = await _calculateVMDHBala(planet, chart);
    final ayana = _calculateAyanaBala(
        planet, planetInfo.position.longitude, planetInfo.position.declination);
    return strength + natonnata + paksha + tribhaga + vmdh + ayana;
  }

  /// Calculates Natonnata Bala (Day/Night Strength).
  ///
  /// Natonnata Bala measures the strength of planets based on whether
  /// the birth occurred during day or night. This implementation uses
  /// actual sunrise/sunset times for accurate determination.
  ///
  /// Day births (Sunrise to Sunset):
  /// - Strong: Sun, Jupiter, Saturn (60 virupas)
  /// - Weak: Moon, Mars, Venus (0 virupas)
  ///
  /// Night births (Sunset to Sunrise):
  /// - Strong: Moon, Mars, Venus (60 virupas)
  /// - Weak: Sun, Jupiter, Saturn (0 virupas)
  ///
  /// Mercury: Always gets 60 virupas (neutral)
  Future<double> _calculateNatonnataBala(
      Planet planet, VedicChart chart) async {
    // Mercury is always strong regardless of day/night
    if (planet == Planet.mercury) return 60.0;

    // Get accurate sunrise/sunset times for the location
    final location = GeographicLocation(
      latitude: chart.latitude,
      longitude: chart.longitudeCoord,
      altitude: 0,
    );

    final sunriseSunset = await _ephemerisService.getSunriseSunset(
      date: chart.dateTime,
      location: location,
    );

    final sunrise = sunriseSunset.$1;
    final sunset = sunriseSunset.$2;

    // If we can't get sunrise/sunset, fall back to house-based calculation
    if (sunrise == null || sunset == null) {
      return _calculateNatonnataBalaFallback(planet, chart);
    }

    // Determine if birth time is during day or night
    final birthTime = chart.dateTime.toUtc();
    final isDay = birthTime.isAfter(sunrise) && birthTime.isBefore(sunset);

    // Planets that are strong during day
    final isDayPowerful = [
      Planet.sun,
      Planet.jupiter,
      Planet.saturn,
    ].contains(planet);

    // Planets that are strong during night
    final isNightPowerful = [
      Planet.moon,
      Planet.mars,
      Planet.venus,
    ].contains(planet);

    if (isDay) {
      return isDayPowerful ? 60.0 : 0.0;
    } else {
      return isNightPowerful ? 60.0 : 0.0;
    }
  }

  /// Fallback calculation using house position when sunrise/sunset unavailable.
  /// This is less accurate and should only be used as a last resort.
  double _calculateNatonnataBalaFallback(Planet planet, VedicChart chart) {
    final sunHouse = chart.getPlanet(Planet.sun)?.house ?? 1;
    final isDay = sunHouse > 6; // Simplified: Sun in houses 7-12 = day

    final isDayPowerful = [
      Planet.sun,
      Planet.jupiter,
      Planet.saturn,
    ].contains(planet);

    final isNightPowerful = [
      Planet.moon,
      Planet.mars,
      Planet.venus,
    ].contains(planet);

    if (planet == Planet.mercury) return 60.0;
    if (isDay) {
      return isDayPowerful ? 60.0 : 0.0;
    } else {
      return isNightPowerful ? 60.0 : 0.0;
    }
  }

  double _calculatePakshaBala(
      Planet planet, VedicPlanetInfo planetInfo, VedicChart chart) {
    final sunInfo = chart.getPlanet(Planet.sun);
    final moonInfo = chart.getPlanet(Planet.moon);
    if (sunInfo == null || moonInfo == null) return 0.0;

    final elongation = (moonInfo.longitude - sunInfo.longitude + 360) % 360;

    if (planet == Planet.moon) {
      final pakshaStrength = elongation > 180 ? (360 - elongation) : elongation;
      return (pakshaStrength / 180.0) * 60.0;
    }

    final isBenefic = [Planet.jupiter, Planet.venus].contains(planet);
    final isMalefic = [Planet.sun, Planet.mars, Planet.saturn].contains(planet);

    if (isBenefic) {
      return (elongation / 360.0) * 60.0;
    } else if (isMalefic) {
      return ((360 - elongation) / 360.0) * 60.0;
    }

    return 30.0;
  }

  Future<double> _calculateTribhagaBala(Planet planet, VedicChart chart) async {
    // Mercury always gets 60 points
    if (planet == Planet.mercury) return 60.0;

    // Assignment:
    // Day (Sunrise-Sunset): 1st 1/3 Jupiter, 2nd 1/3 Sun, 3rd 1/3 Saturn
    // Night (Sunset-Sunrise): 1st 1/3 Moon, 2nd 1/3 Venus, 3rd 1/3 Mars

    final date = chart.dateTime;
    final location = GeographicLocation(
      latitude: chart.latitude,
      longitude: chart.longitudeCoord,
      altitude: 0,
    );

    final sunriseSunset = await _ephemerisService.getSunriseSunset(
        date: date, location: location);
    final sunrise = sunriseSunset.$1;
    final sunset = sunriseSunset.$2;

    if (sunrise == null || sunset == null) return 0.0;

    final birthTime = chart.dateTime.toUtc();
    final isDay = birthTime.isAfter(sunrise) && birthTime.isBefore(sunset);

    if (isDay) {
      final dayDuration = sunset.difference(sunrise).inSeconds;
      final partDuration = dayDuration / 3;
      final secondsSinceSunrise = birthTime.difference(sunrise).inSeconds;
      final partIndex =
          (secondsSinceSunrise / partDuration).floor().clamp(0, 2);

      final lords = [Planet.jupiter, Planet.sun, Planet.saturn];
      return planet == lords[partIndex] ? 60.0 : 0.0;
    } else {
      // Find previous sunset and next sunrise for accurate night division
      final prevDate = date.subtract(const Duration(days: 1));
      final prevSunriseSunset = await _ephemerisService.getSunriseSunset(
          date: prevDate, location: location);
      final prevSunset = prevSunriseSunset.$2;

      final nextDate = date.add(const Duration(days: 1));
      final nextSunriseSunset = await _ephemerisService.getSunriseSunset(
          date: nextDate, location: location);
      final nextSunrise = nextSunriseSunset.$1;

      // Determine which night segment we are in
      DateTime nightStart;
      DateTime nightEnd;

      if (birthTime.isAfter(sunset)) {
        nightStart = sunset;
        nightEnd = nextSunrise ?? sunset.add(const Duration(hours: 12));
      } else {
        nightStart = prevSunset ?? sunrise.subtract(const Duration(hours: 12));
        nightEnd = sunrise;
      }

      final nightDuration = nightEnd.difference(nightStart).inSeconds;
      final partDuration = nightDuration / 3;
      final secondsSinceNightStart = birthTime.difference(nightStart).inSeconds;
      final partIndex =
          (secondsSinceNightStart / partDuration).floor().clamp(0, 2);

      final lords = [Planet.moon, Planet.venus, Planet.mars];
      return planet == lords[partIndex] ? 60.0 : 0.0;
    }
  }

  double _calculateAyanaBala(Planet planet, double longitude, double decl) {
    // Ayana Bala = 60 * (23°27' ± Kranti) / 46°54'
    // Where Kranti = declination of the planet
    // Correct formula from Parashara Hora Shastra:
    // ayanabala = 60 * (23°27' ± kranti) / 46°54' = (23°27' ± kranti) * 1.2793

    const obliquityOfEcliptic = 23.45;
    const denominator = 46.90; // 46°54' = 46.90 degrees

    if ([Planet.sun, Planet.mars, Planet.jupiter, Planet.venus]
        .contains(planet)) {
      // Sun, Mars, Jupiter, Venus: + for Northern declination, - for Southern
      return (obliquityOfEcliptic + decl) / denominator * 60;
    } else if ([Planet.moon, Planet.saturn].contains(planet)) {
      // Moon, Saturn: - for Northern declination, + for Southern
      return (obliquityOfEcliptic - decl) / denominator * 60;
    } else {
      // Mercury: Always plus (absolute declination)
      return (obliquityOfEcliptic + decl.abs()) / denominator * 60;
    }
  }

  /// Calculates VMDH Bala (Vara-Maasa-Varsha-Hora Bala).
  ///
  /// Total: 150 virupas (60 Rupas)
  /// - Vara Bala: 45 virupas (Weekday lord)
  /// - Maasa Bala: 30 virupas (Month lord)
  /// - Varsha Bala: 15 virupas (Year lord)
  /// - Hora Bala: 60 virupas (Planetary hour lord)
  Future<double> _calculateVMDHBala(Planet planet, VedicChart chart) async {
    final varaBala = await _calculateVaraBala(planet, chart);
    final maasaBala = await _calculateMaasaBala(planet, chart);
    final varshaBala = await _calculateVarshaBala(planet, chart);
    final horaBala = await _calculateHoraBala(planet, chart);

    return varaBala + maasaBala + varshaBala + horaBala;
  }

  /// Vara Bala: 45 virupas for the weekday lord.
  /// Weekday: Sun (1), Mon (2), Tue (3), Wed (4), Thu (5), Fri (6), Sat (7)
  ///
  /// IMPORTANT: In Vedic astrology, the weekday changes at sunrise, not at midnight.
  /// If the birth time is before sunrise, it belongs to the previous weekday.
  Future<double> _calculateVaraBala(Planet planet, VedicChart chart) async {
    final dateTime = chart.dateTime;

    // Get sunrise time for the location
    final location = GeographicLocation(
      latitude: chart.latitude,
      longitude: chart.longitudeCoord,
      altitude: 0,
    );

    final sunriseSunset = await _ephemerisService.getSunriseSunset(
      date: dateTime,
      location: location,
    );

    final sunrise = sunriseSunset.$1;

    // Determine the effective weekday
    // In Vedic astrology, day changes at sunrise, not at midnight
    int weekday;
    if (sunrise != null && dateTime.isBefore(sunrise)) {
      // Before sunrise - use previous day
      final previousDay = dateTime.subtract(const Duration(days: 1));
      weekday = previousDay.weekday;
    } else {
      // After sunrise - use current day
      weekday = dateTime.weekday;
    }

    final varaLord = switch (weekday) {
      7 => Planet.sun, // Sunday
      1 => Planet.moon, // Monday
      2 => Planet.mars, // Tuesday
      3 => Planet.mercury, // Wednesday
      4 => Planet.jupiter, // Thursday
      5 => Planet.venus, // Friday
      6 => Planet.saturn, // Saturday
      _ => Planet.sun,
    };

    return planet == varaLord ? 45.0 : 0.0;
  }

  /// Maasa Bala: 30 virupas for the month lord.
  /// Based on the Hindu lunar month (Maasa) determined by Sun's position in zodiac.
  ///
  /// The lunar month is determined by the Sun's position in the zodiac signs:
  /// - Chaitra (0°-30° Aries): Jupiter
  /// - Vaishakha (30°-60° Taurus): Venus
  /// - Jyeshtha (60°-90° Gemini): Mercury
  /// - Ashadha (90°-120° Cancer): Saturn
  /// - Shravana (120°-150° Leo): Saturn
  /// - Bhadrapada (150°-180° Virgo): Jupiter
  /// - Ashwin (180°-210° Libra): Mars
  /// - Kartik (210°-240° Scorpio): Moon
  /// - Agrahayana (240°-270° Sagittarius): Venus
  /// - Pausha (270°-300° Capricorn): Mercury
  /// - Magha (300°-330° Aquarius): Jupiter
  /// - Phalguna (330°-360° Pisces): Sun
  Future<double> _calculateMaasaBala(Planet planet, VedicChart chart) async {
    // Get Sun's position to determine the Hindu lunar month
    final sunInfo = chart.getPlanet(Planet.sun);
    if (sunInfo == null) return 0.0;

    final monthLord = _getMonthLordFromSunLongitude(sunInfo.longitude);
    return planet == monthLord ? 30.0 : 0.0;
  }

  /// Gets the lord of the current month based on Sun's position in the zodiac.
  ///
  /// In traditional Vedic astrology, the lunar month (Maasa) is determined by
  /// the Sun's position in the zodiac, not the Gregorian calendar month.
  /// This provides accurate Maasa Bala calculations.
  ///
  /// [sunLongitude] - Sun's longitude in degrees (0-360)
  Planet _getMonthLordFromSunLongitude(double sunLongitude) {
    // Normalize longitude to 0-360
    final normalizedLong = sunLongitude % 360;

    // Determine which sign the Sun is in (0-11)
    final signIndex = (normalizedLong / 30).floor();

    // Traditional month lords based on Sun's sign position
    // Chaitra (Aries/0) = Jupiter, Vaishakha (Taurus/1) = Venus, etc.
    final monthLords = [
      Planet.jupiter, // Chaitra - Aries (0°-30°)
      Planet.venus, // Vaishakha - Taurus (30°-60°)
      Planet.mercury, // Jyeshtha - Gemini (60°-90°)
      Planet.saturn, // Ashadha - Cancer (90°-120°)
      Planet.saturn, // Shravana - Leo (120°-150°)
      Planet.jupiter, // Bhadrapada - Virgo (150°-180°)
      Planet.mars, // Ashwin - Libra (180°-210°)
      Planet.moon, // Kartik - Scorpio (210°-240°)
      Planet.venus, // Agrahayana - Sagittarius (240°-270°)
      Planet.mercury, // Pausha - Capricorn (270°-300°)
      Planet.jupiter, // Magha - Aquarius (300°-330°)
      Planet.sun, // Phalguna - Pisces (330°-360°)
    ];

    return monthLords[signIndex % 12];
  }

  /// Varsha Bala: 15 virupas for the year lord.
  /// Based on Jupiter's position in the 60-year Jovian cycle (Samvatsara/Brihaspati cycle).
  ///
  /// The traditional 60-year cycle assigns lords based on Jupiter's position:
  /// - Each year is associated with a specific planet as per the Samvatsara system
  /// - The cycle accurately follows Jupiter's orbital period (~11.86 years x 5 = 59.3 years)
  Future<double> _calculateVarshaBala(Planet planet, VedicChart chart) async {
    final yearLord = await _getYearLordFromJupiter(chart);
    return planet == yearLord ? 15.0 : 0.0;
  }

  /// Gets the lord of the year based on Jupiter's position in the 60-year cycle.
  ///
  /// The 60-year Samvatsara cycle is based on Jupiter's position in the zodiac.
  /// Jupiter takes approximately 11.86 years to orbit the Sun, and 5 Jupiter years
  /// equal approximately 60 solar years (59.3 years).
  ///
  /// The cycle assigns lords to each of the 60 years following traditional rules:
  /// - Years are ruled by planets in a specific sequence
  /// - All 7 traditional planets (Sun, Moon, Mars, Mercury, Jupiter, Venus, Saturn)
  /// serve as year lords
  ///
  /// [chart] - The Vedic chart containing planetary positions
  Future<Planet> _getYearLordFromJupiter(VedicChart chart) async {
    // Get Jupiter's position
    final jupiterInfo = chart.getPlanet(Planet.jupiter);
    if (jupiterInfo == null) return Planet.jupiter;

    final jupiterLongitude = jupiterInfo.longitude;

    // Jupiter's sign position (0-11)
    final jupiterSign = (jupiterLongitude / 30).floor();

    // Jupiter's degree within sign (0-30)
    final jupiterDegree = jupiterLongitude % 30;

    // Calculate which 60-year cycle position we're in
    // Jupiter moves through ~5 signs in 60 years
    // We combine sign position with degree to determine the exact year lord

    // Base calculation: 60-year cycle position
    // Reference: When Jupiter is at 0° Aries, it marks a cycle starting point
    final baseCyclePosition = (jupiterSign * 5) + (jupiterDegree / 6).floor();

    // Full 60-year cycle with all 7 planets as lords
    // Sequence follows traditional Samvatsara assignments
    final samvatsaraLords = [
      Planet.jupiter, // Prabhava
      Planet.jupiter, // Vibhava
      Planet.mars, // Shukla
      Planet.mars, // Pramodoota
      Planet.sun, // Prajothpatti
      Planet.sun, // Aangirasa
      Planet.mercury, // Shreemukha
      Planet.mercury, // Bhaava
      Planet.saturn, // Yuva
      Planet.saturn, // Dhaatu
      Planet.jupiter, // Eeshwara
      Planet.jupiter, // Bahudhanya
      Planet.mars, // Pramaadi
      Planet.mars, // Vikrama
      Planet.sun, // Vishu
      Planet.sun, // Chitrabhanu
      Planet.mercury, // Svabhanu
      Planet.mercury, // Taarana
      Planet.saturn, // Paarthiva
      Planet.saturn, // Vyaya
      Planet.jupiter, // Sarvajith
      Planet.jupiter, // Sarvadhaari
      Planet.mars, // Virodhi
      Planet.mars, // Vikrita
      Planet.sun, // Khara
      Planet.sun, // Nandana
      Planet.mercury, // Vijaya
      Planet.mercury, // Jaya
      Planet.saturn, // Manmatha
      Planet.saturn, // Durmukhi
      Planet.jupiter, // Hevilambi
      Planet.jupiter, // Vilambi
      Planet.mars, // Vikaari
      Planet.mars, // Shaarvari
      Planet.sun, // Plava
      Planet.sun, // Shubhakruth
      Planet.mercury, // Shobhakruth
      Planet.mercury, // Krodhi
      Planet.saturn, // Vishvaavasu
      Planet.saturn, // Paraabhava
      Planet.jupiter, // Plavanga
      Planet.jupiter, // Keelaka
      Planet.mars, // Saumya
      Planet.mars, // Saadhaarana
      Planet.sun, // Virodhikruth
      Planet.sun, // Paridhawi
      Planet.mercury, // Pramaadeecha
      Planet.mercury, // Aananda
      Planet.saturn, // Raakshasa
      Planet.saturn, // Nala
      Planet.jupiter, // Pingala
      Planet.jupiter, // Kaalayukthi
      Planet.mars, // Siddharthi
      Planet.mars, // Raudra
      Planet.sun, // Durmathi
      Planet.sun, // Dundubhi
      Planet.mercury, // Rudhirodgaari
      Planet.mercury, // Raktaakshi
      Planet.saturn, // Krodhana
      Planet.saturn, // Akshaya
    ];

    return samvatsaraLords[baseCyclePosition % 60];
  }

  /// Hora Bala: 60 virupas for the current Hora (planetary hour) lord.
  /// Each day is divided into 24 Horas (12 daytime + 12 nighttime).
  Future<double> _calculateHoraBala(Planet planet, VedicChart chart) async {
    final location = GeographicLocation(
      latitude: chart.latitude,
      longitude: chart.longitudeCoord,
      altitude: 0,
    );

    // Get sunrise and sunset for accurate Hora calculation
    final sunriseSunset = await _ephemerisService.getSunriseSunset(
        date: chart.dateTime, location: location);

    if (sunriseSunset.$1 == null || sunriseSunset.$2 == null) {
      // If sunrise/sunset unavailable, return 0
      return 0.0;
    }

    final horaLord = _getHoraLord(
      chart.dateTime,
      sunriseSunset.$1!,
      sunriseSunset.$2!,
    );

    return planet == horaLord ? 60.0 : 0.0;
  }

  /// Calculates the Hora (planetary hour) lord for a given time.
  ///
  /// Each day has 24 Horas:
  /// - 12 daytime Horas (from sunrise to sunset)
  /// - 12 nighttime Horas (from sunset to next sunrise)
  ///
  /// The sequence of lords follows the Chaldean order:
  /// Sun -> Venus -> Mercury -> Moon -> Saturn -> Jupiter -> Mars -> Sun...
  Planet _getHoraLord(DateTime dateTime, DateTime sunrise, DateTime sunset) {
    // Determine if it's day or night
    final birthTime = dateTime.toUtc();
    final isDay = birthTime.isAfter(sunrise) && birthTime.isBefore(sunset);

    // Get weekday (0 = Sunday, 1 = Monday, etc.)
    final weekday = dateTime.weekday % 7;

    // Hora lords sequence: Sun, Venus, Mercury, Moon, Saturn, Jupiter, Mars
    const horaSequence = [
      Planet.sun,
      Planet.venus,
      Planet.mercury,
      Planet.moon,
      Planet.saturn,
      Planet.jupiter,
      Planet.mars,
    ];

    // First Hora of each day is ruled by the day lord
    final dayStartLords = [
      Planet.sun, // Sunday
      Planet.moon, // Monday
      Planet.mars, // Tuesday
      Planet.mercury, // Wednesday
      Planet.jupiter, // Thursday
      Planet.venus, // Friday
      Planet.saturn, // Saturday
    ];

    final dayStartLord = dayStartLords[weekday];
    var startIndex = horaSequence.indexOf(dayStartLord);

    if (isDay) {
      // Daytime: Calculate which Hora we're in
      final dayDuration = sunset.difference(sunrise);
      final horaDuration = dayDuration.inSeconds / 12;
      final secondsSinceSunrise = birthTime.difference(sunrise).inSeconds;
      final horaIndex = (secondsSinceSunrise / horaDuration).floor();

      return horaSequence[(startIndex + horaIndex) % 7];
    } else {
      // Nighttime: Night starts with 5th lord from day start
      startIndex = (startIndex + 4) % 7;

      // Calculate night duration and Hora
      final nextSunrise = sunrise.add(const Duration(days: 1));
      DateTime nightStart;
      DateTime nightEnd;

      if (birthTime.isAfter(sunset)) {
        nightStart = sunset;
        nightEnd = nextSunrise;
      } else {
        // Before sunrise - use previous sunset
        nightStart = sunrise.subtract(const Duration(hours: 12));
        nightEnd = sunrise;
      }

      final nightDuration = nightEnd.difference(nightStart);
      final horaDuration = nightDuration.inSeconds / 12;
      final secondsSinceNightStart = birthTime.difference(nightStart).inSeconds;
      final horaIndex = (secondsSinceNightStart / horaDuration).floor();

      return horaSequence[(startIndex + horaIndex) % 7];
    }
  }

  /// Calculates all 24 Hora lords for a complete day.
  ///
  /// Returns a list of 24 planetary hour lords starting from sunrise.
  /// Index 0 = first Hora after sunrise (daytime Horas 1-12)
  /// Index 12 = first Hora after sunset (nighttime Horas 13-24)
  ///
  /// [date] - The date for which to calculate Horas
  /// [location] - Geographic location for accurate sunrise/sunset
  ///
  /// Returns a list of 24 Planet values representing each Hora lord
  Future<List<Planet>> calculateHoraLordsForDay({
    required DateTime date,
    required GeographicLocation location,
  }) async {
    final sunriseSunset = await _ephemerisService.getSunriseSunset(
      date: date,
      location: location,
    );

    if (sunriseSunset.$1 == null || sunriseSunset.$2 == null) {
      // Fallback if sunrise/sunset unavailable
      return _calculateFallbackHoraLords(date);
    }

    final sunrise = sunriseSunset.$1!;
    final sunset = sunriseSunset.$2!;
    final horaLords = <Planet>[];

    // Calculate daytime Horas (12)
    final dayDuration = sunset.difference(sunrise);
    final dayHoraDuration = dayDuration.inSeconds / 12;

    for (var i = 0; i < 12; i++) {
      final horaTime = sunrise.add(
        Duration(seconds: (dayHoraDuration * i).round()),
      );
      final lord = _getHoraLord(horaTime, sunrise, sunset);
      horaLords.add(lord);
    }

    // Calculate nighttime Horas (12)
    final nextSunrise = sunrise.add(const Duration(days: 1));
    final nightDuration = nextSunrise.difference(sunset);
    final nightHoraDuration = nightDuration.inSeconds / 12;

    for (var i = 0; i < 12; i++) {
      final horaTime = sunset.add(
        Duration(seconds: (nightHoraDuration * i).round()),
      );
      final lord = _getHoraLord(horaTime, sunrise, sunset);
      horaLords.add(lord);
    }

    return horaLords;
  }

  /// Fallback calculation for Hora lords when sunrise/sunset unavailable.
  List<Planet> _calculateFallbackHoraLords(DateTime date) {
    final horaLords = <Planet>[];
    final weekday = date.weekday % 7;

    // Hora lords sequence: Sun, Venus, Mercury, Moon, Saturn, Jupiter, Mars
    const horaSequence = [
      Planet.sun,
      Planet.venus,
      Planet.mercury,
      Planet.moon,
      Planet.saturn,
      Planet.jupiter,
      Planet.mars,
    ];

    // First Hora of each day is ruled by the day lord
    final dayStartLords = [
      Planet.sun, // Sunday
      Planet.moon, // Monday
      Planet.mars, // Tuesday
      Planet.mercury, // Wednesday
      Planet.jupiter, // Thursday
      Planet.venus, // Friday
      Planet.saturn, // Saturday
    ];

    final dayStartLord = dayStartLords[weekday];
    var startIndex = horaSequence.indexOf(dayStartLord);

    // Generate 24 Horas
    for (var i = 0; i < 24; i++) {
      if (i == 12) {
        // Night starts with 5th lord from day start
        startIndex = (startIndex + 4) % 7;
      }
      horaLords.add(horaSequence[(startIndex + (i % 12)) % 7]);
    }

    return horaLords;
  }

  /// Checks detailed combustion status for a planet.
  ///
  /// Combustion occurs when a planet is too close to the Sun.
  /// Different planets have different combustion orbs (degrees).
  ///
  /// Per traditional Surya Siddhanta:
  /// - Mercury and Venus have smaller orbs when retrograde
  /// - This is because they are closer to Sun when retrograde (inferior conjunction)
  ///
  /// [planet] - The planet to check
  /// [planetLongitude] - Longitude of the planet
  /// [sunLongitude] - Longitude of the Sun
  /// [planetSpeed] - Planet's speed (negative = retrograde)
  ///
  /// Returns detailed combustion information
  CombustionInfo checkCombustion({
    required Planet planet,
    required double planetLongitude,
    required double sunLongitude,
    double? planetSpeed,
  }) {
    // Combustion orbs for each planet (in degrees)
    // Normal orbs for direct motion, smaller for retrograde
    final combustionOrbs = {
      Planet.moon: 12.0,
      Planet.mars: 17.0,
      Planet.jupiter: 11.0,
      Planet.saturn: 16.0,
    };

    // Mercury and Venus have different orbs based on retrograde status
    double mercuryOrb;
    double venusOrb;

    final isRetrograde = (planetSpeed ?? 0) < 0;

    if (isRetrograde) {
      // Retrograde Mercury/Venus are at inferior conjunction - closer to Sun
      mercuryOrb = 12.0; // Reduced from 14°
      venusOrb = 8.0; // Reduced from 10°
    } else {
      mercuryOrb = 14.0;
      venusOrb = 10.0;
    }

    // Get the appropriate orb
    double orb;
    switch (planet) {
      case Planet.mercury:
        orb = mercuryOrb;
      case Planet.venus:
        orb = venusOrb;
      default:
        orb = combustionOrbs[planet] ?? 0.0;
    }

    // Sun and nodes don't get combust
    if (orb == 0.0) {
      return CombustionInfo(
        planet: planet,
        isCombust: false,
        distanceFromSun: 0.0,
        combustionOrb: 0.0,
        severity: CombustionSeverity.none,
        description: '${planet.displayName} does not undergo combustion',
      );
    }

    // Calculate angular distance from Sun
    var distance = (planetLongitude - sunLongitude).abs();
    if (distance > 180) {
      distance = 360 - distance;
    }

    // Check combustion status
    final isCombust = distance < orb;
    final severity = _getCombustionSeverity(distance, orb);

    String description;
    if (isCombust) {
      final remainingDegrees = orb - distance;
      description =
          '${planet.displayName} is combust (${isRetrograde ? 'retrograde' : 'direct'}), ${remainingDegrees.toStringAsFixed(1)}° from leaving combustion';
    } else {
      final degreesToCombustion = distance - orb;
      description =
          '${planet.displayName} is not combust, ${degreesToCombustion.toStringAsFixed(1)}° away from combustion orb';
    }

    return CombustionInfo(
      planet: planet,
      isCombust: isCombust,
      distanceFromSun: distance,
      combustionOrb: orb,
      severity: severity,
      description: description,
    );
  }

  /// Gets combustion severity based on distance and orb.
  CombustionSeverity _getCombustionSeverity(double distance, double orb) {
    if (distance >= orb) return CombustionSeverity.none;

    final ratio = distance / orb;
    if (ratio < 0.25) return CombustionSeverity.severe;
    if (ratio < 0.5) return CombustionSeverity.moderate;
    if (ratio < 0.75) return CombustionSeverity.mild;
    return CombustionSeverity.veryMild;
  }

  /// Chesta Bala (Motional Strength) calculation.
  ///
  /// Traditional categories (per Parashara):
  /// - Vakra (Retrograde): Maximum strength - 60 virupas
  /// - Vikala (Stationary): Minimum strength - 0 virupas
  /// - Mandi (Slow): Based on ratio to average speed
  /// - Sama (Normal): Based on ratio to average speed
  ///
  /// This implementation uses the simplified ratio method but considers
  /// retrograde motion for full strength.
  double _calculateChestaBala(Planet planet, VedicPlanetInfo planetInfo) {
    if (planet == Planet.sun || planet == Planet.moon) return 0.0;

    final speed = planetInfo.position.longitudeSpeed;

    // Retrograde (Vakra) - maximum strength per traditional rules
    if (speed < 0) return 60.0;

    // Stationary (Vikala) - near zero speed
    if (speed.abs() < 0.01) return 0.0;

    // Calculate ratio to average speed (Mandi/Sama)
    final avgSpeed = _averageSpeeds[planet] ?? 1.0;
    final ratio = (speed / avgSpeed).clamp(0.0, 1.0);

    // Convert ratio to virupas (traditional: max 60)
    return ratio * 60.0;
  }

  double _calculateNaisargikaBala(Planet planet) {
    const naturalStrengths = {
      Planet.sun: 60.0,
      Planet.moon: 51.43,
      Planet.venus: 42.85,
      Planet.jupiter: 34.28,
      Planet.mercury: 25.71,
      Planet.mars: 17.14,
      Planet.saturn: 8.57,
    };
    return naturalStrengths[planet] ?? 30.0;
  }

  /// Calculates Drik Bala (Aspectual Strength) using professional 60-virupa system.
  ///
  /// Drik Bala measures the aspectual influence on a planet.
  /// Benefic aspects add strength, malefic aspects subtract strength.
  /// Total virupas range from -60 to +60.
  double _calculateDrikBala(
      Planet planet, VedicPlanetInfo planetInfo, VedicChart chart) {
    var netVirupas = 0.0;

    for (final otherPlanet in Planet.traditionalPlanets) {
      if (otherPlanet == planet) continue;
      final otherInfo = chart.getPlanet(otherPlanet);
      if (otherInfo == null) continue;

      // Calculate full professional aspect strength (0-60 virupas)
      final aspectStrength = _calculateProfessionalAspectStrength(
        aspecting: otherPlanet,
        aspectingLong: otherInfo.longitude,
        aspectedLong: planetInfo.longitude,
      );

      // Apply aspect based on benefic/malefic nature
      final aspectValue = _applyAspectNature(otherPlanet, aspectStrength);
      netVirupas += aspectValue;
    }

    // Clamp to valid range (-60 to +60 virupas)
    return netVirupas.clamp(-60.0, 60.0);
  }

  /// Applies aspect nature (benefic adds, malefic subtracts).
  ///
  /// Benefic planets: Jupiter, Venus, Mercury, Moon
  /// Malefic planets: Sun, Mars, Saturn
  /// Aspect strength is divided by 4 as per Parashara
  double _applyAspectNature(Planet aspectingPlanet, double aspectStrength) {
    // Determine planet nature
    final isBenefic = [
      Planet.jupiter,
      Planet.venus,
      Planet.mercury,
      Planet.moon,
    ].contains(aspectingPlanet);

    final isMalefic = [
      Planet.sun,
      Planet.mars,
      Planet.saturn,
    ].contains(aspectingPlanet);

    // Apply Parashara's rule: divide by 4
    final virupas = aspectStrength / 4.0;

    if (isBenefic) {
      return virupas; // Benefic aspects add strength
    } else if (isMalefic) {
      return -virupas; // Malefic aspects subtract strength
    }

    return 0.0;
  }

  /// Calculates professional aspect strength using 60-virupa mathematical system.
  ///
  /// Uses precise interpolation based on Parasharic rules:
  /// - Full aspects: 60 virupas
  /// - 3/4 aspects: 45 virupas
  /// - 1/2 aspects: 30 virupas
  /// - 1/4 aspects: 15 virupas
  /// - No aspect: 0 virupas
  ///
  /// All planets have full 7th aspect (180°).
  /// Mars has special aspects on 4th (90°) and 8th (210°).
  /// Jupiter has special aspects on 5th (120°) and 9th (240°).
  /// Saturn has special aspects on 3rd (60°) and 10th (270°).
  /// Also partial aspects for all planets.
  double _calculateProfessionalAspectStrength({
    required Planet aspecting,
    required double aspectingLong,
    required double aspectedLong,
  }) {
    final diff = (aspectedLong - aspectingLong + 360) % 360;
    var maxStrength = 0.0;

    // Check all applicable aspects for this planet
    final aspects = _getPlanetAspects(aspecting);

    for (final aspectAngle in aspects) {
      final aspectDiff = (diff - aspectAngle + 360) % 360;
      final orb = aspectDiff > 180 ? 360 - aspectDiff : aspectDiff;

      // Calculate virupa strength based on orb
      final baseStrength = _calculateVirupaFromOrb(orb, aspecting, aspectAngle);

      // Apply partial aspect multiplier
      final multiplier = _getAspectStrengthMultiplier(aspectAngle);
      final strength = baseStrength * multiplier;

      if (strength > maxStrength) {
        maxStrength = strength;
      }
    }

    return maxStrength;
  }

  /// Gets all aspect angles for a planet.
  ///
  /// Per Parashara's Shadbala:
  /// - All planets have full 7th aspect (180°)
  /// - Mars has 4th and 8th special aspects
  /// - Jupiter has 5th and 9th special aspects
  /// - Saturn has 3rd and 10th special aspects
  ///
  /// Additionally, per classical texts, ALL planets cast partial aspects:
  /// - 1/4 aspect (quarter): Casts on house 1 from position (same house)
  /// - 1/2 aspect (half): Casts on houses 1-2 from position
  /// - 3/4 aspect (three-quarter): Casts on houses 1-3 from position
  List<double> _getPlanetAspects(Planet planet) {
    // Full aspect - all planets have 7th aspect (180°)
    final aspects = <double>[180.0];

    // Special aspects per planet
    switch (planet) {
      case Planet.mars:
        aspects.addAll([90.0, 210.0]); // 4th and 8th
      case Planet.jupiter:
        aspects.addAll([120.0, 240.0]); // 5th and 9th
      case Planet.saturn:
        aspects.addAll([60.0, 270.0]); // 3rd and 10th
      default:
        break;
    }

    // Add partial aspects (1/4, 1/2, 3/4) for all planets
    // These represent the traditional understanding that planets
    // cast partial aspects on adjacent houses:
    // - 1/4 aspect: 90° (houses 1-2 from planet's position)
    // - 1/2 aspect: 180° is full, but 1/2 strength = ~90° effective (same as 1/4 for calculation)
    // - 3/4 aspect: 270° (houses 1-3 from position)
    aspects.addAll([90.0, 270.0]); // Partial 1/4 and 3/4 aspects

    return aspects;
  }

  /// Gets the aspect strength multiplier for partial aspects.
  /// Full aspects (180°) get full 60 virupas, partial aspects get reduced.
  double _getAspectStrengthMultiplier(double aspectAngle) {
    // Full 7th aspect
    if (aspectAngle == 180.0) return 1.0;

    // Special aspects (Mars 4th/8th, Jupiter 5th/9th, Saturn 3rd/10th)
    if ([90.0, 120.0, 210.0, 240.0, 60.0, 270.0].contains(aspectAngle)) {
      return 1.0; // Full strength for special aspects
    }

    // Partial aspects (1/4 and 3/4)
    // These get 1/4 of full strength per traditional interpretation
    return 0.25;
  }

  /// Calculates virupa strength (0-60) from aspect orb using linear interpolation.
  ///
  /// Traditional 60-virupa system (per Parashara):
  /// - 0° orb: 60 virupas (full strength)
  /// - At 1/4 of max orb: 45 virupas (3/4 strength)
  /// - At 1/2 of max orb: 30 virupas (1/2 strength)
  /// - At 3/4 of max orb: 15 virupas (1/4 strength)
  /// - At max orb: 0 virupas (no strength)
  ///
  /// Uses LINEAR interpolation as per traditional Vedic calculations.
  double _calculateVirupaFromOrb(
      double orb, Planet planet, double aspectAngle) {
    // Normalize orb to 0-180 range
    final normalizedOrb = orb.abs();

    // Maximum orb allowance varies by aspect type
    final maxOrb = _getMaxOrbForAspect(planet, aspectAngle);

    if (normalizedOrb >= maxOrb) {
      return 0.0; // Outside orb limit
    }

    // Traditional LINEAR interpolation:
    // strength = 60 * (1 - orb/maxOrb)
    // At orb=0: strength=60, at orb=max: strength=0
    final strength = 60.0 * (1.0 - normalizedOrb / maxOrb);

    return strength;
  }

  /// Gets maximum orb allowance for different aspect types.
  double _getMaxOrbForAspect(Planet planet, double aspectAngle) {
    // Full aspects (7th house) get 30° orb for all planets
    if (aspectAngle == 180.0) {
      return 30.0;
    }

    // Special aspects get 15° orb
    if ([90.0, 210.0, 120.0, 240.0, 60.0, 270.0].contains(aspectAngle)) {
      return 15.0;
    }

    return 30.0;
  }

  // Cosine function for interpolation
  double cos(double radians) {
    return cosInternal(radians);
  }

  double cosInternal(double x) {
    // Taylor series approximation for cosine
    x = x % (2 * 3.14159265358979323846);
    double result = 1.0;
    double term = 1.0;
    final x2 = x * x;

    for (int i = 1; i <= 10; i++) {
      term *= -x2 / ((2 * i - 1) * (2 * i));
      result += term;
    }

    return result;
  }

  /// Pi constant
  static const double pi = 3.14159265358979323846;

  ShadbalaStrength _getStrengthCategory(double totalBala) {
    if (totalBala >= 380) return ShadbalaStrength.veryStrong;
    if (totalBala >= 330) return ShadbalaStrength.strong;
    if (totalBala >= 280) return ShadbalaStrength.moderate;
    if (totalBala >= 230) return ShadbalaStrength.weak;
    return ShadbalaStrength.veryWeak;
  }

  static const _averageSpeeds = {
    Planet.mars: 0.524,
    Planet.mercury: 1.383,
    Planet.jupiter: 0.083,
    Planet.venus: 1.2,
    Planet.saturn: 0.033,
  };

  static const _kendraHouses = [1, 4, 7, 10];

  static const _deepExaltationPoints = {
    Planet.sun: 10.0,
    Planet.moon: 33.0,
    Planet.mars: 298.0,
    Planet.mercury: 165.0,
    Planet.jupiter: 95.0,
    Planet.venus: 357.0,
    Planet.saturn: 200.0,
  };
}

class ShadbalaResult {
  const ShadbalaResult({
    required this.planet,
    required this.sthanaBala,
    required this.digBala,
    required this.kalaBala,
    required this.chestaBala,
    required this.naisargikaBala,
    required this.drikBala,
    required this.totalBala,
    required this.strengthCategory,
    this.ishtaPhala = 0.0,
    this.kashtaPhala = 0.0,
    this.netPhala = 0.0,
  });

  final Planet planet;
  final double sthanaBala;
  final double digBala;
  final double kalaBala;
  final double chestaBala;
  final double naisargikaBala;
  final double drikBala;
  final double totalBala;
  final ShadbalaStrength strengthCategory;

  /// Ishta Phala (Benefic influence)
  final double ishtaPhala;

  /// Kashta Phala (Malefic influence)
  final double kashtaPhala;

  /// Net Phala (Ishta - Kashta)
  final double netPhala;

  bool get isStrong => totalBala >= 330;
  bool get isWeak => totalBala < 280;
  double get rupas => totalBala / 60.0;

  @override
  String toString() {
    return '${planet.displayName}: ${totalBala.toStringAsFixed(1)} (${strengthCategory.name})';
  }
}

enum ShadbalaStrength {
  veryStrong('Very Strong', 'Excellent planetary influence'),
  strong('Strong', 'Good planetary influence'),
  moderate('Moderate', 'Average planetary influence'),
  weak('Weak', 'Reduced planetary influence'),
  veryWeak('Very Weak', 'Minimal planetary influence');

  const ShadbalaStrength(this.name, this.description);
  final String name;
  final String description;
}

/// Represents detailed combustion information for a planet.
class CombustionInfo {
  const CombustionInfo({
    required this.planet,
    required this.isCombust,
    required this.distanceFromSun,
    required this.combustionOrb,
    required this.severity,
    required this.description,
  });

  /// The planet being checked
  final Planet planet;

  /// Whether the planet is combust
  final bool isCombust;

  /// Angular distance from Sun in degrees
  final double distanceFromSun;

  /// Combustion orb for this planet
  final double combustionOrb;

  /// Severity of combustion
  final CombustionSeverity severity;

  /// Text description
  final String description;

  /// Remaining degrees to exit combustion (0 if not combust)
  double get remainingDegrees =>
      isCombust ? combustionOrb - distanceFromSun : 0.0;

  /// Whether combustion is critical (severe)
  bool get isCritical => severity == CombustionSeverity.severe;

  @override
  String toString() {
    return '${planet.displayName}: ${isCombust ? "Combust (${severity.name})" : "Not combust"} - ${distanceFromSun.toStringAsFixed(1)}° from Sun';
  }
}

/// Combustion severity levels
enum CombustionSeverity {
  none('Not combust', 1.0),
  veryMild('Very mild', 0.9),
  mild('Mild', 0.75),
  moderate('Moderate', 0.5),
  severe('Severe', 0.25);

  const CombustionSeverity(this.name, this.intensityFactor);

  final String name;
  final double intensityFactor; // Factor for calculating reduced effect

  @override
  String toString() => name;
}
