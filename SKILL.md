# Jyotish Library AI Agent Skill (skill.md)

This document provides essential instructions, patterns, and reference data for AI agents working with the `jyotish` Flutter library.

## 1. Core Principles
- **Vedic Accuracy**: The library uses high-precision Swiss Ephemeris.
- **Sunrise-Based Days**: In Vedic astrology, the day (Vara) begins at Sunrise, not midnight.
- **Coordinate Precision**: Always use decimal degrees for latitude/longitude.
- **Timezone Awareness**: Use IANA timezone identifiers (e.g., 'Asia/Kolkata').

## 2. Quick Start for Agents
### Initialization
Always initialize the `Jyotish` facade before any calculations.
```dart
final jyotish = Jyotish();
await jyotish.initialize(); // Loads ephemeris files
```

### Creating a Chart
```dart
final location = GeographicLocation(
  latitude: 28.6139,
  longitude: 77.2090,
  timezone: 'Asia/Kolkata',
);
final chart = await jyotish.calculateVedicChart(
  dateTime: DateTime.now(),
  location: location,
);
```

## 3. Important Models & Enums
- **Planet**: Enum representing Sun, Moon, Mars, Mercury, Jupiter, Venus, Saturn, Rahu, Ketu, plus outer planets/asteroids.
- **Rashi**: Enum representing Aries (1) to Pisces (12).
- **Nakshatra**: 1 to 27 (standard) or 28 (with Abhijit).
- **VedicChart**: Contains all planetary positions, house cusps, and divisional charts.
- **VargaConfiguration**: Specifies calculation variations for Divisional Charts (D2 Hora, D3 Drekkana, D9 Navamsha, D10 Dashamsha).
- **WarDetails**: Carries participant details, magnitudes, declinations, and the winner of a planetary war.
- **PrastaraResult**: Holds the 96-cell binary Ashtakavarga contribution grid (8 points × 12 signs) for a planet.
- **SpecialLagnas**: Carries calculated degrees for Hora Lagna (HL), Ghati Lagna (GL), and Sree Lagna (SL).
- **CompatibilityReport**: Contains Guna Milan score/details, Nadi & Bhakoot doshas, Manglik status, and cancellations.
- **MuhurtaScoreResult**: Holds composite 0-100% suitability score combining Tithi, Nakshatra, Vara, Yoga, Karana, and native Tara/Chandrabalam.
- **SarvatobhadraAnalysis**: Carries transit Vedha findings across all 81 squares of the Sarvatobhadra Chakra.
- **EventTimingWindow**: Holds high-probability life event prediction windows combining Dasha, Transit, and Ashtakavarga.
- **D10CareerAnalysis**: Holds 10th house, Amatyakaraka, and Dashamsha D10 professional indications.
- **ProgenyResult**: Holds 5th house, Jupiter, Saptamsha D7, Kshetra Sphuta, and Beeja Sphuta fertility indicators.
- **SudarshanChakraResult**: Carries 12-house evaluations viewed simultaneously from Lagna, Surya, and Chandra.
- **BhavaBalaResult**: 6-fold strength score for all 12 houses.
- **VimshopakBala**: Holds 20-point divisional dignity strength across Shadvarga, Saptavarga, Dasavarga, and Shodashavarga.
- **NadiInfo**: Holds Nadi amsha (150 divisions per sign) and planetary theme indications.
- **RitualElements**: Holds Panchanga ritual readiness (Homahuti, Agnivasa, Shivavasa, Kumbha Chakra).
- **GowriPanchangamInfo**: Holds Tamil/South Indian auspicious/inauspicious daytime and nighttime periods.
- **VargottamaStatus**: Enum representing planet's Vargottama state (`none`, `vargottama`, `neechaVargottama`, `ucchaVargottama`).
- **CompoundRelationship**: Enum representing Panchadha Maitri relationship (`greatFriend`, `friend`, `neutral`, `enemy`, `greatEnemy`).
- **House**: Model representing individual houses with attributes (`number`, `cusp`, `zodiacSign`) and classifications (`isKendra`, `isTrikona`, `isDusthana`, `isUpachaya`).
- **NatalYoga**: Holds detected yoga results with attributes (`key`, `name`, `category`, `description`, `benefits`, `isPresent`, `explanation`).
- **FullDoshaReport**: Holds detected individual natal doshas (Kala Sarpa, Manglik with 17 exceptions, Pitru, Guru Chandala, Ganda Moola, Kalathra, Ghata, and Shrapit).
- **VedicTime**: Model representing traditional time elapsed since sunrise (`ghati`, `vighati`, `lipta`, `prana`, `currentSunrise`, `nextSunrise`, `totalGhatis`).

