# Jyotish Mobile App Example

A complete Flutter mobile application demonstrating the Jyotish library for Vedic astrology calculations.

## Features

✨ **Birth Chart Calculator**

- Calculate planetary positions for any date, time, and location
- Sidereal (Vedic) calculations with Lahiri ayanamsa
- Display all 9 planets with nakshatras and house positions

🌍 **Location Selection**

- Built-in database of major cities worldwide
- Custom location input (latitude/longitude)
- GPS location support (coming soon)

📅 **Date & Time Picker**

- Easy date selection
- Time zone support
- Current time quick select

📊 **Vedic Chart Display**

- Traditional Vedic chart layout (South Indian style)
- Planetary positions with degrees and nakshatras
- House cusps and ascendant (Lagna)
- Rahu and Ketu positions

🎨 **Beautiful UI**

- Material Design 3
- Dark mode support
- Responsive layout for all screen sizes
- Smooth animations

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio or Xcode (for mobile development)
- A physical device or emulator

### Installation

1. **Clone or navigate to the example app**:

   ```bash
   cd /Users/sanjibacharya/Developer/jyotish/example
   ```

2. **Get dependencies**:

   ```bash
   flutter pub get
   ```

3. **Run on device/emulator**:
   ```bash
   flutter run
   ```

## Building for Production

### Android

1. **Build APK**:

   ```bash
   flutter build apk --release
   ```

   Output: `build/app/outputs/flutter-apk/app-release.apk`

2. **Build App Bundle** (for Play Store):

   ```bash
   flutter build appbundle --release
   ```

   Output: `build/app/outputs/bundle/release/app-release.aab`

3. **Install on device**:
   ```bash
   flutter install
   ```

### iOS

1. **Build iOS app**:

   ```bash
   flutter build ios --release
   ```

2. **Open in Xcode**:

   ```bash
   open ios/Runner.xcworkspace
   ```

3. **Archive and distribute** through Xcode

## Using the Helper Script

A convenient build script is provided at the root level:

```bash
cd /Users/sanjibacharya/Developer/jyotish
./build_app.sh
```

This script provides an interactive menu to:

- Build Android APK (Debug/Release)
- Build Android App Bundle
- Build iOS
- Run on device
- Run tests
- Check for issues

## Project Structure

```
example/
├── lib/
│   └── main.dart              # Main app entry point
├── android/                   # Android-specific files
├── ios/                       # iOS-specific files
├── assets/                    # App assets (icons, ephemeris data)
└── pubspec.yaml              # Dependencies
```

## Key Features Implementation

### 1. Planetary Position Calculation

```dart
final jyotish = Jyotish();
await jyotish.initialize();

final position = await jyotish.getPlanetPosition(
  planet: Planet.sun,
  dateTime: DateTime.now(),
  location: GeographicLocation(latitude: 27.7172, longitude: 85.3240),
);

print('Sun is at ${position.formattedPosition}');
print('Nakshatra: ${position.nakshatra}');
```

### 2. Complete Vedic Chart

```dart
final chart = await jyotish.calculateVedicChart(
  dateTime: birthDateTime,
  location: birthLocation,
);

// Access planets
for (final planetInfo in chart.planets.entries) {
  print('${planetInfo.key.displayName}: ${planetInfo.value.position.formattedPosition}');
  print('House: ${planetInfo.value.house}');
  print('Dignity: ${planetInfo.value.dignity}');
}

// Access houses
print('Ascendant: ${chart.ascendantSign}');
for (var i = 0; i < 12; i++) {
  print('House ${i + 1}: ${chart.houses.cusps[i]}°');
}
```

### 3. UI Components

The example app includes reusable components:

- Planet position card
- Vedic chart wheel widget
- Date/time picker
- Location selector

## Customization

### Adding Your Own Features

1. **Dasha Calculations** (Planetary Periods)
2. **Transit Predictions**
3. **Compatibility Matching**
4. **Muhurta (Auspicious Timing)**
5. **Panchang (Daily Calendar)**

### Styling

Modify `ThemeData` in `main.dart`:

```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.light,
  ),
  useMaterial3: true,
),
```

## Native Library Setup

### Android

The app automatically loads the Swiss Ephemeris library. If you encounter issues:

1. Place compiled `.so` files in:
   ```
   android/app/src/main/jniLibs/
   ├── arm64-v8a/libswisseph.so
   ├── armeabi-v7a/libswisseph.so
   ├── x86/libswisseph.so
   └── x86_64/libswisseph.so
   ```

### iOS

1. Add the framework to `ios/Frameworks/`
2. Update Xcode project to embed the framework
3. The library will be automatically loaded

### Ephemeris Data

The app needs Swiss Ephemeris data files. Options:

1. **Bundle with app** (increases app size):

   - Add files to `assets/ephe/`
   - Update `pubspec.yaml` to include assets

2. **Download on first launch** (smaller app size):
   - Implement a download manager
   - Store in app's documents directory

## Testing

Run tests from the example directory:

```bash
flutter test
```

Or run integration tests on a real device:

```bash
flutter test integration_test/
```

## Troubleshooting

### Common Issues

1. **Swiss Ephemeris library not found**

   - Ensure native libraries are in the correct folders
   - Check that library loading code uses correct paths
   - For iOS, use `DynamicLibrary.process()`

2. **Calculation errors**

   - Verify ephemeris data files are included
   - Check that the ephemeris path is correct
   - Ensure date is within valid range (typically 3000 BC - 3000 AD)

3. **UI not responsive**

   - Use `FutureBuilder` for async calculations
   - Show loading indicators during calculations
   - Consider caching frequently used calculations

4. **App size too large**
   - Use `--split-per-abi` for Android builds
   - Bundle only essential ephemeris files
   - Enable code minification and obfuscation

## Performance Tips

1. **Initialize once**: Initialize Jyotish library once in app lifecycle
2. **Cache results**: Store calculated charts to avoid recalculation
3. **Use isolates**: For heavy calculations, use Flutter isolates
4. **Lazy loading**: Load ephemeris data only when needed

## Publishing

See the [PUBLISHING_GUIDE.md](../PUBLISHING_GUIDE.md) for detailed instructions on:

- Preparing your app for release
- Creating app icons and splash screens
- Signing and building
- Publishing to Play Store and App Store

## Support

For issues or questions:

- Library issues: https://github.com/yourusername/jyotish/issues
- Example app: Create a discussion in the repository

## License

This example app follows the same license as the Jyotish library (MIT).

## Credits

- Swiss Ephemeris by Astrodienst AG
- Flutter by Google
- Vedic Astrology calculations based on traditional Jyotish principles
# jyotish-flutter-library
