import '../models/planet.dart';
import '../models/rashi.dart';
import '../models/nadi.dart';
import '../models/vedic_chart.dart';

class NadiService {
  static const int totalNadisPerSign = 150;
  static const int totalNadis = 1800;

  static final Map<int, String> _nadiNames = {
    1: 'Agneya',
    2: 'Ap',
    3: 'Ayu',
    4: 'Mitra',
    5: 'Vara',
    6: 'Vishnu',
    7: 'Vayu',
    8: 'Kuber',
    9: 'Ashwin',
    10: 'Bhuta',
    11: 'Gandha',
    12: 'Jaya',
    13: 'Tva',
    14: 'Sampada',
    15: 'Mridu',
    16: 'Krama',
    17: 'Tandra',
    18: 'Ksham',
    19: 'Harsha',
    20: 'Shiva',
    21: 'Santana',
    22: 'Punya',
    23: 'Pavahana',
    24: 'Madhava',
    25: 'Arka',
    26: 'Soma',
    27: 'Surya',
    28: 'Prabha',
    29: 'Chaya',
    30: 'Shuchi',
    31: 'Sita',
    32: 'Kanya',
    33: 'Kumara',
    34: 'Vasava',
    35: 'Indra',
    36: 'Brihaspati',
    37: 'Savitri',
    38: 'Gayatri',
    39: 'Saraswati',
    40: 'Brahma',
    41: 'Vedhas',
    42: 'Tapomaya',
    43: 'Dharma',
    44: 'Adharma',
    45: 'Shubha',
    46: 'Ashubha',
    47: 'Mangala',
    48: 'Saumya',
    49: 'Bharga',
    50: 'Deva',
  };

  NadiChart calculateNadiChart(VedicChart chart) {
    final moonInfo = chart.getPlanet(Planet.moon);
    final sunInfo = chart.getPlanet(Planet.sun);

    final moonNadi = moonInfo != null
        ? getNadiFromLongitude(moonInfo.longitude)
        : getNadiFromLongitude(0);
    final sunNadi = sunInfo != null
        ? getNadiFromLongitude(sunInfo.longitude)
        : getNadiFromLongitude(0);
    final ascendantNadi = getNadiFromLongitude(chart.ascendant);

    final planetNadis = <Planet, NadiInfo>{};
    for (final entry in chart.planets.entries) {
      planetNadis[entry.key] = getNadiFromLongitude(entry.value.longitude);
    }

    final nadiSeed = _calculateNadiSeed(
      moonInfo?.pada ?? 1,
      moonInfo?.nakshatra ?? 'Ashwini',
    );

    return NadiChart(
      moonNadi: moonNadi,
      sunNadi: sunNadi,
      ascendantNadi: ascendantNadi,
      planetNadis: planetNadis,
      nadiSeed: nadiSeed,
    );
  }

  NadiInfo getNadiFromLongitude(double longitude) {
    final normalizedLong = longitude % 360;
    final nadiNumber = ((normalizedLong / 360) * totalNadis).floor() + 1;
    return _getNadiInfo(nadiNumber);
  }

  NadiInfo _getNadiInfo(int nadiNumber) {
    final nadiIndex = (nadiNumber - 1) % 50;
    final nadiName = _nadiNames[nadiIndex + 1] ?? 'Nadi ${nadiNumber}';
    final signIndex = ((nadiNumber - 1) ~/ 150);
    final positionInSign = ((nadiNumber - 1) % 150);
    final startLongitude = signIndex * 30 + (positionInSign / 150) * 30;
    final endLongitude = startLongitude + (30 / 150);

    return NadiInfo(
      nadiNumber: nadiNumber,
      nadiName: nadiName,
      nadiType: _getNadiType(nadiNumber),
      startLongitude: startLongitude,
      endLongitude: endLongitude,
      rulingPlanet: _getNadiRulingPlanet(nadiNumber),
      element: _getNadiElement(nadiNumber),
      characteristics: _getNadiCharacteristics(nadiNumber),
    );
  }

  NadiType _getNadiType(int nadiNumber) {
    final modulo = nadiNumber % 6;
    return switch (modulo) {
      1 => NadiType.agasthiya,
      2 => NadiType.bhrigu,
      3 => NadiType.saptarshi,
      4 => NadiType.nandi,
      5 => NadiType.bharga,
      _ => NadiType.chandra,
    };
  }

  Planet _getNadiRulingPlanet(int nadiNumber) {
    final modulo = nadiNumber % 9;
    return switch (modulo) {
      1 => Planet.sun,
      2 => Planet.moon,
      3 => Planet.mars,
      4 => Planet.mercury,
      5 => Planet.jupiter,
      6 => Planet.venus,
      7 => Planet.saturn,
      8 => Planet.meanNode,
      _ => Planet.ketu,
    };
  }