## 4. Common Tasks & Service Access
| Task | Recommended Method |
|------|-------------------|
| **JyotishSystems Facade** | Access 40+ domain services directly: `jyotish.systems.dasha`, `jyotish.systems.kp`, `jyotish.systems.shadbala`, `jyotish.systems.dosha`, `jyotish.systems.yoga`, `jyotish.systems.grahaYuddha`, `jyotish.systems.gocharaVedha`, `jyotish.systems.sarvatobhadra`, `jyotish.systems.nadi`, etc. |
| **Panchanga** | `jyotish.calculatePanchanga(dateTime: dt, location: loc)` |
| **Dasha** | `jyotish.getVimshottariDasha(natalChart: chart)` (Includes 1st Mahadasha elapsed balance calculation) |
| **Muhurta** | `jyotish.calculateMuhurta(date: d, sunrise: sr, sunset: ss, location: l)` |
| **Muhurta Scoring** | `jyotish.calculateMuhurtaScore(...)` / `jyotish.scanMuhurtaSuitability(...)` (0-100% time suitability) |
| **Divisional Charts** | `jyotish.getDivisionalChart(rashiChart: chart, type: DivisionalChartType.d9, config: config)` |
| **Graha Yuddha** | `jyotish.checkGrahaYuddha(chart)` (Evaluates conjunction <= 1°, magnitude, and declination) |
| **Prastara Grid** | `jyotish.calculatePrastaraAshtakavarga(chart, planet)` |
| **Ashtakavarga Shodhana** | `jyotish.applyEkadhipatiShodhana(ashtakavarga)` (Canonical BPHS Ch. 67 planetary occupancy rules) |
| **Special Lagnas** | `jyotish.calculateSpecialLagnas(chart, sunrise)` (Hora Lagna, Ghati Lagna, Sree Lagna) |
| **Compatibility Report** | `jyotish.calculateCompatibilityReport(boyChart, girlChart)` (36 Guna Milan without double penalty) |
| **Gochara Vedha** | `jyotish.systems.gocharaVedha.calculateVedha(...)` (Classical house pairs & Vipareeta Vedha) |
| **Sarvatobhadra Chakra**| `jyotish.analyzeSarvatobhadra(natalChart: chart, transitDateTime: dt)` (81-square Vedha analysis) |
| **Special Transits** | `jyotish.getSpecialTransits(chart, transitDate)` (Sade Sati, Dhaiya, Ashtama Shani, Panchak) |
| **Event Timing** | `jyotish.analyzeEventTiming(chart, category: EventCategory.marriage)` |
| **Career D10 Analysis** | `jyotish.analyzeCareerD10(chart)` |
| **Progeny D7 Analysis** | `jyotish.analyzeProgeny(chart)` (Kshetra/Beeja Sphuta & Saptamsha D7) |
| **Sudarshan Chakra** | `jyotish.calculateSudarshanChakra(chart)` (Lagna, Surya, Chandra triple perspective) |
| **Brahma Muhurta** | `jyotish.calculateBrahmaMuhurta(date: dt, location: loc)` (14th Muhurta of night) |
| **Abhijit Muhurta** | `jyotish.calculateAbhijitMuhurta(date: dt, location: loc)` (8th daytime Muhurta around midday) |
| **Special Yogas**| Access `muhurta.specialYogas` for Sarvartha Siddhi, Guru Pushya, etc. |
| **Gowri Panchangam** | `jyotish.getCurrentGowriPanchangam(dateTime: dt, location: loc)` |
| **Ritual Elements** | `jyotish.calculateRitualElements(panchanga: p)` (Homahuti, Agnivasa, Shivavasa, Kumbha Chakra) |
| **Nadi Astrology** | `jyotish.getNadiInfo(planet: p, longitude: lon)` (150 Nadi amshas per sign) |
| **KP Sub-Lords** | `jyotish.calculateKPData(natalChart: chart)` (Sub-Lords, Sub-Sub-Lords, ABCD significators) |
| **Jaimini Karakas** | `jyotish.getCharaKarakas(chart)` / `jyotish.getAtmakaraka(chart)` / `jyotish.getKarakamsa(chart)` |
| **Arudha Padas** | `jyotish.getArudhaPadas(chart)` / `jyotish.getArudhaLagna(chart)` / `jyotish.getUpapada(chart)` |
| **Argala & Virodha** | `jyotish.getAllArgalas(chart)` |
| **Julian Day** | `ephemerisService.dateTimeToJulianDay(dateTime, timezoneId: tz)` |
| **Moolatrikona Check** | `planetInfo.isMoolatrikona` |
| **Vargottama Check** | `chart.isVargottama(planet)` / `chart.getVargottamaStatus(planet)` |
| **Deep Exalt/Debilit Check** | `planetInfo.isDeepExalted(orb)` / `planetInfo.isDeepDebilitated(orb)` |
| **Combustion Distance** | `planetInfo.combustionDistance` |
| **Compound Friendship** | `chart.getCompoundRelationship(planetA, planetB)` |
| **House Classification** | `house.isKendra` / `house.isTrikona` / `house.isDusthana` / `house.isUpachaya` |
| **True Solar Return** | `varshapalService.calculateSolarReturn(birthDateTime: dt, targetYear: yr, location: loc)` |
| **Panchavargiya Bala** | `varshapalService.calculatePanchavargiyaBala(planet, chart)` |
| **Varshesh Determination** | `varshapalService.determineVarshesh(natalChart: nc, annualChart: ac, balaMap: bm, varshaDateTime: vdt, birthDateTime: bdt)` |
| **Mudda Dasha** | `varshapalService.calculateMuddaDasha(birthDateTime: bdt, varshaDateTime: vdt, annualChart: ac, location: loc, flags: f)` |
| **Gregorian to Vedic Time** | `VedicTime.calculate(time: dt, location: loc, getSunriseSunset: fn)` |
| **Vedic Time to Gregorian** | `vt.toDateTime()` |
| **Yoga Detection** | `YogaService().detectNatalYogas(chart)` |
| **Dosha Detection** | `jyotish.checkNatalDoshas(chart)` / `DoshaService().calculateFullDoshaReport(chart)` |
| **Manglik Raman Check** | `jyotish.checkManglikDoshaWithRamanExceptions(chart)` |
| **Eclipse Predictions** | `EclipseService().getLunarEclipses(startYear: s, endYear: e)` / `getSolarEclipses(...)` |
| **Clear Caches** | `jyotish.clearCache()` / `ephemerisService.clearCache()` |
| **SVG Chart Export** | `chart.toSVG(style: ChartStyle.northIndian)` |
| **Flutter Chart Widget** | `VedicChartView(chart: chart, style: ChartStyle.northIndian)` |
| **Lazy Dasha Stream** | `jyotish.systems.dasha.streamVimshottariDasha(moonLongitude: ml, birthDateTime: dt, maxLevel: lvl)` |
| **Dynamic Timezone Load**| `Jyotish.loadTimezoneDatabase(bytes)` |

