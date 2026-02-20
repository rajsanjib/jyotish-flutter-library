# Jyotish (SV-stark Fork)

> [!NOTE]  
> This project is a **fork** of the original [jyotish-flutter-library](https://github.com/rajsanjib/jyotish-flutter-library). It builds upon the core high-precision Swiss Ephemeris integration and adds significant advanced Vedic astrology features.

A production-ready Flutter library for advanced Vedic astrology calculations using Swiss Ephemeris. Provides high-precision sidereal planetary positions with Lahiri ayanamsa for authentic Jyotish applications.

[![GitHub](https://img.shields.io/badge/GitHub-SV--stark%2Fjyotish--flutter--library--fork-blue?logo=github)](https://github.com/SV-stark/jyotish-flutter-library-fork)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.0.0-blue?logo=flutter)](https://flutter.dev)

## Core Features

✨ **High-Precision Sidereal Calculations**: Uses Swiss Ephemeris with Lahiri ayanamsa for accurate Vedic astrology.

🌍 **Authentic Vedic System**:
- Sidereal zodiac with support for 40+ ayanamsas.
- Geocentric and topocentric calculations.

🪐 **Comprehensive Planet Support**:
- Traditional Vedic planets + Rahu and Ketu.
- Optional outer planets (Uranus, Neptune, Pluto).
- Lunar apogees and asteroids.

## Advanced Vedic Features (Fork Additions)

This fork significantly extends the original library with high-level astrological services:

### Chart Calculations
- **🔮 Varga Charts**: Support for all 16 major divisional charts (D1 to D60) plus D249 (249 subdivisions) for ultra-precise micro-level analysis.
- **⏳ Dasha Systems**: Vimshottari (120y), Yogini (36y), Ashtottari (108y), Kalachakra, Chara, and Narayana Dasha support.

### Panchanga & Time
- **✨ Panchanga**: Tithi, Yoga, Karana, vara, and precise Sunrise/Sunset modules.
- **📅 Masa & Samvatsara**: Lunar months (Amanta/Purnimanta) and 60-year Jupiter cycle.

### Strength Analysis
- **📊 Ashtakavarga**: Full BAV/SAV point system, Trikona Shodhana (reduction), and transit strength analysis.
- **⚖️ Shadbala**: Complete 6-fold planetary strength calculation.
- **🏠 Bhava Bala**: House strength analysis.
- **🎡 Sudarshan Chakra**: Triple-perspective strength analysis from Lagna, Moon, and Sun.

### Special Systems
- **🤝 Planetary Friendship**: Logic for temporary (Tatkalika) and permanent (Naisargika) friendship status.
- **🎯 KP System**: Significators, Sub-Lord, and Sub-Sub-Lord logic with precise KP-specific ayanamsa calculation.
- **🪐 Special Transits**: Automated analysis for Sade Sati, Dhaiya, and Panchak.
- **🧘 Jaimini Astrology**: Atmakaraka, Karakamsa, Arudha Lagna (AL), Upapada (UL), and Chara/Narayana Dashas.
- **❓ Prashna (Horary)**: Arudha calculation (1-249), Sphutas, and Gulika.

### New Features (Latest)
- **📐 House Strength (Vimsopaka Bala)**: Enhanced house strength with divisional chart integration.
- **🔢 Nadi Astrology**: Nadi identification from planetary positions (150 Nadis per sign).
- **👶 Progeny Analysis**: Child prediction based on 5th house, Jupiter, and D7 chart.
- **💑 Marriage Compatibility**: Ashtakoota (36 Guna) matching with Manglik/Nadi/Bhakoot Dosha checks.

### Muhurta
- **⏰ Hora**: Planetary hours calculations.
- **🌅 Choghadiya**: 8 auspicious/inauspicious periods.
- **⚠️ Inauspicious Periods**: Rahukalam, Gulikalam, Yamagandam.

## Usage

For detailed usage examples and code samples for all features including the new fork additions (Vimsopaka Bala, Nadi Astrology, Progeny Analysis, Marriage Compatibility), see [USAGE.md](USAGE.md).

### Quick Start

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

  final chart = await jyotish.calculateVedicChart(
    dateTime: DateTime(1990, 5, 15, 14, 30),
    location: location,
  );

  print('Ascendant: ${chart.ascendantSign}');
  print('Sun: ${chart.getPlanet(Planet.sun)?.zodiacSign}');

  jyotish.dispose();
}
```

**Key Features:**

- Sidereal zodiac with Lahiri ayanamsa
- Whole Sign house system
- 27 Nakshatras with pada divisions
- Multiple Dasha systems (Vimshottari, Yogini, Ashtottari, etc.)
- Divisional charts (D1-D60, D249)
- Ashtakavarga, KP System, Jaimini astrology
- Panchanga, Muhurta, Transit calculations
- **NEW:** House Strength (Vimsopaka Bala), Nadi Astrology, Progeny Analysis, Marriage Compatibility

See [USAGE.md](USAGE.md) for comprehensive examples of all features.

## API Reference

### Main Classes

#### `Jyotish`

The main entry point for the library.

- `initialize({String? ephemerisPath})`: Initialize the library
- `getPlanetPosition(...)`: Calculate a single planet's position
- `getMultiplePlanetPositions(...)`: Calculate multiple planets
- `getAllPlanetPositions(...)`: Calculate all major planets
- `getVara(...)`: Get Vedic Vara (Day Lord) - **Async**
- `getTithiEndTime(...)`: Find precise Tithi end time - **New**
- `dispose()`: Clean up resources

**Abhijit Nakshatra Methods:**
- `getNakshatraWithAbhijit(...)`: Get nakshatra with 28th Abhijit support
- `isInAbhijitNakshatra(...)`: Check if longitude is in Abhijit (6°40' to 10°53'20" Capricorn)
- `getAbhijitBoundaries()`: Get start/end longitudes of Abhijit

**Lunar Month (Masa) Methods:**
- `getMasa(...)`: Calculate lunar month with Amanta/Purnimanta support
- `getAmantaMasa(...)`: Get lunar month using Amanta system (starts from New Moon)
- `getPurnimantaMasa(...)`: Get lunar month using Purnimanta system (starts from Full Moon)
- `getSamvatsara(...)`: Get 60-year Jupiter cycle (Samvatsara) name
- `getMasaListForYear(...)`: Get list of all lunar months for a year

#### `Planet` (enum)

Enumeration of supported celestial bodies.

Available planets:

- `Planet.sun`, `Planet.moon`
- `Planet.mercury`, `Planet.venus`, `Planet.mars`
- `Planet.jupiter`, `Planet.saturn`
- `Planet.uranus`, `Planet.neptune`, `Planet.pluto`
- `Planet.meanNode`, `Planet.trueNode`
- `Planet.chiron`, `Planet.ceres`, etc.

Static methods:

- `Planet.majorPlanets`: Sun through Pluto
- `Planet.traditionalPlanets`: Sun through Saturn
- `Planet.asteroids`: Chiron, Ceres, Pallas, Juno, Vesta

#### `PlanetPosition`

Contains calculated position data.

Properties:

- `longitude`: Ecliptic longitude (0-360°)
- `latitude`: Ecliptic latitude
- `distance`: Distance from Earth in AU
- `longitudeSpeed`: Degrees per day
- `zodiacSign`: Name of zodiac sign
- `positionInSign`: Degrees within sign (0-30°)
- `nakshatra`: Indian lunar mansion name
- `nakshatraPada`: Quarter of nakshatra (1-4)
- `isRetrograde`: Whether planet is in retrograde motion
- `formattedPosition`: Human-readable position string

#### `GeographicLocation`

Represents a location on Earth.

Properties:

- `latitude`: -90 to 90 (North positive)
- `longitude`: -180 to 180 (East positive)
- `altitude`: Meters above sea level

#### `CalculationFlags`

Controls calculation behavior.

Factory constructors:

- `CalculationFlags.defaultFlags()`: Tropical, geocentric
- `CalculationFlags.siderealLahiri()`: Sidereal with Lahiri ayanamsa
- `CalculationFlags.sidereal(SiderealMode)`: Custom sidereal mode
- `CalculationFlags.topocentric()`: Topocentric calculations

#### `SiderealMode` (enum)

Available ayanamsa systems for sidereal calculations.

Popular modes:

- `SiderealMode.lahiri`: Most common in Indian astrology
- `SiderealMode.faganBradley`: Western sidereal astrology
- `SiderealMode.krishnamurti`: KP astrology
- `SiderealMode.raman`: Raman ayanamsa
- 40+ other modes available

#### `NakshatraInfo`

Represents nakshatra information including Abhijit (28th nakshatra).

Properties:
- `number`: Nakshatra number (1-27 for standard, 28 for Abhijit)
- `name`: Nakshatra name (Sanskrit)
- `rulingPlanet`: Planet ruling the nakshatra
- `longitude`: Normalized longitude (0-360°)
- `pada`: Pada or quarter (1-4)
- `isAbhijit`: Whether currently in Abhijit nakshatra
- `abhijitPortion`: Portion through Abhijit (0.0-1.0, 0.0 if not in Abhijit)

Static Properties:
- `nakshatraNames`: List of all 28 nakshatra names
- `nakshatraLords`: List of ruling planets for each nakshatra
- `abhijitStart`: Start longitude of Abhijit (276.6666667°)
- `abhijitEnd`: End longitude of Abhijit (286.6666667°)
- `nakshatraDashaLords`: Map of nakshatra to Vimshottari dasha lords

#### `MasaInfo`

Represents lunar month (Masa) information.

Properties:
- `month`: Lunar month enum (Chaitra through Phalguna)
- `monthNumber`: Month number (1-12)
- `type`: MasaType (amanta or purnimanta)
- `adhikaType`: AdhikaMasaType (none, adhika, nija)
- `sunLongitude`: Sun's longitude in degrees
- `tithiInfo`: Current Tithi information
- `year`: Optional Samvatsara year number
- `isLunarLeapYear`: Whether it's a lunar leap year

Methods:
- `displayName`: Full display name including Adhika prefix if applicable

#### `MasaType` (enum)

Lunar month system types.
- `MasaType.amanta`: Month starts from Amavasya (New Moon) - Southern India, Gujarat
- `MasaType.purnimanta`: Month starts from Purnima (Full Moon) - Northern India

#### `LunarMonth` (enum)

The 12 lunar months in the Indian calendar.
- `LunarMonth.chaitra` through `LunarMonth.phalguna`
- Each month has `sanskrit` and `transliteration` properties

#### `AdhikaMasaType` (enum)

Adhika (extra) Masa status.
- `AdhikaMasaType.none`: Regular lunar month
- `AdhikaMasaType.adhika`: Extra leap month
- `AdhikaMasaType.nija`: Regular month in a year with Adhika

#### `Samvatsara`

Represents the 60-year Jupiter cycle.

Static Methods:
- `getSamvatsaraName(int yearIndex)`: Get Samvatsara name from year index
- `samvatsaraNames`: List of all 60 Samvatsara names (Prabhava to Akshaya)

#### `NodeType` (enum)

Lunar node type for Rahu/Ketu calculations.

- `NodeType.meanNode` - Uses Mean Node (default). This is the average position of Moon's orbit crossing. Preferred by traditional Vedic astrologers.
- `NodeType.trueNode` - Uses True Node. This is the actual position at the exact moment. Preferred by modern Vedic astrologers for greater precision.

Usage:
```dart
// Use True Node instead of Mean Node (default)
final flags = CalculationFlags.withNodeType(NodeType.trueNode);

final chart = await jyotish.calculateVedicChart(
  dateTime: DateTime.now(),
  location: location,
  flags: flags,
);

// Calculate specific planet with True Node
final rahuPosition = await jyotish.getPlanetPosition(
  planet: Planet.trueNode,
  dateTime: DateTime.now(),
  location: location,
);
```

Properties:
- `description`: Human-readable description
- `technicalDescription`: Technical explanation
  - `planet`: Returns the appropriate Planet enum (`Planet.meanNode` or `Planet.trueNode`)
 
#### `DivisionalChartType.d249`

D249 (249 Subdivisions) is a KP micro-level divisional chart that uses **Vimshottari Dasha proportional divisions**, NOT linear equal divisions.

**Important**: D249 is NOT a simple 1/249th division. Each subdivision's span is proportional to the dasha period of its ruling planet.

#### Key Characteristics:

1. **Proportional to Vimshottari Dasha**: Each subdivision's span is proportional to the dasha period of its ruling planet
2. **Total Subdivisions**: 249 = (27 complete cycles × 9 planets) + 6 extra subdivisions
3. **Pattern**: The 9-planet Vimshottari sequence repeats 27 times, with a partial 28th cycle

#### Vimshottari Dasha Proportions:

| Planet (Ruler) | Dash Period | Degree Span | Subdivisions per Sign |
|-----------------|------------|-------------|---------------------|
| Ketu | 7 years | 1.75° | 27 |
| Venus | 20 years | 5.0° | 54 |
| Sun | 6 years | 1.5° | 18 |
| Moon | 10 years | 2.5° | 27 |
| Mars | 7 years | 1.75° | 18 |
| Rahu | 18 years | 4.5° | 54 |
| Jupiter | 16 years | 4.0° | 48 |
| Saturn | 19 years | 4.75° | 48 |
| Mercury | 17 years | 4.25° | 51 |

**Complete Cycles**: 27 × 9 = 243 subdivisions  
**Partial 28th Cycle**: 6 subdivisions (Ketu through Rahu)  
**Total**: 243 + 6 = 249 subdivisions

#### Usage Example:

```dart
// Calculate D249 chart
final d249 = jyotish.getDivisionalChart(
  rashiChart: rashiChart,
  type: DivisionalChartType.d249,
);

// Check which subdivision a planet is in
final sunDivision = kpData.getPlanetSubLord(Planet.sun);
print('Sun in D249 subdivision: ${sunDivision?.subSpan.toStringAsFixed(4)}°');

// Works with both KP ayanamsas (already supported)
final kpOld = await jyotish.calculateKPData(
  natalChart: chart,
  useNewAyanamsa: false, // Old KP ayanamsa
);

final kpNew = await jyotish.calculateKPData(
  natalChart: chart,
  useNewAyanamsa: true, // KP New VP291 ayanamsa
);
```

#### Important Notes:

1. **KP Ayanamsa Support**: Both old and new KP ayanamsas are already supported via `useNewAyanamsa` parameter in `calculateKPData()`
2. **Node Type Compatibility**: Works with both Mean Node and True Node via `CalculationFlags.nodeType`
3. **Precision**: Provides 10-20x more precision than D9 (9 subdivisions) for micro-level analysis

## Error Handling

The library throws specific exception types:

```dart
try {
  final position = await jyotish.getPlanetPosition(...);
} on InitializationException catch (e) {
  print('Failed to initialize: $e');
} on CalculationException catch (e) {
  print('Calculation failed: $e');
} on ValidationException catch (e) {
  print('Invalid input: $e');
} on JyotishException catch (e) {
  print('General error: $e');
}
```

## Example App

Run the example app to see the library in action:

```bash
cd example
flutter run
```

The example app demonstrates:

- Calculating all major planet positions
- Switching between tropical and sidereal zodiac
- Displaying position in multiple formats
- Showing nakshatra and retrograde status

## Advanced Topics

### Custom Ephemeris Path

```dart
await jyotish.initialize(
  ephemerisPath: '/path/to/ephemeris/files',
);
```

### Topocentric vs Geocentric

Geocentric positions are calculated from Earth's center (default).
Topocentric positions are calculated from a specific location on Earth's surface.

```dart
final flags = CalculationFlags(useTopocentric: true);
```

### Understanding Ayanamsa

The ayanamsa is the difference between tropical and sidereal zodiac systems. Different systems use different reference points:

- **Lahiri**: Official ayanamsa of India
- **Fagan-Bradley**: Popular in Western sidereal astrology
- **Krishnamurti**: Used in KP system

Get current ayanamsa value:

```dart
final service = EphemerisService();
await service.initialize();
final ayanamsa = await service.getAyanamsa(
  dateTime: DateTime.now(),
  mode: SiderealMode.lahiri,
);
print('Lahiri Ayanamsa: ${ayanamsa.toStringAsFixed(6)}°');
```

## Performance Considerations

1. **Initialization**: Call `initialize()` once at app startup
2. **Batch Calculations**: Use `getMultiplePlanetPositions()` for multiple planets
3. **Caching**: Consider caching results if querying the same time repeatedly
4. **Resource Management**: Always call `dispose()` when done

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This library is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

Swiss Ephemeris is licensed under GNU GPL v2 or Swiss Ephemeris Professional License.

## Credits

This library uses:

- [Swiss Ephemeris](https://www.astro.com/swisseph/) by Astrodienst AG
- Developed with ❤️ for the Flutter community

## Support

- Issues: [GitHub Issues](https://github.com/SV-stark/jyotish-flutter-library-fork/issues)
- Original Repo: [rajsanjib/jyotish-flutter-library](https://github.com/rajsanjib/jyotish-flutter-library)

## Detailed Fork Additions Summary

For comprehensive usage examples and code samples for all features, see [USAGE.md](USAGE.md).

This fork was created to bridge the gap between low-level astronomical calculations and high-level Vedic astrological analysis. The following modules were added entirely in this version:

### 1. Advanced Predictive Service
- **Vimshottari Dasha**: Full 120-year cycle with 5 levels of depth (Mahadasha to Sukshma Dasha) and refined Rahu/Ketu lordship logic.
- **Yogini Dasha**: 36-year cycle with accurate lord calculation and Nakshatra alignment.
- **Ashtottari Dasha**: 108-year cycle.
- **Kalachakra Dasha**: Zodiacal dasha system.
- **Chara Dasha**: Jaimini's moving dasha.
- **Narayana Dasha**: Based on planetary periods.

### 2. Comprehensive Panchanga
- A complete Indian lunar calendar module providing **Tithi, Yoga, Karana, Vara**, and precise solar times (Sunrise/Sunset/Noon).
- **Corrected Vara**: Day lord now respects the **Sunrise boundary** as per traditional Vedic standards (births between midnight and sunrise use the previous day's lord).
- **Tithi Analysis**: New high-precision API for finding exact Tithi end times.
- **Abhijit Nakshatra**: Support for the 28th intercalary nakshatra.

### 3. Strength & Relationship Systems
- **Shadbala**: Implementation of the complete 6-fold planetary strength system (Shadbala) including positional, directional, temporal, and motional strengths.
- **Vimsopaka Bala**: Enhanced planetary strength from divisional charts (D1, D2, D3, D9, D12, D30).
- **Bhava Bala**: House strength analysis with Kendra/Panaphara/Apoklima categorization.
- **Planetary Relationships**: Automated determination of permanent and temporary friendships used for accurate dignity and strength analysis.

### 4. Mathematical Systems
- **Ashtakavarga**: Automated calculation of Bindus for all 7 planets (BAV) and the total system (SAV), including **Trikona Shodhana** (Trine Reduction) and transit strength analysis.
- **KP System**: Implementation of the Krishnamurti Paddhati, including high-precision significators, cuspal sub-lords, and precise KP ayanamsa formulas.
- **Divisional Charts (Varga)**: Calculations for all 16 major charts (D1-D60) plus D249 (249 subdivisions) with high-precision mapping rules for Saptamsa, Dasamsa, Shashtiamsa (D60), and 249-subdivision micro analysis.

### 5. Transit & Muhurta Analysis
- **Special Transits**: Real-time detection of Sade Sati, Dhaiya, and Panchak.
- **Muhurta Engine**: Daily Hora, Choghadiya, Gowri Panchangam, and inauspicious period (Rahu Kalam/Yamagandam) tracking.
- **Gochara Vedha**: Transit obstruction analysis.

### 6. Lunar Month (Masa) & Time
- **Abhijit Nakshatra**: Full support for the 28th intercalary nakshatra (6°40' to 10°53'20" in Capricorn).
- **Lunar Month (Masa) Calculations**: Complete implementation of both Amanta and Purnimanta lunar month systems.
- **Adhika Masa Detection**: Automatic detection of extra lunar months (leap months).
- **Samvatsara**: Support for the 60-year Jupiter cycle.

### 7. Jaimini Astrology
- **Atmakaraka**: Planet with highest degree.
- **Karakamsa**: Soul planet in Navamsa.
- **Arudha Lagna (AL)**: D2/D12 calculation.
- **Upapada (UL)**: D12 calculation for spouse.
- **Rashi Drishti**: Sign-based aspects.
- **Chara Dasha**: Jaimini's moving dasha system.
- **Narayana Dasha**: Based on house occupancy.

### 8. Horary (Prashna) Astrology
- **Prashna Arudha**: Arudha based on seed number (1-249).
- **Sphutas**: Trisphuta, Chatursphuta, Panchadhyayi, Shadvarga, Hora, Gulika.

### 9. New Advanced Features
- **House Strength (Vimsopaka)**: Enhanced Bhava Bala with divisional chart integration.
- **Nadi Astrology**: Nadi identification from planetary positions (150 Nadis per sign).
- **Progeny Analysis**: Child prediction based on 5th house, Jupiter, D7 chart, and child yogas.
- **Marriage Compatibility**: Ashtakoota (36 Guna) matching with Manglik/Nadi/Bhakoot Dosha checks.

### 10. Mean Node vs True Node (Rahu) Configuration
- **Configurable Node Type**: Full support for switching between Mean Node (traditional Vedic standard) and True Node (modern preference) for Rahu/Ketu calculations.
- **Global Setting via CalculationFlags**: Use `NodeType.meanNode` (default) for traditional calculations or `NodeType.trueNode` for greater precision with actual node positions.

### 11. Lunar Month (Masa) & Abhijit Nakshatra
- **Abhijit Nakshatra**: Full support for the 28th intercalary nakshatra (6°40' to 10°53'20" in Capricorn), including position checking and nakshatra calculation with Abhijit detection.
- **Lunar Month (Masa) Calculations**: Complete implementation of both Amanta and Purnimanta lunar month systems:
  - **Amanta (Amavasyanta)**: Month starts from Amavasya (New Moon). Used in Southern India, Gujarat, and other regions.
  - **Purnimanta (Suklanta)**: Month starts from Purnima (Full Moon). Used in Northern India.
- **Adhika Masa Detection**: Automatic detection of extra lunar months (leap months) in the lunar calendar.
- **Samvatsara**: Support for the 60-year Jupiter cycle (Samvatsara names from Prabhava to Akshaya).

### 12. Mean Node vs True Node (Rahu) Configuration
- **Configurable Node Type**: Full support for switching between Mean Node (traditional Vedic standard) and True Node (modern preference) for Rahu/Ketu calculations.
- **Global Setting via CalculationFlags**: Use `NodeType.meanNode` (default) for traditional calculations or `NodeType.trueNode` for greater precision with actual node positions.
- **Per-Call Flexibility**: Calculate specific charts with different node types without affecting global defaults.
- **Backward Compatible**: Mean Node remains the default to maintain compatibility with existing code and traditional astrologers.

---

Made with ❤️ using Swiss Ephemeris
