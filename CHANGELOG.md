# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
- **Graha Maitri Koota**: Was a stub returning 0. Now fully implemented with
  the BPHS natural planetary friendship table (friends/enemies/neutrals for
  each of the 7 traditional planets). Sign lords are looked up per classical
  rules (e.g. Mars rules Aries and Scorpio).
- **Bhakoot Koota**: Dosha check now covers all three problematic inter-sign
  relationships: **2/12, 5/9, and 6/8** (previously only checked for 6/12).
- **Nadi Koota**: Nadi (Adi/Madhya/Antya) now uses correct **cyclic modulo-3**
  grouping (`nakshatraIndex % 3`) instead of the incorrect sequential blocks of
  9 nakshatras.

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
