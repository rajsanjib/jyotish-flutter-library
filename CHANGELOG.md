# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.6.0] - 2026-02-25

### [2.6.0] - High-Precision Eclipse & API Completeness
### **Major Eclipse Enhancements (Solar & Lunar)**
We have vastly improved the calculation of solar and lunar eclipses by exposing and integrating explicit local visibility functions from the underlying Swiss Ephemeris C-library (`swe_sol_eclipse_when_loc`, `swe_lun_eclipse_when`, etc.). 

- **Local Solar Eclipse Precision**: `EphemerisService.getEclipseData()` now accurately determines if a solar eclipse is visible at the provided `GeographicLocation`. It no longer defaults to global visibility, but instead accurately computes local obscuration magnitudes, contact times, and duration.
- **Accurate Lunar Penumbral Phases**: Fixed bugs where `P4` (Penumbral End) contact times were mapping to incorrect pointers in memory. Lunar Eclipses now capture global `P1` and `P4` accurately alongside the primary `U1` to `U4` umbral contacts.
- **`calculateLunarEclipseHow`** — wraps `swe_lun_eclipse_how`; returns umbral
  and penumbral magnitudes and 20 eclipse attributes at a given moment.
- **`findLunarEclipseWhen`** — wraps `swe_lun_eclipse_when`; returns the full
  `tret[0..9]` contact-time array for the next eclipse after a given JD.

#### New `EclipseData` Fields
| Field | Description |
|---|---|
| `penumbralMagnitude` | Fraction of Moon's diameter in penumbra (e.g. 2.18) |
| `penumbralStartTime` | P1 – first contact with penumbra |
| `penumbralEndTime` | P4 – last contact with penumbra |
| `partialStartTime` | U1 – first contact with umbra |
| `partialEndTime` | U4 – last contact with umbra |
| `totalStartTime` | U2 – total phase begins |
| `totalEndTime` | U3 – total phase ends |
| `moonrise` | Moonrise at observer's location (UTC) |
| `moonset` | Moonset at observer's location after moonrise (UTC) |

#### New `EclipseData` Getters
| Getter | Description |
|---|---|
| `localStartTime` | Later of U1 and moonrise (eclipse visible start for observer) |
| `localEndTime` | Earlier of U4 and moonset (eclipse visible end for observer) |
| `localDuration` | Duration of eclipse as seen from observer's location |
| `isPenumbralOnly` | True when magnitude ≤ 0 but penumbral magnitude > 0 |
| `sutakForSensitive` | 3-hour Sutak for children, elderly, and the sick |

#### Updated Sutak Logic
`sutakStartTime` and `sutakForSensitive` now anchor to `localStartTime`
(moonrise if after U1) rather than global U1. This correctly models the
traditional rule that Sutak applies from when the eclipse is *observable* at
the observer's location.

#### `getRiseSet` Enhancement
Added optional `searchFromExactTime` parameter (default `false`). When `true`,
the search begins at the exact DateTime provided rather than the start-of-day
UTC — used internally to find moonset *after* moonrise.

#### Verification (New Delhi — 03 March 2026 Total Lunar Eclipse)
```
P1 – 14:14 IST  [Ref: 14:16]   ✅
U1 – 15:20 IST  [Ref: 15:21]   ✅
U2 – 16:34 IST  [Ref: 16:35]   ✅
Max – 17:03 IST [Ref: 17:04]   ✅
U3 – 17:32 IST  [Ref: 17:33]   ✅
U4 – 18:47 IST  [Ref: 18:46]   ✅
P4 – 19:53 IST  [Ref: 19:52]   ✅
Umbral Magnitude  1.1482  [Ref: 1.14]   ✅
Penumbral Mag     2.1814  [Ref: 2.18]   ✅
Local Start  18:22 IST   [Ref: 18:26]   ✅
Local End    18:47 IST   [Ref: 18:46]   ✅
```

## [2.5.0] - 2026-02-25

### Added — `AstrologicalSystem` Enum & System Clarity

