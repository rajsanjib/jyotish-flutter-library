import '../constants/planet_constants.dart';
import 'planet.dart';

/// The high-level astrological paradigm (system) being used.
///
/// Every service and factory in this library operates under one of two
/// mutually-exclusive paradigms.  Mixing paradigms (e.g. using Lahiri
/// ayanamsa with KP Sub-Lord tables, or using Placidus houses in traditional
/// Parashari analysis) produces numerically inconsistent results.
///
/// Use [AstrologicalSystem.traditional] for:
///   - Parashari / KN Rao / BPHS-style calculations
///   - Shadbala, Ashtakavarga, Jaimini, Dasha systems beyond Vimshottari
///   - Graha Drishti (sign-based aspects)
///   - Whole-Sign or Equal house systems
///
/// Use [AstrologicalSystem.kp] for:
///   - Krishnamurti Paddhati (KP)
///   - Sub-Lord, Sub-Sub-Lord, Significator (ABCD) calculations
///   - Ruling Planets and cuspal-interlink analysis
///   - KP VP291 ayanamsa + Placidus house system
enum AstrologicalSystem {
  /// Traditional Parashari / KN Rao Vedic astrology.
  ///
  /// Default ayanamsa : Lahiri.
  /// Default house system : Whole-Sign (or Equal).
  /// Rahu/Ketu : Mean Node (BPHS) or True Node (modern researchers).
  traditional,

  /// Krishnamurti Paddhati (KP) system.
  ///
  /// Ayanamsa : Krishnamurti VP291 (KP New ayanamsa).
  /// House system : Placidus — **mandatory**.
  /// Zodiac division : Sign → Star → Sub → Sub-Sub (249 divisions).
  ///
  /// Services exclusive to this system:
  ///   [KPService] — Sub-Lords, Significators, Ruling Planets.
  kp,
}

/// Calculation flags for Swiss Ephemeris.
///
/// This library is designed for Vedic astrology and uses sidereal zodiac
/// with Lahiri ayanamsa by default.
class CalculationFlags {
  /// Creates calculation flags for Vedic astrology (sidereal calculations).
  ///
  /// [system]          - Astrological paradigm (default: [AstrologicalSystem.traditional]).
  /// [useSwissEphemeris] - Use Swiss Ephemeris (default: true).
  /// [calculateSpeed] - Calculate planetary speed/velocity (default: true).
  /// [siderealMode]   - Ayanamsa for sidereal calculations (default: Lahiri).
  /// [useTopocentric] - Use topocentric positions (default: false).
  /// [useEquatorial]  - Use equatorial coordinates (default: false).
  /// [nodeType]       - Type of lunar node for Rahu/Ketu (default: meanNode).
  ///
  /// Prefer the named factory constructors:
  ///   - [CalculationFlags.traditionalist()] for Traditional / KN Rao Parashari.
  ///   - [CalculationFlags.kp()] for Krishnamurti Paddhati.
  const CalculationFlags({
    this.system = AstrologicalSystem.traditional,
    this.useSwissEphemeris = true,
    this.calculateSpeed = true,
    this.siderealMode = SiderealMode.lahiri,
    this.useTopocentric = false,
    this.useEquatorial = false,
    this.nodeType = NodeType.meanNode,
  });

  /// Creates default calculation flags (Lahiri sidereal, geocentric, with speed, mean node).
  ///
  /// **Deprecated**: Use `CalculationFlags.traditionalist()` or `CalculationFlags.modernPrecision()`
  /// to explicitly declare node type choice.
  @Deprecated(
      'Use CalculationFlags.traditionalist() for Mean Node or CalculationFlags.modernPrecision() for True Node')
  factory CalculationFlags.defaultFlags() => const CalculationFlags();

  /// Strong default for traditional Indian astrology.
  ///
  /// System : **[AstrologicalSystem.traditional]**.
  /// Ayanamsa : Lahiri | House system : Whole-Sign | Node : Mean Node.
  /// Covers: Parashari, KN Rao, BPHS, Jaimini, Shadbala, all Dasha systems.
  factory CalculationFlags.traditionalist() => const CalculationFlags(
        system: AstrologicalSystem.traditional,
      );

