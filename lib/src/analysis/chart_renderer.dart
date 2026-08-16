import 'package:flutter/material.dart';
import '../models/vedic_chart.dart';
import '../models/planet.dart';

/// Available chart rendering styles.
enum ChartStyle {
  /// Clockwise grid-based chart where zodiac signs are fixed and house numbers vary.
  southIndian,

  /// Counter-clockwise diamond-based chart where houses are fixed and sign numbers vary.
  northIndian,
}

/// Helper extension on [VedicChart] to provide SVG rendering capabilities.
extension VedicChartRenderer on VedicChart {
  /// Generates a clean, modern, and beautifully styled SVG representation of the chart.
  ///
  /// Supports [ChartStyle.southIndian] and [ChartStyle.northIndian].
  String toSVG({
    ChartStyle style = ChartStyle.southIndian,
    double width = 500,
    double height = 500,
    bool darkTheme = false,
  }) {
    final strokeColor = darkTheme ? '#ffffff' : '#1e293b';
    final textColor = darkTheme ? '#f1f5f9' : '#0f172a';
    final labelColor = darkTheme ? '#94a3b8' : '#64748b';
    final cardBg = darkTheme ? '#0f172a' : '#ffffff';
    final ascColor = '#f59e0b'; // Amber Accent

    final buffer = StringBuffer();
    buffer.write(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 500" width="$width" height="$height">');

    // Background card
    buffer.write(
        '<rect width="500" height="500" rx="16" fill="$cardBg" stroke="$strokeColor" stroke-width="2"/>');

    if (style == ChartStyle.southIndian) {
      _drawSouthIndianSVG(buffer, strokeColor, textColor, labelColor, ascColor);
    } else {
      _drawNorthIndianSVG(buffer, strokeColor, textColor, labelColor, ascColor);
    }

    buffer.write('</svg>');
    return buffer.toString();
  }

  void _drawSouthIndianSVG(
    StringBuffer buffer,
    String strokeColor,
    String textColor,
    String labelColor,
    String ascColor,
  ) {
    // 4x4 Grid paths
    final step = 500.0 / 4;
    for (var i = 1; i < 4; i++) {
      final pos = i * step;
      buffer.write(
          '<line x1="$pos" y1="0" x2="$pos" y2="500" stroke="$strokeColor" stroke-width="1.5" stroke-dasharray="1 1"/>');
      buffer.write(
          '<line x1="0" y1="$pos" x2="500" y2="$pos" stroke="$strokeColor" stroke-width="1.5" stroke-dasharray="1 1"/>');
    }

    // Outer boundary borders
    buffer.write(
        '<rect x="0" y="0" width="500" height="500" fill="none" stroke="$strokeColor" stroke-width="3"/>');
    // Inner center box (covering 2x2 blocks)
    buffer.write(
        '<rect x="$step" y="$step" width="${step * 2}" height="${step * 2}" fill="none" stroke="$strokeColor" stroke-width="3"/>');

    // South Indian Sign Coordinates (standard clockwise layout)
    final gridCoords = [
      (0, 1), // Aries (0)
      (0, 2), // Taurus (1)
      (0, 3), // Gemini (2)
      (1, 3), // Cancer (3)
      (2, 3), // Leo (4)
      (3, 3), // Virgo (5)
      (3, 2), // Libra (6)
      (3, 1), // Scorpio (7)
      (3, 0), // Sagittarius (8)
      (2, 0), // Capricorn (9)
      (1, 0), // Aquarius (10)
      (0, 0), // Pisces (11)
    ];

    final signAbbr = [
      'Ar',
      'Ta',
      'Ge',
      'Ca',
      'Le',
      'Vi',
      'Li',
      'Sc',
      'Sa',
      'Cp',
      'Aq',
      'Pi'
    ];

    // Map each planet to its zodiac sign
    final planetsInSign = List.generate(12, (_) => <String>[]);
    for (final info in planets.values) {
      final signIndex = (info.longitude / 30).floor() % 12;
      planetsInSign[signIndex].add(_getPlanetAbbr(info.planet));
    }
    // Add Rahu/Ketu
    final rahuSign = (rahu.longitude / 30).floor() % 12;
    planetsInSign[rahuSign].add('Ra');
    final ketuSign = (ketu.longitude / 30).floor() % 12;
    planetsInSign[ketuSign].add('Ke');

    // Check Ascendant
    final ascSign = (ascendant / 30).floor() % 12;

    for (var rashiIdx = 0; rashiIdx < 12; rashiIdx++) {
      final coord = gridCoords[rashiIdx];
      final x = coord.$2 * step;
      final y = coord.$1 * step;

      // Draw sign name label
      buffer.write(
          '<text x="${x + 8}" y="${y + 20}" font-family="system-ui, sans-serif" font-size="12" font-weight="bold" fill="$labelColor">${signAbbr[rashiIdx]}</text>');

      // Draw Lagna marker (ASC)
      if (rashiIdx == ascSign) {
        buffer.write(
            '<text x="${x + step - 32}" y="${y + 20}" font-family="system-ui, sans-serif" font-size="11" font-weight="bold" fill="$ascColor">ASC</text>');
      }

      // Draw planets list inside the box
      final plList = planetsInSign[rashiIdx];
      var py = y + 42.0;
      for (var pIdx = 0; pIdx < plList.length; pIdx += 2) {
        final pair = plList
            .sublist(pIdx, pIdx + 2 > plList.length ? plList.length : pIdx + 2)
            .join(' ');
        buffer.write(
            '<text x="${x + 12}" y="$py" font-family="system-ui, sans-serif" font-size="14" font-weight="bold" fill="$textColor">$pair</text>');
        py += 18.0;
      }
    }

    // Write chart metadata in the center box
    final centerX = 250.0;
    buffer.write(
        '<text x="$centerX" y="220" text-anchor="middle" font-family="system-ui, sans-serif" font-size="16" font-weight="bold" fill="$textColor">RASHI CHART</text>');
    buffer.write(
        '<text x="$centerX" y="248" text-anchor="middle" font-family="system-ui, sans-serif" font-size="11" fill="$labelColor">Lagna: ${houses.ascendantSign}</text>');
    buffer.write(
        '<text x="$centerX" y="270" text-anchor="middle" font-family="system-ui, sans-serif" font-size="11" fill="$labelColor">${dateTime.toLocal().toString().substring(0, 16)}</text>');
  }

  void _drawNorthIndianSVG(
    StringBuffer buffer,
    String strokeColor,
    String textColor,
    String labelColor,
    String ascColor,
  ) {
    // Outer boundary box
    buffer.write(
        '<rect x="0" y="0" width="500" height="500" fill="none" stroke="$strokeColor" stroke-width="3"/>');

    // Drawing diagonals
    buffer.write(
        '<line x1="0" y1="0" x2="500" y2="500" stroke="$strokeColor" stroke-width="2"/>');
    buffer.write(
        '<line x1="500" y1="0" x2="0" y2="500" stroke="$strokeColor" stroke-width="2"/>');

    // Drawing Inner Diamond
    buffer.write(
        '<polygon points="250,0 500,250 250,500 0,250" fill="none" stroke="$strokeColor" stroke-width="2"/>');

    // Define center points for each of the 12 houses to place text
    final centers = [
      const Offset(250.0, 120.0), // House 1
      const Offset(120.0, 60.0), // House 2
      const Offset(60.0, 120.0), // House 3
      const Offset(125.0, 250.0), // House 4
      const Offset(60.0, 380.0), // House 5
      const Offset(120.0, 440.0), // House 6
      const Offset(250.0, 380.0), // House 7
      const Offset(380.0, 440.0), // House 8
      const Offset(440.0, 380.0), // House 9
      const Offset(375.0, 250.0), // House 10
      const Offset(440.0, 120.0), // House 11
      const Offset(380.0, 60.0), // House 12
    ];

    final ascSign = (ascendant / 30).floor() % 12;

    // Place sign numbers and planets in houses
    for (var h = 1; h <= 12; h++) {
      final center = centers[h - 1];
      final signNumber = ((ascSign + h - 1) % 12) + 1;

      // Draw sign number
      buffer.write(
          '<text x="${center.dx}" y="${center.dy - 25}" text-anchor="middle" font-family="system-ui, sans-serif" font-size="11" font-weight="bold" fill="$labelColor">$signNumber</text>');

      // Get planets in this house
      final planetsInHouse = getPlanetsInHouse(h)
          .map((info) => _getPlanetAbbr(info.planet))
          .toList();
      // Check node placements manually since they are not in planets map
      final rahuHouse = houses.getHouseForLongitude(rahu.longitude);
      if (rahuHouse == h) planetsInHouse.add('Ra');
      final ketuHouse = houses.getHouseForLongitude(ketu.longitude);
      if (ketuHouse == h) planetsInHouse.add('Ke');

      // Draw lagna marker on the 1st house
      if (h == 1) {
        buffer.write(
            '<text x="${center.dx}" y="${center.dy - 40}" text-anchor="middle" font-family="system-ui, sans-serif" font-size="10" font-weight="bold" fill="$ascColor">ASC</text>');
      }

      // Draw planets
      if (planetsInHouse.isNotEmpty) {
        var py = center.dy;
        for (var pIdx = 0; pIdx < planetsInHouse.length; pIdx += 3) {
          final chunk = planetsInHouse
              .sublist(
                  pIdx,
                  pIdx + 3 > planetsInHouse.length
                      ? planetsInHouse.length
                      : pIdx + 3)
              .join(' ');
          buffer.write(
              '<text x="${center.dx}" y="$py" text-anchor="middle" font-family="system-ui, sans-serif" font-size="13" font-weight="bold" fill="$textColor">$chunk</text>');
          py += 16.0;
        }
      }
    }
  }

  String _getPlanetAbbr(Planet planet) {
    return switch (planet) {
      Planet.sun => 'Su',
      Planet.moon => 'Mo',
      Planet.mars => 'Ma',
      Planet.mercury => 'Me',
      Planet.jupiter => 'Ju',
      Planet.venus => 'Ve',
      Planet.saturn => 'Sa',
      Planet.meanNode || Planet.trueNode => 'Ra',
      Planet.ketu => 'Ke',
      _ => planet.displayName.substring(0, 2),
    };
  }
}

/// A Flutter [CustomPainter] that draws a traditional South Indian style Rashi chart.
class SouthIndianChartPainter extends CustomPainter {
  /// The vedic chart data.
  final VedicChart chart;

