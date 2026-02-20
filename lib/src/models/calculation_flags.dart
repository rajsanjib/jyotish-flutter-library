import '../constants/planet_constants.dart';
import 'planet.dart';

/// Calculation flags for Swiss Ephemeris.
///
/// This library is designed for Vedic astrology and uses sidereal zodiac
/// with Lahiri ayanamsa by default.
class CalculationFlags {
  /// Creates calculation flags for Vedic astrology (sidereal calculations).
  ///
  /// [useSwissEphemeris] - Use Swiss Ephemeris (default: true)
  /// [calculateSpeed] - Calculate planetary speed/velocity (default: true)
  /// [siderealMode] - Ayanamsa for sidereal calculations (default: Lahiri)
  /// [useTopocentric] - Use topocentric positions (default: false)
  /// [useEquatorial] - Use equatorial coordinates (default: false)
  /// [nodeType] - Type of lunar node for Rahu/Ketu (default: meanNode)
  const CalculationFlags({
    this.useSwissEphemeris = true,
    this.calculateSpeed = true,
    this.siderealMode = SiderealMode.lahiri,
    this.useTopocentric = false,
    this.useEquatorial = false,
    this.nodeType = NodeType.meanNode,
  });

  /// Creates default calculation flags (Lahiri sidereal, geocentric, with speed).
  factory CalculationFlags.defaultFlags() => const CalculationFlags();

  /// Creates flags for sidereal calculations with custom ayanamsa.
  factory CalculationFlags.sidereal(SiderealMode mode) => CalculationFlags(
        siderealMode: mode,
      );

  /// Creates flags for sidereal calculations with Lahiri ayanamsa.
  factory CalculationFlags.siderealLahiri() => const CalculationFlags(
        siderealMode: SiderealMode.lahiri,
      );

  /// Creates flags for topocentric calculations.
  factory CalculationFlags.topocentric() => const CalculationFlags(
        useTopocentric: true,
      );

  /// Creates flags with specified node type.
  ///
  /// [nodeType] - Type of lunar node (meanNode or trueNode)
  factory CalculationFlags.withNodeType(NodeType nodeType) => CalculationFlags(
        nodeType: nodeType,
      );

  /// Use Swiss Ephemeris (high precision)
  final bool useSwissEphemeris;

  /// Calculate speed (velocity)
  final bool calculateSpeed;

  /// Sidereal ayanamsa mode (Lahiri by default for Vedic astrology)
  final SiderealMode siderealMode;

  /// Use topocentric positions (observed from surface of Earth)
  /// instead of geocentric (from Earth's center)
  final bool useTopocentric;

  /// Use equatorial coordinates instead of ecliptic
  final bool useEquatorial;

  /// Type of lunar node to use for Rahu/Ketu calculations.
  ///
  /// Many traditional Vedic astrologers use Mean Node (default), while
  /// modern Vedic astrologers often prefer True Node for more accuracy.
  /// - [NodeType.meanNode]: Uses Mean Node (average position of Moon's orbit crossing)
  /// - [NodeType.trueNode]: Uses True Node (actual position at exact moment)
  final NodeType nodeType;

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
        'swissEph: $useSwissEphemeris, '
        'speed: $calculateSpeed, '
        'ayanamsa: ${siderealMode.name}, '
        'topocentric: $useTopocentric, '
        'equatorial: $useEquatorial, '
        'nodeType: ${nodeType.name})';
  }

  /// Creates a copy with optional parameter overrides.
  CalculationFlags copyWith({
    bool? useSwissEphemeris,
    bool? calculateSpeed,
    SiderealMode? siderealMode,
    bool? useTopocentric,
    bool? useEquatorial,
    NodeType? nodeType,
  }) {
    return CalculationFlags(
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
