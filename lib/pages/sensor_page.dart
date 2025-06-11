import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import '../database/database_helper.dart';

class SensorScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const SensorScreen({Key? key, required this.user}) : super(key: key);

  @override
  _SensorScreenState createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _sensorHistory = [];
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  AccelerometerEvent? _currentAccelerometer;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  GyroscopeEvent? _currentGyroscope;
  bool _isRecording = false;
  Timer? _recordingTimer;

  @override
  void initState() {
    super.initState();
    _loadSensorHistory();
    _initializeSensors();
  }

  Future<void> _loadSensorHistory() async {
    final history = await _dbHelper.getRecentSensorData(widget.user['id'], limit: 50);
    setState(() {
      _sensorHistory = history;
    });
  }

  void _initializeSensors() {
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      setState(() {
        _currentAccelerometer = event;
      });
    });

    _gyroscopeSubscription = gyroscopeEvents.listen((event) {
      setState(() {
        _currentGyroscope = event;
      });
    });
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      _recordingTimer = Timer.periodic(Duration(seconds: 2), (timer) {
        if (!_isRecording) {
          timer.cancel();
          return;
        }
        
        if (_currentAccelerometer != null) {
          _dbHelper.insertSensorData({
            'user_id': widget.user['id'],
            'accelerometer_x': _currentAccelerometer!.x,
            'accelerometer_y': _currentAccelerometer!.y,
            'accelerometer_z': _currentAccelerometer!.z,
          });
          _loadSensorHistory();
        }
      });
    } else {
      _recordingTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sensor Data'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isRecording ? Icons.stop : Icons.play_arrow),
            onPressed: _toggleRecording,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Sensor Data
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.sensors, color: Colors.purple),
                        SizedBox(width: 8),
                        Text(
                          'Live Sensor Data',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _isRecording ? Colors.red : Colors.grey,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _isRecording ? 'RECORDING' : 'PAUSED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Accelerometer',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    if (_currentAccelerometer != null) ...[
                      _buildSensorRow('X', _currentAccelerometer!.x),
                      _buildSensorRow('Y', _currentAccelerometer!.y),
                      _buildSensorRow('Z', _currentAccelerometer!.z),
                    ] else
                      Text('No accelerometer data'),
                    
                    SizedBox(height: 16),
                    Text(
                      'Gyroscope',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    if (_currentGyroscope != null) ...[
                      _buildSensorRow('X', _currentGyroscope!.x),
                      _buildSensorRow('Y', _currentGyroscope!.y),
                      _buildSensorRow('Z', _currentGyroscope!.z),
                    ] else
                      Text('No gyroscope data'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Sensor History
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.history, color: Colors.purple),
                        SizedBox(width: 8),
                        Text(
                          'Sensor History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        TextButton(
                          onPressed: _loadSensorHistory,
                          child: Text('Refresh'),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    if (_sensorHistory.isEmpty)
                      Center(
                        child: Text(
                          'No sensor data recorded yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _sensorHistory.length > 10 ? 10 : _sensorHistory.length,
                        itemBuilder: (context, index) {
                          final data = _sensorHistory[index];
                          final timestamp = DateTime.parse(data['timestamp']);
                          
                          return Container(
                            margin: EdgeInsets.only(bottom: 8),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text('X: ${data['accelerometer_x']?.toStringAsFixed(2) ?? 'N/A'}'),
                                    ),
                                    Expanded(
                                      child: Text('Y: ${data['accelerometer_y']?.toStringAsFixed(2) ?? 'N/A'}'),
                                    ),
                                    Expanded(
                                      child: Text('Z: ${data['accelerometer_z']?.toStringAsFixed(2) ?? 'N/A'}'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorRow(String axis, double value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              '$axis:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  Container(
                    width: (value.abs() / 20.0).clamp(0.0, 1.0) * MediaQuery.of(context).size.width * 0.6,
                    height: 20,
                    decoration: BoxDecoration(
                      color: value >= 0 ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: Text(
              value.toStringAsFixed(2),
              style: TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _recordingTimer?.cancel();
    super.dispose();
  }
}