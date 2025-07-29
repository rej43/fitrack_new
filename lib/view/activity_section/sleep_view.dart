import 'package:flutter/material.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:fitrack/common/color_extension.dart';
// ignore_for_file: unused_import
import 'dart:async';

class SleepView extends StatefulWidget {
  const SleepView({super.key});

  @override
  State<SleepView> createState() => _SleepViewState();
}

class _SleepViewState extends State<SleepView> {
  DateTime? _sleepStart;
  DateTime? _sleepEnd;
  Duration? _lastSleepDuration;
  bool _isSleeping = false;

  void _toggleSleep() {
    setState(() {
      if (!_isSleeping) {
        _sleepStart = DateTime.now();
        _sleepEnd = null;
        _lastSleepDuration = null;
        _isSleeping = true;
      } else {
        _sleepEnd = DateTime.now();
        if (_sleepStart != null) {
          _lastSleepDuration = _sleepEnd!.difference(_sleepStart!);
        }
        _isSleeping = false;
      }
    });
  }

  double get _progress {
    if (_lastSleepDuration == null) return 0;
    // Recommended sleep: 8 hours
    double hours = _lastSleepDuration!.inMinutes / 60.0;
    return (hours / 8.0).clamp(0, 1);
  }

  String get _sleepDurationText {
    if (_lastSleepDuration == null) return '--';
    int h = _lastSleepDuration!.inHours;
    int m = _lastSleepDuration!.inMinutes % 60;
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sleep Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: TColor.primaryColor1,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: media.width * 0.6,
                height: media.width * 0.6,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SimpleCircularProgressBar(
                      progressStrokeWidth: 18,
                      backStrokeWidth: 18,
                      progressColors: TColor.primaryG,
                      backColor: Colors.grey.shade100,
                      valueNotifier: ValueNotifier(_progress * 100),
                      startAngle: -90,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _sleepDurationText,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: TColor.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Last Sleep',
                          style: TextStyle(fontSize: 18, color: TColor.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'of 8h goal',
                          style: TextStyle(fontSize: 14, color: TColor.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _toggleSleep,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isSleeping
                          ? TColor.secondaryColor2
                          : TColor.primaryColor2,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                child: Text(
                  _isSleeping ? 'Wake Up' : 'Go to Sleep',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_isSleeping && _sleepStart != null)
                Text(
                  'Sleeping since: ${_sleepStart!.hour.toString().padLeft(2, '0')}:${_sleepStart!.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(color: TColor.grey, fontSize: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
