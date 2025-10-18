import 'package:flutter/material.dart';
import 'package:jyotish/jyotish.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jyotish Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const PlanetaryPositionsScreen(),
    );
  }
}

class PlanetaryPositionsScreen extends StatefulWidget {
  const PlanetaryPositionsScreen({super.key});

  @override
  State<PlanetaryPositionsScreen> createState() =>
      _PlanetaryPositionsScreenState();
}

class _PlanetaryPositionsScreenState extends State<PlanetaryPositionsScreen> {
  final Jyotish _jyotish = Jyotish();
  Map<Planet, PlanetPosition>? _positions;
  bool _isLoading = false;
  String? _error;
  bool _useSidereal = false;

  // Default location: Kathmandu, Nepal
  GeographicLocation _location = GeographicLocation(
    latitude: 27.7172,
    longitude: 85.3240,
    altitude: 1400,
  );

  DateTime _selectedDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initializeAndCalculate();
  }

  Future<void> _initializeAndCalculate() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _jyotish.initialize();
      await _calculatePositions();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _calculatePositions() async {
    try {
      final flags = _useSidereal
          ? CalculationFlags.siderealLahiri()
          : CalculationFlags.defaultFlags();

      final positions = await _jyotish.getAllPlanetPositions(
        dateTime: _selectedDateTime,
        location: _location,
        flags: flags,
      );

      setState(() {
        _positions = positions;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Jyotish - Planetary Positions'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Error: $_error',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildControlPanel(),
                      const SizedBox(height: 24),
                      _buildLocationInfo(),
                      const SizedBox(height: 24),
                      _buildPlanetList(),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _calculatePositions,
        tooltip: 'Recalculate',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Use Sidereal (Lahiri)'),
              subtitle: const Text('Toggle between Tropical and Sidereal'),
              value: _useSidereal,
              onChanged: (value) {
                setState(() {
                  _useSidereal = value;
                });
                _calculatePositions();
              },
            ),
            ListTile(
              title: const Text('Date & Time'),
              subtitle: Text(_selectedDateTime.toString().substring(0, 19)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDateTime,
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
                  );
                  if (time != null) {
                    setState(() {
                      _selectedDateTime = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                    _calculatePositions();
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(_location.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanetList() {
    if (_positions == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Planetary Positions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ..._positions!.entries.map((entry) {
              return _buildPlanetCard(entry.value);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanetCard(PlanetPosition position) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  position.planet.displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (position.isRetrograde)
                  Chip(
                    label: const Text('R'),
                    backgroundColor: Colors.orange[100],
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Position', position.formattedPositionDMS),
            _buildInfoRow(
                'Longitude', '${position.longitude.toStringAsFixed(6)}°'),
            _buildInfoRow(
                'Latitude', '${position.latitude.toStringAsFixed(6)}°'),
            _buildInfoRow(
                'Distance', '${position.distance.toStringAsFixed(6)} AU'),
            _buildInfoRow('Nakshatra',
                '${position.nakshatra} (Pada ${position.nakshatraPada})'),
            _buildInfoRow(
                'Speed', '${position.longitudeSpeed.toStringAsFixed(4)}°/day'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _jyotish.dispose();
    super.dispose();
  }
}
