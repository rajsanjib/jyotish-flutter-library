import 'panchanga.dart';

enum MasaType {
  amanta('Amanta', 'Month starts from Amavasya (New Moon)'),
  purnimanta('Purnimanta', 'Month starts from Purnima (Full Moon)');

  const MasaType(this.sanskrit, this.description);
  final String sanskrit;
  final String description;
}

enum LunarMonth {
  chaitra('Chaitra', 'Chaitra'),
  vaishakha('Vaishakha', 'Vaishakha'),
  jyeshtha('Jyeshtha', 'Jyeshtha'),
  ashadha('Ashadha', 'Ashadha'),
  shravana('Shravana', 'Shravana'),
  bhadrapada('Bhadrapada', 'Bhadrapada'),
  ashwin('Ashwin', 'Ashwin'),
  kartika('Kartika', 'Kartika'),
  margashirsha('Margashirsha', 'Margashirsha'),
  pausha('Pausha', 'Pausha'),
  magha('Magha', 'Magha'),
  phalguna('Phalguna', 'Phalguna');

  const LunarMonth(this.sanskrit, this.transliteration);
  final String sanskrit;
  final String transliteration;
}

enum AdhikaMasaType {
  none('No Adhika Masa'),
  adhika('Adhika (Extra) Masa'),
  nija('Nija (Regular) Masa');

  const AdhikaMasaType(this.description);
  final String description;
}

class MasaInfo {
  const MasaInfo({
    required this.month,
    required this.monthNumber,
    required this.type,
    required this.adhikaType,
    required this.sunLongitude,
    required this.tithiInfo,
    this.year,
    this.isLunarLeapYear = false,
  });

  final LunarMonth month;
  final int monthNumber;
  final MasaType type;
  final AdhikaMasaType adhikaType;
  final double sunLongitude;
  final TithiInfo tithiInfo;
  final int? year;
  final bool isLunarLeapYear;

  static const List<LunarMonth> amantaMonthOrder = [
    LunarMonth.chaitra,
    LunarMonth.vaishakha,
    LunarMonth.jyeshtha,
    LunarMonth.ashadha,
    LunarMonth.shravana,
    LunarMonth.bhadrapada,
    LunarMonth.ashwin,
    LunarMonth.kartika,
    LunarMonth.margashirsha,
    LunarMonth.pausha,
    LunarMonth.magha,
    LunarMonth.phalguna,
  ];

  static const List<LunarMonth> purnimantaMonthOrder = [
    LunarMonth.phalguna,
    LunarMonth.chaitra,
    LunarMonth.vaishakha,
    LunarMonth.jyeshtha,
    LunarMonth.ashadha,
    LunarMonth.shravana,
    LunarMonth.bhadrapada,
    LunarMonth.ashwin,
    LunarMonth.kartika,
    LunarMonth.margashirsha,
    LunarMonth.pausha,
    LunarMonth.magha,
  ];

  static LunarMonth getMonthFromSunLongitude(double sunLongitude) {
    final signIndex = (sunLongitude / 30).floor();
    return amantaMonthOrder[signIndex];
  }

  String get displayName {
    final prefix = adhikaType == AdhikaMasaType.adhika ? 'Adhika ' : '';
    final suffix = adhikaType == AdhikaMasaType.nija ? ' (Nija)' : '';
    return '$prefix${month.sanskrit}$suffix';
  }

  @override
  String toString() {
    return 'MasaInfo($displayName, Type: ${type.sanskrit})';
  }
}

/// Hindu seasons (Ritu) - Six-fold division of the year.
enum Ritu {
  /// Vasanta (Spring) - Chaitra, Vaishakha
  vasanta(
    'Vasanta',
    'Spring',
    'Flowering season, new beginnings',
    ['Growth', 'Renewal', 'Beauty'],
    'Earth',
  ),

