/// Swiss Ephemeris planet constants.
///
/// These constants correspond to the planet numbers used by Swiss Ephemeris.
class SwissEphConstants {
  SwissEphConstants._();
  // Main planets
  static const int sun = 0;
  static const int moon = 1;
  static const int mercury = 2;
  static const int venus = 3;
  static const int mars = 4;
  static const int jupiter = 5;
  static const int saturn = 6;
  static const int uranus = 7;
  static const int neptune = 8;
  static const int pluto = 9;

  // Moon nodes
  static const int meanNode = 10;
  static const int trueNode = 11;

  // Ketu (South Node) - computed as 180° from Rahu, uses custom ID
  static const int ketu = 100; // Custom ID for Ketu (not a Swiss Ephemeris constant)
  static const int meanApog = 12; // Mean Lunar Apogee (Black Moon Lilith)
  static const int oscuApog = 13; // Osculating Lunar Apogee

  // Additional points
  static const int earthPlanet = 14;
  static const int chiron = 15;
  static const int pholus = 16;
  static const int ceres = 17;
  static const int pallas = 18;
  static const int juno = 19;
  static const int vesta = 20;

  // Calculation flags
  static const int swissEph = 2; // Use Swiss Ephemeris
  static const int speed = 256; // Calculate speed
  static const int sidereal = 64; // Sidereal calculation
  static const int tropical = 0; // Tropical calculation (default)
  static const int equatorial = 2048; // Equatorial positions
  static const int topocentricFlag = 32 * 1024; // Topocentric positions

  // Sidereal modes
  static const int sidmFaganBradley = 0;
  static const int sidmLahiri = 1;
  static const int sidmDeluce = 2;
  static const int sidmRaman = 3;
  static const int sidmUshashashi = 4;
  static const int sidmKrishnamurti = 5;
  static const int sidmDjwhalKhul = 6;
  static const int sidmYukteshwar = 7;
  static const int sidmJnBhasin = 8;
  static const int sidmBabylonianKugler1 = 9;
  static const int sidmBabylonianKugler2 = 10;
  static const int sidmBabylonianKugler3 = 11;
  static const int sidmBabylonianHuber = 12;
  static const int sidmBabylonianEtpsc = 13;
  static const int sidmAldebaran15Tau = 14;
  static const int sidmHipparchos = 15;
  static const int sidmSassanian = 16;
  static const int sidmGalcentMulaWilhelm = 17;
  static const int sidmAyanamsa = 18;
  static const int sidmGalcentCochrane = 19;
  static const int sidmGalequIau1958 = 20;
  static const int sidmGalequTrue = 21;
  static const int sidmGalequMula = 22;
  static const int sidmGalalignMardyks = 23;
  static const int sidmTrueCitra = 24;
  static const int sidmTrueRevati = 25;
  static const int sidmTruePushya = 26;
  static const int sidmGalcentRothers = 27;
  static const int sidmGalcent0Sag = 28;
  static const int sidmJ2000 = 29;
  static const int sidmJ1900 = 30;
  static const int sidmB1950 = 31;
  static const int sidmSuryasiddhanta = 32;
  static const int sidmSuryasiddhantaMsun = 33;
  static const int sidmAryabhata = 34;
  static const int sidmAryabhataMsun = 35;
  static const int sidmSsRevati = 36;
  static const int sidmSsCitra = 37;
  static const int sidmTrueSherpas = 38;
  static const int sidmTrueMula = 39;
  static const int sidmGalcentMula0 = 40;
  static const int sidmGalcentMulaVerneau = 41;
  static const int sidmValensBow = 42;
  static const int sidmLahiri1940 = 43;
  static const int sidmLahiriVP285 = 44;
  static const int sidmKrishnamurtiVP291 = 45; // KP New (VP291)
  static const int sidmLahiriICRC = 46;
  static const int sidmKhullar = 47; // Khullar Ayanamsa
  static const int sidmUserDefined = 255;

  // House systems
  static const String housePlacidus = 'P';
  static const String houseKoch = 'K';
  static const String housePorphyry = 'O';
  static const String houseRegiomontanus = 'R';
  static const String houseCampanus = 'C';
  static const String houseEqual = 'E';
  static const String houseWholeSign = 'W';
  static const String houseMeridian = 'X';
  static const String houseHorizontal = 'H';
  static const String housePolich = 'T';
  static const String houseAlcabitus = 'B';
  static const String houseKrusinski = 'U';

  // Rise/Set calculation flags (rsmi)
  static const int calcRise = 1; // SE_CALC_RISE
  static const int calcSet = 2; // SE_CALC_SET
  static const int calcMTransit = 4; // SE_CALC_MTRANSIT
  static const int calcITransit = 8; // SE_CALC_ITRANSIT
  static const int bitDiscCenter = 256; // SE_BIT_DISC_CENTER
  static const int bitDiscBottom = 8192; // SE_BIT_DISC_BOTTOM
  static const int bitNoRefraction = 512; // SE_BIT_NO_REFRACTION
  static const int bitCivilTwilight = 1024; // SE_BIT_CIVIL_TWILIGHT
  static const int bitNauticTwilight = 2048; // SE_BIT_NAUTIC_TWILIGHT
  static const int bitAstroTwilight = 4096; // SE_BIT_ASTRO_TWILIGHT
  static const int bitFixedDiscSize = 16384; // SE_BIT_FIXED_DISC_SIZE
  static const int bitHinduRising = bitDiscCenter | bitNoRefraction;
}