This release formalises the split between the **Traditional Parashari / KN Rao**
paradigm and the **Krishnamurti Paddhati (KP)** system. Mixing paradigms was a
source of subtle, silent bugs (e.g., KP Sub-Lord tables computed against Lahiri
ayanamsa). Library users now get compile-time clarity, runtime guard-rails, and
**automated configuration** (using `CalculationFlags.kp()` now automatically
selects the Placidus house system).

#### New: `AstrologicalSystem` enum (`calculation_flags.dart`)

```dart
enum AstrologicalSystem { traditional, kp }
```

| Value | Ayanamsa | House System | Node | Use for |
|---|---|---|---|---|
| `traditional` | Lahiri | Whole-Sign / Equal | Mean Node (BPHS) | Parashari, KN Rao, BPHS, Jaimini, Shadbala, all Dasha systems |
| `kp` | KP VP291 | **Placidus** (mandatory) | True Node | KP Sub-Lords, Significators, Ruling Planets, cuspal interlinks |

#### Updated: `CalculationFlags`

- **New field**: `system` (`AstrologicalSystem`, default `traditional`).
- **New convenience getters**: `isKP` and `isTraditional`.
- **Updated `copyWith`**: now accepts `system` parameter.
- **Updated `toString`**: includes `system` name.
- All factory constructors now explicitly set `system`:
  - `CalculationFlags.traditionalist()` → `AstrologicalSystem.traditional`
  - `CalculationFlags.modernPrecision()` → `AstrologicalSystem.traditional`
  - `CalculationFlags.kp()` → `AstrologicalSystem.kp`
  - `CalculationFlags.sidereal()`, `.siderealLahiri()`, `.topocentric()`, `.withNodeType()` → `AstrologicalSystem.traditional`

#### Updated: `VedicChart`

- **New getter**: `flags` — returns `calculationFlags ?? CalculationFlags.traditionalist()`.
  Only the existing nullable `calculationFlags` field is stored; the getter is a
  zero-breaking-change convenience accessor.

#### Updated: `KPService` — system guard-rails

`calculateKPData()` and `calculateRulingPlanets()` now assert that the supplied
chart was created with `CalculationFlags.kp()`. A clear `StateError` is thrown
if a traditional-system chart is passed by mistake:

```
StateError: calculateKPData requires CalculationFlags.kp()
(AstrologicalSystem.kp + KP VP291 ayanamsa).
Received system: traditional, ayanamsa: lahiri.
Create the chart with CalculationFlags.kp() and houseSystem: "P"
(Placidus) before calling KP-specific services.
```

### Migration Guide

Existing code that does **not** pass `CalculationFlags` to `calculateVedicChart`
continues to work unchanged (defaults to `traditional`).

Existing code that uses `KPService` and passes a non-KP chart will now receive a
`StateError` at runtime. Fix by ensuring the chart is created with the KP flags:

```dart
// Before (silently wrong — Lahiri ayanamsa used with KP tables):
final chart = await jyotish.calculateVedicChart(...);
final kpData = await jyotish.calculateKPData(chart); // ← no guard-rail

// After (correct — fails fast if wrong flags used):
final chart = await jyotish.calculateVedicChart(
  ...,
  houseSystem: 'P',               // Placidus — mandatory for KP
  flags: CalculationFlags.kp(),   // ← KP VP291 ayanamsa + system tag
);
final kpData = await jyotish.calculateKPData(chart); // ← guard-rail passes
```

## [2.4.0] - 2026-02-25

### Fixed — Missing API Surface & Implementations

