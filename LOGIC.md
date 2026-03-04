# Jyotish Library Logic Documentation

This document serves as the technical authority for the `jyotish` library. It details the mathematical formulas, classical Vedic references, and modern implementation standards used for all astrological calculations.

---

## 1. Core Astronomical Foundation

### Swiss Ephemeris Integration
The library utilizes the **Swiss Ephemeris** (SE) for sub-arcsecond precision.
- **Ephemeris Type**: `SEFLG_SWIEPH` (High-precision ephemeris).
- **Coordinate System**: Geocentric ecliptic by default. Topocentric positions (`SEFLG_TOPOCTR`) are calculated when `useTopocentric` is enabled in `CalculationFlags`.
- **Precession Adjustment**: For sidereal speed (Chesta Bala), a 0.01% correction factor is applied to account for the difference between tropical and sidereal motion rates (~50.3" per year).

### Sidereal Conversion (Ayanamsa)
The library converts tropical coordinates to the sidereal frame using precise ayanamsa values.
- **Formula**: `Sidereal_Longitude = (Tropical_Longitude - Ayanamsa + 360) % 360`.
- **Ayanamsa Precision**: Time-varying formulas from SE are used. 
    - *Example*: Lahiri (Chitra Paksha) uses the fixed star Spica (α Virginis) as the anchor (coordinate 180°).
- **KP New Ayanamsa (VP291)**: Used specifically for the KP System, diverging from Lahiri by approximately 6 minutes of arc.

---

## 2. Panchanga (The Five Limbs)

### Tithi (Lunar Day)
- **Mathematical Formula**: `Tithi = floor((Moon_Long - Sun_Long) / 12) + 1`.
- **End-Time Calculation**: Determined using a high-precision binary search (1-minute resolution) to find the exact moment the elongation hits a multiple of 12°.
- **Reference**: *Surya Siddhanta*.

### Vara (Weekday Lord)
- **Logic**: The planetary ruler of the day based on the sequence: Sun, Moon, Mars, Mercury, Jupiter, Venus, Saturn.
- **Vedic Boundary**: The day changes at **local Sunrise**. 
- **Calculation**: If `Birth_Time < Sunrise_Time`, the `Vara` is of the previous solar day.
- **Reference**: *Brihat Parashara Hora Shastra (BPHS)*.

### Nakshatra (Lunar Mansion)
- **Division**: 360° / 27 = 13°20' per Nakshatra.
- **Formula**: `Nakshatra = floor(Moon_Sidereal_Long / (13.333333)) + 1`.
- **Abhijit Nakshatra**: Incorporated for specific rituals and Muhurta (Brahma/Abhijit). Occupies the region between 276°40' and 280°53'20" (the last quarter of Uttarashadha).

### Yoga & Karana
- **Yoga**: `floor((Sun_Long + Moon_Long) / 13.333333) + 1`.
- **Karana**: Half a Tithi (6°). Includes 7 repeating variable karanas and 4 fixed ones (Kimstughna, Shakuni, Chatushpada, Naga) which occur at specific points in the lunar month.

---

## 3. Planetary Strength (Shadbala)

The library implements the complex 6-fold strength system as defined in **BPHS**, following the numerical models of **P.V.R. Narasimha Rao**.

### Sthana Bala (Positional Strength)
1.  **Uchcha Bala**: `(180 - Distance_from_Deep_Exaltation) / 3`. Max = 60 Virupas.
2.  **Saptavargaja Bala**: Cumulative strength across 7 divisional charts (D1, D2, D3, D7, D9, D12, D30).
    - Own Sign: 30 | Friend: 22.5 | Neutral: 15 | Enemy: 3.75 | Great Enemy: 1.875 units.
3.  **Ojayugmarasyamsa**: Based on Odd/Even sign and Navamsa placement for masculine/feminine planets.

### Kala Bala (Temporal Strength)
- **Natonnata Bala**: Day and night strength. Max 60 for Moon/Mars/Saturn at midnight, 60 for Sun/Jupiter/Venus at noon.
- **Ayana Bala**: Strength based on Declination (Kranti). Formula: `(24 ± Declination) / 48 * 60`.
- **Paksha Bala**: Lunar phase strength. Benefics gain near Full Moon; Malefics gain near New Moon.

### Chesta Bala (Motional Strength)
- Derived from the planet's daily velocity relative to its average motion.
- Retrograde planets (`speed < 0`) receive full Chesta Bala (60).

### Functional Phala
- **Ishta Phala**: Benefic results. `sqrt(Uchcha_Bala * Chesta_Bala)`.
- **Kashta Phala**: Malefic results. `sqrt((60 - Uchcha_Bala) * (60 - Chesta_Bala))`.

---

## 4. Divisional Charts (Varga)

The `DivisionalChartService` calculates fractional vargas (D1 to D60) and Nadi Amsa (D150).

### Key Mapping Rules:
- **Hora (D2)**: 15° segments. Odd sign: first 15° = Sun (Leo), second 15° = Moon (Cancer). Even sign: reverse.
- **Drekkana (D3)**: 10° segments. 1st: same; 2nd: 5th from sign; 3rd: 9th from sign.
- **Navamsa (D9)**: 3°20' segments.
    - Fire Signs: Start from Aries.
    - Earth Signs: Start from Capricorn.
    - Air Signs: Start from Libra.
    - Water Signs: Start from Cancer.
- **Trimsamsa (D30)**: Uneven mapping per BPHS. Odd signs: 0-5° Mars, 5-10° Saturn, 10-18° Jupiter, 18-25° Mercury, 25-30° Venus. Even signs: reverse order and lords adjusted.
- **Shashtiamsa (D60)**: 0.5° segments. Odd signs: forward count from current. Even signs: forward count from 9th sign.
- **Nadi Amsa (D150)**: 150 divisions per sign. Odd signs: forward from Aries; Even signs: backward from Pisces.

---

## 5. Ashtakavarga

A system of evaluation based on benefic points (Bindus) contributed by the 7 planets and Ascendant.

### Reductions (Shodhana):
1.  **Trikona Shodhana (Trine Reduction)**: For each planet's BAV, the lowest bindu count among signs in a trine (e.g., Aries-Leo-Sag) is subtracted from all three.
2.  **Ekadhipati Shodhana (Dual-Lordship Reduction)**:
    - Applied to signs owned by the same planet (excluding Sun/Moon signs).
    - If signs are "Odd Foot" (1, 2, 3, 7, 8, 9), subtract smaller from larger.
    - If "Even Foot", take the minimum non-zero value.
3.  **Shodhya Pinda**: The final reduced values are multiplied by **Rashi Multipliers** (1 to 12) and **Graha Multipliers** to find the net planetary strength.

---

## 6. KP System (Krishnamurti Paddhati)

KP is a sub-lord based system emphasizing the "Star Lord" and "Sub-Lord" over the traditional sign-based analysis.

### Technical Parameters:
- **Ayanamsa**: Strict use of **KP New (VP291)** Ayanamsa.
- **Houses**: **Placidus (Semi-arc)** house system is mandatory for accurate Sub-Lord boundaries.
- **249 Sub-Divisions**: Each Nakshatra is divided proportionally to the Vimshottari Dasha years (120-year cycle). If a sub-lord boundary crosses a sign boundary (0°, 30°), it is split into two, totaling 249 divisions.
- **Sub-Sub-Lord (SSL)**: Further refinement dividing the Sub-Lord into 9 further proportional parts.

### Significators (ABCD Grading):
The library assigns significators for each planet/house interaction:
- **Grade A**: Occupants of the star of the house lord. (Strongest)
- **Grade B**: Occupants of the house.
- **Grade C**: Houses owned by the planet (Cusp-based ownership).
- **Grade D**: Houses owned by the planet's Sign Lord.

---

## 7. Advanced Panchang & Muhurta

This section details the newly implemented extended Panchang features, ensuring alignment with both Northern (BPHS) and Southern (Muhurta Chintamani) traditions.

### Samvat & Solar Metadata
- **Vikram Samvat**: Gregorian Year + 57 (changes at Chaitra Shukla Pratipada).
- **Shaka Samvat**: Gregorian Year - 78 (changes at Chaitra Shukla Pratipada).
- **Gujarati Samvat**: Vikram Samvat - 1 (lags behind until Kartiki Pratipada).
- **Ayana**: Based on Tropical Sun Longitude. `long < 180° = Uttarayana`, `long ≥ 180° = Dakshinayana`.
- **Pravishte**: Solar date within the current sidereal Rashi (Sun transit).

### Muhurta Timing Rules
- **Dur Muhurtam (Default)**: Divided into 8 equal parts of daytime (BPHS/Northern). One part per day is designated as the "Dur Muhurta" based on the day's ruler alignment.
- **Dur Muhurtam (South Indian)**: Divided into 15 equal parts (Muhurta Chintamani). Two specific Muhurtas per weekday are designated as inauspicious.
- **Varjyam (Thyajya)**: The "poisonous" portion of a Nakshatra transit. The start time is calculated as `Nakshatra_Start + (Thyajya_Ghati / 60) * Nakshatra_Duration`.

### Astrological Strength (Balam)
- **Chandrabalam**: The strength of the transit Moon relative to the native's Rashi. 
    - *Strong*: 1st, 3rd, 6th, 7th, 10th, 11th from Moon.
    - *Moderate*: 2nd, 5th, 9th.
    - *Weak*: 4th, 8th, 12th.
- **Tarabalam**: Calculated as `(Current_Nakshatra - Birth_Nakshatra + 27) % 9`. 
    - Resulting index maps to 9 Tara types (Janma, Sampat, Vipat, etc).

### Ritual Elements
- **Krishna Paksha Offset**: For ceremonial modulo math, Krishna Paksha Tithis (1-15) are mathematically treated as **16-30** to align with Drik Panchang and textual standards.
- **Agnivasa (Fire Residence)**: `(Tithi + Weekday + 1) % 4`. Result 0/3 = Earth, 1 = Sky, 2 = Underworld.
- **Shivavasa (Shiva's Residence)**: A 7-period rotation based on absolute Tithi.

---

## 8. Deviations & Clarifications

| Feature | Implementation | Standard | Rationale |
| :--- | :--- | :--- | :--- |
| **Rahu/Ketu** | Mean Node | BPHS / Traditional | Default set to Mean Node; True Node available as a flag. |
| **Vara Boundary** | Sunrise | Jyotish Standard | Day lord must change at Sunrise. |
| **Dur Muhurtam** | BPHS (1/8th) | BPHS Default | Set as default for Drik Panchang compatibility; 1/15th available as option. |
| **Ritual Tithis** | 1-30 numbering | Purnimanta/Amanta | Offset added in Krishna Paksha for correct modulo outcomes. |
| **Ishta/Kashta** | sqrt formula | PVR Narasimha Rao | Adopted from Jagannatha Hora model. |

---

## 9. Authorities & Texts

- **BPHS**: *Brihat Parashara Hora Shastra* - Core foundation for Shadbala and Northern Muhurta (8-part).
- **Muhurta Chintamani**: Primary authority for the 15-part Muhurta division used in the South Indian optional method.
- **Kala Prakashika**: Authority for Varjyam and Rahu Vasa calculations.
- **Surya Siddhanta**: Primary astronomical authority for Panchanga logic.
- **KS Krishnamurti / P.V.R. Narasimha Rao**: Modern references for numerical standardization.
