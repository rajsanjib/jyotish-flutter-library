import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:jyotish/src/models/geographic_location.dart';
import 'package:jyotish/src/muhurta/vedic_time.dart';

/// A controller to manage or observe changes in a [VedicDigitalClock].
class VedicClockController extends ChangeNotifier {
  VedicTime? _currentTime;
  bool _isLoading = true;
  String? _errorMessage;

  VedicTime? get currentTime => _currentTime;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void updateTime(VedicTime? time, {bool isLoading = false, String? error}) {
    _currentTime = time;
    _isLoading = isLoading;
    _errorMessage = error;
    notifyListeners();
  }
}

/// A Digital Vedic Clock that displays current Ghatis, Vighatis, and Liptas.
class VedicDigitalClock extends StatefulWidget {
  /// The location to compute Sunrise and Vedic time for.
  final GeographicLocation location;

  /// Function to resolve sunrise/sunset timings (typically `Jyotish().getSunriseSunset`).
  final Future<(DateTime? sunrise, DateTime? sunset)> Function({
    required DateTime date,
    required GeographicLocation location,
  }) getSunriseSunset;

  /// Optional custom controller. If not provided, an internal one will be created.
  final VedicClockController? controller;

  /// Text style for the main digital readout.
  final TextStyle? digitStyle;

  /// Text style for labels like "Sunrise" or "Local Time".
  final TextStyle? labelStyle;

  /// Custom padding.
  final EdgeInsetsGeometry padding;

  /// Custom background decoration.
  final Decoration? decoration;

  /// Whether to show the local standard clock time alongside the Vedic time.
  final bool showLocalTime;

  /// Whether to show the Sunrise and Sunset times calculated for the day.
  final bool showSunriseSunset;

  const VedicDigitalClock({
    super.key,
    required this.location,
    required this.getSunriseSunset,
    this.controller,
    this.digitStyle,
    this.labelStyle,
    this.padding = const EdgeInsets.all(20),
    this.decoration,
    this.showLocalTime = true,
    this.showSunriseSunset = true,
  });

  @override
  State<VedicDigitalClock> createState() => _VedicDigitalClockState();
}

