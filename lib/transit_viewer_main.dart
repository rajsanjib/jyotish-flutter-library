import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Mock models for web compatibility
class MockPlanet {
  final String name;
  final String symbol;
  final Color color;

  const MockPlanet(this.name, this.symbol, this.color);

  static const sun = MockPlanet('Sun', '☉', Colors.orange);
  static const moon = MockPlanet('Moon', '☽', Colors.blueGrey);
  static const mercury = MockPlanet('Mercury', '☿', Colors.green);
  static const venus = MockPlanet('Venus', '♀', Colors.pink);
  static const mars = MockPlanet('Mars', '♂', Colors.red);
  static const jupiter = MockPlanet('Jupiter', '♃', Colors.amber);
  static const saturn = MockPlanet('Saturn', '♄', Colors.brown);

  static const all = [sun, moon, mercury, venus, mars, jupiter, saturn];
}

class MockPosition {
  final double longitude;
  final bool isRetrograde;
  final double speed;

  MockPosition({
    required this.longitude,
    required this.isRetrograde,
    required this.speed,
  });

  String get zodiacSign {
    const signs = [
      'Aries',
      'Taurus',
      'Gemini',
      'Cancer',
      'Leo',
      'Virgo',
      'Libra',
      'Scorpio',
      'Sagittarius',
      'Capricorn',
      'Aquarius',
      'Pisces'
    ];
    return signs[(longitude / 30).floor()];
  }

  double get positionInSign => longitude % 30;

  String get nakshatra {
    const nakshatras = [
      'Ashwini',
      'Bharani',
      'Krittika',
      'Rohini',
      'Mrigashira',
      'Ardra',
      'Punarvasu',
      'Pushya',
      'Ashlesha',
      'Magha',
      'Purva Phalguni',
      'Uttara Phalguni',
      'Hasta',
      'Chitra',
      'Swati',
      'Vishakha',
      'Anuradha',
      'Jyeshtha',
      'Mula',
      'Purva Ashadha',
      'Uttara Ashadha',
      'Shravana',
      'Dhanishta',
      'Shatabhisha',
      'Purva Bhadrapada',
      'Uttara Bhadrapada',
      'Revati'
    ];
    final index = ((longitude / (360 / 27)).floor()) % 27;
    return nakshatras[index];
  }

  int get nakshatraPada {
    final positionInNakshatra = longitude % (360 / 27);
    return ((positionInNakshatra / (360 / 27 / 4)).floor() + 1).clamp(1, 4);
  }

  String get formattedPosition {
    final degrees = positionInSign.floor();
    final minutes = ((positionInSign - degrees) * 60).floor();
    return '$degrees° $zodiacSign $minutes\'';
  }
}

void main() {
  runApp(const TransitViewerApp());
}

class TransitViewerApp extends StatelessWidget {
  const TransitViewerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Planetary Transit Viewer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const TransitViewerScreen(),
    );
  }
}

class TransitViewerScreen extends StatefulWidget {
  const TransitViewerScreen({super.key});

  @override
  State<TransitViewerScreen> createState() => _TransitViewerScreenState();
}

class _TransitViewerScreenState extends State<TransitViewerScreen> {
  final Jyotish _jyotish = Jyotish();
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _error;

  // Date range: 1 year from today
  late DateTime _startDate;
  late DateTime _endDate;
  late DateTime _currentDate;
  double _sliderValue = 0.0;

  // Planet positions
  Map<Planet, PlanetPosition>? _planetPositions;
  Planet? _selectedPlanet;

