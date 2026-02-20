import '../models/calculation_flags.dart';
import '../models/geographic_location.dart';
import '../models/masa.dart';
import '../models/nakshatra.dart';
import '../models/panchanga.dart';
import '../models/planet.dart';
import '../models/planet_position.dart';
import 'ephemeris_service.dart';

class MasaService {
  MasaService(this._ephemerisService);
  final EphemerisService _ephemerisService;

  Future<MasaInfo> calculateMasa({
    required DateTime dateTime,
    required GeographicLocation location,
    MasaType type = MasaType.amanta,
  }) async {
    final flags = CalculationFlags.defaultFlags();

    final sunPos = await _ephemerisService.calculatePlanetPosition(
      planet: Planet.sun,
      dateTime: dateTime,
      location: location,
      flags: flags,
    );

    final moonPos = await _ephemerisService.calculatePlanetPosition(
      planet: Planet.moon,
      dateTime: dateTime,
      location: location,
      flags: flags,
    );

    final tithi = _calculateTithi(sunPos, moonPos);

    LunarMonth month;
    int monthNumber;

    if (type == MasaType.amanta) {
      month = _calculateAmantaMonth(sunPos.longitude, tithi);
      monthNumber = _getAmantaMonthNumber(month);
    } else {
      month = _calculatePurnimantaMonth(sunPos.longitude, tithi);
      monthNumber = _getPurnimantaMonthNumber(month);
    }

    final adhikaType = await _checkAdhikaMasa(
      sunPos.longitude,
      dateTime,
      location,
      type,
    );

    return MasaInfo(
      month: month,
      monthNumber: monthNumber,
      type: type,
      adhikaType: adhikaType,
      sunLongitude: sunPos.longitude,
      tithiInfo: tithi,
    );
  }

  TithiInfo _calculateTithi(PlanetPosition sunPos, PlanetPosition moonPos) {
    var elongation = moonPos.longitude - sunPos.longitude;
    if (elongation < 0) elongation += 360;

    const tithiDegrees = 12.0;
    final tithiNumber = (elongation / tithiDegrees).floor() + 1;
    final elapsed = (elongation % tithiDegrees) / tithiDegrees;

    final paksha = Paksha.fromTithiNumber(tithiNumber);
    final nameIndex = (tithiNumber - 1) % 15;
    final name = TithiInfo.tithiNames[nameIndex];

    return TithiInfo(
      number: tithiNumber,
      name: name,
      paksha: paksha,
      elapsed: elapsed,
    );
  }

  LunarMonth _calculateAmantaMonth(double sunLongitude, TithiInfo tithi) {
    final baseMonth = MasaInfo.getMonthFromSunLongitude(sunLongitude);

    if (tithi.number >= 16 && tithi.number <= 30) {
      final currentIndex = MasaInfo.amantaMonthOrder.indexOf(baseMonth);
      final nextIndex = (currentIndex + 1) % 12;
      return MasaInfo.amantaMonthOrder[nextIndex];
    }

    return baseMonth;
  }

  LunarMonth _calculatePurnimantaMonth(double sunLongitude, TithiInfo tithi) {
    final baseMonth = MasaInfo.getMonthFromSunLongitude(sunLongitude);

    if (tithi.number >= 16 && tithi.number <= 30) {
      final currentIndex = MasaInfo.purnimantaMonthOrder.indexOf(baseMonth);
      final nextIndex = (currentIndex + 1) % 12;
      return MasaInfo.purnimantaMonthOrder[nextIndex];
    }

    return baseMonth;
  }

  int _getAmantaMonthNumber(LunarMonth month) {
    return MasaInfo.amantaMonthOrder.indexOf(month) + 1;
  }

  int _getPurnimantaMonthNumber(LunarMonth month) {
    return MasaInfo.purnimantaMonthOrder.indexOf(month) + 1;
  }

  Future<AdhikaMasaType> _checkAdhikaMasa(
    double currentSunLongitude,
    DateTime dateTime,
    GeographicLocation location,
    MasaType type,
  ) async {
    final signIndex = (currentSunLongitude / 30).floor();

    final oneMonthAgo = dateTime.subtract(const Duration(days: 30));
    final flags = CalculationFlags.defaultFlags();

    final sunPosMonthAgo = await _ephemerisService.calculatePlanetPosition(
      planet: Planet.sun,
      dateTime: oneMonthAgo,
      location: location,
      flags: flags,
    );

    final signIndexMonthAgo = (sunPosMonthAgo.longitude / 30).floor();

    if (signIndexMonthAgo == signIndex) {
      return AdhikaMasaType.adhika;
    }

    return AdhikaMasaType.none;
  }

  Future<String> getSamvatsara({
    required DateTime dateTime,
    required GeographicLocation location,
  }) async {
    const yugaStartYear = 1986;

    final yearDifference = dateTime.year - yugaStartYear;
    final samvatsaraIndex = (yearDifference + 48) % 60;

    return Samvatsara.getSamvatsaraName(samvatsaraIndex);
  }

  Future<NakshatraInfo> getNakshatraWithAbhijit({
    required DateTime dateTime,
    required GeographicLocation location,
  }) async {
    final flags = CalculationFlags.defaultFlags();

    final moonPos = await _ephemerisService.calculatePlanetPosition(
      planet: Planet.moon,
      dateTime: dateTime,
      location: location,
      flags: flags,
    );

    return _calculateNakshatraWithAbhijit(moonPos.longitude);
  }