- **Panchanga Service API Extension**: Exposed 5 advanced Panchanga methods directly on the `Jyotish` facade (`calculateAbhijitMuhurta`, `calculateBrahmaMuhurta`, `calculateNighttimeInauspicious`, `getTithiJunction`, `getMoonPhaseDetails`). Exported the corresponding models.
- **Gochara Vedha API Extension**: Exposed 3 transit obstruction methods (`hasMutualVedha`, `findFavorablePeriodsWithoutVedha`, `getVedhaRemedies`) and exported their models.
- **Strength Analysis API Extension**: Exposed alternate `getStrengthBhavaBala` and batch `getAllPlanetsVimshopakBala`. Exported related models.
- **Tajaka Saham Expansion**: Increased calculated Sahams from 3 to 14, implementing classical daytime/nighttime reversal logic.
- **Sarvatobhadra Chakra**: Refactored the simplified offset logic into the accurate classical 27-star Nakshatra Vedha lookup table mapping (Frontal, Left, Right aspects).
- **Graha Avastha Deeptadi**: Added the 9 `DeeptadiAvastha` states (Mood/Condition) derived from planetary dignity, combustion, and retrograde status. Added this state to the `GrahaAvastha` model.
- **Event Timing Dual-Scoring**: Enhanced the `EventTimingService` scoring engine to jointly evaluate both the Mahadasha and Antardasha lords' transits (and their Vedhas) when generating favorable event windows.

## [2.3.0] - 2026-02-25

### Added — Professional Features (Phase 2)

Integrated 9 advanced features for professional astrology analysis:
- **Configurable Ayanamsa per Chart**: Threaded `CalculationFlags` through all services to allow per-chart Ayanamsa overrides.
- **Graha Avastha**: Added `Baladi` (age-based) and `Jagratadi` (alertness-based) states mapping dignity and signs.
- **Strength Summary Report**: New `StrengthReportService` aggregating Shadbala, Vimshopaka, and Avastha.
- **Kalachakra Antardashas**: Added proportional sub-period distribution based on BPHS logic.
- **Event Timing (Dasha + Transit)**: New engine combining Dasha periods with Gochara Vedha and house transit analysis for event scoring.
- **D-10 Career Analysis**: Professional career domain analysis based on Dashamsha lord and strong planets.
- **KP 249-Division Table**: Complete system generate the 249 sub-lord boundaries with high precision.
- **Sarvatobhadra Chakra**: Transit Vedha analysis on the 27-star Nakshatra lattice for obstruction detection.
- **Tajaka Enhancements**: Annual chart expansions including Muntha, Sahams (Punya/Vidya), and Tajaka Yogas.

## [2.2.0] - 2026-02-25

### Fixed — Vedic System Accuracy & Strength Logic

This major accuracy release addresses several core discrepancies in planetary strength and relationship logic.

#### Core Models & Relationships
- **Moon→Venus Relationship**: Corrected to **Neutral** (0) per BPHS. Previously incorrectly set to Enemy (-1).
- **Rahu/Ketu Natural Relations**: Added Rahu (acts like Saturn) and Ketu (acts like Mars) entries to `RelationshipCalculator` to support full Panchadha logic.
- **Ketu Direction**: Fixed `KetuPosition.longitudeSpeed` to match Rahu exactly (negation removed).
- **Combustion Refs**: Mercury (12°/14°) and Venus (8°/10°) orbs now tighten in retrograde. All planets now use specialized orbs per BPHS rules.

#### Dignity & Friendship
- **Panchadha Maitri Implementation**: Refactored `VedicChartService` and `DivisionalChartService` to use a two-pass house mapping. Dignities now correctly account for **Temporal (Tatkalika)** friendship in every chart.
- **Vimshopaka Points**: Fixed MoolaTrikona value to 18 points (previously 10).

#### Dasha System Corrections
- **Narayana Dasha**: Fixed sign counting direction. Even signs now correctly count in reverse.
- **Yogini Dasha**: Removed incorrect +3 offset from starting lord index. Ashwini now correctly starts with Mangala.
- **Ashtottari Dasha**: Added support for 2 levels (Antardashas) with proportional segment allocation.

#### Shadbala & Aspects
- **Natonnata Bala**: Replaced binary 60/0 logic with a proportional **Day/Night arc gradient**. Strength peaks at temporal mid-points (Noon/Midnight).
- **Chesta Bala**: Implemented the traditional **8-state motion classification** (Vakra, Anuvakra, Vikala, etc.) based on planetary speed vs mean speed.
- **Rashi Drishti**: Exposed `getRashiAspects` bridge in `AspectService` for Jaimini sign-based aspects.