  /// Precision-focused modern Vedic astrology.
  ///
  /// System : **[AstrologicalSystem.traditional]**.
  /// Uses Lahiri ayanamsa and True Node (preferred by contemporary researchers).
  factory CalculationFlags.modernPrecision() => const CalculationFlags(
        system: AstrologicalSystem.traditional,
        nodeType: NodeType.trueNode,
      );

  /// Creates flags for sidereal calculations with a custom ayanamsa.
  /// Defaults to the [AstrologicalSystem.traditional] paradigm.
  factory CalculationFlags.sidereal(SiderealMode mode) => CalculationFlags(
        system: AstrologicalSystem.traditional,
        siderealMode: mode,
      );

  /// Creates flags for sidereal calculations with Lahiri ayanamsa.
  factory CalculationFlags.siderealLahiri() => const CalculationFlags(
        system: AstrologicalSystem.traditional,
        siderealMode: SiderealMode.lahiri,
      );

  /// Creates flags for topocentric calculations (traditional system).
  factory CalculationFlags.topocentric() => const CalculationFlags(
        system: AstrologicalSystem.traditional,
        useTopocentric: true,
      );

  /// Creates flags for the **KP (Krishnamurti Paddhati)** system.
  ///
  /// System : **[AstrologicalSystem.kp]**.
  ///
  /// This preset configures:
  /// - Ayanamsa: Krishnamurti VP291 ("KP New Ayanamsa") — the correct
  ///   ayanamsa for all KP work, distinct from classical Lahiri.
  /// - System tag: [AstrologicalSystem.kp] — enables KP-exclusive services
  ///   ([KPService]) and guard-rail assertions.
  ///
  /// **Important**: pair this with `houseSystem: 'P'` (Placidus) when
  /// calling [calculateVedicChart], as Placidus is mandatory in KP.
  ///
  /// ```dart
  /// final chart = await jyotish.calculateVedicChart(
  ///   dateTime: birthDateTime,
  ///   location: location,
  ///   houseSystem: 'P', // Placidus — mandatory for KP
  ///   flags: CalculationFlags.kp(),
  /// );
  /// final kpData = await jyotish.calculateKPData(chart);
  /// ```
  factory CalculationFlags.kp() => const CalculationFlags(
        system: AstrologicalSystem.kp,
        siderealMode: SiderealMode.krishnamurtiVP291,
      );

  /// Creates flags with specified node type (traditional system).
  ///
  /// [nodeType] - Type of lunar node (meanNode or trueNode).
  factory CalculationFlags.withNodeType(NodeType nodeType) => CalculationFlags(
        system: AstrologicalSystem.traditional,
        nodeType: nodeType,
      );

  /// The high-level astrological system/paradigm.
  ///
  /// Drives which services are valid to use and which ayanamsa / house
  /// system combination is expected.  Use [AstrologicalSystem.traditional]
  /// for Parashari / KN Rao work and [AstrologicalSystem.kp] for KP.
  final AstrologicalSystem system;

  /// Use Swiss Ephemeris (high precision).
  final bool useSwissEphemeris;

  /// Calculate speed (velocity).
  final bool calculateSpeed;

  /// Sidereal ayanamsa mode (Lahiri by default for Vedic astrology).
  final SiderealMode siderealMode;

  /// Use topocentric positions (observed from surface of Earth)
  /// instead of geocentric (from Earth's center).
  final bool useTopocentric;

  /// Use equatorial coordinates instead of ecliptic.
  final bool useEquatorial;

  /// Type of lunar node to use for Rahu/Ketu calculations.
  ///
  /// Many traditional Vedic astrologers use Mean Node (default), while
  /// modern Vedic astrologers often prefer True Node for more accuracy.
  /// - [NodeType.meanNode]: Uses Mean Node (average position of Moon's orbit crossing)
  /// - [NodeType.trueNode]: Uses True Node (actual position at exact moment)
  final NodeType nodeType;

  /// Returns `true` when these flags describe the KP paradigm.
  bool get isKP => system == AstrologicalSystem.kp;

