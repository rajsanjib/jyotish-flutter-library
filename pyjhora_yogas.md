# PyJHora Yogas: Comprehensive Catalog & Rules

This catalog details all the 320+ astrological yogas, rules, and mathematical criteria implemented in the **PyJHora** Python library.

## Categories Overview
- **Chandra Yogas (Moon-based)**: Combinations formed around the Moon (Sunapha, Anapha, etc.).
- **Ravi Yogas (Sun-based)**: Combinations formed around the Sun (Vesi, Vosi, etc.).
- **Pancha Mahapurusha Yogas**: Special combinations of Mars, Mercury, Jupiter, Venus, and Saturn in Quadrants and Own/Exaltation signs.
- **Nabhasa Yogas**: Mathematical layout-based combinations of all planets in specific signs/houses.
- **Raja Yogas**: Combinations of quadrant (Kendras) and trine (Trikonas) lords that grant power, fame, and status.
- **Dhana Yogas (Wealth)**: Combinations of houses and planet lords indicating wealth and financial prosperity.
- **Daridra Yogas (Poverty)**: Inauspicious combinations that obstruct wealth and bring difficulties.
- **Daily Panchanga & Nitya Yogas**: Solar-Lunar daily Nitya yogas (27), Anandadi Nakshatra-Weekday yogas (28), and Tamil Muhurta yogas (8).
- **Progeny, Longevity, and Other Natal Yogas**: Special planetary alignments for specific life areas like children, health, house, and vehicles.

---

## Table of Contents
- [Chandra Yogas (Moon-based)](#chandra-yogas-moon-based)
- [Daily Panchanga & Muhurta Yogas](#daily-panchanga--muhurta-yogas)
- [Daily Panchanga & Nitya Yogas](#daily-panchanga--nitya-yogas)
- [Daridra Yogas (Poverty)](#daridra-yogas-poverty)
- [Dhana Yogas (Wealth)](#dhana-yogas-wealth)
- [Longevity & Health Yogas](#longevity--health-yogas)
- [Nabhasa Yogas](#nabhasa-yogas)
- [Other Natal Yoga](#other-natal-yoga)
- [Pancha Mahapurusha Yogas](#pancha-mahapurusha-yogas)
- [Progeny Yogas (Children)](#progeny-yogas-children)
- [Raja Yogas](#raja-yogas)
- [Ravi Yogas (Sun-based)](#ravi-yogas-sun-based)

---

## Chandra Yogas (Moon-based)

Total yogas in this category: **11**

### Adhi Yoga

- **PyJHora Function/Key**: `adhi_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Natural benefics occupy 6th, 7th and 8th from Moon
- **Effects/Benefits**: You may become a king or a minister or an army chief, depending on the strength of the planets involved
- **Notes/Reference**: BVR-7 Adhi Yoga - natural benefics occupy 6th, 7th and 8th from Moon,

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-7 Adhi Yoga - natural benefics occupy 6th, 7th and 8th from Moon, """
    """ 
        NOTE: Mercury is treated as natural benefics if alone or with Jupiter and/or Venus
        Moon is not considered here because tithi information is not passed
        If moon is to be considered use adhi_yoga(jd,place)
    """
    # AND is used to check ALL NATURAL BENEFICS are in 6 or 7 or 8 from moon
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    yoga_houses = [const.HOUSE_6,const.HOUSE_7,const.HOUSE_8]
    houses_from_moon = [(p_to_h[const.MOON_ID]+mh)%12 for mh in yoga_houses]
    if natural_benefics is not None:
        _natural_benefics = natural_benefics
    else:
        _natural_benefics = const.natural_benefics
    if _is_mercury_benefic(chart_1d):
        _natural_benefics += [const.MERCURY_ID] 
    return all(p_to_h[pid] in houses_from_moon for pid in _natural_benefics)
```

---

### Anaphaa Yoga

- **PyJHora Function/Key**: `anaphaa_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: There are planets other than Sun in the 12th house from Moon
- **Effects/Benefits**: You will become a king with good looks. Your body is likely free from disease. You are a person of character and have great reputation. You are surrounded by comforts.
- **Notes/Reference**: BVR-3 If there are planets other than Sun in the 12th house from Moon, this yoga is present.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-3 If there are planets other than Sun in the 12th house from Moon, this yoga is present. """ 
    yoga_planet = const.MOON_ID; excluded_planet = const.SUN_ID
    house_from_yoga_planet = const.HOUSE_12
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    yoga_house = (p_to_h[yoga_planet] + house_from_yoga_planet) % 12
    yoga_house_planets = planets_in_raasi(yoga_house,p_to_h) # V4.8.0
    planet_ids = [int(p) for p in yoga_house_planets if p!='' and p != const._ascendant_symbol]
    return (len(planet_ids) >= 1) and (excluded_planet not in planet_ids)
```

---

### Ardha Chandra Yoga

- **PyJHora Function/Key**: `ardha_chandra_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All the planets occupy the 7 signs starting from a panapara or an apoklima.
- **Effects/Benefits**: One born with this yoga becomes an army chief. This person has a good physique. Kings like this person. This person is strong and possesses gems, gold and many ornaments. Ardha Chandra means half-Moon.
- **Notes/Reference**: BVR-79 Ardha Chandra Yoga (strict):
      - All seven visible planets (Sun..Saturn) are confined to a span of
        seven consecutive houses that STARTS from a non-Kendra (Panapara or Apoklima),
      - AND each of those seven houses is occupied (none empty).
    Returns:
      True if Ardha Chandra Yoga is present per strict definition, else False.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    BVR-79 Ardha Chandra Yoga (strict):
      - All seven visible planets (Sun..Saturn) are confined to a span of
        seven consecutive houses that STARTS from a non-Kendra (Panapara or Apoklima),
      - AND each of those seven houses is occupied (none empty).
    Returns:
      True if Ardha Chandra Yoga is present per strict definition, else False.
    """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    asc_house = p_to_h[const._ascendant_symbol]  # 0..11
    # Panaparas (succedents): 2, 5, 8, 11
    # Apoklimas (cadents): 3, 6, 9, 12 (=> 0 in 0-index system)
    starting_offsets = [
        const.HOUSE_2, const.HOUSE_5, const.HOUSE_8, const.HOUSE_11,  # panaparas
        const.HOUSE_3, const.HOUSE_6, const.HOUSE_9, const.HOUSE_12   # apoklimas
    ]
    # Precompute house -> visible planets for occupancy checks
    house_to_visible = {h: set() for h in range(12)}
    for pid in SUN_TO_SATURN:
        h = p_to_h.get(pid)
        if h is not None:
            house_to_visible[h].add(pid)
    # Try each allowed starting offset
    for offset in starting_offsets:
        start_house = (asc_house + offset) % 12
        span7_list = [(start_house + i) % 12 for i in const.SUN_TO_SATURN]
        span7_set = set(span7_list)
        # 1) Confinement: every visible planet must lie within this span
        all_in_span = all(p_to_h.get(pid) in span7_set for pid in SUN_TO_SATURN)
        if not all_in_span:
            continue
        # 2) Occupancy: each house in the span must have at least one visible planet
        all_occupied = all(len(house_to_visible[h]) > 0 for h in span7_list)
        if all_occupied:
            return True
    return False
```

---

### Chandra Mangala Yoga

- **PyJHora Function/Key**: `chandra_mangala_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Moon and Mars are together (in one sign).
- **Effects/Benefits**: You are worldly wise and materially successful. You may earn money through unscrupulous means. You may treat mother or other women badly.
- **Notes/Reference**: BVR-6 Chandra-Mangala Yoga - Moon and Mars are together (in one sign).

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-6 Chandra-Mangala Yoga - Moon and Mars are together (in one sign). """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    return p_to_h[const.MARS_ID]==p_to_h[const.MOON_ID]
```

---

### Duradhara Yoga

- **PyJHora Function/Key**: `duradhara_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: There are planets other than Sun in the 2nd and 12th houses from Moon.
- **Effects/Benefits**: You will enjoy many pleasures. You are charitable. You will wealth and vehicles. You will have good servants.
- **Notes/Reference**: BVR-4 Sunaphaa/Duradhara/Dhuradhara Yoga - There is a planet other than Sun in the 2nd and 12th house from Moon.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-4 Sunaphaa/Duradhara/Dhuradhara Yoga - There is a planet other than Sun in the 2nd and 12th house from Moon. """
    return sunaphaa_yoga(chart_1d) and anaphaa_yoga(chart_1d)
```

---

### Kemadruma Yoga

- **PyJHora Function/Key**: `kemadruma_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: There are no planets other than Sun in the 1st, 2nd and 12th houses from Moon and there are no planets other than Moon in the quadrants from lagna
- **Effects/Benefits**: You are unlucky, bereft of intelligence and learning and afflicted by poverty and trouble. This bad yoga kills the results of other good yogas in the chart, especially Chandra yogas (if any). You have to work hard and succeed through great efforts.
- **Notes/Reference**: BVR-5 Kemadruma Yoga:
    - No planets other than Sun in the 1st, 2nd, and 12th houses from Moon
      (i.e., in those three houses, allowed occupants among planets are Moon and Sun only; emptiness is also fine).
    - No planets other than Moon in the quadrants (1, 4, 7, 10) from lagna
      (i.e., in those four houses, allowed among planets is Moon only; emptiness is also fine).

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    BVR-5 Kemadruma Yoga:
    - No planets other than Sun in the 1st, 2nd, and 12th houses from Moon
      (i.e., in those three houses, allowed occupants among planets are Moon and Sun only; emptiness is also fine).
    - No planets other than Moon in the quadrants (1, 4, 7, 10) from lagna
      (i.e., in those four houses, allowed among planets is Moon only; emptiness is also fine).
    """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    # Read key anchors
    moon_house = p_to_h[const.MOON_ID]
    lagna_house = p_to_h[const._ascendant_symbol]
    # --- Condition 1: 1st, 2nd, 12th from Moon ---
    houses_from_moon = [(moon_house + off) % 12 for off in (const.HOUSE_1, const.HOUSE_2, const.HOUSE_12)]
    # Collect *planets only* (exclude ascendant symbol)
    planets_in_moon_zone = [p for p, h in p_to_h.items() if p in SUN_TO_KETU and h in houses_from_moon]
    # Allowed: Moon and Sun only
    ky1 = all(p in (const.MOON_ID, const.SUN_ID) for p in planets_in_moon_zone)
    # --- Condition 2: Quadrants from Lagna ---
    quadrants = house.quadrants_of_the_raasi(lagna_house)  # [lagna, lagna+3, lagna+6, lagna+9] % 12
    planets_in_quadrants = [p for p, h in p_to_h.items() if p in SUN_TO_KETU and h in quadrants]
    # Allowed: Moon only
    ky2 = all(p == const.MOON_ID for p in planets_in_quadrants)
    return ky1 and ky2
```

---

### Lagnaadhi Yoga

- **PyJHora Function/Key**: `lagnaadhi_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If (1) the 7th and 8th houses from lagna are occupied by benefics and (2) no malefics conjoin or aspect these planets, then this yoga is present.
- **Effects/Benefits**: One born with this yoga becomes a great person. Person is learned and happy. Adhi means over or above. Lagnaadhi yoga means Adhi Yoga from lagna.
- **Notes/Reference**: Lagnaadhi Yoga: If (1) the 6th, 7th and 8th houses from lagna are occupied by benefics
        and (2) no malefics conjoin or aspect these planets.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" Lagnaadhi Yoga: If (1) the 6th, 7th and 8th houses from lagna are occupied by benefics
        and (2) no malefics conjoin or aspect these planets. """
    return _lagnaadhi_yoga_calculation(chart_1d=chart_1d)
```

---

### Sisnavyadhi Yoga

- **PyJHora Function/Key**: `sisnavyadhi_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**:  266 - Mercury should join Lagna in association with the lords of the 6th and 8th
- **Effects/Benefits**: The native will suffer from incurable sexual diseases.
- **Notes/Reference**: 266 - Mercury should join Lagna in conjunction with the lords of the 6th and 8th

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        266 - Mercury should join Lagna in conjunction with the lords of the 6th and 8th
    """
    return _sisnavyadhi_yoga_calculation(chart_1d=chart_1d)
```

---

### Sunaphaa Yoga

- **PyJHora Function/Key**: `sunaphaa_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: There are planets other than Sun in the 2nd house from Moon
- **Effects/Benefits**: You will become a king or an equal. You are intelligent, wealthy and famous. You will have self-earned wealth.
- **Notes/Reference**: BVR-2 If there are planets other than Sun in the 2nd house from Moon, this yoga is present.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-2 If there are planets other than Sun in the 2nd house from Moon, this yoga is present. """ 
    yoga_planet = const.MOON_ID; excluded_planet = const.SUN_ID
    house_from_yoga_planet = const.HOUSE_2
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    yoga_house = (p_to_h[yoga_planet] + house_from_yoga_planet) % 12
    yoga_house_planets = planets_in_raasi(yoga_house,p_to_h) # V4.8.0
    planet_ids = [int(p) for p in yoga_house_planets if p!='' and p != const._ascendant_symbol]
    return (len(planet_ids) >= 1) and (excluded_planet not in planet_ids)
```

---

### gaja_kesari_yoga

- **PyJHora Function/Key**: `gaja_kesari_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Gaja-Kesari Yoga: If (1) Jupiter is in a quadrant from Moon, (2) a benefic planet conjoins or aspects Jupiter, and, (3) Jupiter is not debilitated or combust or in an enemy’s house
- **Effects/Benefits**: One born with this yoga is famous, wealthy and intelligent. The person has great character and is liked by kings. For virtuousness and ever-lasting fame, this is a key yoga.
- **Notes/Reference**: BVR1 - Gaja-Kesari Yoga: If (1) Jupiter is in a quadrant from Moon, (2) a benefic planet
        conjoins or aspects Jupiter, and, (3) Jupiter is not debilitated or combust or in an
        enemy’s house
        NOTE: Since only chart is given:
            2. benefic is assumed to only mercury,jupiter,venus. Mercury if alone or jupiter/venus
            3. combustion if Jupiter and Sun in same house.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" 
        BVR1 - Gaja-Kesari Yoga: If (1) Jupiter is in a quadrant from Moon, (2) a benefic planet
        conjoins or aspects Jupiter, and, (3) Jupiter is not debilitated or combust or in an
        enemy’s house
        NOTE: Since only chart is given:
            2. benefic is assumed to only mercury,jupiter,venus. Mercury if alone or jupiter/venus
            3. combustion if Jupiter and Sun in same house.
        
    """
    return _gaja_kesari_yoga_calculation(chart_1d)
```

---

### guru_mangala_yoga

- **PyJHora Function/Key**: `guru_mangala_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If Jupiter and Mars are together or in the 7th house from each other, then this yoga is present.
- **Effects/Benefits**: One born with this yoga is righteous and energetic. The person's 'energies are channelled in dharmic paths.
- **Notes/Reference**: Guru-Mangala Yoga: If Jupiter and Mars are together or in the 7th house from each other

**Python Logic Summary (PyJHora Implementation)**:
```python
""" Guru-Mangala Yoga: If Jupiter and Mars are together or in the 7th house from each other """
    #p_to_h = utils.get_planet_house_dictionary_from_planet_positions(planet_positions)
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    gmy1 = p_to_h[const.MARS_ID]==p_to_h[const.JUPITER_ID]
    gmy2 = p_to_h[const.MARS_ID]==(p_to_h[const.JUPITER_ID]+const.HOUSE_7)%12
    gmy3 = p_to_h[const.JUPITER_ID]==(p_to_h[const.MARS_ID]+const.HOUSE_7)%12
    return  gmy1 or gmy2 or gmy3
```

---

## Daily Panchanga & Muhurta Yogas

Total yogas in this category: **38**

### Amirtha Yoga (Tamil Muhurta)

- **PyJHora Function/Key**: `tamil_yoga_4` (Source: `const.py`)
- **Astro Criteria (Rule)**: Tamil daily Muhurta yoga determined by the weekday and Nakshatra combination.
- **Effects/Benefits**: Highly used in South Indian Muhurta astrology for determining auspiciousness of activities.

**Python Logic Summary (PyJHora Implementation)**:
```python
Determined by Tamil basic yoga nakshatra matrix in const.py.
```

---

### Amirtha siddha Yoga (Tamil Muhurta)

- **PyJHora Function/Key**: `tamil_yoga_5` (Source: `const.py`)
- **Astro Criteria (Rule)**: Tamil daily Muhurta yoga determined by the weekday and Nakshatra combination.
- **Effects/Benefits**: Highly used in South Indian Muhurta astrology for determining auspiciousness of activities.

**Python Logic Summary (PyJHora Implementation)**:
```python
Determined by Tamil basic yoga nakshatra matrix in const.py.
```

---

### Amruth Yoga (Anandadi)

- **PyJHora Function/Key**: `anandadi_yoga_21` (Source: `const.py`)
- **Astro Criteria (Rule)**: One of the 28 Anandadi daily yogas calculated based on the weekday and Nakshatra combination.
- **Effects/Benefits**: Determines Muhurta suitability and auspiciousness for daily tasks.

**Python Logic Summary (PyJHora Implementation)**:
```python
Check Anandadi nakshatra-weekday rules in drik/panchanga modules.
```

---

### Anand Yoga (Anandadi)

- **PyJHora Function/Key**: `anandadi_yoga_1` (Source: `const.py`)
- **Astro Criteria (Rule)**: One of the 28 Anandadi daily yogas calculated based on the weekday and Nakshatra combination.
- **Effects/Benefits**: Determines Muhurta suitability and auspiciousness for daily tasks.

**Python Logic Summary (PyJHora Implementation)**:
```python
Check Anandadi nakshatra-weekday rules in drik/panchanga modules.
```

---

### Chara Yoga (Anandadi)

- **PyJHora Function/Key**: `anandadi_yoga_26` (Source: `const.py`)
- **Astro Criteria (Rule)**: One of the 28 Anandadi daily yogas calculated based on the weekday and Nakshatra combination.
- **Effects/Benefits**: Determines Muhurta suitability and auspiciousness for daily tasks.

**Python Logic Summary (PyJHora Implementation)**:
```python
Check Anandadi nakshatra-weekday rules in drik/panchanga modules.
```

---

### Chathra Yoga (Anandadi)

- **PyJHora Function/Key**: `anandadi_yoga_11` (Source: `const.py`)
- **Astro Criteria (Rule)**: One of the 28 Anandadi daily yogas calculated based on the weekday and Nakshatra combination.
- **Effects/Benefits**: Determines Muhurta suitability and auspiciousness for daily tasks.

**Python Logic Summary (PyJHora Implementation)**:
```python
Check Anandadi nakshatra-weekday rules in drik/panchanga modules.
```

---

### Daghda Yoga (Tamil Muhurta)

- **PyJHora Function/Key**: `tamil_yoga_7` (Source: `const.py`)
- **Astro Criteria (Rule)**: Tamil daily Muhurta yoga determined by the weekday and Nakshatra combination.
- **Effects/Benefits**: Highly used in South Indian Muhurta astrology for determining auspiciousness of activities.

**Python Logic Summary (PyJHora Implementation)**:
```python
Determined by Tamil basic yoga nakshatra matrix in const.py.
```

---

### Dhumra Yoga (Anandadi)

- **PyJHora Function/Key**: `anandadi_yoga_3` (Source: `const.py`)
- **Astro Criteria (Rule)**: One of the 28 Anandadi daily yogas calculated based on the weekday and Nakshatra combination.
- **Effects/Benefits**: Determines Muhurta suitability and auspiciousness for daily tasks.

**Python Logic Summary (PyJHora Implementation)**:
```python
Check Anandadi nakshatra-weekday rules in drik/panchanga modules.
```

---

### Dhwaja Yoga (Anandadi)

- **PyJHora Function/Key**: `anandadi_yoga_7` (Source: `const.py`)
- **Astro Criteria (Rule)**: One of the 28 Anandadi daily yogas calculated based on the weekday and Nakshatra combination.
- **Effects/Benefits**: Determines Muhurta suitability and auspiciousness for daily tasks.

**Python Logic Summary (PyJHora Implementation)**:
```python
Check Anandadi nakshatra-weekday rules in drik/panchanga modules.
```

---

### Dhwanksha Yoga (Anandadi)

- **PyJHora Function/Key**: `anandadi_yoga_6` (Source: `const.py`)
- **Astro Criteria (Rule)**: One of the 28 Anandadi daily yogas calculated based on the weekday and Nakshatra combination.
- **Effects/Benefits**: Determines Muhurta suitability and auspiciousness for daily tasks.

**Python Logic Summary (PyJHora Implementation)**:
```python
Check Anandadi nakshatra-weekday rules in drik/panchanga modules.
```

---

### Gada Yoga (Anandadi)

- **PyJHora Function/Key**: `anandadi_yoga_23` (Source: `const.py`)
- **Astro Criteria (Rule)**: One of the 28 Anandadi daily yogas calculated based on the weekday and Nakshatra combination.
- **Effects/Benefits**: Determines Muhurta suitability and auspiciousness for daily tasks.

**Python Logic Summary (PyJHora Implementation)**:
```python
Check Anandadi nakshatra-weekday rules in drik/panchanga modules.
```

---

### Kaal Yoga (Anandadi)

- **PyJHora Function/Key**: `anandadi_yoga_2` (Source: `const.py`)
- **Astro Criteria (Rule)**: One of the 28 Anandadi daily yogas calculated based on the weekday and Nakshatra combination.
- **Effects/Benefits**: Determines Muhurta suitability and auspiciousness for daily tasks.

**Python Logic Summary (PyJHora Implementation)**:
```python
Check Anandadi nakshatra-weekday rules in drik/panchanga modules.
```

---

### Kaan Yoga (Anandadi)

- **PyJHora Function/Key**: `anandadi_yoga_18` (Source: `const.py`)
- **Astro Criteria (Rule)**: One of the 28 Anandadi daily yogas calculated based on the weekday and Nakshatra combination.
- **Effects/Benefits**: Determines Muhurta suitability and auspiciousness for daily tasks.

**Python Logic Summary (PyJHora Implementation)**:
```python
Check Anandadi nakshatra-weekday rules in drik/panchanga modules.
```

---

### Lumbkak Yoga (Anandadi)

- **PyJHora Function/Key**: `anandadi_yoga_15` (Source: `const.py`)
- **Astro Criteria (Rule)**: One of the 28 Anandadi daily yogas calculated based on the weekday and Nakshatra combination.
- **Effects/Benefits**: Determines Muhurta suitability and auspiciousness for daily tasks.

**Python Logic Summary (PyJHora Implementation)**:
```python
Check Anandadi nakshatra-weekday rules in drik/panchanga modules.
```

---

### Maathanga Yoga (Anandadi)

- **PyJHora Function/Key**: `anandadi_yoga_24` (Source: `const.py`)
- **Astro Criteria (Rule)**: One of the 28 Anandadi daily yogas calculated based on the weekday and Nakshatra combination.
- **Effects/Benefits**: Determines Muhurta suitability and auspiciousness for daily tasks.

**Python Logic Summary (PyJHora Implementation)**:
```python
Check Anandadi nakshatra-weekday rules in drik/panchanga modules.
```

---

### Mansa Yoga (Anandadi)

- **PyJHora Function/Key**: `anandadi_yoga_13` (Source: `const.py`)
- **Astro Criteria (Rule)**: One of the 28 Anandadi daily yogas calculated based on the weekday and Nakshatra combination.
- **Effects/Benefits**: Determines Muhurta suitability and auspiciousness for daily tasks.

**Python Logic Summary (PyJHora Implementation)**:
```python
Check Anandadi nakshatra-weekday rules in drik/panchanga modules.
```

---

### Marana Yoga (Tamil Muhurta)

- **PyJHora Function/Key**: `tamil_yoga_3` (Source: `const.py`)
- **Astro Criteria (Rule)**: Tamil daily Muhurta yoga determined by the weekday and Nakshatra combination.
- **Effects/Benefits**: Highly used in South Indian Muhurta astrology for determining auspiciousness of activities.

**Python Logic Summary (PyJHora Implementation)**:
```python
Determined by Tamil basic yoga nakshatra matrix in const.py.
```

---

### Mithra Yoga (Anandadi)

- **PyJHora Function/Key**: `anandadi_yoga_12` (Source: `const.py`)
- **Astro Criteria (Rule)**: One of the 28 Anandadi daily yogas calculated based on the weekday and Nakshatra combination.
- **Effects/Benefits**: Determines Muhurta suitability and auspiciousness for daily tasks.

**Python Logic Summary (PyJHora Implementation)**:
```python
Check Anandadi nakshatra-weekday rules in drik/panchanga modules.
```

---

### Mrithyu Yoga (Anandadi)

- **PyJHora Function/Key**: `anandadi_yoga_17` (Source: `const.py`)
- **Astro Criteria (Rule)**: One of the 28 Anandadi daily yogas calculated based on the weekday and Nakshatra combination.
- **Effects/Benefits**: Determines Muhurta suitability and auspiciousness for daily tasks.

**Python Logic Summary (PyJHora Implementation)**:
```python
Check Anandadi nakshatra-weekday rules in drik/panchanga modules.
```

---

### Mrithyu Yoga (Tamil Muhurta)

- **PyJHora Function/Key**: `tamil_yoga_6` (Source: `const.py`)
- **Astro Criteria (Rule)**: Tamil daily Muhurta yoga determined by the weekday and Nakshatra combination.
- **Effects/Benefits**: Highly used in South Indian Muhurta astrology for determining auspiciousness of activities.

**Python Logic Summary (PyJHora Implementation)**:
```python
Determined by Tamil basic yoga nakshatra matrix in const.py.
```

---

### Mudgar Yoga (Anandadi)

- **PyJHora Function/Key**: `anandadi_yoga_10` (Source: `const.py`)
- **Astro Criteria (Rule)**: One of the 28 Anandadi daily yogas calculated based on the weekday and Nakshatra combination.
- **Effects/Benefits**: Determines Muhurta suitability and auspiciousness for daily tasks.

**Python Logic Summary (PyJHora Implementation)**:
```python
Check Anandadi nakshatra-weekday rules in drik/panchanga modules.
```

---

### Musal Yoga (Anandadi)

- **PyJHora Function/Key**: `anandadi_yoga_22` (Source: `const.py`)
- **Astro Criteria (Rule)**: One of the 28 Anandadi daily yogas calculated based on the weekday and Nakshatra combination.
- **Effects/Benefits**: Determines Muhurta suitability and auspiciousness for daily tasks.

**Python Logic Summary (PyJHora Implementation)**:
```python
Check Anandadi nakshatra-weekday rules in drik/panchanga modules.
```

---

### Padhma Yoga (Anandadi)

- **PyJHora Function/Key**: `anandadi_yoga_14` (Source: `const.py`)
- **Astro Criteria (Rule)**: One of the 28 Anandadi daily yogas calculated based on the weekday and Nakshatra combination.
- **Effects/Benefits**: Determines Muhurta suitability and auspiciousness for daily tasks.

**Python Logic Summary (PyJHora Implementation)**:
```python
Check Anandadi nakshatra-weekday rules in drik/panchanga modules.
```

---

### Prabalarishta Yoga (Tamil Muhurta)

- **PyJHora Function/Key**: `tamil_yoga_2` (Source: `const.py`)
- **Astro Criteria (Rule)**: Tamil daily Muhurta yoga determined by the weekday and Nakshatra combination.
- **Effects/Benefits**: Highly used in South Indian Muhurta astrology for determining auspiciousness of activities.

**Python Logic Summary (PyJHora Implementation)**:
```python
Determined by Tamil basic yoga nakshatra matrix in const.py.
```

---

### Prajapathi Yoga (Anandadi)

- **PyJHora Function/Key**: `anandadi_yoga_4` (Source: `const.py`)
- **Astro Criteria (Rule)**: One of the 28 Anandadi daily yogas calculated based on the weekday and Nakshatra combination.
- **Effects/Benefits**: Determines Muhurta suitability and auspiciousness for daily tasks.

**Python Logic Summary (PyJHora Implementation)**:
```python
Check Anandadi nakshatra-weekday rules in drik/panchanga modules.
```

---

### Raakshasa Yoga (Anandadi)

- **PyJHora Function/Key**: `anandadi_yoga_25` (Source: `const.py`)
- **Astro Criteria (Rule)**: One of the 28 Anandadi daily yogas calculated based on the weekday and Nakshatra combination.
- **Effects/Benefits**: Determines Muhurta suitability and auspiciousness for daily tasks.

**Python Logic Summary (PyJHora Implementation)**:
```python
Check Anandadi nakshatra-weekday rules in drik/panchanga modules.
```

---

### Sarvartha siddha Yoga (Tamil Muhurta)

- **PyJHora Function/Key**: `tamil_yoga_10` (Source: `const.py`)
- **Astro Criteria (Rule)**: Tamil daily Muhurta yoga determined by the weekday and Nakshatra combination.
- **Effects/Benefits**: Highly used in South Indian Muhurta astrology for determining auspiciousness of activities.

**Python Logic Summary (PyJHora Implementation)**:
```python
Determined by Tamil basic yoga nakshatra matrix in const.py.
```

---

### Shreevathsa Yoga (Anandadi)

- **PyJHora Function/Key**: `anandadi_yoga_8` (Source: `const.py`)
- **Astro Criteria (Rule)**: One of the 28 Anandadi daily yogas calculated based on the weekday and Nakshatra combination.
- **Effects/Benefits**: Determines Muhurta suitability and auspiciousness for daily tasks.

**Python Logic Summary (PyJHora Implementation)**:
```python
Check Anandadi nakshatra-weekday rules in drik/panchanga modules.
```

---

### Shubha Yoga (Anandadi)

- **PyJHora Function/Key**: `anandadi_yoga_20` (Source: `const.py`)
- **Astro Criteria (Rule)**: One of the 28 Anandadi daily yogas calculated based on the weekday and Nakshatra combination.
- **Effects/Benefits**: Determines Muhurta suitability and auspiciousness for daily tasks.

**Python Logic Summary (PyJHora Implementation)**:
```python
Check Anandadi nakshatra-weekday rules in drik/panchanga modules.
```

---

### Siddha Yoga (Tamil Muhurta)

- **PyJHora Function/Key**: `tamil_yoga_1` (Source: `const.py`)
- **Astro Criteria (Rule)**: Tamil daily Muhurta yoga determined by the weekday and Nakshatra combination.
- **Effects/Benefits**: Highly used in South Indian Muhurta astrology for determining auspiciousness of activities.

**Python Logic Summary (PyJHora Implementation)**:
```python
Determined by Tamil basic yoga nakshatra matrix in const.py.
```

---

### Siddhi Yoga (Anandadi)

- **PyJHora Function/Key**: `anandadi_yoga_19` (Source: `const.py`)
- **Astro Criteria (Rule)**: One of the 28 Anandadi daily yogas calculated based on the weekday and Nakshatra combination.
- **Effects/Benefits**: Determines Muhurta suitability and auspiciousness for daily tasks.

**Python Logic Summary (PyJHora Implementation)**:
```python
Check Anandadi nakshatra-weekday rules in drik/panchanga modules.
```

---

### Soumya Yoga (Anandadi)

- **PyJHora Function/Key**: `anandadi_yoga_5` (Source: `const.py`)
- **Astro Criteria (Rule)**: One of the 28 Anandadi daily yogas calculated based on the weekday and Nakshatra combination.
- **Effects/Benefits**: Determines Muhurta suitability and auspiciousness for daily tasks.

**Python Logic Summary (PyJHora Implementation)**:
```python
Check Anandadi nakshatra-weekday rules in drik/panchanga modules.
```

---

### Sthira Yoga (Anandadi)

- **PyJHora Function/Key**: `anandadi_yoga_27` (Source: `const.py`)
- **Astro Criteria (Rule)**: One of the 28 Anandadi daily yogas calculated based on the weekday and Nakshatra combination.
- **Effects/Benefits**: Determines Muhurta suitability and auspiciousness for daily tasks.

**Python Logic Summary (PyJHora Implementation)**:
```python
Check Anandadi nakshatra-weekday rules in drik/panchanga modules.
```

---

### Uthpath Yoga (Anandadi)

- **PyJHora Function/Key**: `anandadi_yoga_16` (Source: `const.py`)
- **Astro Criteria (Rule)**: One of the 28 Anandadi daily yogas calculated based on the weekday and Nakshatra combination.
- **Effects/Benefits**: Determines Muhurta suitability and auspiciousness for daily tasks.

**Python Logic Summary (PyJHora Implementation)**:
```python
Check Anandadi nakshatra-weekday rules in drik/panchanga modules.
```

---

### Uthpatha Yoga (Tamil Muhurta)

- **PyJHora Function/Key**: `tamil_yoga_9` (Source: `const.py`)
- **Astro Criteria (Rule)**: Tamil daily Muhurta yoga determined by the weekday and Nakshatra combination.
- **Effects/Benefits**: Highly used in South Indian Muhurta astrology for determining auspiciousness of activities.

**Python Logic Summary (PyJHora Implementation)**:
```python
Determined by Tamil basic yoga nakshatra matrix in const.py.
```

---

### Vajra Yoga (Anandadi)

- **PyJHora Function/Key**: `anandadi_yoga_9` (Source: `const.py`)
- **Astro Criteria (Rule)**: One of the 28 Anandadi daily yogas calculated based on the weekday and Nakshatra combination.
- **Effects/Benefits**: Determines Muhurta suitability and auspiciousness for daily tasks.

**Python Logic Summary (PyJHora Implementation)**:
```python
Check Anandadi nakshatra-weekday rules in drik/panchanga modules.
```

---

### Vrudh Yoga (Anandadi)

- **PyJHora Function/Key**: `anandadi_yoga_28` (Source: `const.py`)
- **Astro Criteria (Rule)**: One of the 28 Anandadi daily yogas calculated based on the weekday and Nakshatra combination.
- **Effects/Benefits**: Determines Muhurta suitability and auspiciousness for daily tasks.

**Python Logic Summary (PyJHora Implementation)**:
```python
Check Anandadi nakshatra-weekday rules in drik/panchanga modules.
```

---

### Yamaghata Yoga (Tamil Muhurta)

- **PyJHora Function/Key**: `tamil_yoga_8` (Source: `const.py`)
- **Astro Criteria (Rule)**: Tamil daily Muhurta yoga determined by the weekday and Nakshatra combination.
- **Effects/Benefits**: Highly used in South Indian Muhurta astrology for determining auspiciousness of activities.

**Python Logic Summary (PyJHora Implementation)**:
```python
Determined by Tamil basic yoga nakshatra matrix in const.py.
```

---

## Daily Panchanga & Nitya Yogas

Total yogas in this category: **27**

### Atiganda Yoga

- **PyJHora Function/Key**: `nitya_yoga_6` (Source: `panchanga/drik.py`)
- **Astro Criteria (Rule)**: One of the 27 daily Nitya Yogas, calculated by sum of Sun and Moon longitudes divided by 13°20'.
- **Effects/Benefits**: Indicates general nature of birth and day. Inauspicious daily yoga.

**Python Logic Summary (PyJHora Implementation)**:
```python
Nitya Yoga = (Sun Longitude + Moon Longitude) / 13°20' (modulo 27)
```

---

### Ayushman Yoga

- **PyJHora Function/Key**: `nitya_yoga_3` (Source: `panchanga/drik.py`)
- **Astro Criteria (Rule)**: One of the 27 daily Nitya Yogas, calculated by sum of Sun and Moon longitudes divided by 13°20'.
- **Effects/Benefits**: Indicates general nature of birth and day. Auspicious daily yoga.

**Python Logic Summary (PyJHora Implementation)**:
```python
Nitya Yoga = (Sun Longitude + Moon Longitude) / 13°20' (modulo 27)
```

---

### Brahma Yoga

- **PyJHora Function/Key**: `nitya_yoga_25` (Source: `panchanga/drik.py`)
- **Astro Criteria (Rule)**: One of the 27 daily Nitya Yogas, calculated by sum of Sun and Moon longitudes divided by 13°20'.
- **Effects/Benefits**: Indicates general nature of birth and day. Auspicious daily yoga.

**Python Logic Summary (PyJHora Implementation)**:
```python
Nitya Yoga = (Sun Longitude + Moon Longitude) / 13°20' (modulo 27)
```

---

### Dhriti Yoga

- **PyJHora Function/Key**: `nitya_yoga_8` (Source: `panchanga/drik.py`)
- **Astro Criteria (Rule)**: One of the 27 daily Nitya Yogas, calculated by sum of Sun and Moon longitudes divided by 13°20'.
- **Effects/Benefits**: Indicates general nature of birth and day. Auspicious daily yoga.

**Python Logic Summary (PyJHora Implementation)**:
```python
Nitya Yoga = (Sun Longitude + Moon Longitude) / 13°20' (modulo 27)
```

---

### Dhruva Yoga

- **PyJHora Function/Key**: `nitya_yoga_12` (Source: `panchanga/drik.py`)
- **Astro Criteria (Rule)**: One of the 27 daily Nitya Yogas, calculated by sum of Sun and Moon longitudes divided by 13°20'.
- **Effects/Benefits**: Indicates general nature of birth and day. Auspicious daily yoga.

**Python Logic Summary (PyJHora Implementation)**:
```python
Nitya Yoga = (Sun Longitude + Moon Longitude) / 13°20' (modulo 27)
```

---

### Ganda Yoga

- **PyJHora Function/Key**: `nitya_yoga_10` (Source: `panchanga/drik.py`)
- **Astro Criteria (Rule)**: One of the 27 daily Nitya Yogas, calculated by sum of Sun and Moon longitudes divided by 13°20'.
- **Effects/Benefits**: Indicates general nature of birth and day. Inauspicious daily yoga.

**Python Logic Summary (PyJHora Implementation)**:
```python
Nitya Yoga = (Sun Longitude + Moon Longitude) / 13°20' (modulo 27)
```

---

### Harshana Yoga

- **PyJHora Function/Key**: `nitya_yoga_14` (Source: `panchanga/drik.py`)
- **Astro Criteria (Rule)**: One of the 27 daily Nitya Yogas, calculated by sum of Sun and Moon longitudes divided by 13°20'.
- **Effects/Benefits**: Indicates general nature of birth and day. Auspicious daily yoga.

**Python Logic Summary (PyJHora Implementation)**:
```python
Nitya Yoga = (Sun Longitude + Moon Longitude) / 13°20' (modulo 27)
```

---

### Indra Yoga

- **PyJHora Function/Key**: `nitya_yoga_26` (Source: `panchanga/drik.py`)
- **Astro Criteria (Rule)**: One of the 27 daily Nitya Yogas, calculated by sum of Sun and Moon longitudes divided by 13°20'.
- **Effects/Benefits**: Indicates general nature of birth and day. Auspicious daily yoga.

**Python Logic Summary (PyJHora Implementation)**:
```python
Nitya Yoga = (Sun Longitude + Moon Longitude) / 13°20' (modulo 27)
```

---

### Parigha Yoga

- **PyJHora Function/Key**: `nitya_yoga_19` (Source: `panchanga/drik.py`)
- **Astro Criteria (Rule)**: One of the 27 daily Nitya Yogas, calculated by sum of Sun and Moon longitudes divided by 13°20'.
- **Effects/Benefits**: Indicates general nature of birth and day. Inauspicious daily yoga.

**Python Logic Summary (PyJHora Implementation)**:
```python
Nitya Yoga = (Sun Longitude + Moon Longitude) / 13°20' (modulo 27)
```

---

### Preeti Yoga

- **PyJHora Function/Key**: `nitya_yoga_2` (Source: `panchanga/drik.py`)
- **Astro Criteria (Rule)**: One of the 27 daily Nitya Yogas, calculated by sum of Sun and Moon longitudes divided by 13°20'.
- **Effects/Benefits**: Indicates general nature of birth and day. Auspicious daily yoga.

**Python Logic Summary (PyJHora Implementation)**:
```python
Nitya Yoga = (Sun Longitude + Moon Longitude) / 13°20' (modulo 27)
```

---

### Sadhya Yoga

- **PyJHora Function/Key**: `nitya_yoga_22` (Source: `panchanga/drik.py`)
- **Astro Criteria (Rule)**: One of the 27 daily Nitya Yogas, calculated by sum of Sun and Moon longitudes divided by 13°20'.
- **Effects/Benefits**: Indicates general nature of birth and day. Auspicious daily yoga.

**Python Logic Summary (PyJHora Implementation)**:
```python
Nitya Yoga = (Sun Longitude + Moon Longitude) / 13°20' (modulo 27)
```

---

### Saubhagya Yoga

- **PyJHora Function/Key**: `nitya_yoga_4` (Source: `panchanga/drik.py`)
- **Astro Criteria (Rule)**: One of the 27 daily Nitya Yogas, calculated by sum of Sun and Moon longitudes divided by 13°20'.
- **Effects/Benefits**: Indicates general nature of birth and day. Auspicious daily yoga.

**Python Logic Summary (PyJHora Implementation)**:
```python
Nitya Yoga = (Sun Longitude + Moon Longitude) / 13°20' (modulo 27)
```

---

### Shiva Yoga

- **PyJHora Function/Key**: `nitya_yoga_20` (Source: `panchanga/drik.py`)
- **Astro Criteria (Rule)**: One of the 27 daily Nitya Yogas, calculated by sum of Sun and Moon longitudes divided by 13°20'.
- **Effects/Benefits**: Indicates general nature of birth and day. Auspicious daily yoga.

**Python Logic Summary (PyJHora Implementation)**:
```python
Nitya Yoga = (Sun Longitude + Moon Longitude) / 13°20' (modulo 27)
```

---

### Shobhana Yoga

- **PyJHora Function/Key**: `nitya_yoga_5` (Source: `panchanga/drik.py`)
- **Astro Criteria (Rule)**: One of the 27 daily Nitya Yogas, calculated by sum of Sun and Moon longitudes divided by 13°20'.
- **Effects/Benefits**: Indicates general nature of birth and day. Auspicious daily yoga.

**Python Logic Summary (PyJHora Implementation)**:
```python
Nitya Yoga = (Sun Longitude + Moon Longitude) / 13°20' (modulo 27)
```

---

### Shoola Yoga

- **PyJHora Function/Key**: `nitya_yoga_9` (Source: `panchanga/drik.py`)
- **Astro Criteria (Rule)**: One of the 27 daily Nitya Yogas, calculated by sum of Sun and Moon longitudes divided by 13°20'.
- **Effects/Benefits**: Indicates general nature of birth and day. Inauspicious daily yoga.

**Python Logic Summary (PyJHora Implementation)**:
```python
Nitya Yoga = (Sun Longitude + Moon Longitude) / 13°20' (modulo 27)
```

---

### Shubha Yoga

- **PyJHora Function/Key**: `nitya_yoga_23` (Source: `panchanga/drik.py`)
- **Astro Criteria (Rule)**: One of the 27 daily Nitya Yogas, calculated by sum of Sun and Moon longitudes divided by 13°20'.
- **Effects/Benefits**: Indicates general nature of birth and day. Auspicious daily yoga.

**Python Logic Summary (PyJHora Implementation)**:
```python
Nitya Yoga = (Sun Longitude + Moon Longitude) / 13°20' (modulo 27)
```

---

### Shukla Yoga

- **PyJHora Function/Key**: `nitya_yoga_24` (Source: `panchanga/drik.py`)
- **Astro Criteria (Rule)**: One of the 27 daily Nitya Yogas, calculated by sum of Sun and Moon longitudes divided by 13°20'.
- **Effects/Benefits**: Indicates general nature of birth and day. Auspicious daily yoga.

**Python Logic Summary (PyJHora Implementation)**:
```python
Nitya Yoga = (Sun Longitude + Moon Longitude) / 13°20' (modulo 27)
```

---

### Siddha Yoga

- **PyJHora Function/Key**: `nitya_yoga_21` (Source: `panchanga/drik.py`)
- **Astro Criteria (Rule)**: One of the 27 daily Nitya Yogas, calculated by sum of Sun and Moon longitudes divided by 13°20'.
- **Effects/Benefits**: Indicates general nature of birth and day. Auspicious daily yoga.

**Python Logic Summary (PyJHora Implementation)**:
```python
Nitya Yoga = (Sun Longitude + Moon Longitude) / 13°20' (modulo 27)
```

---

### Siddhi Yoga

- **PyJHora Function/Key**: `nitya_yoga_16` (Source: `panchanga/drik.py`)
- **Astro Criteria (Rule)**: One of the 27 daily Nitya Yogas, calculated by sum of Sun and Moon longitudes divided by 13°20'.
- **Effects/Benefits**: Indicates general nature of birth and day. Auspicious daily yoga.

**Python Logic Summary (PyJHora Implementation)**:
```python
Nitya Yoga = (Sun Longitude + Moon Longitude) / 13°20' (modulo 27)
```

---

### Sukarma Yoga

- **PyJHora Function/Key**: `nitya_yoga_7` (Source: `panchanga/drik.py`)
- **Astro Criteria (Rule)**: One of the 27 daily Nitya Yogas, calculated by sum of Sun and Moon longitudes divided by 13°20'.
- **Effects/Benefits**: Indicates general nature of birth and day. Auspicious daily yoga.

**Python Logic Summary (PyJHora Implementation)**:
```python
Nitya Yoga = (Sun Longitude + Moon Longitude) / 13°20' (modulo 27)
```

---

### Vaidhriti Yoga

- **PyJHora Function/Key**: `nitya_yoga_27` (Source: `panchanga/drik.py`)
- **Astro Criteria (Rule)**: One of the 27 daily Nitya Yogas, calculated by sum of Sun and Moon longitudes divided by 13°20'.
- **Effects/Benefits**: Indicates general nature of birth and day. Inauspicious daily yoga.

**Python Logic Summary (PyJHora Implementation)**:
```python
Nitya Yoga = (Sun Longitude + Moon Longitude) / 13°20' (modulo 27)
```

---

### Vajra Yoga

- **PyJHora Function/Key**: `nitya_yoga_15` (Source: `panchanga/drik.py`)
- **Astro Criteria (Rule)**: One of the 27 daily Nitya Yogas, calculated by sum of Sun and Moon longitudes divided by 13°20'.
- **Effects/Benefits**: Indicates general nature of birth and day. Inauspicious daily yoga.

**Python Logic Summary (PyJHora Implementation)**:
```python
Nitya Yoga = (Sun Longitude + Moon Longitude) / 13°20' (modulo 27)
```

---

### Variyana Yoga

- **PyJHora Function/Key**: `nitya_yoga_18` (Source: `panchanga/drik.py`)
- **Astro Criteria (Rule)**: One of the 27 daily Nitya Yogas, calculated by sum of Sun and Moon longitudes divided by 13°20'.
- **Effects/Benefits**: Indicates general nature of birth and day. Auspicious daily yoga.

**Python Logic Summary (PyJHora Implementation)**:
```python
Nitya Yoga = (Sun Longitude + Moon Longitude) / 13°20' (modulo 27)
```

---

### Vishkumbha Yoga

- **PyJHora Function/Key**: `nitya_yoga_1` (Source: `panchanga/drik.py`)
- **Astro Criteria (Rule)**: One of the 27 daily Nitya Yogas, calculated by sum of Sun and Moon longitudes divided by 13°20'.
- **Effects/Benefits**: Indicates general nature of birth and day. Inauspicious daily yoga.

**Python Logic Summary (PyJHora Implementation)**:
```python
Nitya Yoga = (Sun Longitude + Moon Longitude) / 13°20' (modulo 27)
```

---

### Vriddhi Yoga

- **PyJHora Function/Key**: `nitya_yoga_11` (Source: `panchanga/drik.py`)
- **Astro Criteria (Rule)**: One of the 27 daily Nitya Yogas, calculated by sum of Sun and Moon longitudes divided by 13°20'.
- **Effects/Benefits**: Indicates general nature of birth and day. Auspicious daily yoga.

**Python Logic Summary (PyJHora Implementation)**:
```python
Nitya Yoga = (Sun Longitude + Moon Longitude) / 13°20' (modulo 27)
```

---

### Vyaghata Yoga

- **PyJHora Function/Key**: `nitya_yoga_13` (Source: `panchanga/drik.py`)
- **Astro Criteria (Rule)**: One of the 27 daily Nitya Yogas, calculated by sum of Sun and Moon longitudes divided by 13°20'.
- **Effects/Benefits**: Indicates general nature of birth and day. Inauspicious daily yoga.

**Python Logic Summary (PyJHora Implementation)**:
```python
Nitya Yoga = (Sun Longitude + Moon Longitude) / 13°20' (modulo 27)
```

---

### Vyatipata Yoga

- **PyJHora Function/Key**: `nitya_yoga_17` (Source: `panchanga/drik.py`)
- **Astro Criteria (Rule)**: One of the 27 daily Nitya Yogas, calculated by sum of Sun and Moon longitudes divided by 13°20'.
- **Effects/Benefits**: Indicates general nature of birth and day. Inauspicious daily yoga.

**Python Logic Summary (PyJHora Implementation)**:
```python
Nitya Yoga = (Sun Longitude + Moon Longitude) / 13°20' (modulo 27)
```

---

## Daridra Yogas (Poverty)

Total yogas in this category: **11**

### Dharidhra Yoga

- **PyJHora Function/Key**: `dharidhra_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The lord of the 11th house is in the 6th, 8th, or 12th house.
- **Effects/Benefits**: You may face financial struggles, heavy debts, and difficulty in accumulating wealth despite hard work.
- **Notes/Reference**: BVR 144 to 152
        Method=1 Ref: Medium - What is daridra yoga
        the lord of 1nd or 11th is situated in the 6th, 8th or 12th
        Method = 2 - Ref: BV Raman Dharidhra Yoga #144 to #152

**Python Logic Summary (PyJHora Implementation)**:
```python
""" 
        BVR 144 to 152
        Method=1 Ref: Medium - What is daridra yoga
        the lord of 1nd or 11th is situated in the 6th, 8th or 12th
        Method = 2 - Ref: BV Raman Dharidhra Yoga #144 to #152
    """
    return _dharidhra_yoga_calculation(chart_rasi=chart_rasi,chart_navamsa=chart_navamsa,method=method)
```

---

### Dharidhra Yoga

- **PyJHora Function/Key**: `dharidhra_yoga_144` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The lords of the 12th and Lagna exchange positions and are conjoined with or aspected by the lord of the 7th.
- **Effects/Benefits**: Yoga causes dire poverty, financial straits, wretchedness and miseries
- **Notes/Reference**: Daridra Yoga (BV Raman 144)
    Definition: The lords of the 12th and Lagna exchange positions and 
    are conjoined with or aspected by the lord of the 7th.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Daridra Yoga (BV Raman 144)
    Definition: The lords of the 12th and Lagna exchange positions and 
    are conjoined with or aspected by the lord of the 7th.
    """
    if planet_positions is not None:
        chart_1d = utils.get_house_planet_list_from_planet_positions(planet_positions)
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    _asc = const._ascendant_symbol
    asc_h = p_to_h[_asc]
    
    h12 = (asc_h + 11) % 12
    h7 = (asc_h + 6) % 12

    if planet_positions is not None:
        l1 = house.house_owner_from_planet_positions(planet_positions, asc_h)
        l12 = house.house_owner_from_planet_positions(planet_positions, h12)
        l7 = house.house_owner_from_planet_positions(planet_positions, h7)
    else:
        l1 = house.house_owner(chart_1d, asc_h)
        l12 = house.house_owner(chart_1d, h12)
        l7 = house.house_owner(chart_1d, h7)
    # Exchange logic: L1 in 12th house AND L12 in Lagna
    exchange = (p_to_h[l1] == h12) and (p_to_h[l12] == asc_h)
    if not exchange:
        return False
    
    l7_h = p_to_h[l7]
    conjoined = (l7_h == p_to_h[l1]) or (l7_h == p_to_h[l12])
    
    graha_aspects = house.aspected_planets_of_the_planet(chart_1d, l7)
    rasi_aspects = house.aspected_planets_of_the_raasi(chart_1d, l7_h)
    
    aspected = (l1 in graha_aspects or l12 in graha_aspects) or \
               (l1 in rasi_aspects or l12 in rasi_aspects)

    return exchange and (conjoined or aspected)
```

---

### Dharidhra Yoga

- **PyJHora Function/Key**: `dharidhra_yoga_145` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The lords of the 6th and Lagna interchange positions and the Moon is aspected by the 2nd or 7th lord.
- **Effects/Benefits**: Yoga causes dire poverty, financial straits, wretchedness and miseries
- **Notes/Reference**: Daridra Yoga (BV Raman 145)
    Definition: The lords of the 6th and Lagna interchange positions and 
    the Moon is aspected by the 2nd or 7th lord.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Daridra Yoga (BV Raman 145)
    Definition: The lords of the 6th and Lagna interchange positions and 
    the Moon is aspected by the 2nd or 7th lord.
    """
    if planet_positions is not None:
        chart_1d = utils.get_house_planet_list_from_planet_positions(planet_positions)
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    _asc = const._ascendant_symbol
    asc_h = p_to_h[_asc]
    h6 = (asc_h + const.HOUSE_6) % 12
    h2 = (asc_h + const.HOUSE_2) % 12
    h7 = (asc_h + const.HOUSE_7) % 12

    if planet_positions is not None:
        l1 = int(house.house_owner_from_planet_positions(planet_positions, asc_h))
        l6 = int(house.house_owner_from_planet_positions(planet_positions, h6))
        l2 = int(house.house_owner_from_planet_positions(planet_positions, h2))
        l7 = int(house.house_owner_from_planet_positions(planet_positions, h7))
    else:
        l1 = int(house.house_owner(chart_1d, asc_h))
        l6 = int(house.house_owner(chart_1d, h6))
        l2 = int(house.house_owner(chart_1d, h2))
        l7 = int(house.house_owner(chart_1d, h7))

    exchange = (p_to_h[l1] == h6) and (p_to_h[l6] == asc_h)
    
    moon = const.MOON_ID
    # Aspect on Moon by L2 or L7
    asp_l2 = (moon in house.aspected_planets_of_the_planet(chart_1d, l2)) or \
             (moon in house.aspected_planets_of_the_raasi(chart_1d, p_to_h[l2]))
    asp_l7 = (moon in house.aspected_planets_of_the_planet(chart_1d, l7)) or \
             (moon in house.aspected_planets_of_the_raasi(chart_1d, p_to_h[l7]))

    return exchange and (asp_l2 or asp_l7)
```

---

### Dharidhra Yoga

- **PyJHora Function/Key**: `dharidhra_yoga_146` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Ketu and the Moon should be in Lagna.
- **Effects/Benefits**: Yoga causes dire poverty, financial straits, wretchedness and miseries
- **Notes/Reference**: Daridra Yoga (BV Raman 146)
    Definition: Ketu and the Moon should be in Lagna.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Daridra Yoga (BV Raman 146)
    Definition: Ketu and the Moon should be in Lagna.
    """
    if planet_positions is not None:
        chart_1d = utils.get_house_planet_list_from_planet_positions(planet_positions)
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    _asc = const._ascendant_symbol
    asc_h = p_to_h[_asc]

    return (p_to_h[const.KETU_ID] == asc_h) and (p_to_h[const.MOON_ID] == asc_h)
```

---

### Dharidhra Yoga

- **PyJHora Function/Key**: `dharidhra_yoga_147` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The lord of Lagna is in the 8th aspected by or in conjunction with the 2nd or 7th lord.
- **Effects/Benefits**: Yoga causes dire poverty, financial straits, wretchedness and miseries
- **Notes/Reference**: Daridra Yoga (BV Raman 147)
    Definition: The lord of Lagna is in the 8th aspected by or in 
    conjunction with the 2nd or 7th lord.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Daridra Yoga (BV Raman 147)
    Definition: The lord of Lagna is in the 8th aspected by or in 
    conjunction with the 2nd or 7th lord.
    """
    if planet_positions is not None:
        chart_1d = utils.get_house_planet_list_from_planet_positions(planet_positions)
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    _asc = const._ascendant_symbol
    asc_h = p_to_h[_asc]
    h8 = (asc_h + const.HOUSE_8) % 12
    h2 = (asc_h + const.HOUSE_2) % 12
    h7 = (asc_h + const.HOUSE_7) % 12

    if planet_positions is not None:
        l1 = int(house.house_owner_from_planet_positions(planet_positions, asc_h))
        l2 = int(house.house_owner_from_planet_positions(planet_positions, h2))
        l7 = int(house.house_owner_from_planet_positions(planet_positions, h7))
    else:
        l1 = int(house.house_owner(chart_1d, asc_h))
        l2 = int(house.house_owner(chart_1d, h2))
        l7 = int(house.house_owner(chart_1d, h7))

    # Condition 1: L1 in 8th
    if p_to_h[l1] != h8:
        return False

    # Condition 2: Conjunction or Aspect with L2 or L7
    for maraka in [l2, l7]:
        if (p_to_h[maraka] == h8) or \
           (l1 in house.aspected_planets_of_the_planet(chart_1d, maraka)) or \
           (l1 in house.aspected_planets_of_the_raasi(chart_1d, p_to_h[maraka])):
            return True
    return False
```

---

### Dharidhra Yoga

- **PyJHora Function/Key**: `dharidhra_yoga_148` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Lord of Lagna in 6, 8, or 12 with a malefic, aspected by or combined with the 2nd or 7th lord.
- **Effects/Benefits**: Yoga causes dire poverty, financial straits, wretchedness and miseries
- **Notes/Reference**: Daridra Yoga (BV Raman 148)
    Definition: Lord of Lagna in 6, 8, or 12 with a malefic, aspected by or 
    combined with the 2nd or 7th lord.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Daridra Yoga (BV Raman 148)
    Definition: Lord of Lagna in 6, 8, or 12 with a malefic, aspected by or 
    combined with the 2nd or 7th lord.
    """
    if planet_positions is not None:
        chart_1d = utils.get_house_planet_list_from_planet_positions(planet_positions)
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    _asc = const._ascendant_symbol
    asc_h = p_to_h[_asc]
    trik_houses = [(asc_h + h) % 12 for h in [const.HOUSE_6, const.HOUSE_8, const.HOUSE_12]]
    
    if natural_malefics is None:
        _natural_malefics = set(const.natural_malefics)
    else:
        _natural_malefics = set(natural_malefics)

    if planet_positions is not None:
        l1 = int(house.house_owner_from_planet_positions(planet_positions, asc_h))
        l2 = int(house.house_owner_from_planet_positions(planet_positions, (asc_h + const.HOUSE_2) % 12))
        l7 = int(house.house_owner_from_planet_positions(planet_positions, (asc_h + const.HOUSE_7) % 12))
    else:
        l1 = int(house.house_owner(chart_1d, asc_h))
        l2 = int(house.house_owner(chart_1d, (asc_h + const.HOUSE_2) % 12))
        l7 = int(house.house_owner(chart_1d, (asc_h + const.HOUSE_7) % 12))

    l1_house = p_to_h[l1]
    if l1_house not in trik_houses:
        return False

    # Check if a malefic is in the same house as L1
    malefic_with_l1 = any(m for m in _natural_malefics if m != l1 and p_to_h[m] == l1_house)
    if not malefic_with_l1:
        return False

    # Check influence of L2 or L7 on L1
    for maraka in [l2, l7]:
        if (p_to_h[maraka] == l1_house) or \
           (l1 in house.aspected_planets_of_the_planet(chart_1d, maraka)) or \
           (l1 in house.aspected_planets_of_the_raasi(chart_1d, p_to_h[maraka])):
            return True
    return False
```

---

### Dharidhra Yoga

- **PyJHora Function/Key**: `dharidhra_yoga_149` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Lord of Lagna associated with 6th, 8th, or 12th lord and subjected to malefic aspects.
- **Effects/Benefits**: Yoga causes dire poverty, financial straits, wretchedness and miseries
- **Notes/Reference**: Daridra Yoga (BV Raman 149)
    Definition: Lord of Lagna associated with 6th, 8th, or 12th lord and 
    subjected to malefic aspects.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Daridra Yoga (BV Raman 149)
    Definition: Lord of Lagna associated with 6th, 8th, or 12th lord and 
    subjected to malefic aspects.
    """
    if planet_positions is not None:
        chart_1d = utils.get_house_planet_list_from_planet_positions(planet_positions)
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    _asc = const._ascendant_symbol
    asc_h = p_to_h[_asc]

    if natural_malefics is None:
        _natural_malefics = set(const.natural_malefics)
    else:
        _natural_malefics = set(natural_malefics)

    if planet_positions is not None:
        l1 = int(house.house_owner_from_planet_positions(planet_positions, asc_h))
        trik_lords = [int(house.house_owner_from_planet_positions(planet_positions, (asc_h + h) % 12)) 
                      for h in [const.HOUSE_6, const.HOUSE_8, const.HOUSE_12]]
    else:
        l1 = int(house.house_owner(chart_1d, asc_h))
        trik_lords = [int(house.house_owner(chart_1d, (asc_h + h) % 12)) 
                      for h in [const.HOUSE_6, const.HOUSE_8, const.HOUSE_12]]

    # Association with Trik lord (Conjunction or Mutual Aspect)
    l1_h = p_to_h[l1]
    associated = False
    for tl in trik_lords:
        if (p_to_h[tl] == l1_h) or (l1 in house.aspected_planets_of_the_planet(chart_1d, tl)):
            associated = True
            break
    
    if not associated:
        return False

    # Subjected to malefic aspects
    malefic_aspect = False
    for m in _natural_malefics:
        if m != l1 and (l1 in house.aspected_planets_of_the_planet(chart_1d, m)):
            malefic_aspect = True
            break
            
    return malefic_aspect
```

---

### Dharidhra Yoga

- **PyJHora Function/Key**: `dharidhra_yoga_150` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Lord of 5th joins lord of 6, 8, or 12 without beneficial aspects/conjunctions.
- **Effects/Benefits**: Yoga causes dire poverty, financial straits, wretchedness and miseries
- **Notes/Reference**: Daridra Yoga (BV Raman 150)
    Definition: Lord of 5th joins lord of 6, 8, or 12 without beneficial aspects/conjunctions.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Daridra Yoga (BV Raman 150)
    Definition: Lord of 5th joins lord of 6, 8, or 12 without beneficial aspects/conjunctions.
    """
    if planet_positions is not None:
        chart_1d = utils.get_house_planet_list_from_planet_positions(planet_positions)
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    _asc = const._ascendant_symbol
    asc_h = p_to_h[_asc]

    _natural_benefics = _get_natural_benefics(chart_1d, natural_benefics)

    if planet_positions is not None:
        l5 = int(house.house_owner_from_planet_positions(planet_positions, (asc_h + const.HOUSE_5) % 12))
        trik_lords = [int(house.house_owner_from_planet_positions(planet_positions, (asc_h + h) % 12)) 
                      for h in [const.HOUSE_6, const.HOUSE_8, const.HOUSE_12]]
    else:
        l5 = int(house.house_owner(chart_1d, (asc_h + const.HOUSE_5) % 12))
        trik_lords = [int(house.house_owner(chart_1d, (asc_h + h) % 12)) 
                      for h in [const.HOUSE_6, const.HOUSE_8, const.HOUSE_12]]

    # Joins (Conjunction) with Trik Lord
    l5_h = p_to_h[l5]
    joined = any(p_to_h[tl] == l5_h for tl in trik_lords)
    
    if not joined:
        return False

    # Check for beneficial aspects or conjunctions
    for b in _natural_benefics:
        if (p_to_h[b] == l5_h) or (l5 in house.aspected_planets_of_the_planet(chart_1d, b)):
            return False # Has beneficial influence
            
    return True
```

---

### Dharidhra Yoga

- **PyJHora Function/Key**: `dharidhra_yoga_151` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Lord of 5th in 6th or 10th aspected by lords of 2, 6, 7, 8, or 12.
- **Effects/Benefits**: Yoga causes dire poverty, financial straits, wretchedness and miseries
- **Notes/Reference**: Daridra Yoga (BV Raman 151)
    Definition: Lord of 5th in 6th or 10th aspected by lords of 2, 6, 7, 8, or 12.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Daridra Yoga (BV Raman 151)
    Definition: Lord of 5th in 6th or 10th aspected by lords of 2, 6, 7, 8, or 12.
    """
    if planet_positions is not None:
        chart_1d = utils.get_house_planet_list_from_planet_positions(planet_positions)
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    _asc = const._ascendant_symbol
    asc_h = p_to_h[_asc]

    if planet_positions is not None:
        l5 = int(house.house_owner_from_planet_positions(planet_positions, (asc_h + const.HOUSE_5) % 12))
        target_lords = [int(house.house_owner_from_planet_positions(planet_positions, (asc_h + h) % 12)) 
                        for h in [const.HOUSE_2, const.HOUSE_6, const.HOUSE_7, const.HOUSE_8, const.HOUSE_12]]
    else:
        l5 = int(house.house_owner(chart_1d, (asc_h + const.HOUSE_5) % 12))
        target_lords = [int(house.house_owner(chart_1d, (asc_h + h) % 12)) 
                        for h in [const.HOUSE_2, const.HOUSE_6, const.HOUSE_7, const.HOUSE_8, const.HOUSE_12]]

    l5_h = p_to_h[l5]
    if l5_h not in [(asc_h + const.HOUSE_6) % 12, (asc_h + const.HOUSE_10) % 12]:
        return False

    # Aspected by any of the target lords
    for tl in target_lords:
        if (l5 in house.aspected_planets_of_the_planet(chart_1d, tl)) or \
           (l5 in house.aspected_planets_of_the_raasi(chart_1d, p_to_h[tl])):
            return True
            
    return False
```

---

### Dharidhra Yoga

- **PyJHora Function/Key**: `dharidhra_yoga_152` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Natural malefics (not owning 9th or 10th) in Lagna associated with or aspected by maraka lords (L2/L7).
- **Effects/Benefits**: Yoga causes dire poverty, financial straits, wretchedness and miseries
- **Notes/Reference**: Daridra Yoga (BV Raman 152)
    Definition: Natural malefics (not owning 9th or 10th) in Lagna associated 
    with or aspected by maraka lords (L2/L7).

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Daridra Yoga (BV Raman 152)
    Definition: Natural malefics (not owning 9th or 10th) in Lagna associated 
    with or aspected by maraka lords (L2/L7).
    """
    if planet_positions is not None:
        chart_1d = utils.get_house_planet_list_from_planet_positions(planet_positions)
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    _asc = const._ascendant_symbol
    asc_h = p_to_h[_asc]
    h9 = (asc_h + const.HOUSE_9) % 12
    h10 = (asc_h + const.HOUSE_10) % 12
    h2 = (asc_h + const.HOUSE_2) % 12
    h7 = (asc_h + const.HOUSE_7) % 12

    if natural_malefics is None:
        _natural_malefics = set(const.natural_malefics)
    else:
        _natural_malefics = set(natural_malefics)

    if planet_positions is not None:
        l9 = int(house.house_owner_from_planet_positions(planet_positions, h9))
        l10 = int(house.house_owner_from_planet_positions(planet_positions, h10))
        l2 = int(house.house_owner_from_planet_positions(planet_positions, h2))
        l7 = int(house.house_owner_from_planet_positions(planet_positions, h7))
    else:
        l9 = int(house.house_owner(chart_1d, h9))
        l10 = int(house.house_owner(chart_1d, h10))
        l2 = int(house.house_owner(chart_1d, h2))
        l7 = int(house.house_owner(chart_1d, h7))

    malefics_in_lagna = [m for m in _natural_malefics if p_to_h[m] == asc_h]
    valid_malefics = [m for m in malefics_in_lagna if m != l9 and m != l10]

    if not valid_malefics:
        return False

    for m in valid_malefics:
        # Check association or aspect with L2 or L7
        for maraka in [l2, l7]:
            if (p_to_h[m] == p_to_h[maraka]) or \
               (m in house.aspected_planets_of_the_planet(chart_1d, maraka)) or \
               (m in house.aspected_planets_of_the_raasi(chart_1d, p_to_h[maraka])):
                return True
    return False
```

---

### Dharidhra Yoga

- **PyJHora Function/Key**: `dharidhra_yoga_153` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The lords of the Lagna and Navamsa Lagna should occupy the 6th, 8th or 12th and have the aspect or conjunction of the lords of the 2nd and 7th.
- **Effects/Benefits**: Yoga causes dire poverty, financial straits, wretchedness and miseries

---

## Dhana Yogas (Wealth)

Total yogas in this category: **22**

### Amaranantha Dhana Yoga

- **PyJHora Function/Key**: `amaranantha_dhana_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The lords of the 2nd, 9th, and 11th are in Kendras from the Lagna and the Lagna lord is strong.
- **Effects/Benefits**: You will remain wealthy and enjoy financial stability until the very end of your life.
- **Notes/Reference**: Amaranantha Dhana Yoga (BV Raman 142)
    Definition: If a number of planets occupy the 2nd house and the wealth-giving 
    ones are strong or occupy own or exaltation signs.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Amaranantha Dhana Yoga (BV Raman 142)
    Definition: If a number of planets occupy the 2nd house and the wealth-giving 
    ones are strong or occupy own or exaltation signs.
    """
    return _amaranantha_dhana_yoga_calculation(chart_1d)
```

---

### Anthya Vayasi Dhana Yoga

- **PyJHora Function/Key**: `anthya_vayasi_dhana_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The lords of the 2nd, 9th, and 11th houses are placed in the 12th, 6th, or 8th houses from each other but associated with benefics.
- **Effects/Benefits**: You will accumulate and enjoy great wealth and prosperity during the later years or the final stage of your life.
- **Notes/Reference**: BVR-134 Anthya Vayasi Dhana Yoga
    Covers wealth acquired or peaking in middle age.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    BVR-134 Anthya Vayasi Dhana Yoga
    Covers wealth acquired or peaking in middle age.
    """
    return _anthya_vayasi_dhana_yoga_calculation(chart_1d=chart_1d)
```

---

### Balya Dhana Yoga

- **PyJHora Function/Key**: `balya_dhana_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The lords of the 2nd and 10th should be in conjunction in a kendra aspected by the lord of the Navamsa occupied by the ascendant lord.
- **Effects/Benefits**: The person acquries immense riches in the early part of life.
- **Notes/Reference**: BVR-135 Balya Dhana Yoga
    Three conditions have to be fulfilled for its presence, viz., 
    (a) the 2nd and 10th lords should be in conjunction; 
    (b) they must occupy a kendra from Lagna, and 
    (c) they must be aspected by the planet who owns the Navamsa in which the lord of Lagna is located.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    BVR-135 Balya Dhana Yoga
    Three conditions have to be fulfilled for its presence, viz., 
    (a) the 2nd and 10th lords should be in conjunction; 
    (b) they must occupy a kendra from Lagna, and 
    (c) they must be aspected by the planet who owns the Navamsa in which the lord of Lagna is located.
    """
    return _balya_dhana_yoga_calculation(chart_rasi=chart_rasi, chart_navamsa=chart_navamsa,
                                         natural_benefics=natural_benefics)
```

---

### Bhandhana Yoga

- **PyJHora Function/Key**: `bhandhana_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 271 - The lord of the Lagna and the 6th join a kendra or thrikona with Saturn, Rahu or Kethu, the above yoga is given rise to.
- **Effects/Benefits**: The native will be incarcerated.
- **Notes/Reference**: 271 - The lord of the Lagna and the 6th conjoin with Saturn or Rahu or Kethu, in a kendra or thrikona  
        the above yoga is given rise to.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        271 - The lord of the Lagna and the 6th conjoin with Saturn or Rahu or Kethu, in a kendra or thrikona  
        the above yoga is given rise to.
    """
    return _bhandhana_yoga_calculation(chart_1d=chart_1d)
```

---

### Dhana Yoga

- **PyJHora Function/Key**: `dhana_yoga_128` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Venus should be in Lagna identicalwith his own sign and joined or aspectedby Saturn and Mercury.
- **Effects/Benefits**: You will accumulate significant wealth, enjoy financial prosperity, and lead a comfortable life with multiple sources of income.
- **Notes/Reference**: Dhana Yogas (B.V. Raman #128)
    Venus should be in Lagna identicalwith his own sign and joined or aspectedby Saturn and Mercury

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Dhana Yogas (B.V. Raman #128)
    Venus should be in Lagna identicalwith his own sign and joined or aspectedby Saturn and Mercury
    """
    if planet_positions_rasi is not None:
        chart_rasi = utils.get_house_planet_list_from_planet_positions(planet_positions_rasi)
    
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_rasi)
    asc_house = p_to_h.get(const._ascendant_symbol)
    # Helper: Check if a planet is influenced (conjoined or aspected) by targets
    def is_planet_influenced_by(target_p_id, influencers):
        # 1. Get planets aspecting the target planet
        aspecting = house.planets_aspecting_the_planet(chart_rasi, target_p_id)
        # 2. Check each influencer
        for inf_id in influencers:
            # Check for Conjunction (In the same house)
            conjoined = (p_to_h.get(target_p_id) == p_to_h.get(inf_id))
            # Check for Aspect
            aspected = inf_id in aspecting
            if not (conjoined or aspected):
                return False
        return True
    # 128: Venus in Taurus/Libra Lagna + Saturn and Mercury
    return ( (asc_house in [const.TAURUS, const.LIBRA] and p_to_h.get(const.VENUS_ID) == asc_house) and
             (is_planet_influenced_by(const.VENUS_ID, [const.SATURN_ID, const.MERCURY_ID]))
        )
```

---

### Dhana Yoga

- **PyJHora Function/Key**: `dhana_yoga_127` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Jupiter should be in Lagna identical with his own sign and joined or aspected by Mercury and Mars.
- **Effects/Benefits**: You will accumulate significant wealth, enjoy financial prosperity, and lead a comfortable life with multiple sources of income.
- **Notes/Reference**: Dhana Yogas (B.V. Raman #127)
    Jupiter should be in Lagna identical with his own sign and joined or aspected by Mercury and Mars.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Dhana Yogas (B.V. Raman #127)
    Jupiter should be in Lagna identical with his own sign and joined or aspected by Mercury and Mars.
    """
    if planet_positions_rasi is not None:
        chart_rasi = utils.get_house_planet_list_from_planet_positions(planet_positions_rasi)
    
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_rasi)
    asc_house = p_to_h.get(const._ascendant_symbol)
    # Helper: Check if a planet is influenced (conjoined or aspected) by targets
    def is_planet_influenced_by(target_p_id, influencers):
        # 1. Get planets aspecting the target planet
        aspecting = house.planets_aspecting_the_planet(chart_rasi, target_p_id)
        # 2. Check each influencer
        for inf_id in influencers:
            # Check for Conjunction (In the same house)
            conjoined = (p_to_h.get(target_p_id) == p_to_h.get(inf_id))
            # Check for Aspect
            aspected = inf_id in aspecting
            if not (conjoined or aspected):
                return False
        return True
    # 127: Jupiter in Sagit/Pisces Lagna + Mercury and Mars
    return ( (asc_house in [const.SAGITTARIUS, const.PISCES] and p_to_h.get(const.JUPITER_ID) == asc_house) and 
        ( is_planet_influenced_by(const.JUPITER_ID, [const.MERCURY_ID, const.MARS_ID]))
        )
```

---

### Dhana Yoga

- **PyJHora Function/Key**: `dhana_yoga_126` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Mercury should be in Lagna identical with his own sign and joined or aspectedby Saturn and Venus.
- **Effects/Benefits**: You will accumulate significant wealth, enjoy financial prosperity, and lead a comfortable life with multiple sources of income.
- **Notes/Reference**: Dhana Yogas (B.V. Raman #126)
    Mercury should be in Lagna identical with his own sign and joined or aspectedby Saturn and Venus.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Dhana Yogas (B.V. Raman #126)
    Mercury should be in Lagna identical with his own sign and joined or aspectedby Saturn and Venus.
    """
    if planet_positions_rasi is not None:
        chart_rasi = utils.get_house_planet_list_from_planet_positions(planet_positions_rasi)
    
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_rasi)
    asc_house = p_to_h.get(const._ascendant_symbol)
    # Helper: Check if a planet is influenced (conjoined or aspected) by targets
    def is_planet_influenced_by(target_p_id, influencers):
        # 1. Get planets aspecting the target planet
        aspecting = house.planets_aspecting_the_planet(chart_rasi, target_p_id)
        # 2. Check each influencer
        for inf_id in influencers:
            # Check for Conjunction (In the same house)
            conjoined = (p_to_h.get(target_p_id) == p_to_h.get(inf_id))
            # Check for Aspect
            aspected = inf_id in aspecting
            if not (conjoined or aspected):
                return False
        return True
    # 126: Mercury in Gemini/Virgo Lagna + Saturn and Venus
    return ( (asc_house in [const.GEMINI, const.VIRGO] and p_to_h.get(const.MERCURY_ID) == asc_house) and
        (is_planet_influenced_by(const.MERCURY_ID, [const.SATURN_ID, const.VENUS_ID]))
        )
```

---

### Dhana Yoga

- **PyJHora Function/Key**: `dhana_yoga_125` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Mars should be in Lagna identical with Aries or Scorpio and joined or aspectedby the Moon, Venus and Saturn.
- **Effects/Benefits**: You will accumulate significant wealth, enjoy financial prosperity, and lead a comfortable life with multiple sources of income.
- **Notes/Reference**: Dhana Yogas (B.V. Raman #125)
    Mars should be in Lagna identical with Aries or Scorpio and joined or aspectedby the Moon, Venus and Saturn.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Dhana Yogas (B.V. Raman #125)
    Mars should be in Lagna identical with Aries or Scorpio and joined or aspectedby the Moon, Venus and Saturn.
    """
    if planet_positions_rasi is not None:
        chart_rasi = utils.get_house_planet_list_from_planet_positions(planet_positions_rasi)
    
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_rasi)
    asc_house = p_to_h.get(const._ascendant_symbol)
    # Helper: Check if a planet is influenced (conjoined or aspected) by targets
    def is_planet_influenced_by(target_p_id, influencers):
        # 1. Get planets aspecting the target planet
        aspecting = house.planets_aspecting_the_planet(chart_rasi, target_p_id)
        # 2. Check each influencer
        for inf_id in influencers:
            # Check for Conjunction (In the same house)
            conjoined = (p_to_h.get(target_p_id) == p_to_h.get(inf_id))
            # Check for Aspect
            aspected = inf_id in aspecting
            if not (conjoined or aspected):
                return False
        return True

    # 125: Mars in Aries/Scorpio Lagna + Moon, Venus, Saturn
    return ( (asc_house in [const.ARIES, const.SCORPIO] and p_to_h.get(const.MARS_ID) == asc_house) and 
              (is_planet_influenced_by(const.MARS_ID, [const.MOON_ID, const.VENUS_ID, const.SATURN_ID]))
        )
```

---

### Dhana Yoga

- **PyJHora Function/Key**: `dhana_yoga_124` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If the Moon is in Lagna identical with Cancer and aspectedby Jupiter and Mars, this yoga is caused.
- **Effects/Benefits**: You will accumulate significant wealth, enjoy financial prosperity, and lead a comfortable life with multiple sources of income.
- **Notes/Reference**: Dhana Yogas (B.V. Raman #124)
    If the Moon is in Lagna identical with Cancer and aspectedby Jupiter and Mars, this yoga is caused.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Dhana Yogas (B.V. Raman #124)
    If the Moon is in Lagna identical with Cancer and aspectedby Jupiter and Mars, this yoga is caused.
    """
    if planet_positions_rasi is not None:
        chart_rasi = utils.get_house_planet_list_from_planet_positions(planet_positions_rasi)
    
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_rasi)
    asc_house = p_to_h.get(const._ascendant_symbol)
    # Helper: Check if a planet is influenced (conjoined or aspected) by targets
    def is_planet_influenced_by(target_p_id, influencers):
        # 1. Get planets aspecting the target planet
        aspecting = house.planets_aspecting_the_planet(chart_rasi, target_p_id)
        # 2. Check each influencer
        for inf_id in influencers:
            # Check for Conjunction (In the same house)
            conjoined = (p_to_h.get(target_p_id) == p_to_h.get(inf_id))
            # Check for Aspect
            aspected = inf_id in aspecting
            if not (conjoined or aspected):
                return False
        return True
    # 124: Moon in Cancer Lagna + Jupiter and Mars
    return ( (asc_house == const.CANCER and p_to_h.get(const.MOON_ID) == asc_house) and 
             (is_planet_influenced_by(const.MOON_ID, [const.JUPITER_ID, const.MARS_ID]))
            )
```

---

### Dhana Yoga

- **PyJHora Function/Key**: `dhana_yoga_123` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If the Sun is in Lagna identical with Leo, and aspected or joined by Mars and Jupiter, this yoga is formed.
- **Effects/Benefits**: You will accumulate significant wealth, enjoy financial prosperity, and lead a comfortable life with multiple sources of income.
- **Notes/Reference**: Dhana Yogas (B.V. Raman #123)
    "If the Sun is in Lagna identical with Leo, and aspected or joined by Mars and Jupiter, this yoga is formed.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Dhana Yogas (B.V. Raman #123)
    "If the Sun is in Lagna identical with Leo, and aspected or joined by Mars and Jupiter, this yoga is formed.
    """
    if planet_positions_rasi is not None:
        chart_rasi = utils.get_house_planet_list_from_planet_positions(planet_positions_rasi)
    
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_rasi)
    asc_house = p_to_h.get(const._ascendant_symbol)
    # Helper: Check if a planet is influenced (conjoined or aspected) by targets
    def is_planet_influenced_by(target_p_id, influencers):
        # 1. Get planets aspecting the target planet
        aspecting = house.planets_aspecting_the_planet(chart_rasi, target_p_id)
        # 2. Check each influencer
        for inf_id in influencers:
            # Check for Conjunction (In the same house)
            conjoined = (p_to_h.get(target_p_id) == p_to_h.get(inf_id))
            # Check for Aspect
            aspected = inf_id in aspecting
            if not (conjoined or aspected):
                return False
        return True
    # 123: Sun in Leo Lagna + Mars and Jupiter
    return ( (asc_house == const.LEO and p_to_h.get(const.SUN_ID) == asc_house) and 
             (is_planet_influenced_by(const.SUN_ID, [const.MARS_ID, const.JUPITER_ID]))
           )
```

---

### Dhana Yoga

- **PyJHora Function/Key**: `dhana_yoga_122` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If the 5th from Lagna happens to be a house of Jupiter with Jupiter there and Mars and the Moon  in the 11th, Dhana Yoga arises.
- **Effects/Benefits**: You will accumulate significant wealth, enjoy financial prosperity, and lead a comfortable life with multiple sources of income.
- **Notes/Reference**: Dhana Yogas (B.V. Raman #122)
    If the 5th from Lagna happens to be a house of Jupiter with Jupiter there and Mars and the Moon 
    in the 11th, Dhana Yoga arises.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Dhana Yogas (B.V. Raman #122)
    If the 5th from Lagna happens to be a house of Jupiter with Jupiter there and Mars and the Moon 
    in the 11th, Dhana Yoga arises.
    """
    if planet_positions_rasi is not None:
        chart_rasi = utils.get_house_planet_list_from_planet_positions(planet_positions_rasi)
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_rasi)
    asc_house = p_to_h.get(const._ascendant_symbol)
    # h5 is 4 houses away from Lagna; h11 is 10 houses away from Lagna
    h5 = (asc_house + const.HOUSE_5) % 12
    h11 = (asc_house + const.HOUSE_11) % 12
    pos = {p: p_to_h.get(p) for p in range(9)}
    # 122: 5th is Jupiter sign (Sagittarius/Pisces), Jupiter in 5th, Mars & Moon in 11th
    return h5 in [const.SAGITTARIUS, const.PISCES] and pos[const.JUPITER_ID] == h5 and \
       pos[const.MARS_ID] == h11 and pos[const.MOON_ID] == h11
```

---

### Dhana Yoga

- **PyJHora Function/Key**: `dhana_yoga_121` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The Sun must occupy the 5th identical with his own sign and Jupiter and the Moon should be in the 11th.
- **Effects/Benefits**: You will accumulate significant wealth, enjoy financial prosperity, and lead a comfortable life with multiple sources of income.
- **Notes/Reference**: Dhana Yogas (B.V. Raman #121)
    The Sun must occupy the 5th identical with his own sign and Jupiter and the Moon should be in the 11th.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Dhana Yogas (B.V. Raman #121)
    The Sun must occupy the 5th identical with his own sign and Jupiter and the Moon should be in the 11th.
    """
    if planet_positions_rasi is not None:
        chart_rasi = utils.get_house_planet_list_from_planet_positions(planet_positions_rasi)
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_rasi)
    asc_house = p_to_h.get(const._ascendant_symbol)
    # h5 is 4 houses away from Lagna; h11 is 10 houses away from Lagna
    h5 = (asc_house + const.HOUSE_5) % 12
    h11 = (asc_house + const.HOUSE_11) % 12
    pos = {p: p_to_h.get(p) for p in range(9)}
    # 121: 5th is Sun sign (Leo), Sun in 5th, Jupiter & Moon in 11th
    return h5 == const.LEO and pos[const.SUN_ID] == h5 and \
       pos[const.JUPITER_ID] == h11 and pos[const.MOON_ID] == h11
```

---

### Dhana Yoga

- **PyJHora Function/Key**: `dhana_yoga_120` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Saturn should occupy his own sign which shouldbe the 5th from Lagna, and Mercury and Mars should be posited in the 11th.
- **Effects/Benefits**: You will accumulate significant wealth, enjoy financial prosperity, and lead a comfortable life with multiple sources of income.
- **Notes/Reference**: Dhana Yogas (B.V. Raman #120)
    Saturn should occupy his own sign which shouldbe the 5th from Lagna, and Mercury and Mars 
    should be posited in the 11th.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Dhana Yogas (B.V. Raman #120)
    Saturn should occupy his own sign which shouldbe the 5th from Lagna, and Mercury and Mars 
    should be posited in the 11th.
    """
    if planet_positions_rasi is not None:
        chart_rasi = utils.get_house_planet_list_from_planet_positions(planet_positions_rasi)
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_rasi)
    asc_house = p_to_h.get(const._ascendant_symbol)
    # h5 is 4 houses away from Lagna; h11 is 10 houses away from Lagna
    h5 = (asc_house + const.HOUSE_5) % 12
    h11 = (asc_house + const.HOUSE_11) % 12
    pos = {p: p_to_h.get(p) for p in range(9)}
    # 120: 5th is Saturn sign (Capricorn/Aquarius), Saturn in 5th, Mercury & Mars in 11th
    return h5 in [const.CAPRICORN, const.AQUARIUS] and pos[const.SATURN_ID] == h5 and \
       pos[const.MERCURY_ID] == h11 and pos[const.MARS_ID] == h11
    #return False
```

---

### Dhana Yoga

- **PyJHora Function/Key**: `dhana_yoga_119` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Mercury should occupy his own sign which should be the 5th from Lagna and the Moon and Mars should be in the 11th.
- **Effects/Benefits**: You will accumulate significant wealth, enjoy financial prosperity, and lead a comfortable life with multiple sources of income.
- **Notes/Reference**: Dhana Yogas (B.V. Raman #119)
    Mercury should occupy his own sign which should be the 5th from Lagna and the Moon and Mars should be in the 11th.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Dhana Yogas (B.V. Raman #119)
    Mercury should occupy his own sign which should be the 5th from Lagna and the Moon and Mars should be in the 11th.
    """
    if planet_positions_rasi is not None:
        chart_rasi = utils.get_house_planet_list_from_planet_positions(planet_positions_rasi)
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_rasi)
    asc_house = p_to_h.get(const._ascendant_symbol)
    # h5 is 4 houses away from Lagna; h11 is 10 houses away from Lagna
    h5 = (asc_house + const.HOUSE_5) % 12
    h11 = (asc_house + const.HOUSE_11) % 12
    pos = {p: p_to_h.get(p) for p in range(9)}
    # 119: 5th is Mercury sign (Gemini/Virgo), Mercury in 5th, Moon & Mars in 11th
    return h5 in [const.GEMINI, const.VIRGO] and pos[const.MERCURY_ID] == h5 and \
       pos[const.MOON_ID] == h11 and pos[const.MARS_ID] == h11
```

---

### Dhana Yoga

- **PyJHora Function/Key**: `dhana_yoga_118` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If the 5th from the Ascendant happens to be a sign of Venus, and if Venus and Saturn are situated in the 5th and 11th respectively, Dhana Yoga is caused.
- **Effects/Benefits**: You will accumulate significant wealth, enjoy financial prosperity, and lead a comfortable life with multiple sources of income.
- **Notes/Reference**: Dhana Yogas (B.V. Raman #118)
    If the 5th from the Ascendant happens to be a sign of Venus, and if Venus and Saturn are situated 
    in the 5th and 11th respectively, Dhana Yoga is caused.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Dhana Yogas (B.V. Raman #118)
    If the 5th from the Ascendant happens to be a sign of Venus, and if Venus and Saturn are situated 
    in the 5th and 11th respectively, Dhana Yoga is caused.
    """
    if planet_positions_rasi is not None:
        chart_rasi = utils.get_house_planet_list_from_planet_positions(planet_positions_rasi)
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_rasi)
    asc_house = p_to_h.get(const._ascendant_symbol)
    # h5 is 4 houses away from Lagna; h11 is 10 houses away from Lagna
    h5 = (asc_house + const.HOUSE_5) % 12
    h11 = (asc_house + const.HOUSE_11) % 12
    pos = {p: p_to_h.get(p) for p in range(9)}
    # 118: 5th is Venus sign (Taurus/Libra), Venus in 5th, Saturn in 11th
    return h5 in [const.TAURUS, const.LIBRA] and pos[const.VENUS_ID] == h5 and pos[const.SATURN_ID] == h11
```

---

### Kalatramooladdhana Yoga

- **PyJHora Function/Key**: `kalatramooladdhana_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The 2nd lord is associated with the 7th lord or placed in the 7th house with benefics.
- **Effects/Benefits**: You will gain wealth and assets through your spouse or your marriage partner's family.
- **Notes/Reference**: Kalatramooladdhana Yoga (BV Raman 141)
    Definition: The strong lord of the 2nd should join or be aspected by 
    the 7th lord and Venus and the lord of Lagna must be powerful.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Kalatramooladdhana Yoga (BV Raman 141)
    Definition: The strong lord of the 2nd should join or be aspected by 
    the 7th lord and Venus and the lord of Lagna must be powerful.
    """
    return _kalatramooladdhana_yoga_calculation(chart_1d)
```

---

### Kulavardhana Yoga

- **PyJHora Function/Key**: `kulavardhana_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If each planet occupies the 5th house from either lagna or Moon or Sun, then this yoga is present.
- **Effects/Benefits**: One born with this yoga is happy, wealthy and brings name to his lineage and community. Person has an unbroken line of worthy successors. Kula means 'lineage or community''. Vardhana means 'one who makes it grow and prosper'.
- **Notes/Reference**: BVR-70 Kulavardhana Yoga: 
    If each planet (Sun to Saturn) occupies the 5th house from either:
    (1) Lagna, (2) Moon, or (3) Sun.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" 
    BVR-70 Kulavardhana Yoga: 
    If each planet (Sun to Saturn) occupies the 5th house from either:
    (1) Lagna, (2) Moon, or (3) Sun.
    """
    return _kulavardhana_yoga_calculation(chart_1d=chart_1d)
```

---

### Madhya Vayasi Dhana Yoga

- **PyJHora Function/Key**: `madhya_vayasi_dhana_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The lords of the Lagna, 2nd, and 11th houses are placed in Kendras or Thrikonas.
- **Effects/Benefits**: You will experience a significant rise in wealth and financial status during the middle part of your life.
- **Notes/Reference**: BVR-133 Madhya Vayasi Dhana Yoga
    Covers wealth acquired or peaking in middle age.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    BVR-133 Madhya Vayasi Dhana Yoga
    Covers wealth acquired or peaking in middle age.
    """
    return _madhya_vayasi_dhana_yoga_calculation(chart_rasi=chart_rasi)
```

---

### Matrumooladdhana Yoga

- **PyJHora Function/Key**: `matrumooladdhana_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The 2nd lord is associated with the 4th lord or placed in the 4th house with strong benefic influence.
- **Effects/Benefits**: You will inherit or gain wealth and assets through your mother or from your maternal side of the family.
- **Notes/Reference**: Matrumooladdhana Yoga (BV Raman 138)
    Definition: If the lord of the 2nd joins the 4th lord or is aspected by him.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Matrumooladdhana Yoga (BV Raman 138)
    Definition: If the lord of the 2nd joins the 4th lord or is aspected by him.
    """
    return _matrumooladdhana_yoga_calculation(chart_1d)
```

---

### Putramooladdhana Yoga

- **PyJHora Function/Key**: `putramooladdhana_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The 2nd lord is associated with the 5th lord or placed in the 5th house.
- **Effects/Benefits**: You will gain wealth through your children, or your children will become a source of great financial prosperity for you.
- **Notes/Reference**: Putramooladdhana Yoga (BV Raman 139)
    Definition: If the strong lord of the 2nd is in conjunction with the 5th lord 
    or Jupiter and if the lord of Lagna is in Vaiseshikamsa.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Putramooladdhana Yoga (BV Raman 139)
    Definition: If the strong lord of the 2nd is in conjunction with the 5th lord 
    or Jupiter and if the lord of Lagna is in Vaiseshikamsa.
    """
    return _putramooladdhana_yoga_calculation(chart_1d)
```

---

### Shatrumooladdhana Yoga

- **PyJHora Function/Key**: `shatrumooladdhana_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The 2nd lord is associated with the 6th lord or placed in the 6th house, and the 6th lord is in a benefic house.
- **Effects/Benefits**: You will gain wealth through your enemies, competitions, or litigation.
- **Notes/Reference**: Shatrumooladdhana Yoga (BV Raman 140)
    Definition: The strong lord of the 2nd should join the lord of the 6th or Mars 
    and the powerful lord of Lagna should be in Vaiseshikamsa.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Shatrumooladdhana Yoga (BV Raman 140)
    Definition: The strong lord of the 2nd should join the lord of the 6th or Mars 
    and the powerful lord of Lagna should be in Vaiseshikamsa.
    """
    return _shatrumooladdhana_yoga_calculation(chart_1d)
```

---

### Swaveeryaddhana Yoga

- **PyJHora Function/Key**: `swaveeryaddhana_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The Lagna lord is the strongest planet in the chart and is placed in a Kendra, associated with the 2nd lord.
- **Effects/Benefits**: You will earn wealth solely through your own efforts, hard work, and personal prowess, without much ancestral help.
- **Notes/Reference**: BVR-130-132 Swaveeryaddhana Yoga (Wealth by own effort) 
    and detailed varga/dispositor conditions.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    BVR-130-132 Swaveeryaddhana Yoga (Wealth by own effort) 
    and detailed varga/dispositor conditions.
    """
    return _swaveeryaddhana_yoga_calculation(chart_rasi=chart_rasi, chart_navamsa=chart_navamsa,natural_benefics=natural_benefics)
```

---

## Longevity & Health Yogas

Total yogas in this category: **5**

### Dhurmarana Yoag

- **PyJHora Function/Key**: `dhurmarana_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 274 - The Moon being aspected by lord of Lagna should occupy the 6th, 8th or 12th in association/conjunction with Saturn, Mandi or Rahu.
- **Effects/Benefits**: The person will meet with unnatural death

---

### Jananatpurvam Pithru Marana Yoga

- **PyJHora Function/Key**: `jananatpurvam_pitru_marana_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 242 - The Sun must be in the 6th, 8th or 12th; lord of the 8th must be in the 9th; lord of the 12th in Lagna and the lord of the 6th in the 5th.
- **Effects/Benefits**: The person will be a posthumous child.
- **Notes/Reference**: 242 - The Sun must be in the 6th, 8th or 12th; lord of the 8th must be in the 9th; 
            lord of the 12th in Lagna and the lord of the 6th in the 5th.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        242 - The Sun must be in the 6th, 8th or 12th; lord of the 8th must be in the 9th; 
            lord of the 12th in Lagna and the lord of the 6th in the 5th.
    """
    return _jananatpurvam_pitru_marana_yoga_calculation(chart_1d=chart_1d)
```

---

### Maathru dheerghayur Yoga

- **PyJHora Function/Key**: `matrudeerghayur_yoga_196` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 196 -  benefic must occupy the 4th, the 4th lord must be exalted, and the Moon must be strong.
- **Effects/Benefits**: The native's mother will live long.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        196 -  benefic must occupy the 4th, the 4th lord must be exalted, and the Moon must be strong.
    """
    if planet_positions is not None:
        chart_1d = utils.get_house_planet_list_from_planet_positions(planet_positions)
    if chart_1d is None: return False
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    lagna_house = p_to_h['L']
    house_4_rasi = (lagna_house + const.HOUSE_4) % 12
    if planet_positions is not None:
        lord_4 = int(house.house_owner_from_planet_positions(planet_positions, house_4_rasi))
    else:
        lord_4 = int(house.house_owner(chart_1d, house_4_rasi))
    _natural_benefics = _get_natural_benefics(chart_1d, natural_benefics)
    # Criteria A: Benefic in the 4th house
    planets_in_4th = planets_in_raasi(house_4_rasi,p_to_h,exclude_lagna=True)
    has_benefic_in_4th = any(p in _natural_benefics for p in planets_in_4th)
    # Criteria B: 4th Lord must be Exalted (4) [cite: 6, 7]
    lord_4_rasi = p_to_h[lord_4]
    is_lord_4_exalted = const.house_strengths_of_planets[lord_4][lord_4_rasi] >= const._EXALTED_UCCHAM
    # Criteria C: Moon must be strong (Exalted or Ruler) [cite: 7]
    is_moon_strong = const.house_strengths_of_planets[const.MOON_ID][p_to_h[const.MOON_ID]] >= const._EXALTED_UCCHAM
    return has_benefic_in_4th and is_lord_4_exalted and is_moon_strong
```

---

### Maathru dheerghayur Yoga

- **PyJHora Function/Key**: `matrudeerghayur_yoga_197` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 197 - The lord of the navamsaoccupiedby the 4th lord should be strong and occupy a kendra from Lagna as well as Chandra Lagna.
- **Effects/Benefits**: The native's mother will live long.
- **Notes/Reference**: 197 - The lord of the navamsaoccupiedby the 4th lord should be strong and occupy a kendra from Lagna
        as well as Chandra Lagna.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        197 - The lord of the navamsaoccupiedby the 4th lord should be strong and occupy a kendra from Lagna
        as well as Chandra Lagna.
    """
    if planet_positions_rasi is not None:
        chart_rasi = utils.get_house_planet_list_from_planet_positions(planet_positions_rasi)
        if planet_positions_navamsa is None:
            planet_positions_navamsa = charts.navamsa_chart(planet_positions_rasi)[:const._pp_count_upto_ketu]
    if chart_rasi is None: return False
    if planet_positions_navamsa is not None:
        chart_navamsa = utils.get_house_planet_list_from_planet_positions(planet_positions_navamsa)
    if chart_navamsa is None: return False
    p_to_h_rasi = utils.get_planet_to_house_dict_from_chart(chart_rasi)
    p_to_h_nav = utils.get_planet_to_house_dict_from_chart(chart_navamsa)
    # 1. Find 4th lord of Rasi
    lagna_rasi = p_to_h_rasi['L']
    house_4_rasi_idx = (lagna_rasi + const.HOUSE_4) % 12
    if planet_positions_rasi is not None:
        lord_4_rasi = int(house.house_owner_from_planet_positions(planet_positions_rasi, house_4_rasi_idx))
    else:
        lord_4_rasi = int(house.house_owner(chart_rasi, house_4_rasi_idx))
    # 2. Find the Navamsa Rasi occupied by that 4th lord
    navamsa_rasi_of_4th_lord = p_to_h_nav[lord_4_rasi]
    # 3. Find the Lord of that Navamsa Rasi (Navamsa Lord)
    if planet_positions_navamsa is not None:
        nav_lord = int(house.house_owner_from_planet_positions(planet_positions_navamsa, navamsa_rasi_of_4th_lord))
    else:
        nav_lord = int(house.house_owner(chart_navamsa, navamsa_rasi_of_4th_lord))
    # [cite_start]4. Criteria: Navamsa Lord must be strong (in Rasi chart) [cite: 7]
    nav_lord_rasi_pos = p_to_h_rasi[nav_lord]
    is_nav_lord_strong = const.house_strengths_of_planets[nav_lord][nav_lord_rasi_pos] >= const._OWNER_RULER
    # 5. Criteria: Occupy Kendra from Lagna and Chandra Lagna (in Rasi)
    kendra_from_lagna = quadrants_of_the_house(lagna_rasi)
    chandra_lagna = p_to_h_rasi[const.MOON_ID]
    kendra_from_chandra = quadrants_of_the_house(chandra_lagna)
    nav_lord_house = p_to_h_rasi[nav_lord]
    in_kendra = (nav_lord_house in kendra_from_lagna) and (nav_lord_house in kendra_from_chandra)
    return is_nav_lord_strong and in_kendra
```

---

### Yuddha Marana Yoga

- **PyJHora Function/Key**: `yuddha_marana_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 275 - Mars, being lord of the 6th or 8th, should conjoin the 3rd lord and Rahu, Saturn or Maandi in cruel shashti-amsas.
- **Effects/Benefits**: The personwill be killed in battle or due to consequences of war.

---

## Nabhasa Yogas

Total yogas in this category: **34**

### Chaapa Yoga

- **PyJHora Function/Key**: `chaapa_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All the planets occupy the 7 signs from the 10th house.
- **Effects/Benefits**: One born with this yoga becomes a liar, thief and a protector of secrets. This person wanders in forests. This person is unfortunate. This person is happy in the middle part of the life. Chaapa means a bow.

**Python Logic Summary (PyJHora Implementation)**:
```python
# V4.6.0
    """ BVR-78 Chaapa Yoga: If all the planets occupy the 7 signs from the 10th house, """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    base_house = (p_to_h[const._ascendant_symbol]+const.HOUSE_10)%12
    # Seven consecutive houses from Base House
    valid_houses = [(base_house + offset) % 12 for offset in const.SUN_TO_SATURN]
    valid_houses_set = set(valid_houses)
    # 1) Every visible planet must lie within the 7-house span.
    all_in_span = all(p_to_h.get(pid) in valid_houses_set for pid in SUN_TO_SATURN)
    if not all_in_span:
        return False
    # 2) Each of the seven houses in the span must be occupied by at least one visible planet.
    house_to_visible = {h: set() for h in range(12)}
    for pid in SUN_TO_SATURN:
        h = p_to_h.get(pid)
        if h is not None:
            house_to_visible[h].add(pid)
    all_occupied = all(len(house_to_visible[h]) > 0 for h in valid_houses)
    return all_occupied
```

---

### Chakra Yoga

- **PyJHora Function/Key**: `chakra_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All the planets occupy 1st, 3rd, 5th, 7th, 9th and 11th houses from the lagna.
- **Effects/Benefits**: One born with this yoga becomes a great emperor. Diamond-studded crowns of many kings touch this person's feet (i.e. many kings prostate before this person). Chakra means a wheel. Chakravarti means an emperor.
- **Notes/Reference**: BVR-80 Chakra/Chandra Yoga: If all the planets occupy 1st, 3rd, 5th, 7th, 9th and 11th houses

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-80 Chakra/Chandra Yoga: If all the planets occupy 1st, 3rd, 5th, 7th, 9th and 11th houses """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    asc_house = p_to_h[const._ascendant_symbol]
    _valid_houses = [const.HOUSE_1,const.HOUSE_3,const.HOUSE_5,const.HOUSE_7,const.HOUSE_9,const.HOUSE_11]
    valid_houses = [(asc_house + offset) % 12 for offset in _valid_houses]
    valid_houses_set = set(valid_houses)
    # 1) Every visible planet must lie within valid houses
    all_in_span = all(p_to_h.get(pid) in valid_houses_set for pid in SUN_TO_SATURN)
    if not all_in_span:
        return False
    # 2) Each of the valid houses must be occupied by at least one visible planet.
    house_to_visible = {h: set() for h in range(12)}
    for pid in SUN_TO_SATURN:
        h = p_to_h.get(pid)
        if h is not None:
            house_to_visible[h].add(pid)
    all_occupied = all(len(house_to_visible[h]) > 0 for h in valid_houses)
    return all_occupied
```

---

### Chatra Yoga

- **PyJHora Function/Key**: `chatra_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All the planets occupy the 7 signs from the 7th house.
- **Effects/Benefits**: One born with this yoga will help his people. This person is kind and liked by many kings. This person is intelligent. This person is happy in the early and late parts of life. This person is longlived. Chatra means an umbrella.
- **Notes/Reference**: BVR-77 Chatra Yoga: If all the planets occupy the 7 signs from the 7th house,

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-77 Chatra Yoga: If all the planets occupy the 7 signs from the 7th house, """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    base_house = (p_to_h[const._ascendant_symbol]+const.HOUSE_7)%12
    # Seven consecutive houses from Base House
    span7 = [(base_house + offset) % 12 for offset in const.SUN_TO_SATURN]
    span7_set = set(span7)
    # 1) Every visible planet must lie within the 7-house span.
    all_in_span = all(p_to_h.get(pid) in span7_set for pid in SUN_TO_SATURN)
    if not all_in_span:
        return False
    # 2) Each of the seven houses in the span must be occupied by at least one visible planet.
    house_to_visible = {h: set() for h in range(12)}
    for pid in SUN_TO_SATURN:
        h = p_to_h.get(pid)
        if h is not None:
            house_to_visible[h].add(pid)
    all_occupied = all(len(house_to_visible[h]) > 0 for h in span7)
    return all_occupied
```

---

### Daama Yoga

- **PyJHora Function/Key**: `daama_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The seven planets occupy exactly 6 distinct signs among them.
- **Effects/Benefits**: One born with this yoga is very rich and famous. This person has many children. This person has many gems. This person helps others. Daama means a wreath. Some authors call this Daamini yoga.
- **Notes/Reference**: BVR-92 Daama/Damni Yoga: If the seven planets occupy exactly 6 distinct signs among them

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-92 Daama/Damni Yoga: If the seven planets occupy exactly 6 distinct signs among them """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    chk = set([p_to_h[p] for p in SUN_TO_SATURN])
    return len(chk) == 6
```

---

### Danda Yoga

- **PyJHora Function/Key**: `danda_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All the planets are in 10th, 11th, 12th and 1st houses from lagna.
- **Effects/Benefits**: One born with this yoga lose wife and children and their people will desert them. They are unhappy and serve mean people. Danda means a stick used to punish people.
- **Notes/Reference**: BVR-74 Danda Yoga: If all the planets are in 10th, 11th, 12th and 1st houses from lagna

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-74 Danda Yoga: If all the planets are in 10th, 11th, 12th and 1st houses from lagna """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    asc_house = p_to_h[const._ascendant_symbol]
    yoga_houses = {
        (asc_house + const.HOUSE_10)  % 12,
        (asc_house + const.HOUSE_11)  % 12,
        (asc_house + const.HOUSE_12)  % 12,
        (asc_house + const.HOUSE_1) % 12,
    }
    return all(p_to_h.get(pid) in yoga_houses for pid in SUN_TO_SATURN)
```

---

### Gadaa Yoga

- **PyJHora Function/Key**: `gadaa_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All the planets occupy two successive quadrants from lagna.
- **Effects/Benefits**: One born with this yoga possesses wealth, gold and gems. You may perform yajnas (sacrificial rites). You know sastras (sciences) and songs.
- **Notes/Reference**: BVR-81 Gadaa Yoga: all the planets occupy two successive quadrants from lagna

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-81 Gadaa Yoga: all the planets occupy two successive quadrants from lagna """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    asc_house = p_to_h[const._ascendant_symbol]
    quadrant_houses = [const.HOUSE_1, const.HOUSE_4, const.HOUSE_7, const.HOUSE_10]
    quadrant_pairs = [tuple(sorted(((asc_house+a)%12,(asc_house+b)%12))) for a,b in zip(quadrant_houses, quadrant_houses[1:]+quadrant_houses[:1])]
    sph = tuple(sorted({p_to_h[p_id] for p_id in SUN_TO_SATURN}))
    gadaa_yoga = sph in quadrant_pairs
    return gadaa_yoga
```

---

### Gola Yoga

- **PyJHora Function/Key**: `gola_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All seven planets are situated in a single sign.
- **Effects/Benefits**: You may be uneducated, destitute, and lead a life of misery, often being misunderstood by society.
- **Notes/Reference**: BVR-97 Gola Yoga: 7 planets in 1 sign (B.V. Raman #88)

**Python Logic Summary (PyJHora Implementation)**:
```python
"""BVR-97 Gola Yoga: 7 planets in 1 sign (B.V. Raman #88)"""
    return _sankhya_yoga_calculation(chart_1d=chart_1d, required_count=1)
```

---

### Hala Yoga

- **PyJHora Function/Key**: `hala_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All the planets occupy mutual trines but not trines from lagna.
- **Effects/Benefits**: One born with this yoga becomes a farmer. This person eats a lot of food. This person is poor. This person is deserted by friends and relatives. This person is unhappy and worried. Hala means a plough.
- **Notes/Reference**: BVR-87 Hala Yoga: If all the planets occupy mutual trines but not trines from lagna

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-87 Hala Yoga: If all the planets occupy mutual trines but not trines from lagna """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    asc_house = p_to_h[const._ascendant_symbol]
    slq = [tuple(sorted(((asc_house+const.HOUSE_2)%12, (asc_house+const.HOUSE_6)%12, (asc_house+const.HOUSE_10)%12))),
        tuple(sorted(((asc_house+const.HOUSE_3)%12, (asc_house+const.HOUSE_7)%12, (asc_house+const.HOUSE_11)%12))),
        tuple(sorted(((asc_house+const.HOUSE_4)%12, (asc_house+const.HOUSE_8)%12, (asc_house+const.HOUSE_12)%12)))
        ]
    sph = tuple(sorted({p_to_h[p_id] for p_id in SUN_TO_SATURN}))
    hala_yoga = sph in slq
    return hala_yoga
```

---

### Kaahala Yoga

- **PyJHora Function/Key**: `kaahala_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If (1) the 4th lord and Jupiter32 are in mutual quadrants and (2) lagna lord is strong, then this yoga is present. Alternately, this yoga is present if the 4th lord is exalted or in own sign and the 10th lord joins him.
- **Effects/Benefits**: One born with this yoga is strong, bold, cunning and leads a large army. Person owns a few villages. Kaahala means excessive. It also means mischievous.
- **Notes/Reference**: BVR-15 Kaahala Yoga: If (1) the 4th lord and Jupiter are in mutual quadrants and (2) lagna lord is strong

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-15 Kaahala Yoga: If (1) the 4th lord and Jupiter are in mutual quadrants and (2) lagna lord is strong """
    planet_positions_available = planet_positions is not None
    if planet_positions_available:
        chart_1d = utils.get_house_planet_list_from_planet_positions(planet_positions)
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    asc_house = p_to_h[const._ascendant_symbol]
    if planet_positions_available:
        fourth_lord = house.house_owner_from_planet_positions(planet_positions,(asc_house+const.HOUSE_4)%12)
        lagna_lord = house.house_owner_from_planet_positions(planet_positions,asc_house)
    else:
        fourth_lord = house.house_owner(chart_1d,(asc_house+const.HOUSE_4)%12)
        lagna_lord = house.house_owner(chart_1d,asc_house)
    ky1 = ( p_to_h[fourth_lord] in quadrants_of_the_house(p_to_h[const.JUPITER_ID]) or 
            p_to_h[const.JUPITER_ID] in quadrants_of_the_house(p_to_h[fourth_lord]) )
    if not ky1:
        return False
    ky2 = utils.is_planet_strong(lagna_lord,asc_house,include_neutral_samam=True)
    return ky1 and ky2
```

---

### Kahala Yoga

- **PyJHora Function/Key**: `kahala_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The lords of the 4th and 9th houses are in mutual Kendras and the lord of the Lagna is strong.
- **Effects/Benefits**: You will be stubborn, courageous, and perhaps hold a position of authority like a village head or an army officer.
- **Notes/Reference**: BVR-15 Kahala Yoga: L4 and L9 in mutual Kendras, and L1 is strong.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-15 Kahala Yoga: L4 and L9 in mutual Kendras, and L1 is strong. """
    return _kahala_yoga_calculation(chart_1d=chart_1d)
```

---

### Kamala Yoga

- **PyJHora Function/Key**: `kamala_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All the planets are in quadrants from lagna.
- **Effects/Benefits**: One born with this yoga becomes a king. This person has a strong character. This person is famous and long-lived. This person is pure and performs many good deeds. Kamala means a lotus.
- **Notes/Reference**: BVR-88 Kamala Yoga: If all the planets are in quadrants (kendras) from lagna, this yoga is formed.
    Subset interpretation: every considered planet lies in one of {1,4,7,10} from Lagna.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    BVR-88 Kamala Yoga: If all the planets are in quadrants (kendras) from lagna, this yoga is formed.
    Subset interpretation: every considered planet lies in one of {1,4,7,10} from Lagna.
    """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    asc_house = p_to_h[const._ascendant_symbol]
    # Kendras (quadrants) from Lagna: 1, 4, 7, 10 (mod 12)
    kendras = {
        (asc_house + const.HOUSE_1)  % 12,
        (asc_house + const.HOUSE_4)  % 12,
        (asc_house + const.HOUSE_7)  % 12,
        (asc_house + const.HOUSE_10) % 12,
    }
    # All considered planets must lie within kendras
    return all(p_to_h.get(pid) in kendras for pid in SUN_TO_SATURN)
```

---

### Kedaara Yoga

- **PyJHora Function/Key**: `kedaara_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The seven planets occupy exactly 4 distinct signs among them.
- **Effects/Benefits**: One born with this yoga is an agriculturist. This person is happy wealthy and helpful to others. Kedaara means a field.
- **Notes/Reference**: BVR-94 Kedaara Yoga: If the seven planets occupy exactly 4 distinct signs among them

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-94 Kedaara Yoga: If the seven planets occupy exactly 4 distinct signs among them """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    chk = set([p_to_h[p] for p in SUN_TO_SATURN])
    return len(chk) == 4
```

---

### Koota Yoga

- **PyJHora Function/Key**: `koota_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All the planets occupy the 7 signs from the 4th house.
- **Effects/Benefits**: One born with this yoga becomes a jailer. The person is a liar. The person lives in hills and forts. The person is poor and cruel. Koota means a group. It has several other meanings.
- **Notes/Reference**: BVR-76 Koota Yoga: If all the planets occupy the 7 signs from the 4th house

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-76 Koota Yoga: If all the planets occupy the 7 signs from the 4th house """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    base_house = (p_to_h[const._ascendant_symbol]+const.HOUSE_4)%12
    # Seven consecutive houses from Base House
    span7 = [(base_house + offset) % 12 for offset in const.SUN_TO_SATURN]
    span7_set = set(span7)
    # 1) Every visible planet must lie within the 7-house span.
    all_in_span = all(p_to_h.get(pid) in span7_set for pid in SUN_TO_SATURN)
    if not all_in_span:
        return False
    # 2) Each of the seven houses in the span must be occupied by at least one visible planet.
    house_to_visible = {h: set() for h in range(12)}
    for pid in SUN_TO_SATURN:
        h = p_to_h.get(pid)
        if h is not None:
            house_to_visible[h].add(pid)
    all_occupied = all(len(house_to_visible[h]) > 0 for h in span7)
    return all_occupied
```

---

### Maalaa Yoga

- **PyJHora Function/Key**: `maalaa_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Three quadrants are occupied by natural benefics.
- **Effects/Benefits**: You will be always happy. You will have nice clothes, vehicles, luxuries and friendship of many women.
- **Notes/Reference**: BVR-101 Srik/maalaa Yoga -  all the benefics occupy kendras, Srik Yoga is caused.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-101 Srik/maalaa Yoga -  all the benefics occupy kendras, Srik Yoga is caused."""
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    if natural_benefics is not None:
        _natural_benefics = natural_benefics
    else:
        _natural_benefics = const.natural_benefics
    if _is_mercury_benefic(chart_1d):
        _natural_benefics += [const.MERCURY_ID] 
    lagna_house = p_to_h[const._ascendant_symbol]
    kendra_houses = quadrants_of_the_house(lagna_house)
    occupied_benefic_kendras = 0
    for house_index in kendra_houses:
        planets_in_house = planets_in_raasi(house_index,p_to_h) # V4.8.0
        if any(nb in planets_in_house for nb in _natural_benefics):
            occupied_benefic_kendras += 1
    return occupied_benefic_kendras == 3
```

---

### Musala Yoga

- **PyJHora Function/Key**: `musala_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All the planets are exclusively in fixed signs.
- **Effects/Benefits**: You will have honor, wisdom and wealth. Kings will like you. You are famous and will have many children. You have a firm spirit.
- **Notes/Reference**: BVR-99 Musala Yoga: all the planets are exclusively in fixed signs

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-99 Musala Yoga: all the planets are exclusively in fixed signs """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    _musala_yoga = all(p_to_h[p] in fixed_signs for p in SUN_TO_KETU)
    return _musala_yoga
```

---

### Nala Yoga

- **PyJHora Function/Key**: `nala_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All the planets are exclusively in dual signs.
- **Effects/Benefits**: You will have a poor physique. You may accumulate money. You may have good looks and help relatives. You are skillful.
- **Notes/Reference**: BVR-100 Nala Yoga: all the planets are exclusively in dual signs,

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-100 Nala Yoga: all the planets are exclusively in dual signs, """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    _nala_yoga = all(p_to_h[p] in dual_signs for p in SUN_TO_KETU)
    return _nala_yoga
```

---

### Naukaa Yoga

- **PyJHora Function/Key**: `naukaa_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All the planets occupy the 7 signs from lagna.
- **Effects/Benefits**: One born with this yoga make money on things related to water. They have many desires. They are well-known. They are wicked, rough and miserly. Naukaa means a ship.
- **Notes/Reference**: BVR-75 Naukaa (Nauka)/Nav Yoga: All seven visible planets (Sun..Saturn) occupy the seven
    consecutive houses commencing from Lagna (1st through 7th), with none of those
    houses empty and no visible planet outside this span.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    BVR-75 Naukaa (Nauka)/Nav Yoga: All seven visible planets (Sun..Saturn) occupy the seven
    consecutive houses commencing from Lagna (1st through 7th), with none of those
    houses empty and no visible planet outside this span.
    """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    base_house = p_to_h[const._ascendant_symbol]  # 0..11
    # Seven consecutive houses from Base House
    span7 = [(base_house + offset) % 12 for offset in const.SUN_TO_SATURN]
    span7_set = set(span7)
    # 1) Every visible planet must lie within the 7-house span.
    all_in_span = all(p_to_h.get(pid) in span7_set for pid in SUN_TO_SATURN)
    if not all_in_span:
        return False
    # 2) Each of the seven houses in the span must be occupied by at least one visible planet.
    house_to_visible = {h: set() for h in range(12)}
    for pid in SUN_TO_SATURN:
        h = p_to_h.get(pid)
        if h is not None:
            house_to_visible[h].add(pid)
    all_occupied = all(len(house_to_visible[h]) > 0 for h in span7)
    return all_occupied
```

---

### Paasa Yoga

- **PyJHora Function/Key**: `paasa_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The seven planets occupy exactly 5 distinct signs among them.
- **Effects/Benefits**: One born with this yoga has the risk of being imprisoned. This person is capable in their work. This person is talkataive. This person has many servants. This person lacks character. Paasa means a noose.
- **Notes/Reference**: BVR-93 Paasa Yoga: If the seven planets occupy exactly 5 distinct signs among them

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-93 Paasa Yoga: If the seven planets occupy exactly 5 distinct signs among them """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    chk = set([p_to_h[p] for p in SUN_TO_SATURN])
    return len(chk) == 5
```

---

### Rajju Yoga

- **PyJHora Function/Key**: `rajju_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All the planets are exclusively in movable signs.
- **Effects/Benefits**: You may like to travel. You may have good looks and flourishes in foreign countries. You may be cruel.
- **Notes/Reference**: BVR-98 Rajju Yoga: all the planets are exclusively in movable signs

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-98 Rajju Yoga: all the planets are exclusively in movable signs """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    _rajju_yoga = all(p_to_h[p] in movable_signs for p in SUN_TO_KETU)
    return _rajju_yoga
```

---

### Sakata Yoga

- **PyJHora Function/Key**: `sakata_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The Moon is in the 6th, 8th or 12th house from Jupiter, provided Jupiter is not in a kendra from the Lagna.
- **Effects/Benefits**: Life will be characterized by fluctuations, like the rising and falling of a wheel. You may lose your position and reputation but can regain them. You may face poverty and misery but will be resilient.
- **Notes/Reference**: BVR-82 Sakata Yoga: If all the planets occupy 1st and 7th houses from lagna

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-82 Sakata Yoga: If all the planets occupy 1st and 7th houses from lagna """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    asc_house = p_to_h[const._ascendant_symbol]
    slq = [tuple(sorted(((asc_house+const.HOUSE_1)%12, (asc_house+const.HOUSE_7)%12)))]
    sph = tuple(sorted({p_to_h[p_id] for p_id in SUN_TO_SATURN}))
    sakata_yoga = sph in slq
    return sakata_yoga
```

---

### Sakti Yoga

- **PyJHora Function/Key**: `sakti_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All the planets are in 7th, 8th, 9th and 10th houses from lagna.
- **Effects/Benefits**: One born with this yoga are unhappy, poor, unsuccessful, unworthy, lazy, long-lived and firm. They have sharp minds in war. Sakti means energy and it is also a powerful weapon.
- **Notes/Reference**: BVR-73 Sakti Yoga: If all the planets are in 7th, 8th, 9th and 10th houses from lagna

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-73 Sakti Yoga: If all the planets are in 7th, 8th, 9th and 10th houses from lagna """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    asc_house = p_to_h[const._ascendant_symbol]
    yoga_houses = {
        (asc_house + const.HOUSE_7)  % 12,
        (asc_house + const.HOUSE_8)  % 12,
        (asc_house + const.HOUSE_9)  % 12,
        (asc_house + const.HOUSE_10) % 12,
    }
    return all(p_to_h.get(pid) in yoga_houses for pid in SUN_TO_SATURN)
```

---

### Samudra Yoga

- **PyJHora Function/Key**: `samudra_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All the planets occupy 2nd, 4th, 6th, 8th, 10th and 12th houses from the lagna.
- **Effects/Benefits**: One born with this yoga owns a lot of wealth and many gems. This person has luxuries and likes people. Their fortune and greatness are stable. They are softnatured. Samudra means a sea or an ocean. Samudra is also the name of the God of Ocean, who has a lot of wealth and many gems with this person.
- **Notes/Reference**: BVR-90 Samudra Yoga: If all the planets occupy 2nd, 4th, 6th, 8th, 10th and 12th houses

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-90 Samudra Yoga: If all the planets occupy 2nd, 4th, 6th, 8th, 10th and 12th houses """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    asc_house = p_to_h[const._ascendant_symbol]
    _valid_houses = [const.HOUSE_2,const.HOUSE_4,const.HOUSE_6,const.HOUSE_8,const.HOUSE_10,const.HOUSE_12]
    valid_houses = [(asc_house + offset) % 12 for offset in _valid_houses]
    valid_houses_set = set(valid_houses)
    # 1) Every visible planet must lie within valid houses
    all_in_span = all(p_to_h.get(pid) in valid_houses_set for pid in SUN_TO_SATURN)
    if not all_in_span:
        return False
    # 2) Each of the valid houses must be occupied by at least one visible planet.
    house_to_visible = {h: set() for h in range(12)}
    for pid in SUN_TO_SATURN:
        h = p_to_h.get(pid)
        if h is not None:
            house_to_visible[h].add(pid)
    all_occupied = all(len(house_to_visible[h]) > 0 for h in valid_houses)
    return all_occupied
```

---

### Sara Yoga

- **PyJHora Function/Key**: `sara_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All the planets are in 4th, 5th, 6th and 7th houses from lagna.
- **Effects/Benefits**: One born with this yoga makes arrows. This person heads prisons. This person is a hunter. This person eats meats. This person tortures people. Sara means an arrow.
- **Notes/Reference**: BVR-72 Sara/Ishu Yoga: all the planets are in 4th, 5th, 6th and 7th houses from lagna, 
        NOTE: BV Raman in his book states 4,5,9,7. Not sure spellinhg mistake? (method=2)

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-72 Sara/Ishu Yoga: all the planets are in 4th, 5th, 6th and 7th houses from lagna, 
        NOTE: BV Raman in his book states 4,5,9,7. Not sure spellinhg mistake? (method=2) """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    asc_house = p_to_h[const._ascendant_symbol]
    yoga_houses = {
        (asc_house + const.HOUSE_4)  % 12,
        (asc_house + const.HOUSE_5)  % 12,
        (asc_house + const.HOUSE_6)  % 12 if method==1 else (asc_house + const.HOUSE_9)  % 12,
        (asc_house + const.HOUSE_7) % 12,
    }
    return all(p_to_h.get(pid) in yoga_houses for pid in SUN_TO_SATURN)
```

---

### Sarpa Yoga

- **PyJHora Function/Key**: `sarpa_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Three quadrants are occupied by natural malefic planets.
- **Effects/Benefits**: One born with this yoga is miserable, unhappy, cruel, poor and dependent on others for food. This is a very bad combination.
- **Notes/Reference**: BVR-102 Sarpa Yoga: If three quadrants from lagna are occupied by natural malefics,

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-102 Sarpa Yoga: If three quadrants from lagna are occupied by natural malefics, """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    _natural_malefics = const.natural_malefics
    lagna_house = p_to_h[const._ascendant_symbol]
    kendra_houses = quadrants_of_the_house(lagna_house)
    occupied_benefic_kendras = 0
    for house_index in kendra_houses:
        planets_in_house = planets_in_raasi(house_index,p_to_h) # V4.8.0
        if any(nb in planets_in_house for nb in _natural_malefics):
            occupied_benefic_kendras += 1
    return occupied_benefic_kendras == 3
```

---

### Soola Yoga

- **PyJHora Function/Key**: `soola_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The seven planets occupy exactly 3 distinct signs among them.
- **Effects/Benefits**: One born with this yoga is sharp, lazy, violent, poor, prohibited and valiant. They win accolades in wars. Soola is Shiva’s weapon.
- **Notes/Reference**: BVR-95 Soola Yoga: If the seven planets occupy exactly 3 distinct signs among them

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-95 Soola Yoga: If the seven planets occupy exactly 3 distinct signs among them """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    chk = set([p_to_h[p] for p in SUN_TO_SATURN])
    return len(chk) == 3
```

---

### Srik Yoga

- **PyJHora Function/Key**: `srik_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All natural benefics (Jupiter, Venus, Mercury) occupy the Kendra houses.
- **Effects/Benefits**: You will be wealthy, enjoy many comforts, possess fine clothes and ornaments, and lead a happy, luxurious life.
- **Notes/Reference**: BVR-101 Srik/maalaa Yoga -  all the benefics occupy kendras, Srik Yoga is caused.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-101 Srik/maalaa Yoga -  all the benefics occupy kendras, Srik Yoga is caused."""
    return maalaa_yoga(chart_1d,natural_benefics=natural_benefics)
```

---

### Sringaataka Yoga

- **PyJHora Function/Key**: `sringaataka_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All the planets occupy trines (1st, 5th and 9th) from lagna.
- **Effects/Benefits**: One born with this yoga is happy and liked by kings. This person has a noble wife and hates women. This person is wealthy. Sringaataka means a cross-road junction. It has some other popular meanings too.
- **Notes/Reference**: BVR-86 Sringaataka Yoga: If all the planets occupy trines (1st, 5th and 9th) from lagna

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-86 Sringaataka Yoga: If all the planets occupy trines (1st, 5th and 9th) from lagna """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    asc_house = p_to_h[const._ascendant_symbol]
    slq = [tuple(sorted(((asc_house+const.HOUSE_1)%12, (asc_house+const.HOUSE_5)%12, (asc_house+const.HOUSE_9)%12)))]
    sph = tuple(sorted({p_to_h[p_id] for p_id in SUN_TO_SATURN}))
    sringaataka_yoga = sph in slq
    return sringaataka_yoga
```

---

### Vaapi Yoga

- **PyJHora Function/Key**: `vaapi_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All the planets are panaparas or in apoklimas from lagna.
- **Effects/Benefits**: One born with this yoga has a mind capable of amassing wealth. This person has all comforts. This person becomes a king. Vaapi means a pond or a water tank or a well.
- **Notes/Reference**: BVR-89 Vaapi Yoga: If all the planets are in Panaparas (2,5,8,11) or in Apoklimas (3,6,9,12) from Lagna.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    BVR-89 Vaapi Yoga: If all the planets are in Panaparas (2,5,8,11) or in Apoklimas (3,6,9,12) from Lagna.
    """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    asc_house = p_to_h[const._ascendant_symbol]
    panaparas = {(asc_house + const.HOUSE_2) % 12,
                 (asc_house + const.HOUSE_5) % 12,
                 (asc_house + const.HOUSE_8) % 12,
                 (asc_house + const.HOUSE_11) % 12}
    apoklimas = {(asc_house + const.HOUSE_3) % 12,
                 (asc_house + const.HOUSE_6) % 12,
                 (asc_house + const.HOUSE_9) % 12,
                 (asc_house + const.HOUSE_12) % 12}
    # Check if all planets are in panaparas OR all in apoklimas
    all_in_panaparas = all(p_to_h.get(pid) in panaparas for pid in SUN_TO_SATURN)
    all_in_apoklimas = all(p_to_h.get(pid) in apoklimas for pid in SUN_TO_SATURN)
    return all_in_panaparas or all_in_apoklimas
```

---

### Vajra Yoga

- **PyJHora Function/Key**: `vajra_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Lagna and the 7th houses are occupied by natural benefic planet and the 4th and 10th houses are occupied by natural malefic planets.
- **Effects/Benefits**: One born with this yoga is happy in the early and late parts of life. This person has valour. This person is not fortunate, but has no desires either. This person fights. Vajra means a diamond.
- **Notes/Reference**: BVR-84 Vajra Yoga (presence-based):
    - Lagna and 7th houses have at least one natural benefic present.
    - 4th and 10th houses have at least one natural malefic present.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    BVR-84 Vajra Yoga (presence-based):
    - Lagna and 7th houses have at least one natural benefic present.
    - 4th and 10th houses have at least one natural malefic present.
    """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)

    asc_house = p_to_h[const._ascendant_symbol]  # 0..11

    lagna   = (asc_house + const.HOUSE_1)  % 12
    seventh = (asc_house + const.HOUSE_7)  % 12
    fourth  = (asc_house + const.HOUSE_4)  % 12
    tenth   = (asc_house + const.HOUSE_10) % 12

    def any_in_house(planet_ids, target_house):
        return any(p_to_h.get(pid) == target_house for pid in planet_ids)

    benefic_ok = any_in_house(const.natural_benefics, lagna) and \
                 any_in_house(const.natural_benefics, seventh)

    malefic_ok = any_in_house(const.natural_malefics, fourth) and \
                 any_in_house(const.natural_malefics, tenth)

    return benefic_ok and malefic_ok
```

---

### Veenaa Yoga

- **PyJHora Function/Key**: `veenaa_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The seven planets occupy exactly 7 distinct signs among them.
- **Effects/Benefits**: One born with this yoga likes music, dance and songs. This person has many servants. This person is wealthy, skillful and a leader of men. Veenaa is a stringed musical instrument. This is also called Vallaki yoga by some authors.
- **Notes/Reference**: BVR-91 Veenaa/Vallaki Yoga: If the seven planets occupy exactly 7 distinct signs among them

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-91 Veenaa/Vallaki Yoga: If the seven planets occupy exactly 7 distinct signs among them """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    chk = set([p_to_h[p] for p in SUN_TO_SATURN])
    return (None not in chk) and (len(chk) == 7)
```

---

### Vihanga Yoga

- **PyJHora Function/Key**: `vihanga_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All planets are situated in the 4th and 10th houses.
- **Effects/Benefits**: You will be a wanderer, a traveler, or a messenger. You may be prone to acting as an intermediary and might have many secret enemies.
- **Notes/Reference**: BVR-83 Vihanga/Vihaga Yoga: If all the planets occupy 4th and 10th houses from lagna

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-83 Vihanga/Vihaga Yoga: If all the planets occupy 4th and 10th houses from lagna """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    asc_house = p_to_h[const._ascendant_symbol]
    slq = [tuple(sorted(((asc_house+const.HOUSE_4)%12, (asc_house+const.HOUSE_10)%12)))]
    sph = tuple(sorted({p_to_h[p_id] for p_id in SUN_TO_SATURN}))
    vihanga_yoga = sph in slq
    return vihanga_yoga
```

---

### Yava Yoga

- **PyJHora Function/Key**: `yava_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Lagna and the 7th houses are occupied by natural malefic planets and the 4th and 10th houses are occupied by natural benefic planets.
- **Effects/Benefits**: One born with this yoga observes religious rules. This person is happy in the middle part of life. This person has wealth and good children. This person is charitable. He is strong-minded. Yava means a grain among other things.
- **Notes/Reference**: BVR-85 Yava Yoga: If lagna and the 7th houses are occupied by natural malefics and the 4th
        and 10th houses are occupied by natural benefics,

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-85 Yava Yoga: If lagna and the 7th houses are occupied by natural malefics and the 4th
        and 10th houses are occupied by natural benefics, """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)

    asc_house = p_to_h[const._ascendant_symbol]  # 0..11

    lagna   = (asc_house + const.HOUSE_1)  % 12
    seventh = (asc_house + const.HOUSE_7)  % 12
    fourth  = (asc_house + const.HOUSE_4)  % 12
    tenth   = (asc_house + const.HOUSE_10) % 12

    def any_in_house(planet_ids, target_house):
        return any(p_to_h.get(pid) == target_house for pid in planet_ids)

    malefic_ok = any_in_house(const.natural_malefics, lagna) and \
                 any_in_house(const.natural_malefics, seventh)

    benefic_ok = any_in_house(const.natural_benefics, fourth) and \
                 any_in_house(const.natural_benefics, tenth)

    return benefic_ok and malefic_ok
```

---

### Yoopa Yoga

- **PyJHora Function/Key**: `yoopa_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All the planets are in 1st, 2nd, 3rd and 4th houses from lagna.
- **Effects/Benefits**: One born with this yoga has spiritual knowledge and knowledge of yajnas (sacrificial rites). This person's spouse is always together. This person has sattwa guna. This person observes all the religious rules. Yoopa means a pillar and in particular a sacrificial post.
- **Notes/Reference**: BVR-71 Yoopa Yoga: all the planets are in 1st, 2nd, 3rd and 4th houses from lagna

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-71 Yoopa Yoga: all the planets are in 1st, 2nd, 3rd and 4th houses from lagna """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    asc_house = p_to_h[const._ascendant_symbol]
    yoga_houses = {
        (asc_house + const.HOUSE_1)  % 12,
        (asc_house + const.HOUSE_2)  % 12,
        (asc_house + const.HOUSE_3)  % 12,
        (asc_house + const.HOUSE_4) % 12,
    }
    return all(p_to_h.get(pid) in yoga_houses for pid in SUN_TO_SATURN)
```

---

### Yuga Yoga

- **PyJHora Function/Key**: `yuga_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All seven planets are distributed among only two different signs.
- **Effects/Benefits**: You may be poor, a hypocrite, and lack social status or family happiness.
- **Notes/Reference**: BVR-96 Yuga Yoga: 7 planets in 2 signs (B.V. Raman #87)

**Python Logic Summary (PyJHora Implementation)**:
```python
"""BVR-96 Yuga Yoga: 7 planets in 2 signs (B.V. Raman #87)"""
    return _sankhya_yoga_calculation(chart_1d=chart_1d, required_count=2)
```

---

## Other Natal Yoga

Total yogas in this category: **177**

### Amala Yoga

- **PyJHora Function/Key**: `amala_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: There are only natural benefics present in the 10th house from lagna or Moon.
- **Effects/Benefits**: One born with this yoga has ever-lasting fame. The person is respected by kings. Person has luxuries and is virtuous. Person helps others. Amala means pure. Because the 10th house shows one's' conduct in society, situation of only benefics there makes one’s conduct in the society very pure.
- **Notes/Reference**: BVR-13 Amala Yoga: If there are only natural benefics in the 10th house from lagna or Moon

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-13 Amala Yoga: If there are only natural benefics in the 10th house from lagna or Moon """
    return _amala_yoga_calculation(chart_1d)
```

---

### Amsaavatara Yoga

- **PyJHora Function/Key**: `amsaavatara_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If Jupiter, Venus and exalted Saturn are in quadrants, then this yoga is present.
- **Effects/Benefits**: One born with this yoga becomes a king or an equal. Person is learned and pleasure-loving. Person has unsullied reputation. Amsaavatara means one who is an incarnation of a part of the Lord.
- **Notes/Reference**: BVR-50 Amsaavatara Yoga: 
    Method 1 (PVR): Jupiter, Venus, and exalted Saturn are in quadrants.
    Method 2 (BVR): Same as Method 1, but Lagna must be in a movable sign.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" 
    BVR-50 Amsaavatara Yoga: 
    Method 1 (PVR): Jupiter, Venus, and exalted Saturn are in quadrants.
    Method 2 (BVR): Same as Method 1, but Lagna must be in a movable sign.
    """
    return _amsaavatara_yoga_calculation(chart_1d=chart_1d, method=method)
```

---

### Anapathya Yoga

- **PyJHora Function/Key**: `anapathya_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Jupiter and the lords of Lagna, the 7th and the 5th are weak
- **Effects/Benefits**: The person will have no children.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        Jupiter and the lords of Lagna, the 7th and the 5th are weak
    """
    return _anapathya_yoga_calculation(chart_1d=chart_1d, natural_malefics=natural_malefics)
```

---

### Andha Yoga

- **PyJHora Function/Key**: `andha_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The Lagna lord, Sun, and Moon are associated with malefic planets in the 2nd or 12th house.
- **Effects/Benefits**: This indicates potential blindness or significantly weakened eyesight.
- **Notes/Reference**: Andha Yoga: Mercury and the Moon should be in the 2nd OR the lords of 
    Lagna and the 2nd should join the 2nd with the Sun.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Andha Yoga: Mercury and the Moon should be in the 2nd OR the lords of 
    Lagna and the 2nd should join the 2nd with the Sun.
    """
    return _andha_yoga_calculation(chart_1d=chart_1d)
```

---

### Andha Yoga

- **PyJHora Function/Key**: `andha_yoga_288` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 288 - When Rahu is in Lagna in conjunction with the Sun and the malefics join trines, the above yoga is given rise to.
- **Effects/Benefits**: The person will be stone-blind.
- **Notes/Reference**: 288 - When Rahu is in Lagna in conjunction with the Sun and the malefics join trines,
        the above yoga is given rise to.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        288 - When Rahu is in Lagna in conjunction with the Sun and the malefics join trines,
        the above yoga is given rise to.    
    """
    return _andha_yoga_288_calculation(chart_1d=chart_1d, natural_malefics=natural_malefics)
```

---

### Andha Yoga

- **PyJHora Function/Key**: `andha_yoga_289` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 289 - Mars, the Moon, Saturn and the Sun should respectively occupy the 2nd, 6th, 12th and 8th
- **Effects/Benefits**: The person will be stone-blind.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        289 - Mars, the Moon, Saturn and the Sun should respectively occupy the 2nd, 6th, 12th and 8th    
    """
    return _andha_yoga_289_calculation(chart_1d=chart_1d, natural_malefics=natural_malefics)
```

---

### Angaheena Yoga

- **PyJHora Function/Key**: `angaheena_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 285 - When the Moon is in the 10th, Mars in the 7th and Saturn in the 2nd from the Sun,the above yoga is formed.
- **Effects/Benefits**: The person suffers from loss of limbs.
- **Notes/Reference**: 285 - When the Moon is in the 10th, Mars in the 7th and Saturn in the 2nd from the Sun, 
        the above yoga is formed.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" 
        285 - When the Moon is in the 10th, Mars in the 7th and Saturn in the 2nd from the Sun, 
        the above yoga is formed.
    """
    return _angaheena_yoga_calculation(chart_1d=chart_1d)
```

---

### Annadana Yoga

- **PyJHora Function/Key**: `annadana_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Jupiter or the Moon has a benefic association with the 2nd or 12th house.
- **Effects/Benefits**: You will be very interested in feeding others and providing charity to the needy.
- **Notes/Reference**: Annadana Yoga: The lord of the 2nd should join Vaiseshikamsa (score 13) 
    and be in conjunction with or aspected by Jupiter and Mercury.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Annadana Yoga: The lord of the 2nd should join Vaiseshikamsa (score 13) 
    and be in conjunction with or aspected by Jupiter and Mercury.
    """
    return _annadana_yoga_calculation(chart_1d=chart_1d, natural_benefics=natural_benefics, v_score=v_score)
```

---

### Apakeerthi Yoga

- **PyJHora Function/Key**: `apakeerthi_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 244 - The 10th house must be occupied by the Sun and Saturn who should join malefic amsas or be aspected by malefics.
- **Effects/Benefits**: The person will have a bad reputation.
- **Notes/Reference**: 244 - The 10th house must be occupied by the Sun and Saturn who should join malefic amsas 
        or be aspected by malefics.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        244 - The 10th house must be occupied by the Sun and Saturn who should join malefic amsas 
        or be aspected by malefics.
    """
    return _apakeerthi_yoga_calculation(chart_rasi=chart_rasi,chart_navamsa=chart_navamsa,
                                        natural_malefics=natural_malefics)
```

---

### Asatyavadi Yoga

- **PyJHora Function/Key**: `asatyavadi_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The 2nd lord is associated with malefic planets (Saturn, Rahu, Ketu) and Mercury is weak.
- **Effects/Benefits**: You may have a tendency to speak untruths or have a habit of lying.
- **Notes/Reference**: Asatyavadi Ycga Definition.*-If the lord of the 2nd occupies the
        house of Saturn or Mars and if malefics join kendras and thrikonas.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        Asatyavadi Ycga Definition.*-If the lord of the 2nd occupies the
        house of Saturn or Mars and if malefics join kendras and thrikonas.
    """
    return _asatyavadi_yoga_calculation(chart_1d=chart_1d, natural_malefics=natural_malefics)
```

---

### Asubha Yoga

- **PyJHora Function/Key**: `asubha_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Lagna has malefics or has “paapa kartari or maleefics in 12th and 2nd house from Lagna.
- **Effects/Benefits**: One born with this yoga has many desires and is sinful and enjoys the wealth of others.
- **Notes/Reference**: Asubha Yoga
      Present if either:
        (1) Lagna has malenefics and is NOT affected by benefics, OR
        (2) Lagna is surrounded by malefics (malefics in BOTH 12th and 2nd) and lagna is NOT affected by benefics.
      Note: In your simplified version, "not affected" can be enforced via "only malefics" in the tested houses.
    Parameters:
      - use_affliction_check (bool): If True, compute "not affected by benefics" using occupancy, aspects, and hemming.
        If False, rely solely on "only malefics" conditions in the tested houses.
        TODO: Need to check use_affliction_check algorithm=True
    Returns:
      - bool: True if Asubha Yoga is present, False otherwise.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Asubha Yoga
      Present if either:
        (1) Lagna has malenefics and is NOT affected by benefics, OR
        (2) Lagna is surrounded by malefics (malefics in BOTH 12th and 2nd) and lagna is NOT affected by benefics.
      Note: In your simplified version, "not affected" can be enforced via "only malefics" in the tested houses.
    Parameters:
      - use_affliction_check (bool): If True, compute "not affected by benefics" using occupancy, aspects, and hemming.
        If False, rely solely on "only malefics" conditions in the tested houses.
        TODO: Need to check use_affliction_check algorithm=True
    Returns:
      - bool: True if Asubha Yoga is present, False otherwise.
    """
    _natural_benefics = {3, 4, 5}
    # Malefics: Sun(0), Mars(2), Saturn(6), Rahu(7), Ketu(8)
    _natural_malefics = {0, 2, 6, 7, 8}
    return _asubha_yoga_calculation(chart_1d, _natural_benefics, _natural_malefics,use_affliction_check=use_affliction_check)
```

---

### Ayatna Griha Prapta Yoga

- **PyJHora Function/Key**: `ayatna_griha_prapta_yoga_189` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 189. Lords of Lagna and the 7th should occupy Lagna or the 4th, aspected by benefics.
- **Effects/Benefits**: The person acquires substantial house property with hardly any effort.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
            189. Lords of Lagna and the 7th should occupy Lagna or the 4th, aspected by benefics. 
    """
    if planet_positions is not None:
        chart_1d = utils.get_house_planet_list_from_planet_positions(planet_positions)
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    _natural_benefics = _get_natural_benefics(chart_1d, natural_benefics)
    # 1. Get 3rd Lord
    lagna_house = p_to_h[const._ascendant_symbol]
    fourth_house = (lagna_house + const.HOUSE_4)%12
    seventh_house = (lagna_house + const.HOUSE_7) % 12
    if planet_positions is not None:
        lord_of_lagna = house.house_owner_from_planet_positions(planet_positions, lagna_house)
        lord_of_7th = house.house_owner_from_planet_positions(planet_positions, seventh_house)
    else:
        lord_of_lagna = house.house_owner(chart_1d, lagna_house)
        lord_of_7th = house.house_owner(chart_1d, seventh_house)
    lagna_7th_lords_in_lagna = (p_to_h[lord_of_lagna] == lagna_house == p_to_h[lord_of_7th])
    lagna_7th_lords_in_4th = (p_to_h[lord_of_lagna] == fourth_house == p_to_h[lord_of_7th])
    planets_aspecting_lagna_lord = house.planets_aspecting_the_planet(chart_1d, lord_of_lagna) 
    planets_aspecting_7th_lord = house.planets_aspecting_the_planet(chart_1d, lord_of_7th) 
    lagna_lord_aspected_by_benefic = any(p in _natural_benefics for p in planets_aspecting_lagna_lord)
    seventh_lord_aspected_by_benefic = any(p in _natural_benefics for p in planets_aspecting_7th_lord)
    variation_1 =  (lagna_7th_lords_in_lagna or lagna_7th_lords_in_4th) and \
           (lagna_lord_aspected_by_benefic or seventh_lord_aspected_by_benefic)
    return variation_1
```

---

### Ayatna Griha Prapta Yoga

- **PyJHora Function/Key**: `ayatna_griha_prapta_yoga_190` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 190. The lord of the 9th should be posited in a kendra and the lord of the 4th must be in exaltation, moola-thrikona or own house.
- **Effects/Benefits**: The person acquires substantial house property with hardly any effort.
- **Notes/Reference**: 190. The lord of the 9th should be posited in a kendra and the lord of the 4th must be 
            in exaltation, moola-thrikona or own house.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
            190. The lord of the 9th should be posited in a kendra and the lord of the 4th must be 
            in exaltation, moola-thrikona or own house.
    """
    if planet_positions is not None:
        chart_1d = utils.get_house_planet_list_from_planet_positions(planet_positions)
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    _natural_benefics = _get_natural_benefics(chart_1d, natural_benefics)
    # 1. Get 3rd Lord
    lagna_house = p_to_h[const._ascendant_symbol]
    fourth_house = (lagna_house + const.HOUSE_4)%12
    nineth_house = (lagna_house + const.HOUSE_9) % 12
    if planet_positions is not None:
        lord_of_4th = house.house_owner_from_planet_positions(planet_positions, fourth_house)
        lord_of_9th = house.house_owner_from_planet_positions(planet_positions, nineth_house)
    else:
        lord_of_4th = house.house_owner(chart_1d, fourth_house)
        lord_of_9th = house.house_owner(chart_1d, nineth_house)
    ### Variation 2
    # 3. Check Condition 1: 9th Lord in Kendra
    kendra_houses = quadrants_of_the_house(lagna_house)
    ninth_lord_in_kendra = p_to_h[lord_of_9th] in kendra_houses
    # 4. Check Condition 2: 4th Lord Strength
    current_house_of_4th_lord = p_to_h[lord_of_4th]
    # A) Check matrix for Own Sign (5) or Exalted (4)
    #strength_score = const.house_strengths_of_planets[lord_of_4th][current_house_of_4th_lord]
    #is_strong_by_matrix = strength_score in [const._OWNER_RULER, const._EXALTED_UCCHAM]
    lord_is_strong = utils.is_planet_strong(lord_of_4th, current_house_of_4th_lord, include_neutral_samam=False)
    # B) Check Moola Trikona list
    is_moola_trikona = current_house_of_4th_lord == const.moola_trikona_of_planets[lord_of_4th]
    return ninth_lord_in_kendra and (lord_is_strong or is_moola_trikona)
```

---

### Ayatnadhanalabha Yoga

- **PyJHora Function/Key**: `ayatnadhanalabha_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The Lagna lord and the 2nd lord are in exchange of houses (Parivartana) or are together in a house.
- **Effects/Benefits**: You will obtain wealth effortlessly or through unexpected windfalls like lotteries, gifts, or sudden luck.
- **Notes/Reference**: Ayatnadhanalabha Yoga (BV Raman 143)
    Definition: The lord of the Lagna and the 2nd must exchange their places.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Ayatnadhanalabha Yoga (BV Raman 143)
    Definition: The lord of the Lagna and the 2nd must exchange their places.
    """
    return _ayatnadhanalabha_yoga_calculation(chart_1d)
```

---

### Bahu Sthree Yoga

- **PyJHora Function/Key**: `bahu_sthree_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 238 - If the lords of the Lagna and the 7th are in conjunction or aspect with each other, the above yoga is given rise to.
- **Effects/Benefits**: The person will have any number of wives.
- **Notes/Reference**: 238 - If the lords of the Lagna and the 7th are in conjunction or aspect with each other, the 
        above yoga is given rise to.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        238 - If the lords of the Lagna and the 7th are in conjunction or aspect with each other, the 
        above yoga is given rise to.
    """
    return _bahu_sthree_yoga_calculation(chart_1d=chart_1d)
```

---

### Bahudravyarjana Yoga

- **PyJHora Function/Key**: `bahudravyarjana_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The Lagna lord is in the 2nd, the 2nd lord is in the 11th, and the 11th lord is in the Lagna.
- **Effects/Benefits**: You will earn vast amounts of wealth through various means and become a very rich person in your community.
- **Notes/Reference**: BVR-129: Lord of the Lagna in the 2nd, lord of the 2nd in the 11th and the lord of the 11th in 
            Lagna will give rise to this Yoga.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        BVR-129: Lord of the Lagna in the 2nd, lord of the 2nd in the 11th and the lord of the 11th in 
            Lagna will give rise to this Yoga.
    """
    return _bahudravyarjana_yoga_calculation(chart_1d=chart_1d)
```

---

### Bandhu Bhisthyaktha Yoga

- **PyJHora Function/Key**: `bandhubhisthyaktha_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 195. The 4th lord must be associated with malefics or occupy evil shashtiamsas or join inimical or debilitation signs.
- **Effects/Benefits**: The person will be clesertedby his relatives.
- **Notes/Reference**: 195. The 4th lord must be associated with malefics or occupy evil shashtiamsas or join 
    inimical or debilitation signs.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    195. The 4th lord must be associated with malefics or occupy evil shashtiamsas or join 
    inimical or debilitation signs.
    """
    return _bandhubhisthyaktha_yoga_calculation(chart_1d, natural_malefics=natural_malefics)
```

---

### Bandhu Pujya Yoga

- **PyJHora Function/Key**: `bandhu_pujya_yoga_193` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 193 - If the benefic lord of the 4th is aspected by another benefic and Mercury is situated in Lagna, the above yoga is given rise to.
- **Effects/Benefits**: The person will be respected by his relatives and friends.
- **Notes/Reference**: 193 - If the benefic lord of rhe 4th is aspected by another benefic and Mercury is situated 
            in Lagna, the above yoga is given rise to.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        193 - If the benefic lord of rhe 4th is aspected by another benefic and Mercury is situated 
            in Lagna, the above yoga is given rise to.
    """
    if planet_positions is not None:
        chart_1d = utils.get_house_planet_list_from_planet_positions(planet_positions)
    if chart_1d is None: return False   
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    asc_house = p_to_h[const._ascendant_symbol]
    fourth_house_idx = (asc_house + 3) % 12  # 4th house (0-indexed)
    _natural_benefics = _get_natural_benefics(chart_1d, natural_benefics)
    lord_of_4th = ( house.house_owner_from_planet_positions(planet_positions,fourth_house_idx) if planet_positions
                    else house.house_owner(chart_1d, fourth_house_idx) )
    # --- Rule 193 Logic ---
    # A) Benefic lord of 4th
    lord_4_is_benefic = lord_of_4th in _natural_benefics
    # B) Aspected by ANOTHER benefic
    aspects_to_lord_4 = house.planets_aspecting_the_planet(chart_1d, lord_of_4th)
    aspected_by_other_benefic = any(bp in aspects_to_lord_4 for bp in _natural_benefics if bp != lord_of_4th)
    # C) Mercury in Lagna
    mercury_in_lagna = p_to_h.get(const.MERCURY_ID) == asc_house
    return lord_4_is_benefic and aspected_by_other_benefic and mercury_in_lagna
```

---

### Bandhu Pujya Yoga

- **PyJHora Function/Key**: `bandhu_pujya_yoga_194` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 194 - The 4th house or the 4th lord should have the association or aspect of Jupiter.
- **Effects/Benefits**: The person will be respected by his relatives and friends.
- **Notes/Reference**: 194 = The 4th house or the 4th lord should have the association or aspect of Jupiter.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        194 = The 4th house or the 4th lord should have the association or aspect of Jupiter.
    """
    if planet_positions is not None:
        chart_1d = utils.get_house_planet_list_from_planet_positions(planet_positions)   
    if chart_1d is None: return False
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    asc_house = p_to_h[const._ascendant_symbol]
    fourth_house_idx = (asc_house + const.HOUSE_4) % 12  # 4th house (0-indexed)
    _natural_benefics = _get_natural_benefics(chart_1d, natural_benefics)
    lord_of_4th = ( house.house_owner_from_planet_positions(planet_positions,fourth_house_idx) if planet_positions
                    else house.house_owner(chart_1d, fourth_house_idx) )
    # --- Rule 194 Logic ---
    fourth_house_rasi = (asc_house + const.HOUSE_4) % 12  # Assuming 0-indexed Rasis
    # 1. Check if Jupiter is IN the 4th house
    jup_in_4th = p_to_h.get(const.JUPITER_ID) == fourth_house_rasi
    # 2. Check if Jupiter ASPECTS the 4th house (Rasi)
    aspects_to_4th_rasi = house.planets_aspecting_the_raasi(chart_1d, fourth_house_rasi)
    jup_aspects_4th_house = const.JUPITER_ID in aspects_to_4th_rasi
    # 3. Check if Jupiter ASPECTS or CONJOINS the 4th Lord
    jup_conjoins_4th_lord = p_to_h.get(const.JUPITER_ID) == p_to_h.get(lord_of_4th)
    aspects_to_4th_lord = house.planets_aspecting_the_planet(chart_1d, lord_of_4th)
    jup_aspects_4th_lord = const.JUPITER_ID in aspects_to_4th_lord
    return jup_in_4th or jup_aspects_4th_house or jup_conjoins_4th_lord or jup_aspects_4th_lord
```

---

### Bhaagya Yoga

- **PyJHora Function/Key**: `bhaagya_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 241 -  strong benefic should be in Lagna, the 3rd or 5th, simultaneously aspecting the 9th.
- **Effects/Benefits**: The subject will be extremely fortunate, pleasure-loving and rich.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        241 -  strong benefic should be in Lagna, the 3rd or 5th, simultaneously aspecting the 9th.
    """
    return _bhaagya_yoga_calculation(chart_1d=chart_1d, natural_benefics=natural_benefics)
```

---

### Bhaarathi Yoga

- **PyJHora Function/Key**: `bhaarathi_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If the lord of the sign occupied in navamsa by 2nd, 5th or 11th lord exalted and joins the 9th lord, then this yoga is present.
- **Effects/Benefits**: One born with this yoga is a great scholar. Person is intelligent, religious, good-looking and famous. Bhaarathi is another name of Saraswathi, the goddess of learning.
- **Notes/Reference**: BVR-29 Bhaarathi Yoga: If the lord of the sign occupied in navamsa by 2nd, 5th or 11th lord
        exalted and joins the 9th lord

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-29 Bhaarathi Yoga: If the lord of the sign occupied in navamsa by 2nd, 5th or 11th lord
        exalted and joins the 9th lord """
    return _bhaarathi_yoga_calculation(chart_1d_rasi=chart_1d_rasi, chart_1d_navamsa=chart_1d_navamsa)
```

---

### Bhaaskara Yoga

- **PyJHora Function/Key**: `bhaaskara_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If (1) Moon is in the 12th from Sun, (2) Mercury is in the 2nd from Sun, and, (3) Jupiter is in the 5th or 9th from Moon, then this yoga is present.
- **Effects/Benefits**: One born with this yoga is wealthy, valorous and aristocratic. Person is learned in sastras, astrology and music. Person has a good personality. Bhaaskara means 'one with bright rays'. It is a name of Sun.
- **Notes/Reference**: BVR-159 Bhaaskara Yoga: 
        Method=1 (PVR) (1) Moon 12th from Sun (2) Mercury 2nd from Sun (3) Jupiter 5/9 from Moon 
        Method=2 (BVR) (2) Moon 11th from Mercury (2) Mercury 2nd from Sun (3) Jupiter 5/9 from Moon

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-159 Bhaaskara Yoga: 
        Method=1 (PVR) (1) Moon 12th from Sun (2) Mercury 2nd from Sun (3) Jupiter 5/9 from Moon 
        Method=2 (BVR) (2) Moon 11th from Mercury (2) Mercury 2nd from Sun (3) Jupiter 5/9 from Moon
    """
    return _bhaaskara_yoga_calculation(chart_1d=chart_1d,method=method)
```

---

### Bhaga Chumbana yoga

- **PyJHora Function/Key**: `bhaga_chumbana_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 240 - If the lord of the 7th is in the 4th in conjunction with Venus, the above yoga is caused
- **Effects/Benefits**: Person has excessive attachment to self-pleasure and difficulty in managing sensual desires.
- **Notes/Reference**: 240. A. 7th lord in 4th and in conjunction with Venus. OR
             B. if Lagna lord is debilitated in rasi or in navamsa

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        240. A. 7th lord in 4th and in conjunction with Venus. OR
             B. if Lagna lord is debilitated in rasi or in navamsa
    """
    return _bhaga_chumbana_yoga_calculation(chart_1d=chart_1d, chart_navamsa=chart_navamsa)
```

---

### Bhagya Malika Yoga

- **PyJHora Function/Key**: `bhagya_malika_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All seven planets occupy seven continuous houses starting from the 9th house (Bhagya Bhava).
- **Effects/Benefits**: You will be extremely fortunate, religious, and world-renowned for your charitable deeds.
- **Notes/Reference**: BVR-40 Bhagya Malika Yoga: Malika Yoga Starting from 9th House

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        BVR-40 Bhagya Malika Yoga: Malika Yoga Starting from 9th House
    """
    return _bhagya_malika_yoga_calc(chart_1d=chart_1d)
```

---

### Bharya sahavyabhichara Yoga

- **PyJHora Function/Key**: `bharyasahavyabhichara_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 282 - Venus, Saturn and Mars must join the Moon in the 7th house. Variation: 7th lord is in conjunction with Venus, aspected by Saturn; 7th house aspected by Saturn and Mars; Venus and Moon are afflicted by malefics (from natural_malefics).
- **Effects/Benefits**: The husband and wife will both be guilty of adultery.
- **Notes/Reference**: 282 - Venus, Saturn and Mars must join the Moon in the 7th house.
             Variation: 7th lord in conjunction with Venus, aspected by Saturn;
                        7th house aspected by Saturn and Mars;
                        Venus and Moon afflicted by malefics.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        282 - Venus, Saturn and Mars must join the Moon in the 7th house.
             Variation: 7th lord in conjunction with Venus, aspected by Saturn;
                        7th house aspected by Saturn and Mars;
                        Venus and Moon afflicted by malefics.
    """
    return _bharyasahavyabhichara_yoga_calculation(chart_1d=chart_1d,natural_malefics=natural_malefics)
```

---

### Bheri Yoga

- **PyJHora Function/Key**: `bheri_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: ]If (1) the 9th lord is strong and (2) 1st, 2nd, 7th and 12th houses are occupied by planets, then this yoga is present. Alternately, this is yoga is present if (1) the 9th lord is strong and (2) Jupiter, Venus and lagna lord are in mutual quadrants.
- **Effects/Benefits**: One born with this yoga is blessed with wealth, spouse and children. Person can be a king. Person has fame and character. Person is virtuous and religious. Person enjoys pleasures. Bheri means a kettledrum.
- **Notes/Reference**: BVR-45 Bheri Yoga:
       Path A: (1) 9th lord is strong AND (2) 1st, 2nd, 7th, and 12th houses are occupied by planets
       OR
       Path B: (1) 9th lord is strong AND (2) Jupiter, Venus, and Lagna lord are in mutual quadrants

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-45 Bheri Yoga:
       Path A: (1) 9th lord is strong AND (2) 1st, 2nd, 7th, and 12th houses are occupied by planets
       OR
       Path B: (1) 9th lord is strong AND (2) Jupiter, Venus, and Lagna lord are in mutual quadrants
    """
    return _bheri_yoga_calculation(chart_1d=chart_1d)
```

---

### Bhojana Soukhya Yoga

- **PyJHora Function/Key**: `bhojana_soukhya_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The 2nd lord is strong and associated with benefic planets.
- **Effects/Benefits**: You will always enjoy delicious, high-quality food and comforts of the table.
- **Notes/Reference**: Bhojana Soukhya Yoga: The powerful lord of the 2nd should occupy Vaiseshikamsa 
    and have the aspect of Jupiter or Venus.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Bhojana Soukhya Yoga: The powerful lord of the 2nd should occupy Vaiseshikamsa 
    and have the aspect of Jupiter or Venus.
    """
    return _bhojana_soukhya_yoga_calculation(chart_1d=chart_1d, natural_benefics=natural_benefics,
                                             v_score=v_score)
```

---

### Bhraathru Saapa Sutakshaya Yoga

- **PyJHora Function/Key**: `bhraathru_saapa_sutakshaya_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: A. The lords of Lagna and the 5th must join the 8th house AND B. the lord of the 3rd should combine with Mars and Rahu in the 5th house.
- **Effects/Benefits**: There will be death of children due to curses from brothers.
- **Notes/Reference**: BVR 218 - Bhraathru Saapa Sutakshya Yoga
        A. The lords of Lagna and the 5th must join the 8th house AND 
        B. the lord of the 3rd should combine with Mars and Rahu in the 5th house.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        BVR 218 - Bhraathru Saapa Sutakshya Yoga
        A. The lords of Lagna and the 5th must join the 8th house AND 
        B. the lord of the 3rd should combine with Mars and Rahu in the 5th house.
    """
    return _bhraathru_saapa_sutakshaya_yoga_calculation(chart_1d=chart_1d)
```

---

### Bhratrumooladdhanaprapti Yoga

- **PyJHora Function/Key**: `bhratrumooladdhanaprapti_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The 2nd lord is associated with the 3rd lord or placed in the 3rd house with a benefic.
- **Effects/Benefits**: You will gain wealth, property, or financial assistance through your brothers or siblings.
- **Notes/Reference**: Bhratrumooladdhanaprapti Yoga (BV Raman 136, 137)
    Covers wealth from brothers through specific conjunctions and aspects.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Bhratrumooladdhanaprapti Yoga (BV Raman 136, 137)
    Covers wealth from brothers through specific conjunctions and aspects.
    """
    return _bhratrumooladdhanaprapti_yoga_calculation(chart_1d)
```

---

### Bhratruvriddhi Yoga

- **PyJHora Function/Key**: `bhratruvriddhi_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The 3rd lord or Mars is associated with a benefic planet or placed in a benefic sign/Navamsha.
- **Effects/Benefits**: You will have an increase in the number of brothers and sisters, and enjoy a harmonious relationship with them.
- **Notes/Reference**: Bhratruvriddhi Yoga (177): 3rd lord, Mars, or 3rd house joined/aspected by benefics and strong.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Bhratruvriddhi Yoga (177): 3rd lord, Mars, or 3rd house joined/aspected by benefics and strong.
    """
    return _bhratruvriddhi_yoga_calculation(chart_1d,natural_benefics=natural_benefics)
```

---

### Brahma Yoga

- **PyJHora Function/Key**: `brahma_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If benefics occupy the 4th, 10th and 11th houses counted from lagna lord, then this yoga is present. Another variation of Brahma yoga: If (1) Jupiter is in a quadrant from the 9th lord, (2) Venus is in a quadrant from the 11th lord, and, (3) Mercury is in a quadrant from the 1st lord or 10th lord, then this yoga is present.
- **Effects/Benefits**: One born with this yoga is happy, learned and blessed with wealth and children. Brahma is the creator of this universe. Lagna rules birth and the Creator is represented in a chart by lagna lord.
- **Notes/Reference**: BVR-51 Brahma Yoga (part of harihara brahma yoga): 
        Brahma Yoga: (Based on PVR Narasimha Rao)
        Method 1: Benefics in 4th, 10th and 11th from Lagna Lord.
        Method 2: Jupiter in quadrant from 9th lord, Venus in quadrant from 11th lord, 
                  and Mercury in quadrant from 1st or 10th lord.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-51 Brahma Yoga (part of harihara brahma yoga): 
        Brahma Yoga: (Based on PVR Narasimha Rao)
        Method 1: Benefics in 4th, 10th and 11th from Lagna Lord.
        Method 2: Jupiter in quadrant from 9th lord, Venus in quadrant from 11th lord, 
                  and Mercury in quadrant from 1st or 10th lord.
    """
    return _brahma_yoga_calculation(chart_1d=chart_1d,natural_benefics=natural_benefics,method=method)
```

---

### Buddhi Jada Yoga

- **PyJHora Function/Key**: `buddhi_jada_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 233 - Lord of Lagna cojoins or aspected by malefics. AND Saturn occupies 5th house, AND Lord of lagna is aspected by Saturn. OR 5th lord is conjoined with malefics AND (Saturn aspects 5th Lord) OR Moon in 5th House
- **Effects/Benefits**: The person will be a dunce.
- **Notes/Reference**: 233 - Lord of Lagna cojoins or aspected by malefics. AND Saturn occupies 5th house, AND 
            Lord of lagna is aspected by Saturn.
            OR
            5th lord is conjoined with malefics AND 
            (Saturn aspects 5th Lord) OR Moon in 5th House

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        233 - Lord of Lagna cojoins or aspected by malefics. AND Saturn occupies 5th house, AND 
            Lord of lagna is aspected by Saturn.
            OR
            5th lord is conjoined with malefics AND 
            (Saturn aspects 5th Lord) OR Moon in 5th House 
    """
    return _buddhi_jada_yoga_calculation(chart_1d=chart_1d, natural_malefics=natural_malefics)
```

---

### Buddhimaturya Yoga

- **PyJHora Function/Key**: `buddhimaturya_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 231 - If the 5th lord, being a benefic, is either aspected by another benefic or occupies a benefic sign, the above yoga is given rise to.
- **Effects/Benefits**: The person will be a man of great intelligence and character.
- **Notes/Reference**: 231 - If the 5th lord, being a benefic, is either aspected by another benefic or occupies a 
            benefic sign, the above yoga is given rise to.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        231 - If the 5th lord, being a benefic, is either aspected by another benefic or occupies a 
            benefic sign, the above yoga is given rise to.
    """
    return _buddhimaturya_yoga_calculation(chart_1d=chart_1d, natural_benefics=natural_benefics,
                                require_lord_of_5th_to_be_benefic=require_lord_of_5th_to_be_benefic)
```

---

### Budha Yoga

- **PyJHora Function/Key**: `budha_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The Lagna lord is strong and Mercury is in a Kendra house.
- **Effects/Benefits**: You will be highly intelligent, learned, and skillful in all your endeavors.
- **Notes/Reference**: Budha Yoga: Jupiter in Lagna, the Moon in a kendra, 
    Rahu in the 2nd from the Moon and the Sun and Mars in the 3rd from Rahu.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Budha Yoga: Jupiter in Lagna, the Moon in a kendra, 
    Rahu in the 2nd from the Moon and the Sun and Mars in the 3rd from Rahu.
    """
    return _budha_yoga_calculation(chart_1d=chart_1d)
```

---

### Chaamara Yoga

- **PyJHora Function/Key**: `chaamara_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If the lagna lord is exalted in a quadrant with Jupiter’s aspect or two benefics join in 7th, 9th or 10th, then this yoga is present.
- **Effects/Benefits**: One born with this yoga is a king or someone respected by kings. Person is long-lived, scholarly, eloquent and learned in many arts. Chaamara means something akin to the plume on the head of a horse. By waving it, servants give relief to kings from heat (like a fan). It basically stands for the trappings of power.
- **Notes/Reference**: Chaamara Yoga: If the lagna lord is exalted in a quadrant with Jupiter’s aspect or
        two benefics join in 7th, 9th or 10th

**Python Logic Summary (PyJHora Implementation)**:
```python
""" Chaamara Yoga: If the lagna lord is exalted in a quadrant with Jupiter’s aspect or
        two benefics join in 7th, 9th or 10th """
    return _chaamara_yoga_calculation(chart_1d,natural_benefics=natural_benefics)
```

---

### Chandikaa Yoga

- **PyJHora Function/Key**: `chandikaa_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If (1) lagna is in a fixed sign aspected by 6th lord and (2) Sun joins the lords of the signs occupied in navamsa by 6th and 9th lords, then this yoga is present.
- **Effects/Benefits**: One born with this yoga is aggressive, charitable, wealthy, famous and longlived. Chandika is an aggressive form of Parvati. She kills demons mercilessly.
- **Notes/Reference**: BVR-57 Chandikaa Yoga: If (1) lagna is in a fixed sign aspected by 6th lord and (2) Sun
        joins the lords of the signs occupied in navamsa by 6th and 9th lords

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-57 Chandikaa Yoga: If (1) lagna is in a fixed sign aspected by 6th lord and (2) Sun
        joins the lords of the signs occupied in navamsa by 6th and 9th lords """
    return _chandikaa_yoga_calculation(chart_1d_rasi=chart_1d_rasi, chart_1d_navamsa=chart_1d_navamsa)
```

---

### Chapa Yoga

- **PyJHora Function/Key**: `chapa_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If (1) the 4th and 10th lords have an exchange and (2) lagna lord is exalted, then this yoga is present.
- **Effects/Benefits**: One born with this yoga works for a king and commands a lot of wealth. Chapa means a bow.
- **Notes/Reference**: BVR-30 Chapa Yoga: 
    (1) 4th and 10th lords have an exchange (Parivartana).
    (2) Lagna lord is exalted (Strength >= 4).

**Python Logic Summary (PyJHora Implementation)**:
```python
""" 
    BVR-30 Chapa Yoga: 
    (1) 4th and 10th lords have an exchange (Parivartana).
    (2) Lagna lord is exalted (Strength >= 4).
    """
    return _chapa_yoga_calculation(chart_1d=chart_1d)
```

---

### Chatussagara Yoga

- **PyJHora Function/Key**: `chatussagara_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All planets occupy the four Kendra houses (1, 4, 7, 10).
- **Effects/Benefits**: You will earn great reputation, be equal to a king, and possess good health and a long life.
- **Notes/Reference**: BVR-8 Chatussagara Yoga: All quadrants (1, 4, 7, 10) are occupied by planets.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-8 Chatussagara Yoga: All quadrants (1, 4, 7, 10) are occupied by planets. """
    return _chatussagara_yoga_calculation(chart_1d=chart_1d)
```

---

### Dama Yoga

- **PyJHora Function/Key**: `dama_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All seven planets are distributed among six different signs.
- **Effects/Benefits**: You will be a philanthropist, helpful to others, courageous, and very wealthy.
- **Notes/Reference**: BVR-92 Dama/Damni Yoga: 7 planets in 6 signs (B.V. Raman #83)

**Python Logic Summary (PyJHora Implementation)**:
```python
"""BVR-92 Dama/Damni Yoga: 7 planets in 6 signs (B.V. Raman #83)"""
    return _sankhya_yoga_calculation(chart_1d=chart_1d, required_count=6)
```

---

### Dehapushti Yoga

- **PyJHora Function/Key**: `dehapushti_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The Lagna lord is in a movable sign (Chara Rashi) and is aspected by a benefic planet.
- **Effects/Benefits**: You will have a strong, well-developed, and healthy physique.
- **Notes/Reference**: BVR-109 Dehapushti Yoga
    The Lagna Lord is in a movable sign and is aspected by a benefic.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    BVR-109 Dehapushti Yoga
    The Lagna Lord is in a movable sign and is aspected by a benefic.
    """
    return _dehapushti_calculation(chart_1d=chart_1d, natural_benefics=natural_benefics)
```

---

### Dehasthoulya Yoga

- **PyJHora Function/Key**: `dehasthoulya_yoga_114` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Lagna Lord and its Navamsa Lord both occupy watery signs (in Rasi).
- **Effects/Benefits**: You will have a stout, heavy, or corpulent body (tendency toward obesity).

---

### Dehasthoulya Yoga

- **PyJHora Function/Key**: `dehasthoulya_yoga_115` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Jupiter in Lagna OR Jupiter aspects Lagna from a watery sign.
- **Effects/Benefits**: You will have a stout, heavy, or corpulent body (tendency toward obesity).
- **Notes/Reference**: BVR 115
    Dehasthoulya Yoga (Stout Body)
    Condition 2: Jupiter in Lagna OR Jupiter aspects Lagna from a watery sign.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    BVR 115
    Dehasthoulya Yoga (Stout Body)
    Condition 2: Jupiter in Lagna OR Jupiter aspects Lagna from a watery sign.
    """
    if planet_positions_rasi is not None:
        chart_rasi = utils.get_house_planet_list_from_planet_positions(planet_positions_rasi)
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_rasi)
    asc_house = p_to_h.get(const._ascendant_symbol)
    if asc_house is None: return False

    _natural_benefics = _get_natural_benefics(chart_rasi, natural_benefics)
    # --- Condition 2 (Yoga #115) ---
    j_h = p_to_h.get(const.JUPITER_ID)
    condition_2 = False
    if j_h is not None:
        # Part A: Jupiter in Lagna
        if j_h == asc_house:
            condition_2 = True
        # Part B: Jupiter aspects Lagna from a watery sign
        elif j_h in const.water_signs:
            # Jupiter aspects 5, 7, 9 houses away
            jupiter_aspects = [(j_h + 4) % 12, (j_h + 6) % 12, (j_h + 8) % 12]
            if asc_house in jupiter_aspects:
                condition_2 = True
    return condition_2
```

---

### Dehasthoulya Yoga

- **PyJHora Function/Key**: `dehasthoulya_yoga_116` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Lagna in a watery sign joined by benefics OR Lagna Lord is a watery planet.
- **Effects/Benefits**: You will have a stout, heavy, or corpulent body (tendency toward obesity).
- **Notes/Reference**: BVR 116
    Dehasthoulya Yoga (Stout Body)
    Condition 3: Lagna in a watery sign joined by benefics OR Lagna Lord is a watery planet.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    BVR 116
    Dehasthoulya Yoga (Stout Body)
    Condition 3: Lagna in a watery sign joined by benefics OR Lagna Lord is a watery planet.
    """
    if planet_positions_rasi is not None:
        chart_rasi = utils.get_house_planet_list_from_planet_positions(planet_positions_rasi)
    
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_rasi)
    asc_house = p_to_h.get(const._ascendant_symbol)
    if asc_house is None: return False

    # 1. House Lord and Benefic Templates
    if planet_positions_rasi is not None:
        ll = int(house.house_owner_from_planet_positions(planet_positions_rasi, asc_house))
    else:
        ll = int(house.house_owner(chart_rasi, asc_house))

    _natural_benefics = _get_natural_benefics(chart_rasi, natural_benefics)
    # --- Condition 3 (Yoga #116) ---
    # Part A: Lagna in watery sign with benefics
    ben_in_lagna = any(p_to_h.get(b) == asc_house for b in _natural_benefics)
    cond_3_a = (asc_house in const.water_signs) and ben_in_lagna
    # Part B: Lagna Lord is a watery planet
    cond_3_b = ll in const.watery_planets
    condition_3 = cond_3_a or cond_3_b
    return condition_3
```

---

### Devendra Yoga

- **PyJHora Function/Key**: `devendra_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If (1) lagna is in a fixed sign, (2) 2nd and 10th lords have an exchange35, and, (3) lagna and 11th lords have an exchange, then this yoga is present.
- **Effects/Benefits**: One born with this yoga is a leader of men. Person is handsome, romantic, long-lived and famous. Devendra is the ruler of gods.
- **Notes/Reference**: BVR-55 Devendra Yoga: 
    (1) Lagna is in a fixed sign.
    (2) 2nd and 10th lords have an exchange.
    (3) Lagna and 11th lords have an exchange.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" 
    BVR-55 Devendra Yoga: 
    (1) Lagna is in a fixed sign.
    (2) 2nd and 10th lords have an exchange.
    (3) Lagna and 11th lords have an exchange.
    """
    return _devendra_yoga_calculation(chart_1d=chart_1d)
```

---

### Dhana Malika Yoga

- **PyJHora Function/Key**: `dhana_malika_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All seven planets occupy seven continuous houses starting from the 2nd house (Dhana Bhava).
- **Effects/Benefits**: You will be wealthy, charitable, dutiful toward your family, and enjoy material prosperity.
- **Notes/Reference**: BVR-33 Dhana Malika Yoga: Malika Yoga Starting from 2nd House

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        BVR-33 Dhana Malika Yoga: Malika Yoga Starting from 2nd House
    """
    return _dhana_malika_yoga_calc(chart_1d=chart_1d)
```

---

### Dhatrutwa Yoga

- **PyJHora Function/Key**: `dhatrutwa_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 243. The lord of the 9th should be exalted, and aspected by a benefic, and the 9th house should be occupied by a benefic.
- **Effects/Benefits**: The person will be an embodiment of generosity
- **Notes/Reference**: 243. The lord of the 9th should be exalted, and aspected by a benefic, 
        and the 9th house should be occupied by a benefic.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        243. The lord of the 9th should be exalted, and aspected by a benefic, 
        and the 9th house should be occupied by a benefic.
    """
    return _dhatrutwa_yoga_calculation(chart_1d=chart_1d, natural_benefics=natural_benefics)
```

---

### Dhur Yoga

- **PyJHora Function/Key**: `dhur_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The lord of the 10th house is in the 6th, 8th, or 12th house.
- **Effects/Benefits**: You may face difficulties in your career, loss of position, or struggle to get recognition for your work.
- **Notes/Reference**: the lord of the 10th is situated in the 6th, 8th or 12th

**Python Logic Summary (PyJHora Implementation)**:
```python
""" the lord of the 10th is situated in the 6th, 8th or 12th """
    return _dhur_yoga_calculation(chart_1d=chart_1d)
```

---

### Durmukha Yoga

- **PyJHora Function/Key**: `durmukha_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Malefic planets (Saturn, Rahu, Ketu) occupy the 2nd house.
- **Effects/Benefits**: You may have a facial defect or an expression characterized by anger.
- **Notes/Reference**: Durmukha Yoga:
    Method 1 (168): Malefics in the 2nd AND its lord joins an evil planet or is in debilitation.
    Method 2 (169): Lord of 2nd (being evil) joins Gulika OR in unfriendly/debilitated Navamsa with malefics.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Durmukha Yoga:
    Method 1 (168): Malefics in the 2nd AND its lord joins an evil planet or is in debilitation.
    Method 2 (169): Lord of 2nd (being evil) joins Gulika OR in unfriendly/debilitated Navamsa with malefics.
    """
    return _durmukha_yoga_calculation(chart_1d=chart_1d, natural_malefics=natural_malefics, method=method,
                                      navamsa_chart=navamsa_chart, gulika_house=gulika_house)
```

---

### Dwadasa Sahodara Yoga

- **PyJHora Function/Key**: `dwadasa_sahodara_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The 3rd lord is in a kendra and exalted Mars joins Jupiter in a thrikona from the 3rd lord.
- **Effects/Benefits**: The person will be blessed with twelve brothers or siblings.
- **Notes/Reference**: Dwadasa Sahodara Yoga: If the 3rd lord is in a kendra and
    exalted Mars joins Jupiter in a thrikona from the 3rd lord, 
    the above yoga is caused.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Dwadasa Sahodara Yoga: If the 3rd lord is in a kendra and
    exalted Mars joins Jupiter in a thrikona from the 3rd lord, 
    the above yoga is caused.
    """
    return dwadasa_sahodara_yoga_calculation(chart_1d)
```

---

### Ekabhagini Yoga

- **PyJHora Function/Key**: `ekabhagini_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Mercury is in the 3rd house, the lord of the 3rd is with the Moon, and Mars is with Saturn.
- **Effects/Benefits**: The person will have only one sister.
- **Notes/Reference**: 179. Ekabhagini Yoga Definition.-Mercury, the lord of the 3rd and Mars should join 
        the 3rd house, the Moon and Saturn respectively.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        179. Ekabhagini Yoga Definition.-Mercury, the lord of the 3rd and Mars should join 
        the 3rd house, the Moon and Saturn respectively.
    """
    return _ekabhagini_yoga_calculation(chart_1d=chart_1d)
```

---

### Galakarna Yoga

- **PyJHora Function/Key**: `galakarna_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 264. The 3rd house must be occupied by Mandi and Rahu or by Mars in the shashtiamsa of Preta Puriha (Cruel deities).
- **Effects/Benefits**: The native suffersf rom ear troubles.
- **Notes/Reference**: 264. The 3rd house must be occupied by Mandi and Rahu 
            or by Mars in the shashtiamsa of Preta Puriha (Cruel deities).

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        264. The 3rd house must be occupied by Mandi and Rahu 
            or by Mars in the shashtiamsa of Preta Puriha (Cruel deities).
    """
    return _galakarna_yoga_calculation(chart_1d=chart_1d, maandi_house=maandi_house)
```

---

### Gandharva Yoga

- **PyJHora Function/Key**: `gandharva_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If (1) the 10th lord is in a trine from the 7th house, (2) lagna lord is conjoined or aspected by Jupiter, (3) Sun is exalted and strong, and, (4) Moon is in the 9th house, then this yoga is present.
- **Effects/Benefits**: One born with this yoga is skillful and famous in fine arts. Gandharvas are a class of gods with excellent skills in singing and other fine arts.
- **Notes/Reference**: BVR-60 Gandharva Yoga:
    Method 1 (PVR Narasimha Rao):
        (1) 10th lord is in a trine from the 7th house.
        (2) Lagna lord is conjoined or aspected by Jupiter.
        (3) Sun is exalted and strong (Strength >= 4).
        (4) Moon is in the 9th house.
    Method 2 (BV Raman /Kama Trikona):
        (1) 10th Lord is in a Kama Trikona house (3rd, 7th, or 11th).
        (2) Lagna Lord and Jupiter are conjoined.
        (3) Sun is exalted and strong.
        (4) Moon is in the 9th house.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" 
    BVR-60 Gandharva Yoga:
    Method 1 (PVR Narasimha Rao):
        (1) 10th lord is in a trine from the 7th house.
        (2) Lagna lord is conjoined or aspected by Jupiter.
        (3) Sun is exalted and strong (Strength >= 4).
        (4) Moon is in the 9th house.
    Method 2 (BV Raman /Kama Trikona):
        (1) 10th Lord is in a Kama Trikona house (3rd, 7th, or 11th).
        (2) Lagna Lord and Jupiter are conjoined.
        (3) Sun is exalted and strong.
        (4) Moon is in the 9th house.
    """
    return _gandharva_yoga_calculation(chart_1d=chart_1d, method=method)
```

---

### Garuda Yoga

- **PyJHora Function/Key**: `garuda_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The lord of the Navamsha occupied by the Moon is exalted, and the birth occurs during the day when the Moon is waxing.
- **Effects/Benefits**: You will be respected by the pious, an eloquent speaker, courageous, and face danger from enemies in your 34th year.
- **Notes/Reference**: BVR-66 Garuda Yoga (B.V. Raman #58):
    The lord of Navamsa occupied by the Moon should be exalted in Rasi.
    Birth should occur during daytime when the Moon is waxing.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    BVR-66 Garuda Yoga (B.V. Raman #58):
    The lord of Navamsa occupied by the Moon should be exalted in Rasi.
    Birth should occur during daytime when the Moon is waxing.
    """
    return _garuda_yoga_calculation(chart_1d_rasi=chart_1d_rasi, 
                                   chart_1d_navamsa=chart_1d_navamsa, 
                                   is_shukla_paksha=is_shukla_paksha, 
                                   is_daytime_birth=is_daytime_birth)
```

---

### Go Yoga

- **PyJHora Function/Key**: `go_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If (1) Jupiter is strong in his moolatrikona, (2) the lord of the 2nd house is with Jupiter, and, (3) lagna lord is exalted, then this yoga is present.
- **Effects/Benefits**: One born with this yoga is from a respectable family. Person is wealthy and resepcted by all. Go means a cow.
- **Notes/Reference**: BVR-67 Go Yoga: 
    (1) Jupiter in Moolatrikona (Sag 0-10°).
    (2) 2nd Lord conjoined with Jupiter.
    (3) Lagna lord is exalted.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" 
    BVR-67 Go Yoga: 
    (1) Jupiter in Moolatrikona (Sag 0-10°).
    (2) 2nd Lord conjoined with Jupiter.
    (3) Lagna lord is exalted.
    """
    return _go_yoga_calculation(chart_1d=chart_1d)
```

---

### Gouri Yoga

- **PyJHora Function/Key**: `gouri_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If the lord of the sign occupied in navamsa by the 10th lord is exalted in the 10th house and lagna lord joins him, then this yoga is present.
- **Effects/Benefits**: One born with this yoga is from a respectable family and person is religious and virtuous. Person is blessed with happiness from family. Gouri is a form of Parvati – Lord Siva’s wife. She is an epitome of marital bliss and purity.
- **Notes/Reference**: BVR-28 Gouri Yoga: If the lord of the sign occupied in navamsa by the 10th lord is exalted in
        the 10th house and lagna lord joins him

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-28 Gouri Yoga: If the lord of the sign occupied in navamsa by the 10th lord is exalted in
        the 10th house and lagna lord joins him """
    return _gouri_yoga_calculation(chart_1d_rasi=chart_1d_rasi, chart_1d_navamsa=chart_1d_navamsa)
```

---

### Grihansa Yoga

- **PyJHora Function/Key**: `grihanasa_yoga_191` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 191 - The lord of the 4th should be in the 12th aspected by a malefic.
- **Effects/Benefits**: The person will lose all the house property.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    191 - The lord of the 4th should be in the 12th aspected by a malefic.
    """
    # 1. Standardize Rasi and Navamsa charts
    if planet_positions_rasi is not None:
        chart_rasi = utils.get_house_planet_list_from_planet_positions(planet_positions_rasi)
    
    p_to_h_rasi = utils.get_planet_to_house_dict_from_chart(chart_rasi)
    _natural_malefics = natural_malefics if natural_malefics else const.natural_malefics

    lagna_house_rasi = p_to_h_rasi[const._ascendant_symbol]
    house_12_rasi = (lagna_house_rasi + const.HOUSE_12) % 12
    house_4_rasi = (lagna_house_rasi + const.HOUSE_4) % 12
    
    if planet_positions_rasi is not None:
        lord_of_4th_rasi = int(house.house_owner_from_planet_positions(planet_positions_rasi, house_4_rasi))
    else:
        lord_of_4th_rasi = int(house.house_owner(chart_rasi, house_4_rasi))
    # --- Yoga 191 Calculation ---
    is_4th_lord_in_12th_rasi = p_to_h_rasi[lord_of_4th_rasi] == house_12_rasi
    aspects_on_4th_lord = house.planets_aspecting_the_planet(chart_rasi, lord_of_4th_rasi)
    is_aspected_by_malefic = any(p in _natural_malefics for p in aspects_on_4th_lord)
    return is_4th_lord_in_12th_rasi and is_aspected_by_malefic
```

---

### Grihansa Yoga

- **PyJHora Function/Key**: `grihanasa_yoga_192` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 192 - The lord of the navamsa occupied by the lord of the 4th should be disposed in the 12th.
- **Effects/Benefits**: The person will lose all the house property.

---

### Guhyaroga Yoga

- **PyJHora Function/Key**: `guhyaroga_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 281 - The Moon should join malefics in the Navamsa of Cancer or Scorpio.
- **Effects/Benefits**: The person suffers from diseases in the private parts.
- **Notes/Reference**: 284 - The Moon should join malefics in the Navamsa of Cancer or Scorpio.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        284 - The Moon should join malefics in the Navamsa of Cancer or Scorpio.
    """
    return _guhyaroga_yoga_calculation(chart_navamsa=chart_navamsa, natural_malefics=natural_malefics)
```

---

### Hara Yoga

- **PyJHora Function/Key**: `hara_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Benefic planets are situated in the 4th, 9th, and 8th houses.
- **Effects/Benefits**: You will be happy, well-disposed, and enjoy life's pleasures, though you may sometimes face unexpected turns in fortune.
- **Notes/Reference**: BVR-51 Hara Yoga (part of harihara brahma yoga): 
    If benefics occupy the 4th, 9th and 8th houses counted from the 7th lord.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-51 Hara Yoga (part of harihara brahma yoga): 
    If benefics occupy the 4th, 9th and 8th houses counted from the 7th lord. """
    return _hara_yoga_calculation(chart_1d=chart_1d,natural_benefics=natural_benefics)
```

---

### Hari Yoga

- **PyJHora Function/Key**: `hari_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If benefics occupy the 2nd, 12th and 8th houses counted from the 2nd lord, then this yoga is present.
- **Effects/Benefits**: One born with this yoga is happy, learned and blessed with wealth and children. Hari is a name of Lord Vishnu. The 2nd house is the house of food and money and it is a trine from karma sthana – the 10th house. It stands for sustenance and its lord represents Hari – Sustainer of Hindu Trinity – in a chart.
- **Notes/Reference**: BVR-51 Hari Yoga (part of harihara brahma yoga): 
        If benefics occupy the 2nd, 12th and 8th houses counted from the 2nd lord.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-51 Hari Yoga (part of harihara brahma yoga): 
        If benefics occupy the 2nd, 12th and 8th houses counted from the 2nd lord. """
    return _hari_yoga_calculation(chart_1d=chart_1d,natural_benefics=natural_benefics)
```

---

### Harihara Brahma Yoga

- **PyJHora Function/Key**: `harihara_brahma_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Benefics are placed in the 2nd, 8th, and 12th houses from the Lord of the 9th.
- **Effects/Benefits**: You will be a truthful person, an eloquent speaker, and highly learned in various sciences and scriptures.
- **Notes/Reference**: BVR-51 Definition per BV Raman. 
            If benefics are in the 8th or 12th from the 2nd lord OR 
            if Jupiter, the Moon and Mercury are in the 4th, 9th and 8th from the 7th lord OR 
            if the Sun, Venus and Mars are in the 4th, lOth and 11th from the lord of Lagna
            the above Yoga is caused.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        BVR-51 Definition per BV Raman. 
            If benefics are in the 8th or 12th from the 2nd lord OR 
            if Jupiter, the Moon and Mercury are in the 4th, 9th and 8th from the 7th lord OR 
            if the Sun, Venus and Mars are in the 4th, lOth and 11th from the lord of Lagna
            the above Yoga is caused.
    """
    _hari = hari_yoga(chart_1d)
    _hara = hara_yoga(chart_1d)
    _brahma = brahma_yoga(chart_1d, method=method) 
    return _hari or _hara or _brahma
```

---

### Harsha Yoga

- **PyJHora Function/Key**: `harsha_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If the 6th lord occupies the 6th house, then this yoga is present.
- **Effects/Benefits**: One born with this yoga is happy, strong, good-natured and invincible. Harsha means joyous.
- **Notes/Reference**: BVR-105 Harsha Yoga: 6th lord occupies the 6th house

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-105 Harsha Yoga: 6th lord occupies the 6th house """
    return _vipareeta_yoga_calculation(6, chart_1d=chart_1d)
```

---

### Indra Yoga

- **PyJHora Function/Key**: `indra_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If (1) the 5th and 11th lords have an exchange and (2) Moon occupies the 5th house, then this yoga is present.
- **Effects/Benefits**: One born with this yoga becomes a king. Person is bold, famous and long-lived. Indra is the ruler of gods.
- **Notes/Reference**: BVR-64 Indra Yoga: 
    (1) Exchange between 5th and 11th lords.
    (2) Moon occupies the 5th house.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" 
    BVR-64 Indra Yoga: 
    (1) Exchange between 5th and 11th lords.
    (2) Moon occupies the 5th house.
    """
    return _indra_yoga_calculation(chart_1d=chart_1d)
```

---

### Ishu Yoga

- **PyJHora Function/Key**: `ishu_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All planets occupy the first four houses (1, 2, 3, 4) or from the 4th to 7th, 7th to 10th, or 10th to 1st.
- **Effects/Benefits**: You will be a jailer, a cruel person, or a manufacturer of weapons and arrows.
- **Notes/Reference**: BVR-72 Sara/Ishu Yoga: all the planets are in 4th, 5th, 6th and 7th houses from lagna, 
        NOTE: BV Raman in his book states 4,5,9,7. Not sure spellinhg mistake? (method=2)

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-72 Sara/Ishu Yoga: all the planets are in 4th, 5th, 6th and 7th houses from lagna, 
        NOTE: BV Raman in his book states 4,5,9,7. Not sure spellinhg mistake? (method=2) """
    return sara_yoga(chart_1d,method=method)
```

---

### Jada Yoga

- **PyJHora Function/Key**: `jada_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The lord of the 2nd house is in the 6th, 8th, or 12th house and is aspected by malefic planets.
- **Effects/Benefits**: You may exhibit laziness or a lack of mental sharpness in your activities.
- **Notes/Reference**: Defnition.-The lord of the 2nd should be posited in the l0th with maleficsor the 2nd must be 
        joined by the Sun and Mandi.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        Defnition.-The lord of the 2nd should be posited in the l0th with maleficsor the 2nd must be 
        joined by the Sun and Mandi.
    """
    return _jada_yoga_calculation(chart_1d=chart_1d, natural_malefics=natural_malefics, mandi_house=mandi_house)
```

---

### Jara Yoga

- **PyJHora Function/Key**: `jara_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 236 - he l0th house must be occupied by the lords of the 10th, 2nd and 7th.
- **Effects/Benefits**: The person will have extra-marital relations with a number of women.
- **Notes/Reference**: 236 - The 10th house must be occupied by the lords of the 10th, 2nd and 7th.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        236 - The 10th house must be occupied by the lords of the 10th, 2nd and 7th.
    """
    return _jara_yoga_calculation(chart_1d=chart_1d)
```

---

### Jaya Yoga

- **PyJHora Function/Key**: `jaya_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If (1) the 10th lord is in deep exaltation and (2) the 6th lord is debilitated, then this yoga is present.
- **Effects/Benefits**: One born with this yoga is happy, successful, victorious over enemies and long-lived. Jaya means victorious.
- **Notes/Reference**: BVR-58 Jaya Yoga: 10th lord in deep exaltation and 6th lord debilitated.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-58 Jaya Yoga: 10th lord in deep exaltation and 6th lord debilitated. """
    return _jaya_yoga_calculation(chart_1d=chart_1d, enforce_deep_exaltation=enforce_deep_exaltation)
```

---

### Kalaanidhi Yoga

- **PyJHora Function/Key**: `kalaanidhi_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If (1) Jupiter is in the 2nd house or the 5th house and (2) he is conjoined or aspected by Mercury and Venus, then this yoga is present.
- **Effects/Benefits**: One born with this yoga is endowed with character, happiness, good health, wealth and learning. Person is respected by kings. Kalaanidhi means a treasure of arts and skills.
- **Notes/Reference**: BVR-49 Kalaanidhi Yoga: If (1) Jupiter is in the 2nd house or the 5th house and (2) he is
        conjoined or aspected by Mercury and Venus.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-49 Kalaanidhi Yoga: If (1) Jupiter is in the 2nd house or the 5th house and (2) he is
        conjoined or aspected by Mercury and Venus. """
    return _kalanidhi_yoga_calculation(chart_1d=chart_1d)
```

---

### Kalanidhi Yoga

- **PyJHora Function/Key**: `kalanidhi_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Jupiter is joined with or aspected by Mercury and Venus in the 2nd or the 5th house, and is in the signs of Mercury or Venus.
- **Effects/Benefits**: You will be highly learned, a scholar in many sciences, virtuous, and blessed with good health and immense wealth.
- **Notes/Reference**: BVR-49 Kalanidhi Yoga (B.V. Raman #49):
    Jupiter must join or be aspected by Mercury and Venus either in the 2nd 
    or in the 5th house; Jupiter must occupy the 2nd or 5th identical 
    with the swakshetra (sign) of Mercury or Venus.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    BVR-49 Kalanidhi Yoga (B.V. Raman #49):
    Jupiter must join or be aspected by Mercury and Venus either in the 2nd 
    or in the 5th house; Jupiter must occupy the 2nd or 5th identical 
    with the swakshetra (sign) of Mercury or Venus.
    """
    return _kalanidhi_yoga_calculation(chart_1d=chart_1d)
```

---

### Kalatra Malika Yoga

- **PyJHora Function/Key**: `kalatra_malika_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All seven planets occupy seven continuous houses starting from the 7th house (Kalatra Bhava).
- **Effects/Benefits**: You will be very popular with the opposite sex and may enjoy a high social status through marriage.
- **Notes/Reference**: BVR-38 Kalathra Malika Yoga: Malika Yoga Starting from 7th House

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        BVR-38 Kalathra Malika Yoga: Malika Yoga Starting from 7th House
    """
    return _kalatra_malika_yoga_calc(chart_1d=chart_1d)
```

---

### Kalpadruma Yoga

- **PyJHora Function/Key**: `kalpadruma_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Consider (1) lagna lord, (2) his dispositor, (3) the latter’s dispositor in rasi and (4) in navamsa. If all the four planets are all in quadrants, trines or exaltation signs of both rasi and navamsa, then this yoga is present.
- **Effects/Benefits**: One born with this yoga becomes a king. Person likes wars. Person is very prosperous, principled, strong and kind. Kalpadruma is a celestial tree of the heaven. This yoga is also known as Paarijaata yoga. Paarijaata is a celestial flower.
- **Notes/Reference**: BVR-47 Paarijaatha/Kalpadruma Yoga: Consider (1) lagna lord, (2) his dispositor, (3) the latter’s
        dispositor in rasi and (4) in navamsa. If all the four planets are all in quadrants, trines
        or exaltation signs.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-47 Paarijaatha/Kalpadruma Yoga: Consider (1) lagna lord, (2) his dispositor, (3) the latter’s
        dispositor in rasi and (4) in navamsa. If all the four planets are all in quadrants, trines
        or exaltation signs. """
    return _kalpadruma_yoga_calculation(chart_1d_rasi=chart_1d_rasi, chart_1d_navamsa=chart_1d_navamsa)
```

---

### Kapata Yoga

- **PyJHora Function/Key**: `kapata_yoga_202` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 202 - The 4th house must be joined by a malefic and the 4rh lord must be associated with or aspected by malefics or be hemmed in between malefics.
- **Effects/Benefits**: The person becomes a hypocrite.
- **Notes/Reference**: 202 - The 4th house must be joined by a malefic and the 4rh lord must be associated with or 
            aspected by malefics or be hemmed in between malefics.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        202 - The 4th house must be joined by a malefic and the 4rh lord must be associated with or 
            aspected by malefics or be hemmed in between malefics.
    """
    if planet_positions is not None:
        chart_1d = utils.get_house_planet_list_from_planet_positions(planet_positions)
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    asc_house = p_to_h[const._ascendant_symbol]
    fourth_house = (asc_house+const.HOUSE_4)%12
    if planet_positions is not None:
        lord_of_4th = house.house_owner_from_planet_positions(planet_positions, fourth_house)
    else:
        lord_of_4th = house.house_owner(chart_1d,fourth_house)
    _natural_malefics = natural_malefics if natural_malefics else const.natural_malefics
    malefic_joins_4th_house = any(p_to_h[m] == fourth_house for m in _natural_malefics)
    house_of_lord_of_4th = p_to_h[lord_of_4th]
    aspected_by = house.aspected_planets_of_the_planet(chart_1d, lord_of_4th)
    lord_of_4th_aspected_by_malefic = any(m in aspected_by for m in _natural_malefics)
    lord_of_4th_joined_by_malefic = any(p_to_h[m] == house_of_lord_of_4th for m in _natural_malefics)
    prev_house = (house_of_lord_of_4th - 1) % 12
    next_house = (house_of_lord_of_4th + 1) % 12
    prev_house_malefic = any(p in _natural_malefics for p in planets_in_raasi(prev_house,p_to_h,exclude_lagna=True))
    next_house_malefic = any(p in _natural_malefics for p in planets_in_raasi(next_house,p_to_h,exclude_lagna=True))
    is_4th_lord_hemmed_between_malefics = prev_house_malefic and next_house_malefic
    return malefic_joins_4th_house and (lord_of_4th_aspected_by_malefic or lord_of_4th_joined_by_malefic or 
                                        is_4th_lord_hemmed_between_malefics)
```

---

### Kapata Yoga

- **PyJHora Function/Key**: `kapata_yoga_203` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 203 - The 4th must be occupied by Sani, Kuja, Rahu, and the malefic 1Oth lord, who in his turn should be aspected by malefics.
- **Effects/Benefits**: The person becomes a hypocrite.
- **Notes/Reference**: 203 - The 4th must be occupied by Sani, Kuja, Rahu, and the malefic 1Oth lord, who in his turn should 
            be aspected by malefics.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        203 - The 4th must be occupied by Sani, Kuja, Rahu, and the malefic 1Oth lord, who in his turn should 
            be aspected by malefics.
    """
    if planet_positions is not None:
        chart_1d = utils.get_house_planet_list_from_planet_positions(planet_positions)
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    asc_house = p_to_h[const._ascendant_symbol]
    fourth_house = (asc_house+const.HOUSE_4)%12
    _natural_malefics = natural_malefics if natural_malefics else const.natural_malefics
    ## Yoga 203 Check
    # 4th house occupied by Saturn, Mars, Rahu
    fourth_occupied_by_saturn_mars_rahu = (p_to_h[const.SATURN_ID]==p_to_h[const.MARS_ID]==p_to_h[const.RAHU_ID]==fourth_house)
    # 10th lord aspected by malefics
    tenth_house = (asc_house+const.HOUSE_10)%12
    if planet_positions is not None:
        lord_of_10th = house.house_owner_from_planet_positions(planet_positions, tenth_house)
    else:
        lord_of_10th = house.house_owner(chart_1d,tenth_house)
    aspected_by = house.aspected_planets_of_the_planet(chart_1d, lord_of_10th)
    lord_of_10th_is_a_malefic = lord_of_10th in _natural_malefics
    lord_of_10th_aspected_by_malefic = any(m in aspected_by for m in _natural_malefics)
    return fourth_occupied_by_saturn_mars_rahu and lord_of_10th_is_a_malefic \
                    and lord_of_10th_aspected_by_malefic
```

---

### Kapata Yoga

- **PyJHora Function/Key**: `kapata_yoga_204` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 204 - The 4th lord must join Saturn, Mandi and Rahu and aspected by malefics.
- **Effects/Benefits**: The person becomes a hypocrite.
- **Notes/Reference**: 204 - The 4th lord must join Saturn, Mandi and Rahu and aspected by malefics

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        204 - The 4th lord must join Saturn, Mandi and Rahu and aspected by malefics
    """
    if planet_positions is not None:
        chart_1d = utils.get_house_planet_list_from_planet_positions(planet_positions)
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    asc_house = p_to_h[const._ascendant_symbol]
    fourth_house = (asc_house+const.HOUSE_4)%12
    if planet_positions is not None:
        lord_of_4th = house.house_owner_from_planet_positions(planet_positions, fourth_house)
    else:
        lord_of_4th = house.house_owner(chart_1d,fourth_house)
    _natural_malefics = natural_malefics if natural_malefics else const.natural_malefics
    house_of_lord_of_4th = p_to_h[lord_of_4th]
    aspected_by = house.aspected_planets_of_the_planet(chart_1d, lord_of_4th)
    lord_of_4th_aspected_by_malefic = any(m in aspected_by for m in _natural_malefics)
    # Yoga 204 check
    # The 4th lord must join Saturn, Mandi and Rahu and aspected by malefics
    if maandi_house is None:
        lord_of_4th_joins_saturn_mandi_rahu = False
    else:
        lord_of_4th_joins_saturn_mandi_rahu = (p_to_h[const.SATURN_ID]==maandi_house==p_to_h[const.RAHU_ID]==house_of_lord_of_4th)
    return lord_of_4th_joins_saturn_mandi_rahu and lord_of_4th_aspected_by_malefic
```

---

### Karascheda Yoga

- **PyJHora Function/Key**: `karascheda_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 272 - Saturn and Jupiter should be in the 9th and the 3rd.
- **Effects/Benefits**: The native's hands will be cut off.
- **Notes/Reference**: 272 - Saturn and Jupiter should be in 9th and 3rd houses.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        272 - Saturn and Jupiter should be in 9th and 3rd houses.
    """
    return _karascheda_yoga_calculation(chart_1d=chart_1d)
```

---

### Karma Malika Yoga

- **PyJHora Function/Key**: `karma_malika_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All seven planets occupy seven continuous houses starting from the 10th house (Karma Bhava).
- **Effects/Benefits**: You will be highly successful in your career, respected by the state, and a leader in your field.
- **Notes/Reference**: BVR-41 Karma Malika Yoga: Malika Yoga Starting from 10th House

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        BVR-41 Karma Malika Yoga: Malika Yoga Starting from 10th House
    """
    return _karma_malika_yoga_calc(chart_1d=chart_1d)
```

---

### Kedara Yoga

- **PyJHora Function/Key**: `kedara_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All seven planets are distributed among four different signs.
- **Effects/Benefits**: You will be a farmer or associated with land, truthful, happy, and helpful to others.
- **Notes/Reference**: BVR-94 Kedara Yoga: 7 planets in 4 signs (B.V. Raman #85)

**Python Logic Summary (PyJHora Implementation)**:
```python
"""BVR-94 Kedara Yoga: 7 planets in 4 signs (B.V. Raman #85)"""
    return _sankhya_yoga_calculation(chart_1d=chart_1d, required_count=4)
```

---

### Khadga Yoga

- **PyJHora Function/Key**: `khadga_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If (1) the 2nd lord is in the 9th house, (2) the 9th lord is in the 2nd house, and, (3) lagna lord is in a quadrant or a trine, then this yoga is present.
- **Effects/Benefits**: One born with this yoga is skillful, wealthy, learned, happy, fortunate, intelligent, grateful and mighty. Khadga means a sword.
- **Notes/Reference**: Khadga Yoga: If (1) the 2nd lord is in the 9th house, (2) the 9th lord is in the 2nd
        house, and, (3) lagna lord is in a quadrant or a trine.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" Khadga Yoga: If (1) the 2nd lord is in the 9th house, (2) the 9th lord is in the 2nd
        house, and, (3) lagna lord is in a quadrant or a trine. """
    return _khadga_yoga_calculation(chart_1d=chart_1d)
```

---

### Khalwata Yoga

- **PyJHora Function/Key**: `khalwata_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 295 - The ascendant must be a malefic sign or Sagittarius or Taurus aspected by malefic planets.
- **Effects/Benefits**: The person will be bald-headed.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        295 - The ascendant must be a malefic sign or Sagittarius or Taurus aspected by malefic planets.
    """
    return _khalwata_yoga_calculation(chart_1d=chart_1d, natural_malefics=natural_malefics)
```

---

### Koorma Yoga

- **PyJHora Function/Key**: `koorma_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If (1) the 5th, 6th and 7th houses are occupied by benefics who are in own, exaltation or friendly signs and (2) the 1st, 3rd and 11th houses are occupied by malefics who are in own or exaltation signs, then this yoga is present.
- **Effects/Benefits**: One born with this yoga becomes a king. Person has piety and character. Person is happy, helpful and famous. Koorma means a tortoise.
- **Notes/Reference**: BVR-54 Koorma Yoga: If (1) the 5th, 6th and 7th houses are occupied by benefics who are in
        own, exaltation or friendly signs and (2) the 1st, 3rd and 11th houses are occupied by
        malefics who are in own or exaltation signs. 
        Method = 1 BV Raman - 
            2nd condition is also for BENEFICS (not malefics) AND 
            ONLY ONE of the above two conditions required
            Condition >= Friend, exalt, own
        Method = 2 PVR - 
            BOTH conditions are required and 1st for benefics and 2nd for malefics
            Condition 1 == Friend/exalt/Own and Condition 2 >= exalt/Own (No Friend)

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-54 Koorma Yoga: If (1) the 5th, 6th and 7th houses are occupied by benefics who are in
        own, exaltation or friendly signs and (2) the 1st, 3rd and 11th houses are occupied by
        malefics who are in own or exaltation signs. 
        Method = 1 BV Raman - 
            2nd condition is also for BENEFICS (not malefics) AND 
            ONLY ONE of the above two conditions required
            Condition >= Friend, exalt, own
        Method = 2 PVR - 
            BOTH conditions are required and 1st for benefics and 2nd for malefics
            Condition 1 == Friend/exalt/Own and Condition 2 >= exalt/Own (No Friend)
    """
    return _koorma_yoga_calculation(chart_1d=chart_1d, method=method,natural_benefics=natural_benefics,
                                    natural_malefics=natural_malefics)
```

---

### Krisanga Yoga

- **PyJHora Function/Key**: `krisanga_yoga_112` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Lagna lord in a dry sign or in a sign owned by a dry planet.
- **Effects/Benefits**: You will have a lean, thin, or emaciated physical appearance.
- **Notes/Reference**: BVR-112 Krisanga Yoga  
    Lagna lord in a dry sign or in a sign owned by a dry planet.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    BVR-112 Krisanga Yoga  
    Lagna lord in a dry sign or in a sign owned by a dry planet.
    """
    if planet_positions_rasi is not None:
        chart_rasi = utils.get_house_planet_list_from_planet_positions(planet_positions_rasi)
        if planet_positions_navamsa is None:
            planet_positions_navamsa = charts.navamsa_chart(planet_positions_rasi)[:const._pp_count_upto_ketu]
    if planet_positions_navamsa is not None:
        chart_navamsa = utils.get_house_planet_list_from_planet_positions(planet_positions_navamsa)
    
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_rasi)
    asc_house = p_to_h.get(const._ascendant_symbol)
    if asc_house is None: return False

    if planet_positions_rasi is not None:
        lagna_lord = int(house.house_owner_from_planet_positions(planet_positions_rasi, asc_house))
    else:
        lagna_lord = int(house.house_owner(chart_rasi, asc_house))

    if natural_malefics is None:
        _natural_malefics = set(const.natural_malefics)
    else:
        _natural_malefics = set(natural_malefics)

    # --- Condition 1 (Rasi Logic) ---
    ll_house = p_to_h[lagna_lord]
    
    if planet_positions_rasi is not None:
        ll_house_owner = int(house.house_owner_from_planet_positions(planet_positions_rasi, ll_house))
    else:
        ll_house_owner = int(house.house_owner(chart_rasi, ll_house))
    
    # LL in dry sign OR LL house owned by dry planet 
    return (ll_house in const.dry_signs) or (ll_house_owner in const.dry_planets)
```

---

### Krisanga Yoga

- **PyJHora Function/Key**: `krisanga_yoga_113` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The Navamsa Lagna is owned by a dry planet AND malefics join the Rasi Lagna.
- **Effects/Benefits**: You will have a lean, thin, or emaciated physical appearance.
- **Notes/Reference**: BVR-113 Krisanga Yoga  
    The Navamsa Lagna is owned by a dry planet AND malefics join the Rasi Lagna.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    BVR-113 Krisanga Yoga  
    The Navamsa Lagna is owned by a dry planet AND malefics join the Rasi Lagna.
    """
    if planet_positions_rasi is not None:
        chart_rasi = utils.get_house_planet_list_from_planet_positions(planet_positions_rasi)
        if planet_positions_navamsa is None:
            planet_positions_navamsa = charts.navamsa_chart(planet_positions_rasi)[:const._pp_count_upto_ketu]
    
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_rasi)
    asc_house = p_to_h.get(const._ascendant_symbol)
    if asc_house is None: return False
    _natural_malefics= set(const.natural_malefics) if natural_malefics is None else set(natural_malefics)
    # --- Condition 2 (Navamsa + Rasi Conjunction Logic) ---
    if planet_positions_navamsa is not None:
        chart_navamsa = utils.get_house_planet_list_from_planet_positions(planet_positions_navamsa)
        p_to_h_9d = utils.get_planet_house_dictionary_from_planet_positions(planet_positions_navamsa)
        asc_house_9d = p_to_h_9d.get(const._ascendant_symbol)
        nav_lagna_owner = house.house_owner_from_planet_positions(planet_positions_navamsa, asc_house_9d)
    elif chart_navamsa is not None:
        p_to_h_9d = utils.get_planet_to_house_dict_from_chart(chart_navamsa)
        asc_house_9d = p_to_h_9d.get(const._ascendant_symbol)
        nav_lagna_owner = int(house.house_owner(chart_navamsa, asc_house_9d))
    else: return False
    # Navamsa Lagna owned by dry planet AND Malefics in Rasi Lagna
    malefic_in_lagna = any(p_to_h[m] == asc_house for m in _natural_malefics if m in p_to_h)
    condition_2 = (nav_lagna_owner in const.dry_planets) and malefic_in_lagna
    return condition_2
```

---

### Kshayaroga Yoga

- **PyJHora Function/Key**: `kshayaroga_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 270 - Rahu in the 6th, Mandi in a kendra from Lagna, and the lord of Lagna in the 8th gives rise to this yoga.
- **Effects/Benefits**: The person suffers from tuberculosis.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        270 - Rahu in the 6th, Mandi in a kendra from Lagna, and the lord of Lagna in the 8th gives rise to this yoga.
    """
    return _kshayaroga_yoga_calculation(
        chart_1d=chart_1d,
        maandi_house=maandi_house,
        skip_other_variations=True
    )
```

---

### Kushtaroga Yoga

- **PyJHora Function/Key**: `kushtaroga_yoga_268` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 268 - The lord of Lagna must join Mars and Mercury in the 4th or 12th house.
- **Effects/Benefits**: The person suffers from leprosy.
- **Notes/Reference**: 268 - The lord of Lagna must join Mars and Mercury in the 4th or 12th house .

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        268 - The lord of Lagna must join Mars and Mercury in the 4th or 12th house .
    """
    return _kushtaroga_yoga_268_calculation(chart_1d=chart_1d)
```

---

### Kushtaroga Yoga

- **PyJHora Function/Key**: `kushtaroga_yoga_269` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 269 - Jupiter in conjunction with Saturn and the Moon should occupy the 6th house.
- **Effects/Benefits**: The person suffers from leprosy.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        269 - Jupiter in conjunction with Saturn and the Moon should occupy the 6th house.    
    """
    return _kushtaroga_yoga_269_calculation(chart_1d=chart_1d)
```

---

### Kusuma Yoga

- **PyJHora Function/Key**: `kusuma_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If (1) lagna is in a fixed sign, (2) Venus is in a quadrant, (3) Moon is in a trine with a benefic, and, (4) Saturn is in the 10th house, then this yoga is present.
- **Effects/Benefits**: One born with this yoga becomes a king or an equal. Person is charitable. Person is endowed with pleasures and happiness. Person is a leader of community. Person has character and scholarship. Kusuma means a flower.
- **Notes/Reference**: BVR-52 Kusuma Yoga: If (1) lagna is in a fixed sign, (2) Venus is in a quadrant, (3) Moon is
        in a trine with a benefic, and, (4) Saturn is in the 10th house.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-52 Kusuma Yoga: If (1) lagna is in a fixed sign, (2) Venus is in a quadrant, (3) Moon is
        in a trine with a benefic, and, (4) Saturn is in the 10th house. """
    return _kusuma_yoga_calculation(chart_1d=chart_1d)
```

---

### Laabha Malika Yoga

- **PyJHora Function/Key**: `laabha_malika_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All seven planets occupy seven continuous houses starting from the 11th house (Laabha Bhava).
- **Effects/Benefits**: You will have multiple sources of income and fulfill all your desires through your social network.
- **Notes/Reference**: BVR-42 Laabha Malika Yoga: Malika Yoga Starting from 11th House

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        BVR-42 Laabha Malika Yoga: Malika Yoga Starting from 11th House
    """
    return _laabha_malika_yoga_calc(chart_1d=chart_1d)
```

---

### Lagna Malika Yoga

- **PyJHora Function/Key**: `lagna_malika_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All seven planets occupy seven continuous houses starting from the Lagna (1st house).
- **Effects/Benefits**: You will be a commander or a ruler, possessing wealth, many vehicles, and high social status.
- **Notes/Reference**: BVR-32 Lagna Malika Yoga: Malika Yoga Starting from 1st House

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        BVR-32 Lagna Malika Yoga: Malika Yoga Starting from 1st House
    """
    return _lagna_malika_yoga_calc(chart_1d=chart_1d)
```

---

### Lakshmi Yoga

- **PyJHora Function/Key**: `lakshmi_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If (1) the 9th lord is in an own sign or in his exaltation sign that happens to be quadrant from lagna and (2) lagna lord is strong, then this yoga is present.
- **Effects/Benefits**: One born with this yoga becomes a king. Person is blessed with good looks, character, wealth and many children. Person is principled and famous. Lakshmi is Vishnu’s wife. She is the goddess of prosperity.
- **Notes/Reference**: BVR-27 Lakshmi Yoga: 
    Method 1 (PVR): 9th lord is in own sign or exaltation sign that happens to be a quadrant 
    from lagna and lagna lord is strong.
    Method 2 (BV Raman): Lagna lord is powerful and 9th lord occupies own or 
    exaltation sign identical with a Kendra or Thrikona.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" 
    BVR-27 Lakshmi Yoga: 
    Method 1 (PVR): 9th lord is in own sign or exaltation sign that happens to be a quadrant 
    from lagna and lagna lord is strong.
    Method 2 (BV Raman): Lagna lord is powerful and 9th lord occupies own or 
    exaltation sign identical with a Kendra or Thrikona.
    """
    return _lakshmi_yoga_calculation(chart_1d=chart_1d, method=method)
```

---

### Maathru Naasa yoga

- **PyJHora Function/Key**: `matrunasa_yoga_198` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 198 - The Moon should be hemmed in between, associated with or aspected by evil planets.
- **Effects/Benefits**: The person's mother will have a very early death.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        198 - The Moon should be hemmed in between, associated with or aspected by evil planets.
    """
    if planet_positions_rasi is not None:
        chart_rasi = utils.get_house_planet_list_from_planet_positions(planet_positions_rasi)
    if chart_rasi is None: return False
    p_to_h_rasi = utils.get_planet_to_house_dict_from_chart(chart_rasi)
    _natural_malefics = natural_malefics if natural_malefics else const.natural_malefics
    moon_house = p_to_h_rasi[const.MOON_ID]
    # --- Yoga 198 Logic ---
    # Per BVR: Moon hemmed, associated with, or aspected by evil planets
    # 1. Associated with malefic (Conjunction)
    #planets_in_moon_house = [p for p, h in p_to_h_rasi.items() if h == moon_house]
    planets_in_moon_house = planets_in_raasi(moon_house,p_to_h_rasi,exclude_lagna=True)
    associated_malefic = any(p in _natural_malefics for p in planets_in_moon_house)
    # 2. Aspected by malefic
    aspected_by_malefic = any(p in _natural_malefics for p in house.aspected_planets_of_the_raasi(chart_rasi, moon_house))
    # 3. Hemmed in (Papa Kartari)
    prev_house = (moon_house - 1) % 12
    next_house = (moon_house + 1) % 12
    prev_house_malefic = any(p in _natural_malefics for p in planets_in_raasi(prev_house,p_to_h_rasi,exclude_lagna=True))
    next_house_malefic = any(p in _natural_malefics for p in planets_in_raasi(next_house,p_to_h_rasi,exclude_lagna=True))
    hemmed = prev_house_malefic and next_house_malefic
    return hemmed or associated_malefic or aspected_by_malefic
```

---

### Maathru Naasa yoga

- **PyJHora Function/Key**: `matrunasa_yoga_199` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 199 - The planet owning the navamsa, in which the lord of the navamsa occupied by the 4th lord is situated should be disposed in the 6th, 8th or 12th house.
- **Effects/Benefits**: The person's mother will have a very early death.
- **Notes/Reference**: 199 - The planet owning the navamsa, in which the lord of the navamsa occupied by the 4th lord is 
            situated should be disposed in the 6th, 8th or 12th house.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        199 - The planet owning the navamsa, in which the lord of the navamsa occupied by the 4th lord is 
            situated should be disposed in the 6th, 8th or 12th house.
    """
    if planet_positions_rasi is not None:
        chart_rasi = utils.get_house_planet_list_from_planet_positions(planet_positions_rasi)
        if planet_positions_navamsa is None:
            planet_positions_navamsa = charts.navamsa_chart(planet_positions_rasi)[:const._pp_count_upto_ketu]
            chart_navamsa = utils.get_house_planet_list_from_planet_positions(planet_positions_navamsa)
    if chart_rasi is None or chart_navamsa is None: return False
    p_to_h_rasi = utils.get_planet_to_house_dict_from_chart(chart_rasi)
    lagna_house_rasi = p_to_h_rasi[const._ascendant_symbol]
    # --- Yoga 199 Logic ---
    # Navamsa chain: 4th lord's Navamsa lord -> its Navamsa lord -> Rasi position in 6/8/12
    p_to_h_navamsa = utils.get_planet_to_house_dict_from_chart(chart_navamsa)
    # Step A: Find 4th lord in Rasi
    h4_rasi_idx = (lagna_house_rasi + const.HOUSE_4) % 12
    if planet_positions_rasi is not None:
        lord_4 = int(house.house_owner_from_planet_positions(planet_positions_rasi, h4_rasi_idx))
    else:
        lord_4 = int(house.house_owner(chart_rasi, h4_rasi_idx))
    # Step B: Lord of the Navamsa occupied by the 4th lord
    nav_house_of_lord4 = p_to_h_navamsa[lord_4]
    if planet_positions_navamsa is not None:
        lord_of_nav_house = int(house.house_owner_from_planet_positions(planet_positions_navamsa, nav_house_of_lord4))
    else:
        lord_of_nav_house = int(house.house_owner(chart_navamsa, nav_house_of_lord4))
    # Step C: The planet owning the Navamsa in which 'lord_of_nav_house' is situated
    nav_house_of_step_b = p_to_h_navamsa[lord_of_nav_house]
    if planet_positions_navamsa is not None:
        final_planet = int(house.house_owner_from_planet_positions(planet_positions_navamsa, nav_house_of_step_b))
    else:
        final_planet = int(house.house_owner(chart_navamsa, nav_house_of_step_b))
    # Step D: Final planet must be in 6th, 8th, or 12th house in Rasi chart
    final_planet_house_rasi = p_to_h_rasi[final_planet]
    # Using your formulas for house calculation
    house_6_rasi = (lagna_house_rasi + const.HOUSE_6) % 12
    house_8_rasi = (lagna_house_rasi + const.HOUSE_8) % 12
    house_12_rasi = (lagna_house_rasi + const.HOUSE_12) % 12
    return final_planet_house_rasi in [house_6_rasi, house_8_rasi, house_12_rasi]
```

---

### Maathru Saapa Sutakshaya Yoga

- **PyJHora Function/Key**: `maathru_saapa_sutakshaya_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: A. The 8th lord is in the 5th lord's house AND the 5th lord is in the 8th lord's house AND B the Moon and the 4th lord join the 6th house
- **Effects/Benefits**: There will be loss of children due to the curse of the mother.
- **Notes/Reference**: BVR 217 - Maathru Saapa Sutakshya Yoga
        A. The 8th lord is in the 5th lord's house AND the 5th lord is in the 8th lord's house AND 
        B the Moon and the 4th lord join the 6th house

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        BVR 217 - Maathru Saapa Sutakshya Yoga
        A. The 8th lord is in the 5th lord's house AND the 5th lord is in the 8th lord's house AND 
        B the Moon and the 4th lord join the 6th house
    """
    return _maathru_saapa_sutakshaya_yoga_calculation(chart_1d=chart_1d)
```

---

### Maathru Sneha Yoga

- **PyJHora Function/Key**: `matru_sneha_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: First Variation - The Lagna (1st house) and the 4th house have the same planetary ruler. The lst and 4th houses can have common lords only in respect of Ge/Vi (Me) or Sg/Pi (Ju). Second Variation - The lords of the 1st and 4th houses are either natural or temporal friends. Third Variation - The Lagna lord (1st house ruler) and the 4th house lord are aspected by benefics.
- **Effects/Benefits**: Cordial relations will prevail between mother and son.
- **Notes/Reference**: First Variation - The Lagna (1st house) and the 4th house have the same planetary ruler
        The lst and 4th houses can have common lords only in respect of Ge/Vi (Me) or Sg/Pi (Ju) 
        Second Variation - The lords of the 1st and 4th houses are either natural or temporal friends.
        Third Variation - The Lagna lord (1st house ruler) and the 4th house lord are aspected by benefics.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        First Variation - The Lagna (1st house) and the 4th house have the same planetary ruler
        The lst and 4th houses can have common lords only in respect of Ge/Vi (Me) or Sg/Pi (Ju) 
        Second Variation - The lords of the 1st and 4th houses are either natural or temporal friends.
        Third Variation - The Lagna lord (1st house ruler) and the 4th house lord are aspected by benefics.
    """
    return _matru_sneha_yoga_calculation(chart_1d=chart_1d, natural_benefics=natural_benefics)
```

---

### Mahabhagya Yoga

- **PyJHora Function/Key**: `mahabhagya_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: For males: Birth in daytime with Lagna, Sun, and Moon in odd signs. For females: Birth at night with Lagna, Sun, and Moon in even signs.
- **Effects/Benefits**: You will be extremely fortunate, wealthy, famous, and live a long life with a noble character.
- **Notes/Reference**: BVR-25 Mahabhagya Yoga: Formed based on gender, time of birth, and sign types.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-25 Mahabhagya Yoga: Formed based on gender, time of birth, and sign types. """
    return _mahabhagya_yoga_calculation(chart_1d=chart_1d, gender=gender, day_time_birth=day_time_birth)
```

---

### Makuta Yoga

- **PyJHora Function/Key**: `makuta_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If (1) Jupiter is in the 9th house from the 9th lord, (2) the 9th house from Jupiter has a benefic, and, (3) Saturn is in the 10th house, then this yoga is present.
- **Effects/Benefits**: One born with this yoga is a powerful leader of men. Person often manages unruly activities. Makuta means crown.
- **Notes/Reference**: BVR-56 Makuta Yoga: Jupiter 9th from 9th lord, benefic 9th from Jupiter, Saturn in 10th

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-56 Makuta Yoga: Jupiter 9th from 9th lord, benefic 9th from Jupiter, Saturn in 10th """
    return _makuta_yoga_calculation(chart_1d=chart_1d)
```

---

### Marud Yoga

- **PyJHora Function/Key**: `marud_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Venus, Jupiter, and the Moon are in Kendra or Thrikona houses.
- **Effects/Benefits**: You will be fortunate, have an interest in music and arts, and possess a very attractive personality.
- **Notes/Reference**: Marud Yoga: Jupiter in 5th or 9th from Venus, the Moon in the 5th from Jupiter 
    and the Sun in a kendra from the Moon.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Marud Yoga: Jupiter in 5th or 9th from Venus, the Moon in the 5th from Jupiter 
    and the Sun in a kendra from the Moon.
    """
    return _marud_yoga_calculation(chart_1d=chart_1d)
```

---

### Mathibhramana Yoga

- **PyJHora Function/Key**: `mathibhramana_yoga_291` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 291 - Jupiter and Mars should occupy the Lagna and the 7th respectively.
- **Effects/Benefits**: The person becomes insane.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" 
        291 - Jupiter and Mars should occupy the Lagna and the 7th respectively.
    """
    if planet_positions is not None:
        chart_1d = utils.get_house_planet_list_from_planet_positions(planet_positions)
        p_to_h = utils.get_planet_house_dictionary_from_planet_positions(planet_positions)
    elif chart_1d is not None:
        p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    else:
        return False
    lagna_house = p_to_h[const._ascendant_symbol]; house_7th = (lagna_house+const.HOUSE_7)%12
    return ( p_to_h[const.JUPITER_ID]==lagna_house and p_to_h[const.MARS_ID] == house_7th )
```

---

### Mathibhramana Yoga

- **PyJHora Function/Key**: `mathibhramana_yoga_292` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 292 - Saturn must be in Lagna and Mars should join the 9th, 5th or 7th.
- **Effects/Benefits**: The person becomes insane.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" 
        292 - Saturn must be in Lagna and Mars should join the 9th, 5th or 7th.
    """
    if planet_positions is not None:
        chart_1d = utils.get_house_planet_list_from_planet_positions(planet_positions)
        p_to_h = utils.get_planet_house_dictionary_from_planet_positions(planet_positions)
    elif chart_1d is not None:
        p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    else:
        return False
    lagna_house = p_to_h[const._ascendant_symbol]
    return ( p_to_h[const.SATURN_ID]==lagna_house and p_to_h[const.MARS_ID] in [(lagna_house+h-1) for h in[5,7,9]])
```

---

### Mathibhramana Yoga

- **PyJHora Function/Key**: `mathibhramana_yoga_293` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 293 - Saturn must occupy the 12th with the waning Moon.
- **Effects/Benefits**: The person becomes insane.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" 
        293 - Saturn must occupy the 12th with the waning Moon.
    """
    if planet_positions is not None:
        chart_1d = utils.get_house_planet_list_from_planet_positions(planet_positions)
        p_to_h = utils.get_planet_house_dictionary_from_planet_positions(planet_positions)
    elif chart_1d is not None:
        p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    else:
        return False
    lagna_house = p_to_h[const._ascendant_symbol]
    return ( is_waning_moon and p_to_h[const.SATURN_ID]==(lagna_house+const.HOUSE_12)%12)
```

---

### Mathibhramana Yoga

- **PyJHora Function/Key**: `mathibhramana_yoga_294` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 294 - The Moon and Mercury should be in a kendra, aspected by or conjoined with any other planet.
- **Effects/Benefits**: The person becomes insane.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" 
        294 - The Moon and Mercury should be in a kendra, aspected by or conjoined with any other planet.    
    """
    if planet_positions is not None:
        chart_1d = utils.get_house_planet_list_from_planet_positions(planet_positions)
        p_to_h = utils.get_planet_house_dictionary_from_planet_positions(planet_positions)
    elif chart_1d is not None:
        p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    else:
        return False
    lagna_house = p_to_h[const._ascendant_symbol]
    favorable_houses = quadrants_of_the_house(lagna_house)
    planets_aspecting_moon = house.planets_aspecting_the_planet(chart_1d, const.MOON_ID)
    planets_aspecting_mercury = house.planets_aspecting_the_planet(chart_1d, const.MERCURY_ID)
    return ( p_to_h[const.MOON_ID] in favorable_houses and p_to_h[const.MERCURY_ID] in favorable_houses and
             len(planets_aspecting_moon)>0 and len(planets_aspecting_mercury)>0)
```

---

### Mathibhramana Yoga

- **PyJHora Function/Key**: `mathibhramana_yoga_variation` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: This yoga occurs, per B.V.Raman Variations, if - (1) The 6th is occupied by Rahu and aspected by Kethu. (2) The 6th lord is further affiicted by conjunction with Mars. (3) The planet of nerves Mercury is in a common sign in conjunction with two malefics, Mars and Sun. (4) In the Navamsa again Mercury occupies the 6th with Rahu and the 6th lord is in conjunction with Mars.
- **Effects/Benefits**: The person becomes insane.

---

### Mathru Sathruthwa Yoga

- **PyJHora Function/Key**: `matru_satrutwa_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Mercury, being lord of Lagna and the 4th, must join with or be aspected by a malefic.
- **Effects/Benefits**: The person will hate his mother.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        Mercury, being lord of Lagna and the 4th, must join with or be aspected by a malefic.
    """
    return _matru_satrutwa_yoga_calculation(chart_1d=chart_1d, natural_malefics=natural_malefics)
```

---

### Matsya Yoga

- **PyJHora Function/Key**: `matsya_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If (1) benefics are in lagna and 9th, (2) some planets are in 5th, and, (3) malefics are in chaturasras (4th and 8th houses), then this yoga is present.
- **Effects/Benefits**: One born with this yoga becomes an astrologer or a seer. Person is a personification of kindness, character and intelligence. Person is strong and good-looking. Person is famous and learned. Person is a tapasvi (austere pursuer). Matsya means a fish.
- **Notes/Reference**: BVR-53 Matsya Yoga - 2 methods
    - BV Raman (300 Important Combinations): (method=1)
        (1) Malefics in Lagna AND 9th (optionally ONLY malefics if strict_exclusive=True)
        (2) 5th contains BOTH benefics AND malefics
        (3) 4th AND 8th contain ONLY malefics (and at least one in each)

    - Parasari / Jātaka Parijāta stream (common modern presentation): (method=2) PVR Book.
        (1) Benefics in Lagna AND 9th (optionally ONLY benefics if strict_exclusive=True)
        (2) 5th contains BOTH benefics AND malefics
        (3) 4th AND 8th contain ONLY malefics (and at least one in each)

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-53 Matsya Yoga - 2 methods
    - BV Raman (300 Important Combinations): (method=1)
        (1) Malefics in Lagna AND 9th (optionally ONLY malefics if strict_exclusive=True)
        (2) 5th contains BOTH benefics AND malefics
        (3) 4th AND 8th contain ONLY malefics (and at least one in each)

    - Parasari / Jātaka Parijāta stream (common modern presentation): (method=2) PVR Book.
        (1) Benefics in Lagna AND 9th (optionally ONLY benefics if strict_exclusive=True)
        (2) 5th contains BOTH benefics AND malefics
        (3) 4th AND 8th contain ONLY malefics (and at least one in each)
    """
    return _matsya_yoga_calculation(chart_1d=chart_1d,method=method,natural_benefics=natural_benefics,
                                    natural_malefics=natural_malefics)
```

---

### Mooka Yoga

- **PyJHora Function/Key**: `mooka_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The 2nd lord is in the 8th house and is associated with malefic planets.
- **Effects/Benefits**: This combination may indicate speech difficulties or a tendency toward being mute.
- **Notes/Reference**: Mooka Yoga: The 2nd lord should join the 8th with Jupiter. 
    The yoga does not apply if the 8th house happens to be Jupiter's own or exaltation sign.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Mooka Yoga: The 2nd lord should join the 8th with Jupiter. 
    The yoga does not apply if the 8th house happens to be Jupiter's own or exaltation sign.
    """
    return _mooka_yoga_calculation(chart_1d)
```

---

### Mridanga Yoga

- **PyJHora Function/Key**: `mridanga_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If (1) there are planets in own and exaltation signs in quadrants and trines and (2) lagna lord is strong, then this yoga is present.
- **Effects/Benefits**: One born with this yoga is a king or an equal and is happy. Mridanga is a rich and elegant percussion instrument popular in south India.
- **Notes/Reference**: BVR-46 Mridanga Yoga: If (1) there are planets in own and exaltation signs in quadrants
        and trines and (2) lagna lord is strong.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-46 Mridanga Yoga: If (1) there are planets in own and exaltation signs in quadrants
        and trines and (2) lagna lord is strong. """
    return _mridanga_yoga_calculation(chart_1d=chart_1d)
```

---

### Nav Yoga

- **PyJHora Function/Key**: `nav_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All planets are situated in seven continuous signs from any house.
- **Effects/Benefits**: You will be famous, recognized, and enjoy the fruits of your labor throughout life.
- **Notes/Reference**: BVR-75 Naukaa (Nauka)/Nav Yoga: All seven visible planets (Sun..Saturn) occupy the seven
    consecutive houses commencing from Lagna (1st through 7th), with none of those
    houses empty and no visible planet outside this span.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    BVR-75 Naukaa (Nauka)/Nav Yoga: All seven visible planets (Sun..Saturn) occupy the seven
    consecutive houses commencing from Lagna (1st through 7th), with none of those
    houses empty and no visible planet outside this span.
    """
    return naukaa_yoga(chart_1d)
```

---

### Netranasa Yoga

- **PyJHora Function/Key**: `netranasa_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The Sun or Moon is under the aspect of malefic planets while the 2nd or 12th house is weak.
- **Effects/Benefits**: There is a possibility of eye-related problems or defects in vision.
- **Notes/Reference**: Netranasa Yoga: If the lords of the 10th and 6th occupy Lagna with the 2nd lord, 
    or if they are in Neechamsat (debilitation).

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Netranasa Yoga: If the lords of the 10th and 6th occupy Lagna with the 2nd lord, 
    or if they are in Neechamsat (debilitation).
    """
    return _netranasa_yoga_calculation(chart_1d=chart_1d)
```

---

### Nishkapata Yoga

- **PyJHora Function/Key**: `nishkapata_yoga_205` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 205 - The 4th house must be occupied by a benefic, or a planet in exaltation, friendly or own house,or the 4th house must be a benefic sign.
- **Effects/Benefits**: The person will be pure-hearted and hates secrecy and hypocrisy.

---

### Nishkapata Yoga

- **PyJHora Function/Key**: `nishkapata_yoga_206` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 206 - Lord of Lagna should join the 4th in conjunction with or aspected by a benefic or occupy Parvata or Uttamamsa.
- **Effects/Benefits**: The person will be pure-hearted and hates secrecy and hypocrisy.

---

### Nishturabhashi Yoga

- **PyJHora Function/Key**: `nishturabhashi_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 296 - The Moon must be in conjunction with Saturn without Jupiter aspect.
- **Effects/Benefits**: The person will be harsh in speech.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        296 - The Moon must be in conjunction with Saturn without Jupiter aspect.
    """
    return _nishturabhashi_yoga_calculation(chart_1d=chart_1d)
```

---

### Parakrama Yoga

- **PyJHora Function/Key**: `parakrama_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The lord of the 3rd should join a benefic navamsa being aspected by (or conjoined with) benefic planets, and Mars should occupy benefic signs.
- **Effects/Benefits**: The individual will be highly courageous, valorous, and possesses great physical and mental strength to overcome obstacles.

**Python Logic Summary (PyJHora Implementation)**:
```python
return _parakrama_yoga_calculation(chart_rasi=chart_rasi, chart_navamsa=chart_navamsa)
```

---

### Parannabhojana Yoga

- **PyJHora Function/Key**: `parannabhojana_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The lord of the 2nd house is weak and situated in the 8th or 12th house.
- **Effects/Benefits**: You may frequently find yourself eating food provided by others or depending on others for your meals.

**Python Logic Summary (PyJHora Implementation)**:
```python
return _parannabhojana_yoga_calculation(chart_1d=chart_1d,navamsa_chart=navamsa_chart)
```

---

### Parihasaka Yoga

- **PyJHora Function/Key**: `parihasaka_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The lord of the Lagna and the 2nd lord are together and associated with or aspected by benefic planets.
- **Effects/Benefits**: You will be humorous and witty. You will be skilled at making others laugh with your words.

---

### Parijatha Yoga

- **PyJHora Function/Key**: `parijatha_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The lord of the sign in which the Lagna lord is placed, and the lord of that planet's sign, are in a Kendra or Thrikona from the Lagna.
- **Effects/Benefits**: You will be happy in the middle and last parts of life, receiving honors from kings or the government. You will be wealthy, famous, and generous.
- **Notes/Reference**: BVR-47 Paarijaatha/Kalpadruma Yoga: The lord of the sign in which the lord of the house occupied by the Ascendant
        lord, or the lord of Navamsa occupied by the lord of the Rasi in which the Ascendant lord is posited, shall
        join a quadrant, a trine or his own or exaltation places.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" 
        BVR-47 Paarijaatha/Kalpadruma Yoga: The lord of the sign in which the lord of the house occupied by the Ascendant
        lord, or the lord of Navamsa occupied by the lord of the Rasi in which the Ascendant lord is posited, shall
        join a quadrant, a trine or his own or exaltation places.
    """
    return _parijatha_yoga_calculation(chart_1d=chart_1d)
```

---

### Parvata Yoga

- **PyJHora Function/Key**: `parvata_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If (1) quadrants are occupied only by benefics and (2) the 7th and 8th houses are either vacant or occupied only by benefics
- **Effects/Benefits**: One born with this yoga is fortunate, eloquent, famous, charitable, easy-going and likes humour. Parvata means a mountain.
- **Notes/Reference**: BVR-14 Parvata Yoga: If (1) quadrants are occupied only by benefics and (2) the 7th and 8th houses 
        are either vacant or occupied only by benefics

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-14 Parvata Yoga: If (1) quadrants are occupied only by benefics and (2) the 7th and 8th houses 
        are either vacant or occupied only by benefics """
    return _parvata_yoga_calculation(chart_1d)
```

---

### Pisacha Grastha Yoga

- **PyJHora Function/Key**: `pisacha_grastha_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 287 - When Rahu is in Lagna in conjunction with the Moon and the malefics join trines, the above yoga is given rise to.
- **Effects/Benefits**: The person suffers from the attacks of 'spirits'.
- **Notes/Reference**: 287 - When Rahu is in Lagna in conjunction with the Moon and the malefics join trines,
        the above yoga is given rise to.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        287 - When Rahu is in Lagna in conjunction with the Moon and the malefics join trines,
        the above yoga is given rise to.    
    """
    return _pisacha_grastha_yoga_calculation(chart_1d=chart_1d, natural_malefics=natural_malefics)
```

---

### Pithru Saapa Sutakshaya Yoga

- **PyJHora Function/Key**: `pithru_saapa_sutakshaya_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 5th House must be occupied by Sun. A. Sun should be in sign of debilitation (Sun in Mithuna/Gemini), OR B. Sun's Navamsa should be in Makara/Capricorn or Kumbha/Aquarius. C. Sun is hemmed either side with malefics
- **Effects/Benefits**: There will be loss of children due to the curse of the father.
- **Notes/Reference**: BVR 216 - Pithru Saapa Sutakshaya Yoga
        5th House must be occupied by Sun
        A. Sun should be in sign of debilitation (Sun in Mithuna/Gemini)
           OR
        B. Sun's Navamsa should be in Makara/Capricorn or Kumbha/Aquarius
        C. Sun is hemmed either side with malefics

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        BVR 216 - Pithru Saapa Sutakshaya Yoga
        5th House must be occupied by Sun
        A. Sun should be in sign of debilitation (Sun in Mithuna/Gemini)
           OR
        B. Sun's Navamsa should be in Makara/Capricorn or Kumbha/Aquarius
        C. Sun is hemmed either side with malefics
    """
    return _pithru_saapa_sutakshaya_yoga_calculation(chart_rasi=chart_rasi, chart_navamsa=chart_navamsa,
                                                  natural_malefics=natural_malefics)
```

---

### Pittharoga Yoga

- **PyJHora Function/Key**: `pittharoga_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 279 - The 6th house must be occupied by the Sun in conjunction with a malefic and further aspected by another malefic.
- **Effects/Benefits**: The person suffers from bilious complaints.
- **Notes/Reference**: 279 - The 6th house must be occupied by the Sun in conjunction with a malefic and further
            aspected by another malefic.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" 
        279 - The 6th house must be occupied by the Sun in conjunction with a malefic and further
            aspected by another malefic.
    """
    return _pittharoga_yoga_calculation(chart_1d=chart_1d, natural_malefics=natural_malefics)
```

---

### Pretha Saapa Yoga

- **PyJHora Function/Key**: `pretha_saapa_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The Sun and Saturn in the 5th house, weak Moon in the 7th house, Rahu in Lagna and Jupiter in the 12th house
- **Effects/Benefits**: Children will die through the curses of Prethas or manes of the dead.
- **Notes/Reference**: BVR 219 - Pretha Saapa Yoga
        The Sun and Saturn in the 5th house, weak Moon in the 7th house, Rahu in Lagna and Jupiter in the 12th house

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        BVR 219 - Pretha Saapa Yoga
        The Sun and Saturn in the 5th house, weak Moon in the 7th house, Rahu in Lagna and Jupiter in the 12th house
    """
    return _pretha_saapa_yoga_calculation(chart_1d=chart_1d)
```

---

### Pushkala Yoga

- **PyJHora Function/Key**: `pushkala_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If (1) lagna lord is with Moon, (2) dispositor of Moon is in a quadrant or in the house of an adhimitra (good friend), (2) dispositor of Moon aspects lagna, and, (4) there is a planet in lagna, then this yoga is present.
- **Effects/Benefits**: One born with this yoga is eloquent, wealthy, famous and respected by kings. Pushkala means abundant.
- **Notes/Reference**: BVR-26 Pushkala Yoga: 
    (1) Lagna lord is with Moon.
    (2) Dispositor of Moon is in a quadrant (Kendra) or in the house of an Adhimitra.
    (3) Dispositor of Moon aspects Lagna (Sign/Rasi Drishti).
    (4) Lagna should be occupied by a powerful planet (Note: Per BVR Chart 26, this is optional if conditions 1-3 are strong).

**Python Logic Summary (PyJHora Implementation)**:
```python
""" 
    BVR-26 Pushkala Yoga: 
    (1) Lagna lord is with Moon.
    (2) Dispositor of Moon is in a quadrant (Kendra) or in the house of an Adhimitra.
    (3) Dispositor of Moon aspects Lagna (Sign/Rasi Drishti).
    (4) Lagna should be occupied by a powerful planet (Note: Per BVR Chart 26, this is optional if conditions 1-3 are strong).
    """
    return _pushkala_yoga_calculation(chart_1d=chart_1d)
```

---

### Raja Bhanga Yoga

- **PyJHora Function/Key**: `raja_bhanga_yoga_298` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 298 - The ascendant being Leo, Saturn must be in exaltation occupying a debilitated Navamsa or aspected by benefic.
- **Effects/Benefits**: The person though born in a royal family will be bereft of fortune and social position.
- **Notes/Reference**: 298 - The ascendant being Leo, Saturn must be in exaltation occupying a debilitated Navamsa 
            or aspected by benefic.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        298 - The ascendant being Leo, Saturn must be in exaltation occupying a debilitated Navamsa 
            or aspected by benefic.
    """
    return _raja_bhanga_yoga_298_calculation(chart_1d=chart_1d, chart_navamsa=chart_navamsa, natural_benefics=natural_benefics)
```

---

### Raja Bhanga Yoga

- **PyJHora Function/Key**: `raja_bhanga_yoga_299` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 299 - The Sun must occupy the 10th degree of Libra.
- **Effects/Benefits**: The person though born in a royal family will be bereft of fortune and social position.

---

### Rajabhrashta Yoga

- **PyJHora Function/Key**: `rajabhrashta_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 297 - The lords of Aroodha Lagna (A1/AL) and Aroodha Dwadasa (A12/UL) should be in conjunction.
- **Effects/Benefits**: The subject will suffer a fall from high position.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        297 - The lords of Aroodha Lagna (A1/AL) and Aroodha Dwadasa (A12/UL) should be in conjunction.
    """
    return _rajabhrashta_yoga_calculation(chart_1d=chart_1d)
```

---

### Rajalakshana Yoga

- **PyJHora Function/Key**: `rajalakshana_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Jupiter, Venus, Mercury, and the Moon are in Kendra houses.
- **Effects/Benefits**: You will possess an attractive personality, noble qualities, and attain high status or leadership.
- **Notes/Reference**: BVR-10 Rajalakshana Yoga: Jupiter, Venus, Mercury, and Moon are in Kendras from Lagna.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-10 Rajalakshana Yoga: Jupiter, Venus, Mercury, and Moon are in Kendras from Lagna. """
    return _rajalakshana_yoga_calculation(chart_1d=chart_1d)
```

---

### Randhra Malika Yoga

- **PyJHora Function/Key**: `randhra_malika_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All seven planets occupy seven continuous houses starting from the 8th house (Randhra Bhava).
- **Effects/Benefits**: You may have a long life but might face struggles, financial setbacks, or be misunderstood by others.
- **Notes/Reference**: BVR-39 Randhra Malika Yoga: Malika Yoga Starting from 8th House

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        BVR-39 Randhra Malika Yoga: Malika Yoga Starting from 8th House
    """
    return _randhra_malika_yoga_calc(chart_1d=chart_1d)
```

---

### Rogagrastha Yoga

- **PyJHora Function/Key**: `rogagrastha_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The Lagna lord is in the 6th, 8th, or 12th house and is associated with the lord of the 6th.
- **Effects/Benefits**: You may have a weak constitution and be prone to chronic health issues or frequent illnesses.
- **Notes/Reference**: BVR-11 Rogagrastha Yoga
        Condition (a): The Lagna Lord is in the 1st House (Lagna) joined by a Dusthana Lord (6th, 8th, or 12th).
        Condition (b): A weak Lagna Lord is situated in a Kendra (1, 4, 7, 10) or a Trikona (1, 5, 9)

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        BVR-11 Rogagrastha Yoga
        Condition (a): The Lagna Lord is in the 1st House (Lagna) joined by a Dusthana Lord (6th, 8th, or 12th).
        Condition (b): A weak Lagna Lord is situated in a Kendra (1, 4, 7, 10) or a Trikona (1, 5, 9)
    """
    return _rogagrastha_calculation(chart_1d=chart_1d, natural_benefics=natural_benefics)
```

---

### Saarada Yoga

- **PyJHora Function/Key**: `saarada_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If (1) the 10th lord is in the 5th house, (2) Mercury is in a quadrant, (3) Sun is strong in Leo, (4) Mercury or Jupiter is in a trine from Moon, and, (5) Mars is in 11th, then this yoga is present.
- **Effects/Benefits**: One born with this yoga is blessed with wealth, spouse and children. Person is happy, learned, principled and liked by kings. Person is a tapaswi (autere pursuer of knowledge). Saarada is another name of Saraswathi, the goddess of learning.
- **Notes/Reference**: Saarada Yoga: 
        (1) 10th lord in 5th house, 
        (2) Mercury in a quadrant, 
        (3) Sun strong in Leo, 
        (4) Mercury or Jupiter in a trine from Moon, 
        (5) Mars in 11th.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" Saarada Yoga: 
        (1) 10th lord in 5th house, 
        (2) Mercury in a quadrant, 
        (3) Sun strong in Leo, 
        (4) Mercury or Jupiter in a trine from Moon, 
        (5) Mars in 11th. """
    return _saarada_yoga_calculation(chart_1d=chart_1d)
```

---

### Sada Sanchara Yoga

- **PyJHora Function/Key**: `sada_sanchara_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The Lagna lord or the Moon is in a movable sign (Chara Rashi).
- **Effects/Benefits**: You will be constantly on the move, traveling frequently for work or personal reasons.
- **Notes/Reference**: BVR-117 Sada Sanchara Yoga
    Definition: The lord of either Lagna or the sign occupied by Lagna lord 
    must be in a movable sign (Aries, Cancer, Libra, Capricorn).

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    BVR-117 Sada Sanchara Yoga
    Definition: The lord of either Lagna or the sign occupied by Lagna lord 
    must be in a movable sign (Aries, Cancer, Libra, Capricorn).
    """
    return _sada_sanchara_yoga_calculation(chart_rasi=chart_rasi)
```

---

### Sankha Yoga

- **PyJHora Function/Key**: `sankha_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If (1) lagna lord is strong and (2) 5th and 6th lords are in mutual quadrants, then this yoga is present. Alternately, this yoga is present if (1) lagna lord and 10th lord are together in a movable sign and (2) the 9th lord is strong.
- **Effects/Benefits**: One born with this yoga is blessed with wealth, spouse and children. He is kind, pious, intelligent and long-lived. Sankha means a conch shell.
- **Notes/Reference**: BVR-12 Sankha Yoga: If (1) lagna lord is strong and (2) 5th and 6th lords are in mutual
        quadrants, then this yoga is present. Alternately, this yoga is present if (1) lagna lord
        and 10th lord are together in a movable sign and (2) the 9th lord is strong.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-12 Sankha Yoga: If (1) lagna lord is strong and (2) 5th and 6th lords are in mutual
        quadrants, then this yoga is present. Alternately, this yoga is present if (1) lagna lord
        and 10th lord are together in a movable sign and (2) the 9th lord is strong. """
    return _sankha_yoga_calculation(chart_1d=chart_1d)
```

---

### Sapthasankhya Sahodara Yoga

- **PyJHora Function/Key**: `sapthasankhya_sahodara_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Lord of the 12th should join Mars and the Moon should be in the 3rd with Jupiter, devoid of association with or aspect of Venus.
- **Effects/Benefits**: The person will have seven siblings or a family structure significantly influenced by the number seven in relation to brothers/sisters.
- **Notes/Reference**: Sapthasankhya Sahodara Yoga:
    Definition: Lord of the 12th should join Mars and the Moon should be in the 3rd 
    with Jupiter, devoid of association with or aspect of Venus.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Sapthasankhya Sahodara Yoga:
    Definition: Lord of the 12th should join Mars and the Moon should be in the 3rd 
    with Jupiter, devoid of association with or aspect of Venus.
    """
    return _sapthasankhya_sahodara_yoga_calculation(chart_1d)
```

---

### Sarala Yoga

- **PyJHora Function/Key**: `sarala_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If the 8th lord occupies the 8th house, then this yoga is present.
- **Effects/Benefits**: One born with this yoga is long-lived, fearless, learned, celebrated and prosperous. Person is a terror to his enemies. Sarala means straight-forward.
- **Notes/Reference**: BVR-106 Sarala Yoga: 8th lord occupies the 8th house

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-106 Sarala Yoga: 8th lord occupies the 8th house """
    return _vipareeta_yoga_calculation(8, chart_1d=chart_1d)
```

---

### Saraswathi Yoga

- **PyJHora Function/Key**: `saraswathi_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If (1) each of Mercury, Jupiter and Venus occupies a quadrant or a trine or the 2nd house (not necessarily together) and (2) Jupiter is in an own or friendly or exaltation sign, then this yoga is present.
- **Effects/Benefits**: One born with this yoga is very learned, skillful, intelligent, rich and famous. Person is praised by all. Saraswathi is the goddess of learning.
- **Notes/Reference**: BVR-161 Saraswathi Yoga: 
    (1) Mercury, Jupiter, and Venus each occupy a quadrant, trine, or the 2nd house.
    (2) Jupiter is in an own, friendly, or exaltation sign.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" 
    BVR-161 Saraswathi Yoga: 
    (1) Mercury, Jupiter, and Venus each occupy a quadrant, trine, or the 2nd house.
    (2) Jupiter is in an own, friendly, or exaltation sign.
    """
    return _saraswathi_yoga_calculation(chart_1d=chart_1d)
```

---

### Sareera Soukhya Yoga

- **PyJHora Function/Key**: `sareera_soukhya_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The Lagna lord, Jupiter, and Venus are placed in Kendra houses.
- **Effects/Benefits**: You will enjoy excellent physical health, a long life, and luxury.
- **Notes/Reference**: BVR-108 Sareera Soukhya Yoga
    The Lord of Lagna, Jupiter, or Venus should occupy a quadrant.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    BVR-108 Sareera Soukhya Yoga
    The Lord of Lagna, Jupiter, or Venus should occupy a quadrant.
    """
    return _sareera_soukhya_calculation(chart_1d=chart_1d)
```

---

### Sarpa Saapa Yogam

- **PyJHora Function/Key**: `sarpasaapa_yoga_212` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 212 - The 5th should be occupied by Rahu and aspected by Kuja or the 5th house being a sign of Mars, should be occupied by Rahu.
- **Effects/Benefits**: There will be death of children due to the curse of serpents.
- **Notes/Reference**: 212 - The 5th should be occupied by Rahu and aspected by Kuja or the 5th house being a sign 
            of Mars, should be occupied by Rahu

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        212 - The 5th should be occupied by Rahu and aspected by Kuja or the 5th house being a sign 
            of Mars, should be occupied by Rahu
    """
    if planet_positions is not None:
        chart_1d = utils.get_house_planet_list_from_planet_positions(planet_positions)
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    asc_house = p_to_h[const._ascendant_symbol]
    fifth_house = (asc_house+const.HOUSE_5)%12
    if planet_positions is not None:
        lord_of_5th = house.house_owner_from_planet_positions(planet_positions, fifth_house)
    else:
        lord_of_5th = house.house_owner(chart_1d, fifth_house)
    # Check for Yoga 212
    rahu_in_5th = p_to_h[const.RAHU_ID] == fifth_house
    aspected_by_mars = house.aspected_planets_of_the_planet(chart_1d, const.MARS_ID)
    mars_aspects_5th = const.RAHU_ID in aspected_by_mars
    if rahu_in_5th and mars_aspects_5th: return True
    # 5th house being a sign of Mars, should be occupied by Rahu
    mars_sign_5th_with_rahu = (lord_of_5th == const.MARS_ID) and (p_to_h[const.RAHU_ID]==fifth_house)
    yoga_212 = (rahu_in_5th and mars_aspects_5th) or mars_sign_5th_with_rahu
    return yoga_212
```

---

### Sarpa Saapa Yogam

- **PyJHora Function/Key**: `sarpasaapa_yoga_213` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 213 - The 5th lord is in conjunction with Rahu, and  Saturn is in the 5th house aspected by or asssociated with the Moon.
- **Effects/Benefits**: There will be death of children due to the curse of serpents.
- **Notes/Reference**: 213 - The 5th lord is in conjunction with Rahu, and  Saturn is in the 5th house aspected by 
            or asssociated with the Moon

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        213 - The 5th lord is in conjunction with Rahu, and  Saturn is in the 5th house aspected by 
            or asssociated with the Moon
    """
    if planet_positions is not None:
        chart_1d = utils.get_house_planet_list_from_planet_positions(planet_positions)
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    asc_house = p_to_h[const._ascendant_symbol]
    fifth_house = (asc_house+const.HOUSE_5)%12
    if planet_positions is not None:
        lord_of_5th = house.house_owner_from_planet_positions(planet_positions, fifth_house)
    else:
        lord_of_5th = house.house_owner(chart_1d, fifth_house)
    house_of_5th_lord = p_to_h[lord_of_5th]
    # The 5th lord is in conjunction with Rahu, and 
    # Saturn is in the 5th house aspected by or asssociated with the Moon
    rahu_with_5th_lord = (p_to_h[const.RAHU_ID]==house_of_5th_lord)
    saturn_in_5th = p_to_h[const.SATURN_ID]==fifth_house
    aspected_by_moon = house.aspected_houses_of_the_planet(chart_1d, const.MOON_ID)
    moon_aspects_5th = fifth_house in aspected_by_moon
    moon_in_5th = p_to_h[const.MOON_ID]==fifth_house
    yoga_213 = (rahu_with_5th_lord and saturn_in_5th and (moon_aspects_5th or moon_in_5th))
    return yoga_213
```

---

### Sarpa Saapa Yogam

- **PyJHora Function/Key**: `sarpasaapa_yoga_214` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 214 - The karaka of children (Jupiter) in association with Mars, Rahu in Lagna, and the 5th lord in a dusthana.
- **Effects/Benefits**: There will be death of children due to the curse of serpents.
- **Notes/Reference**: 214 - The karaka of children (Jupiter) in association with Mars, Rahu in Lagna, 
            and the 5th lord in a dusthana

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        214 - The karaka of children (Jupiter) in association with Mars, Rahu in Lagna, 
            and the 5th lord in a dusthana
    """
    if planet_positions is not None:
        chart_1d = utils.get_house_planet_list_from_planet_positions(planet_positions)
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    asc_house = p_to_h[const._ascendant_symbol]
    fifth_house = (asc_house+const.HOUSE_5)%12
    if planet_positions is not None:
        lord_of_5th = house.house_owner_from_planet_positions(planet_positions, fifth_house)
    else:
        lord_of_5th = house.house_owner(chart_1d, fifth_house)
    house_of_5th_lord = p_to_h[lord_of_5th]
    # The karaka of children (Jupiter) in association with Mars, Rahu in Lagna, and the 5th lord in a dusthana
    jupiter_joins_mars = (p_to_h[const.JUPITER_ID]==p_to_h[const.MARS_ID])
    rahu_in_lagna = (p_to_h[const.RAHU_ID]==asc_house)
    house_of_5th_lord_in_dusthana = house_of_5th_lord in house.dushthanas_of_the_raasi(asc_house)
    yoga_214 = jupiter_joins_mars and rahu_in_lagna and house_of_5th_lord_in_dusthana
    return yoga_214
```

---

### Sarpa Saapa Yogam

- **PyJHora Function/Key**: `sarpasaapa_yoga_215` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 215 - The 5th house, being a sign of Mars, must be conjoined by Rahu and aspected by or associated with Mercury
- **Effects/Benefits**: There will be death of children due to the curse of serpents.
- **Notes/Reference**: 215 - The 5th house, being a sign of Mars, must be conjoined by Rahu and aspected by or associated
            with Mercury

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        215 - The 5th house, being a sign of Mars, must be conjoined by Rahu and aspected by or associated
            with Mercury
    """
    if planet_positions is not None:
        chart_1d = utils.get_house_planet_list_from_planet_positions(planet_positions)
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    asc_house = p_to_h[const._ascendant_symbol]
    fifth_house = (asc_house+const.HOUSE_5)%12
    if planet_positions is not None:
        lord_of_5th = house.house_owner_from_planet_positions(planet_positions, fifth_house)
    else:
        lord_of_5th = house.house_owner(chart_1d, fifth_house)
    # The 5th house, being a sign of Mars, must be conjoined by Rahu and aspected by or associated with Mercury
    mars_is_lord_of_5th = (lord_of_5th == const.MARS_ID) # Mars rules fifth house
    rahu_in_5th = p_to_h[const.RAHU_ID] == fifth_house
    mercury_in_5th = (p_to_h[const.MERCURY_ID]==fifth_house) ## associated with
    mercury_aspects_5th = fifth_house in house.aspected_houses_of_the_planet(chart_1d, const.MERCURY_ID)
    return mars_is_lord_of_5th and rahu_in_5th and (mercury_in_5th or mercury_aspects_5th)
```

---

### Sarpaganda Yoga

- **PyJHora Function/Key**: `sarpaganda_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Rahu is in the 2nd house with the 2nd lord, or aspected by a malefic planet.
- **Effects/Benefits**: You may face danger from snake bites or suffer from poisonous substances and skin-related ailments.
- **Notes/Reference**: Rahu should join the 2nd house with Mandi.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" Rahu should join the 2nd house with Mandi. """
    return _sarpaganda_yoga_calculation(chart_1d=chart_1d, maandi_house=maandi_house)
```

---

### Sathkalatra Yoga

- **PyJHora Function/Key**: `satkalatra_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 239 - The lord of the 7th or Venus should join or be aspected by Jupiter or Mercury.
- **Effects/Benefits**: The native's wife will be noble and virtuous.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        239 - The lord of the 7th or Venus should join or be aspected by Jupiter or Mercury.
    """
    return _satkalatra_yoga_calculation(chart_1d=chart_1d)
```

---

### Satkathadisravana Yoga

- **PyJHora Function/Key**: `satkathadisravana_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The 3rd house is a benefic sign aspected by benefic planets, and the 3rd lord joins a benefic amsa (conjoins with or aspected by a benefic).
- **Effects/Benefits**: You have a natural inclination toward listening to righteous stories, spiritual discourses, and virtuous conversations.
- **Notes/Reference**: 186. Satkathadisravana yoga 
    Definition: The 3rd house should be a benefic sign aspected by benefic planets 
    and the 3rd lord should join a benefic amsa (cojoins with or aspected by a benefic).

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    186. Satkathadisravana yoga 
    Definition: The 3rd house should be a benefic sign aspected by benefic planets 
    and the 3rd lord should join a benefic amsa (cojoins with or aspected by a benefic).
    """
    return _satkathadisravana_yoga_calculation(chart_1d=chart_1d, natural_benefics=natural_benefics)
```

---

### Satru Malika Yoga

- **PyJHora Function/Key**: `satru_malika_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All seven planets occupy seven continuous houses starting from the 6th house (Satru Bhava).
- **Effects/Benefits**: You will be successful in overcoming enemies, though you may face health issues or litigation.
- **Notes/Reference**: BVR-37 Sathru Malika Yoga: Malika Yoga Starting from 6th House

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        BVR-37 Sathru Malika Yoga: Malika Yoga Starting from 6th House
    """
    return _satru_malika_yoga_calc(chart_1d=chart_1d)
```

---

### Sirachcheda Yoga

- **PyJHora Function/Key**: `sirachcheda_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 273 - The lord of the 6th must be in conjunction with Venus while the Sun or Saturn should join Rahu or Kethu in a cruel shashtiamsa.
- **Effects/Benefits**: The person's death will be due to his head being cut off.
- **Notes/Reference**: 273 - The lord of the 6th must be in conjunction with Venus while the Sun or Saturn should 
        join Rahu in a cruel shashtiamsa.
        Use planets_must_share_same_sashtiamsa=True - if you want planets have SAME cruel sashtiamsa

**Python Logic Summary (PyJHora Implementation)**:
```python
""" 
        273 - The lord of the 6th must be in conjunction with Venus while the Sun or Saturn should 
        join Rahu in a cruel shashtiamsa.
        Use planets_must_share_same_sashtiamsa=True - if you want planets have SAME cruel sashtiamsa
    """
    # Convert chart to planet_positions if your codebase provides such a helper.
    # Replace the call below with the appropriate utility in your project if needed.
    return _sirachcheda_yoga_calculations(
        chart_1d=chart_1d,
        planets_must_share_same_sashtiamsa=planets_must_share_same_sashtiamsa
    )
```

---

### Siva Yoga

- **PyJHora Function/Key**: `siva_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If (1) the 5th lord is in the 9th house, (2) the 9th lord is in the 10th house, and, (3) the 10th lord is in the 5th house, then this yoga is present.
- **Effects/Benefits**: One born with this yoga is wise and virtuous. Person is a conqueror. Person can be an army chief or a businessman. Lord Siva is one of the Trinity of Gods.
- **Notes/Reference**: BVR-61 Siva Yoga: If (1) the 5th lord is in the 9th house, (2) the 9th lord is in the 10th house,
        and, (3) the 10th lord is in the 5th house

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-61 Siva Yoga: If (1) the 5th lord is in the 9th house, (2) the 9th lord is in the 10th house,
        and, (3) the 10th lord is in the 5th house """
    return _siva_yoga_calculation(chart_1d=chart_1d)
```

---

### Sodaranasa Yoga

- **PyJHora Function/Key**: `sodaranasa_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Mars and the 3rd lord occupy the 8th, 3rd, 5th, or 7th house and are aspected by malefics.
- **Effects/Benefits**: The person will suffer the loss of brothers or siblings, or may not have any siblings at all.
- **Notes/Reference**: Sodaranasa Yoga: Mars and the 3rd lord should occupy the 8th (3rd, 5th or 7th) 
    house and be aspected by malefics.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Sodaranasa Yoga: Mars and the 3rd lord should occupy the 8th (3rd, 5th or 7th) 
    house and be aspected by malefics.
    """
    return sodaranasa_yoga_calculation(chart_1d)
```

---

### Sraddhannabhuktha Yoga

- **PyJHora Function/Key**: `sraddhannabhuktha_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The lord of the 2nd house is associated with Saturn and the lord of the 8th house.
- **Effects/Benefits**: You may have to eat food offered in funeral rites or ceremonies (Sraddha), or depend on others' charity for sustenance.

**Python Logic Summary (PyJHora Implementation)**:
```python
return _sraddhannabhuktha_yoga_calculation(chart_1d=chart_1d)
```

---

### Sreenaatha Yoga

- **PyJHora Function/Key**: `sreenaatha_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If (1) the 7th lord is exalted in 10th and (2) 10th lord is with 9th lord, then this yoga is present.
- **Effects/Benefits**: One born with this yoga becomes a great king equal to Indra – king of gods. Sreenaatha means the lord of great wealth and prosperity. It also means Vishnu.
- **Notes/Reference**: BVR-31 Sreenaatha Yoga: If (1) the 7th lord is exalted in 10th and (2) 10th lord is with 9th lord.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-31 Sreenaatha Yoga: If (1) the 7th lord is exalted in 10th and (2) 10th lord is with 9th lord. """
    return _sreenaatha_yoga_calculation(chart_1d=chart_1d)
```

---

### Sreenatha Yoga

- **PyJHora Function/Key**: `sreenatha_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The 7th lord is in the 10th and the 10th lord is joined with the 9th lord.
- **Effects/Benefits**: You will be a favorite of society, prosperous, and attain a very high position in life.
- **Notes/Reference**: BVR-31 Sreenatha Yoga: The lord of the 7th should be invariably exalted in the 10th, 
    the lord of which, in turn, must be with the 9th lord.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" 
    BVR-31 Sreenatha Yoga: The lord of the 7th should be invariably exalted in the 10th, 
    the lord of which, in turn, must be with the 9th lord. 
    """
    return _sreenatha_yoga_calculation(chart_1d=chart_1d)
```

---

### Subha Yoga

- **PyJHora Function/Key**: `subha_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Lagna has benefics or has “subha kartari – benefics in 12th and 2nd house from Lagna.
- **Effects/Benefits**:  One born with this yoga has eloquence, good looks and character
- **Notes/Reference**: Subha Yoga
      Present if either:
        (1) Lagna has benefics and is NOT affected by malefics, OR
        (2) Lagna is surrounded by benefics (benefics in BOTH 12th and 2nd) and lagna is NOT affected by malefics.
      Note: In your simplified version, "not affected" can be enforced via "only benefics" in the tested houses.
    Parameters:
      - use_affliction_check (bool): If True, compute "not affected by malefics" using occupancy, aspects, and hemming.
        If False, rely solely on "only benefics" conditions in the tested houses.
      - include_rahu_ketu_aspecting (bool): If True, consider Rahu/Ketu aspects (5th, 9th, and 7th).
    TODO: Need to check use_affliction_check algorithm=True
    Returns:
      - bool: True if Subha Yoga is present, False otherwise.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Subha Yoga
      Present if either:
        (1) Lagna has benefics and is NOT affected by malefics, OR
        (2) Lagna is surrounded by benefics (benefics in BOTH 12th and 2nd) and lagna is NOT affected by malefics.
      Note: In your simplified version, "not affected" can be enforced via "only benefics" in the tested houses.
    Parameters:
      - use_affliction_check (bool): If True, compute "not affected by malefics" using occupancy, aspects, and hemming.
        If False, rely solely on "only benefics" conditions in the tested houses.
      - include_rahu_ketu_aspecting (bool): If True, consider Rahu/Ketu aspects (5th, 9th, and 7th).
    TODO: Need to check use_affliction_check algorithm=True
    Returns:
      - bool: True if Subha Yoga is present, False otherwise.
    """
    _natural_benefics = {3, 4, 5}
    # Malefics: Sun(0), Mars(2), Saturn(6), Rahu(7), Ketu(8)
    _natural_malefics = {0, 2, 6, 7, 8}
    return __subha_yoga_calculation(chart_1d, _natural_benefics, _natural_malefics, use_affliction_check, include_rahu_ketu_aspecting)
```

---

### Sukha Malika Yoga

- **PyJHora Function/Key**: `sukha_malika_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All seven planets occupy seven continuous houses starting from the 4th house (Sukha Bhava).
- **Effects/Benefits**: You will be happy, possess lands and vehicles, and live a life of comfort and peace.
- **Notes/Reference**: BVR-35 Sukha Malika Yoga: Malika Yoga Starting from 4th House

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        BVR-35 Sukha Malika Yoga: Malika Yoga Starting from 4th House
    """
    return _sukha_malika_yoga_calc(chart_1d=chart_1d)
```

---

### Sula Yoga

- **PyJHora Function/Key**: `sula_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All seven planets are distributed among three different signs.
- **Effects/Benefits**: You may be sharp-tempered, brave, perhaps poor, or gain fame through military or courageous deeds.
- **Notes/Reference**: BVR-95 Sula Yoga: 7 planets in 3 signs (B.V. Raman #86)

**Python Logic Summary (PyJHora Implementation)**:
```python
"""BVR-95 Sula Yoga: 7 planets in 3 signs (B.V. Raman #86)"""
    return _sankhya_yoga_calculation(chart_1d=chart_1d, required_count=3)
```

---

### Sumukha Yoga

- **PyJHora Function/Key**: `sumukha_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Benefic planets (Jupiter, Venus) are placed in or aspecting the 2nd house.
- **Effects/Benefits**: You will have an attractive facial appearance and a peaceful temperament.
- **Notes/Reference**: Sumukha Yoga:
    Method 1 (166): Lord of 2nd in a kendra aspected by benefics, OR benefics join the 2nd house.
    Method 2 (167): Lord of 2nd in a kendra (Exalted/Own/Friend) AND the kendra lord is in Gopuramsa.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Sumukha Yoga:
    Method 1 (166): Lord of 2nd in a kendra aspected by benefics, OR benefics join the 2nd house.
    Method 2 (167): Lord of 2nd in a kendra (Exalted/Own/Friend) AND the kendra lord is in Gopuramsa.
    """
    return _sumukha_yoga_calculation(chart_1d=chart_1d,natural_benefics=natural_benefics, method=method,
                                     v_score=v_score)
```

---

### Swetakushta Yoga

- **PyJHora Function/Key**: `swetakushta_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 286 -  Mars and Saturn are in the 2nd and 12th, the Moon in Lagna and the Sun in the 7th, the above Yoga is given rise to.
- **Effects/Benefits**: The person suffers from white leprosy.
- **Notes/Reference**: 286 -  Mars and Saturn are in the 2nd and 12th, the Moon in Lagna and the Sun in the 7th,
        the above Yoga is given rise to.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        286 -  Mars and Saturn are in the 2nd and 12th, the Moon in Lagna and the Sun in the 7th,
        the above Yoga is given rise to.
    """
    return _swetakushta_yoga_calculation(chart_1d=chart_1d)
```

---

### Theevrabuddhi Yoga

- **PyJHora Function/Key**: `theevrabuddhi_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 232 - Lord of 5th in rasi should be a benefic and should in Navamsa Lagna. Lord of Navamsa Lagna should be a benefic or aspected by benefic.
- **Effects/Benefits**: The person will be precociously intelligent.

---

### Thrikaala Gnana Yoga

- **PyJHora Function/Key**: `thrikaala_gnana_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 234 - Jupiter in Mrudwamsa in his own navamsa. OR Jupiter in Gopuramsa (score >= 4) AND aspected by a benefic.
- **Effects/Benefits**: The native becomes capable of reading the past, present and future.

---

### Trilochana Yoga

- **PyJHora Function/Key**: `trilochana_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If Sun, Moon and Mars are in mutual trines, then this yoga is present.
- **Effects/Benefits**: One born with this yoga is wealthy, intelligent, long-lived and victorious over enemies. Person achieves everything without many obstacles. Trilochana means 'one with three eyes'. It is another name of Lord Siva, who has a hidden eye in His forehead.
- **Notes/Reference**: BVR-69 Trilochana Yoga: If Sun, Moon and Mars are in mutual trines.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-69 Trilochana Yoga: If Sun, Moon and Mars are in mutual trines. """
    return _trilochana_yoga_calculation(chart_1d=chart_1d)
```

---

### Uttama Griha Yoga

- **PyJHora Function/Key**: `utthama_graha_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The lord of the 4th house joins benefics and is aspected by benefics while placed in a Kendra (1, 4, 7, 10) or Trikona (1, 5, 9).
- **Effects/Benefits**: This indicates the acquisition of an excellent, beautiful, and comfortable house.
- **Notes/Reference**: 187. Uttama Griha Yoga Definition.--The lord of the 4th house should join benefics and 
        aspected by benefics in a kendra or thrikona.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        187. Uttama Griha Yoga Definition.--The lord of the 4th house should join benefics and 
        aspected by benefics in a kendra or thrikona.
    """
    return _utthama_graha_yoga_calculation(chart_1d=chart_1d, natural_benefics=natural_benefics)
```

---

### Vaahana Yoga

- **PyJHora Function/Key**: `vahana_yoga_209` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 209 - The lord of Lagna must join the 4th, 11th or the 9th.
- **Effects/Benefits**: The native will acquire material comforts and conveyances.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        209 - The lord of Lagna must join the 4th, 11th or the 9th.
    """
    if planet_positions is not None:
        chart_1d = utils.get_house_planet_list_from_planet_positions(planet_positions)
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    asc_house = p_to_h[const._ascendant_symbol]
    fourth_house = (asc_house+const.HOUSE_4)%12
    nineth_house = (asc_house+const.HOUSE_9)%12
    eleventh_house = (asc_house+const.HOUSE_11)%12
    if planet_positions is not None:
        lagna_lord = house.house_owner_from_planet_positions(planet_positions, asc_house)
    else:
        lagna_lord = house.house_owner(chart_1d, asc_house)
    # Variation 1 check - Ruler of the 1st house is in the 4th, 9th or 11th house
    yoga_209 = (
                    (p_to_h[lagna_lord] == fourth_house) or 
                    (p_to_h[lagna_lord] == nineth_house) or
                    (p_to_h[lagna_lord] == eleventh_house)
                  )
    return yoga_209
```

---

### Vaahana Yoga

- **PyJHora Function/Key**: `vahana_yoga_210` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 210 - The 4th lord must be exalted and the lord of the exaltation sign must occupy a kendra or trikona
- **Effects/Benefits**: The native will acquire material comforts and conveyances.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        210 - The 4th lord must be exalted and the lord of the exaltation sign must occupy a kendra or trikona
    """
    if planet_positions is not None:
        chart_1d = utils.get_house_planet_list_from_planet_positions(planet_positions)
    if chart_1d is None: return False
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    asc_house = p_to_h[const._ascendant_symbol]
    fourth_house = (asc_house+const.HOUSE_4)%12
    if planet_positions is not None:
        lord_of_4th = house.house_owner_from_planet_positions(planet_positions, fourth_house)
    else:
        lord_of_4th = house.house_owner(chart_1d, fourth_house)
    # Variation 2 - check - 
    house_of_4th_lord = p_to_h[lord_of_4th] 
    # 2.1 Ruler of the 4th house is in its exaltation sign 
    yoga_210_1 = utils.is_planet_in_exalation(lord_of_4th, house_of_4th_lord,enforce_deep_exaltation=False)
    if not yoga_210_1: return False
    # 2.2 ruler of the exaltation sign is in a kendra (0,3,6,9) house.
    if planet_positions is not None:
        lord_of_4th_exaltation_sign = house.house_owner_from_planet_positions(planet_positions, house_of_4th_lord)
    else:
        lord_of_4th_exaltation_sign = house.house_owner(chart_1d, house_of_4th_lord)
    house_of_lord_of_4th_exaltation_sign = p_to_h[lord_of_4th_exaltation_sign]
    yoga_210_2 = house_of_lord_of_4th_exaltation_sign in quadrants_of_the_house(asc_house)
    # 2.3 ruler of the exaltation sign is in a trikona (0,4,8) house.
    yoga_210_3 = house_of_lord_of_4th_exaltation_sign in trines_of_the_house(asc_house)
    return yoga_210_1 and (yoga_210_2 or yoga_210_3)
```

---

### Vaatharoga Yoga

- **PyJHora Function/Key**: `vaatharoga_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 290 - When Jupiter is in Lagna and Saturn in the 7th house,the above yoga is caused. Method=2: Mars in 5th/7th/9th OR Sun in Lagna, malefic moon and Saturn in 12th.
- **Effects/Benefits**: The person suffers from windy complaints.
- **Notes/Reference**: 290 - When Jupiter is in Lagna and Saturn in the 7th house,the above yoga is caused.
        Method=2: Mars in 5th/7th/9th OR Sun in Lagna, malefic moon and Saturn in 12th

**Python Logic Summary (PyJHora Implementation)**:
```python
""" 
        290 - When Jupiter is in Lagna and Saturn in the 7th house,the above yoga is caused.
        Method=2: Mars in 5th/7th/9th OR Sun in Lagna, malefic moon and Saturn in 12th
    """
    return _vaatharoga_yoga_calculation(chart_1d=chart_1d, is_moon_waning=is_moon_waning, method=method)
```

---

### Vakchalana Yoga

- **PyJHora Function/Key**: `vakchalana_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The lord of the 2nd house is in the 6th, 8th, or 12th house, and is associated with Rahu or Saturn.
- **Effects/Benefits**: You may suffer from a flickering tongue, stammering, or a lack of consistency and clarity in your speech.
- **Notes/Reference**: Vakchalana Yoga (175): 
    1. A natural malefic owns the 2nd house.
    2. The 2nd lord joins a cruel Navamsa (owned by a malefic).
    3. The 2nd house is devoid of benefic aspect or association.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Vakchalana Yoga (175): 
    1. A natural malefic owns the 2nd house.
    2. The 2nd lord joins a cruel Navamsa (owned by a malefic).
    3. The 2nd house is devoid of benefic aspect or association.
    """
    return _vakchalana_yoga_calculation(chart_1d=chart_1d,navamsa_chart=navamsa_chart,
                                        natural_benefics=natural_benefics, natural_malefics=natural_malefics)
```

---

### Vallaki Yoga

- **PyJHora Function/Key**: `vallaki_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All seven planets are distributed among seven different signs.
- **Effects/Benefits**: You will be fond of music, fine arts, and literature. You will be happy, famous, and possess many friends.
- **Notes/Reference**: BVR-91 Vallaki Yoga: 7 planets in 7 signs (B.V. Raman #82)

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-91 Vallaki Yoga: 7 planets in 7 signs (B.V. Raman #82)"""
    return _sankhya_yoga_calculation(chart_1d=chart_1d, required_count=7)
```

---

### Vamsacheda Yoga

- **PyJHora Function/Key**: `vamsacheda_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 283 - The 10th, 7th and 4th must be occupied by the Moon, Venus and malefics respectively. Variation: Moon and Venus in the 7th and malefics in the 4th and 10th.
- **Effects/Benefits**: The person will be the extinguisher of his family.
- **Notes/Reference**: 283 - The 10th, 7th and 4th must be occupied by the Moon, Venus and malefics respectively.
              Variation: Moon and Venus in the 7th and malefics in the 4th and 10th.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        283 - The 10th, 7th and 4th must be occupied by the Moon, Venus and malefics respectively.
              Variation: Moon and Venus in the 7th and malefics in the 4th and 10th.
    """
    return _vamsacheda_yoga_calculation(chart_1d=chart_1d,natural_malefics=natural_malefics)
```

---

### Vanchana Chora Bheethi Yoga

- **PyJHora Function/Key**: `vanchana_chora_bheethi_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The Lord of Lagna is in the 6th, 8th, or 12th house joined with or aspected by malefics.
- **Effects/Benefits**: You will face constant fear of being cheated, defrauded, or robbed by others.
- **Notes/Reference**: BVR-11 Vanchana Chora Bheethi: Lagna malefic/Gulika trine OR Gulika with Kendra/Trine lords OR L1 with Rahu/Sat/Ket.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-11 Vanchana Chora Bheethi: Lagna malefic/Gulika trine OR Gulika with Kendra/Trine lords OR L1 with Rahu/Sat/Ket. """
    return _vanchana_chora_bheethi_yoga_calculation(chart_1d=chart_1d, gulika_h_idx=gulika_h_idx, 
                                                    natural_malefics=natural_malefics)
```

---

### Vasumathi Yoga

- **PyJHora Function/Key**: `vasumathi_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If benefics occupy upachayas, then this yoga is present.
- **Effects/Benefits**: For it to give full results, malefics should not occupy upachayas and the benefics occupying upachayas should be strong. One born with this yoga has abundant wealth. Vasumati means earth.
- **Notes/Reference**: BVR-9 Vasumathi Yoga: 
    Benefics occupy Upachaya houses (3, 6, 10, 11) from Lagna or Moon.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" 
    BVR-9 Vasumathi Yoga: 
    Benefics occupy Upachaya houses (3, 6, 10, 11) from Lagna or Moon.
    """
    return _vasumathi_yoga_calculation(chart_1d=chart_1d)
```

---

### Vichitra Saudha Prakara Yoga

- **PyJHora Function/Key**: `vichitra_saudha_prakara_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The lords of the 4th and 10th houses are conjoined together with Saturn and Mars.
- **Effects/Benefits**: You may possess unique, grand, or many-walled palatial buildings and extensive landed properties.
- **Notes/Reference**: 188. Vichitra Saudha Prakara Yoga 
        Definition.-If the lords of the 4th and l0th are conjoined together with Saturn and Mars
        the above yoga is given rise to.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        188. Vichitra Saudha Prakara Yoga 
        Definition.-If the lords of the 4th and l0th are conjoined together with Saturn and Mars
        the above yoga is given rise to.
    """
    return _vichitra_saudha_prakara_yoga_calculation(chart_1d=chart_1d, natural_benefics=natural_benefics)
```

---

### Vidyut Yoga

- **PyJHora Function/Key**: `vidyut_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If (1) the 11th lord is in deep exaltation, (2) he joins Venus, and, (3) the two of them are in a quadrant from lagna lord, then this yoga is present.
- **Effects/Benefits**: One born with this yoga becomes a king or an equal. Person is wealthy, pleasure-loving and charitable. Vidyut means a lightning bolt or electricity.
- **Notes/Reference**: BVR-59 Vidyut Yoga: 
    (1) 11th lord is in deep exaltation.
    (2) 11th lord conjoins Venus.
    (3) Both are in a quadrant from the lagna lord.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" 
    BVR-59 Vidyut Yoga: 
    (1) 11th lord is in deep exaltation.
    (2) 11th lord conjoins Venus.
    (3) Both are in a quadrant from the lagna lord.
    """
    return _vidyut_yoga_calculation(chart_1d=chart_1d, enforce_deep_exaltation=enforce_deep_exaltation)
```

---

### Vikrama Malika Yoga

- **PyJHora Function/Key**: `vikrama_malika_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All seven planets occupy seven continuous houses starting from the 3rd house (Vikrama Bhava).
- **Effects/Benefits**: You will be courageous, possess many siblings, and attain success through your own prowess.
- **Notes/Reference**: BVR-34 Vikram  Malika Yoga: Malika Yoga Starting from 3rd House

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        BVR-34 Vikram  Malika Yoga: Malika Yoga Starting from 3rd House
    """
    return _vikrama_malika_yoga_calc(chart_1d=chart_1d)
```

---

### Vimala Yoga

- **PyJHora Function/Key**: `vimala_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If the 12th lord occupies the 12th house, then this yoga is present.
- **Effects/Benefits**: One born with this yoga is noble, frugal, happy and independent. Vimala means pure.
- **Notes/Reference**: BVR-107 Vimala Yoga: 12th lord occupies the 12th house

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-107 Vimala Yoga: 12th lord occupies the 12th house """
    return _vipareeta_yoga_calculation(12, chart_1d=chart_1d)
```

---

### Vishaprayoga Yoga

- **PyJHora Function/Key**: `vishaprayoga_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The 2nd lord is associated with the 6th, 8th, or 12th lords and is aspected by malefics.
- **Effects/Benefits**: You may be subject to poisoning by others or face health complications due to toxic substances.
- **Notes/Reference**: Vishaprayoga Yoga (176): 
    1. 2nd house joined AND aspected by malefics.
    2. 2nd lord in a cruel Navamsa (owned by malefic).
    3. 2nd lord (in Rasi) aspected by a malefic.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Vishaprayoga Yoga (176): 
    1. 2nd house joined AND aspected by malefics.
    2. 2nd lord in a cruel Navamsa (owned by malefic).
    3. 2nd lord (in Rasi) aspected by a malefic.
    """
    return _vishaprayoga_yoga_calculation(chart_rasi=chart_rasi,navamsa_chart=navamsa_chart, natural_malefics=natural_malefics )
```

---

### Vishnu Yoga

- **PyJHora Function/Key**: `vishnu_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If (1) the 9th and 10th lords are in the 2nd house and (2) the lord of the sign occupied in navamsa by the 9th lord in rasi chart is also in the 2nd house, then this yoga is present.
- **Effects/Benefits**: One born with this yoga is fortunate, learned, long-lived and liked by kings. Person is a worshipper of Vishnu.
- **Notes/Reference**: BVR-62 Vishnu Yoga (PVR & BVR):
        BV Raman Definition:  the lord of Navamsa in which the 9th iord is placed, and the l0th lord joins the 2nd
            house in conjunction u ith the 9tk lord, Vishnu Yoga is caused.
        PVR Definition:
            1. 9th and 10th lords (from Rasi) are in the 2nd house of Rasi.
            2. The lord of the sign occupied by the 9th lord in Navamsa is also in the 2nd house of Rasi.
        both Methods appear the same

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-62 Vishnu Yoga (PVR & BVR):
        BV Raman Definition:  the lord of Navamsa in which the 9th iord is placed, and the l0th lord joins the 2nd
            house in conjunction u ith the 9tk lord, Vishnu Yoga is caused.
        PVR Definition:
            1. 9th and 10th lords (from Rasi) are in the 2nd house of Rasi.
            2. The lord of the sign occupied by the 9th lord in Navamsa is also in the 2nd house of Rasi.
        both Methods appear the same
    """
    return _vishnu_yoga_calculation(chart_1d_rasi=chart_1d_rasi, chart_1d_navamsa=chart_1d_navamsa)
```

---

### Vrana Yoga

- **PyJHora Function/Key**: `vrana_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 265 - The 6th lord, being a malefic, should occupy the Lagna, 8th or 1Oth. Impacted organs depending on 6th lord: Sun- Spleen,heart. Moon-Oesophagus, alimentary canal. Mars-Genitals, left cerebral hemisphere, red colouring matter in blood,rectum. Mercury- Nerves, right cerebral hemisphere, cerebro-spinal-system, bronchial tubes, ears, tongue. Jupiter- Liver, supra-renals. Venus- Throat, kidneys, uterus, ovaries. Saturn- Teeth, skin, vagus nerve. Rahu- Pituitary body. Kethu- Pineal glands.
- **Effects/Benefits**: The person suffers from dreadful disease of cancer
- **Notes/Reference**: 265 - The 6th lord, being a malefic, should occupy the Lagna, 8th or 1Oth. 
            Impacted organs depending on 6th lord: 
                Sun- Spleen,heart. 
                Moon-Oesophagus, alimentary canal. 
                Mars-Genitals, left cerebral hemisphere, red colouring matter in blood,rectum. 
                Mercury- Nerves, right cerebral hemisphere, cerebro-spinal-system, bronchial tubes, ears, tongue. 
                Jupiter- Liver, supra-renals. 
                Venus- Throat, kidneys, uterus, ovaries. 
                Saturn- Teeth, skin, vagus nerve. 
                Rahu- Pituitary body. 
                Kethu- Pineal glands.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        265 - The 6th lord, being a malefic, should occupy the Lagna, 8th or 1Oth. 
            Impacted organs depending on 6th lord: 
                Sun- Spleen,heart. 
                Moon-Oesophagus, alimentary canal. 
                Mars-Genitals, left cerebral hemisphere, red colouring matter in blood,rectum. 
                Mercury- Nerves, right cerebral hemisphere, cerebro-spinal-system, bronchial tubes, ears, tongue. 
                Jupiter- Liver, supra-renals. 
                Venus- Throat, kidneys, uterus, ovaries. 
                Saturn- Teeth, skin, vagus nerve. 
                Rahu- Pituitary body. 
                Kethu- Pineal glands.
    """
    return _vrana_yoga_calculation(chart_1d=chart_1d, natural_malefics=natural_malefics)
```

---

### Vyaya Malika Yoga

- **PyJHora Function/Key**: `vyaya_malika_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All seven planets occupy seven continuous houses starting from the 12th house (Vyaya Bhava).
- **Effects/Benefits**: You will be a spendthrift, potentially live abroad, and may be inclined toward spiritual or charitable spending.
- **Notes/Reference**: BVR-43 Vyaya Malika Yoga: Malika Yoga Starting from 12th House

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        BVR-43 Vyaya Malika Yoga: Malika Yoga Starting from 12th House
    """
    return _vyaya_malika_yoga_calc(chart_1d=chart_1d)
```

---

### Yuddha Praveena Yoga

- **PyJHora Function/Key**: `yuddha_praveena_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The lord of the Navamsa occupied by the 3rd lord's Navamsa lord is placed in its own Varga.
- **Effects/Benefits**: The person becomes a capable strategist and an expert in warfare and tactical combat.
- **Notes/Reference**: Yuddha praveenayoga - Definition.-If the lord of the navamsajoined by the planet who owns the navamsa 
        in which the 3rd lord is placed, joins his own vargas,

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        Yuddha praveenayoga - Definition.-If the lord of the navamsajoined by the planet who owns the navamsa 
        in which the 3rd lord is placed, joins his own vargas,
    """
    _yuddha_praveena_yoga_calculation(chart_rasi=chart_rasi, chart_navamsa=chart_navamsa,
                                      shadvarga_data=shadvarga_data)
```

---

### Yuddhatpaschaddrudha Yoga

- **PyJHora Function/Key**: `yuddhatpaschaddrudha_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The 3rd lord is in a fixed Rasi, a fixed Navamsa, and a cruel Shashtiamsa, while its dispositor is debilitated.
- **Effects/Benefits**: You may feel hesitant or fearful at the start of a conflict, but once the struggle begins, you develop unshakable resolve and fight with extreme firmness.
- **Notes/Reference**: 185. Yuddhatpaschaddrudha Yoga
    Definition.- The lord of the 3rd should occupy a fixed Rasi, a fixed Navamsa 
    and a cruel Shashtiamsa and the lord of the Rasi so occupied should be in debility.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    185. Yuddhatpaschaddrudha Yoga
    Definition.- The lord of the 3rd should occupy a fixed Rasi, a fixed Navamsa 
    and a cruel Shashtiamsa and the lord of the Rasi so occupied should be in debility.
    """
    return _yuddhatpaschaddrudha_yoga_calculation(chart_rasi=chart_rasi, chart_navamsa=chart_navamsa, deity_index=deity_index)
```

---

### Yuddhatpoorvadridhachitta Yoga

- **PyJHora Function/Key**: `yuddhatpoorvadridhachitta_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 184 - The exalted lord of the 3rd should join malefics in movable Rasis or Navamsas
- **Effects/Benefits**: The person will be courageous before the commencement of the war.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        184 - The exalted lord of the 3rd should join malefics in movable Rasis or Navamsas
    """
    return _yuddhatpoorvadridhachitta_yoga_calculation(chart_rasi=chart_rasi, chart_navamsa=chart_navamsa,
                                                       natural_malefics=natural_malefics)
```

---

### Yukthi Samanwithavagmi Yoga

- **PyJHora Function/Key**: `yukthi_samanwithavagmi_yoga_154` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The 2nd lord should join a benefic in a kendra or thrikona, or be exalted and combined with Jupiter.
- **Effects/Benefits**: You will speak with great logic and tact. Your speech will be highly influential and meaningful.
- **Notes/Reference**: Yukthi Samanwithavagmi Yoga (BV Raman 154)
    Definition: The 2nd lord should join a benefic in a kendra or thrikona, 
    or be exalted and combined with Jupiter.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
    Yukthi Samanwithavagmi Yoga (BV Raman 154)
    Definition: The 2nd lord should join a benefic in a kendra or thrikona, 
    or be exalted and combined with Jupiter.
    """
    if planet_positions is not None:
        chart_1d = utils.get_house_planet_list_from_planet_positions(planet_positions)
    if chart_1d is None: return False
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    _asc = const._ascendant_symbol
    asc_h = p_to_h[_asc]
    h2 = (asc_h + const.HOUSE_2) % 12

    if planet_positions is not None:
        l2 = int(house.house_owner_from_planet_positions(planet_positions, h2))
    else:
        l2 = int(house.house_owner(chart_1d, h2))

    _natural_benefics = _get_natural_benefics(chart_1d, natural_benefics)

    l2_h = p_to_h[l2]
    
    # Kendra/Thrikona logic using your saved lambda info
    # Assuming yoga.quadrants_of_the_house and yoga.trines_of_the_house are available
    kendras = quadrants_of_the_house(asc_h)
    thrikonas = trines_of_the_house(asc_h)
    auspicious_houses = set(kendras + thrikonas)

    # Condition A: L2 joins a benefic in Kendra or Thrikona
    cond_a = False
    if l2_h in auspicious_houses:
        for b in _natural_benefics:
            if b != l2 and p_to_h[b] == l2_h:
                cond_a = True
                break

    # Condition B: L2 is exalted and combined with Jupiter
    is_exalted = utils.is_planet_in_exalation(l2, l2_h, planet_positions,enforce_deep_exaltation=False)
    combined_with_jupiter = (p_to_h[const.JUPITER_ID] == l2_h)
    cond_b = is_exalted and combined_with_jupiter

    return cond_a or cond_b
```

---

### Yukthi Samanwithavagmi Yoga

- **PyJHora Function/Key**: `yukthi_samanwithavagmi_yoga_155` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: The lord of speech should occupy a kendra, attain paramochha and gain Parvatamsa, while Jupiter or Venus should be in Simhasanamsa.
- **Effects/Benefits**: You will speak with great logic and tact. Your speech will be highly influential and meaningful.

---

## Pancha Mahapurusha Yogas

Total yogas in this category: **5**

### Bhadra Yoga

- **PyJHora Function/Key**: `bhadra_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Mercury is in a quadrant in own sign or exaltation sign.
- **Effects/Benefits**: You are a person of earthy nature and are lion-like. You are learned in all respects. You have a good build of body and a deep voice. You have sattwa guna. You know yoga well. You are always surrounded by relatives, friends and family and enjoys your wealth with them. You maintain cleanliness in everything and are very systematic. You are a spirit of independence and religious.
- **Notes/Reference**: BVR-23 Bhadra Yoga - Mercury should be in Ge or Vi and he should be in 1st, 4th, 7th or 10th from lagna.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-23 Bhadra Yoga - Mercury should be in Ge or Vi and he should be in 1st, 4th, 7th or 10th from lagna. """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    yoga_planet = const.MERCURY_ID
    yoga_planet_zodiac = p_to_h[yoga_planet]
    yoga_zodiacs = [const.GEMINI, const.VIRGO]
    _yoga_houses = [const.HOUSE_1,const.HOUSE_4,const.HOUSE_7,const.HOUSE_10]
    yoga_houses =[(p_to_h[const._ascendant_symbol]+mh)%12 for mh in _yoga_houses]
    return yoga_planet_zodiac in yoga_zodiacs and yoga_planet_zodiac in yoga_houses
```

---

### Hamsa Yoga

- **PyJHora Function/Key**: `hamsa_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Jupiter should be in Sagitarius, Pisces or Capricornn and he should be in 1st, 4th, 7th or 10th from lagna.
- **Effects/Benefits**: You are a great man of ethery nature. You are swan-like. You have spiritual strength and purity. You are respected by everyone. You are very passionate. You may become a king. You may have all comforts. You enjoy life fully. You are a clever conversationalist and endowed with good speech.
- **Notes/Reference**: BVR-19 Hamsa Yoga - Jupiter should be in Sg, Pi or Cn and he should be in 1st, 4th, 7th or 10th from lagna.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-19 Hamsa Yoga - Jupiter should be in Sg, Pi or Cn and he should be in 1st, 4th, 7th or 10th from lagna. """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    yoga_planet = const.JUPITER_ID
    yoga_planet_zodiac = p_to_h[yoga_planet]
    yoga_zodiacs = [const.SAGITTARIUS, const.PISCES, const.CANCER]
    _yoga_houses = [const.HOUSE_1,const.HOUSE_4,const.HOUSE_7,const.HOUSE_10]
    yoga_houses =[(p_to_h[const._ascendant_symbol]+mh)%12 for mh in _yoga_houses]
    return yoga_planet_zodiac in yoga_zodiacs and yoga_planet_zodiac in yoga_houses
```

---

### Maalavya Yoga

- **PyJHora Function/Key**: `maalavya_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Venus is in a quadrant in own sign or exaltation sign.
- **Effects/Benefits**: You are a great person of watery nature. You emit a lustre akin to moonlight. You enjoy tasty food. You have luxuries. You have excellent health. You are well-versed in arts.
- **Notes/Reference**: BVR-20 Maalavya Yoga - Venus should be in Ta, Li or Pi and he should be in 1st, 4th, 7th or 10th from lagna.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-20 Maalavya Yoga - Venus should be in Ta, Li or Pi and he should be in 1st, 4th, 7th or 10th from lagna. """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    yoga_planet = const.VENUS_ID
    yoga_planet_zodiac = p_to_h[yoga_planet]
    yoga_zodiacs = [const.TAURUS, const.PISCES, const.LIBRA]
    _yoga_houses = [const.HOUSE_1,const.HOUSE_4,const.HOUSE_7,const.HOUSE_10]
    yoga_houses =[(p_to_h[const._ascendant_symbol]+mh)%12 for mh in _yoga_houses]
    return yoga_planet_zodiac in yoga_zodiacs and yoga_planet_zodiac in yoga_houses
```

---

### Ruchaka Yoga

- **PyJHora Function/Key**: `ruchaka_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Mars is in a quadrant in own sign or exaltation sign.
- **Effects/Benefits**: You are a person of fiery nature. You have a lot of enthusiasm. You are a natural leader. You love to fight wars and you will be victorious over enemies. You are discriminative and a devotee of learned people. You are well-versed in occult sciences. You have good taste. You will be always successful.
- **Notes/Reference**: BVR-22 Ruchaka Yoga - Mars should be in 0 or 7 or 9th rasi and he should be in 1, 4, 7 or 10th from lagna

**Python Logic Summary (PyJHora Implementation)**:
```python
"""  BVR-22 Ruchaka Yoga - Mars should be in 0 or 7 or 9th rasi and he should be in 1, 4, 7 or 10th from lagna """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    yoga_planet = const.MARS_ID
    yoga_planet_zodiac = p_to_h[yoga_planet]
    yoga_zodiacs = [const.ARIES, const.SCORPIO, const.CAPRICORN]
    _yoga_houses = [const.HOUSE_1,const.HOUSE_4,const.HOUSE_7,const.HOUSE_10]
    yoga_houses =[(p_to_h[const._ascendant_symbol]+mh)%12 for mh in _yoga_houses]
    return yoga_planet_zodiac in yoga_zodiacs and yoga_planet_zodiac in yoga_houses
```

---

### Sasa Yoga

- **PyJHora Function/Key**: `sasa_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Saturn should be in Capricorn, Aquariius or Libra and he should be in 1st, 4th, 7th or 10th from lagna
- **Effects/Benefits**: You are a great person of airy nature. You are rabbit-like. You are wise and enjoy wandering. You are comfortable in forests, mountains and forts. You are valorous and have a slender build. You know the weaknesses of others. You are lively, but have some vacillation. You are charitable.
- **Notes/Reference**: BVR-21 Saturn should be in Cp, Aq or Li and he should be in 1st, 4th, 7th or 10th from lagna.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-21 Saturn should be in Cp, Aq or Li and he should be in 1st, 4th, 7th or 10th from lagna. """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    yoga_planet = const.SATURN_ID
    yoga_planet_zodiac = p_to_h[yoga_planet]
    yoga_zodiacs = [const.CAPRICORN, const.AQUARIUS, const.LIBRA]
    _yoga_houses = [const.HOUSE_1,const.HOUSE_4,const.HOUSE_7,const.HOUSE_10]
    yoga_houses =[(p_to_h[const._ascendant_symbol]+mh)%12 for mh in _yoga_houses]
    return yoga_planet_zodiac in yoga_zodiacs and yoga_planet_zodiac in yoga_houses
```

---

## Progeny Yogas (Children)

Total yogas in this category: **14**

### Aputhra Yoga

- **PyJHora Function/Key**: `aputhra_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 224 - The lord of the 5th house should occupy a dusthana.
- **Effects/Benefits**: The person will have no children.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        224 - The lord of the 5th house should occupy a dusthana.
    """
    return _aputhra_yoga_calculation(chart_1d=chart_1d)
```

---

### Bahu Puthra Yoga

- **PyJHora Function/Key**: `bahu_puthra_yoga_220` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 220 - Rahu is in 5th house. And Rahu is not in Saturn's Navamsa (i.e Rahu in D9 not in Aq/Cp).
- **Effects/Benefits**: The person will have a large number of children

---

### Bahu Puthra Yoga

- **PyJHora Function/Key**: `bahu_puthra_yoga_221` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 221 - The same yoga arises if the lord of the Navamsa occupied by a planet who is in association with the 7th lord is in the 1st, 2nd or 5th house. Steps: (1) Get 7th Lord in Rasi. (2) Find which rasi this 7th lord is in Navamsa chart. (3) Find the lord of that sign of step-2. (4) Find the sign of the Lord found from step-3 in rasi chart. (5) That sign should be either 1st, or 2nd or 5th from Lagna in rasi
- **Effects/Benefits**: The person will have a large number of children

---

### Dattha Puthra Yoga

- **PyJHora Function/Key**: `dattha_puthra_yoga_222` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 222 - Mars and Saturn should occupy the 5th house and the lord of Lagna should be in a sign of Mercury, aspected by or in association with the same planet (Mercury).
- **Effects/Benefits**: The person will have adopted children.
- **Notes/Reference**: 222 - Mars and Saturn should occupy the 5th house and the lord of Lagna should be in a sign 
            of Mercury, aspected by or in association with the same planet (Mercury).

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        222 - Mars and Saturn should occupy the 5th house and the lord of Lagna should be in a sign 
            of Mercury, aspected by or in association with the same planet (Mercury).
    """
    if planet_positions is not None:
        chart_1d = utils.get_house_planet_list_from_planet_positions(planet_positions)
    if chart_1d is None: return False
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    lagna_house = p_to_h[const._ascendant_symbol]
    house_5th = (lagna_house+const.HOUSE_5)%12; house_7th = (lagna_house+const.HOUSE_7)%12
    if planet_positions is not None:
        lord_of_lagna = house.house_owner_from_planet_positions(planet_positions, lagna_house)
    else:
        lord_of_lagna = house.house_owner(chart_1d, lagna_house)
    # Mars and Saturn should occupy the 5th house
    mars_saturn_in_5th_house = (p_to_h[const.MARS_ID]==house_5th) and (p_to_h[const.SATURN_ID]==house_5th)
    # the lord of lagna cojoins mercury.
    lord_of_lagna_cojoins_mercury = (p_to_h[lord_of_lagna]==p_to_h[const.MERCURY_ID])
    # the lord of lagna aspected by mercury
    planets_aspected_by_mercury = house.aspected_planets_of_the_planet(chart_1d, const.MERCURY_ID)
    lord_of_lagna_aspected_by_mercury = lord_of_lagna in planets_aspected_by_mercury
    # the lord of Lagna in a sign of Mercury (Ge/Vi)
    lord_of_lagna_in_mercury_signs = lord_of_lagna in [const.GEMINI, const.VIRGO]
    yoga_222 = (mars_saturn_in_5th_house and 
                (lord_of_lagna_cojoins_mercury or lord_of_lagna_aspected_by_mercury or lord_of_lagna_in_mercury_signs)
               )
    if yoga_222: return True
```

---

### Dattha Puthra Yoga

- **PyJHora Function/Key**: `dattha_puthra_yoga_223` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 223 - The lord of the 7th must be posited in the 11th, the 5th lord must join a benefic and the 5th house must be occupied by Mars or Saturn.
- **Effects/Benefits**: The person will have adopted children.
- **Notes/Reference**: 223 - The lord of the 7th must be posited in the 11th, the 5th lord must join a benefic 
            and the 5th house must be occupied by Mars or Saturn.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        223 - The lord of the 7th must be posited in the 11th, the 5th lord must join a benefic 
            and the 5th house must be occupied by Mars or Saturn.
    
    """
    if planet_positions is not None:
        chart_1d = utils.get_house_planet_list_from_planet_positions(planet_positions)
    if chart_1d is None: return False
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    lagna_house = p_to_h[const._ascendant_symbol]
    house_5th = (lagna_house+const.HOUSE_5)%12; house_7th = (lagna_house+const.HOUSE_7)%12
    house_11th = (lagna_house+const.HOUSE_11)%12
    if planet_positions is not None:
        lord_of_5th = house.house_owner_from_planet_positions(planet_positions, house_5th)
        lord_of_7th = house.house_owner_from_planet_positions(planet_positions, house_7th)
    else:
        lord_of_5th = house.house_owner(chart_1d, house_5th)
        lord_of_7th = house.house_owner(chart_1d, house_7th)
    # The lord of the 7th must be posited in the 11th house
    house_of_lord_of_7th = p_to_h[lord_of_7th]
    lord_of_7th_in_11_house = (house_of_lord_of_7th == house_11th)
    if not lord_of_7th_in_11_house: return False
    # the 5th lord must join a benefic 
    _natural_benefics = _get_natural_benefics(chart_1d, natural_benefics)
    house_of_lord_of_5th = p_to_h[lord_of_5th]
    lord_of_5th_joins_a_benefic = any(p_to_h[nb]==house_of_lord_of_5th for nb in _natural_benefics)
    if not lord_of_5th_joins_a_benefic: return False
    # the 5th house must be occupied by Mars or Saturn.
    mars_or_saturn_in_5th_house = (p_to_h[const.MARS_ID]==house_5th) or (p_to_h[const.SATURN_ID]==house_5th)
    return mars_or_saturn_in_5th_house
```

---

### Eka Puthra Yoga

- **PyJHora Function/Key**: `eka_puthra_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 225 - Lord of 5th house should join a kendra or trikona.
- **Effects/Benefits**: The person will have only one child.
- **Notes/Reference**: 225 - Lord of 5th house should join a kendra or trikona

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        225 - Lord of 5th house should join a kendra or trikona
    """
    return _eka_puthra_yoga_calculation(chart_1d=chart_1d)
```

---

### Jarajaputra Yoga

- **PyJHora Function/Key**: `jarajaputra_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 237. Powerful lords of the 5th and the 7th must join with the lord of the 6th and be aspected by benefics.
- **Effects/Benefits**: The person lacks the power of procreation but his wife will have a son from another man.
- **Notes/Reference**: 237. Powerful lords of the 5th and the 7th must join with the lord of the 6th and 
        be aspected by benefics.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" 
        237. Powerful lords of the 5th and the 7th must join with the lord of the 6th and 
        be aspected by benefics.
    """
    return _jarajaputra_yoga_calculation(chart_1d=chart_1d, natural_benefics=natural_benefics)
```

---

### Kaalanirdesat Puthra Yoga

- **PyJHora Function/Key**: `kaalanirdesat_puthra_yoga_227` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 227 - Jupiter should be in the 5th house and the lord of the 5th should join Venus.
- **Effects/Benefits**: The native begets a child either in his 32nd, 33rd or 40th year.
- **Notes/Reference**: 227 - Jupiter should be in the 5th house and the lord of the 5th should join Venus

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        227 - Jupiter should be in the 5th house and the lord of the 5th should join Venus
    """
    if planet_positions is not None:
        chart_1d = utils.get_house_planet_list_from_planet_positions(planet_positions)
    if chart_1d is None: return False
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    lagna_house = p_to_h[const._ascendant_symbol]
    jupiter_house = p_to_h[const.JUPITER_ID]
    venus_house = p_to_h[const.VENUS_ID]
    house_5th = (lagna_house+const.HOUSE_5)%12
    if planet_positions is not None:
        lord_of_5th = house.house_owner_from_planet_positions(planet_positions, house_5th)
    else:
        lord_of_5th = house.house_owner(chart_1d, house_5th)
    jupiter_in_5th = (jupiter_house==house_5th)
    lord_of_5th_joins_venus = (p_to_h[lord_of_5th]==venus_house)
    return jupiter_in_5th and lord_of_5th_joins_venus
```

---

### Kaalanirdesat Puthra Yoga

- **PyJHora Function/Key**: `kaalanirdesat_puthra_yoga_228` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 228 - Jupiter must also occupy the 9th from Lagna and Venus should be in the 9th from Jupiter, in conjunction with the lord of Lagna
- **Effects/Benefits**: The native begets a child either in his 32nd, 33rd or 40th year.
- **Notes/Reference**: 228 - Jupiter must also occupy the 9th from Lagna and Venus should be in the 9th from Jupiter,
            in conjunction with the lord of Lagna

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        228 - Jupiter must also occupy the 9th from Lagna and Venus should be in the 9th from Jupiter,
            in conjunction with the lord of Lagna
    """
    if planet_positions is not None:
        chart_1d = utils.get_house_planet_list_from_planet_positions(planet_positions)
    if chart_1d is None: return False
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    lagna_house = p_to_h[const._ascendant_symbol]
    jupiter_house = p_to_h[const.JUPITER_ID]
    venus_house = p_to_h[const.VENUS_ID]
    house_5th = (lagna_house+const.HOUSE_5)%12
    house_9th = (lagna_house+const.HOUSE_9)%12
    jupiter_9th = (jupiter_house+const.HOUSE_9)%12
    if planet_positions is not None:
        lord_of_lagna = house.house_owner_from_planet_positions(planet_positions, lagna_house)
    else:
        lord_of_lagna = house.house_owner(chart_1d, lagna_house)
    jupiter_in_9th_from_lagna = (jupiter_house == house_9th)
    if not jupiter_in_9th_from_lagna: return False
    venus_in_9th_from_jupiter = (venus_house == jupiter_9th)
    if not venus_in_9th_from_jupiter: return False
    venus_with_lord_of_lagna = (venus_house == p_to_h[lord_of_lagna])
    return venus_with_lord_of_lagna
```

---

### Kaalanirdesat Puthranaasa Yoga

- **PyJHora Function/Key**: `kaalanirdesat_puthranaasa_yoga_229` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 229 - Rahu must occupy the 5th house, the lord of the 5th must be in conjunction with a malefic and Jupiter should be debilitated.
- **Effects/Benefits**: The person will suffer loss of children in his 32nd and 40th years respectively.
- **Notes/Reference**: 229 - Rahu must occupy the 5th house, the lord of the 5th must be in conjunction with a 
            malefic and Jupiter should be debilitated.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        229 - Rahu must occupy the 5th house, the lord of the 5th must be in conjunction with a 
            malefic and Jupiter should be debilitated.
    """
    if planet_positions is not None:
        chart_1d = utils.get_house_planet_list_from_planet_positions(planet_positions)
    if chart_1d is None: return False
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    lagna_house = p_to_h[const._ascendant_symbol]
    jupiter_house = p_to_h[const.JUPITER_ID]
    house_5th = (lagna_house+const.HOUSE_5)%12
    if planet_positions is not None:
        lord_of_5th = house.house_owner_from_planet_positions(planet_positions, house_5th)
    else:
        lord_of_5th = house.house_owner(chart_1d, house_5th)
    _natural_malefics = natural_malefics if natural_malefics else const.natural_malefics
    rahu_in_5th = (p_to_h[const.RAHU_ID] == house_5th)
    jupiter_debilititated = utils.is_planet_in_debilitation(const.JUPITER_ID, jupiter_house, planet_positions=planet_positions, enforce_deep_debilitation=False)
    lord_of_5th_with_malefic = any(p_to_h[lord_of_5th]==p_to_h[mp] for mp in _natural_malefics)
    return rahu_in_5th and jupiter_debilititated and lord_of_5th_with_malefic
```

---

### Kaalanirdesat Puthranaasa Yoga

- **PyJHora Function/Key**: `kaalanirdesat_puthranaasa_yoga_230` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 230 - Malefics should be disposed (cojoins or aspect) in 5th from Jupiter and 5th from Lagna
- **Effects/Benefits**: The person will suffer loss of children in his 32nd and 40th years respectively.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        230 - Malefics should be disposed (cojoins or aspect) in 5th from Jupiter and 5th from Lagna
    """
    if planet_positions is not None:
        chart_1d = utils.get_house_planet_list_from_planet_positions(planet_positions)
    if chart_1d is None: return False
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    lagna_house = p_to_h[const._ascendant_symbol]
    jupiter_house = p_to_h[const.JUPITER_ID]
    house_5th = (lagna_house+const.HOUSE_5)%12
    jupiter_5th = (jupiter_house+const.HOUSE_5)%12
    _natural_malefics = natural_malefics if natural_malefics else const.natural_malefics
    malefic_5th_from_lagna = any(p_to_h[mp]==house_5th for mp in _natural_malefics)
    malefics_aspecting_5th_from_lagna = any(mp in house.planets_aspecting_the_raasi(chart_1d, house_5th) for mp in _natural_malefics)
    malefic_5th_from_jupiter = any(p_to_h[mp]==jupiter_5th for mp in _natural_malefics)
    malefics_aspecting_5th_from_jupiter = any(mp in house.planets_aspecting_the_raasi(chart_1d, jupiter_5th) for mp in _natural_malefics)
    yoga_230 = ((malefic_5th_from_lagna or malefics_aspecting_5th_from_lagna) and 
                (malefic_5th_from_jupiter or malefics_aspecting_5th_from_jupiter))
    return yoga_230
```

---

### Puthra Kalatraheena Yoga

- **PyJHora Function/Key**: `putrakalatraheena_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 281 - When the waning Moon is in the 5th and malefics occupy the 12th, 7th and Lagna, the yoga is formed.
- **Effects/Benefits**: The person will be'deprived of his family and children.
- **Notes/Reference**: 281 - When the waning Moon is in the 5th and malefics occupy the 12th, 7th and Lagna, the yoga is formed.
        The person will be 'deprived of his family and children.'

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        281 - When the waning Moon is in the 5th and malefics occupy the 12th, 7th and Lagna, the yoga is formed.
        The person will be 'deprived of his family and children.'
    """
    return _putrakalatraheena_yoga_calculation(
        chart_1d=chart_1d,
        natural_malefics=natural_malefics,
    )
```

---

### Putra Malika Yoga

- **PyJHora Function/Key**: `putra_malika_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: All seven planets occupy seven continuous houses starting from the 5th house (Putra Bhava).
- **Effects/Benefits**: You will be intelligent, well-versed in scriptures, and blessed with children who bring you pride.
- **Notes/Reference**: BVR-36 Puthra Malika Yoga: Malika Yoga Starting from 5th House

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        BVR-36 Puthra Malika Yoga: Malika Yoga Starting from 5th House
    """
    return _putra_malika_yoga_calc(chart_1d=chart_1d)
```

---

### Suputhra Yoga

- **PyJHora Function/Key**: `suputhra_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: 226 - Jupiter is lord of 5th house (=Lagna in Le/Sc) and Sun in favorable position (own, exalted,friendly sign)
- **Effects/Benefits**: The native will have a worthy child.
- **Notes/Reference**: 226 - Jupiter is lord of 5th house (=Lagna in Le/Sc) and 
            Sun in favorable position (own, exalted,friendly sign)

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        226 - Jupiter is lord of 5th house (=Lagna in Le/Sc) and 
            Sun in favorable position (own, exalted,friendly sign)
    """
    return _suputhra_yoga_calculation(chart_1d=chart_1d)
```

---

## Raja Yogas

Total yogas in this category: **4**

### Dharma Karmadhipati Raja yoga

- **PyJHora Function/Key**: `dharma_karmadhipati_raja_yoga` (Source: `raja_yoga.py`)
- **Astro Criteria (Rule)**: If the lords of dharma sthana (9th) and karma sthana (10th) form a raja yoga, it is known by this special name. The 9th house is the most important trine and the 10th house is the most important quadrant.
- **Effects/Benefits**: One born with this yoga is sincere, devoted and righteous. He is fortunate.
- **Notes/Reference**: Dharma-Karmadhipati Yoga: This is a special case of the above yoga. If the lords
        of dharma sthana (9th) and karma sthana (10th) form a raja yoga 
        @param p_to_h: planet_to_house dictionary Example: {0:1,1:2,...'L':11,..} Sun in Ar, Moon in Ta, Lagnam in Pi
        @param raja_yoga_planet1: Planet index for first raja yoga planet  [0 to 6] Rahu/Kethu/Lagnam not supported
        @param raja_yoga_planet2: Planet index for second raja yoga planet [0 to 6] Rahu/Kethu/Lagnam not supported
        @return: True/False = True = dharma karmadhipati yoga is present

**Python Logic Summary (PyJHora Implementation)**:
```python
""" 
        Dharma-Karmadhipati Yoga: This is a special case of the above yoga. If the lords
        of dharma sthana (9th) and karma sthana (10th) form a raja yoga 
        @param p_to_h: planet_to_house dictionary Example: {0:1,1:2,...'L':11,..} Sun in Ar, Moon in Ta, Lagnam in Pi
        @param raja_yoga_planet1: Planet index for first raja yoga planet  [0 to 6] Rahu/Kethu/Lagnam not supported
        @param raja_yoga_planet2: Planet index for second raja yoga planet [0 to 6] Rahu/Kethu/Lagnam not supported
        @return: True/False = True = dharma karmadhipati yoga is present
    """
    asc_house = p_to_h[const._ascendant_symbol]
    h_to_p = utils.get_house_to_planet_dict_from_planet_to_house_dict(p_to_h)
    house_lords = [house.house_owner(h_to_p,h) for h in [(asc_house+const.HOUSE_9)%12,(asc_house+const.HOUSE_10)%12]]
    dkchk = all([any([hl == rp for hl in house_lords ]) for rp in [raja_yoga_planet1, raja_yoga_planet2] ])
    #print('dharma_karmadhipati_raja_yoga check',dkchk)
    return dkchk
```

---

### Neecha Bhanga Raja yoga

- **PyJHora Function/Key**: `neecha_bhanga_raja_yoga` (Source: `raja_yoga.py`)
- **Astro Criteria (Rule)**: 1. If the lord of the sign occupied by a weak or debilitated planet is exalted or is in Kendra from Moon. Ex, If Jupiter is debilitated in Capricorn and if Saturn is exalted and placed in Kendra from moon. 2. If the debilitated planet is conjunct with the Exalted Planet. 3. If the debilitated planet is aspected by the master of that sign. Ex, If Sun is debilitated in Libra and it is aspect by Venus with 7th aspect. 4. If the debilitated planet is Exalted in Navamsa Chart. 5. The planet which gets exalted in the sign where a debilitated planet is placed is in a Kendra from the Lagna or the Moon. Ex, If Sun is debilitated in the birth chart in Libra and Saturn which gets exalted in Libra is placed in Kendra from Lagna or Moon. NOTE: Checks only the first 3 conditions below. 4 and 5 to be done in future version
- **Effects/Benefits**: Neecha Bhanga Raja Yoga provides one with Fame, Property, and Control usually. But all the said prosperities will be used by the native only in the next half of life particularly after the age 36 corresponding to the age at the yoga developing dasha, sub-period and transits take place in one’s chart. This typical nature is attributed to this Yoga because the planet who create Neecha Bhanga Rajayoga is subjected to debilitation first and then attains the cancellation. Likewise, the native's life too would suffer adversities in the initial part of life and then will start excelling. Earning from multiple sources and earning a good reputation from a vast number of peoples and various communities along with holding a good image is the result of this Yoga. One will be admired within his/her personal, professional and social circles. Whatever they do brings a good reputation for them and people usually like them for what they are. They will gather huge property and start producing many sources of income once the Rajayoga is in operation. They will also hold power in life. The native will be holding power over many people once this Yoga is operational.
- **Notes/Reference**: Checks if given raja yoga pairs form neecha bhanga raja yoga
        NOTE: Checks only the first 3 conditions below. 4 and 5 to be done in future version
        1. If the lord of the sign occupied by a weak or debilitated planet is exalted or is in Kendra from Moon. 
            Ex, If Jupiter is debilitated in Capricorn and if Saturn is exalted and placed in Kendra from moon 
        2. If the debilitated planet is conjunct with the Exalted Planet
        3. If the debilitated planet is aspected by the master of that sign. 
            Ex, If Sun is debilitated in Libra and it is aspect by Venus with 7th aspect.
        4. If the debilitated planet is Exalted in Navamsa Chart.
        5. The planet which gets exalted in the sign where a debilitated planet is placed is in a Kendra from the Lagna or the Moon. 
            Ex, If Sun is debilitated in the birth chart in Libra and Saturn which gets exalted in Libra is placed in Kendra from Lagna or Moon.
        @param house_to_planet_dict: list of raasi with planet ids in them
          Example: ['','','','','2','7','1/5','0','3/4','L','','6/8'] 1st element is Aries and last is Pisces
        @param planet1: Planet index for first raja yoga planet  [0 to 6] Rahu/Kethu/Lagnam not supported
        @param planet2: Planet index for second raja yoga planet [0 to 6] Rahu/Kethu/Lagnam not supported
        @return: True/False = True = neecha bhanga raja yoga is present

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        Checks if given raja yoga pairs form neecha bhanga raja yoga
        NOTE: Checks only the first 3 conditions below. 4 and 5 to be done in future version
        1. If the lord of the sign occupied by a weak or debilitated planet is exalted or is in Kendra from Moon. 
            Ex, If Jupiter is debilitated in Capricorn and if Saturn is exalted and placed in Kendra from moon 
        2. If the debilitated planet is conjunct with the Exalted Planet
        3. If the debilitated planet is aspected by the master of that sign. 
            Ex, If Sun is debilitated in Libra and it is aspect by Venus with 7th aspect.
        4. If the debilitated planet is Exalted in Navamsa Chart.
        5. The planet which gets exalted in the sign where a debilitated planet is placed is in a Kendra from the Lagna or the Moon. 
            Ex, If Sun is debilitated in the birth chart in Libra and Saturn which gets exalted in Libra is placed in Kendra from Lagna or Moon.
        @param house_to_planet_dict: list of raasi with planet ids in them
          Example: ['','','','','2','7','1/5','0','3/4','L','','6/8'] 1st element is Aries and last is Pisces
        @param planet1: Planet index for first raja yoga planet  [0 to 6] Rahu/Kethu/Lagnam not supported
        @param planet2: Planet index for second raja yoga planet [0 to 6] Rahu/Kethu/Lagnam not supported
        @return: True/False = True = neecha bhanga raja yoga is present
    """
    "TODO: Rule 4 and 5. Get jd,place as inputs "
    house_to_planet_list = utils.get_house_to_planet_dict_from_planet_to_house_dict(p_to_h)
    #p_to_h = utils.get_planet_to_house_dict_from_chart(house_to_planet_list)
    rp1_rasi = p_to_h[planet1]
    rp2_rasi = p_to_h[planet2]
    rp1_lord = house.house_owner(house_to_planet_list,rp1_rasi)
    rp2_lord = house.house_owner(house_to_planet_list,rp2_rasi)
    kendra_from_moon = house.quadrants_of_the_raasi(p_to_h[1])
    #print(rp1_rasi,rp1_lord,rp2_rasi,rp2_lord)
    " Rule-1"
    chk1_1 = const.house_strengths_of_planets[planet1][rp1_rasi] <= const._DEBILITATED_NEECHAM and \
        (const.house_strengths_of_planets[rp1_lord][rp1_rasi] >= const._EXALTED_UCCHAM or \
        rp1_rasi in kendra_from_moon)
    chk1_2 = const.house_strengths_of_planets[planet2][rp2_rasi] <= const._DEBILITATED_NEECHAM and \
        (const.house_strengths_of_planets[rp2_lord][rp2_rasi] >= const._EXALTED_UCCHAM or \
        rp2_rasi in kendra_from_moon)
    chk1 = chk1_1 or chk1_2
    if chk1:
        return True
    "Rule 2"
    chk2_1 = (rp1_rasi == rp2_rasi)
    chk2_2 = (const.house_strengths_of_planets[planet1][rp1_rasi] >= const._EXALTED_UCCHAM) and \
             (const.house_strengths_of_planets[planet2][rp2_rasi] <= const._DEBILITATED_NEECHAM)
    chk2_3 = (const.house_strengths_of_planets[planet2][rp2_rasi] >= const._EXALTED_UCCHAM) and \
             (const.house_strengths_of_planets[planet1][rp1_rasi] <= const._DEBILITATED_NEECHAM)
    chk2 = chk2_1 and (chk2_2 or chk2_3)
    if chk2:
        return True
    " Rule 3"
    chk3_1 = (const.house_strengths_of_planets[planet1][rp2_rasi] <= const._DEBILITATED_NEECHAM) and \
             (str(planet1) in house.graha_drishti_of_the_planet(house_to_planet_list, rp1_lord))
    chk3_2 = (const.house_strengths_of_planets[planet2][rp2_rasi] <= const._DEBILITATED_NEECHAM) and \
             (str(planet1) in house.graha_drishti_of_the_planet(house_to_planet_list, rp2_lord))
    chk3 = chk3_1 or chk3_2
    return chk3
```

---

### Raja Yoga (B.V. Raman 245)

- **PyJHora Function/Key**: `raja_yoga_245` (Source: `raja_yoga_bv_raman.py`)
- **Astro Criteria (Rule)**: Three or more planets should be in exaltation or own house occupying kendras.
- **Effects/Benefits**: Brings power, wealth, status and administrative leadership.
- **Notes/Reference**: 245 - Three or more planets should be in exaltation or own house occupying kendras.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" 245 - Three or more planets should be in exaltation or own house occupying kendras."""
    _minimum_required_planets = 3
    # Check if jd, place is supplied
    if jd is not None and place is not None:
        planet_positions = charts.divisional_chart(jd, place, divisional_chart_factor)
    # Check else planet positions supplied and can compute with pp alone
    if planet_positions is not None:
        chart_1d = utils.get_house_planet_list_from_planet_positions(planet_positions)
    # Check last if chart is supplied and can compute raja yoga with chart alone
    if chart_1d is None: return False
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    raja_yoga_planets = []
    for p,h in p_to_h.items():
        if p != const._ascendant_symbol and const.house_strengths_of_planets[p][h] == const._EXALTED_UCCHAM:
            raja_yoga_planets.append(p)
    condition_1 = len(raja_yoga_planets) >= _minimum_required_planets
    if condition_1: return condition_1, raja_yoga_planets
    # Condition 2 - own house occupying kendras
    _kendras = house.quadrants_of_the_raasi(p_to_h[const._ascendant_symbol])
    raja_yoga_planets = []
    for p,h in p_to_h.items():
        if p != const._ascendant_symbol and const.house_strengths_of_planets[p][h] == const._OWNER_RULER:
            if p_to_h[p] in _kendras:
                raja_yoga_planets.append(p)
    condition_2 = len(raja_yoga_planets) >= _minimum_required_planets
    return condition_2, raja_yoga_planets
```

---

### Vipareetha Raja yoga

- **PyJHora Function/Key**: `vipareetha_raja_yoga` (Source: `raja_yoga.py`)
- **Astro Criteria (Rule)**: The 6th, 8th and 12th houses are known as trik sthanas or dusthanas (bad houses). If their lords occupies dusthanas or conjoin dusthanas, it results in this yoga.
- **Effects/Benefits**: One having this yoga experiences tremedous success, typically after an initial struggle. Vipareeta means extreme.
- **Notes/Reference**: Checks if given two raja yoga planets also for vipareetha raja yoga/
        Also returns the sub type of vipareetha raja yoga
            Harsh Raja Yoga, Saral Raja Yoga and Vimal Raja Yoga
        Vipareeta Raaja Yoga: The 6th, 8th and 12th houses are known as trik sthanas or
        dusthanas (bad houses). If their lords occupies dusthanas or conjoin dusthanas
        @param p_to_h: planet_to_house dictionary Example: {0:1,1:2,...'L':11,..} Sun in Ar, Moon in Ta, Lagnam in Pi
        @param raja_yoga_planet1: Planet index for first raja yoga planet  [0 to 6] Rahu/Kethu/Lagnam not supported
        @param raja_yoga_planet2: Planet index for second raja yoga planet [0 to 6] Rahu/Kethu/Lagnam not supported
        return [Boolean, Sub_type]
         Example: [True,'Harsh Raja Yoga']

**Python Logic Summary (PyJHora Implementation)**:
```python
"""
        Checks if given two raja yoga planets also for vipareetha raja yoga/
        Also returns the sub type of vipareetha raja yoga
            Harsh Raja Yoga, Saral Raja Yoga and Vimal Raja Yoga
        Vipareeta Raaja Yoga: The 6th, 8th and 12th houses are known as trik sthanas or
        dusthanas (bad houses). If their lords occupies dusthanas or conjoin dusthanas
        @param p_to_h: planet_to_house dictionary Example: {0:1,1:2,...'L':11,..} Sun in Ar, Moon in Ta, Lagnam in Pi
        @param raja_yoga_planet1: Planet index for first raja yoga planet  [0 to 6] Rahu/Kethu/Lagnam not supported
        @param raja_yoga_planet2: Planet index for second raja yoga planet [0 to 6] Rahu/Kethu/Lagnam not supported
        return [Boolean, Sub_type]
         Example: [True,'Harsh Raja Yoga']
    """
    asc_house = p_to_h[const._ascendant_symbol]
    vrchk1 = ([([p_to_h[rp]==dh for dh in house.dushthanas_of_the_raasi(asc_house)]) \
              for rp in [raja_yoga_planet1, raja_yoga_planet2]])
    vrchk = (all([any(vrchk1[0]),any(vrchk1[1])]))
    vr_sub_type = 'Harsh Raja Yoga'
    if vrchk1[0][1]:
        vr_sub_type = 'Saral Raja Yoga'
    elif vrchk1[0][2]:
        vr_sub_type = 'Vimal Raja Yoga'
    if vrchk:
        return vrchk, vr_sub_type
    else:
        return vrchk
```

---

## Ravi Yogas (Sun-based)

Total yogas in this category: **5**

### Nipuna Yoga

- **PyJHora Function/Key**: `nipuna_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: Sun and Mercury are together (in one sign).
- **Effects/Benefits**: You will be intelligent and skillful in all works. You will be well known, respected and happy.\n This yoga is the most powerful in divisional charts like D-10. In rasi chart also, it can give results if Mercury is not combust.
- **Notes/Reference**: BVR-26 Budha-Aaditya Yoga (Nipuna Yoga)- If Sun and Mercury are together (in one sign), this yoga is present.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-26 Budha-Aaditya Yoga (Nipuna Yoga)- If Sun and Mercury are together (in one sign), this yoga is present."""
    """
        TODO: Note: If Mercury is too close to Sun, he is combust (asta or astangata). Yogas 
                    formed by combust planets lose some of their power to do good. 
    """
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    return p_to_h[const.SUN_ID]==p_to_h[const.MERCURY_ID]
```

---

### Ravi Yoga

- **PyJHora Function/Key**: `ravi_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: If (1) Sun is in the 10th house and (2) the 10th lord is in the 3rd house with Saturn, then this yoga is present.
- **Effects/Benefits**: One born with this yoga is learned, passionate and respected by kings. Ravi means Sun.
- **Notes/Reference**: BVR-65 Ravi Yoga: 
    (1) Sun is in the 10th house.
    (2) The 10th lord is in the 3rd house with Saturn.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" 
    BVR-65 Ravi Yoga: 
    (1) Sun is in the 10th house.
    (2) The 10th lord is in the 3rd house with Saturn.
    """
    return _ravi_yoga_calculation(chart_1d=chart_1d)
```

---

### Ubhayachara Yoga

- **PyJHora Function/Key**: `ubhayachara_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: There are planets other than Moon in the 2nd and 12th houses from Sun
- **Effects/Benefits**: You will have all comforts. You will be like a king or an equal
- **Notes/Reference**: BVR-18 Obhayachari / Ubhayachara  Yoga - There is a planet other than Moon in the 2nd and 12th house from Sun.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-18 Obhayachari / Ubhayachara  Yoga - There is a planet other than Moon in the 2nd and 12th house from Sun. """
    yp = vesi_yoga(chart_1d) and vosi_yoga(chart_1d)
    return yp
```

---

### Vesai Yoga

- **PyJHora Function/Key**: `vesi_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: There is a planet other than Moon in the 2nd house from Sun
- **Effects/Benefits**: You will have a balanced outlook. You are truthful, tall and sluggish. You will be happy and comfortable even with little wealth.
- **Notes/Reference**: BVR-16 If there is a planet other than Moon in the 2nd house from Sun, then this yoga is present.

**Python Logic Summary (PyJHora Implementation)**:
```python
"""  BVR-16 If there is a planet other than Moon in the 2nd house from Sun, then this yoga is present. """
    yoga_planet = const.SUN_ID; excluded_planet = const.MOON_ID
    house_from_yoga_planet = const.HOUSE_2
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    yoga_house = (p_to_h[yoga_planet] + house_from_yoga_planet) % 12
    planet_ids = planets_in_raasi(yoga_house,p_to_h)# V4.8.0
    return (len(planet_ids) >= 1) and (excluded_planet not in planet_ids)
```

---

### Vosi Yoga

- **PyJHora Function/Key**: `vosi_yoga` (Source: `yoga.py`)
- **Astro Criteria (Rule)**: There is a planet other than Moon in the 12th house from Sun
- **Effects/Benefits**: You will be skillful, charitable, famous, learned and strong.
- **Notes/Reference**: BVR-17 (Vasi Yoga) If there is a planet other than Moon in the 12th house from Sun, then this yoga is present.

**Python Logic Summary (PyJHora Implementation)**:
```python
""" BVR-17 (Vasi Yoga) If there is a planet other than Moon in the 12th house from Sun, then this yoga is present. """ 
    yoga_planet = const.SUN_ID; excluded_planet = const.MOON_ID
    house_from_yoga_planet = const.HOUSE_12
    p_to_h = utils.get_planet_to_house_dict_from_chart(chart_1d)
    yoga_house = (p_to_h[yoga_planet] + house_from_yoga_planet) % 12
    planet_ids = planets_in_raasi(yoga_house,p_to_h)# V4.8.0
    return (len(planet_ids) >= 1) and (excluded_planet not in planet_ids)
```

---