#### Ashtakavarga & Jaimini
- **Shodhana (Reductions)**: Implemented full **Trikona Shodhana** (trine) and **Ekadhipati Shodhana** (ownership) reductions.
- **Pinda Calculations**: Added **Rashi Pinda** and **Graha Pinda** (Yoga Pinda) with specialized multipliers for sign lords and Nodes.
- **Dual Ownership**: Implemented Mars/Ketu (Scorpio) and Saturn/Rahu (Aquarius) dual-lordship logic for sign-based dashas.
- **Atmakaraka**: Precision calculation of the **Soul Planet** based on the highest degree in natal chart.

#### KP System Accuracy
- **Significator Prediction**: Fixed **C & D significators** to use dynamically calculated Placidus house cusps instead of fixed 30° sign maps, aligning with high-precision KP software.

### Added
- **Unit Tests**: Added `relationship_test.dart`, `dignity_test.dart`, `bhava_chalit_test.dart`, and `dasha_accuracy_test.dart`.

## [2.1.0] - 2026-02-24

### Fixed — Vedic Astrology Accuracy (Panchanga & Compatibility)

This release corrects several significant discrepancies between the library's
calculations and widely-followed Vedic astrology principles (BPHS, Muhurta
Chintamani, Surya Siddhanta).

#### Panchanga (`panchanga.dart`, `panchanga_service.dart`)

- **Tithi 15 distinction**: `TithiInfo` now has separate `shuklaTithiNames` and
  `krishnaTithiNames` lists. Tithi 15 of Shukla Paksha is correctly named
  **"Purnima"** and Tithi 15 of Krishna Paksha is correctly named **"Amavasya"**.
  The old merged list `tithiNames` has been replaced with the static helper
  `TithiInfo.nameFromNumber(int tithiNumber)` which selects the correct name
  based on paksha. `masa_service.dart` is updated to use the same helper.
- **Moon illumination formula**: Corrected from an inverted linear formula
  (which showed 100% at New Moon) to the astronomically correct cosine formula:
  `((1 − cos(elongation × π/180)) / 2) × 100`. New Moon (0°) now correctly
  yields 0% and Full Moon (180°) yields 100%.
- **Moon phase names**: `_getMoonPhaseName()` previously only covered 0°–168°
  and returned "New Moon" for the entire Krishna Paksha (168°–360°). Now covers
  the full 0°–360° elongation range with correct Tithi-aligned thresholds
  (Purnima at 168°–192°, Krishna Ashtami at 264°–288°, etc.).
- **Brahma Muhurta**: Night duration was previously computed as `sunrise −
  same-day sunset`, yielding a negative value and placing Brahma Muhurta after
  sunrise. Now uses **previous day's sunset** for the correct nighttime duration.

#### Compatibility / Guna Milan (`compatibility_service.dart`)

All eight Kootas are now calculated per standard Vedic texts:

- **Yoni Koota**: Complete and correct animal map for all 27 nakshatras
  (Anuradha→Deer, Jyeshtha→Deer, Mula→Dog, P.Ashadha→Monkey,
  U.Ashadha→Mongoose, Shravana→Monkey, Dhanishta→Lion, Shatabhisha→Horse,
  P.Bhadrapada→Lion, U.Bhadrapada→Cow, Revati→Elephant — previously all
  mapped to "Tiger"). Separate friend/enemy pair logic added.
- **Varna Koota**: Classification reworked per BPHS (Brahmin: Krittika, Pushya,
  Ashlesha, Magha, U.Phalguni, Hasta, Swati, Anuradha, Shravana, P.Ashadha,
  P.Bhadrapada, Revati — and so on for other varnas).
- **Gana Koota**: Classification fixed per BPHS (Deva: Ashwini, Mrigashira,
  Punarvasu, Pushya, Hasta, Swati, Anuradha, Shravana, Revati; Manushya: 9;
  Rakshasa: Krittika, Ashlesha, Magha, Chitra, Vishakha, Jyeshtha, Mula,
  Dhanishta, Shatabhisha). Scoring: same = 6, Deva+Manushya = 3, any
  Rakshasa pair = 0.
