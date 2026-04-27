import 'dart:io';
import 'package:jyotish/jyotish.dart';

void main() async {
  final ephemerisService = EphemerisService();
  await ephemerisService.initialize(ephemerisPath: 'ephe');
  
  final location = GeographicLocation(
    latitude: 28.6139,
    longitude: 77.2090,
    timezone: 'Asia/Kolkata',
  );

  final date = DateTime(2024, 6, 15);
  stdout.writeln('Input Date: $date');

  final (sunrise, sunset) = await ephemerisService.getSunriseSunset(
    date: date,
    location: location,
  );

  stdout.writeln('Sunrise: $sunrise');
  stdout.writeln('Sunset: $sunset');
  
  if (sunrise != null && sunset != null) {
    stdout.writeln('Sunrise before Sunset? ${sunrise.isBefore(sunset)}');
  } else {
    stdout.writeln('One of them is null');
  }
  
  ephemerisService.dispose();
}