  /// Returns `true` when these flags describe the Traditional paradigm.
  bool get isTraditional => system == AstrologicalSystem.traditional;

  /// Converts flags to Swiss Ephemeris integer flag value.
  /// Note: We always calculate tropical and subtract ayanamsa manually
  /// because SEFLG_SIDEREAL doesn't work properly in compiled library.
  int toSwissEphFlag() {
    int flag = 0;

    if (useSwissEphemeris) {
      flag |= SwissEphConstants.swissEph;
    }

    if (calculateSpeed) {
      flag |= SwissEphConstants.speed;
    }

    if (useTopocentric) {
      flag |= SwissEphConstants.topocentricFlag;
    }

    if (useEquatorial) {
      flag |= SwissEphConstants.equatorial;
    }

    return flag;
  }

  /// Gets the sidereal mode constant.
  int get siderealModeConstant => siderealMode.constant;

  @override
  String toString() {
    return 'CalculationFlags('
        'system: ${system.name}, '
        'swissEph: $useSwissEphemeris, '
        'speed: $calculateSpeed, '
        'ayanamsa: ${siderealMode.name}, '
        'topocentric: $useTopocentric, '
        'equatorial: $useEquatorial, '
        'nodeType: ${nodeType.name})';
  }

  /// Creates a copy with optional parameter overrides.
  CalculationFlags copyWith({
    AstrologicalSystem? system,
    bool? useSwissEphemeris,
    bool? calculateSpeed,
    SiderealMode? siderealMode,
    bool? useTopocentric,
    bool? useEquatorial,
    NodeType? nodeType,
  }) {
    return CalculationFlags(
      system: system ?? this.system,
      useSwissEphemeris: useSwissEphemeris ?? this.useSwissEphemeris,
      calculateSpeed: calculateSpeed ?? this.calculateSpeed,
      siderealMode: siderealMode ?? this.siderealMode,
      useTopocentric: useTopocentric ?? this.useTopocentric,
      useEquatorial: useEquatorial ?? this.useEquatorial,
      nodeType: nodeType ?? this.nodeType,
    );
  }
}

/// Lunar node type for Rahu/Ketu calculations.
///
/// Many traditional Vedic astrologers use Mean Node, while modern Vedic
/// astrologers often prefer True Node for more accuracy.
///
/// - [meanNode]: Uses Mean Node (average position of Moon's orbit crossing)
/// - [trueNode]: Uses True Node (actual position at exact moment)
enum NodeType {
  meanNode('Mean Node', 'Average lunar node position'),
  trueNode('True Node', 'Actual lunar node position');

  const NodeType(this.description, this.technicalDescription);

  final String description;
  final String technicalDescription;

  /// Returns the appropriate Planet constant based on node type.
  Planet get planet {
    switch (this) {
      case NodeType.meanNode:
        return Planet.meanNode;
      case NodeType.trueNode:
        return Planet.trueNode;
    }
  }
}

