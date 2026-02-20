# Usage Guide

This document provides comprehensive usage examples for the Jyotish library, covering everything from basic planet calculations to advanced features like Vimsopaka Bala, Nadi Astrology, Progeny Analysis, and Marriage Compatibility.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Basic Planet Calculations](#basic-planet-calculations)
3. [Vedic Chart](#vedic-astrology-chart)
4. [Divisional Charts](#divisional-charts-varga)
5. [Dasha Systems](#dasha-system-support)
6. [Transits](#transit-calculations)
7. [Panchanga](#panchanga-calculations)
8. [Ashtakavarga](#ashtakavarga-analysis)
9. [KP System](#kp-system-krishnamurti-paddhati)
10. [Special Transits](#special-transits-sade-sati-etc)
11. [Muhurta](#muhurta-and-auspicious-timing)
12. [Sudarshan Chakra](#sudarshan-chakra-strength-analysis)
13. [Jaimini Astrology](#jaimini-astrology)
14. [Prashna Horary](#prashna-horary-astrology)
15. [House Strength (Vimsopaka Bala)](#house-strength-vimsopaka-bala)
16. [Nadi Astrology](#nadi-astrology)
17. [Progeny Analysis](#progeny-analysis)
18. [Marriage Compatibility](#marriage-compatibility)

---

## Quick Start

```dart
import 'package:jyotish/jyotish.dart';

void main() async {
  final jyotish = Jyotish();
  await jyotish.initialize();

  final location = GeographicLocation(
    latitude: 27.7172,
    longitude: 85.3240,
    altitude: 1400,
  );

  final sunPosition = await jyotish.getPlanetPosition(
    planet: Planet.sun,
    dateTime: DateTime.now(),
    location: location,
  );

  print('Sun: ${sunPosition.formattedPosition}');
  print('Nakshatra: ${sunPosition.nakshatra}');

  jyotish.dispose();
}
```

---

## Basic Planet Calculations

### Single Planet Position

```dart
final sunPosition = await jyotish.getPlanetPosition(
  planet: Planet.sun,
  dateTime: DateTime(2024, 1, 1, 12, 0),
  location: location,
);

print('Longitude: ${sunPosition.longitude}°');
print('Nakshatra: ${sunPosition.nakshatra}');
print('Pada: ${sunPosition.pada}');
print('Is Retrograde: ${sunPosition.isRetrograde}');
```

### All Planets at Once

```dart
final positions = await jyotish.getAllPlanetPositions(
  dateTime: DateTime(2024, 1, 1, 12, 0),
  location: location,
);

for (final entry in positions.entries) {
  print('${entry.key.displayName}: ${entry.value.formattedPosition}');
}
```

### Custom Ayanamsa

```dart
// Use Krishnamurti ayanamsa instead of default Lahiri
final flags = CalculationFlags.sidereal(SiderealMode.krishnamurti);

final position = await jyotish.getPlanetPosition(
  planet: Planet.moon,
  dateTime: DateTime.now(),
  location: location,
  flags: flags,
);
```

### True Node vs Mean Node

```dart
// Use True Node for Rahu (modern preference)
final flags = CalculationFlags.withNodeType(NodeType.trueNode);

final chart = await jyotish.calculateVedicChart(
  dateTime: DateTime(1990, 5, 15, 14, 30),
  location: location,
  flags: flags,
);

print('Rahu: ${chart.rahu.position.formattedPosition}');
```

---

## Vedic Astrology Chart

```dart
final chart = await jyotish.calculateVedicChart(
  dateTime: DateTime(1990, 5, 15, 14, 30),
  location: location,
);

// Ascendant
print('Ascendant: ${chart.ascendantSign}');
print('Ascendant Degree: ${chart.ascendant}°');

// Planetary positions
final sunInfo = chart.getPlanet(Planet.sun);
if (sunInfo != null) {
  print('Sun in ${sunInfo.zodiacSign}');
  print('House: ${sunInfo.house}');
  print('Nakshatra: ${sunInfo.nakshatra} (Pada ${sunInfo.pada})');
  print('Dignity: ${sunInfo.dignity.english}');
  print('Combust: ${sunInfo.isCombust}');
}

// Special points
print('Rahu in ${chart.rahu.zodiacSign}');
print('Ketu in ${chart.ketu.zodiacSign}');

// Get planets by house
final firstHousePlanets = chart.getPlanetsInHouse(1);

// Get planets by dignity
final exaltedPlanets = chart.exaltedPlanets;
final debilitatedPlanets = chart.debilitatedPlanets;

// House cusps
for (int i = 0; i < 12; i++) {
  print('House ${i + 1}: ${chart.houses.cusps[i]}°');
}
```

---

## Divisional Charts (Varga)

```dart
final d1Chart = await jyotish.calculateVedicChart(
  dateTime: DateTime(1990, 5, 15, 14, 30),
  location: location,
);

// Navamsa (D9) - Marriage and Dharma
final navamsa = jyotish.getDivisionalChart(
  rashiChart: d1Chart,
  type: DivisionalChartType.d9,
);
print('Navamsa Ascendant: ${navamsa.ascendantSign}');

// Dasamsa (D10) - Career
final dasamsa = jyotish.getDivisionalChart(
  rashiChart: d1Chart,
  type: DivisionalChartType.d10,
);

// D249 - Ultra-fine micro analysis
final d249 = jyotish.getDivisionalChart(
  rashiChart: d1Chart,
  type: DivisionalChartType.d249,
);

// All available types:
// D1 (Rashi), D2 (Hora), D3 (Drekkana), D4 (Chathurthaamsa)
// D5 (Panchamsa), D6 (Shasthamsa), D7 (Saptamsa)
// D8 (Ashtamsa), D9 (Navamsa), D10 (Dasamsa)
// D11 (Ekadamsa), D12 (Dwadashamsa), D16 (Shodashamsa)
// D20 (Vimsamsa), D24 (Chaturvimsamsa), D27 (Saptavimsamsa)
// D30 (Trisamsa), D40 (Khavedamsa), D45 (Akshavedamsa)
// D60 (Shashtisamsa), D249 (249 divisions)
```

---

## Dasha System Support

### Vimshottari Dasha

```dart
final vimshottari = await jyotish.getVimshottariDasha(
  natalChart: d1Chart,
  levels: 3, // Mahadasha, Antardasha, Pratyantardasha
);

// Get current period
final now = DateTime.now();
final currentPeriod = vimshottari.getCurrentDasha(date: now);

print('Mahadasha: ${currentPeriod.lord.displayName}');
print('Antardasha: ${currentPeriod.subPeriodLord?.displayName}');

// Get full timeline
for (final md in vimshottari.mahadashas) {
  print('${md.lord.displayName}: ${md.startDate} to ${md.endDate}');
}
```

### Other Dasha Systems

```dart
// Yogini Dasha
final yogini = await jyotish.getYoginiDasha(
  natalChart: d1Chart,
  levels: 2,
);

// Ashtottari Dasha (108 years)
final ashtottari = await jyotish.getAshtottariDasha(
  natalChart: d1Chart,
);

// Kalachakra Dasha
final kalachakra = await jyotish.getKalachakraDasha(
  natalChart: d1Chart,
);

// Narayana Dasha (Jaimini)
final narayana = await jyotish.getNarayanaDasha(
  chart: d1Chart,
);
```

---

## Transit Calculations

```dart
// Check transits relative to natal chart
final transits = await jyotish.getTransitPositions(
  natalChart: d1Chart,
  transitDateTime: DateTime.now(),
  location: location,
);

final saturnTransit = transits[Planet.saturn];
print('Saturn transiting House ${saturnTransit?.transitHouse}');

// Find specific transit events
final events = await jyotish.getTransitEvents(
  natalChart: d1Chart,
  startDate: DateTime.now(),
  endDate: DateTime.now().add(Duration(days: 365)),
  location: location,
  planets: [Planet.jupiter, Planet.saturn],
);

for (final event in events) {
  print('${event.description} on ${event.exactDate}');
}
```

---

## Panchanga Calculations

```dart
final panchanga = await jyotish.calculatePanchanga(
  dateTime: DateTime.now(),
  location: location,
);

print('Tithi: ${panchanga.tithi.name}');
print('Yoga: ${panchanga.yoga.name}');
print('Karana: ${panchanga.karana.name}');
print('Vara: ${panchanga.vara.name}');
print('Day Lord: ${panchanga.vara.rulingPlanet.displayName}');
print('Sunrise: ${panchanga.sunrise}');

// Find exact Tithi end time
final tithiEnd = await jyotish.getTithiEndTime(
  dateTime: DateTime.now(),
  location: location,
);
print('Tithi ends at: $tithiEnd');
```

---

## Ashtakavarga Analysis

```dart
final ashtakavarga = jyotish.calculateAshtakavarga(d1Chart);

// Get SAV (Sarvashtakavarga) points for each house
for (int house = 1; house <= 12; house++) {
  print('House $house: ${ashtakavarga.getTotalBindusForHouse(house)} points');
}

// Analyze transit strength
final transitStrength = jyotish.analyzeAshtakavargaTransit(
  ashtakavarga: ashtakavarga,
  transitPlanet: Planet.jupiter,
  transitSign: 5, // Virgo
);
print('Jupiter transit strength: ${transitStrength.strengthScore}%');

// Get planet-specific bindus
final sunBindus = ashtakavarga.getPlanetBindus(Planet.sun);
print('Sun bindus in each house: $sunBindus');
```

---

## KP System (Krishnamurti Paddhati)

```dart
final kpData = jyotish.calculateKPData(d1Chart);

// Get Sub-Lord for a planet
final sunDivision = kpData.planetDivisions[Planet.sun];
print('Sun Sub-Lord: ${sunDivision?.subLord.displayName}');

// Get planet significators
final sunSignificators = kpData.planetSignificators[Planet.sun];
print('Sun Significators: ${sunSignificators?.allSignificators}');

// Get house cusp Sub-Lord
final house1Division = kpData.houseDivisions[1];
print('House 1 Sub-Lord: ${house1Division?.subLord.displayName}');
```

---

## Special Transits (Sade Sati, etc.)

```dart
final specialTransits = await jyotish.calculateSpecialTransits(
  natalChart: d1Chart,
  location: location,
);

// Sade Sati (Saturn transit over Moon's sign)
if (specialTransits.sadeSati.isActive) {
  print('Sade Sati Phase: ${specialTransits.sadeSati.phase?.name}');
  print('Saturn in: ${specialTransits.sadeSati.saturnSign}');
}

// Dhaiya (Jupiter transit)
if (specialTransits.dhaiya?.isActive ?? false) {
  print('Dhaiya is active');
}

// Panchak
if (specialTransits.panchak?.isActive ?? false) {
  print('Panchak is currently active');
}
```

---

## Muhurta and Auspicious Timing

```dart
final muhurta = await jyotish.calculateMuhurta(
  date: DateTime.now(),
  location: location,
);

// Get current Choghadiya
final currentChoghadiya = muhurta.choghadiya.getPeriodForTime(DateTime.now());
print('Current Choghadiya: ${currentChoghadiya?.name}');
print('Nature: ${currentChoghadiya?.nature}');

// Check for inauspicious periods
if (muhurta.isCurrentlyInauspicious) {
  print('Active Period: ${muhurta.inauspiciousPeriods.getActivePeriod(DateTime.now())}');
}

// Find best Muhurta for specific activities
final bestTimes = jyotish.findBestMuhurta(muhurta: muhurta, activity: 'marriage');
print('Best marriage time: ${bestTimes.first}');

// Other activities: 'travel', 'business', 'education', 'property'
```

---

## Sudarshan Chakra Strength Analysis

```dart
final sudarshan = jyotish.calculateSudarshanChakra(d1Chart);

print('Overall Chart Strength: ${sudarshan.overallStrength.toStringAsFixed(1)}%');
print('Strong Houses: ${sudarshan.strongHouses}');
print('Weak Houses: ${sudarshan.weakHouses}');

// Get strength from each perspective
print('Shad Bala strength: ${sudarshan.shadBalaStrength}');
print('Ashtakavarga strength: ${sudarshan.ashtakavargaStrength}');
print('Vimsopaka strength: ${sudarshan.vimsopakaStrength}');

// Bhava Bala (House Strength)
final bhavaBala = await jyotish.getBhavaBala(d1Chart);
print('10th House Strength: ${bhavaBala[10]?.totalStrength}');
```

---

## Jaimini Astrology

```dart
// Atmakaraka (Soul Planet)
final ak = jyotish.getAtmakaraka(d1Chart);
print('Atmakaraka: ${ak.displayName}');

// Arudha Lagna (AL)
final al = jyotish.getArudhaLagna(d1Chart);
print('Arudha Lagna: ${al.name}');

// Karakamsa
final navamsa = jyotish.getDivisionalChart(
  rashiChart: d1Chart,
  type: DivisionalChartType.d9,
);
final karakamsa = jyotish.getKarakamsa(rashiChart: d1Chart, navamsaChart: navamsa);
print('Karakamsa: ${karakamsa.sign.name}');

// Other Jaimini points available:
// - Amatyakaraka (Career significator)
// - Bhratrikaraka (Siblings)
// - Matrikaraka (Mother)
// - Putrakaraka (Children)
// - Gnatakaraka (Enemies)
// - Darakaraka (Spouse)
```

---

## Prashna (Horary) Astrology

```dart
// Calculate Arudha for a seed number (1-249)
final arudha = jyotish.calculatePrashnaArudha(108);
print('Prashna Arudha: ${arudha.name}');

// Calculate Sphutas
final sphutas = await jyotish.calculatePrashnaSphutas(d1Chart);
print('Trisphuta: ${sphutas.trisphuta.toStringAsFixed(2)}');
print('Charrasphuta: ${sphutas.charrasphuta}');
print('Kalasphuta: ${sphutas.kalasphuta}');

// Gulika (Maandi)
final gulika = await jyotish.calculateGulikaSphuta(d1Chart);
print('Gulika: ${gulika.toStringAsFixed(2)}°');
```

---

## House Strength (Vimsopaka Bala)

Vimsopaka Bala is a comprehensive system for measuring planetary strength through seven different factors.

```dart
// Calculate Vimsopaka Bala for all planets
final vimsopakaBala = jyotish.getVimsopakaBala(d1Chart);

for (final entry in vimsopakaBala.entries) {
  final planet = entry.key;
  final result = entry.value;
  print('${planet.displayName}:');
  print('  Total Score: ${result.totalScore.toStringAsFixed(2)}');
  print('  Varga Score: ${result.vargaScore.toStringAsFixed(2)}');
  print('  Sambandha Score: ${result.sambandhaScore.toStringAsFixed(2)}');
  print('  Category: ${result.category.name}');
}

/*
Categories:
- atipoorna (18+): Full strength
- poorna (16-18): Good strength  
- atimadhya (14-16): Above average
- madhya (12-14): Average
- adhama (10-12): Below average
- durga (8-10): Weak
- sangatDurga (<8): Very weak
*/
```

### Enhanced Bhava Bala

The enhanced Bhava Bala includes Vimsopaka strength along with directional and aspectual strengths.

```dart
// Calculate enhanced house strength
final enhancedBhavaBala = await jyotish.getEnhancedBhavaBala(d1Chart);

for (int house = 1; house <= 12; house++) {
  final result = enhancedBhavaBala[house];
  print('House $house:');
  print('  Total: ${result?.totalStrength.toStringAsFixed(2)}');
  print('  Lord Strength: ${result?.lordStrength.toStringAsFixed(2)}');
  print('  Kendradi Strength: ${result?.kendradiStrength.toStringAsFixed(2)}');
  print('  Drishti Strength: ${result?.drishtiStrength.toStringAsFixed(2)}');
  print('  Vimsopaka Strength: ${result?.vimsopakaStrength.toStringAsFixed(2)}');
  print('  Category: ${result?.category.name}');
  print('  Kendra Type: ${result?.kendraType.name}');
}

/*
House strength categories:
- atiShadbalapurna (150+): Very strong
- shadbalapurna (120-150): Strong
- shadbalardha (90-120): Moderate
- madhyama (60-90): Average
- krishna (30-60): Weak
- atiKrishna (<30): Very weak

Kendra types:
- kendra: 1, 4, 7, 10 (60 points)
- panaphara: 2, 5, 8, 11 (30 points)
- apoklima: 3, 6, 9, 12 (15 points)
*/
```

---

## Nadi Astrology

Nadi astrology uses 1800 Nadis (150 per sign) derived from the Moon's position to provide predictions.

```dart
// Calculate Nadi Chart
final nadiChart = jyotish.getNadiChart(d1Chart);

print('Moon Nadi: ${nadiChart.moonNadi.nadiName}');
print('Moon Nadi Type: ${nadiChart.moonNadi.nadiType.name}');
print('Sun Nadi: ${nadiChart.sunNadi.nadiName}');
print('Ascendant Nadi: ${nadiChart.ascendantNadi.nadiName}');

// Get Nadi for any longitude
final nadiFromLong = jyotish.getNadiFromLongitude(180.5);
print('Nadi at 180.5°: ${nadiFromLong.nadiName}');

// Get interpretation for a Nadi
final interpretation = jyotish.getNadiInterpretation(500);
print(interpretation);

/*
Nadi Types (cycling every 6 nadis):
- agasthiya: Wisdom and spiritual knowledge
- bhrigu: Knowledge and enlightenment
- saptarshi: Balance and harmony
- nandi: Happiness and prosperity
- bharga: Light and energy
- chandra: Calm and emotional

Nadi characteristics based on number:
- 1-100: Early life focus
- 101-500: Mid-life focus  
- 501-1000: Relationship focus
- 1001-1500: Spiritual evolution
- 1501-1800: Liberation focus
*/
```

### Identify Nadi Seed

```dart
// Get Nadi Seed from Nakshatra and Pada
final moonInfo = d1Chart.getPlanet(Planet.moon);
final seed = jyotish.identifyNadiSeed(
  nakshatraNumber: moonInfo?.position.nakshatraIndex ?? 1,
  pada: moonInfo?.pada ?? 1,
);

print('Nadi Seed: ${seed.seedNumber}');
print('Primary Nadi: ${seed.primaryNadi.nadiName}');
print('Nadi Type: ${seed.nadiType.name}');
```

---

## Progeny Analysis

Analyze childbirth prospects using multiple factors including 5th house, Jupiter, D7 chart, and child yogas.

```dart
// Analyze progeny prospects
final progenyResult = jyotish.analyzeProgeny(d1Chart);

print('Overall Strength: ${progenyResult.strength.name}');
print('Score: ${progenyResult.score}/100');

// Fifth House Analysis
print('\n5th House:');
print('  Score: ${progenyResult.fifthHouseStrength.score}');
print('  Is Strong: ${progenyResult.fifthHouseStrength.isStrong}');
print('  Planets in 5th: ${progenyResult.fifthHouseStrength.planetsInHouse}');
print('  Aspects: ${progenyResult.fifthHouseStrength.aspectsOnHouse}');

// Jupiter Condition
print('\nJupiter:');
print('  Score: ${progenyResult.jupiterCondition.score}');
print('  Is Strong: ${progenyResult.jupiterCondition.isStrong}');
print('  Is Exalted: ${progenyResult.jupiterCondition.isExalted}');
print('  Is Own Sign: ${progenyResult.jupiterCondition.isOwnSign}');
print('  House: ${progenyResult.jupiterCondition.house}');

// D7 Chart Analysis
print('\nD7 Chart:');
print('  Score: ${progenyResult.d7Analysis.score}');
print('  Is Strong: ${progenyResult.d7Analysis.isStrong}');

// Child Yogas
print('\nChild Yogas:');
for (final yoga in progenyResult.childYogas) {
  print('  ${yoga.name}: ${yoga.isPresent ? "Present" : "Not Present"}');
  if (yoga.isPresent) print('    ${yoga.description}');
}

// Analysis summary
print('\nAnalysis:');
for (final item in progenyResult.analysis) {
  print('  - $item');
}

/*
Progeny Strength levels:
- strong (60+): High probability of children
- moderate (40-60): Moderate probability
- weak (20-40): Some challenges
- veryWeak (<20): May face difficulties

Key factors:
- 5th house strength (lord, planets, aspects)
- Jupiter condition (exalted/own sign, in 1/5/9)
- D7 chart (5th lord, Jupiter, Venus, Moon)
- Child yogas present in chart
*/
```

### Individual Progeny Analyses

```dart
// Fifth house analysis only
final fifthHouse = jyotish.analyzeFifthHouse(d1Chart);

// Jupiter condition only
final jupiter = jyotish.analyzeJupiterCondition(d1Chart);

// Detect specific child yogas
final yogas = jyotish.detectChildYogas(d1Chart);

for (final yoga in yogas) {
  if (yoga.isPresent) {
    print('${yoga.name}: ${yoga.description}');
  }
}
```

---

## Marriage Compatibility

Calculate compatibility between two charts using Ashtakoota (36 Guna) matching with Dasha consideration.

```dart
// Calculate full compatibility
final boyChart = await jyotish.calculateVedicChart(
  dateTime: DateTime(1990, 5, 15, 14, 30),
  location: boyLocation,
);

final girlChart = await jyotish.calculateVedicChart(
  dateTime: DateTime(1992, 8, 20, 10, 0),
  location: girlLocation,
);

final compatibility = jyotish.calculateCompatibility(boyChart, girlChart);

print('Total Score: ${compatibility.totalScore}/36');
print('Level: ${compatibility.level.name}');
print('Analysis:');
for (final item in compatibility.analysis) {
  print('  - $item');
}
```

### Guna Milan (Ashtakoota)

The 8 koota system with 36 total points:

```dart
final gunaScores = jyotish.calculateGunaMilan(boyChart, girlChart);

print('Varna: ${gunaScores.varna}/1');
print('Vashya: ${gunaScores.vashya}/2');
print('Tara: ${gunaScores.tara}/3');
print('Yoni: ${gunaScores.yoni}/4');
print('Graha Maitri: ${gunaScores.grahaMaitri}/5');
print('Gana: ${gunaScores.gana}/6');
print('Bhakoot: ${gunaScores.bhakoot}/7');
print('Nadi: ${gunaScores.nadi}/8');
print('Total: ${gunaScores.total}/36');

/*
Compatibility Levels:
- excellent: 33-36
- veryGood: 25-32
- good: 18-24
- average: 12-17
- poor: <12

Kootas:
- Varna: Spiritua compatibility
- Vashya: Physical attraction
- Tara: Birth star compatibility
- Yoni: Physical compatibility
- Graha Maitri: Mental compatibility
- Gana: Temperament compatibility
- Bhakoot: Emotional compatibility
- Nadi: Health/offspring compatibility
*/
```

### Dosha Analysis

Check for Manglik, Nadi, and Bhakoot doshas:

```dart
final doshaCheck = jyotish.checkDoshas(boyChart, girlChart);

print('Manglik Dosha: ${doshaCheck.hasManglikDosha ? "Present" : "None"}');
print('Nadi Dosha: ${doshaCheck.hasNadiDosha ? "Present" : "None"}');
print('Bhakoot Dosha: ${doshaCheck.hasBhakootDosha ? "Present" : "None"}');

// Individual dosha checks
final manglik = jyotish.checkManglikDosha(boyChart);
print('Boy Manglik: ${manglik.isManglik}, Severity: ${manglik.severity}');

final nadiDosha = jyotish.checkNadiDosha(boyChart, girlChart);
print('Nadi: Boy ${nadiDosha.boyNadi}, Girl ${nadiDosha.girlNadi}');

final bhakootDosha = jyotish.checkBhakootDosha(boyChart, girlChart);
print('Bhakoot: ${bhakootDosha.description}');

// Dosha Cancellations
print('Cancellations: ${doshaCheck.cancellations}');

/*
Common cancellations:
- Nadi Dosha cancels Manglik Dosha
- If both have Manglik, it gets cancelled
*/
```

### Dasha Compatibility

```dart
final dashaCompat = jyotish.calculateDashaCompatibility(boyChart, girlChart);
print('Dasha Score: ${dashaCompat.score}');
```

---

## Location Helper

Create locations from degrees, minutes, seconds:

```dart
final location = GeographicLocation.fromDMS(
  latDegrees: 27,
  latMinutes: 43,
  latSeconds: 1.92,
  isNorth: true,
  lonDegrees: 85,
  lonMinutes: 19,
  lonSeconds: 26.4,
  isEast: true,
  altitude: 1400,
);
```

---

## Additional Resources

- [API Reference](API_REFERENCE.md) - Complete API documentation
- [README](README.md) - Project overview and features