- **Tara Koota**: Implemented the 9-tier classification (Janma, Sampat, Vipat,
  Kshema, Pratyari, Sadhaka, Vadha, Mitra, Ati-Mitra) based on Nakshatra
  distance from Moon.
- **Vashya Koota**: Added Rashi-based classification (Chatushpada, Manava,
  Jalachara, Vanachara, Keeta) to determine interpersonal control scores.
- **Graha Maitri Koota**: Was a stub returning 0. Now fully implemented with
  the BPHS natural planetary friendship table (friends/enemies/neutrals for
  each of the 7 traditional planets). Sign lords are looked up per classical
  rules (e.g. Mars rules Aries and Scorpio).
- **Bhakoot Koota**: Dosha check now covers all three problematic inter-sign
  relationships: **2/12, 5/9, and 6/8** (previously only checked for 6/12).
- **Nadi Koota**: Nadi (Adi/Madhya/Antya) now uses correct **cyclic modulo-3**
  grouping (`nakshatraIndex % 3`) instead of the incorrect sequential blocks of
  9 nakshatras.

#### Health & Doshas
- **Manglik Dosha**: Initial implementation of **Kuja Dosha** check (Mars in 1st, 2nd, 4th, 7th, 8th, or 12th houses) with high-precision longitude checking.

#### Dasha (`dasha_service.dart`)

- **Period precision**: All five Vimshottari Dasha levels (Mahadasha,
  Antardasha, Pratyantardasha, Sookshma, Prana) now use `Duration(milliseconds:)`
  instead of `Duration(days: .round())`. This prevents cumulative rounding
  errors that could cause drifts of days or weeks over a 120-year cycle.

### Changed API

| Symbol | Change |
|---|---|
| `TithiInfo.tithiNames` | **Replaced** by `TithiInfo.shuklaTithiNames`, `TithiInfo.krishnaTithiNames`, and `TithiInfo.nameFromNumber(int)` |
| `MoonPhaseDetails.illumination` | **Formula corrected** — values are now inverted relative to the old (wrong) output |

> **Migration note**: Any code referencing `TithiInfo.tithiNames[...]` directly
> must be updated to use `TithiInfo.nameFromNumber(tithiNumber)` or index into
> the appropriate paksha list. The old `tithiNames` list no longer exists.

## [2.0.0] - 2026-02-08


### Added

- **Strict Mode Validation for D249**
  - Added validation to ensure D249 uses new KP Ayanamsa only.
  - Throws `AyanamsaMismatchException` if an improper Ayanamsa is used on D249 calculation.

- **Polar Region Strictness**
  - Calculates checking for Absolute Latitude >= 66.5°.
  - Throws `PolarRegionException` when evaluating Placidus or Koch above the Arctic Circle.

- **True Node / Mean Node Configuration (Rahu/Ketu)**
  - Added new explicit standard factories `CalculationFlags.traditionalist()` and `CalculationFlags.modernPrecision()`.
  - Deprecated ambiguous `CalculationFlags.defaultFlags()`.
- **D249 - 249 Subdivisions (High-Precision Micro Analysis)**
  - Complete implementation of 249 subdivisions per zodiac sign
  - Ultra-fine granularity for advanced Vedic analysis (~0.12° per subdivision)
  - Odd sign mapping: starts from same sign, counts forward through 249 parts
  - Even sign mapping: starts from 9th sign, counts forward through 249 parts
  - Compatible with existing D1-D60 divisional chart infrastructure
  - Comprehensive test suite with 10+ test cases
  - API: `DivisionalChartType.d249`

- **Corrected Vara (Weekday) Calculation**
  - Updated `PanchangaService` to use Sunrise as the day boundary instead of midnight
  - Births between midnight and sunrise now correctly resolve to the previous day's planet lord
  - API: `jyotish.getVara()` is now asynchronous and requires `location`