  /// Line and border paint color.
  final Color strokeColor;

  /// Text color for signs and planet names.
  final Color textColor;

  /// Text color for labels/sign titles.
  final Color labelColor;

  /// Color used to highlight the Ascendant.
  final Color ascendantColor;

  SouthIndianChartPainter({
    required this.chart,
    this.strokeColor = const Color(0xFF1E293B),
    this.textColor = const Color(0xFF0F172A),
    this.labelColor = const Color(0xFF64748B),
    this.ascendantColor = const Color(0xFFF59E0B),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Draw main frame outer boundary
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // 4x4 Grid paths
    final stepX = size.width / 4;
    final stepY = size.height / 4;

    for (var i = 1; i < 4; i++) {
      canvas.drawLine(
          Offset(i * stepX, 0), Offset(i * stepX, size.height), paint);
      canvas.drawLine(
          Offset(0, i * stepY), Offset(size.width, i * stepY), paint);
    }

    // Highlight center box
    paint.strokeWidth = 3.0;
    canvas.drawRect(Rect.fromLTWH(stepX, stepY, stepX * 2, stepY * 2), paint);

    // Coordinate mapping for South Indian Signs
    final gridCoords = [
      Offset(1 * stepX, 0 * stepY), // Aries (0)
      Offset(2 * stepX, 0 * stepY), // Taurus (1)
      Offset(3 * stepX, 0 * stepY), // Gemini (2)
      Offset(3 * stepX, 1 * stepY), // Cancer (3)
      Offset(3 * stepX, 2 * stepY), // Leo (4)
      Offset(3 * stepX, 3 * stepY), // Virgo (5)
      Offset(2 * stepX, 3 * stepY), // Libra (6)
      Offset(1 * stepX, 3 * stepY), // Scorpio (7)
      Offset(0 * stepX, 3 * stepY), // Sagittarius (8)
      Offset(0 * stepX, 2 * stepY), // Capricorn (9)
      Offset(0 * stepX, 1 * stepY), // Aquarius (10)
      Offset(0 * stepX, 0 * stepY), // Pisces (11)
    ];

    final signAbbr = [
      'Ar',
      'Ta',
      'Ge',
      'Ca',
      'Le',
      'Vi',
      'Li',
      'Sc',
      'Sa',
      'Cp',
      'Aq',
      'Pi'
    ];

    // Map each planet to its zodiac sign
    final planetsInSign = List.generate(12, (_) => <String>[]);
    for (final info in chart.planets.values) {
      final signIndex = (info.longitude / 30).floor() % 12;
      planetsInSign[signIndex].add(_getAbbreviation(info.planet));
    }
    final rahuSign = (chart.rahu.longitude / 30).floor() % 12;
    planetsInSign[rahuSign].add('Ra');
    final ketuSign = (chart.ketu.longitude / 30).floor() % 12;
    planetsInSign[ketuSign].add('Ke');

    final ascSign = (chart.ascendant / 30).floor() % 12;

    // Draw info inside sign cells
    for (var rashiIdx = 0; rashiIdx < 12; rashiIdx++) {
      final offset = gridCoords[rashiIdx];

      // Draw sign label
      final textPainter = TextPainter(
        text: TextSpan(
          text: signAbbr[rashiIdx],
          style: TextStyle(
              color: labelColor, fontSize: 11, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, offset + const Offset(6, 6));

      // Draw ASC marker
      if (rashiIdx == ascSign) {
        final ascPainter = TextPainter(
          text: TextSpan(
            text: 'ASC',
            style: TextStyle(
                color: ascendantColor,
                fontSize: 10,
                fontWeight: FontWeight.bold),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        ascPainter.paint(canvas, offset + Offset(stepX - 30, 6));
      }

      // Draw planets
      final plList = planetsInSign[rashiIdx];
      var py = offset.dy + 26.0;
      for (var pIdx = 0; pIdx < plList.length; pIdx += 2) {
        final pair = plList
            .sublist(pIdx, pIdx + 2 > plList.length ? plList.length : pIdx + 2)
            .join(' ');
        final planetsPainter = TextPainter(
          text: TextSpan(
            text: pair,
            style: TextStyle(
                color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        planetsPainter.paint(canvas, Offset(offset.dx + 8, py));
        py += 14.0;
      }
    }

    // Write Rashi text in the center
    final centerTitlePainter = TextPainter(
      text: TextSpan(
        text: 'RASHI CHART',
        style: TextStyle(
            color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    centerTitlePainter.paint(
      canvas,
      Offset(
        size.width / 2 - centerTitlePainter.width / 2,
        size.height / 2 - 25,
      ),
    );

    final centerSubPainter = TextPainter(
      text: TextSpan(
        text: 'Lagna: ${chart.houses.ascendantSign}',
        style: TextStyle(color: labelColor, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    centerSubPainter.paint(
      canvas,
      Offset(
        size.width / 2 - centerSubPainter.width / 2,
        size.height / 2 + 5,
      ),
    );
  }

  String _getAbbreviation(Planet planet) {
    return switch (planet) {
      Planet.sun => 'Su',
      Planet.moon => 'Mo',
      Planet.mars => 'Ma',
      Planet.mercury => 'Me',
      Planet.jupiter => 'Ju',
      Planet.venus => 'Ve',
      Planet.saturn => 'Sa',
      Planet.meanNode || Planet.trueNode => 'Ra',
      Planet.ketu => 'Ke',
      _ => planet.displayName.substring(0, 2),
    };
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// A Flutter [CustomPainter] that draws a traditional North Indian style diamond chart.
class NorthIndianChartPainter extends CustomPainter {
  /// The vedic chart data.
  final VedicChart chart;

  /// Line and border paint color.
  final Color strokeColor;

  /// Text color for sign numbers and planet names.
  final Color textColor;

  /// Text color for labels/sign titles.
  final Color labelColor;

  /// Color used to highlight the Ascendant.
  final Color ascendantColor;

  NorthIndianChartPainter({
    required this.chart,
    this.strokeColor = const Color(0xFF1E293B),
    this.textColor = const Color(0xFF0F172A),
    this.labelColor = const Color(0xFF64748B),
    this.ascendantColor = const Color(0xFFF59E0B),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Draw main frame outer boundary
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw Diagonals
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);

    // Draw Inner Diamond
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(0, size.height / 2)
      ..close();
    canvas.drawPath(path, paint);

    // Define center points for each of the 12 houses to place text relative to size
    final stepX = size.width / 500.0;
    final stepY = size.height / 500.0;
    final centers = [
      Offset(250.0 * stepX, 120.0 * stepY), // House 1
      Offset(120.0 * stepX, 60.0 * stepY), // House 2
      Offset(60.0 * stepX, 120.0 * stepY), // House 3
      Offset(125.0 * stepX, 250.0 * stepY), // House 4
      Offset(60.0 * stepX, 380.0 * stepY), // House 5
      Offset(120.0 * stepX, 440.0 * stepY), // House 6
      Offset(250.0 * stepX, 380.0 * stepY), // House 7
      Offset(380.0 * stepX, 440.0 * stepY), // House 8
      Offset(440.0 * stepX, 380.0 * stepY), // House 9
      Offset(375.0 * stepX, 250.0 * stepY), // House 10
      Offset(440.0 * stepX, 120.0 * stepY), // House 11
      Offset(380.0 * stepX, 60.0 * stepY), // House 12
    ];

    final ascSign = (chart.ascendant / 30).floor() % 12;

    for (var h = 1; h <= 12; h++) {
      final center = centers[h - 1];
      final signNumber = ((ascSign + h - 1) % 12) + 1;

      // Draw sign number
      final numPainter = TextPainter(
        text: TextSpan(
          text: '$signNumber',
          style: TextStyle(
              color: labelColor, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      numPainter.paint(canvas, center - Offset(numPainter.width / 2, 22));

      // Get planets in this house
      final planetsInHouse = chart
          .getPlanetsInHouse(h)
          .map((info) => _getAbbreviation(info.planet))
          .toList();
      final rahuHouse = chart.houses.getHouseForLongitude(chart.rahu.longitude);
      if (rahuHouse == h) planetsInHouse.add('Ra');
      final ketuHouse = chart.houses.getHouseForLongitude(chart.ketu.longitude);
      if (ketuHouse == h) planetsInHouse.add('Ke');

      // Draw ASC
      if (h == 1) {
        final ascPainter = TextPainter(
          text: TextSpan(
            text: 'ASC',
            style: TextStyle(
                color: ascendantColor,
                fontSize: 9,
                fontWeight: FontWeight.bold),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        ascPainter.paint(canvas, center - Offset(ascPainter.width / 2, 34));
      }

      // Draw planets
      if (planetsInHouse.isNotEmpty) {
        var py = center.dy;
        for (var pIdx = 0; pIdx < planetsInHouse.length; pIdx += 3) {
          final chunk = planetsInHouse
              .sublist(
                  pIdx,
                  pIdx + 3 > planetsInHouse.length
                      ? planetsInHouse.length
                      : pIdx + 3)
              .join(' ');
          final plPainter = TextPainter(
            text: TextSpan(
              text: chunk,
              style: TextStyle(
                  color: textColor, fontSize: 11, fontWeight: FontWeight.bold),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          plPainter.paint(canvas, Offset(center.dx - plPainter.width / 2, py));
          py += 13.0;
        }
      }
    }
  }

  String _getAbbreviation(Planet planet) {
    return switch (planet) {
      Planet.sun => 'Su',
      Planet.moon => 'Mo',
      Planet.mars => 'Ma',
      Planet.mercury => 'Me',
      Planet.jupiter => 'Ju',
      Planet.venus => 'Ve',
      Planet.saturn => 'Sa',
      Planet.meanNode || Planet.trueNode => 'Ra',
      Planet.ketu => 'Ke',
      _ => planet.displayName.substring(0, 2),
    };
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
