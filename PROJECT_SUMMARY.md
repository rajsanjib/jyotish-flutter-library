# Jyotish Library - Project Overview

## 📦 What We've Built

A complete, production-ready Vedic astrology engine for Flutter using Swiss Ephemeris. The library provides high-precision astronomical calculations and a comprehensive suite of Vedic astrology services (Dasha, Shadbala, Ashtakavarga, KP System, Jaimini, etc.).

## 🏗️ Project Structure

```
jyotish/
├── lib/
│   ├── jyotish.dart                              # Main export file
│   └── src/
│       ├── jyotish_core.dart                     # Core API (Singleton)
│       ├── bindings/
│       │   └── swisseph_bindings.dart            # FFI bindings to Swiss Ephemeris
│       ├── models/                               # 30+ Data models
│       │   ├── planet.dart, planet_position.dart
│       │   ├── dasha.dart, panchanga.dart
│       │   ├── shadbala.dart, ashtakavarga.dart
│       │   ├── kp_calculations.dart, jaimini.dart
│       │   └── ... (see src/models for full list)
│       ├── services/                             # 30+ Specialized services
│       │   ├── ephemeris_service.dart            # Core calculations
│       │   ├── dasha_service.dart                # 6+ Dasha systems
│       │   ├── shadbala_service.dart             # 6-fold planetary strength
│       │   ├── panchanga_service.dart            # Classical Vedic calendar
│       │   └── ... (see src/services for full list)
│       └── ...
├── jyotish-js/                                   # JavaScript/TypeScript port (Experimental)
├── native/                                       # Compiled Swiss Ephemeris binaries
├── example/                                      # Demo Flutter app
├── test/                                         # 200+ Automated tests
├── README.md                                      # Documentation & API usage
├── QUICKSTART.md                                  # 10-minute tutorial
├── SETUP.md                                       # Installation & Native Setup
├── CHANGELOG.md                                   # Detailed version history
├── CONTRIBUTING.md                                # Dev workflow
├── LICENSE                                        # MIT License
└── pubspec.yaml                                   # Dependencies
```

## ✨ Key Features Implemented

### 1. **Core Vedic Engine**

- ✅ Swiss Ephemeris FFI integration (all platforms)
- ✅ High-precision planetary position calculations
- ✅ Support for 21 celestial bodies (Planets, Nodes, Asteroids)
- ✅ **Vedic Accuracy (v2.1.0)**: Corrected Tithi names, Paksha logic, and Brahma Muhurta calculations.
- ✅ **Sunrise Boundary**: Corrected Vara (weekday) logic (day starts at sunrise, not midnight).

### 2. **Classical Vedic Systems**

- ✅ **Shadbala**: Complete six-fold planetary strength calculation (Sthana, Dig, Kala, Chesta, Naisargika, Drik).
- ✅ **Ashtakavarga**: Full system including BAV, SAV, Trikona Shodhana, and Ekadhipati Shodhana reductions.
- ✅ **Dasha Systems**: High-precision implementations of:
    - Vimshottari (Mahadasha through Prana levels with millisecond precision)
    - Yogini (36-year cycle)
    - Ashtottari, Chara, Narayana, and Kalachakra dashas.
- ✅ **KP System (Krishnamurti Paddhati)**: Sign/Star/Sub/Sub-Sub lords, significators, and time-varying ayanamsa.
- ✅ **Jaimini Astrology**: Atmakaraka, Karakamsa, and Sign Aspects (Rashi Drishti).

### 3. **Panchanga & Muhurta**

- ✅ High-precision Tithi, Yoga, Karana, and Vara.
- ✅ **Tithi End-Time**: Binary search algorithm to find exact moments when Tithis end.
- ✅ **Auspicious Timings**: Choghadiya, Gowri Panchangam, and Hora Lord calculations.
- ✅ **Inauspicious Periods**: Rahukalam, Gulikalam, and Yamagandam detection.

### 4. **Charts & Predictions**