## 5. System Differentiator: Traditional vs KP
Crucial for v2.5.0+:
- **Traditional**: Use `CalculationFlags.traditionalist()`. Best for Parashari, Dasha, Shadbala.
- **KP System**: Use `CalculationFlags.kp()`. **Mandatory** for KP Sub-Lords and significators. Chart positions are generated directly in KP ayanamsa.

## 6. Performance, Threads, & Tree Shaking
- For batch calculations (e.g., searching periods), use `Async` variants like `getAllPlanetsVimshopakBalaAsync` to avoid blocking the UI thread.
- `EphemerisService` is a singleton; do not re-initialize it unnecessarily.
- **Tree Shaking & Module Imports (v2.12.0+)**: To reduce application compiled sizes, import micro-targeted barrel files instead of the monolithic `package:jyotish/jyotish.dart`. Available barrel modules:
  - `package:jyotish/core.dart` (facade, location, flags, planets, rashis)
  - `package:jyotish/panchanga.dart` (tithi, vara, nakshatra, yoga, karana, masa)
  - `package:jyotish/systems.dart` (dashas, ashtakavarga, KP system, Varshapal, Jaimini, Prashna)
  - `package:jyotish/transit.dart` (movements, Sade Sati, transit events, Gochara Vedha, Sarvatobhadra)
  - `package:jyotish/strength.dart` (Shadbala, Vimshopak, Avasthas, relationships)
  - `package:jyotish/analysis.dart` (charts, divisional charts, compatibility, progeny, aspects, dosha, graha yuddha, Natal Yoga detection)
  - `package:jyotish/astronomy.dart` (ephemeris coordinates, rise/set calculations, Eclipse predictions)
  - `package:jyotish/muhurta.dart` (auspicious times, Horas, Choghadiyas, Vedic Time, VedicDigitalClock, VedicAnalogClock)
  - `package:jyotish/nadi.dart` (nadi prediction services)

