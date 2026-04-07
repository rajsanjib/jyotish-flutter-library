# Jyotish Library API Audit Report

> Generated: 2026-04-04
> Library version: 2.5.0
> Files examined: 84 Dart files across 12 directories under `lib/src/`

---

## Table of Contents

1. [API Documentation Inaccuracies](#1-api-documentation-inaccuracies)
2. [Entire Services Missing from API Docs](#2-entire-services-missing-from-api-docs)
3. [Undocumented Public Methods on Documented Services](#3-undocumented-public-methods-on-documented-services)
4. [Undocumented Public Classes/Enums](#4-undocumented-public-classesenums)
5. [Undocumented Methods on `Jyotish` Class](#5-undocumented-methods-on-jyotish-class)
6. [Services Not Wired Into `Jyotish` Facade](#6-services-not-wired-into-jyotish-facade)
7. [Internal Utilities Worth Exposing](#7-internal-utilities-worth-exposing)
8. [Summary Statistics](#8-summary-statistics)

---

## 1. API Documentation Inaccuracies

### 1.1 Return Type Mismatches

> **Correction (2026-04-07):** These are NOT mismatches. Both methods correctly return their specific types in both the facade and the service. The "Extended Dasha Methods" table in API_REFERENCE.md listed them as `DashaResult` — that documentation entry has been corrected.

| Method | Correct Return Type | Location |
|---|---|---|
| `getCharaDasha` | `Future<CharaDashaResult>` | `jyotish_core.dart:1940` |
| `getNarayanaDasha` | `Future<NarayanaDashaResult>` | `jyotish_core.dart:1952` |

### 1.2 Methods Listed on `Jyotish` But Actually on Separate Services

> **Fixed (2026-04-07):** `calculateChandrabalam`, `calculateTarabalam`, `calculateUdayaLagnas`, and `calculateRitualElements` have been added as facade methods on `Jyotish` and wired into `initialize()`. `getTajakaEnhancements` remains on `TajakaService` only.

| Method | Status | Notes |
|---|---|---|
| `calculateChandrabalam` | ✅ Fixed — now on `Jyotish` | Delegates to `PanchangStrengthService` |
| `calculateTarabalam` | ✅ Fixed — now on `Jyotish` | Delegates to `PanchangStrengthService` |
| `calculateUdayaLagnas` | ✅ Fixed — now on `Jyotish` | Delegates to `UdayaLagnaService` |
| `calculateRitualElements` | ✅ Fixed — now on `Jyotish` | Delegates to `RitualService` |
| `getTajakaEnhancements` | ✅ Fixed — on `Jyotish` (line 3166) | Delegates to `TajakaService.calculateTajakaEnhancements` |

### 1.3 `VedhaResult` Class Discrepancy

The API docs document `VedhaResult` with a `transitPlanet` property as a `String`. In the actual code (`gochara_vedha_service.dart:343`), the transit planet is stored as a private `Planet _transitPlanet` field, with `transitPlanet` being a getter that returns `String` (the display name). The primary property is `isObstructed`; `isVedhaActive` is a legacy alias getter for backwards compatibility.

---

## 2. Entire Services Missing from API Docs

These services exist in the codebase, are exported in `jyotish.dart`, but have **zero** documentation in `API_REFERENCE.md`:

### 2.1 PanchangStrengthService

- **File**: `lib/src/strength/panchang_strength_service.dart`
- **Public Methods**:
  - `calculateChandrabalam(currentMoonNakshatra)` → `ChandrabalamInfo` — Moon strength for all 12 Rashis
  - `calculateTarabalam(birthNakshatraIndex, currentNakshatra)` → `TarabalamInfo` — Star strength (Janma, Sampat, etc.)

### 2.2 UdayaLagnaService

- **File**: `lib/src/astronomy/udaya_lagna_service.dart`
- **Public Methods**:
  - `calculateUdayaLagnas(date, location, sunrise)` → `Future<List<UdayaLagnaPeriod>>` — 12 Daily Ascendant periods

### 2.3 RitualService

- **File**: `lib/src/muhurta/ritual_service.dart`
- **Public Methods**:
  - `calculateRitualElements(panchanga)` → `RitualElements` — Homahuti, Agnivasa, Shivavasa, Kumbha Chakra

### 2.4 AstrologyTimeService

- **File**: `lib/src/astronomy/astrology_time_service.dart`
- **Public Methods**:
  - `initialize()` — Initialize timezone data (called automatically by `Jyotish.initialize()`)
  - `localToUtc(DateTime localDt, String zoneId)` → `DateTime` — Convert local to UTC
  - `getOffset(DateTime date, String zoneId)` → `Duration` — Get timezone offset (DateTime first, then zone ID)
  - `availableTimezones` → `List<String>` — Available timezone IDs

> **Note:** `getOffset` parameter order is `(DateTime date, String zoneId)` — DateTime first. This was previously documented with reversed parameters.

---

## 3. Undocumented Public Methods on Documented Services

### 3.1 DashaService (`lib/src/systems/dasha_service.dart`)

| Method | Line | Description |
|---|---|---|
| `isAshtottariApplicable(chart)` | 662 | Determines if Ashtottari Dasha is applicable per BPHS rules |
| `defaultYearLength` (static const) | 25 | Default year length = 365.25 |
| `savanaYearLength` (static const) | 28 | Savana year length = 360.0 |
| `vimshottariSequence` (static const) | 31 | Vimshottari planet order |

### 3.2 VarshapalService (`lib/src/systems/varshapal_service.dart`)

| Method | Line | Description |
|---|---|---|
| `getVarshapal(...)` | 143 | Alias for `calculateVarshapal` |
| `getCurrentVarshapal(...)` | 201 | Alias for `calculateCurrentVarshapal` |
| `getSamvatsaraName(int yearNumber)` (static) | 407 | Gets Samvatsara name from year number (1-60) |
| `getCurrentVarshaNumber(DateTime date, {int? referenceYear})` (static) | 412 | Gets current varsha number (1-60); `referenceYear` defaults to current year; epoch: 1983 = Prabhava |

### 3.3 ShadbalaService (`lib/src/systems/shadbala_service.dart`)

| Method | Line | Description |
|---|---|---|
| `calculateVimshopakaBala(planet, chart)` | 111 | Calculates 20-fold strength |
| `_minimumShadbala` (static const Map) | 1476 | BPHS minimum required Shadbala values per planet |

### 3.4 KPService (`lib/src/systems/kp_service.dart`)

| Method | Line | Description |
|---|---|---|
| `generateKPDivisionTable()` | 576 | Generates the complete KP 249 Sub-Lord table |

### 3.5 MuhurtaService (`lib/src/muhurta/muhurta_service.dart`)

| Method | Line | Description |
|---|---|---|
| `getHoraLordForHour(dateTime, sunrise)` | 358 | Gets Hora lord for a specific hour |
| `calculateDurMuhurtam(...)` | 375 | Calculates inauspicious Dur Muhurtam periods (North & South Indian methods) |
| `getDishashool(dateTime)` | 448 | Gets unfavorable travel direction for a date |
| `getRahuVasa(nakshatra)` | 451 | Gets Rahu's residence based on current Nakshatra |
| `getChandraVasa(longitude)` | 465 | Gets Moon's residence based on longitude |
| `calculateVarjyam(...)` | 485 | Calculates Varjyam (Thyajya) inauspicious window |

### 3.6 MasaService (`lib/src/panchanga/masa_service.dart`)

| Method | Line | Description |
|---|---|---|
| `getNakshatraWithAbhijit(dateTime, location)` | 156 | Gets nakshatra including 28th Abhijit |
| `calculateNakshatraFromLongitude(longitude)` | 180 | Core nakshatra calculation from longitude |

### 3.7 JaiminiService (`lib/src/systems/jaimini_service.dart`)

| Method | Line | Description |
|---|---|---|
| `getRashiDrishti(chart, [sign])` | 117 | Legacy method, overloaded for single-sign and full-chart queries |
| `getRashiDrishtiList(chart)` | 112 | Alias for `calculateRashiDrishti` |
| `getActiveRashiDrishti(chart)` | 150 | Alias for `calculateActiveRashiDrishti` |

### 3.8 ArudhaPadaService (`lib/src/systems/arudha_pada_service.dart`)

| Method | Line | Description |
|---|---|---|
| `getArudhaPadas(chart)` | 25 | Alias for `calculateArudhaPadas` |
| `getArudhaLagna(chart)` | 34 | Alias for `calculateArudhaLagna` |
| `getUpapada(chart)` | 43 | Alias for `calculateUpapada` |

### 3.9 ArgalaService (`lib/src/systems/argala_service.dart`)

| Method | Line | Description |
|---|---|---|
| `getAllArgalas(chart)` | 17 | Alias for `calculateAllArgalas` |
| `getArgalaForHouse(chart, house)` | 69 | Alias for `calculateArgalaForHouse` |
| `calculateArgalaForPlanet(chart, planet)` | 76 | Calculates which houses a specific planet causes Argala on |

### 3.10 PlanetaryRelationshipService (`lib/src/strength/planetary_relationship_service.dart`)

| Method | Line | Description |
|---|---|---|
| `describeRelationship(planet, otherPlanet, chart)` | 114 | Returns human-readable summary string |

### 3.11 ProgenyService (`lib/src/analysis/progeny_service.dart`)

| Method | Line | Description |
|---|---|---|
| `analyzeD7Chart(chart)` | 167 | Analyzes the D7 (Saptamsa) chart for progeny |
| `analyzeKalatrakaraka(chart)` | 236 | Analyzes Kalatrakaraka (spouse/child karaka) |

### 3.12 CompatibilityService (`lib/src/analysis/compatibility_service.dart`)

| Method | Line | Description |
|---|---|---|
| `calculateVarna(boyNak, girlNak)` | 73 | Varna Koota scoring (max 1 pt) |
| `calculateTara(boyNak, girlNak, boyIdx, girlIdx)` | 193 | Tara Koota scoring (max 3 pts) |
| `calculateGrahaMaitri(boyChart, girlChart)` | 359 | Graha Maitri scoring (max 5 pts) |
| `calculateGana(boyNak, girlNak)` | 434 | Gana Koota scoring (max 6 pts) |
| `calculateBhakoot(boyChart, girlChart)` | 498 | Bhakoot Koota scoring (max 7 pts) |
| `calculateNadi(boyChart, girlChart)` | 554 | Nadi Koota scoring (max 8 pts) |

### 3.13 EphemerisService (`lib/src/astronomy/ephemeris_service.dart`)

| Method | Line | Description |
|---|---|---|
| `isInitialized` (getter) | 876 | Whether the service has been initialized |

### 3.14 HoraService (`lib/src/muhurta/hora_service.dart`)

| Method | Line | Description |
|---|---|---|
| `chaldeanOrder` (static const) | 22 | Chaldean planetary order list |

---

## 4. Undocumented Public Classes/Enums

### 4.1 Ashtakavarga Classes

| Class/Enum | File | Description |
|---|---|---|
| `PindaResult` | `ashtakavarga_service.dart:638` | Result of Pinda calculation |
| `YogaPindaResult` | `ashtakavarga_service.dart:661` | Result of Yoga Pinda calculation |
| `ShodhyaPindaResult` | `ashtakavarga_service.dart:705` | Complete Shodhya Pinda analysis |
| `YogaPindaRating` | `ashtakavarga_service.dart:687` | Enum: excellent/veryGood/good/moderate/weak/veryWeak |
| `ShodhyaStrength` | `ashtakavarga_service.dart:758` | Enum: veryStrong/strong/moderate/weak/veryWeak |

### 4.2 Strength Classes

| Class/Enum | File | Description |
|---|---|---|
| `VimshopakBala` | `strength_analysis_service.dart:510` | 20-fold strength result |
| `VimshopakStrength` | `strength_analysis_service.dart:550` | Enum: excellent/good/moderate/weak/veryWeak |
| `IshtaKashtaResult` | `strength_analysis_service.dart:565` | Ishtaphala-Kashtaphala analysis |
| `PlanetaryFriendship` | `house_strength_service.dart:351` | Enum: own/greatFriend/friend/neutral/enemy/greatEnemy |

### 4.3 Gochara Vedha Classes

| Class/Enum | File | Description |
|---|---|---|
| `VedhaResult` | `gochara_vedha_service.dart:343` | Vedha obstruction analysis |
| `VedhaSeverity` | `gochara_vedha_service.dart:412` | Enum: none/mild/moderate/severe |
| `TransitSnapshot` | `gochara_vedha_service.dart:428` | Transit snapshot at a time |
| `FavorablePeriod` | `gochara_vedha_service.dart:446` | Favorable period without Vedha |

### 4.4 Panchanga Classes

| Class | File | Description |
|---|---|---|
| `AbhijitMuhurta` | `panchanga_service.dart:1009` | Abhijit Muhurta timing |
| `BrahmaMuhurta` | `panchanga_service.dart:1029` | Brahma Muhurta timing |
| `PanchangaTimePeriod` | `panchanga_service.dart:1049` | Generic time period |
| `NighttimeInauspiciousPeriods` | `panchanga_service.dart:1063` | Nighttime inauspicious periods |
| `MoonPhaseDetails` | `panchanga_service.dart:1086` | Detailed Moon phase info |

### 4.5 Astronomy Classes

| Class | File | Description |
|---|---|---|
| `UdayaLagnaPeriod` | `udaya_lagna_service.dart:5` | Daily ascendant period |

---

## 5. Undocumented Methods on `Jyotish` Class

| Method | Line | Description |
|---|---|---|
| `calculateNatalChart(...)` | 380 | Legacy alias for `calculateVedicChart` |
| `calculateAshtakavargaWithShodhana(chart)` | 796 | Ashtakavarga + all Shodhana reductions |
| `applyTrikonaShodhana(ashtakavarga)` | 823 | Applies trine reduction |
| `applyEkadhipatiShodhana(ashtakavarga)` | 829 | Applies lordship reduction |
| `scoreTransits(...)` | 839 | Score transits against natal Ashtakavarga |
| `getAshtakavargaReductions(...)` | 2009 | Apply reductions to an Ashtakavarga |
| `calculateHoraLordsForDay(...)` | 2052 | All 24 Hora lords for a day |
| `calculateSudarshanChakra(chart)` | 2762 | Primary method — delegates to `SudarshanChakraService` (no alias `getSudarshanChakra` exists) |
| `getChartStrengthReport(chart)` | 3018 | Comprehensive strength report |
| `getAllGrahaAvasthas(chart)` | 3008 | Avasthas for all planets |
| `getPlanetaryRelationship(planet, other, chart)` | 2981 | Relationship between two planets |
| `analyzeD7Chart(chart)` | 2830 | D7 chart analysis for progeny |
| `systems` (getter) | 155 | Access `JyotishSystems` |

---

## 6. Services Not Wired Into `Jyotish` Facade

> **Fixed (2026-04-07):** `PanchangStrengthService`, `UdayaLagnaService`, and `RitualService` are now wired into `Jyotish.initialize()` and exposed as facade methods. `AstrologyTimeService` static proxies (`localToUtc`, `getTimezoneOffset`, `availableTimezones`) are now accessible via `Jyotish` static methods.

| Service | File | Status |
|---|---|---|
| `PanchangStrengthService` | `panchang_strength_service.dart` | ✅ Fixed — wired into facade |
| `UdayaLagnaService` | `udaya_lagna_service.dart` | ✅ Fixed — wired into facade |
| `RitualService` | `ritual_service.dart` | ✅ Fixed — wired into facade |
| `AstrologyTimeService` | `astrology_time_service.dart` | ✅ Fixed — static proxies on `Jyotish` |

---

## 7. Internal Utilities Worth Exposing

### 7.1 High-Value Internal Methods

| Method | Service | File | Why It Should Be Exposed |
|---|---|---|---|
| `_calculateSignLordAdvanced` | `DashaService` | `dasha_service.dart:1024` | Advanced sign lord logic handling Scorpio/Aquarius dual lordship |
| `_calculateSignSourceStrength` | `DashaService` | `dasha_service.dart:1068` | Sign source strength for Narayana Dasha starting sign |
| `_getDynamicMonthLord` | `ShadbalaService` | `shadbala_service.dart:648` | Binary search to find exact Sankranti moment for Maasa Bala |
| `_getYearLordFromMeanJupiter` | `ShadbalaService` | `shadbala_service.dart:763` | Varsha Bala lord using Surya Siddhanta constants |
| `_calculateProfessionalAspectStrength` | `ShadbalaService` | `shadbala_service.dart:1292` | Professional 60-virupa aspect strength calculation |
| `_calculateVargaScore` | `HouseStrengthService` | `house_strength_service.dart:190` | Varga score calculation for Vimsopaka Bala |
| `_calculateSambandhaScore` | `HouseStrengthService` | `house_strength_service.dart:226` | Sambandha (relationship) score calculation |
| `_angularMidpoint` | `BhavaChalitService` | `bhava_chalit_service.dart:89` | Correctly handles 0/360 wrap-around for angular midpoint |
| `_getVedhaNakshatras` | `SarvatobhadraService` | `sarvatobhadra_service.dart:88` | Classical 27-star Sarvatobhadra Vedha mapping table |

### 7.2 Internal Constants Worth Exposing

| Constant | Service | File | Purpose |
|---|---|---|---|
| `_trikonas` | `AshtakavargaService` | `ashtakavarga_service.dart:601` | The 4 trikona groups |
| `_dualSigns` | `AshtakavargaService` | `ashtakavarga_service.dart:609` | Dual sign pairs for Ekadhipati Shodhana |
| `_oddFootSigns` | `AshtakavargaService` | `ashtakavarga_service.dart:618` | Signs with odd foot |
| `_pindaMultipliers` | `AshtakavargaService` | `ashtakavarga_service.dart:621` | Sign multipliers for Pinda (1-12) |
| `_minimumShadbala` | `ShadbalaService` | `shadbala_service.dart:1476` | BPHS minimum required Shadbala per planet |
| `_deepExaltationPoints` | `ShadbalaService` | `shadbala_service.dart:1463` | Deep exaltation degree for each planet |
| `_averageSpeeds` | `ShadbalaService` | `shadbala_service.dart:1453` | Average daily speeds for Chesta Bala |
| `gocharaFavorableHouses` | `GocharaVedhaService` | `gochara_vedha_service.dart:19` | Favorable houses for each transiting planet |
| `vedhaRelationships` | `GocharaVedhaService` | `gochara_vedha_service.dart:37` | Vedha relationship mappings |
| `nakshatraVedha` | `GocharaVedhaService` | `gochara_vedha_service.dart:52` | Nakshatra-based Vedha mappings |
| `totalNadisPerSign` | `NadiService` | `nadi_service.dart:7` | 150 Nadis per sign |
| `totalNadis` | `NadiService` | `nadi_service.dart:8` | Total Nadis (1800) |
| `samvatsaraNames` | `VarshapalService` | `varshapal_service.dart:18` | All 60 Samvatsara names |
| `varshaDasaOrder` | `VarshapalService` | `varshapal_service.dart:34` | Varsha Dasa planet order |

---

## 8. Summary Statistics

| Metric | Count |
|---|---|
| Total Dart files examined | 84 |
| Total public service classes | 41 |
| Services fully documented | ~28 |
| Services with undocumented public methods | 13 |
| Entire services missing from docs | 4 |
| Public methods on services not in docs | ~40+ |
| Public classes/enums not in docs | ~17 |
| Methods on `Jyotish` class not in docs | 13 |
| Documented return types that are wrong | 2 |
| Methods documented on Jyotish but on separate services | 5 |
| Services not wired into Jyotish facade | 4 |