- ✅ **Varga Charts**: Support for 16+ divisional charts (D1 to D60), including high-precision **D249**.
- ✅ **Varshapal**: Complete Annual Chart (Solar Return) system with Varsha/Maas/Dina/Hora dashas.
- ✅ **Transit Analysis**: Gochara (transits) relative to natal chart, with **Vedha** (obstruction) analysis.
- ✅ **Compatibility**: Full 36-point Guna Milan (all 8 Kootas implemented per BPHS).
- ✅ **Special Transits**: Sade Sati, Dhaiya, and Panchak detection.

### 5. **Developer & Production Ready**

- ✅ **Coordinate Systems**: Tropical & Sidereal (40+ ayanamsas).
- ✅ **Polar Region Support**: Strict validation for Placidus/Koch above the Arctic Circle.
- ✅ **Thread-safe**: Singleton pattern with proper resource lifecycle management.
- ✅ **Serialization**: JSON support for all major data models.
- ✅ **Testing**: 200+ unit tests covering edge cases, DMS conversions, and Vedic logic.

## 🔧 Technical Architecture

### Layer 1: FFI Bindings (`swisseph_bindings.dart`)

- Direct C library interface using `dart:ffi`.
- Platform-specific binary loading and memory management.

### Layer 2: Core Services (`ephemeris_service.dart`, etc.)

- **Ephemeris**: Core planetary coordinates and rise/set timing.
- **Vedic Engine**: Transforms astronomical data into Vedic formats (ayanamsa, houses).
- **Specialized Services**: 30+ services for Shadbala, Dasha, Compatibility, etc.

### Layer 3: Main API (`jyotish_core.dart`)

- Singleton entry point (`Jyotish()`).
- High-level methods like `calculateVedicChart()`, `getVimshottariDasha()`, `getShadbala()`.
- Thread-safe initialization and resource handling.

## 🧪 Testing

Comprehensive test suite (200+ tests) covering:

- ✅ **Accuracy**: Comparative testing against standard Vedic texts.
- ✅ **Edge Cases**: Polar regions, birth at midnight/sunrise, retrograde motion.
- ✅ **Stability**: Null safety, exception handling, and resource leak prevention.

## 🎯 Supported Platforms

| Platform | Status  | Notes                     |
| -------- | ------- | ------------------------- |
| Android  | ✅ Full | ARM64, ARM32, x86, x86_64 |
| iOS      | ✅ Full | ARM64                     |
| macOS    | ✅ Full | ARM64, x86_64             |
| Linux    | ✅ Full | x86_64                    |
| Windows  | ✅ Full | x86_64                    |

## 🛣️ Future Roadmap

- [ ] Chart drawing utilities and SVG export.
- [ ] Astrological interpretation engine (AI-enhanced).
- [ ] Local time zone database integration.
- [ ] More specialized Dasha systems (Jaimini, etc.).
- [ ] Mobile/Web UI component library.

## 💝 Acknowledgments

- **Swiss Ephemeris**: By Astrodienst AG (https://www.astro.com/swisseph/)
- **Flutter Community**: For the amazing framework
- **Contributors**: Everyone who helps improve this library

---

## Summary

You now have a **complete, production-ready Vedic astrology engine** for Flutter with:

✅ **21 celestial bodies** and high-precision astronomical calculations.  
✅ **30+ specialized services** covering Shadbala, Ashtakavarga, KP, Jaimini, Dashas, and more.  
✅ **6+ Dasha systems** including Vimshottari and Yogini.  
✅ **16+ Divisional Charts** including the high-precision D249.  
✅ **Varshapal** (Annual Charts) and Gochara (Transit) analysis.  
✅ **5 platforms** fully supported (Android, iOS, macOS, Linux, Windows).  
✅ **200+ Automated tests** ensuring accuracy and stability.  
✅ **Clean, service-based architecture** and professional documentation.

The library is ready to be published to pub.dev or used in enterprise-scale astrology applications!

---

**Made with ❤️ for the Flutter and Astrology communities** 🌟
