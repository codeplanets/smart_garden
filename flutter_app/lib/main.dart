import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartGarden',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _channel = WebSocketChannel.connect(
    Uri.parse('ws://localhost:8000/ws'),
  );
  
  Map<String, dynamic> _currentData = {
    'temperature': 0.0,
    'humidity': 0.0,
    'soilMoisture': 0,
    'lightLevel': 0,
    'pumpStatus': false,
    'ledStatus': false,
    'fanStatus': false,
  };

  Future<void> _controlDevice(String device, String action) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/control/$device/$action'),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to control device');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _channel.stream.listen((message) {
      setState(() {
        _currentData = json.decode(message);
      });
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartGarden'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSensorCard(),
              const SizedBox(height: 20),
              _buildControlPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSensorCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sensor Readings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSensorRow(
              'Temperature',
              '${_currentData['temperature']}°C',
              Icons.thermostat,
            ),
            _buildSensorRow(
              'Humidity',
              '${_currentData['humidity']}%',
              Icons.water_drop,
            ),
            _buildSensorRow(
              'Soil Moisture',
              '${_currentData['soilMoisture']}%',
              Icons.grass,
            ),
            _buildSensorRow(
              'Light Level',
              '${_currentData['lightLevel']}%',
              Icons.wb_sunny,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(label),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
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
            const Text(
              'Control Panel',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildControlSwitch(
              'Water Pump',
              _currentData['pumpStatus'],
              (value) => _controlDevice('pump', value ? 'on' : 'off'),
              Icons.water,
            ),
            _buildControlSwitch(
              'LED Light',
              _currentData['ledStatus'],
              (value) => _controlDevice('led', value ? 'on' : 'off'),
              Icons.lightbulb,
            ),
            _buildControlSwitch(
              'Fan',
              _currentData['fanStatus'],
              (value) => _controlDevice('fan', value ? 'on' : 'off'),
              Icons.air,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlSwitch(
    String label,
    bool value,
    Function(bool) onChanged,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(label),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