## 7. Common Gotchas for Agents
- **Brahma Muhurta**: Depends on the *previous day's* sunset and today's sunrise (14th Muhurta of night = 2 muhurtas / 96 minutes before sunrise). Use `jyotish.calculateBrahmaMuhurta(date: d, location: loc)`.
- **Abhijit Muhurta**: The 8th Muhurta of the daytime (midday). Inauspicious on Wednesdays. Use `jyotish.calculateAbhijitMuhurta(date: d, location: loc)`.
- **Moon Illumination**: v2.1.0 corrected the formula. 0% = New Moon (Amavasya), 100% = Full Moon (Purnima).
- **Vedic Weekday & Sunrise**: Day transitions at local sunrise. For date-only parameters `DateTime(year, month, day)`, the day belongs to that day's sunrise.
- **Karanas**: 4 Sthira Karanas (Kimstughna, Shakuni, Chatushpada, Naga) have `isFixed: true`; the 7 Chara Karanas (Bava through Vishti) have `isFixed: false`.
- **Shadbala Sun/Moon Chesta Bala**: Sun Chesta Bala is Ayana Bala; Moon Chesta Bala is Paksha Bala per classical BPHS.
- **Special Yogas**: Requires Tithi and Nakshatra periods to be passed to `calculateMuhurta` for accurate intersection calculation.
- **Positional Records**: In `calculateMuhurta` parameters, use `(int, DateTime, DateTime)` records. Access fields as `$1`, `$2`, `$3`.

## 8. Reference Data
- **Weekday Numbers**: 0=Sunday, 1=Monday, ..., 6=Saturday.
- **Tithi Numbers**: 1-15 (Shukla), 16-30 (Krishna). 15=Purnima, 30=Amavasya.
- **House Systems**: 'W' (Whole Sign - Default), 'P' (Placidus - Mandatory for KP).

---
*This skill file was last updated for API_REFERENCE.md v2.18.0 — includes JyotishSystems facade exposure, classical BPHS Shadbala & Ashtakavarga reductions, Gochara Vedha pairs, and Graha Yuddha evaluation.*

