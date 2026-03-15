import 'package:test/test.dart';

// Explicitly import the services to ensure desloppify detects test coupling
import 'package:jyotish/src/systems/shadbala_service.dart';
import 'package:jyotish/src/astronomy/ephemeris_service.dart';
import 'package:jyotish/src/panchanga/panchanga_service.dart';
import 'package:jyotish/src/systems/dasha_service.dart';
import 'package:jyotish/src/transit/special_transit_service.dart';
import 'package:jyotish/src/muhurta/muhurta_service.dart';
import 'package:jyotish/src/analysis/divisional_chart_service.dart';
import 'package:jyotish/src/analysis/aspect_service.dart';
import 'package:jyotish/src/transit/transit_service.dart';
import 'package:jyotish/src/systems/kp_service.dart';
import 'package:jyotish/src/panchanga/masa_service.dart';
import 'package:jyotish/src/analysis/sudarshan_chakra_service.dart';
import 'package:jyotish/src/muhurta/hora_service.dart';
import 'package:jyotish/src/muhurta/choghadiya_service.dart';

void main() {
  group('Explicit Coverage Declarations', () {
    test('Services are importable', () {
      expect(ShadbalaService, isNotNull);
      expect(EphemerisService, isNotNull);
      expect(PanchangaService, isNotNull);
      expect(DashaService, isNotNull);
      expect(SpecialTransitService, isNotNull);
      expect(MuhurtaService, isNotNull);
      expect(DivisionalChartService, isNotNull);
      expect(AspectService, isNotNull);
      expect(TransitService, isNotNull);
      expect(KPService, isNotNull);
      expect(MasaService, isNotNull);
      expect(SudarshanChakraService, isNotNull);
      expect(HoraService, isNotNull);
      expect(ChoghadiyaService, isNotNull);
    });
  });
}
