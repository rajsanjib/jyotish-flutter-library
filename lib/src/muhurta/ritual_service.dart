import 'package:jyotish/src/panchanga/panchanga.dart';
import 'package:jyotish/src/muhurta/ritual_elements.dart';

/// Service for calculating ceremonial and astrological ritual elements.
class RitualService {
  /// Calculates the general ritual elements for a day.
  RitualElements calculateRitualElements({
    required Panchanga panchanga,
  }) {
    // Use 1-30 numbering for rituals (Shukla 1-15, Krishna 16-30)
    // tithiNumber in Panchanga is already 1-30.
    int tithiNumber = panchanga.tithi.number;

    final nakshatraNumber = panchanga.nakshatra.number; // 1-27
    final weekday = panchanga.vara.weekday; // 0-6

    // Homahuti calculation based on Tithi
    HomahutiLevel homahuti;
    if (const [1, 2, 3, 5, 7, 10, 11, 13].contains(tithiNumber) ||
        const [16, 17, 18, 20, 22, 25, 26, 28].contains(tithiNumber)) {
      homahuti = HomahutiLevel.siddha;
    } else if (const [4, 6, 8, 9, 12, 14, 15].contains(tithiNumber) ||
        const [19, 21, 23, 24, 27, 29, 30].contains(tithiNumber)) {
      homahuti = HomahutiLevel.inauspicious;
    } else {
      homahuti = HomahutiLevel.auspicious;
    }

    // Agnivasa (Fire Residence)
    // Formula: (Tithi Number + Weekday Number (Sun=1) + 1) mod 4
    final modifiedWeekday = weekday + 1;
    final agniVal = (tithiNumber + modifiedWeekday + 1) % 4;
    String agnivasa;
    if (agniVal == 0 || agniVal == 3) {
      agnivasa = 'Earth (Auspicious)';
    } else if (agniVal == 1) {
      agnivasa = 'Sky (Inauspicious)';
    } else {
      agnivasa = 'Underworld (Inauspicious)';
    }

    // Shivavasa (Shiva's Residence)
    // Standard 7-day cycle based on Tithi (1-30)
    final shivaGroups = [
      'Mount Kailash (Auspicious)',
      'With Gauri (Auspicious)',
      'Mount Nandi (Auspicious)',
      'In Assembly (Neutral)',
      'Eating (Inauspicious)',
      'Playing (Inauspicious)',
      'Cremation Ground (Inauspicious)'
    ];
    // Formula: (Tithi - 1) % 7 maps 1, 8, 15, 22, 29 to Kailash; 2, 9, 16, ... to Gauri
    final shivavasa = shivaGroups[(tithiNumber - 1) % 7];

    // Kumbha Chakra
    // Simplified calculation based on Nakshatra and week day
    final kumbhaVal = (nakshatraNumber + weekday) % 4;
    KumbhaChakraLevel kumbhaChakra;
    switch (kumbhaVal) {
      case 0:
        kumbhaChakra = KumbhaChakraLevel.excellent;
        break;
      case 1:
        kumbhaChakra = KumbhaChakraLevel.good;
        break;
      case 2:
        kumbhaChakra = KumbhaChakraLevel.neutral;
        break;
      default:
        kumbhaChakra = KumbhaChakraLevel.bad;
    }

    return RitualElements(
      homahuti: homahuti,
      agnivasa: agnivasa,
      shivavasa: shivavasa,
      kumbhaChakra: kumbhaChakra,
    );
  }
}
