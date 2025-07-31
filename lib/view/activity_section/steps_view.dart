import 'package:fitrack/common/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:fitrack/view/main_tab/maintab_view.dart';

class StepTrackerPage extends StatefulWidget {
  const StepTrackerPage({super.key});

  @override
  State<StepTrackerPage> createState() => _StepTrackerPageState();
}

class _StepTrackerPageState extends State<StepTrackerPage> {
  late Stream<StepCount> _stepCountStream;
  int _initialSteps = 0;
  int _currentSteps = 0;
  String _status = 'Initializing...';
  int _latestRawSteps = 0;

  String get _today => DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _requestPermissionAndStart();
  }

  Future<void> _requestPermissionAndStart() async {
    final permissionStatus = await Permission.activityRecognition.request();

    if (permissionStatus.isGranted) {
      await _loadSavedData();
      _startStepTracking();
    } else {
      setState(() {
        _status = 'Permission Denied';
      });
    }
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString('step_date') ?? _today;

    if (savedDate == _today) {
      _initialSteps = prefs.getInt('initial_steps') ?? 0;
    } else {
      _initialSteps = 0;
      await prefs.setString('step_date', _today);
      await prefs.setInt('initial_steps', 0);
    }
  }

  Future<void> _saveInitialStep(int steps) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('initial_steps', steps);
    await prefs.setString('step_date', _today);
  }

  void _startStepTracking() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(
      (StepCount event) {
        setState(() {
          _latestRawSteps = event.steps;
          if (_initialSteps == 0) {
            _initialSteps = event.steps;
            _saveInitialStep(_initialSteps);
          }
          _currentSteps = event.steps - _initialSteps;
          _status = 'Tracking steps...';
        });
      },
      onError: (error) {
        setState(() {
          _status = 'Step Count Error: $error';
        });
      },
    );
  }

  Future<void> _resetSteps() async {
    _initialSteps = _latestRawSteps;
    await _saveInitialStep(_initialSteps);
    setState(() {
      _currentSteps = 0;
      _status = 'Reset successful';
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const MainTabView(initialTab: 1),
          ),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Step Tracker',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: TColor.primaryColor1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainTabView(initialTab: 1),
                ),
                (route) => false,
              );
            },
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.directions_walk, size: 100, color: Colors.green),
              const SizedBox(height: 20),
              Text('Steps: $_currentSteps', style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 10),
              Text(_status),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _resetSteps,
                icon: const Icon(Icons.refresh),
                label: const Text("Reset Counter"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