- **Tithi End-Time Analysis**
  - New API for finding exact moments when a Tithi ends
  - Uses high-precision binary search with sub-second accuracy
  - API: `jyotish.getTithiEndTime()`

- **Shadbala (Six-fold Planetary Strength)**
  - Complete implementation of all 6 strength types:
    - Sthana Bala (Positional Strength)
    - Dig Bala (Directional Strength) 
    - Kala Bala (Temporal Strength)
    - Chesta Bala (Motional Strength)
    - Naisargika Bala (Natural Strength)
    - Drik Bala (Aspectual Strength)
  - `calculateShadbala()` - Calculate complete Shadbala for all planets
  - Strength categorization (Very Strong, Strong, Moderate, Weak, Very Weak)

- **Ashtakavarga Reductions (Shodhana)**
  - `applyTrikonaShodhana()` - Trine reduction for 1-5-9 groups
  - `applyEkadhipatiShodhana()` - Reduction for same sign ownership
  - `calculatePinda()` - Final planetary strength (Rupas calculation)

- **Panchanga Module**
  - Tithi, Yoga, Karana, and Vara calculations
  - High-precision sunrise and sunset times using Swiss Ephemeris
- **Ashtakavarga System**
  - Bhinnashtakavarga (BAV) for all planets
  - Sarvashtakavarga (SAV) calculation
  - Ashtakavarga-based transit strength analysis
- **KP System (Krishnamurti Paddhati)**
  - Support for KP-specific ayanamsas (New VP291, Khullar)
  - Sign, Star, Sub-Lord, and Sub-Sub-Lord calculations
  - House and planet significators