  // Location (default to Greenwich for universal time)
  final GeographicLocation _location = GeographicLocation(
    latitude: 0.0,
    longitude: 0.0,
  );

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
    _endDate = _startDate.add(const Duration(days: 365));
    _currentDate = _startDate;
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _jyotish.initialize();
      setState(() {
        _isInitialized = true;
      });
      await _calculatePositions();
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _calculatePositions() async {
    if (!_isInitialized) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final flags = CalculationFlags(
        siderealMode: SiderealMode.lahiri,
        calculateSpeed: true,
      );

      final positions = await _jyotish.getAllPlanetPositions(
        dateTime: _currentDate,
        location: _location,
        flags: flags,
      );

      setState(() {
        _planetPositions = positions;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Calculation failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSliderChanged(double value) {
    setState(() {
      _sliderValue = value;
      // Calculate date based on slider value (0.0 to 1.0 over 1 year)
      final daysDiff = (_endDate.difference(_startDate).inDays * value).round();
      _currentDate = _startDate.add(Duration(days: daysDiff));
    });
    _calculatePositions();
  }

  void _onPlanetTapped(Planet planet) {
    setState(() {
      _selectedPlanet = _selectedPlanet == planet ? null : planet;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: _isLoading && !_isInitialized
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Initializing Swiss Ephemeris...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.redAccent,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _initialize,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Header
                    _buildHeader(),
                    // Chart area
                    Expanded(
                      child: Center(
                        child: _planetPositions == null
                            ? const CircularProgressIndicator()
                            : _buildChart(),
                      ),
                    ),
                    // Date slider
                    _buildDateSlider(),
                    // Planet details
                    if (_selectedPlanet != null) _buildPlanetDetails(),
                  ],
                ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple.shade900,
            Colors.indigo.shade900,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const Text(
              '🌟 Planetary Transit Viewer',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sidereal (Vedic) Positions - Lahiri Ayanamsa',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _formatDate(_currentDate),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size =
            math.min(constraints.maxWidth, constraints.maxHeight) * 0.85;
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: ZodiacChartPainter(
              planetPositions: _planetPositions!,
              selectedPlanet: _selectedPlanet,
              onPlanetTap: _onPlanetTapped,
            ),
            child: GestureDetector(
              onTapDown: (details) {
                _handleChartTap(details.localPosition, size);
              },
            ),
          ),
        );
      },
    );
  }

  void _handleChartTap(Offset localPosition, double size) {
    final center = Offset(size / 2, size / 2);
    final tapOffset = localPosition - center;
    final distance = tapOffset.distance;

    // Check if tap is within planet zone
    if (distance < size * 0.4 && distance > size * 0.15) {
      // Find which planet was tapped
      for (final entry in _planetPositions!.entries) {
        final planet = entry.key;
        final position = entry.value;
        final angle = (position.longitude - 90) * math.pi / 180;
        final planetRadius = size * 0.3;
        final planetX = center.dx + planetRadius * math.cos(angle);
        final planetY = center.dy + planetRadius * math.sin(angle);
        final planetOffset = Offset(planetX, planetY);

        if ((localPosition - planetOffset).distance < 20) {
          _onPlanetTapped(planet);
          break;
        }
      }
    }
  }

  Widget _buildDateSlider() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDateShort(_startDate),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                'Slide to travel through time',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
              Text(
                _formatDateShort(_endDate),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Colors.deepPurple.shade400,
              inactiveTrackColor: Colors.deepPurple.shade900,
              thumbColor: Colors.deepPurple.shade300,
              overlayColor: Colors.deepPurple.shade200.withOpacity(0.3),
              trackHeight: 6,
            ),
            child: Slider(
              value: _sliderValue,
              onChanged: _onSliderChanged,
              min: 0.0,
              max: 1.0,
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Calculating...',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlanetDetails() {
    if (_selectedPlanet == null || _planetPositions == null) {
      return const SizedBox.shrink();
    }

    final position = _planetPositions![_selectedPlanet]!;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple.shade700.withOpacity(0.9),
            Colors.indigo.shade700.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                _getPlanetEmoji(_selectedPlanet!),
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedPlanet!.displayName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      position.isRetrograde ? 'Retrograde ℞' : 'Direct',
                      style: TextStyle(
                        fontSize: 14,
                        color: position.isRetrograde
                            ? Colors.orange.shade300
                            : Colors.green.shade300,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => setState(() => _selectedPlanet = null),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 24),
          _buildDetailRow('Sign', position.zodiacSign),
          _buildDetailRow('Position', position.formattedPosition),
          _buildDetailRow(
              'Degree', '${position.longitude.toStringAsFixed(4)}°'),
          _buildDetailRow('Nakshatra',
              '${position.nakshatra} (Pada ${position.nakshatraPada})'),
          _buildDetailRow(
              'Speed', '${position.longitudeSpeed.toStringAsFixed(4)}°/day'),
          _buildDetailRow(
              'Distance', '${position.distance.toStringAsFixed(6)} AU'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _formatDateShort(DateTime date) {
    return '${date.day} ${_getMonthShort(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  String _getMonthShort(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  String _getPlanetEmoji(Planet planet) {
    switch (planet) {
      case Planet.sun:
        return '☉';
      case Planet.moon:
        return '☽';
      case Planet.mercury:
        return '☿';
      case Planet.venus:
        return '♀';
      case Planet.mars:
        return '♂';
      case Planet.jupiter:
        return '♃';
      case Planet.saturn:
        return '♄';
      case Planet.uranus:
        return '♅';
      case Planet.neptune:
        return '♆';
      case Planet.pluto:
        return '♇';
      default:
        return '●';
    }
  }
}

class ZodiacChartPainter extends CustomPainter {
  final Map<Planet, PlanetPosition> planetPositions;
  final Planet? selectedPlanet;
  final Function(Planet) onPlanetTap;

  ZodiacChartPainter({
    required this.planetPositions,
    this.selectedPlanet,
    required this.onPlanetTap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw zodiac circle
    _drawZodiacCircle(canvas, center, radius);

    // Draw zodiac signs
    _drawZodiacSigns(canvas, center, radius);

    // Draw planets
    _drawPlanets(canvas, center, radius);
  }

  void _drawZodiacCircle(Canvas canvas, Offset center, double radius) {
    // Outer circle
    final outerPaint = Paint()
      ..color = Colors.deepPurple.shade800.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius * 0.9, outerPaint);

    // Inner circle
    final innerPaint = Paint()
      ..color = Colors.deepPurple.shade900.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius * 0.5, innerPaint);

    // Middle circle (planet zone)
    final middlePaint = Paint()
      ..color = Colors.indigo.shade800.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.7, middlePaint);

    // Draw 12 divisions (30° each)
    final divisionPaint = Paint()
      ..color = Colors.deepPurple.shade700.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 12; i++) {
      final angle = (i * 30 - 90) * math.pi / 180;
      final startX = center.dx + radius * 0.5 * math.cos(angle);
      final startY = center.dy + radius * 0.5 * math.sin(angle);
      final endX = center.dx + radius * 0.9 * math.cos(angle);
      final endY = center.dy + radius * 0.9 * math.sin(angle);
      canvas.drawLine(
          Offset(startX, startY), Offset(endX, endY), divisionPaint);
    }
  }