class _VedicDigitalClockState extends State<VedicDigitalClock> {
  late VedicClockController _clockController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _clockController = widget.controller ?? VedicClockController();
    _startClock();
  }

  @override
  void didUpdateWidget(covariant VedicDigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.location != oldWidget.location) {
      _timer?.cancel();
      _startClock();
    }
  }

  void _startClock() {
    _updateVedicTime();
    // Update every 500 milliseconds for responsive updates
    _timer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => _updateVedicTime(),
    );
  }

  Future<void> _updateVedicTime() async {
    try {
      final now = DateTime.now();
      final vTime = await VedicTime.calculate(
        time: now,
        location: widget.location,
        getSunriseSunset: widget.getSunriseSunset,
      );
      if (mounted) {
        _clockController.updateTime(vTime, isLoading: false);
      }
    } catch (e) {
      if (mounted) {
        _clockController.updateTime(
          null,
          isLoading: false,
          error: e.toString(),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (widget.controller == null) {
      _clockController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _clockController,
      builder: (context, _) {
        if (_clockController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_clockController.errorMessage != null) {
          return Center(
            child: Text(
              'Error calculating Vedic time:\n${_clockController.errorMessage}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }

        final vt = _clockController.currentTime;
        if (vt == null) {
          return const Center(child: Text('No Vedic time data available'));
        }

        final dStyle = widget.digitStyle ??
            const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              letterSpacing: 2,
            );

        final lStyle = widget.labelStyle ??
            const TextStyle(fontSize: 14, color: Colors.grey);

        return Container(
          padding: widget.padding,
          decoration: widget.decoration ??
              BoxDecoration(
                color: Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'VEDIC TIME',
                style: lStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              // G : V : L Readout
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(vt.ghati.toString().padLeft(2, '0'), style: dStyle),
                  Text('g', style: lStyle.copyWith(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    ':',
                    style: dStyle.copyWith(
                      color: dStyle.color?.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(vt.vighati.toString().padLeft(2, '0'), style: dStyle),
                  Text('v', style: lStyle.copyWith(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    ':',
                    style: dStyle.copyWith(
                      color: dStyle.color?.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(vt.lipta.toString().padLeft(2, '0'), style: dStyle),
                  Text('l', style: lStyle.copyWith(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 15),
              if (widget.showLocalTime) ...[
                Text(
                  'Local Time: ${DateTime.now().toLocal().toString().substring(11, 19)}',
                  style: lStyle,
                ),
                const SizedBox(height: 5),
              ],
              if (widget.showSunriseSunset) ...[
                Text(
                  'Sunrise: ${vt.currentSunrise.toLocal().toString().substring(11, 16)} | Next Sunrise: ${vt.nextSunrise.toLocal().toString().substring(11, 16)}',
                  style: lStyle.copyWith(fontSize: 12),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// An Analog Vedic Clock showing a 60-Ghati dial (circular clockface).
class VedicAnalogClock extends StatefulWidget {
  /// The location to compute Sunrise and Vedic time for.
  final GeographicLocation location;

  /// Function to resolve sunrise/sunset timings (typically `Jyotish().getSunriseSunset`).
  final Future<(DateTime? sunrise, DateTime? sunset)> Function({
    required DateTime date,
    required GeographicLocation location,
  }) getSunriseSunset;

  /// Width and height of the clock widget.
  final double size;

  /// Color of the clock face.
  final Color faceColor;

  /// Color of the clock dial borders and ticks.
  final Color dialColor;

  /// Color of the Ghati (Hour) hand.
  final Color ghatiHandColor;

  /// Color of the Vighati (Minute) hand.
  final Color vighatiHandColor;

  /// Text style for Ghati digits on the face.
  final TextStyle? numberStyle;

  const VedicAnalogClock({
    super.key,
    required this.location,
    required this.getSunriseSunset,
    this.size = 280,
    this.faceColor = const Color(0xFF0F0F1E),
    this.dialColor = const Color(0xFF6366F1),
    this.ghatiHandColor = const Color(0xFFEC4899),
    this.vighatiHandColor = const Color(0xFF06B6D4),
    this.numberStyle,
  });

  @override
  State<VedicAnalogClock> createState() => _VedicAnalogClockState();
}

class _VedicAnalogClockState extends State<VedicAnalogClock> {
  VedicTime? _currentTime;
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startClock();
  }

  @override
  void didUpdateWidget(covariant VedicAnalogClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.location != oldWidget.location) {
      _timer?.cancel();
      _startClock();
    }
  }

  void _startClock() {
    _updateTime();
    // Update every 250ms for smooth hand movements
    _timer = Timer.periodic(
      const Duration(milliseconds: 250),
      (_) => _updateTime(),
    );
  }

  Future<void> _updateTime() async {
    try {
      final now = DateTime.now();
      final vt = await VedicTime.calculate(
        time: now,
        location: widget.location,
        getSunriseSunset: widget.getSunriseSunset,
      );
      if (mounted) {
        setState(() {
          _currentTime = vt;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Center(
          child: Text(
            'Clock Error:\n$_errorMessage',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      );
    }

    final vt = _currentTime;
    if (vt == null) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: const Center(child: Text('No Time Data')),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _VedicClockPainter(
            time: vt,
            faceColor: widget.faceColor,
            dialColor: widget.dialColor,
            ghatiHandColor: widget.ghatiHandColor,
            vighatiHandColor: widget.vighatiHandColor,
            numberStyle: widget.numberStyle ??
                const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 12),
        // Live Ghati read-out under clock face
        Text(
          vt.format(includeLipta: true),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

class _VedicClockPainter extends CustomPainter {
  final VedicTime time;
  final Color faceColor;
  final Color dialColor;
  final Color ghatiHandColor;
  final Color vighatiHandColor;
  final TextStyle numberStyle;

  _VedicClockPainter({
    required this.time,
    required this.faceColor,
    required this.dialColor,
    required this.ghatiHandColor,
    required this.vighatiHandColor,
    required this.numberStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final center = Offset(centerX, centerY);
    final radius = math.min(centerX, centerY);

    // 1. Draw outer background face
    final fillPaint = Paint()
      ..color = faceColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, fillPaint);

    // 2. Draw border
    final borderPaint = Paint()
      ..color = dialColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawCircle(center, radius - 2, borderPaint);

    // 3. Draw ticks (60 Ghati subdivisions)
    final tickPaint = Paint()..style = PaintingStyle.stroke;

    for (var i = 0; i < 60; i++) {
      // 0 ghati points directly UP (-90 degrees, i.e. -pi/2)
      final angle = (i * 6.0) * math.pi / 180.0 - (math.pi / 2.0);
      final isMajor = i % 5 == 0;

      final tickLength = isMajor ? 12.0 : 6.0;
      tickPaint.color = isMajor ? dialColor : dialColor.withValues(alpha: 0.4);
      tickPaint.strokeWidth = isMajor ? 2.5 : 1.2;

      final startOffset = Offset(
        centerX + (radius - tickLength - 4) * math.cos(angle),
        centerY + (radius - tickLength - 4) * math.sin(angle),
      );
      final endOffset = Offset(
        centerX + (radius - 4) * math.cos(angle),
        centerY + (radius - 4) * math.sin(angle),
      );

      canvas.drawLine(startOffset, endOffset, tickPaint);

      // Draw Ghati numbers (0, 5, 10... 55)
      if (isMajor) {
        final textPainter = TextPainter(
          text: TextSpan(text: i == 0 ? '60' : '$i', style: numberStyle),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        // Offset slightly inward to prevent clipping
        final textRadius = radius - 30;
        final textX =
            centerX + textRadius * math.cos(angle) - textPainter.width / 2;
        final textY =
            centerY + textRadius * math.sin(angle) - textPainter.height / 2;
        textPainter.paint(canvas, Offset(textX, textY));
      }
    }

    // 4. Draw Vighati Hand (cyan/secondary - thinner and longer)
    final vighatiHandPaint = Paint()
      ..color = vighatiHandColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    // Smooth vighati angle calculation including liptas
    final vighatiFraction = (time.vighati + (time.lipta / 60.0));
    final vighatiAngle =
        (vighatiFraction * 6.0) * math.pi / 180.0 - (math.pi / 2.0);
    final vighatiHandLength = radius * 0.75;
    canvas.drawLine(
      center,
      Offset(
        centerX + vighatiHandLength * math.cos(vighatiAngle),
        centerY + vighatiHandLength * math.sin(vighatiAngle),
      ),
      vighatiHandPaint,
    );

    // 5. Draw Ghati Hand (pink/primary - thicker and shorter)
    final ghatiHandPaint = Paint()
      ..color = ghatiHandColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.5;

    // Ghati hand rotates 360 degrees for 60 Ghatis (6 degrees per Ghati)
    // Interpolated with vighatis for smooth rotation
    final ghatiAngle =
        (time.totalGhatis * 6.0) * math.pi / 180.0 - (math.pi / 2.0);
    final ghatiHandLength = radius * 0.55;
    canvas.drawLine(
      center,
      Offset(
        centerX + ghatiHandLength * math.cos(ghatiAngle),
        centerY + ghatiHandLength * math.sin(ghatiAngle),
      ),
      ghatiHandPaint,
    );

    // 6. Draw center spindle pin
    final centerPinPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 6.0, centerPinPaint);

    final centerPinBorderPaint = Paint()
      ..color = ghatiHandColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, 6.0, centerPinBorderPaint);
  }

  @override
  bool shouldRepaint(covariant _VedicClockPainter oldDelegate) {
    return oldDelegate.time.totalGhatis != time.totalGhatis ||
        oldDelegate.time.vighati != time.vighati ||
        oldDelegate.time.lipta != time.lipta;
  }
}