  /// Calculates nakshatra information from a longitude value.
  /// 
  /// This is the core calculation used by other methods. It determines
  /// which of the 27 nakshatras a given longitude falls into.
  /// 
  /// [longitude] - The longitude in degrees (0-360)
  /// 
  /// Returns [NakshatraInfo] without Abhijit calculation (standard 27 nakshatras)
  NakshatraInfo calculateNakshatraFromLongitude(double longitude) {
    var normalizedLongitude = longitude % 360;
    if (normalizedLongitude < 0) normalizedLongitude += 360;

    const nakshatraWidth = 360.0 / 27;
    final nakshatraNumber = (normalizedLongitude / nakshatraWidth).floor() + 1;
    final name = NakshatraInfo.nakshatraNames[nakshatraNumber - 1];
    final rulingPlanet = NakshatraInfo.nakshatraLords[nakshatraNumber - 1];

    final positionInNakshatra = normalizedLongitude % nakshatraWidth;
    final pada = (positionInNakshatra / (nakshatraWidth / 4)).floor() + 1;

    return NakshatraInfo(
      number: nakshatraNumber,
      name: name,
      rulingPlanet: rulingPlanet,
      longitude: normalizedLongitude,
      pada: pada,
      isAbhijit: false,
      abhijitPortion: 0.0,
    );
  }

  NakshatraInfo _calculateNakshatraWithAbhijit(double longitude) {
    var normalizedLongitude = longitude % 360;
    if (normalizedLongitude < 0) normalizedLongitude += 360;

    final isAbhijit = normalizedLongitude >= NakshatraInfo.abhijitStart &&
        normalizedLongitude < NakshatraInfo.abhijitEnd;

    int nakshatraNumber;
    String name;
    Planet rulingPlanet;

    if (isAbhijit) {
      nakshatraNumber = 28;
      name = 'Abhijit';
      rulingPlanet = Planet.sun;
    } else {
      const nakshatraWidth = 360.0 / 27;
      nakshatraNumber = (normalizedLongitude / nakshatraWidth).floor() + 1;
      name = NakshatraInfo.nakshatraNames[nakshatraNumber - 1];
      rulingPlanet = NakshatraInfo.nakshatraLords[nakshatraNumber - 1];
    }

    const nakshatraWidth = 360.0 / 27;
    final positionInNakshatra = normalizedLongitude % nakshatraWidth;
    final pada = (positionInNakshatra / (nakshatraWidth / 4)).floor() + 1;

    final abhijitPortion = isAbhijit
        ? (normalizedLongitude - NakshatraInfo.abhijitStart) /
            (NakshatraInfo.abhijitEnd - NakshatraInfo.abhijitStart)
        : 0.0;

    return NakshatraInfo(
      number: nakshatraNumber,
      name: name,
      rulingPlanet: rulingPlanet,
      longitude: normalizedLongitude,
      pada: pada,
      isAbhijit: isAbhijit,
      abhijitPortion: abhijitPortion,
    );
  }

  Future<List<MasaInfo>> getMasaListForYear({
    required int year,
    required GeographicLocation location,
    MasaType type = MasaType.amanta,
  }) async {
    final masaList = <MasaInfo>[];

    final startDate = DateTime(year, 1, 1);
    for (int i = 0; i < 12; i++) {
      final date = startDate.add(Duration(days: i * 30));
      final masa = await calculateMasa(
        dateTime: date,
        location: location,
        type: type,
      );
      masaList.add(masa);
    }

    return masaList;
  }

  /// Gets the Hindu season (Ritu) based on the lunar month.
  ///
  /// In Vedic tradition, the year is divided into six seasons (Ritus),
  /// each associated with specific lunar months:
  /// - Vasanta (Spring): Chaitra, Vaishakha
  /// - Grishma (Summer): Jyeshtha, Ashadha
  /// - Varsha (Monsoon): Shravana, Bhadrapada
  /// - Sharad (Autumn): Ashwin, Kartika
  /// - Hemanta (Pre-winter): Margashirsha, Pausha
  /// - Shishira (Winter): Magha, Phalguna
  ///
  /// [masaInfo] - The MasaInfo containing the lunar month
  ///
  /// Returns the corresponding Ritu
  Ritu getRitu(MasaInfo masaInfo) {
    return switch (masaInfo.month) {
      LunarMonth.chaitra || LunarMonth.vaishakha => Ritu.vasanta,
      LunarMonth.jyeshtha || LunarMonth.ashadha => Ritu.grishma,
      LunarMonth.shravana || LunarMonth.bhadrapada => Ritu.varsha,
      LunarMonth.ashwin || LunarMonth.kartika => Ritu.sharad,
      LunarMonth.margashirsha || LunarMonth.pausha => Ritu.hemanta,
      LunarMonth.magha || LunarMonth.phalguna => Ritu.shishira,
    };
  }

  /// Gets Ritu details for a specific date.
  ///
  /// [dateTime] - The date to check
  /// [location] - Geographic location
  ///
  /// Returns detailed Ritu information
  Future<RituInfo> getRituDetails({
    required DateTime dateTime,
    required GeographicLocation location,
  }) async {
    final masa = await calculateMasa(
      dateTime: dateTime,
      location: location,
    );

    final ritu = getRitu(masa);

    return RituInfo(
      ritu: ritu,
      masa: masa,
      description: ritu.description,
      characteristics: ritu.characteristics,
      governingElement: ritu.governingElement,
    );
  }
}