/// Sidereal ayanamsa modes supported by Swiss Ephemeris.
enum SiderealMode {
  faganBradley(SwissEphConstants.sidmFaganBradley, 'Fagan/Bradley'),
  lahiri(SwissEphConstants.sidmLahiri, 'Lahiri'),
  deluce(SwissEphConstants.sidmDeluce, 'De Luce'),
  raman(SwissEphConstants.sidmRaman, 'Raman'),
  ushashashi(SwissEphConstants.sidmUshashashi, 'Ushashashi'),
  krishnamurti(SwissEphConstants.sidmKrishnamurti, 'Krishnamurti'),
  djwhalKhul(SwissEphConstants.sidmDjwhalKhul, 'Djwhal Khul'),
  yukteshwar(SwissEphConstants.sidmYukteshwar, 'Yukteshwar'),
  jnBhasin(SwissEphConstants.sidmJnBhasin, 'JN Bhasin'),
  babylonianKugler1(
      SwissEphConstants.sidmBabylonianKugler1, 'Babylonian/Kugler 1'),
  babylonianKugler2(
      SwissEphConstants.sidmBabylonianKugler2, 'Babylonian/Kugler 2'),
  babylonianKugler3(
      SwissEphConstants.sidmBabylonianKugler3, 'Babylonian/Kugler 3'),
  babylonianHuber(SwissEphConstants.sidmBabylonianHuber, 'Babylonian/Huber'),
  babylonianEtpsc(SwissEphConstants.sidmBabylonianEtpsc, 'Babylonian/ETPSC'),
  aldebaran15Tau(SwissEphConstants.sidmAldebaran15Tau, 'Aldebaran at 15 Tau'),
  hipparchos(SwissEphConstants.sidmHipparchos, 'Hipparchos'),
  sassanian(SwissEphConstants.sidmSassanian, 'Sassanian'),
  galcentMulaWilhelm(
      SwissEphConstants.sidmGalcentMulaWilhelm, 'Galactic Center Mula Wilhelm'),
  ayanamsa(SwissEphConstants.sidmAyanamsa, 'Ayanamsa'),
  galcentCochrane(
      SwissEphConstants.sidmGalcentCochrane, 'Galactic Center Cochrane'),
  galequIau1958(SwissEphConstants.sidmGalequIau1958, 'Gal Eq IAU 1958'),
  galequTrue(SwissEphConstants.sidmGalequTrue, 'Gal Eq True'),
  galequMula(SwissEphConstants.sidmGalequMula, 'Gal Eq Mula'),
  galalignMardyks(SwissEphConstants.sidmGalalignMardyks, 'Gal Align Mardyks'),
  trueCitra(SwissEphConstants.sidmTrueCitra, 'True Citra'),
  trueRevati(SwissEphConstants.sidmTrueRevati, 'True Revati'),
  truePushya(SwissEphConstants.sidmTruePushya, 'True Pushya'),
  galcentRothers(
      SwissEphConstants.sidmGalcentRothers, 'Galactic Center Others'),
  galcent0Sag(SwissEphConstants.sidmGalcent0Sag, 'Galactic Center 0 Sag'),
  j2000(SwissEphConstants.sidmJ2000, 'J2000'),
  j1900(SwissEphConstants.sidmJ1900, 'J1900'),
  b1950(SwissEphConstants.sidmB1950, 'B1950'),
  suryasiddhanta(SwissEphConstants.sidmSuryasiddhanta, 'Surya Siddhanta'),
  suryasiddhantaMsun(
      SwissEphConstants.sidmSuryasiddhantaMsun, 'Surya Siddhanta MSun'),
  aryabhata(SwissEphConstants.sidmAryabhata, 'Aryabhata'),
  aryabhataMsun(SwissEphConstants.sidmAryabhataMsun, 'Aryabhata MSun'),
  ssRevati(SwissEphConstants.sidmSsRevati, 'SS Revati'),
  ssCitra(SwissEphConstants.sidmSsCitra, 'SS Citra'),
  trueSherpas(SwissEphConstants.sidmTrueSherpas, 'True Sherpas'),
  trueMula(SwissEphConstants.sidmTrueMula, 'True Mula'),
  galcentMula0(SwissEphConstants.sidmGalcentMula0, 'Galactic Center Mula 0'),
  galcentMulaVerneau(
      SwissEphConstants.sidmGalcentMulaVerneau, 'Galactic Center Mula Verneau'),
  valensBow(SwissEphConstants.sidmValensBow, 'Valens Bow'),
  lahiri1940(SwissEphConstants.sidmLahiri1940, 'Lahiri 1940'),
  lahiriVP285(SwissEphConstants.sidmLahiriVP285, 'Lahiri VP285'),
  krishnamurtiVP291(
      SwissEphConstants.sidmKrishnamurtiVP291, 'Krishnamurti VP291 (KP New)'),
  lahiriICRC(SwissEphConstants.sidmLahiriICRC, 'Lahiri ICRC'),
  khullar(SwissEphConstants.sidmKhullar, 'Khullar Ayanamsa');

  const SiderealMode(this.constant, this.name);

  final int constant;
  final String name;

  @override
  String toString() => name;
}
