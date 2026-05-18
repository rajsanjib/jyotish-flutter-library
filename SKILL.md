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
- **Planet**: Enum representing Sun, Moon, Mars, Mercury, Jupiter, Venus, Saturn, Rahu, Ketu.
- **Rashi**: Enum representing Aries (1) to Pisces (12).
- **Nakshatra**: 1 to 27 (standard) or 28 (with Abhijit).
- **VedicChart**: Contains all planetary positions, house cusps, and divisional charts.

## 4. Common Tasks & Service Access
| Task | Recommended Method |
|------|-------------------|
| **Panchanga** | `jyotish.calculatePanchanga(dateTime: dt, location: loc)` |
| **Dasha** | `jyotish.getVimshottariDasha(natalChart: chart)` |
| **Muhurta** | `jyotish.calculateMuhurta(date: d, sunrise: sr, sunset: ss, location: l)` |
| **Divisional** | `jyotish.getDivisionalChart(rashiChart: chart, type: DivisionalChartType.d9)` |
| **Special Yogas**| Access `muhurta.specialYogas` for Sarvartha Siddhi, Guru Pushya, etc. |
| **Julian Day** | `ephemerisService.dateTimeToJulianDay(dateTime, timezoneId: tz)` |

## 5. System Differentiator: Traditional vs KP
Crucial for v2.5.0+:
- **Traditional**: Use `CalculationFlags.traditionalist()`. Best for Parashari, Dasha, Shadbala.
- **KP System**: Use `CalculationFlags.kp()`. **Mandatory** for KP Sub-Lords and significators. Throws `StateError` if mixed.

## 6. Performance, Threads, & Tree Shaking
- For batch calculations (e.g., searching periods), use `Async` variants like `getAllPlanetsVimshopakBalaAsync` to avoid blocking the UI thread.
- `EphemerisService` is a singleton; do not re-initialize it unnecessarily.
- **Tree Shaking & Module Imports (v2.10.0+)**: To reduce application compiled sizes, import micro-targeted barrel files instead of the monolithic `package:jyotish/jyotish.dart`. Available barrel modules:
  - `package:jyotish/core.dart` (facade, location, flags, planets, rashis)
  - `package:jyotish/panchanga.dart` (tithi, vara, nakshatra, yoga, karana, masa)
  - `package:jyotish/systems.dart` (dashas, ashtakavarga, KP system, Varshapal, Jaimini, Prashna)
  - `package:jyotish/transit.dart` (movements, Sade Sati, transit events, Gochara Vedha, Sarvatobhadra)
  - `package:jyotish/strength.dart` (Shadbala, Vimshopak, Avasthas, relationships)
  - `package:jyotish/analysis.dart` (charts, divisional charts, compatibility, progeny, aspects)
  - `package:jyotish/astronomy.dart` (ephemeris coordinates, rise/set calculations)
  - `package:jyotish/muhurta.dart` (auspicious times, Horas, Choghadiyas)
  - `package:jyotish/nadi.dart` (nadi prediction services)

## 7. Common Gotchas for Agents
- **Moon Illumination**: v2.1.0 corrected the formula. 0% = New Moon (Amavasya), 100% = Full Moon (Purnima).
- **Brahma Muhurta**: Depends on the *previous day's* sunset. Use `calculateBrahmaMuhurta`.
- **Special Yogas**: Requires Tithi and Nakshatra periods to be passed to `calculateMuhurta` for accurate intersection calculation.
- **Positional Records**: In `calculateMuhurta` parameters, use `(int, DateTime, DateTime)` records. Access fields as `$1`, `$2`, `$3`.

## 8. Reference Data
- **Weekday Numbers**: 0=Sunday, 1=Monday, ..., 6=Saturday.
- **Tithi Numbers**: 1-15 (Shukla), 16-30 (Krishna). 15=Purnima, 30=Amavasya.
- **House Systems**: 'W' (Whole Sign - Default), 'P' (Placidus - Mandatory for KP).

---
*This skill file was automatically generated based on API_REFERENCE.md v2.10.0.*
