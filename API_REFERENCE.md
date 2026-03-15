# Jyotish Library API Reference

A comprehensive API reference for the Jyotish Flutter library - production-ready Vedic astrology using Swiss Ephemeris.

---

## Table of Contents

- [Quick Start](#quick-start)
- [Core Classes](#core-classes)
  - [Jyotish](#jyotish)
  - [GeographicLocation](#geographiclocation)
  - [CalculationFlags](#calculationflags)
- [New in v2.6.0 — High-Precision Eclipse Reporting](#new-in-v260--high-precision-eclipse-reporting)
- [New in v2.5.0 — AstrologicalSystem](#new-in-v250--astrologicalsystem)
- [New in v2.4.0](#new-in-v240)
  - [Bhava Chalit (Cuspal Chart)](#bhava-chalit-cuspal-chart)
  - [Pancha-Vargeeya Maitri (5-fold Friendship)](#pancha-vargeeya-maitri)
  - [Ayanamsa Utility](#ayanamsa-utility)
  - [Reference Chart Test Suite](#reference-chart-test-suite)
- [New in v2.5.0](#new-in-v250)
  - [Ashtakavarga Shodhana (Reductions)](#ashtakavarga-shodhana-reductions)
  - [BPHS Dasha Applicability](#bphs-dasha-applicability)
  - [Shadbala Minimum Requirements](#shadbala-minimum-requirements)
- [New in v2.3.0](#new-in-v230)
  - [Professional Features Suite](#professional-features-suite)
  - [Graha Avastha & Strength Reports](#graha-avastha--strength-reports)
  - [Event Timing Engine](#event-timing-engine)
  - [Sarvatobhadra Chakra](#sarvatobhadra-chakra)
- [Services](#services)
  - [EphemerisService](#ephemerisservice)
  - [VedicChartService](#vedicchartservice)
  - [DashaService](#dashaservice)
  - [VarshapalService](#varshapalservice)
  - [PanchangaService](#panchangaservice)
  - [AshtakavargaService](#ashtakavargaservice)
  - [AspectService](#aspectservice)
  - [TransitService](#transitservice)
  - [SpecialTransitService](#specialtransitservice)
  - [DivisionalChartService](#divisionalchartservice)
  - [ShadbalaService](#shadbalaservice)
  - [KPService](#kpservice)
  - [MuhurtaService](#muhurtaservice)
  - [MasaService](#masaservice)
  - [SudarshanChakraService](#sudarshanchakraservice)
  - [StrengthAnalysisService](#strengthanalysisservice)
  - [GocharaVedhaService](#gocharavedhaservice)
  - [HoraService](#horaservice)
  - [ChoghadiyaService](#choghadiyaservice)
  - [GowriPanchangamService](#gowripanchangamservice)
  - [BhavaBalaService](#bhavabalaservice)
  - [JaiminiService](#jaiminiservice)
  - [ArudhaPadaService](#arudhapadaservice)
  - [ArgalaService](#argalaservice)
  - [PrashnaService](#prashnaservice)
  - [GocharaVedhaService](#gocharavedhaservice)
  - [HouseStrengthService](#housestrengthservice)
  - [NadiService](#nadiservice)
  - [ProgenyService](#progenyservice)
  - [CompatibilityService](#compatibilityservice)
- [Models](#models)
  - [VedicChart](#vedicchart)
  - [PlanetPosition](#planetposition)
  - [VedicPlanetInfo](#vedicplanetinfo)
  - [Panchanga](#panchanga)
  - [DashaResult](#dasharesult)
  - [Varshapal](#varshapal)
  - [VarshapalPeriod](#varshapaperiod)
  - [Ashtakavarga](#ashtakavarga)
  - [VimshopakBala](#vimshopakbala)
  - [CombustionInfo](#combustioninfo)
  - [YogaPindaResult](#yogapindaresult)
  - [ShodhyaPindaResult](#shodhyapindaresult)
  - [VedhaResult](#vedharesult)
  - [PlanetVisibility](#planetvisibility)
  - [EclipseData](#eclipsedata)
  - [AbhijitMuhurta](#abhijitmuhurta)
  - [BrahmaMuhurta](#brahmamuhurta)
  - [NighttimeInauspiciousPeriods](#nighttimeinauspiciousperiods)
  - [MoonPhaseDetails](#moonphasedetails)
  - [YogaDetails](#yogadetails)
  - [GowriPanchangamInfo](#gowripanchangaminfo)
  - [GowriType](#gowritype)
  - [BhavaBalaResult](#bhavabalaresult)
  - [BhavaStrengthCategory](#bhavastrengthcategory)
  - [HoraPeriod](#horaperiod)
  - [Choghadiya](#choghadiya)
  - [ChoghadiyaType](#choghadiyatype)
  - [ArudhaPadaInfo](#arudhapadainfo)
  - [ArudhaPadaResult](#arudhapadaresult)
  - [ArgalaInfo](#argalainfo)
  - [KarakamsaInfo](#karakamsainfo)
  - [RashiDrishtiInfo](#rashidrishtiinfo)
  - [PrashnaSphutas](#prashnasphutas)
  - [SudarshanChakraResult](#sudarshanchakraresult)
  - [VimsopakaBalaResult](#vimsopakabalaresult)
  - [VimsopakaCategory](#vimsopakacategory)
  - [EnhancedBhavaBalaResult](#enhancedbhavabalaresult)
  - [NadiInfo](#nadiinfo)
  - [NadiChart](#nadichart)
  - [NadiType](#naditype)
  - [ProgenyResult](#progenyresult)
  - [ProgenyStrength](#progenystrength)
  - [CompatibilityResult](#compatibilityresult)
  - [GunaScores](#gunascores)
  - [CompatibilityLevel](#compatibilitylevel)
- [Enums](#enums)
- [Professional Features (v2.3.0)](#professional-features-v230)
- [New in v2.6.0 — High-Precision Eclipse Reporting](#new-in-v260--high-precision-eclipse-reporting)
- [Error Handling](#error-handling)
- [Best Practices](#best-practices)

---

## Quick Start

```dart
import 'package:jyotish/jyotish.dart';

// 1. Initialize
final jyotish = Jyotish();
await jyotish.initialize();

// 2. Define location
final location = GeographicLocation(
  latitude: 27.7172,   // Kathmandu, Nepal
  longitude: 85.3240,
  altitude: 1400,
  timezone: 'Asia/Kathmandu',
);

// 3. Calculate birth chart
final chart = await jyotish.calculateVedicChart(
  dateTime: DateTime(1990, 5, 15, 14, 30),
  location: location,
);

// 4. Access chart data
print('Ascendant: ${chart.ascendantSign}');
print('Moon: ${chart.getPlanet(Planet.moon)?.zodiacSign}');

// 5. Cleanup
jyotish.dispose();
```

---

## Core Classes

### Jyotish

The main entry point for all library operations. Provides a high-level API wrapping all services.

#### Initialization

```dart
final jyotish = Jyotish();
await jyotish.initialize({String? ephemerisPath});
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `ephemerisPath` | `String?` | No | Custom path to Swiss Ephemeris data files |

| Property | Type | Description |
|----------|------|-------------|
| `isInitialized` | `bool` | Whether the library has been initialized |

#### Planetary Position Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `getPlanetPosition({planet, dateTime, location, flags?})` | `Future<PlanetPosition>` | Calculate single planet position |
| `getMultiplePlanetPositions({planets, dateTime, location, flags?})` | `Future<Map<Planet, PlanetPosition>>` | Calculate multiple planets |
| `getAllPlanetPositions({dateTime, location, flags?})` | `Future<Map<Planet, PlanetPosition>>` | All major planets (Sun-Pluto) |

#### Chart Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `calculateVedicChart({dateTime, location, houseSystem?, includeOuterPlanets?, flags?})` | `Future<VedicChart>` | Complete Vedic birth chart |
| `getDivisionalChart({rashiChart, type})` | `VedicChart` | Calculate divisional chart (D1-D60, D249) |

#### Aspect Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `getAspects({dateTime, location, config?})` | `Future<List<AspectInfo>>` | All planetary aspects |
| `getAspectsForPlanet({planet, dateTime, location})` | `Future<List<AspectInfo>>` | Aspects for specific planet |
| `getChartAspects(chart, {config?})` | `List<AspectInfo>` | Aspects within a chart |
| `getRashiAspects(chart, {activeOnly?})` | `List<RashiDrishtiInfo>` | Jaimini Sign Aspects (Movable/Fixed/Dual) |

#### Dasha Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `getVimshottariDasha({natalChart, levels?, birthTimeUncertainty?, yearLength?})` | `Future<DashaResult>` | Vimshottari Dasha (120-year). yearLength: 365.25 (default) or 360.0 for Savana year |
| `getYoginiDasha({natalChart, levels?})` | `Future<DashaResult>` | Yogini Dasha (36-year) |
| `getCharaDasha({natalChart, levels?})` | `Future<CharaDashaResult>` | Chara Dasha (Jaimini) |
| `getNarayanaDasha({chart, levels?})` | `Future<NarayanaDashaResult>` | Narayana Dasha (Jaimini) |
| `getAshtottariDasha({natalChart, scheme?, forceCalculation?, levels?})` | `Future<DashaResult>` | Ashtottari Dasha (108-year) |
| `getKalachakraDasha({natalChart, levels?})` | `Future<DashaResult>` | Kalachakra Dasha (levels 1=MD, 2=AD) |
| `getCurrentDasha({natalChart, targetDate, type?})` | `DashaPeriod` | Current active period |

#### Professional Analysis Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `getStrengthReport(chart)` | `Future<StrengthReport>` | Combined planetary strength summary |
| `getGrahaAvastha(planet, chart)` | `GrahaAvastha` | Baladi & Jagratadi states |
| `findEventTimingWindows(request)` | `Future<List<EventTimingWindow>>` | Search for dates matching Dasha+Transit criteria |
| `getD10CareerAnalysis(natalChart)` | `Future<D10CareerAnalysis>` | Career specialization from Dashamsha |
| `getKPDivisionTable()` | `List<KPDivisionEntry>` | Full 249 sub-lord boundary table |
| `analyzeSarvatobhadra({natalChart, transitPositions})` | `SarvatobhadraAnalysis` | Transit Vedha analysis on star grid |
| `getTajakaEnhancements({natalChart, annualChart, age})` | `TajakaEnhancement` | Muntha, Sahams, and Tajaka Yogas |


#### Varshapal (Annual Chart) Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `getVarshapal({birthDateTime, varshaDateTime, location, houseSystem?, checkDate?})` | `Future<Varshapal>` | Annual chart for specific year |
| `getCurrentVarshapal({birthDateTime, location, houseSystem?, checkDate?})` | `Future<Varshapal>` | Current year's annual chart |

#### Transit Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `getTransitPositions({natalChart, transitDateTime?, location})` | `Future<Map<Planet, TransitInfo>>` | Transit positions vs natal |
| `getTransitEvents({natalChart, startDate, endDate, location, planets?})` | `Future<List<TransitEvent>>` | Transit events in date range |
| `calculateSpecialTransits({natalChart, checkDate?, location})` | `Future<SpecialTransits>` | Sade Sati, Dhaiya, Panchak |
| `predictSadeSatiPeriods(natalChart, {yearsBefore?, yearsAfter?})` | `List<Map<String, dynamic>>` | Past/future Sade Sati periods |

#### Sunrise/Sunset & Rise/Set Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `getSunriseSunset({date, location, atpress?, attemp?})` | `Future<(DateTime?, DateTime?)>` | High-precision sunrise/sunset |
| `getRiseSet({planet, date, location, rsmi, atpress?, attemp?, searchFromExactTime?})` | `Future<DateTime?>` | Rise/set time. `searchFromExactTime` (default false): when true, uses full DateTime for search start rather than truncating to midnight. |

#### Panchanga Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `calculatePanchanga({dateTime, location})` | `Future<Panchanga>` | Complete Panchanga (5 limbs) |
| `getTithi({dateTime, location})` | `Future<TithiInfo>` | Lunar day |
| `getTithiJunction({targetTithiNumber, startDate, location})` | `Future<DateTime>` | Exact time a Tithi begins/ends |
| `getTithiEndTime({dateTime, location, accuracyThreshold?})` | `Future<DateTime>` | Precise Tithi end time |
| `getYoga({dateTime, location})` | `Future<YogaInfo>` | Sun-Moon combination |
| `getKarana({dateTime, location})` | `Future<KaranaInfo>` | Half-Tithi |
| `getVara({dateTime, location})` | `Future<VaraInfo>` | Weekday/planetary lord |
| `getNakshatra({dateTime, location})` | `Future<NakshatraInfo>` | Moon's nakshatra |
| `getNakshatraWithAbhijit({dateTime, location})` | `Future<NakshatraInfo>` | With 28th nakshatra |
| `calculateAbhijitMuhurta({date, location})` | `Future<AbhijitMuhurta>` | Auspicious midday period |
| `calculateBrahmaMuhurta({date, location})` | `Future<BrahmaMuhurta>` | Auspicious pre-dawn period |
| `calculateNighttimeInauspicious({date, location})` | `Future<NighttimeInauspiciousPeriods>` | Nighttime inauspicious times |
| `getMoonPhaseDetails({dateTime, location})` | `Future<MoonPhaseDetails>` | Illumination, age, velocity |

#### Ashtakavarga Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `calculateAshtakavarga(natalChart)` | `Ashtakavarga` | Complete Ashtakavarga |
| `calculateAshtakavargaWithShodhana(natalChart)` | `AshtakavargaWithShodhana` | Raw + Shodhana Reductions |
| `analyzeAshtakavargaTransit({ashtakavarga, transitPlanet, transitSign})` | `TransitAnalysis` | Transit strength analysis |
| `getAshtakavargaReductions(ashtakavarga, {trikonaReduction?, ekadhipatiReduction?})` | `Ashtakavarga` | Reduced Ashtakavarga |
| `calculatePinda(ashtakavarga)` | `Map<Planet, PindaResult>` | Rashi + Graha Pinda strength |
| `calculateYogaPinda(ashtakavarga)` | `Map<Planet, YogaPindaResult>` | Auspicious Yoga Pinda |
| `calculateShodhyaPinda(ashtakavarga)` | `ShodhyaPindaResult` | Reduced Shodhya Pinda |
| `calculateHousePinda(ashtakavarga, houseNumber)` | `double` | Pinda for specific house |
| `calculateAllHousesPinda(ashtakavarga)` | `Map<int, double>` | Pinda for all 12 houses |

#### KP System Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `calculateKPData(natalChart, {useNewAyanamsa?})` | `Future<KPCalculations>` | Complete KP data (ayanamsa-adjusted Sub-Lords, cusp-based significators) |
| `getSubLord(longitude)` | `Planet` | Sub-Lord for longitude |
| `getSubSubLord(longitude)` | `Planet` | Sub-Sub-Lord |
| `getHouseGroupSignificators(significators)` | `KPHouseGroupSignificators` | House group significators |
| `calculateTransitKPDivisions(transitPositions)` | `Map<Planet, KPDivision>` | Transit KP divisions |
| `compareKPTransitToNatal({natalChart, natalKP?, transitDateTime?, location, useNewAyanamsa?})` | `Future<List<KPTransitComparison>>` | Transit vs natal Sub-Lord comparison, sorted by match strength |
| `getKPRulingPlanets({chart, useNewAyanamsa?})` | `Future<KPRulingPlanets>` | Seven KP Ruling Planets for a Prashna query moment |

> **Accuracy note (v2.2.0)**: C and D significators now use the chart's actual Placidus house cusps (`getOwnedHousesFromChart`) instead of the fixed natural Aries Lagna sign map. This ensures Mars correctly shows houses 5 & 12 for a chart where Aries falls on the 5th cusp, rather than always returning houses 1 & 8.

#### Muhurta Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `calculateMuhurta({date, sunrise, sunset, location})` | `Muhurta` | Complete Muhurta |
| `getHoraPeriods({date, sunrise, sunset})` | `List<HoraPeriod>` | Planetary hours |
| `getCurrentHora({dateTime, location})` | `Future<HoraPeriod>` | Current planetary hour |
| `getHorasForDay({date, location})` | `Future<List<HoraPeriod>>` | All Horas for a day |
| `getChoghadiya({date, sunrise, sunset})` | `ChoghadiyaPeriods` | Choghadiya periods |
| `getCurrentChoghadiya({dateTime, location})` | `Future<Choghadiya>` | Current Choghadiya |
| `getInauspiciousPeriods({date, sunrise, sunset})` | `InauspiciousPeriods` | Rahukalam, Gulikalam, Yamagandam |
| `findBestMuhurta({muhurta, activity})` | `List<MuhurtaPeriod>` | Best times for activity |
| `getCurrentGowriPanchangam({dateTime, location})` | `Future<GowriPanchangamInfo>` | Current Gowri Panchangam |

#### Nakshatra Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `getNakshatra({dateTime, location})` | `Future<NakshatraInfo>` | Moon's nakshatra |
| `getNakshatraWithAbhijit({dateTime, location})` | `Future<NakshatraInfo>` | With 28th nakshatra |
| `getNakshatraForPlanet({planet, dateTime, location})` | `Future<NakshatraInfo>` | Nakshatra for any planet |
| `isInAbhijitNakshatra(longitude)` | `bool` | Check if longitude is in Abhijit |
| `getAbhijitBoundaries()` | `(double, double)` | Abhijit start/end longitude |
| `getTithiEndTime({dateTime, location, accuracyThreshold?})` | `Future<DateTime>` | Precise Tithi end time |
| `getVara({dateTime, location})` | `Future<VaraInfo>` | Weekday/planetary lord |

#### Masa Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `getMasa({dateTime, location, type?})` | `Future<MasaInfo>` | Lunar month |
| `getAmantaMasa({dateTime, location})` | `Future<MasaInfo>` | Amanta system |
| `getPurnimantaMasa({dateTime, location})` | `Future<MasaInfo>` | Purnimanta system |
| `getSamvatsara({dateTime, location})` | `Future<String>` | 60-year cycle name |
| `getSamvatInfo({dateTime, location})` | `Future<SamvatInfo>` | Vikram/Shaka/Gujarati Samvat |
| `getAyana({dateTime, location})` | `Future<Ayana>` | Uttarayana or Dakshinayana |
| `getPravishte({dateTime, location})` | `Future<PravishteInfo>` | Solar Day/Month |
| `getMasaListForYear({year, location, type?})` | `Future<List<MasaInfo>>` | All months in year |
| `getRitu(masaInfo)` | `Ritu` | Hindu season |
| `getRituDetails({dateTime, location})` | `Future<RituInfo>` | Detailed season info |

#### Ephemeris Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `calculateHouses({dateTime, location, houseSystem?})` | `Future<Map<String, List<double>>>` | House cusps and ascendant/MC |

#### Shadbala & Strength Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `getShadbala(chart)` | `Future<Map<Planet, ShadbalaResult>>` | Six-fold planetary strength |
| `getVimshopakBala(planet, chart)` | `double` | 20-fold planetary strength for one planet |
| `getAllPlanetsVimshopakBala(chart)` | `Map<Planet, VimshopakBala>` | 20-fold strength for all planets |
| `getIshtaphala(planet, chart, shadbala)` | `double` | Auspicious potential (0-60) |
| `getKashtaphala(planet, chart, shadbala)` | `double` | Inauspicious potential (0-60) |

#### Astrological Strength & Rituals (Panchang)

| Method | Returns | Description |
|--------|---------|-------------|
| `calculateChandrabalam({currentMoonNakshatra})` | `ChandrabalamInfo` | Moon strength for all 12 Rashis |
| `calculateTarabalam({birthNakshatraIndex, currentNakshatra})` | `TarabalamInfo` | Star strength (Janma, Sampat, etc.) |
| `calculateUdayaLagnas({date, location, sunrise})` | `Future<List<UdayaLagnaPeriod>>` | 12 Daily Ascendant periods |
| `calculateRitualElements({panchanga})` | `RitualElements` | Homahuti, Agnivasa, Shivavasa, Kumbha Chakra |

#### Sudarshan Chakra & Bhava Bala

| Method | Returns | Description |
|--------|---------|-------------|
| `calculateSudarshanChakra(chart)` | `SudarshanChakraResult` | Triple-perspective strength analysis |
| `getSudarshanChakra(chart)` | `SudarshanChakraResult` | Get Sudarshan Chakra (alias) |
| `getBhavaBala(chart)` | `Future<Map<int, BhavaBalaResult>>` | House Strength (Bhava Bala service) |
| `getStrengthBhavaBala({chart, shadbalaResults})` | `Map<int, double>` | House Strength (Strength Analysis service) |

#### Gochara Vedha (Transit Obstruction)

| Method | Returns | Description |
|--------|---------|-------------|
| `calculateGocharaVedha({transitPlanet, houseFromMoon, moonNakshatra, otherTransits})` | `VedhaResult` | Check Vedha for single transit |
| `calculateMultipleGocharaVedha({transits, moonNakshatra})` | `List<VedhaResult>` | Check Vedha for multiple transits |
| `hasMutualVedha(planet1, house1, planet2, house2)` | `bool` | Check bidirectional obstruction |
| `findFavorablePeriodsWithoutVedha(transitsOverTime)` | `List<FavorablePeriod>` | Find clear transit windows |
| `getVedhaRemedies(vedhaResult)` | `List<String>` | Suggest remedies for obstruction |

#### Extended Dasha Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `getCharaDasha({natalChart, levels?})` | `Future<DashaResult>` | Chara Dasha (Jaimini) |
| `getNarayanaDasha({chart, levels?})` | `Future<DashaResult>` | Narayana Dasha (Jaimini) |

#### Prashna (Horary) Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `calculatePrashnaArudha(seed)` | `Rashi` | Arudha based on seed (1-249) |
| `calculatePrashnaSphutas(chart)` | `Future<PrashnaSphutas>` | Trisphuta, Chatursphuta, etc. |
| `calculateGulikaSphuta(chart)` | `Future<double>` | Gulika position |

#### House Strength & Vimsopaka Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `getEnhancedBhavaBala(chart)` | `Future<Map<int, EnhancedBhavaBalaResult>>` | Enhanced house strength |
| `getVimsopakaBala(chart)` | `Map<Planet, VimsopakaBalaResult>` | Divisional chart strength |

#### Nadi Astrology Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `calculateNadiChart(chart)` | `NadiChart` | Complete Nadi positions |
| `getNadiFromLongitude(longitude)` | `NadiInfo` | Nadi for longitude |
| `getNadiInterpretation(nadiNumber)` | `String` | Nadi prediction |
| `identifyNadiSeed(nakshatra, pada)` | `NadiSeedResult` | Primary Nadi seed |

#### Progeny (Child) Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `analyzeProgeny(chart)` | `ProgenyResult` | Complete progeny analysis |
| `analyzeFifthHouse(chart)` | `FifthHouseStrength` | 5th house analysis |
| `analyzeJupiterCondition(chart)` | `JupiterCondition` | Jupiter as child karaka |
| `detectChildYogas(chart)` | `List<ChildYoga>` | Favorable combinations |

#### Marriage Compatibility Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `calculateCompatibility(boyChart, girlChart)` | `CompatibilityResult` | Full compatibility + doshas |
| `calculateGunaMilan(boyChart, girlChart)` | `GunaScores` | All 8 Ashtakoota scores |
| `calculateVashya(boyChart, girlChart)` | `int` | **[CHANGED v2.1.0]** Rashi-based classification (0-2 pts) |
| `calculateYoni(boyNakshatra, girlNakshatra)` | `int` | Uses correct 14x14 matrix scoring (0-4 pts) |
| `checkManglikDosha(chart)` | `ManglikDoshaResult` | Mars in 1/2/4/7/8/12 houses |
| `checkNadiDosha(boyChart, girlChart)` | `NadiDoshaResult` | Nadi match with cancellation rules |
| `checkBhakootDosha(boyChart, girlChart)` | `BhakootDoshaResult` | 2/12, 5/9, 6/8 pairs with cancellation rules |
| `checkDoshas(boyChart, girlChart)` | `DoshaCheck` | All dosha checks combined |
| `calculateDashaCompatibility(boyChart, girlChart)` | `DashaCompatibility` | Dasha timing compatibility |

> **API Change (v2.1.0)**: `calculateVashya` signature has changed from `(String boyNakshatra, String girlNakshatra)` to `(VedicChart boyChart, VedicChart girlChart)` to implement correct Rashi-based Vashya Koota classification according to traditional texts.
>
> **Calculation Updates (v2.1.0)**:
> - **Bhakoot & Nadi Dosha**: Now implements extensive cancellation rules based on sign lords, mutual friendship, Nakshatra Padas, and Rashi/Nakshatra combinations.
> - **Yoni Koota**: Replaced simple friend/enemy array pairs with the standard precision 14x14 Yoni points matrix to correctly return intermediate scores.
> - **Samvatsara (Varsha Bala)**: The 60-year cycle calculation inside `ShadbalaService` now correctly computes the elapsed Jovian Years since the Kali Yuga epoch using Mean Jupiter motion (Ahargana) rather than simply reading Jupiter's spatial position.
> - **Maasa Bala**: Month-lord mapping updated to align correctly with the Drik Siddhanta.
>
> **Accuracy Fixes (v2.3.0)**:
> - **Vashya Dual Signs (Issue 10)**: Sagittarius and Capricorn are now split at the 15┬░ boundary: Sagittarius 0┬░ΓÇô15┬░ = Chatushpada, 15┬░ΓÇô30┬░ = Manava; Capricorn 0┬░ΓÇô15┬░ = Chatushpada, 15┬░ΓÇô30┬░ = Jalachara. A `longitude` parameter is now passed to the internal `_getRashiVashya` method.
> - **Manglik Dosha Cancellations (Issue 11)**: Added 3 additional BPHS/Phaladeepika Parihara rules:
>   1. Mars in Leo or Aquarius
>   2. Mars aspected (whole-sign 7th) by Jupiter or Venus
>   3. Mars is the Lagna Lord (Aries or Scorpio Ascendant)

#### Service Accessors

| Method | Returns | Description |
|--------|---------|-------------|
| `panchangaService` | `PanchangaService` | Access advanced Panchanga methods |

#### Jaimini Astrology Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `getAtmakaraka(chart)` | `Planet` | Uses 7 or 8 karaka scheme |
| `getKarakamsa({rashiChart, navamsaChart})` | `KarakamsaInfo` | Soul planet in Navamsa |
| `getRashiDrishti(chart)` | `List<RashiDrishtiInfo>` | Sign-based aspects |
| `getActiveRashiDrishti(chart)` | `List<RashiDrishtiInfo>` | Aspects from occupied signs |
| `getArudhaPadas(chart)` | `Map<int, ArudhaPada>` | Arudha Padas for all houses |
| `getArudhaLagna(chart)` | `Rashi` | Arudha Lagna (AL) |
| `getUpapada(chart)` | `Rashi` | Upapada Lagna (UL) |
| `getAllArgalas(chart)` | `Map<int, List<ArgalaInfo>>` | Argalas for all houses |
| `getArgalaForHouse(chart, house)` | `List<ArgalaInfo>` | Argala for specific house |

#### Prashna (Horary) Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `calculatePrashnaArudha(seed)` | `Rashi` | Arudha based on seed (1-249) |
| `calculatePrashnaSphutas(chart)` | `Future<PrashnaSphutas>` | Trisphuta, Chatursphuta, etc. |
| `calculateGulikaSphuta(chart)` | `Future<double>` | Gulika position |

#### Compatibility Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `getPlanetaryRelationships({natalChart})` | `List<PlanetaryRelationship>` | Panchadha Maitri (flat list) |
| `getPlanetaryRelationshipsMatrix(chart)` | `Map<Planet, Map<Planet, PlanetaryRelationship>>` | 5-fold friendship matrix (O(1) lookup) |
| `getBhavaChalit(chart)` | `BhavaChalit` | Cuspal chart with mid-cusp boundaries |
| `getAyanamsa({dateTime, mode?, location?})` | `Future<double>` | Ayanamsa offset for a date/mode |

#### Cleanup

```dart
jyotish.dispose();
```

---

## New in v2.4.0

### Bhava Chalit (Cuspal Chart)

Bhava Chalit redistributes planets to houses based on **mid-cusp boundaries** (midpoint between
adjacent house cusps) rather than fixed 30┬░ sign edges. This distinction is most significant with
non-Whole-Sign house systems (Placidus, KochΓÇª) and is key for transit/dasha timing.

```dart
// Get the Rashi chart first
final rashiChart = await jyotish.calculateVedicChart(
  dateTime: birthDate,
  location: location,
  houseSystem: 'P', // Placidus ΓÇö most meaningful for Chalit
);

// Compute Bhava Chalit
final chalit = jyotish.getBhavaChalit(rashiChart);

// See which planets shifted
for (final s in chalit.shiftedPlanets) {
  print('${s.planet.displayName}: Rashi H${s.rashiHouse} ΓåÆ Chalit H${s.bhavaHouse}');
}

// Query a specific planet
final jupBhava = chalit.getBhavaForPlanet(Planet.jupiter);

// Query by longitude
final bhavaNum = chalit.getBhavaForLongitude(56.7);
```

**BhavaChalit properties:**

| Property | Type | Description |
|----------|------|-------------|
| `bhavas` | `List<BhavaInfo>` | 12 bhavas with mid-cusp boundaries |
| `chart` | `VedicChart` | Source Rashi chart |
| `shiftedPlanets` | `List<({planet, rashiHouse, bhavaHouse})>` | Planets that changed house |

**BhavaInfo properties:**

| Property | Type | Description |
|----------|------|-------------|
| `houseNumber` | `int` | 1ΓÇô12 |
| `midCuspStart` | `double` | Entry longitude (┬░) |
| `midCuspEnd` | `double` | Exit longitude (┬░) |
| `cusp` | `double` | Actual house cusp (┬░) |
| `planets` | `List<Planet>` | Planets in this bhava |

---

### Pancha-Vargeeya Maitri

The 5-fold friendship table combines Naisargika (natural) + Tatkalika (temporal) relationships
into the Panchadha Maitri compound result.

```dart
// Flat list ΓÇö one entry per ordered pair (7├ù6 = 42 items)
final rels = jyotish.getPlanetaryRelationships(natalChart: chart);
for (final r in rels) {
  print('${r.planet.displayName}ΓåÆ${r.otherPlanet.displayName}: ${r.compound.displayName}');
}

// Matrix ΓÇö nested map for O(1) pair lookups
final matrix = jyotish.getPlanetaryRelationshipsMatrix(chart);
final sunJupiter = matrix[Planet.sun]![Planet.jupiter]!;
print('Natural: ${sunJupiter.natural}')    // friend
print('Temporal: ${sunJupiter.temporary}') // depends on chart
print('Compound: ${sunJupiter.compound}')  // Panchadha result
```

**PlanetaryRelationship fields:**

| Field | Type | Description |
|-------|------|-------------|
| `natural` | `RelationshipType` | Naisargika Maitri |
| `temporary` | `RelationshipType` | Tatkalika Maitri (chart placement) |
| `compound` | `RelationshipType` | Panchadha Maitri (combined) |

**Panchadha Maitri combination rule:**

| Natural | Temporal | Compound |
|---------|----------|----------|
| Friend | Friend | `greatFriend` |
| Friend | Enemy | `neutral` |
| Neutral | Friend | `friend` |
| Neutral | Enemy | `enemy` |
| Enemy | Friend | `neutral` |
| Enemy | Enemy | `greatEnemy` |

---

### Ayanamsa Utility

```dart
// Get Lahiri ayanamsa for a date
final lah = await jyotish.getAyanamsa(dateTime: date);
print('Lahiri: ${lah.toStringAsFixed(4)}┬░');

// Compare with KP ayanamsa
final kp = await jyotish.getAyanamsa(
  dateTime: date,
  mode: SiderealMode.krishnamurtiVP291,
);
print('KP: ${kp.toStringAsFixed(4)}┬░');
print('Difference: ${(kp - lah).abs().toStringAsFixed(4)}┬░');
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `dateTime` | `DateTime` | required | Date for calculation |
| `mode` | `SiderealMode` | `lahiri` | Ayanamsa system |
| `location` | `GeographicLocation?` | null | Optional for timezone |

---

### Reference Chart Test Suite

A validated regression test suite is provided at `test/reference_charts_test.dart`.
The primary reference chart is **India Independence (15 Aug 1947, 00:00 IST, New Delhi)**.

Run with:
```bash
dart test test/reference_charts_test.dart
```

Requires Swiss Ephemeris data files in the `ephe/` directory (same as integration tests).

Tests cover:
- Planetary sign placements (all 7 planets + Rahu)
- House placements (Whole Sign, Taurus Ascendant)
- Planetary dignities
- Vimshottari dasha starting lord
- `getAyanamsa()` values and `CalculationFlags.kp()` mode
- `getBhavaChalit()` output for Whole Sign chart
- `getPlanetaryRelationshipsMatrix()` for known pairs


### GeographicLocation

Represents a geographic location on Earth.

#### Constructors

```dart
// Decimal degrees
GeographicLocation({
  required double latitude,    // -90 to 90 (North positive)
  required double longitude,   // -180 to 180 (East positive)
  double altitude = 0.0,       // Meters above sea level
  String? timezone,            // IANA timezone ID
});

// From DMS
GeographicLocation.fromDMS({
  required int latDegrees,
  required int latMinutes,
  required double latSeconds,
  required bool isNorth,
  required int lonDegrees,
  required int lonMinutes,
  required double lonSeconds,
  required bool isEast,
  double altitude = 0.0,
  String? timezone,
});

// From JSON
GeographicLocation.fromJson(Map<String, dynamic> json);
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `latitude` | `double` | Latitude (-90 to 90) |
| `longitude` | `double` | Longitude (-180 to 180) |
| `altitude` | `double` | Meters above sea level |
| `timezone` | `String?` | IANA timezone ID |
| `latitudeDMS` | `Map<String, dynamic>` | Latitude in DMS format |
| `longitudeDMS` | `Map<String, dynamic>` | Longitude in DMS format |

#### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `copyWith({...})` | `GeographicLocation` | Create modified copy |
| `toJson()` | `Map<String, dynamic>` | Convert to JSON |

---

### CalculationFlags

Controls calculation behavior for planetary positions.

#### Factory Constructors

```dart
// Default flags (Deprecated - use traditionalist/modernPrecision)
@Deprecated('Use traditionalist() or modernPrecision()')
CalculationFlags.defaultFlags();

// Traditional Vedic standard (Mean Node, Lahiri) — system: traditional
CalculationFlags.traditionalist();

// Modern precision standard (True Node, Lahiri) — system: traditional
CalculationFlags.modernPrecision();

// KP system (Krishnamurti VP291 ayanamsa) — system: kp
// Automatically selects Placidus ('P') house system in VedicChartService
CalculationFlags.kp();

// Sidereal with Lahiri ayanamsa — system: traditional
CalculationFlags.siderealLahiri();

// Custom sidereal mode — system: traditional
CalculationFlags.sidereal(SiderealMode mode);

// Topocentric calculations — system: traditional
CalculationFlags.topocentric();

// Specify node type (Mean vs True Node) — system: traditional
CalculationFlags.withNodeType(NodeType nodeType);
```

> **v2.4.0**: `CalculationFlags.kp()` added — uses `SiderealMode.krishnamurtiVP291` (the
> correct KP New Ayanamsa). Distinct from `SiderealMode.krishnamurti` (old Krishnamurti).
> Always use `kp()` for Krishnamurti Paddhati charts.
>
> **v2.5.0**: All factory constructors now carry an explicit `AstrologicalSystem` tag.
> `CalculationFlags.kp()` sets `system: AstrologicalSystem.kp`; all others set
> `system: AstrologicalSystem.traditional`. Use `.isKP` / `.isTraditional` getters to
> branch logic at runtime. See [New in v2.5.0](#new-in-v250--astrologicalsystem).

#### Main Constructor

```dart
CalculationFlags({
  AstrologicalSystem system = AstrologicalSystem.traditional, // NEW v2.5.0
  SiderealMode? siderealMode,
  bool useTopocentric = false,
  bool calculateSpeed = true,
  NodeType nodeType = NodeType.meanNode,
});
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `system` | `AstrologicalSystem` | **NEW v2.5.0** — Paradigm: `traditional` or `kp` |
| `isKP` | `bool` | **NEW v2.5.0** — `true` when `system == kp` |
| `isTraditional` | `bool` | **NEW v2.5.0** — `true` when `system == traditional` |
| `siderealMode` | `SiderealMode` | Ayanamsa mode |
| `useTopocentric` | `bool` | Use topocentric calculations |
| `calculateSpeed` | `bool` | Calculate planetary speed |
| `nodeType` | `NodeType` | Mean or True Node |

---

## Services

Services provide low-level access to specific calculation domains. For most use cases, use the `Jyotish` class which wraps these services.

### EphemerisService

Core planetary position calculations using Swiss Ephemeris.

```dart
final service = EphemerisService();
await service.initialize();
```

| Method | Returns | Description |
|--------|---------|-------------|
| `calculatePlanetPosition({planet, dateTime, location, flags})` | `Future<PlanetPosition>` | Calculate planet position |
| `getAyanamsa({dateTime, mode, timezoneId?})` | `Future<double>` | Get ayanamsa value |
| `calculateHouses({dateTime, location, houseSystem?})` | `Future<HouseSystem>` | Calculate house cusps |
| `getRiseSet({planet, date, location, rsmi, atpress?, attemp?, searchFromExactTime?})` | `Future<DateTime?>` | Rise/set time. `searchFromExactTime` (default false) allows finding the correct moonset after a specific moonrise time. |
| `getSunriseSunset({date, location, atpress?, attemp?})` | `Future<(DateTime?, DateTime?)>` | Sunrise and sunset |
| `getPlanetRiseSet({planet, date, location})` | `Future<(DateTime?, DateTime?)>` | Rise/set for any planet |
| `getMeridianTransit({planet, date, location, upperCulmination})` | `Future<DateTime?>` | Upper/lower culmination |
| `getPlanetVisibility({planet, date, location})` | `Future<PlanetVisibility>` | Heliacal rise/set |
| `getEclipseData({date, location, eclipseType})` | `Future<EclipseData?>` | Solar/lunar eclipse info |
| `getJulianDay(dateTime, {timezoneId?})` | `double` | DateTime to Julian Day |
| `dispose()` | `void` | Release resources |

---

### VedicChartService

Calculates complete Vedic astrology charts.

```dart
final service = VedicChartService(ephemerisService);
```

| Method | Returns | Description |
|--------|---------|-------------|
| `calculateChart({dateTime, location, houseSystem?, includeOuterPlanets?, flags?})` | `Future<VedicChart>` | Complete Vedic chart |

**Planetary Dignity Priority (BPHS order)**

| Priority | Dignity | Rule |
|----------|---------|------|
| 1 | `exalted` | Planet in its exaltation sign |
| 2 | `debilitated` | Planet in its debilitation sign |
| 3 | `moolaTrikona` | Planet within BPHS MT degree range in MT sign |
| 4 | `ownSign` | Planet in its own sign (outside MT range) |
| 5 | `friendSign` / `enemySign` / `neutralSign` | Sign-lord friendship |

**Moola Trikona Degree Ranges (BPHS)**

| Planet | Sign | MT Range |
|--------|------|----------|
| Sun | Leo | 0┬░ΓÇô20┬░ |
| Moon | Taurus | 4┬░ΓÇô20┬░ |
| Mars | Aries | 0┬░ΓÇô12┬░ |
| Mercury | Virgo | 16┬░ΓÇô20┬░ |
| Jupiter | Sagittarius | 0┬░ΓÇô10┬░ |
| Venus | Libra | 0┬░ΓÇô15┬░ |
| Saturn | Aquarius | 0┬░ΓÇô20┬░ |

**Debilitation Degree Corrections (v2.3.0)**

| Planet | Old value | Correct value |
|--------|-----------|---------------|
| Venus | 165.0┬░ (15┬░ Virgo) | 177.0┬░ (27┬░ Virgo) |

**Rahu/Ketu Dignity (v2.3.0)**
- Both `Planet.meanNode` and `Planet.trueNode` are supported for exaltation and debilitation
- **Rahu**: Exalted in Gemini, Debilitated in Sagittarius
- **Ketu**: Exalted in Sagittarius, Debilitated in Gemini (opposite Rahu)

**Planetary Relationships (v2.2.0)**
- MoonΓåÆVenus: corrected to **neutral** (0) per BPHS (was incorrectly set to enemy)
- Rahu/Ketu: full natural relationship sets added for Panchadha Maitri support.

---

### DashaService

Vedic dasha period calculations.

```dart
final service = DashaService();
```

| Method | Returns | Description |
|--------|---------|-------------|
| `calculateVimshottariDasha({moonLongitude, birthDateTime, levels?, birthTimeUncertainty?})` | `DashaResult` | Vimshottari (120-year) dasha |
| `calculateYoginiDasha({moonLongitude, birthDateTime, levels?, birthTimeUncertainty?})` | `DashaResult` | Yogini (36-year) dasha ΓÇö durations computed in **milliseconds** for precision |
| `calculateCharaDasha(rashiChart, {levels?})` | `CharaDashaResult` | Chara (Jaimini) dasha |
| `getNarayanaDasha(rashiChart, {levels?})` | `NarayanaDashaResult` | Jaimini sign-based dasha ΓÇö uses reverse count for even signs |
| `getAshtottariDasha(chart, {scheme?, forceCalculation?, levels?})` | `DashaResult` | 108-year cycle dasha ΓÇö supports nested Antardashas |
| `getKalachakraDasha(chart)` | `KalachakraDashaResult` | Nakshatra-based dasha ΓÇö `balanceOfFirstDasha` computed from Moon's actual pada position |

> **Accuracy Fixes (v2.3.0)**:
> - **Yogini Dasha (Issue 8)**: Antardasha and Pratyantardasha durations now accumulated in milliseconds to eliminate day-rounding drift across sub-period chains.
> - **Kalachakra Dasha (Issue 12)**: `DashaResult.balanceOfFirstDasha` is now the actual remaining days calculated from the Moon's proportional position within its pada (was hardcoded to 0).
> - **Narayana Dasha (Issue 13)**: The 12-sign sequence now follows consecutive zodiacal order (forward for odd starting signs, reverse for even) per the Jaimini rule, replacing the incorrect `i ├ù 6` modulo formula.

---

## New in v2.3.0

### Professional Features Suite

The "Professional Features" suite adds high-level analysis engines that aggregate core library data into predictive and strength-based reports.

### Graha Avastha & Strength Reports

Strength analysis now considers the **Avastha** (state) of the planet:
- **Baladi Avastha**: 5 states (Bala, Kumara, Yuva, Vriddha, Mrita) based on longitude parity in signs.
- **Jagratadi Avastha**: 3 states (Jagrat, Swapna, Sushupti) based on dignity.

The `StrengthReport` aggregates Shadbala, Vimshopaka, Dignity, and Avastha into a single score.

### Event Timing Engine

The `EventTimingService` searches for optimal windows by scoring:
1. **Dasha Favorability**: Active Dasha/Antardasha lords.
2. **Transit Support**: Transit positions of Dasha lords.
3. **Gochara Vedha**: Obstructions from other transiting planets.
4. **House Activation**: Transits through houses relevant to the event category (e.g., 2nd/7th for Marriage).

### Sarvatobhadra Chakra

A comprehensive transit analysis grid. It maps the 27 Nakshatras onto a square lattice and identifies **Vedha** (aspects) cast by transiting planets onto natal points (Moon, Ascendant, Sun).

### Tajaka Enhancements

Expands the annual `Varshapal` chart with:
- **Muntha**: The progressed Ascendant sign for the year.
- **Sahams**: Arabic Parts (Punya, Vidya, etc.) calculated from Sun/Moon/Ascendant.
- **Tajaka Yogas**: Specific annual aspects like *Itthasala* (applying) and *Ishrafa* (separating).


---

### VarshapalService

Varshapal (Annual Chart) calculations. The annual chart is calculated from the birthday each year.

```dart
final service = VarshapalService(ephemerisService);
```

| Method | Returns | Description |
|--------|---------|-------------|
| `calculateVarshapal({birthDateTime, varshaDateTime, location, houseSystem?, checkDate?})` | `Future<Varshapal>` | Annual chart for a specific year |
| `calculateCurrentVarshapal({birthDateTime, location, houseSystem?, checkDate?})` | `Future<Varshapal>` | Current year's annual chart |

---

### PanchangaService

Panchanga (five limbs) calculations.

```dart
final service = PanchangaService(ephemerisService);
```

| Method | Returns | Description |
|--------|---------|-------------|
| `calculatePanchanga({dateTime, location})` | `Future<Panchanga>` | Complete Panchanga |
| `getTithi({dateTime, location})` | `Future<TithiInfo>` | Tithi (lunar day) |
| `getYoga({dateTime, location})` | `Future<YogaInfo>` | Yoga (Sun+Moon combination) |
| `getKarana({dateTime, location})` | `Future<KaranaInfo>` | Karana (half-Tithi) |
| `getVara({dateTime, location})` | `Future<VaraInfo>` | Vara (weekday lord) |
| `getNakshatra({dateTime, location})` | `Future<NakshatraInfo>` | Moon's nakshatra |
| `getTithiEndTime({dateTime, location, accuracyThreshold?})` | `Future<DateTime>` | Precise Tithi end |
| `calculateAbhijitMuhurta({date, location})` | `Future<AbhijitMuhurta>` | 8th Muhurta (1/15th of daytime) |
| `calculateBrahmaMuhurta({date, location})` | `Future<BrahmaMuhurta>` | 14th Muhurta of night (uses previous sunset ΓåÆ today sunrise) |
| `calculateNighttimeInauspicious({date, location})` | `Future<NighttimeInauspiciousPeriods>` | Night Rahu/Gulika/Yamagandam |
| `getTithiJunction({targetTithiNumber, startDate, location})` | `Future<DateTime>` | Microsecond-precision Tithi change |
| `getMoonPhaseDetails({dateTime, location})` | `Future<MoonPhaseDetails>` | Comprehensive lunar data |

> **API Change (v2.1.0)**: `TithiInfo.tithiNames` has been replaced.
> Use `TithiInfo.nameFromNumber(int tithiNumber)` to get the correct name for
> any Tithi (1ΓÇô30). This correctly returns **"Purnima"** for Shukla Tithi 15
> and **"Amavasya"** for Krishna Tithi 15. Direct access via `shuklaTithiNames`
> and `krishnaTithiNames` lists is also available.
>
> **API Change (v2.1.0)**: `MoonPhaseDetails.illumination` now uses the correct
> cosine formula. New Moon (elongation=0┬░) = **0%**, Full Moon (180┬░) = **100%**.
> The old formula was inverted.



---

### AshtakavargaService

Ashtakavarga (eightfold division) calculations.

```dart
final service = AshtakavargaService();
```

| Method | Returns | Description |
|--------|---------|-------------|
| `calculateAshtakavarga(natalChart)` | `Ashtakavarga` | Complete Ashtakavarga |
| `analyzeTransit({ashtakavarga, transitPlanet, transitSign, transitDate?})` | `TransitAnalysis` | Transit strength |
| `getFavorableTransitSigns(ashtakavarga, planet)` | `List<int>` | Favorable signs (>28 bindus) |
| `getBinduDetailsForSign(ashtakavarga, signIndex)` | `Map<Planet, int>` | Bindus per planet |
| `applyTrikonaShodhana(ashtakavarga)` | `Ashtakavarga` | Apply trine reduction |
| `applyEkadhipatiShodhana(ashtakavarga)` | `Ashtakavarga` | Apply lordship reduction |
| `calculatePinda(ashtakavarga)` | `Map<Planet, double>` | Planetary strength |
| `calculateYogaPinda(ashtakavarga)` | `Map<Planet, double>` | Auspicious strength |
| `calculateShodhyaPinda(ashtakavarga)` | `ShodhyaPindaResult` | Reduced strength |
| `calculateHousePinda(ashtakavarga, houseNumber)` | `double` | House strength |
| `calculateAllHousesPinda(ashtakavarga)` | `Map<int, double>` | All house strengths |

---

### AspectService

Vedic planetary aspects (Graha Drishti).

```dart
final service = AspectService();
```

| Method | Returns | Description |
|--------|---------|-------------|
| `calculateAspects(positions, {config?})` | `List<AspectInfo>` | All aspects (whole-sign by default) |
| `getAspectsForPlanet(planet, positions, {config?})` | `List<AspectInfo>` | Aspects involving planet |
| `getAspectsCastBy(planet, positions, {config?})` | `List<AspectInfo>` | Aspects cast by planet |
| `getAspectsReceivedBy(planet, positions, {config?})` | `List<AspectInfo>` | Aspects received by planet |
| `getPlanetsAspectingSign(houseSignIndex, positions, {useWholeSign?})` | `List<Planet>` | Planets aspecting sign (whole-sign default) |
| `getRashiAspects(chart, {activeOnly?})` | `List<RashiDrishtiInfo>` | Jaimini sign-based aspects (Movable/Fixed/Dual rules) |

**AspectConfig**

| Preset | `useWholeSignAspects` | Description |
|--------|-----------------------|-------------|
| `AspectConfig.vedic` *(default)* | `true` | Sign-to-sign Parashari aspects ΓÇö planets aspect the entire sign, strength = 1.0 |
| `AspectConfig.western` | `false` | Degree + orb system for Western / KP use |

```dart
// Vedic (whole-sign) ΓÇö default
final aspects = service.calculateAspects(positions);

// Western/KP (degree-based)
final aspects = service.calculateAspects(
  positions,
  config: AspectConfig.western,
);

// Custom: whole-sign with special aspects disabled
final config = AspectConfig(
  useWholeSignAspects: true,
  includeSpecialAspects: false,
);
```

**Vedic Special Aspects (whole-sign)**

| Planet | Houses Aspected |
|--------|----------------|
| All planets | 7th (opposition) |
| Mars | 4th, 7th, 8th |
| Jupiter | 5th, 7th, 9th |
| Saturn | 3rd, 7th, 10th |

> **Accuracy Fix (v2.3.0)**: Aspects are now calculated sign-to-sign (Parashari whole-sign model) rather than degree+orb. A planet in sign X aspects every planet in the target sign regardless of exact degree separation. Strength is always `1.0`. Use `AspectConfig.western` to retain degree-based orb calculations for KP or Western use.

---

### TransitService

Transit position calculations.

```dart
final service = TransitService(ephemerisService);
```

| Method | Returns | Description |
|--------|---------|-------------|
| `calculateTransits({natalChart, transitDateTime, location})` | `Future<Map<Planet, TransitInfo>>` | Transit positions |
| `findTransitEvents({natalChart, config, location})` | `Future<List<TransitEvent>>` | Transit events |

---

### SpecialTransitService

Special transit features (Sade Sati, Dhaiya, Panchak).

```dart
final service = SpecialTransitService(ephemerisService);
```

| Method | Returns | Description |
|--------|---------|-------------|
| `calculateSpecialTransits({natalChart, checkDate?, location})` | `Future<SpecialTransits>` | All special transits |
| `predictSadeSatiPeriods(natalChart, {yearsBefore?, yearsAfter?})` | `Future<List<SadeSatiPeriod>>` | Past/future Sade Sati |

---

### DivisionalChartService

Divisional charts (Varga) calculations.

```dart
final service = DivisionalChartService();
```

| Method | Returns | Description |
|--------|---------|-------------|
| `calculateDivisionalChart(rashiChart, type)` | `VedicChart` | Any divisional chart |

**Supported Chart Types**: D1 (Rashi), D2 (Hora), D3 (Drekkana), D4 (Chaturthamsa), D5 (Panchamsa), D6 (Shashthamsa), D7 (Saptamsa), D8 (Ashtamsa), D9 (Navamsa), D10 (Dasamsa), D11 (Rudramsa), D12 (Dwadasamsa), D16 (Shodasamsa), D20 (Vimsamsa), D24 (Chaturvimshamsa), D27 (Saptavimshamsa), D30 (Trimsamsa), D40 (Khavedamsa), D45 (Akshavedamsa), D60 (Shashtiamsa), D150 (Nadi Amsa), D249 (KP micro-divisions)

---

### ShadbalaService

Six-fold planetary strength calculations.

```dart
final service = ShadbalaService(ephemerisService);
```

| Method | Returns | Description |
|--------|---------|-------------|
| `calculateShadbala(chart)` | `Map<Planet, ShadbalaResult>` | Complete Shadbala |
| `getUchchaBalaOnly(planet, longitude)` | `double` | Uchcha Bala (exaltation strength) for a planet |
| `calculateHoraLordsForDay({date, location})` | `Future<List<Planet>>` | 24 Hora lords |
| `checkCombustion({planet, planetLongitude, sunLongitude, planetSpeed?})` | `CombustionInfo` | Detailed combustion status. Refined orbs (v2.2.0) + retrograde logic |

**Shadbala Components**:
1. **Sthana Bala** - Positional strength (Uchcha, Saptavargaja, Ojayugma, Drekkana, Kendra)
2. **Dig Bala** - Directional strength
3. **Kala Bala** - Temporal strength (Natonnata, Paksha, Tribhaga, VMDH, Ayana)
4. **Chesta Bala** - Motional strength (Vakra retrograde, Vikala stationary)
5. **Naisargika Bala** - Natural strength
6. **Drik Bala** - Aspectual strength (linear interpolation, partial aspects)

> **Accuracy Fix (v2.3.0) ΓÇö Paksha Bala (Issue 9)**:
> Paksha Bala now correctly peaks for **benefics** (Jupiter, Venus) at Full Moon (elongation = 180┬░) and for **malefics** (Sun, Mars, Saturn) at New Moon (elongation = 0┬░), per BPHS. The previous formula was using a simple linear elongation ratio which gave malefics maximum strength at Full Moon ΓÇö the opposite of classical texts. Moon's own Paksha Bala still peaks at Full Moon irrespective of paksha type.

---

### KPService

Krishnamurti Paddhati (KP) system calculations.

> **v2.5.0 — System Guard-Rail**: `calculateKPData()` and `calculateRulingPlanets()` now
> assert that the supplied chart was created with `CalculationFlags.kp()`. A descriptive
> `StateError` is thrown if a traditional-system chart is passed by mistake. This prevents
> the silent bug of KP Sub-Lord tables being calculated against Lahiri ayanamsa.
> See [New in v2.5.0](#new-in-v250--astrologicalsystem) for the migration guide.

```dart
final service = KPService(ephemerisService);
```

| Method | Returns | Description |
|--------|---------|-------------|
| `calculateKPData(natalChart, {useNewAyanamsa?})` | `Future<KPCalculations>` | Complete KP data with cusp-based ABCD significators. **Requires KP flags (v2.5.0).** |
| `getSubLord(longitude)` | `Planet` | Sub-Lord for longitude |
| `getSubSubLord(longitude)` | `Planet` | Sub-Sub-Lord |
| `getHouseGroupSignificators(significators)` | `KPHouseGroupSignificators` | House group significators |
| `calculateTransitKPDivisions(transitPositions)` | `Map<Planet, KPDivision>` | Transit KP divisions |
| `compareTransitToNatal({natalKP, transitDivisions})` | `List<KPTransitComparison>` | Sync transit Sub-Lords against natal; sorted by match strength |
| `calculateRulingPlanets(chart, {useNewAyanamsa?})` | `Future<KPRulingPlanets>` | Seven KP Ruling Planets (Day, Asc Sign/Star/Sub, Moon Sign/Star/Sub). **Requires KP flags (v2.5.0).** |

**ABCD Significator Grades**:
- **A**: Houses *occupied* by the planet's Sign Lord  
- **B**: Houses *occupied* by the planet's Star Lord  
- **C**: Houses *owned* by the planet (based on actual chart cusps ΓÇö v2.2.0 fix)  
- **D**: Houses *owned* by the planet's Sign Lord (based on actual chart cusps ΓÇö v2.2.0 fix)  

**Transit Comparison** (`compareTransitToNatal`):
- Checks Star-Lord match, Sub-Lord match, and common house significators
- Returns list sorted by `matchStrength` (0ΓÇô3)
- `isActive` is true when any of the three triggers fire

**Ruling Planets** (`calculateRulingPlanets` / `getKPRulingPlanets`):
- Computes Sign, Star, and Sub lords of the Ascendant and Moon
- Adds the weekday Day Lord
- Deduplicates by priority order; returns `KPRulingPlanets.rulingPlanets`

---

### MuhurtaService

Muhurta (auspicious timing) calculations.

```dart
final service = MuhurtaService();
```

| Method | Returns | Description |
|--------|---------|-------------|
| `calculateMuhurta({date, sunrise, sunset, location})` | `Muhurta` | Complete Muhurta |
| `getHoraPeriods({date, sunrise, sunset})` | `List<HoraPeriod>` | Planetary hours (24) |
| `getChoghadiya({date, sunrise, sunset})` | `List<ChoghadiyaPeriod>` | Choghadiya periods (16) |
| `getInauspiciousPeriods({date, sunrise, sunset})` | `InauspiciousPeriods` | Rahukalam/Gulikalam/Yamagandam |
| `findBestMuhurta({muhurta, activity})` | `List<TimePeriod>` | Best times for activity |
| `getHoraLordForHour(dateTime, sunrise)` | `Planet` | Hora lord at time |

---

### MasaService

Lunar month (Masa) and calendar calculations.

```dart
final service = MasaService(ephemerisService);
```

| Method | Returns | Description |
|--------|---------|-------------|
| `calculateMasa({dateTime, location, type?})` | `Future<MasaInfo>` | Lunar month info |
| `getSamvatsara({dateTime, location})` | `Future<String>` | 60-year cycle name |
| `getNakshatraWithAbhijit({dateTime, location})` | `Future<NakshatraInfo>` | With 28th nakshatra |
| `calculateNakshatraFromLongitude(longitude)` | `NakshatraInfo` | Nakshatra from longitude |
| `getMasaListForYear({year, location, type?})` | `Future<List<MasaInfo>>` | All months in year |
| `getRitu(masaInfo)` | `Ritu` | Hindu season |
| `getRituDetails({dateTime, location})` | `Future<RituDetails>` | Season details |

---

### SudarshanChakraService

Service for calculating Sudarshan Chakra strength from Lagna, Moon, and Sun perspectives.

```dart
final service = SudarshanChakraService();
```

| Method | Returns | Description |
|--------|---------|-------------|
| `calculateSudarshanChakra(chart)` | `SudarshanChakraResult` | Calculate triple-perspective strength |

---

### StrengthAnalysisService

Advanced planetary strength and house analysis.

```dart
final service = StrengthAnalysisService();
```

| Method | Returns | Description |
|--------|---------|-------------|
| `getIshtaphala({planet, chart, shadbalaStrength})` | `double` | Ishtaphala (auspicious fruit) |
| `getKashtaphala({planet, chart, shadbalaStrength})` | `double` | Kashtaphala (inauspicious fruit) |
| `getBhavaBala({chart, shadbalaResults})` | `Map<int, double>` | Strength for all 12 houses |
| `getVimshopakBala({chart, planet})` | `VimshopakBala` | 20-fold strength for planet |
| `getAllPlanetsVimshopakBala(chart)` | `Map<Planet, VimshopakBala>` | Vimshopak Bala for all planets |

---

### HoraService

Planetary hour (Hora) calculations. Each day is divided into 24 Horas (12 daytime, 12 nighttime), each ruled by a planet in Chaldean order.

```dart
final service = HoraService(ephemerisService);
```

| Method | Returns | Description |
|--------|---------|-------------|
| `getCurrentHora({dateTime, location})` | `Future<HoraPeriod>` | Current planetary hour |
| `getHorasForDay({date, location})` | `Future<List<HoraPeriod>>` | All 24 horas for a day |

**Chaldean Order**: Saturn -> Jupiter -> Mars -> Sun -> Venus -> Mercury -> Moon

---

### ChoghadiyaService

Choghadiya periods - 8 auspicious/inauspicious periods during day and night.

```dart
final service = ChoghadiyaService(ephemerisService);
```

| Method | Returns | Description |
|--------|---------|-------------|
| `getCurrentChoghadiya({dateTime, location})` | `Future<Choghadiya>` | Current Choghadiya period |

**Choghadiya Types**: Amrit (Nectar), Shubh (Auspicious), Labh (Gain), Char (Moving), Udveg (Anxiety), Kaal (Death), Rog (Disease)

---

### GowriPanchangamService

Traditional South Indian electional system dividing day and night into 8 parts each.

```dart
final service = GowriPanchangamService(ephemerisService);
```

| Method | Returns | Description |
|--------|---------|-------------|
| `getCurrentGowriPanchangam({dateTime, location})` | `Future<GowriPanchangamInfo>` | Current Gowri period |

**Gowri Types**: Uthi, Amrit, Rogam, Labhamu, Dhana, Soolai, Visham, Nirkku

---

### BhavaBalaService

House strength (Bhava Bala) calculations.

```dart
final service = BhavaBalaService(shadbalaService);
```

| Method | Returns | Description |
|--------|---------|-------------|
| `calculateBhavaBala(chart)` | `Future<Map<int, BhavaBalaResult>>` | Strength for all 12 houses |

---

### JaiminiService

Jaimini astrology calculations including Atmakaraka, Karakamsa, and Rashi Drishti.

```dart
final service = JaiminiService();
```

| Method | Returns | Description |
|--------|---------|-------------|
| `getAtmakaraka(chart)` | `Planet` | Planet with highest degree (7 or 8 karaka) |
| `getKarakamsa({rashiChart, navamsaChart})` | `KarakamsaInfo` | Soul planet in Navamsa |
| `calculateRashiDrishti(chart)` | `List<RashiDrishtiInfo>` | Sign-based aspects |
| `calculateActiveRashiDrishti(chart)` | `List<RashiDrishtiInfo>` | Aspects from occupied signs |

---

### ArudhaPadaService

Arudha Lagna and Upapada calculations.

```dart
final service = ArudhaPadaService();
```

| Method | Returns | Description |
|--------|---------|-------------|
| `calculateArudhaPadas(chart)` | `ArudhaPadaResult` | Arudha Padas for all houses |
| `calculateArudhaLagna(chart)` | `ArudhaPadaInfo` | Arudha Lagna (AL) |
| `calculateUpapada(chart)` | `ArudhaPadaInfo` | Upapada Lagna (UL) |

---

### ArgalaService

Argalas (planetary strengths/interruptions) for houses.

```dart
final service = ArgalaService();
```

| Method | Returns | Description |
|--------|---------|-------------|
| `calculateAllArargalas(chart)` | `Map<int, List<ArgalaInfo>>` | Argalas for all houses |
| `calculateArgalaForHouse(chart, house)` | `List<ArgalaInfo>` | Argalas for specific house |

---

### PrashnaService

Horary astrology (Prashna) calculations.

```dart
final service = PrashnaService(ephemerisService);
```

| Method | Returns | Description |
|--------|---------|-------------|
| `calculatePrashnaArudha(seed)` | `Rashi` | Arudha based on seed (1-249) |
| `calculateSphutas(chart)` | `Future<PrashnaSphutas>` | Trisphuta, Chatursphuta |
| `calculateGulikaSphuta(chart)` | `Future<double>` | Gulika longitude |

---

### GocharaVedhaService

Transit obstruction (Vedha) analysis.

```dart
final service = GocharaVedhaService();
```

| Method | Returns | Description |
|--------|---------|-------------|
| `calculateVedha({transitPlanet, houseFromMoon, moonNakshatra, otherTransits})` | `VedhaResult` | Check Vedha for single transit |
| `calculateMultipleVedha({transits, moonNakshatra})` | `List<VedhaResult>` | Check Vedha for multiple transits |
| `findFavorablePeriodsWithoutVedha(transitSnapshots)` | `List<TimePeriod>` | Find periods free from obstruction |
| `getVedhaRemedies(vedhaResult)` | `List<String>` | Remedies for obstruction |

---

### HouseStrengthService

Enhanced house strength calculations with Vimsopaka Bala integration.

```dart
final service = HouseStrengthService(shadbalaService);
```

| Method | Returns | Description |
|--------|---------|-------------|
| `calculateEnhancedBhavaBala(chart)` | `Future<Map<int, EnhancedBhavaBalaResult>>` | Enhanced house strength |
| `calculateVimsopakaBala(chart)` | `Map<Planet, VimsopakaBalaResult>` | Divisional chart strength |
| `getHouseStrengthSummary(results)` | `HouseStrengthSummary` | Summary of all houses |

**Vimsopaka Categories**: Atipoorna (18-20), Poorna (16-18), Atimadhya (14-16), Madhya (12-14), Adhama (10-12), Durga (8-10), Sangat Durga (5-8)

---

### NadiService

Nadi astrology identification system.

```dart
final service = NadiService();
```

| Method | Returns | Description |
|--------|---------|-------------|
| `calculateNadiChart(chart)` | `NadiChart` | Complete Nadi positions |
| `getNadiFromLongitude(longitude)` | `NadiInfo` | Nadi for a longitude |
| `getNadiInterpretation(nadiNumber)` | `String` | Nadi prediction text |
| `identifyNadiSeed(nakshatra, pada)` | `NadiSeedResult` | Primary Nadi seed |

**Nadi Types**: Agasthiya, Bhrigu, Saptarshi, Nandi, Bharga, Chandra

---

### ProgenyService

Child prediction and progeny analysis.

```dart
final service = ProgenyService();
```

| Method | Returns | Description |
|--------|---------|-------------|
| `analyzeProgeny(chart)` | `ProgenyResult` | Complete progeny analysis |
| `analyzeFifthHouse(chart)` | `FifthHouseStrength` | 5th house strength |
| `analyzeJupiterCondition(chart)` | `JupiterCondition` | Jupiter as child karaka |
| `analyzeD7Chart(chart)` | `D7Analysis` | Saptamsa analysis |
| `detectChildYogas(chart)` | `List<ChildYoga>` | Favorable combinations |

---

### CompatibilityService

Marriage compatibility (Kundli Milan) calculations.

```dart
final service = CompatibilityService();
```

| Method | Returns | Description |
|--------|---------|-------------|
| `calculateCompatibility(boyChart, girlChart)` | `CompatibilityResult` | Full compatibility analysis |
| `calculateGunaMilan(boyChart, girlChart)` | `GunaScores` | Ashtakoota scores |
| `checkManglikDosha(chart)` | `ManglikDoshaResult` | Mars placement analysis |
| `checkNadiDosha(boyChart, girlChart)` | `NadiDoshaResult` | Nadi compatibility |
| `checkBhakootDosha(boyChart, girlChart)` | `BhakootDoshaResult` | Moon sign compatibility |
| `calculateDashaCompatibility(boyChart, girlChart)` | `DashaCompatibility` | Dasha period matching |

**Ashtakoota (36 Guna) Points**:
- Varna (1), Vashya (2), Tara (3), Yoni (4)
- GrahaMaitri (5), Gana (6), Bhakoot (7), Nadi (8)


---

## Models

### VedicChart

Complete Vedic astrology chart data.

| Property | Type | Description |
|----------|------|-------------|
| `dateTime` | `DateTime` | Chart date/time |
| `location` | `GeographicLocation` | Chart location |
| `ayanamsa` | `double` | Ayanamsa value used |
| `ascendant` | `double` | Ascendant longitude |
| `ascendantSign` | `String` | Ascendant zodiac sign |
| `planets` | `Map<Planet, VedicPlanetInfo>` | All planetary data |
| `houses` | `HouseSystem` | House cusps |
| `rahu` | `VedicPlanetInfo` | Rahu position |
| `ketu` | `KetuPosition` | Ketu position |
| `calculationFlags` | `CalculationFlags?` | Stored flags (nullable, legacy) |
| `flags` | `CalculationFlags` | **NEW v2.5.0** — Non-nullable; defaults to `traditionalist()` for old charts |

| Method | Returns | Description |
|--------|---------|-------------|
| `getPlanet(planet)` | `VedicPlanetInfo?` | Get planet info |
| `getPlanetsInHouse(houseNumber)` | `List<VedicPlanetInfo>` | Planets in house |

---

### PlanetPosition

Calculated position of a celestial body.

| Property | Type | Description |
|----------|------|-------------|
| `planet` | `Planet` | The planet |
| `longitude` | `double` | Ecliptic longitude (0-360┬░) |
| `latitude` | `double` | Ecliptic latitude |
| `distance` | `double` | Distance from Earth (AU) |
| `longitudeSpeed` | `double` | Speed (degrees/day) |
| `zodiacSign` | `String` | Zodiac sign name |
| `signIndex` | `int` | Sign index (0-11) |
| `positionInSign` | `double` | Degrees in sign (0-30) |
| `nakshatra` | `String` | Nakshatra name |
| `nakshatraIndex` | `int` | Nakshatra index (0-26) |
| `nakshatraPada` | `int` | Pada (1-4) |
| `isRetrograde` | `bool` | Retrograde motion |
| `isCombust` | `bool` | Combustion status |
| `formattedPosition` | `String` | Human-readable position |

---

### VedicPlanetInfo

Extended Vedic planetary information.

| Property | Type | Description |
|----------|------|-------------|
| `planet` | `Planet` | The planet |
| `position` | `PlanetPosition` | Calculated position |
| `house` | `int` | House number (1-12) |
| `zodiacSign` | `String` | Zodiac sign name |
| `nakshatra` | `String` | Nakshatra name |
| `pada` | `int` | Nakshatra pada (1-4) |
| `dignity` | `PlanetaryDignity` | Dignity status |
| `isRetrograde` | `bool` | Retrograde status |
| `isCombust` | `bool` | Combustion status |

---

### Panchanga

Complete Panchanga (five limbs) data.

| Property | Type | Description |
|----------|------|-------------|
| `dateTime` | `DateTime` | Calculation time |
| `tithi` | `TithiInfo` | Lunar day |
| `nakshatra` | `NakshatraInfo` | Moon's nakshatra |
| `yoga` | `YogaInfo` | Sun-Moon combination |
| `karana` | `KaranaInfo` | Half-Tithi |
| `vara` | `VaraInfo` | Weekday/lord |
| `sunrise` | `DateTime` | Sunrise time |
| `sunset` | `DateTime` | Sunset time |

---

### DashaResult

Dasha calculation result.

| Property | Type | Description |
|----------|------|-------------|
| `system` | `DashaSystem` | Dasha system used |
| `birthDateTime` | `DateTime` | Birth date/time |
| `moonLongitude` | `double` | Moon longitude at birth |
| `startingNakshatra` | `String` | Birth nakshatra |
| `startingLord` | `Planet` | Starting dasha lord |
| `balanceAtBirth` | `double` | Balance of first dasha (days) |
| `mahadashas` | `List<MahadashaPeriod>` | All mahadasha periods |

| Method | Returns | Description |
|--------|---------|-------------|
| `getActivePeriodsAt(date)` | `List<DashaPeriod>` | Active periods at date |

---

### Varshapal

Annual chart data with periods.

| Property | Type | Description |
|----------|------|-------------|
| `chart` | `VedicChart` | The annual chart |
| `birthDateTime` | `DateTime` | Original birth date/time |
| `varshaDateTime` | `DateTime` | Annual chart date (birthday) |
| `varshaLord` | `Planet` | Ruling planet of the year |
| `varshaNumber` | `int` | Year number in 60-year cycle (1-60) |
| `samvatsaraName` | `String` | Traditional Samvatsara name |
| `allVarshaPeriods` | `List<VarshapalPeriod>` | All year periods |
| `allMaasaPeriods` | `List<VarshapalPeriod>` | All month periods |
| `allDinaPeriods` | `List<VarshapalPeriod>` | All day periods |
| `allHoraPeriods` | `List<VarshapalPeriod>` | All hour periods |

| Method | Returns | Description |
|--------|---------|-------------|
| `getCurrentPeriods(date)` | `VarshapalCurrentPeriods` | Current periods at date |
| `getCurrentPeriodString(date)` | `String` | Formatted period string |

---

### VarshapalPeriod

A period within the Varshapal system.

| Property | Type | Description |
|----------|------|-------------|
| `type` | `VarshapalPeriodType` | Period type (varsha/maasa/dina/hora) |
| `lord` | `Planet` | Ruling planet |
| `startDate` | `DateTime` | Period start |
| `endDate` | `DateTime` | Period end |
| `duration` | `Duration` | Period duration |

---

### Ashtakavarga

Complete Ashtakavarga data.

| Property | Type | Description |
|----------|------|-------------|
| `bhinnashtakavarga` | `Map<Planet, Bhinnashtakavarga>` | Individual planet scores |
| `sarvashtakavarga` | `List<int>` | Combined scores per sign |
| `samudaya` | `int` | Total points |

| Method | Returns | Description |
|--------|---------|-------------|
| `getTotalBindusForHouse(house)` | `int` | SAV for house |
| `getBindusForPlanet(planet, sign)` | `int` | BAV for planet in sign |

---

### VimshopakBala

20-fold strength result.

| Property | Type | Description |
|----------|------|-------------|
| `totalScore` | `double` | Total score out of 20 |
| `strengthCategory` | `StrengthCategory` | Category (Very Strong, Strong, etc) |
| `individualScores` | `Map<DivisionalChartType, double>` | Score per varga |

---

### CombustionInfo

Detailed combustion status.

| Property | Type | Description |
|----------|------|-------------|
| `isCombust` | `bool` | Is planet combust |
| `distanceFromSun` | `double` | Distance from Sun in degrees |
| `combustionOrb` | `double` | Allowed orb for combustion |
| `severity` | `CombustionSeverity` | Severity (None, Partial, Deep, etc) |
| `remainingDegrees` | `double` | Degrees to exit combustion |

---

### YogaPindaResult

Yoga Pinda calculation result.

| Property | Type | Description |
|----------|------|-------------|
| `planet` | `Planet` | The planet |
| `totalYogaPinda` | `double` | Total Yoga Pinda points |
| `strengthRating` | `String` | Strength description |

---

### ShodhyaPindaResult

Complete Shodhya Pinda analysis.

| Property | Type | Description |
|----------|------|-------------|
| `yogaPinda` | `Map<Planet, YogaPindaResult>` | Yoga Pinda per planet |
| `totalYogaPinda` | `double` | Sum of all Yoga Pindas |
| `averageYogaPinda` | `double` | Average Yoga Pinda |
| `overallStrength` | `String` | Overall chart strength |

---

### VedhaResult

Transit obstruction analysis.

| Property | Type | Description |
|----------|------|-------------|
| `transitPlanet` | `Planet` | Transiting planet |
| `houseFromMoon` | `int` | House from natal Moon |
| `isFavorablePosition` | `bool` | Is in favorable house |
| `isObstructed` | `bool` | Is obstructed by Vedha |
| `obstructingPlanets` | `List<Planet>` | Planets causing obstruction |
| `severity` | `VedhaSeverity` | Severity of obstruction |

---

### PlanetVisibility

Visibility analysis result.

| Property | Type | Description |
|----------|------|-------------|
| `isVisible` | `bool` | Is planet visible |
| `visibilityType` | `VisibilityType` | Type of visibility |
| `elongation` | `double` | Angle from Sun |
| `magnitude` | `double` | Approximate magnitude |
| `description` | `String` | Visibility description |

---

### EclipseData

Solar or lunar eclipse information.

| Property | Type | Description |
|----------|------|-------------|
| `date` | `DateTime` | Date of maximum eclipse |
| `eclipseType` | `EclipseType` | Solar or Lunar |
| `magnitude` | `double` | Umbral eclipse magnitude |
| `penumbralMagnitude` | `double?` | Fraction of Moon diameter in penumbra |
| `isVisible` | `bool` | Visible at location |
| `isTotal` | `bool` | Is total eclipse |
| `penumbralStartTime` | `DateTime?` | P1 – Penumbral start |
| `partialStartTime` | `DateTime?` | U1 – Partial start |
| `totalStartTime` | `DateTime?` | U2 – Total begins |
| `totalEndTime` | `DateTime?` | U3 – Total ends |
| `partialEndTime` | `DateTime?` | U4 – Partial ends |
| `penumbralEndTime` | `DateTime?` | P4 – Penumbral ends |
| `moonrise` | `DateTime?` | Observer's moonrise (UTC) |
| `moonset` | `DateTime?` | Observer's moonset (UTC) |
| `localStartTime` | `DateTime?` | Visible eclipse start (local window) |
| `localEndTime` | `DateTime?` | Visible eclipse end (local window) |
| `localDuration` | `Duration?` | Total duration visible at location |
| `sutakStartTime` | `DateTime?` | Sutak begin (anchored to local visibility) |
| `sutakEndTime` | `DateTime?` | Sutak end (matches U4) |
| `sutakForSensitive` | `DateTime?` | 3-hour Sutak for vulnerable groups |
| `description` | `String` | Eclipse description |

---

### AbhijitMuhurta

The 8th Muhurta of daytime. Calculated as 1/15th of daylight duration (traditional). Duration varies by season/location (~45-60 min).

| Property | Type | Description |
|----------|------|-------------|
| `startTime` | `DateTime` | Start time |
| `endTime` | `DateTime` | End time |
| `duration` | `Duration` | Length of muhurta |
| `description` | `String` | Description |

| Method | Returns | Description |
|--------|---------|-------------|
| `contains(dateTime)` | `bool` | Is time in muhurta |

---

### BrahmaMuhurta

The 14th Muhurta of night, ending at sunrise. Calculated as 1/15th of nighttime (traditional). Duration varies by season/location.

| Property | Type | Description |
|----------|------|-------------|
| `startTime` | `DateTime` | Start time |
| `endTime` | `DateTime` | End time |
| `duration` | `Duration` | Length of muhurta |
| `description` | `String` | Description |

---

### NighttimeInauspiciousPeriods

Night inauspicious times.

| Property | Type | Description |
|----------|------|-------------|
| `rahuKaal` | `TimePeriod` | Night Rahu Kaal |
| `gulikaKaal` | `TimePeriod` | Night Gulika Kaal |
| `yamagandam` | `TimePeriod` | Night Yamagandam |

| Method | Returns | Description |
|--------|---------|-------------|
| `isInauspicious(dateTime)` | `bool` | Is time in any period |

---

### MoonPhaseDetails

Comprehensive Moon data.

| Property | Type | Description |
|----------|------|-------------|
| `phaseName` | `String` | Name of phase |
| `illumination` | `double` | % Illumination |
| `isWaxing` | `bool` | Waxing or Waning |
| `lunarAge` | `double` | Days since New Moon |
| `elongation` | `double` | Angle from Sun |
| `elongationVelocity` | `double` | Speed relative to Sun |
| `tithiNumber` | `int` | Current Tithi (1-30) |
| `isFullMoon` | `bool` | Is Full Moon |
| `isNewMoon` | `bool` | Is New Moon |

---

### YogaDetails

27 Nitya Yoga descriptions.

| Property | Type | Description |
|----------|------|-------------|
| `name` | `String` | Yoga name |
| `nature` | `String` | Nature (Benefic/Malefic) |
| `rulingPlanet` | `String` | Ruling planet |
| `description` | `String` | Description |
| `effects` | `String` | General effects |
| `recommendations` | `String` | Recommended activities |

| Method | Returns | Description |
|--------|---------|-------------|
| `isFavorableFor(activity)` | `bool` | Check activity |

---

### GowriPanchangamInfo

Gowri Panchangam period information.

| Property | Type | Description |
|----------|------|-------------|
| `type` | `GowriType` | Type of Gowri period |
| `startTime` | `DateTime` | Start time of period |
| `endTime` | `DateTime` | End time of period |
| `isDaytime` | `bool` | True if daytime, false if nighttime |
| `periodNumber` | `int` | Sequence number (1-8) |
| `description` | `String` | Human-readable description |

---

### GowriType

Enum for the 8 Gowri periods.

| Value | Sanskrit | Auspicious | Description |
|-------|----------|------------|-------------|
| `amrit` | α«àα««α«┐α«░α»ìα«ñα««α»ì | Yes | Nectar, success in all endeavors |
| `rogam` | α«░α»ïα«òα««α»ì | No | Disease, suffering |
| `uthi` | α«ëα«ñα«┐ | Yes | Progress, upliftment |
| `labhamu` | α«▓α«╛α«¬α««α»ì | Yes | Gain, profit |
| `dhana` | α«ñhana | Yes | Wealth, prosperity |
| `nirkku` | α«¿α«┐α«░α»ìα«òα»ìα«òα»ü | No | Obstacles, impediments |
| `visham` | α«╡α«┐α«╖α««α»ì | No | Poison, danger |
| `soolai` | α«Üα»éα«▓α»ê | No | Distress, pain |

---

### BhavaBalaResult

House strength calculation result.

| Property | Type | Description |
|----------|------|-------------|
| `houseNumber` | `int` | House number (1-12) |
| `strength` | `double` | Total strength value |
| `category` | `BhavaStrengthCategory` | Strength category |
| `lordStrength` | `double` | Strength from house lord (Shadbala) |
| `placementStrength` | `double` | Strength from planet placement |
| `aspectStrength` | `double` | Strength from aspects |
| `digBala` | `double` | Directional strength |

---

### BhavaStrengthCategory

House strength categories.

| Value | Range |
|-------|-------|
| `veryStrong` | 90-100 |
| `strong` | 70-90 |
| `moderate` | 50-70 |
| `weak` | 30-50 |
| `veryWeak` | 0-30 |

---

### HoraPeriod

Planetary hour period.

| Property | Type | Description |
|----------|------|-------------|
| `lord` | `Planet` | Ruling planet |
| `startTime` | `DateTime` | Start time |
| `endTime` | `DateTime` | End time |
| `hourNumber` | `int` | Hour number (1-12) |
| `isDaytime` | `bool` | True if daytime |

| Method | Returns | Description |
|--------|---------|-------------|
| `contains(time)` | `bool` | Check if time falls in period |
| `isFavorableFor(activity)` | `bool` | Check if favorable for activity |

---

### Choghadiya

Choghadiya period information.

| Property | Type | Description |
|----------|------|-------------|
| `type` | `ChoghadiyaType` | Type of Choghadiya |
| `startTime` | `DateTime` | Start time |
| `endTime` | `DateTime` | End time |
| `isDaytime` | `bool` | True if daytime |
| `periodNumber` | `int` | Period number (1-8) |
| `rulingPlanet` | `Planet?` | Ruling planet |

---

### ChoghadiyaType

Choghadiya period types.

| Value | Meaning | Auspicious | Favored Activities |
|-------|---------|------------|-------------------|
| `amrit` | Nectar | Yes | All auspicious |
| `shubh` | Auspicious | Yes | Beginnings, travel |
| `labh` | Gain | Yes | Business, investment |
| `char` | Moving | Yes | Travel, relocation |
| `udveg` | Anxiety | No | Routine work only |
| `kaal` | Death | No | Avoid auspicious |
| `rog` | Disease | No | Avoid procedures |

---

### ArudhaPadaInfo

Arudha Pada calculation result.

| Property | Type | Description |
|----------|------|-------------|
| `houseNumber` | `int` | House number |
| `sign` | `Rashi` | Sign of Arudha Pada |
| `longitude` | `double` | Longitude in degrees |
| `lord` | `Planet` | Sign lord |

---

### ArudhaPadaResult

Complete Arudha Padas for all houses.

| Property | Type | Description |
|----------|------|-------------|
| `arudhaPadas` | `Map<int, ArudhaPadaInfo>` | Arudha Padas for houses 1-12 |
| `arudhaLagna` | `ArudhaPadaInfo` | Arudha Lagna (AL) |
| `upapada` | `ArudhaPadaInfo` | Upapada Lagna (UL) |

---

### ArgalaInfo

Argala (planetary interruption) information.

| Property | Type | Description |
|----------|------|-------------|
| `planet` | `Planet` | Planet causing argala |
| `house` | `int` | House being aspected |
| `isFavorable` | `bool` | Is favorable argala |
| `strength` | `double` | Strength of argala |

---

### KarakamsaInfo

Karakamsa (soul planet in Navamsa) result.

| Property | Type | Description |
|----------|------|-------------|
| `atmakaraka` | `Planet` | Planet with highest degree |
| `karakamsaSign` | `Rashi` | Sign where AK is in Navamsa |
| `karakamsaLongitude` | `double` | Longitude in Navamsa |

---

### RashiDrishtiInfo

Jaimini sign aspect information.

| Property | Type | Description |
|----------|------|-------------|
| `fromSign` | `Rashi` | Sign casting aspect |
| `toSign` | `Rashi` | Sign receiving aspect |
| `aspectingPlanets` | `List<Planet>` | Planets casting aspect |
| `aspectStrength` | `double` | Strength of aspect |

---

### PrashnaSphutas

Prashna (horary) special points.

| Property | Type | Description |
|----------|------|-------------|
| `trisphuta` | `double` | Trisphuta longitude |
| `chatursphuta` | `double` | Chatursphuta longitude |
| `panchadhyayi` | `double` | Panchadhyayi point |
| `shadVarga` | `double` | Shad Varga point |
| ` Hora` | `double` | Hora point |
| `gulika` | `double` | Gulika longitude |

---

### SudarshanChakraResult

Sudarshan Chakra strength analysis result.

| Property | Type | Description |
|----------|------|-------------|
| `lagnaPerspective` | `Map<int, double>` | House strengths from Lagna |
| `chandraPerspective` | `Map<int, double>` | House strengths from Moon |
| `suryaPerspective` | `Map<int, double>` | House strengths from Sun |
| `overallStrength` | `double` | Overall chart strength |
| `strongHouses` | `List<int>` | Houses with strength >= 60% |
| `weakHouses` | `List<int>` | Houses with strength < 40% |

---

### VimsopakaBalaResult

Vimsopaka Bala (divisional chart strength) result.

| Property | Type | Description |
|----------|------|-------------|
| `planet` | `Planet` | Planet |
| `totalScore` | `double` | Score out of 20 |
| `vargaScore` | `double` | Varga component |
| `sambandhaScore` | `double` | Relationship component |
| `category` | `VimsopakaCategory` | Strength category |

### VimsopakaCategory

| Value | Score Range | Description |
|-------|------------|-------------|
| `atipoorna` | 18-20 | Exceptional |
| `poorna` | 16-18 | Very Good |
| `atimadhya` | 14-16 | Above Average |
| `madhya` | 12-14 | Average |
| `adhama` | 10-12 | Below Average |
| `durga` | 8-10 | Weak |
| `sangatDurga` | 5-8 | Very Weak |

### EnhancedBhavaBalaResult

Enhanced house strength with Vimsopaka integration.

| Property | Type | Description |
|----------|------|-------------|
| `houseNumber` | `int` | House 1-12 |
| `totalStrength` | `double` | Total strength |
| `category` | `EnhancedBhavaStrengthCategory` | Strength category |
| `lordStrength` | `double` | From house lord's Shadbala |
| `kendradiStrength` | `double` | Kendra/Panaphara/Apoklima |
| `drishtiStrength` | `double` | From aspects |
| `vimsopakaStrength` | `double` | From Vimsopaka Bala |

---

### NadiInfo

Nadi astrology information.

| Property | Type | Description |
|----------|------|-------------|
| `nadiNumber` | `int` | Nadi number (1-1800) |
| `nadiName` | `String` | Name of Nadi |
| `nadiType` | `NadiType` | Type (Agasthiya, etc.) |
| `startLongitude` | `double` | Starting longitude |
| `endLongitude` | `double` | Ending longitude |
| `rulingPlanet` | `Planet` | Ruling planet |
| `element` | `String` | Element (Fire, Earth, etc.) |
| `characteristics` | `List<String>` | Nadi characteristics |

### NadiChart

Complete Nadi chart for a Vedic chart.

| Property | Type | Description |
|----------|------|-------------|
| `moonNadi` | `NadiInfo` | Moon's Nadi |
| `sunNadi` | `NadiInfo` | Sun's Nadi |
| `ascendantNadi` | `NadiInfo` | Ascendant's Nadi |
| `planetNadis` | `Map<Planet, NadiInfo>` | All planets' Nadis |
| `nadiSeed` | `int` | Primary Nadi seed number |

### NadiType

| Value | Description |
|-------|-------------|
| `agasthiya` | Most comprehensive |
| `bhrigu` | Past life karma focus |
| `saptarshi` | General predictions |
| `nandi` | Dharma focused |
| `bharga` | Energy/vitality |
| `chandra` | Mind/emotions |

---

### ProgenyResult

Progeny analysis result.

| Property | Type | Description |
|----------|------|-------------|
| `strength` | `ProgenyStrength` | Overall strength category |
| `score` | `int` | Score (0-100) |
| `fifthHouseStrength` | `FifthHouseStrength` | 5th house analysis |
| `jupiterCondition` | `JupiterCondition` | Jupiter analysis |
| `d7Analysis` | `D7Analysis` | Saptamsa analysis |
| `childYogas` | `List<ChildYoga>` | Favorable yogas |
| `analysis` | `List<String>` | Detailed analysis |

### ProgenyStrength

| Value | Score Range |
|-------|------------|
| `strong` | 60-100 |
| `moderate` | 40-60 |
| `weak` | 20-40 |
| `veryWeak` | 0-20 |

---

### CompatibilityResult

Marriage compatibility result.

| Property | Type | Description |
|----------|------|-------------|
| `totalScore` | `int` | Score out of 36 |
| `level` | `CompatibilityLevel` | Compatibility level |
| `gunaScores` | `GunaScores` | Individual koota scores |
| `doshaCheck` | `DoshaCheck` | Dosha analysis |
| `dashaCompatibility` | `DashaCompatibility?` | Dasha matching |
| `analysis` | `List<String>` | Detailed analysis |

### GunaScores

Ashtakoota (36 Guna) scoring. All 8 Kootas are calculated per BPHS and
standard Vedic texts. Scores are added to produce the total out of 36.

| Koota | Max Points | Classification Basis |
|-------|------------|---------------------|
| `varna` | 1 | BPHS 4-tier: Brahmin / Kshatriya / Vaishya / Shudra per nakshatra |
| `vashya` | 2 | 5-category: Manava / Vanachara / Chatushpada / Jalajiva / Keeta per nakshatra |
| `tara` | 3 | Count from boy's nakshatra to girl's; groups of 9 (birth, sampat, vipatΓÇª) |
| `yoni` | 4 | Animal pair per nakshatra (all 27 correctly mapped); friend/enemy pairs scored |
| `grahaMaitri` | 5 | Natural friendship between Moon sign lords per BPHS friendship table |
| `gana` | 6 | BPHS: Deva / Manushya / Rakshasa ΓÇö same=6, Deva+Manushya=3, Rakshasa=0 |
| `bhakoot` | 7 | No dosha = 7; Dosha (2/12, 5/9, or 6/8 moon-sign relationship) = 0 |
| `nadi` | 8 | Cyclic modulo-3 grouping: 0% same Nadi (Dosha) = 0, different = 8 |

**Bhakoot Dosha** is checked for three problematic inter-sign relationships:
2/12 (financial stress), 5/9 (progeny issues), and 6/8 (health/longevity).

**Nadi** is determined by `nakshatraIndex % 3` (cyclic): 0=Adi, 1=Madhya, 2=Antya.
This differs from the old sequential block-of-9 approach which was incorrect.

### CompatibilityLevel

| Value | Score Range |
|-------|------------|
| `excellent` | 33-36 |
| `veryGood` | 25-32 |
| `good` | 18-24 |
| `average` | 12-17 |
| `poor` | 0-11 |

---

---

## New in v2.5.0 — AstrologicalSystem

This release formalises the split between the **Traditional Parashari / KN Rao** paradigm
and the **Krishnamurti Paddhati (KP)** system at the API level.

### `AstrologicalSystem` enum

```dart
enum AstrologicalSystem { traditional, kp }
```

| Value | Ayanamsa | House System | Node | Exclusive services |
|---|---|---|---|---|
| `traditional` | Lahiri | Whole-Sign / Equal | Mean Node (BPHS) | All except `KPService` |
| `kp` | KP VP291 | **Placidus** (auto-selected) | True Node | `KPService` |

### What changed in `CalculationFlags`

| New member | Type | Description |
|---|---|---|
| `system` | `AstrologicalSystem` | The paradigm this flag set describes |
| `isKP` | `bool` | Shorthand: `system == kp` |
| `isTraditional` | `bool` | Shorthand: `system == traditional` |

All factory constructors now declare their system explicitly.  
`CalculationFlags.kp()` → `AstrologicalSystem.kp`  
All other factories → `AstrologicalSystem.traditional`

`copyWith` and `toString` are updated accordingly.

### What changed in `VedicChart`

- New **`flags`** getter (`CalculationFlags`, non-nullable). Returns `calculationFlags`
  or `CalculationFlags.traditionalist()` for backwards-compatible charts.

### KPService guard-rails

`calculateKPData()` and `calculateRulingPlanets()` now throw `StateError` if the chart
was not created with `CalculationFlags.kp()`. Error message includes the received
system and ayanamsa to guide the fix.

### Migration guide

```dart
// ❌ Before — silently wrong (Lahiri ayanamsa with KP Sub-Lord tables)
final chart = await jyotish.calculateVedicChart(dateTime: dt, location: loc);
final kp = await jyotish.calculateKPData(chart); // no guard-rail

// ✅ After — fails fast, clear error if wrong
final chart = await jyotish.calculateVedicChart(
  dateTime: dt,
  location: loc,
  houseSystem: 'P',              // Placidus — mandatory for KP
  flags: CalculationFlags.kp(),  // KP VP291 ayanamsa + system tag
);
final kp = await jyotish.calculateKPData(chart); // guard-rail passes
```

### Checking the system at runtime

```dart
if (chart.flags.isKP) {
  // safe to call any KPService method
}
if (chart.flags.isTraditional) {
  // safe to call Parashari / Jaimini / Shadbala methods
}
```

---

## Enums

### Planet

Celestial bodies supported by the library.

| Value | Description |
|-------|-------------|
| `sun`, `moon` | Luminaries |
| `mercury`, `venus`, `mars`, `jupiter`, `saturn` | Traditional planets |
| `uranus`, `neptune`, `pluto` | Outer planets |
| `meanNode`, `trueNode`, `ketu` | Lunar nodes |
| `chiron`, `ceres`, `pallas`, `juno`, `vesta` | Asteroids |

**Static Getters**: `majorPlanets`, `traditionalPlanets`, `outerPlanets`, `lunarNodes`, `asteroids`, `all`

---

### SiderealMode

Ayanamsa modes for sidereal calculations.

| Value | Description |
|-------|-------------|
| `lahiri` | Most common in Indian astrology |
| `krishnamurti` | KP astrology |
| `raman` | Raman ayanamsa |
| `faganBradley` | Western sidereal |
| ... | 40+ modes available |

---

### DivisionalChartType

Divisional chart types.

| Value | Description |
|-------|-------------|
| `d1` | Rashi (birth chart) |
| `d2` | Hora (wealth) |
| `d3` | Drekkana (siblings) |
| `d4` | Chaturthamsa (fortune) |
| `d7` | Saptamsa (children) |
| `d9` | Navamsa (marriage/dharma) |
| `d10` | Dasamsa (career) |
| `d12` | Dwadasamsa (parents) |
| `d16` | Shodasamsa (vehicles) |
| `d20` | Vimsamsa (spiritual) |
| `d24` | Chaturvimshamsa (education) |
| `d27` | Saptavimshamsa (strength) |
| `d30` | Trimsamsa (misfortune) |
| `d40` | Khavedamsa (auspiciousness) |
| `d45` | Akshavedamsa (general) |
| `d60` | Shashtiamsa (past karma) |
| `d249` | KP micro-divisions |

---

### PlanetaryDignity

Planetary dignity status.

| Value | English | Sanskrit |
|-------|---------|----------|
| `exalted` | Exalted | Uccha |
| `moolaTrikona` | Moola Trikona | Moola Trikona |
| `ownSign` | Own Sign | Swakshetra |
| `greatFriend` | Great Friend | Adhi-Mitra |
| `friendSign` | Friend's Sign | Mitra |
| `neutral` | Neutral | Sama |
| `enemySign` | Enemy's Sign | Shatru |
| `greatEnemy` | Great Enemy | Adhi-Shatru |
| `debilitated` | Debilitated | Neecha |

---

### NodeType

Lunar node calculation type.

| Value | Description |
|-------|-------------|
| `meanNode` | Mean Node (traditional, smoother) |
| `trueNode` | True Node (modern, precise) |

---

### MasaType

Lunar month system.

| Value | Description |
|-------|-------------|
| `amanta` | Starts from New Moon (South India, Gujarat) |
| `purnimanta` | Starts from Full Moon (North India) |

---

### LunarMonth

The 12 lunar months.

| Value | Sanskrit | Period |
|-------|----------|--------|
| `chaitra` | αñÜαÑêαññαÑìαñ░ | March-April |
| `vaishakha` | αñ╡αÑêαñ╢αñ╛αñû | April-May |
| `jyeshtha` | αñ£αÑìαñ»αÑçαñ╖αÑìαñá | May-June |
| `ashadha` | αñåαñ╖αñ╛αñóαñ╝ | June-July |
| `shravana` | αñ╢αÑìαñ░αñ╛αñ╡αñú | July-August |
| `bhadrapada` | αñ¡αñ╛αñªαÑìαñ░αñ¬αñª | August-September |
| `ashwina` | αñàαñ╢αÑìαñ╡αñ┐αñ¿ | September-October |
| `kartika` | αñòαñ╛αñ░αÑìαññαñ┐αñò | October-November |
| `margashirsha` | αñ«αñ╛αñ░αÑìαñùαñ╢αÑÇαñ░αÑìαñ╖ | November-December |
| `pausha` | αñ¬αÑîαñ╖ | December-January |
| `magha` | αñ«αñ╛αñÿ | January-February |
| `phalguna` | αñ½αñ╛αñ▓αÑìαñùαÑüαñ¿ | February-March |

---

### Ritu

Hindu seasons.

| Value | Description | Months |
|-------|-------------|--------|
| `vasanta` | Spring | Chaitra, Vaishakha |
| `grishma` | Summer | Jyeshtha, Ashadha |
| `varsha` | Monsoon | Shravana, Bhadrapada |
| `sharad` | Autumn | Ashwina, Kartika |
| `hemanta` | Pre-winter | Margashirsha, Pausha |
| `shishira` | Winter | Magha, Phalguna |

---

### VisibilityType

Planet visibility status.

| Value | Description |
|-------|-------------|
| `notVisible` | Too close to Sun |
| `heliacalRise` | First visible before sunrise |
| `heliacalSet` | Last visible after sunset |
| `daytime` | Visible in daylight |
| `evening` | Evening star |
| `morning` | Morning star |

---

### VarshapalPeriodType

Varshapal period types.

| Value | Description |
|-------|-------------|
| `varsha` | Year period (1 year) |
| `maasa` | Month period (~30 days) |
| `dina` | Day period (1 day) |
| `hora` | Hour period (1 hour) |

---

### EclipseType

Type of eclipse.

| Value | Description |
|-------|-------------|
| `solar` | Solar eclipse |
| `lunar` | Lunar eclipse |

---

## New in v2.6.0 — High-Precision Eclipse Reporting

This release introduces professional-grade eclipse reporting using Swiss Ephemeris' native FFI bindings, providing all 7 major contact times and local observer visibility details.

### Expanded `EclipseData`

The `EclipseData` model now provides granular phase transitions for lunar eclipses:

- **P1**: Penumbral Start
- **U1**: Umbral Start (Partial begin)
- **U2**: Total Start
- **U3**: Total End
- **U4**: Umbral End (Partial end)
- **P4**: Penumbral End

### Local Visibility Window

Observers often want to know if an eclipse is visible from their specific location. The library now automatically calculates:
- `moonrise` / `moonset`: Calculated for the eclipse search date.
- `localStartTime`: The later of U1 and moonrise.
- `localEndTime`: The earlier of U4 and moonset.
- `localDuration`: The actual visible duration for the observer.

### Location-Aware Sutak

Traditional religious timings (Sutak) are now anchored to `localStartTime` instead of the global astronomical U1. This ensures that if the Moon rises *after* the eclipse has already begun globally, the Sutak period correctly shifts relative to the visibility at the observer's location.

### `getRiseSet` precision

The `getRiseSet` method now includes `searchFromExactTime`. Setting this to `true` allows finding the sequence of events (e.g., finding the moonset that occurs *after* a specific moonrise), which is crucial for across-midnight events.

---

## Error Handling

The library throws `JyotishException` for errors:

```dart
try {
  final chart = await jyotish.calculateVedicChart(...);
} on InitializationException catch (e) {
  // Library not initialized
} on CalculationException catch (e) {
  // Calculation failed
} on PolarRegionException catch (e) {
  // Latitude too high for Placidus/Koch house systems
} on AyanamsaMismatchException catch (e) {
  // Base chart Ayanamsa incompatible with requested divisional chart
} on ValidationException catch (e) {
  // Invalid inputs
} on JyotishException catch (e) {
  // General error
}
```

---

## Best Practices

1. **Always initialize before use**: Call `jyotish.initialize()` before any calculations
2. **Dispose when done**: Call `jyotish.dispose()` to free resources
3. **Use timezone**: Include timezone in `GeographicLocation` for accurate historical calculations
4. **Prefer Jyotish class**: Use the main `Jyotish` class instead of individual services for simpler code
5. **Cache charts**: Reuse `VedicChart` objects for multiple calculations (aspects, dashas, etc.)

---

*Generated for Jyotish Flutter Library (SV-stark Fork)*
