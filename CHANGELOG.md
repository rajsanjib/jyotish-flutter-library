# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [2.18.0] - 2026-07-22

### Added
- **Data Model Serialization & Immutability (`toJson`, `fromJson`, `copyWith`)**:
  - Implemented 2-way JSON serialization (`toJson()` / `fromJson()`) and `copyWith()` state manipulation across core models (`VedicChart`, `PlanetPosition`, `VedicPlanetInfo`, `HouseSystem`, `DashaPeriod`, `DashaResult`).
- **Dependency Optimization & Cleanup**:
  - Moved `intl` to `dev_dependencies` (used strictly in test verification).
  - Explicitly pinned `test: ^1.24.0` in `dev_dependencies` for `package:test` test suites.
  - Enhanced `swisseph_bindings` and `ephemeris_service` with `package:path` for robust cross-platform path building and normalization.
- **Structured Service Logging**:
  - Integrated `Logger` from `package:logging` across core services (`VedicChartService`, `PanchangaService`, `DashaService`, `ShadbalaService`) for calculation diagnostics and warning reporting.
- **Documentation & Unit Tests**:
  - Added [test/serialization_test.dart](file:///D:/jyotish-flutter-library-fork/test/serialization_test.dart) covering JSON serialization and `copyWith` state manipulation.
  - Updated `USAGE.md` and `API_REFERENCE.md` with new model API signatures and serialization usage guides.

## [2.17.0] - 2026-07-04

### Added
- **Calculation Caching & Memoization**:
  - Implemented memory-bounded in-memory caching (max 5,000 items) inside `EphemerisService` for high-precision Swiss Ephemeris FFI calls, covering planetary positions, house systems, and sunrise/sunset timings.
  - Exposed `clearCache()` on the `Jyotish` core facade.
- **Astro-Chart Rendering Engine**:
  - Added a new `chart_renderer.dart` module providing high-fidelity SVG exports (`VedicChart.toSVG()`) for both South Indian (grid-based) and North Indian (diamond-based) chart styles.
  - Exposed Flutter `CustomPainter` canvas painter classes (`SouthIndianChartPainter` and `NorthIndianChartPainter`) to natively draw astrological charts in Flutter widgets.
- **Dynamic Timezone Database Loading**:
  - Added `loadTimezoneDatabase(List<int> bytes)` to allow developers to dynamically load newer IANA `.tzf` timezone databases at runtime without needing library updates.
- **Lazy Dasha Streams**:
  - Implemented `streamVimshottariDasha()` yielding nested Dasha periods lazily as a Dart stream to prevent memory bloat when scanning micro-periods.
- **Ashtakavarga Reductions (Shodhana) & Shodhya Pinda Corrections**:
  - Corrected sign multipliers (Rashi Gunakara) and planetary multipliers (Graha Gunakara) in `AshtakavargaService` to match classical Parashari values.
  - Corrected Graha Pinda calculation to evaluate only occupied signs in the birth chart using the occupying planet's multiplier.
- **Vimshopaka Bala Point Scale Corrections**:
  - Updated dignity points in `_getVimshopakaPoints` to align with the classical Parashari 20-point scale.

## [2.16.0] - 2026-06-20

### Added
- **Auspicious Muhurtas Comprehensive Scoring Engine**:
  - Implemented `MuhurtaScoringService` to evaluate time suitability on a 0-100% scale using weighted scores for Tithis, Nakshatras, Weekdays (Varas), Yogas, and Karanas, along with optional native Tarabalam/Chandrabalam factors.
  - Added `scanMuhurtaSuitability` to scan and identify the most auspicious Muhurtas over a specified window.
- **Specialized Jaimini & Nakshatra Dasha Systems**:
  - Exposed and fully tested Jaimini Chara Dasha, Narayana Dasha, and Kalachakra Dasha engines via `Jyotish` core and facade APIs, supporting sub-period sequences and balance calculations.
- **Double-Precision Junction Guardrails**:
  - Added coordinate snapping (`_adjustJunctionBoundary` and `_snapKPLongitude`) with a `1e-11` precision margin in `DivisionalChartService` and `KPService` to protect division and sign boundaries from floating-point representation errors.
  - Applied epsilon subtraction guardrails to Vimshottari dasha sub-lord division boundaries to eliminate edge-case errors.
- **Polar Region Sunrise/Sunset Fallbacks**:
  - Implemented a robust polar region fallback in `PanchangaService`. When Swiss Ephemeris returns `null` for sunrise/sunset (during polar day/night), it calculates apparent solar noon (meridian transit) and splits the day/night into equal 12-hour segments to prevent downstream service crashes.
- **Rahu/Ketu Node Type Consistency**:
  - Updated Ketu calculation logic in `EphemerisService` to check `CalculationFlags.nodeType` and resolve dynamically from either `Planet.trueNode` or `Planet.meanNode` matching Rahu, preventing node alignment mismatch.
- **Altitude Propagation**:
  - Propagated observer elevation/altitude to `VedicChart` and all local astronomical sub-services (Shadbala, Prashna, Muhurtas, etc.) to replace sea-level defaults and improve precision.

## [2.15.0] - 2026-06-19

### Added
- **High-Precision End-Times & Junctions for Nakshatras and Yogas**:
  - Implemented `getNakshatraEndTime`, `getYogaEndTime`, `getNakshatraJunction`, and `getYogaJunction` in [PanchangaService](file:///E:/jyotish-flutter-library-fork/lib/src/panchanga/panchanga_service.dart) using high-precision binary search.
  - Refactored `getTithiEndTime` and `getTithiJunction` wrap-around boundary logic using signed angular differences to prevent search direction bugs near 360°/0° crossings.
- **KP Sub-Sub-Sub-Lord (SSSL) Support**:
  - Added the `subSubSubLord` field to the `KPDivision` class and implemented `_calculateSubSubBoundaries` and `_calculateSubSubSubLord` in [KPService](file:///E:/jyotish-flutter-library-fork/lib/src/systems/kp_service.dart) to support micro-level astrological event timing.
- **Dynamic Obliquity of the Ecliptic in Shadbala**:
  - Implemented dynamic obliquity calculations using Swiss Ephemeris (`SE_ECL_NUT` / planet ID `-1`) in `EphemerisService.getObliquity`.
  - Integrated dynamic obliquity into Shadbala's `_calculateAyanaBala` to replace the static `23.45°` hardcoded constant.
- **Time-Varying & Ayanamsa-Specific Precession Corrections**:
  - Refactored planetary velocity corrections in `calculatePlanetPosition` to calculate the precession rate dynamically by taking the difference between tomorrow's and today's ayanamsa. This automatically accounts for both time-varying precession drift and ayanamsa-specific reference frames.
- **Exposed Atmospheric Refraction Parameters**:
  - Exposed `atmosphericPressure` and `atmosphericTemperature` parameters in `calculatePanchanga` to allow precise Sunrise/Sunset calculations under variable local atmospheric conditions.

## [2.14.0] - 2026-05-31

### Added
- **Natal & Conjunction Dosha Detection Engine**:
  - Implemented a comprehensive, high-precision dosha detection module at par with PyJHora, capable of identifying 8 key Vedic astrological flaws (Doshas) in natal charts.
  - **Kala Sarpa Dosha**: Detects if all traditional planets are hemmed between Rahu and Ketu. Resolves 12 specific types (Anant, Kulik, Vasuki, Shankhapal, Padma, Mahapadma, Takshak, Karkotak, Shankhachur, Ghatak, Vishdhar, Sheshnag) based on Rahu's house placement.
  - **Manglik Dosha**: Evaluates Mars placement relative to Lagna, Moon, and Venus. Integrates 17 BV Raman exceptions (such as Leo/Aquarius sign, Yoga Karaka Lagna, combustion, conjunctions with Jupiter/Moon, aspect from Saturn, and retrograde status) to calculate accurate Manglik cancellation status.
  - **Pitru Dosha**: Scans ancestral karmic afflictions using 5 classical rules (such as Sun/Moon/Rahu in the 9th house, Ketu in the 4th house, and Saturn/Mars afflictions to Sun/Moon/Nodes). Includes detailed remedies and factors matched.
  - **Guru Chandala Dosha**: Identifies Jupiter-Rahu/Ketu conjunctions, including planet strength evaluation to determine if Jupiter is stronger, which mitigates/cancels the dosha.
  - **Ganda Moola Dosha**: Scans if the Moon at birth is in one of the 6 Ketu/Mercury junction Nakshatras (Ashlesha, Magha, Jyeshtha, Mula, Revati, Ashwini).
  - **Kalathra Dosha**: Checks for natural malefic placements in spouse/partner houses (1st, 2nd, 4th, 7th, 8th, and 12th) from Lagna and Moon.
  - **Ghata & Shrapit Conjunction Doshas**: Scans for Mars-Saturn (Ghata) and Saturn-Rahu (Shrapit) conjunctions in the same house.
  - Exposed `checkNatalDoshas(chart)` through the main `Jyotish` facade, and `DoshaService().calculateFullDoshaReport(chart)` for direct usage.
  - Added unit test suite `test/dosha_test.dart` to verify logic accuracy.

## [2.13.0] - 2026-05-31

### Added
- **Natal & Raja Yoga Detection Engine**:
  - Implemented a comprehensive, high-precision yoga detection module at par with PyJHora, capable of identifying 287 different standard and Raja yogas in natal charts.
  - Added support for Sun/Moon flanking configurations (Vesi, Vosi, Sunapha, Anapha, Duradhara, Kemadruma Yogas).
  - Added full evaluation for Pancha Mahapurusha Yogas (Ruchaka, Bhadra, Hamsa, Malavya, Sasa).
  - Added complete Nabhasa Yogas suite (3 Aasraya Yogas, 2 Dala Yogas, 8 Aakriti Yogas, 7 Sankhya Yogas).
  - Added core Raja Yogas (Dharma-Karmadhipati, Vipareetha, and Neecha-Bhanga) with automatic debilitation cancellation rules.
  - Added `NatalYoga` model representing a detected yoga, its criteria, benefits, presence status, and dynamic explanation.
  - Added a high-level delegate method `detectNatalYogas(VedicChart chart)` in `Jyotish` core.
  - Added unit test suite `test/natal_yoga_test.dart` to verify logic correctness using mock longitudinal configurations.
- **Vedic Clock & Vedic Time Enhancements**:
  - Added round-trip conversion method `toDateTime()` in `VedicTime` to calculate Gregorian `DateTime` from traditional Vedic time (Ghati, Vighati, Lipta).
  - Refactored `VedicDigitalClock` and `VedicAnalogClock` widgets to use modern Flutter `super.key` and non-deprecated `.withValues(alpha: ...)` for color opacities.
  - Cleaned up all compile warnings and static analysis lints across newly introduced modules (such as unused variables, comment references, and curly brace block control flow).

## [2.12.0] - 2026-05-30

### Added
- **Tajika Varshapal (Solar Return) Engine Enhancements**:
  - **True Solar Return Moment**: High-precision binary search on UTC time to find the exact millisecond the transiting Sun returns to its natal longitude, with clean local timezone conversion.
  - **Panchavargiya Bala**: Standard 5-fold planetary strength calculation (Kshetra, Hadda, Drekkana, Navamsa, and Uccha Bala).
  - **Varshesh Determination**: Precise Year Lord selection utilizing the five candidate planets (Panchadhikaris) with aspect checks to Lagna and priority tie-breaking.
  - **Mudda Dasha**: Scaled annual Vimshottari periods based on the annual Moon's Nakshatra, adjusting start balance and cycling through all planetary periods.

---
## [2.10.0] - 2026-05-18

### Added
- **Tree-Shaking & Modular Barrel Files**: Added 9 independent barrel files representing logically isolated sub-modules. Consumers can now import micro-targeted modules directly instead of the heavy all-in-one barrel to optimize compiled bundle sizes and avoid cross-module export leaks:
  - `package:jyotish/core.dart` — Common models, enums, calculation flags, and base exceptions (`Jyotish`, `GeographicLocation`, `CalculationFlags`, `Planet`, `Rashi`, etc.)
  - `package:jyotish/analysis.dart` — Chart structures, divisional charts, compatibility Guna Milan, aspects, progeny, event timing, and Sudarshan Chakra
  - `package:jyotish/astronomy.dart` — Precision coordinate translations, astronomy time service, Udaya Lagna, and ephemeris structures
  - `package:jyotish/muhurta.dart` — Auspicious timings, Hora/Choghadiya services, Gowri Panchangam, Tarabalam/Chandrabalam, and ritual selectors
  - `package:jyotish/nadi.dart` — Nadi leaf prediction engines and services
  - `package:jyotish/panchanga.dart` — Core 5 limbs of time (Tithi, Vara, Nakshatra, Yoga, Karana) and Masa services
  - `package:jyotish/strength.dart` — Shadbala, Bhava Bala, Vimshopak Bala, Graha Avasthas, and Planetary friendship relations
  - `package:jyotish/systems.dart` — Astrological engine systems (Dasha, Ashtakavarga, KP System, Varshapal, Jaimini, Prashna, Argala, Arudha Pada)
  - `package:jyotish/transit.dart` — Planetary movements, Sade Sati, transit events, Gochara Vedha, and Sarvatobhadra Chakra
- **Module Isolation & Safety**: Internal types like `VedhaSeverity` in `sarvatobhadra.dart` are hidden from external exports in `transit.dart` to prevent implementation detail leakage.
- **Tree Shaking Verification Test Suite**: Added a robust test suite (`test/tree_shaking_test.dart`) with 119 unit tests to guarantee clean compilation boundaries, verify correct export counts per module, validate selective import usage, and ensure module isolation.

---

## [2.9.1] - 2026-05-17

### Added
- **Julian Day Helper**: Added `dateTimeToJulianDay` as a public method in `EphemerisService` to allow external consumers to convert timezone-aware Dart `DateTime` objects to high-precision Julian Day floats.

---

## [2.9.0] - 2026-05-16

### Added
- **JSON Serialization**: Full serialization support via `toJson()` across core models (`VedicChart`, `HouseSystem`, `VedicPlanetInfo`, `KetuPosition`, `PlanetPosition`). Deeply nested objects are natively supported for easier cross-isolate processing and caching.
- **Sanskrit Localization (IAST)**:
  - `Planet` enum now includes `sanskritName` (e.g., `Sūrya`, `Candra`).
  - Added `ascendantSignSanskrit` to `HouseSystem`.
  - Added `nakshatraSanskrit` to `PlanetPosition` using proper IAST (e.g., `Āśleṣā`).

### Fixed
- **Jaimini Chara Karakas**: Fixed calculation to include the full 7 or 8 Karaka ranking system (AK, AmK, BK, etc.). Default behavior respects the 8-Karaka scheme. Exposed via `getCharaKarakas()`.
- **Chara Dasha Sub-periods**: Resolved a bug where `levels` parameter was ignored. Chara Dasha now recursively calculates sub-periods (Antardashas) to the requested depth. Mahadasha levels correctly reflect depth `0`.
- **Cleanup**: Removed circular `KPService` imports in configuration flags.

---

## [2.8.0] - 2026-05-02

### Added — Special Muhurta Yogas
Implemented high-precision calculation of specialized Vedic auspicious and repetitive Yogas. These are automatically identified based on the overlap of Weekday, Tithi, and Nakshatra periods.

- **Sarvartha Siddhi Yog**: Weekday + Nakshatra combinations for general success in all activities.
- **Amrit Siddhi Yog**: Highly powerful Weekday + Nakshatra pairings for significant tasks.
- **Guru Pushya Yog**: The "King of Yogas" occurring when Thursday coincides with Pushya Nakshatra.
- **Ravi Pushya Yog**: Highly auspicious timing when Sunday coincides with Pushya Nakshatra.
- **Dwi Pushkar Yog**: Repetitive Yoga (Sun/Tue/Sat + Bhadra Tithi + Dwi-pada Nakshatra) that doubles the result of an event (good or bad).
- **Tri Pushkar Yog**: Repetitive Yoga (Sun/Tue/Sat + Bhadra Tithi + Tri-pada Nakshatra) that triples the result of an event.

#### Updated API
- **`Muhurta` model**: Added `specialYogas` field containing a list of `SpecialYoga` objects active for the day.
- **`MuhurtaService`**: Updated `calculateMuhurta` to optionally accept `tithiPeriods` and `nakshatraPeriods` to enable these calculations.
- **`SpecialYoga`**: New model representing a yoga period with `type`, `startTime`, `endTime`, and `isAuspicious` flag.

---

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
