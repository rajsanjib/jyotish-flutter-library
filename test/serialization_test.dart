import 'package:flutter_test/flutter_test.dart';
import 'package:jyotish/jyotish.dart';

void main() {
  group('Data Model Serialization & Immutability Tests', () {
    test('PlanetPosition toJson, fromJson, and copyWith', () {
      final pos = PlanetPosition(
        planet: Planet.sun,
        dateTime: DateTime.utc(2026, 1, 1, 12, 0, 0),
        longitude: 280.5,
        latitude: 0.0,
        distance: 0.983,
        longitudeSpeed: 1.01,
        latitudeSpeed: 0.0,
        distanceSpeed: 0.0,
      );

      final json = pos.toJson();
      expect(json['planet'], equals('Sun'));
      expect(json['longitude'], equals(280.5));

      final deserialized = PlanetPosition.fromJson(json);
      expect(deserialized.planet, equals(Planet.sun));
      expect(deserialized.longitude, equals(280.5));
      expect(deserialized.dateTime, equals(DateTime.utc(2026, 1, 1, 12, 0, 0)));

      final updated = pos.copyWith(longitude: 281.0);
      expect(updated.longitude, equals(281.0));
      expect(updated.planet, equals(Planet.sun));
    });

    test('HouseSystem toJson, fromJson, and copyWith', () {
      final cusps = HouseSystem(
        system: 'W',
        ascendant: 15.0,
        midheaven: 105.0,
        cusps: List.generate(12, (i) => i * 30.0),
      );

      final json = cusps.toJson();
      final deserialized = HouseSystem.fromJson(json);

      expect(deserialized.system, equals('W'));
      expect(deserialized.ascendant, equals(15.0));
      expect(deserialized.cusps.length, equals(12));

      final updated = cusps.copyWith(ascendant: 20.0);
      expect(updated.ascendant, equals(20.0));
    });

    test('DashaPeriod toJson, fromJson, and copyWith', () {
      final period = DashaPeriod(
        lord: Planet.jupiter,
        startDate: DateTime.utc(2026, 1, 1),
        endDate: DateTime.utc(2042, 1, 1),
        duration: const Duration(days: 5844),
        level: 0,
      );

      final json = period.toJson();
      final deserialized = DashaPeriod.fromJson(json);

      expect(deserialized.lord, equals(Planet.jupiter));
      expect(deserialized.level, equals(0));
      expect(deserialized.startDate, equals(DateTime.utc(2026, 1, 1)));

      final copy = period.copyWith(level: 1);
      expect(copy.level, equals(1));
    });

    test('VedicChart toJson, fromJson, and copyWith', () {
      final pos = PlanetPosition(
        planet: Planet.sun,
        dateTime: DateTime.utc(2026, 1, 1, 12, 0, 0),
        longitude: 280.5,
        latitude: 0.0,
        distance: 0.983,
        longitudeSpeed: 1.01,
        latitudeSpeed: 0.0,
        distanceSpeed: 0.0,
      );

      final planetInfo = VedicPlanetInfo(
        position: pos,
        house: 10,
        dignity: PlanetaryDignity.exalted,
      );

      final houses = HouseSystem(
        system: 'W',
        ascendant: 15.0,
        midheaven: 105.0,
        cusps: List.generate(12, (i) => i * 30.0),
      );

      final chart = VedicChart(
        dateTime: DateTime.utc(2026, 1, 1, 12, 0, 0),
        location: 'New Delhi, India',
        latitude: 28.6139,
        longitudeCoord: 77.2090,
        altitude: 216.0,
        houses: houses,
        planets: {Planet.sun: planetInfo},
        rahu: planetInfo,
        ketu: KetuPosition(rahuPosition: pos),
      );

      final json = chart.toJson();
      final deserialized = VedicChart.fromJson(json);

      expect(deserialized.location, equals('New Delhi, India'));
      expect(deserialized.latitude, equals(28.6139));
      expect(deserialized.planets[Planet.sun]?.house, equals(10));

      final updated = chart.copyWith(location: 'Mumbai, India');
      expect(updated.location, equals('Mumbai, India'));
    });
  });
}