  String _getNadiElement(int nadiNumber) {
    final modulo = nadiNumber % 5;
    return switch (modulo) {
      1 => 'Fire',
      2 => 'Earth',
      3 => 'Air',
      4 => 'Water',
      _ => 'Ether',
    };
  }

  List<String> _getNadiCharacteristics(int nadiNumber) {
    final characteristics = <String>[];

    if (nadiNumber % 3 == 1) {
      characteristics.add('Spiritual inclined');
    }
    if (nadiNumber % 5 == 0) {
      characteristics.add('Materialistic');
    }
    if (nadiNumber % 7 == 0) {
      characteristics.add('Balanced');
    }
    if (nadiNumber % 9 == 0) {
      characteristics.add('Mysterious');
    }
    if (nadiNumber % 11 == 0) {
      characteristics.add('Knowledge seeker');
    }
    if (nadiNumber <= 100) {
      characteristics.add('Early life focus');
    } else if (nadiNumber <= 500) {
      characteristics.add('Mid-life focus');
    } else {
      characteristics.add('Late life focus');
    }

    return characteristics;
  }

  int _calculateNadiSeed(int pada, String nakshatra) {
    final nakshatraNumber = _getNakshatraNumber(nakshatra);
    final baseSeed = ((nakshatraNumber - 1) * 4 + pada) % 150;
    return baseSeed + 1;
  }

  int _getNakshatraNumber(String nakshatra) {
    final nakshatraMap = {
      'Ashwini': 1,
      'Bharani': 2,
      'Krittika': 3,
      'Rohini': 4,
      'Mrigashirsha': 5,
      'Ardra': 6,
      'Punarvasu': 7,
      'Pushya': 8,
      'Ashlesha': 9,
      'Magha': 10,
      'Purva Phalguni': 11,
      'Uttara Phalguni': 12,
      'Hasta': 13,
      'Chitra': 14,
      'Swati': 15,
      'Vishakha': 16,
      'Anuradha': 17,
      'Jyeshtha': 18,
      'Mula': 19,
      'Purva Ashadha': 20,
      'Uttara Ashadha': 21,
      'Shravana': 22,
      'Dhanishtha': 23,
      'Shatabhisha': 24,
      'Purva Bhadrapada': 25,
      'Uttara Bhadrapada': 26,
      'Revati': 27,
    };
    return nakshatraMap[nakshatra] ?? 1;
  }

  NadiSeedResult identifyNadiSeed(int nakshatraNumber, int pada) {
    final seedNumber = ((nakshatraNumber - 1) * 4 + pada) % 150 + 1;
    final nadiType = _getNadiType(seedNumber);
    final primaryNadi = _getNadiInfo(seedNumber);

    final relatedNadis = <NadiInfo>[];
    for (var i = -2; i <= 2; i++) {
      if (i == 0) continue;
      final relatedNum = ((seedNumber - 1 + i) % 150).abs() + 1;
      relatedNadis.add(_getNadiInfo(relatedNum));
    }

    return NadiSeedResult(
      seedNumber: seedNumber,
      nadiType: nadiType,
      primaryNadi: primaryNadi,
      relatedNadis: relatedNadis,
    );
  }

  String getNadiInterpretation(int nadiNumber) {
    if (nadiNumber < 1 || nadiNumber > 1800) {
      return 'Invalid Nadi number';
    }

    final signIndex = ((nadiNumber - 1) ~/ 150);
    final positionInSign = ((nadiNumber - 1) % 150);
    final sign = Rashi.values[signIndex];

    final sb = StringBuffer();
    sb.writeln('Nadi ${nadiNumber} - ${sign.name}');
    sb.writeln(
        'Position in sign: ${(positionInSign / 150 * 100).toStringAsFixed(1)}%');
    sb.writeln('');

    if (nadiNumber <= 300) {
      sb.writeln(
          'This nadi indicates early life experiences and foundational karma.');
    } else if (nadiNumber <= 600) {
      sb.writeln(
          'This nadi relates to material pursuits and worldly achievements.');
    } else if (nadiNumber <= 900) {
      sb.writeln('This nadi indicates relationships and partnerships.');
    } else if (nadiNumber <= 1200) {
      sb.writeln('This nadi relates to spiritual evolution and wisdom.');
    } else if (nadiNumber <= 1500) {
      sb.writeln('This nadi indicates transformation and hidden knowledge.');
    } else {
      sb.writeln('This nadi relates to final realizations and liberation.');
    }

    return sb.toString();
  }
}
