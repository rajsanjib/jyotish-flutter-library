import '../models/planet.dart';
import '../models/rashi.dart';
import '../models/vedic_chart.dart';
import '../models/tajaka.dart';

class TajakaService {
  TajakaEnhancement calculateTajakaEnhancements({
    required VedicChart natalChart,
    required VedicChart annualChart,
    required int age,
  }) {
    final ascendantSign = natalChart.ascendantSign;
    
    // Muntha calculation
    final munthaSignIndex = (ascendantSign.index + age) % 12;
    final munthaSign = Rashi.values[munthaSignIndex];
    
    // Muntha House in Annual Chart
    final annualAscSign = annualChart.ascendantSign;
    int munthaHouse = ((munthaSignIndex - annualAscSign.index) % 12) + 1;
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
    final ascLon = annualChart.houses.ascendant;

    // Daytime chart check
    // Very basic check: Is Sun in houses 7-12?
    // Accurate logic is Sun above horizon. We'll use a simplified check based on distance from Ascendant.
    // If Sun - Ascendant mod 360 is between 180 and 360, it's daytime.
    double diff = (sunLon - ascLon + 360) % 360;
    bool isDay = diff >= 180 && diff <= 360;

    // Punya (Fortune)
    double punya;
    if (isDay) {
      punya = (ascLon + moonLon - sunLon + 360) % 360;
    } else {
      punya = (ascLon + sunLon - moonLon + 360) % 360;
    }
    sahams['Punya'] = punya;

    // Vidya (Education) = As + Mercury - Sun
    sahams['Vidya'] = (ascLon + mercLon - sunLon + 360) % 360;

    // Yasas (Fame) = As + Jupiter - Sun
    sahams['Yasas'] = (ascLon + jupLon - sunLon + 360) % 360;

    return sahams;
  }

  List<TajakaYoga> _detectYogas(VedicChart annualChart, Planet munthesh, Planet varshesh) {
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

    if (distance < 15.0) { // Deepthamsha/Orb overlap
      if (isApp) {
         yogas.add(TajakaYoga(
           type: TajakaYogaType.itthasala,
           planet1: varshesh,
           planet2: munthesh,
           isApplying: true,
           interpretation: 'Applying Itthasala between Annual Lord ($varshesh) and Muntha Lord ($munthesh), showing impending success.',
         ));
      } else {
         yogas.add(TajakaYoga(
           type: TajakaYogaType.ishrafa,
           planet1: varshesh,
           planet2: munthesh,
           isApplying: false,
           interpretation: 'Separating Ishrafa between Annual Lord and Muntha Lord. Past efforts indicated.',
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