  /// Grishma (Summer) - Jyeshtha, Ashadha
  grishma(
    'Grishma',
    'Summer',
    'Hot season, peak energy',
    ['Heat', 'Intensity', 'Power'],
    'Fire',
  ),

  /// Varsha (Monsoon) - Shravana, Bhadrapada
  varsha(
    'Varsha',
    'Monsoon',
    'Rainy season, nourishment',
    ['Nourishment', 'Cooling', 'Flow'],
    'Water',
  ),

  /// Sharad (Autumn) - Ashwin, Kartika
  sharad(
    'Sharad',
    'Autumn',
    'Harvest season, maturity',
    ['Harvest', 'Gratitude', 'Balance'],
    'Air',
  ),

  /// Hemanta (Pre-winter) - Margashirsha, Pausha
  hemanta(
    'Hemanta',
    'Pre-winter',
    'Cooling down, preparation',
    ['Preparation', 'Conservation', 'Rest'],
    'Space',
  ),

  /// Shishira (Winter) - Magha, Phalguna
  shishira(
    'Shishira',
    'Winter',
    'Cold season, introspection',
    ['Introspection', 'Wisdom', 'Endings'],
    'Earth',
  );

  const Ritu(
    this.sanskrit,
    this.english,
    this.description,
    this.characteristics,
    this.governingElement,
  );

  final String sanskrit;
  final String english;
  final String description;
  final List<String> characteristics;
  final String governingElement;

  @override
  String toString() => '$sanskrit ($english)';
}

/// Ritu information with details.
class RituInfo {
  const RituInfo({
    required this.ritu,
    required this.masa,
    required this.description,
    required this.characteristics,
    required this.governingElement,
  });

  /// The season
  final Ritu ritu;

  /// The lunar month
  final MasaInfo masa;

  /// Detailed description
  final String description;

  /// Seasonal characteristics
  final List<String> characteristics;

  /// Governing element (Panchabhuta)
  final String governingElement;

  /// Formatted display string
  String get displayString => '${ritu.sanskrit} Ritu - ${masa.displayName}';

  @override
  String toString() => displayString;
}

class Samvatsara {
  const Samvatsara({
    required this.name,
    required this.yearNumber,
    required this.sanskritName,
  });

  final String name;
  final int yearNumber;
  final String sanskritName;

  static const List<String> samvatsaraNames = [
    'Prabhava',
    'Vibhava',
    'Shukla',
    'Pramodoota',
    'Prajothpatti',
    'Aangirasa',
    'Shreemukha',
    'Bhaava',
    'Yuva',
    'Dhaatu',
    'Eeshwara',
    'Bahudhanya',
    'Pramaadi',
    'Vikrama',
    'Vishu',
    'Chitrabhanu',
    'Svabhanu',
    'Taarana',
    'Paarthiva',
    'Vyaya',
    'Sarvajith',
    'Sarvadhaari',
    'Virodhi',
    'Vikrita',
    'Khara',
    'Nandana',
    'Vijaya',
    'Jaya',
    'Manmatha',
    'Durmukhi',
    'Hevilambi',
    'Vilambi',
    'Vikaari',
    'Shaarvari',
    'Plava',
    'Shubhakruth',
    'Shobhakruth',
    'Krodhi',
    'Vishvaavasu',
    'Paraabhava',
    'Plavanga',
    'Keelaka',
    'Saumya',
    'Saadhaarana',
    'Virodhikruth',
    'Paridhawi',
    'Pramaadeecha',
    'Aananda',
    'Raakshasa',
    'Nala',
    'Pingala',
    'Kaalayukthi',
    'Siddharthi',
    'Raudra',
    'Durmathi',
    'Dundubhi',
    'Rudhirodgaari',
    'Raktaakshi',
    'Krodhana',
    'Akshaya',
  ];

  static String getSamvatsaraName(int yearIndex) {
    return samvatsaraNames[yearIndex % 60];
  }
}
