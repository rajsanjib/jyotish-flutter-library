# Vedic Astrology Library Comparison: Jyotish (Flutter) vs. PyJHora (Python)

This document provides a detailed, comprehensive comparison between the **Jyotish Flutter Library (SV-stark Fork)** and **PyJHora**, an open-source Python package developed by `naturalstupid`. Both libraries are high-precision Vedic astrology engines leveraging the Swiss Ephemeris, but they serve different ecosystems, architectures, and design paradigms.

---

## 1. Core Project Information & Metadata

| Feature / Metric | Jyotish Flutter Library (SV-stark Fork) | PyJHora (Python) |
| :--- | :--- | :--- |
| **Repository URL** | [SV-stark/jyotish-flutter-library-fork](https://github.com/SV-stark/jyotish-flutter-library-fork) | [naturalstupid/PyJHora](https://github.com/naturalstupid/PyJHora) |
| **Primary Language** | **Dart** | **Python** |
| **Target Environment** | Mobile (iOS/Android), Desktop (Windows/macOS/Linux), Web (Dart/JS) | Desktop (Python environment, PyQt GUI), Server-side scripting, CLI |
| **License** | **MIT License** (Highly permissive for commercial and private closed-source applications) | **GNU AGPL-3.0 License** (Copyleft; requires any network-hosted derivative works to open-source their codebase) |
| **Primary Inspiration** | High-precision Swiss Ephemeris integration for cross-platform Flutter mobile apps. | PVR Narasimha Rao's book *"Vedic Astrology - An Integrated Approach"* and the desktop software *"Jagannatha Hora (JHora)"*. |
| **Dependencies** | `dart:ffi` (Direct C-bindings to Swiss Ephemeris native binaries) | `pyswisseph` (Python bindings for Swiss Ephemeris), `pyqt6` (for GUI components) |
| **User Interface (UI)** | Headless core engine. Provides an example app, but requires developers to build their own UI. | Includes a fully functional **PyQt6-based Desktop GUI** with multiple tab views (`horo_chart_tabs.py`), Panchanga page (`panchangam.py`), calendar view (`vedic_calendar.py`), and compatibility page (`match_ui.py`). |
| **Target Audience** | Mobile & web developers building cross-platform consumer-facing astrology apps. | Researchers, CLI scripting enthusiasts, Python backend developers, and desktop power users. |

---

## 2. Astronomical & Calculation Foundation

| Calculation Area | Jyotish Flutter Library (SV-stark Fork) | PyJHora (Python) |
| :--- | :--- | :--- |
| **Ephemeris Library** | Swiss Ephemeris (high-precision C binary accessed via FFI bindings). | Swiss Ephemeris (high-precision C library accessed via `pyswisseph`). |
| **Coordinates** | Geocentric and topocentric (`SEFLG_TOPOCTR`) support. | Geocentric and topocentric support. |
| **Ayanamsas** | **40+ Ayanamsa systems** supported (Lahiri, Raman, Krishnamurti, Fagan-Bradley, etc.). | **40+ Ayanamsa systems** supported. Default configured to `TRUE_PUSHYA` (V4.7+) to match JHora default configurations. |
| **Lunar Node Types** | Selectable between **Mean Node** (default) and **True Node** (via `NodeType` enum). | Selectable between **True Node** (V4.7+ default matching JHora) and **Mean Node**. |
| **Celestial Bodies** | Supports **21+ bodies** (Traditional Planets, Rahu, Ketu, Outer Planets: Uranus/Neptune/Pluto, Lunar Apogees, Asteroids: Chiron/Ceres/Pallas/Juno/Vesta). | Supports Traditional Planets, Nodes (Mean/True), and optionally filters/includes western outer planets and asteroids. |
| **Precession Correction** | Applied ~0.01% correction factor for sidereal speed (Chesta Bala calculations) to differentiate tropical from sidereal motion. | Custom tuning of ephemeris parameters for aberration, nutation, and light-time reflection to exactly match JHora software outputs. |
| **Timezone & Location** | Manual latitude, longitude, and elevation input. Developers must supply external timezone databases. | Integrated **Place Database** (CSV, Pickle, or SQLite engine options) containing world cities. Applies **automatic Daylight Savings Time (DST)** calculations depending on date/time/place. |

---

## 3. Panchanga & Muhurta Features

| Panchanga Element | Jyotish Flutter Library (SV-stark Fork) | PyJHora (Python) |
| :--- | :--- | :--- |
| **The 5 Limbs** | High-precision Tithi, Nakshatra, Yoga, Karana, Vara. | High-precision Tithi, Nakshatra, Yoga, Karana, Vara. |
| **Vara Boundary** | Strict **Sunrise boundary** (Vara changes at Sunrise, not midnight). | Strict **Sunrise boundary** (with daylight/rise computations). |
| **Tithi End-Time** | Binary search algorithm (1-minute resolution) to determine exact ending moments of Tithis. | Speed-based calculations using Moon/Sun speeds. Old Inverse Lagrange method retained (`_old` suffix) as a fallback option. Supports Adhik Tithi extraction. |
| **Inauspicious Periods** | Rahukalam, Yamagandam, Gulikalam. | Rahukalam, Yamagandam, Gulikalam, Durmuhurtam, Trikaalam. |
| **Auspicious Timings** | Choghadiya, Gowri Panchangam, Hora Lord. | Choghadiya, Gowri Panchangam, Hora Lord, Pushkara Yoga, Aadal Yoga, Vidaal Yoga, Disha Shool, Yogini Vaasa. |
| **Vedic Calendar** | Support for **Amanta & Purnimanta** lunar calendars, Solar calendars, Vikram/Shaka/Gujarati Samvatsara calculations, and 60-year Jupiter cycle (Samvatsara names). | Support for Amanta & Purnimanta systems, Solar calendars (Tamil month methods), **Islamic Hijri Calendar** conversion, and a database-driven multi-lingual Hindu festivals lookup. |
| **Vedic Clock** | **VedicTime** converter (Ghati, Vighati, Lipta, Prana) and interactive **VedicDigitalClock** & CustomPainter-based **VedicAnalogClock** Flutter widgets. | Built-in interactive **Vedic Digital & Analog Clock** widgets. |
| **Ritual Calculations** | **Agnivasa** (Fire Residence: Earth/Sky/Underworld) and **Shivavasa** (Shiva's Residence) calculations for ritual fire ceremonies. | Standard vratha/festival calculations. |
| **Astrological Strengths** | **Chandrabalam** (Moon strength relative to natal chart) and **Tarabalam** (9-Tara mapping). | Nakshatra and special Tara (Janma, Nava, Special Tara) traverse calculations. |

---

## 4. Varga Charts & House Systems

| System / Chart | Jyotish Flutter Library (SV-stark Fork) | PyJHora (Python) |
| :--- | :--- | :--- |
| **Divisional Charts (Vargas)** | Supports **16+ divisional charts** (D1 through D60) based on classical BPHS rules + specialized high-precision **D249** subdivision chart. | Supports standard divisional charts (D1 to D60) matched against JHora calculations. |
| **D60 & D30 Logic** | Implements custom Shashtiamsa (D60) odd/even sign offsets and Trimsamsa (D30) uneven mapping per BPHS rules. | Implements identical BPHS rules verified through integration tests. |
| **House Division Systems (Bhava)** | Supports Whole Sign, Placidus, and Koch systems (with strict polar validation for regions above the Arctic Circle). | Supports a vast array of systems: KN Rao, Parashari, KP, Raman, Sripathi, Placidus, Koch, Porphyrius, Regiomontanus, Campanus, Vehlow, Axial, Topocentric, Alcabitus, Morinus. |
| **Arudhas** | Jaimini Arudha Lagna (AL) and Upapada Lagna (UL) calculations. | Full **Bhava Arudha** longitudes (0-360°) calculation aligned with JHora V8.0 algorithm updates. |

---

## 5. Dasha Systems (Planetary Periods)

| Dasha Feature | Jyotish Flutter Library (SV-stark Fork) | PyJHora (Python) |
| :--- | :--- | :--- |
| **System Diversity** | **6 major Dasha systems**: Vimshottari, Yogini, Ashtottari, Kalachakra, Chara, and Narayana Dashas. | **50+ Dasha systems** implemented, including Vimshottari, Yogini, Ashtottari, Chara, Narayana, Kalachakra, Drig, Padhanadhamsa, Sudharsana Chakra, Panchasvara, Rashmi, Raashiyanka, Ashtakavarga, Nakshathra Dhasa Progression, Chathuvidha Utthara, etc. |
| **Dasha Depth** | Vimshottari calculated with millisecond-precision down to Prana/Deha levels (Maha -> Bhukti -> Antara -> Prana -> Deha). | Generates periods down to Dehaantara/Deha level for all dashas using selectable Dasha Year definitions (True/Mean Sidereal, True/Mean Tropical, Lunar, Savana, Gregorian). |
| **Custom Methods** | Standard BPHS methods. | Offers multiple algorithm variations for specific dashas (e.g., 2 Drig methods, 3 Padhanadhamsa methods, 3 Chara methods) to match different commentaries. |

---

## 6. Vedic Strength Systems

| Strength Metric | Jyotish Flutter Library (SV-stark Fork) | PyJHora (Python) |
| :--- | :--- | :--- |
| **Shadbala** | Complete **six-fold planetary strength** calculation: Sthana (Positional), Dig (Directional), Kala (Temporal), Chesta (Motional), Naisargika (Natural), and Drik (Aspectual) Bala. Implemented per BPHS models. | Classical Shadbala calculation. Matches standard book examples (BV Raman & VP Jain), but notes minor deviations from JHora desktop software outputs. |
| **Bhava Bala** | House strength calculation based on Bhavas. | Bhava Bala calculation. |
| **Ashtakavarga** | Complete BAV, SAV, Trikona Shodhana (Trine Reduction), and Ekadhipati Shodhana (Dual-Lordship Reduction) to compute final **Shodhya Pinda** values. | Full Ashtakavarga calculations, trine reduction, and dual-lordship reductions. Supports experimental Ashtakavarga Dasha systems. |
| **Sudarshan Chakra** | Triple-perspective strength analysis (Lagna, Moon, Sun perspectives). | Sudarshan Chakra calculations. |
| **Special Strength** | **Vimsopaka Bala** (planetary strength across divisional charts) and **Planetary Friendship** logic (Tatkalika + Naisargika). | Planetary relationship tables matching JHora formats (with minor differences). |

---

## 7. Specialized Vedic Systems

| Specialized Feature | Jyotish Flutter Library (SV-stark Fork) | PyJHora (Python) |
| :--- | :--- | :--- |
| **KP System** | Direct support for **Sign/Star/Sub/Sub-Sub Lords** for planets and houses, planetary significators (Grade A-D), Placidus house alignment, and KP-specific ayanamsa. | Placidus/KP house division calculations. Does not emphasize sub-lord grading/significators UI natively. |
| **Jaimini Astrology** | Calculates Jaimini Karakas (Atmakaraka through Kalakaraka), Karakamsa, Sign Aspects (Rashi Drishti), and Chara/Narayana Dashas. | Jaimini Arudhas, Sign Aspects, and custom Jaimini-based Dasha configurations (Chara, Drig, Padhanadhamsa). |
| **Nadi Astrology** | **Nadi identification** based on planetary positions (150 Nadis mapped per zodiac sign). | Not natively supported. |
| **Progeny Analysis** | Child prediction logic based on 5th house dynamics, Jupiter strength, and D7 divisional chart factors. | Not natively supported. |
| **Compatibility (Matchmaking)** | Complete **36-point Guna Milan** (Ashtakoota) calculation including specific dosha checks (Manglik Dosha, Nadi Dosha, Bhakoot Dosha overrides). | Star-based marriage compatibility matching (`match_ui.py`) with support for Minimum Tamil Porutham rules. |
| **Transits & Predictions** | Natal-relative Gochara (Transit) analysis including **Vedha (obstruction)** calculations. Specialized detection for Sade Sati, Dhaiya, and Panchak transits. | Transit calculations, planet entry dates, nakshatra entry, and planet-pair conjunction tracking. |
| **Prashna (Horary)** | Arudha calculations (1-249 grid), Sphutas (Prana, Deha, Mrityu), and Gulika longitude. | Arudha computations and core Prashna metrics. |
| **Eclipses** | **EclipseService** predicts next N solar/lunar eclipses (globally or locally visible at observer coordinates) with full contact timings and magnitudes. | **Dedicated Eclipse Module** predicts Solar and Lunar eclipses (Total, Partial, Annular, Penumbral), Local/Global visibility, and maximum eclipse location tracking. |

---

## 8. Developer Experience & Production Readiness

| Aspect | Jyotish Flutter Library (SV-stark Fork) | PyJHora (Python) |
| :--- | :--- | :--- |
| **JSON Serialization** | Native JSON serialization (`toJson` / `fromJson`) implemented across 30+ core data models for API integration. | Custom file configurations saved as `.ini` or `.json`, but lacks standardized out-of-the-box model serialization. |
| **Thread-Safety** | Clean singleton pattern (`Jyotish()`) utilizing thread-safe resource initialization and safe disposal of underlying Swiss Ephemeris FFI memory pointers. | Python module structure. Memory footprint was highly optimized in recent versions (switching from Pandas to CSV for database lookups). |
| **Build Optimization** | **Tree-Shaking Support**: Refactored into **9 isolated barrel files** (e.g. `core.dart`, `muhurta.dart`, `transit.dart`), allowing Flutter compiler to strip unused parts of the library to reduce app size. | Traditional Python package structure. No native tree-shaking; entire package must be installed. |
| **Test Coverage** | **200+ unit tests** covering DMS conversions, polar edge cases, and core astrological formulas. | **7,600+ unit tests** (`jhora.tests.pvr_tests`) verifying calculations against examples in PVR Narasimha Rao's book. |
| **Platform Portability** | Runs natively across **iOS, Android, macOS, Linux, and Windows** via Flutter/Dart FFI compilation. Experimental JavaScript port (`jyotish-js`) is also present. | Runs on any platform supporting Python 3 and PyQt6 (primarily Windows, macOS, Linux desktop/server). Difficult to run natively in mobile/browser environments. |

---

## Summary & Recommendations

### Choose **Jyotish Flutter Library** if:
* You are building a **mobile application (iOS/Android)** or a cross-platform desktop application using Flutter.
* You need a highly permissive **MIT License** for commercial or closed-source app-store publications.
* You want **production-ready JSON models** that integrate seamlessly with REST APIs or local SQLite databases in mobile apps.
* App bundle size matters to you: the library's **tree-shaking barrel structure** ensures your final app binary is as lightweight as possible.
* You are building features involving **Nadi Astrology, Progeny Analysis, or deep KP System Sub-Lords**.

### Choose **PyJHora** if:
* You are writing **Python scripts, Jupyter notebooks, or server-side tools** for research and data analysis.
* You need access to an **unmatched selection of Dasha systems (50+)** and customizable year durations (tropical, lunar, savana, etc.).
* You want a **ready-made desktop GUI** out of the box to compute and display charts without writing UI code.
* You need a library with a **built-in cities database** that automatically manages global coordinates and Daylight Savings Time (DST).
* You are studying or reproducing calculations exactly as described in **PVR Narasimha Rao's book and Jagannatha Hora software**, verified by over 7,600 test cases.
