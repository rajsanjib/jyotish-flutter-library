import 'package:jyotish/src/models/planet.dart';
import 'package:jyotish/src/models/rashi.dart';
import 'package:jyotish/src/models/vedic_chart.dart';
import 'package:jyotish/src/systems/tajaka.dart';

class TajakaService {
  TajakaEnhancement calculateTajakaEnhancements({
    required VedicChart natalChart,
    required VedicChart annualChart,
    required int age,
  }) {
    final ascendantSign = Rashi.fromLongitude(natalChart.ascendant);

    // Muntha calculation
    final munthaSignIndex = (ascendantSign.number + age) % 12;
    final munthaSign = Rashi.values[munthaSignIndex];

    // Muntha House in Annual Chart
    final annualAscSign = Rashi.fromLongitude(annualChart.ascendant);
    int munthaHouse = ((munthaSignIndex - annualAscSign.number) % 12) + 1;
    if (munthaHouse <= 0) munthaHouse += 12;

    final munthaLord = _getSignLord(munthaSign);

    // Sahams (Punya, Vidya)
    final sahams = _calculateSahams(annualChart);

    // Tajaka Yogas (Itthasala)
    // For a minimal demonstration, we check for yogas involving the Munthesh and Varshesh
    final varshesh = _getSignLord(annualAscSign);
    final yogas = _detectYogas(annualChart, munthaLord, varshesh);

    return TajakaEnhancement(
      munthaSign: munthaSign,
      munthaHouse: munthaHouse,
      munthaLord: munthaLord,
      sahams: sahams,
      yogas: yogas,
    );
  }

  Map<String, double> _calculateSahams(VedicChart annualChart) {
    final Map<String, double> sahams = {};

    final sunLon = annualChart.planets[Planet.sun]?.longitude ?? 0.0;
    final moonLon = annualChart.planets[Planet.moon]?.longitude ?? 0.0;
    final jupLon = annualChart.planets[Planet.jupiter]?.longitude ?? 0.0;
    final mercLon = annualChart.planets[Planet.mercury]?.longitude ?? 0.0;
    final venLon = annualChart.planets[Planet.venus]?.longitude ?? 0.0;
    final marsLon = annualChart.planets[Planet.mars]?.longitude ?? 0.0;
    final satLon = annualChart.planets[Planet.saturn]?.longitude ?? 0.0;
    final ascLon = annualChart.houses.ascendant;
    final eighthHouseCusp = annualChart.houses.cusps.length > 7
        ? annualChart.houses.cusps[7]
        : (ascLon + 210) % 360;

    // Daytime chart check
    // If Sun - Ascendant mod 360 is between 180 and 360, it's daytime.
    double diff = (sunLon - ascLon + 360) % 360;
    bool isDay = diff >= 180 && diff <= 360;

    double calc(double a, double b, double c, bool reverseForNight) {
      if (reverseForNight && !isDay) {
        return (c + b - a + 360) % 360;
      }
      return (c + a - b + 360) % 360;
    }

    // Punya (Fortune)
    sahams['Punya'] = calc(moonLon, sunLon, ascLon, true);
    // Vidya (Education)
    sahams['Vidya'] = calc(sunLon, moonLon, ascLon, true);
    // Yasas (Fame)
    sahams['Yasas'] = calc(jupLon, sunLon, ascLon, true);
    // Mrityu (Death)
    sahams['Mrityu'] = calc(eighthHouseCusp, moonLon, ascLon, true);
    // Pitru (Father)
    sahams['Pitru'] = calc(sunLon, satLon, ascLon, true);
    // Matru (Mother)
    sahams['Matru'] = calc(moonLon, venLon, ascLon, true);
    // Putra (Children)
    sahams['Putra'] = calc(jupLon, moonLon, ascLon, true);
    // Vivaha (Marriage)
    sahams['Vivaha'] = calc(venLon, satLon, ascLon, true);
    // Karyasiddhi (Success)
    sahams['Karyasiddhi'] = calc(satLon, sunLon, ascLon, true);
    // Bhratru (Sibling)
    sahams['Bhratru'] = calc(jupLon, marsLon, ascLon, true);
    // Rog (Disease)
    sahams['Rog'] = calc(marsLon, satLon, ascLon, true);
    // Kali (Conflict)
    sahams['Kali'] = calc(jupLon, marsLon, ascLon, true);
    // Labha (Gain)
    sahams['Labha'] = calc(jupLon, sunLon, ascLon, false); // No reverse
    // Karma (Action)
    sahams['Karma'] = calc(marsLon, mercLon, ascLon, true);

    return sahams;
  }

  List<TajakaYoga> _detectYogas(
      VedicChart annualChart, Planet munthesh, Planet varshesh) {
    final yogas = <TajakaYoga>[];

    if (munthesh == varshesh) return yogas;

    final p1 = annualChart.planets[varshesh];
    final p2 = annualChart.planets[munthesh];

    if (p1 == null || p2 == null) return yogas;

    // Speeds of planets
    final speed = {
      Planet.moon: 13.0,
      Planet.mercury: 1.5,
      Planet.venus: 1.2,
      Planet.sun: 1.0,
      Planet.mars: 0.5,
      Planet.jupiter: 0.08,
      Planet.saturn: 0.03,
    };

    final s1 = speed[varshesh] ?? 0.0;
    final s2 = speed[munthesh] ?? 0.0;

    // Determine aspect distance
    final distance = (p1.longitude - p2.longitude).abs();

    // Simplified true/false applying check
    bool isApp = false;
    if (s1 > s2) {
      if ((p1.longitude < p2.longitude) && distance < 12.0) {
        isApp = true;
      }
    } else {
      if ((p2.longitude < p1.longitude) && distance < 12.0) {
        isApp = true;
      }
    }

    if (distance < 15.0) {
      // Deepthamsha/Orb overlap
      if (isApp) {
        yogas.add(TajakaYoga(
          type: TajakaYogaType.itthasala,
          planet1: varshesh,
          planet2: munthesh,
          isApplying: true,
          interpretation:
              'Applying Itthasala between Annual Lord ($varshesh) and Muntha Lord ($munthesh), showing impending success.',
        ));
      } else {
        yogas.add(TajakaYoga(
          type: TajakaYogaType.ishrafa,
          planet1: varshesh,
          planet2: munthesh,
          isApplying: false,
          interpretation:
              'Separating Ishrafa between Annual Lord and Muntha Lord. Past efforts indicated.',
        ));
      }
    }

    return yogas;
  }

  Planet _getSignLord(Rashi sign) {
    return switch (sign) {
      Rashi.aries || Rashi.scorpio => Planet.mars,
      Rashi.taurus || Rashi.libra => Planet.venus,
      Rashi.gemini || Rashi.virgo => Planet.mercury,
      Rashi.cancer => Planet.moon,
      Rashi.leo => Planet.sun,
      Rashi.sagittarius || Rashi.pisces => Planet.jupiter,
      Rashi.capricorn || Rashi.aquarius => Planet.saturn,
    };
  }
}