  void _drawZodiacSigns(Canvas canvas, Offset center, double radius) {
    const signs = [
      '♈', // Aries
      '♉', // Taurus
      '♊', // Gemini
      '♋', // Cancer
      '♌', // Leo
      '♍', // Virgo
      '♎', // Libra
      '♏', // Scorpio
      '♐', // Sagittarius
      '♑', // Capricorn
      '♒', // Aquarius
      '♓', // Pisces
    ];

    const signNames = [
      'Aries',
      'Taurus',
      'Gemini',
      'Cancer',
      'Leo',
      'Virgo',
      'Libra',
      'Scorpio',
      'Sagittarius',
      'Capricorn',
      'Aquarius',
      'Pisces',
    ];

    for (int i = 0; i < 12; i++) {
      final angle = ((i * 30 + 15) - 90) * math.pi / 180;

      // Sign symbol
      final symbolX = center.dx + radius * 0.8 * math.cos(angle);
      final symbolY = center.dy + radius * 0.8 * math.sin(angle);

      final symbolPainter = TextPainter(
        text: TextSpan(
          text: signs[i],
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white70,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      symbolPainter.layout();
      symbolPainter.paint(
        canvas,
        Offset(symbolX - symbolPainter.width / 2,
            symbolY - symbolPainter.height / 2),
      );

      // Sign name
      final nameX = center.dx + radius * 0.65 * math.cos(angle);
      final nameY = center.dy + radius * 0.65 * math.sin(angle);

      final namePainter = TextPainter(
        text: TextSpan(
          text: signNames[i],
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white38,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      namePainter.layout();
      namePainter.paint(
        canvas,
        Offset(nameX - namePainter.width / 2, nameY - namePainter.height / 2),
      );
    }
  }

  void _drawPlanets(Canvas canvas, Offset center, double radius) {
    for (final entry in planetPositions.entries) {
      final planet = entry.key;
      final position = entry.value;
      final isSelected = planet == selectedPlanet;

      // Calculate position on circle
      final angle = (position.longitude - 90) * math.pi / 180;
      final planetRadius = radius * 0.55;
      final x = center.dx + planetRadius * math.cos(angle);
      final y = center.dy + planetRadius * math.sin(angle);

      // Draw planet glow for selected
      if (isSelected) {
        final glowPaint = Paint()
          ..color = Colors.yellow.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
        canvas.drawCircle(Offset(x, y), 25, glowPaint);
      }

      // Draw planet circle
      final planetPaint = Paint()
        ..color = isSelected ? Colors.yellow.shade300 : _getPlanetColor(planet)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), isSelected ? 18 : 14, planetPaint);

      // Draw planet border
      final borderPaint = Paint()
        ..color = Colors.white.withOpacity(isSelected ? 0.9 : 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 3 : 2;
      canvas.drawCircle(Offset(x, y), isSelected ? 18 : 14, borderPaint);

      // Draw planet symbol
      final symbolPainter = TextPainter(
        text: TextSpan(
          text: _getPlanetSymbol(planet),
          style: TextStyle(
            fontSize: isSelected ? 16 : 14,
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      symbolPainter.layout();
      symbolPainter.paint(
        canvas,
        Offset(x - symbolPainter.width / 2, y - symbolPainter.height / 2),
      );

      // Draw retrograde indicator
      if (position.isRetrograde) {
        final retroPainter = TextPainter(
          text: const TextSpan(
            text: 'R',
            style: TextStyle(
              fontSize: 8,
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        retroPainter.layout();
        retroPainter.paint(canvas, Offset(x + 12, y - 12));
      }
    }
  }

  Color _getPlanetColor(Planet planet) {
    switch (planet) {
      case Planet.sun:
        return Colors.orange.shade400;
      case Planet.moon:
        return Colors.blue.shade200;
      case Planet.mercury:
        return Colors.green.shade400;
      case Planet.venus:
        return Colors.pink.shade300;
      case Planet.mars:
        return Colors.red.shade400;
      case Planet.jupiter:
        return Colors.amber.shade600;
      case Planet.saturn:
        return Colors.brown.shade400;
      case Planet.uranus:
        return Colors.cyan.shade400;
      case Planet.neptune:
        return Colors.blue.shade600;
      case Planet.pluto:
        return Colors.grey.shade600;
      default:
        return Colors.white;
    }
  }

  String _getPlanetSymbol(Planet planet) {
    switch (planet) {
      case Planet.sun:
        return '☉';
      case Planet.moon:
        return '☽';
      case Planet.mercury:
        return '☿';
      case Planet.venus:
        return '♀';
      case Planet.mars:
        return '♂';
      case Planet.jupiter:
        return '♃';
      case Planet.saturn:
        return '♄';
      case Planet.uranus:
        return '♅';
      case Planet.neptune:
        return '♆';
      case Planet.pluto:
        return '♇';
      default:
        return '●';
    }
  }

  @override
  bool shouldRepaint(ZodiacChartPainter oldDelegate) {
    return oldDelegate.planetPositions != planetPositions ||
        oldDelegate.selectedPlanet != selectedPlanet;
  }
}