- **Special Transits**
  - Sade Sati (Saturn's 7.5 year transit) status and phase analysis
  - Dhaiya (Saturn's 2.5 year transit/Panoti) analysis
  - Panchak detection and precautions
- **Muhurta & Auspicious Timings**
  - Hourly Hora Lord calculation
  - Daytime and Nighttime Choghadiya periods
  - Inauspicious periods: Rahukalam, Gulikalam, and Yamagandam
  - Activity-based Muhurta filtering

- **Vedic Aspect Calculations (Graha Drishti)**
  - All planets aspect 7th house (opposition)
  - Mars special aspects (4th, 8th houses)
  - Jupiter special aspects (5th, 9th houses)
  - Saturn special aspects (3rd, 10th houses)
  - Applying/separating aspect detection
  - Aspect strength calculation

- **Transit Calculations**
  - Current planetary transits over natal positions
  - Transit house placements
  - Transit aspects to natal planets
  - Transit event prediction with date ranges

- **Dasha System Support**
  - Vimshottari Dasha (120-year cycle)
  - Yogini Dasha (36-year cycle)
  - Mahadasha, Antardasha, Pratyantardasha levels
  - Current period calculation
  - Birth time precision warnings

- **Yogini Dasha Antardashas**
  - Added support for sub-periods (Antardasha) in Yogini Dasha
  - Added support for sub-sub-periods (Pratyantardasha) in Yogini Dasha
  - Correctly displaying Yogini names (e.g., Mangala, Pingala) instead of planet names


### New API Methods

- `getAspects()` - Calculate all Vedic aspects between planets
- `getAspectsForPlanet()` - Get aspects involving a specific planet
- `getChartAspects()` - Calculate aspects from a VedicChart
- `getTransitPositions()` - Calculate transit positions relative to natal chart
- `getTransitEvents()` - Find significant transit events in a date range
- `getVimshottariDasha()` - Calculate Vimshottari dasha periods
- `getYoginiDasha()` - Calculate Yogini dasha periods
- `getCurrentDasha()` - Get active dasha periods at any date

### New Models

- `AspectType` - Enum of Vedic aspect types
- `AspectInfo` - Detailed aspect information
- `AspectConfig` - Aspect calculation configuration
- `TransitInfo` - Transit position data
- `TransitEvent` - Transit event details
- `TransitConfig` - Transit calculation configuration
- `DashaPeriod` - Dasha period data
- `DashaResult` - Complete dasha calculation result
- `DashaType` - Enum of dasha systems
- `Yogini` - Enum of Yogini dasha lords

### Improved

- **Precision**: Updated Panchak calculation to use precise Mean Daily Motion of Moon (13.176°) instead of approximation.
- **Ephemeris Service**: Enhanced support for rise/set transitions and topocentric corrections.
- **Vedic Chart**: Improved planet data model to support extended Vedic properties.

### Fixed

- **Planetary Friendship Calculations**
  - Now properly calculates friend, enemy, and neutral relationships
  - Added `greatFriend` (Adhi-Mitra) and `greatEnemy` (Adhi-Shatru) dignities
  - Affects dignity calculations in both Rashi and all D-Charts

- **D-Chart Dignity Calculations**
  - All divisional charts (D1-D60) now calculate dignities correctly
  - Dignities no longer default to "neutral" in D-Charts

- **Sade Sati Date Estimation**
  - Replaced constant `daysPerSign` with variable Saturn speed calculation
  - Now accounts for retrograde motion and sign-specific variations
  - More accurate start/end date predictions

- **Rahu/Ketu Distinguishability**
  - Added `lordName` field to `DashaPeriod` to properly distinguish Rahu from Ketu
  - Both planets display correctly in dasha output (e.g., "Rahu-Mercury-Venus")

- **KP Ayanamsa Calculation**
  - Now uses precise time-varying formula from Swiss Ephemeris
  - Uses `SiderealMode.krishnamurtiVP291` instead of hardcoded offset

- **Extended Dasha Support**
  - Added **Chara Dasha** (Jaimini sign-based dasha)
  - Added **Narayana Dasha**
  - Added **Ashtottari Dasha** (108-year cycle)
  - Added **Kalachakra Dasha**
  - `getDashaPeriods()` now supports all these systems

- **Jaimini Astrology Support**
  - **Atmakaraka** calculation (planet with highest degree)
  - **Karakamsa** (Atmakaraka in Navamsa) analysis
  - **Rashi Drishti** (Sign Aspects) per Jaimini rules

- **Sudarshan Chakra**
  - Complete analysis of Sun, Moon, and Ascendant charts combined
  - Visualizing planetary positions across all three reference points

- **Gochara Vedha (Transit Obstruction)**
  - Analysis of Vedha (obstruction) points for transiting planets
  - Determines if a transit's effect is blocked or modified by other planets

### Breaking Changes

- **`calculateKPData()` is now async** - Returns `Future<KPCalculations>` instead of `KPCalculations`
  - Migration: Add `await` before the call: `final kpData = await jyotish.calculateKPData(chart)`

## [1.0.1] - 2025-11-25

### Fixed

- Fixed package validation errors for pub.dev publishing
- Improved export organization (alphabetically sorted)

## [1.0.0] - 2025-10-19

### Added

- Initial release of Jyotish library
- Swiss Ephemeris integration via FFI
- Support for all major planets (Sun through Pluto)
- Lunar nodes (Mean and True Node)
- Lunar apogees (Black Moon Lilith)
- Major asteroids (Chiron, Pholus, Ceres, Pallas, Juno, Vesta)
- Tropical and sidereal zodiac calculations
- 40+ ayanamsa systems for sidereal calculations
- Geocentric and topocentric position calculations
- Retrograde detection
- Nakshatra (lunar mansion) calculations
- Zodiac sign and position calculations
- Speed/velocity calculations
- Comprehensive error handling
- Input validation
- Production-ready API
- Full documentation and examples
- Example Flutter app
- Platform support: Android, iOS, macOS, Linux, Windows

### Features

- High-precision astronomical calculations
- Easy-to-use API
- Batch planet calculations
- Flexible calculation flags
- Geographic location support with DMS conversion
- JSON serialization support
- Proper resource management

[1.1.0]: https://github.com/rajsanjib/jyotish-flutter-library/releases/tag/v1.1.0
[1.0.1]: https://github.com/rajsanjib/jyotish-flutter-library/releases/tag/v1.0.1
[1.0.0]: https://github.com/rajsanjib/jyotish-flutter-library/releases/tag/v1.0.0
