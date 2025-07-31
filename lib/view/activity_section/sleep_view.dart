import 'package:flutter/material.dart';
import 'package:fitrack/common/color_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:fitrack/view/main_tab/maintab_view.dart';
import 'dart:async';
import 'dart:convert';

class SleepRecord {
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? duration;

  SleepRecord({
    required this.startTime,
    this.endTime,
    this.duration,
  });

  Map<String, dynamic> toJson() => {
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'duration': duration?.inMinutes,
  };

  factory SleepRecord.fromJson(Map<String, dynamic> json) => SleepRecord(
    startTime: DateTime.parse(json['startTime']),
    endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    duration: json['duration'] != null ? Duration(minutes: json['duration']) : null,
  );
}

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
  final String _today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  Timer? _sleepTimer;
  final List<SleepRecord> _sleepHistory = [];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString('sleep_date') ?? _today;

    if (savedDate == _today) {
      final sleepStartString = prefs.getString('sleep_start');
      final sleepEndString = prefs.getString('sleep_end');

      if (sleepStartString != null) {
        _sleepStart = DateTime.parse(sleepStartString);
      }

      if (sleepEndString != null) {
        _sleepEnd = DateTime.parse(sleepEndString);
        if (_sleepStart != null) {
          _lastSleepDuration = _sleepEnd!.difference(_sleepStart!);
        }
      }

      final isCurrentlySleeping = prefs.getBool('is_sleeping') ?? false;
      if (isCurrentlySleeping && _sleepStart != null && _sleepEnd == null) {
        _isSleeping = true;
        _startSleepTimer();
      }
    } else {
      await prefs.setString('sleep_date', _today);
      await prefs.remove('sleep_start');
      await prefs.remove('sleep_end');
      await prefs.setBool('is_sleeping', false);
    }

    // Load sleep history
    final historyJson = prefs.getStringList('sleep_history') ?? [];
    _sleepHistory.clear();
    for (final recordString in historyJson) {
      try {
        final recordData = jsonDecode(recordString);
        _sleepHistory.add(SleepRecord.fromJson(recordData));
      } catch (e) {
        // Skip invalid entries
      }
    }

    setState(() {});
  }

  Future<void> _saveSleepData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sleep_date', _today);

    if (_sleepStart != null) {
      await prefs.setString('sleep_start', _sleepStart!.toIso8601String());
    }

    if (_sleepEnd != null) {
      await prefs.setString('sleep_end', _sleepEnd!.toIso8601String());
    }

    await prefs.setBool('is_sleeping', _isSleeping);
  }

  Future<void> _saveSleepHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = _sleepHistory.map((record) => jsonEncode(record.toJson())).toList();
    await prefs.setStringList('sleep_history', historyJson);
  }

  void _startSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isSleeping) {
        setState(() {});
      } else {
        timer.cancel();
      }
    });
  }

  void _toggleSleep() async {
    if (!_isSleeping) {
      // Starting sleep
      setState(() {
        _sleepStart = DateTime.now();
        _sleepEnd = null;
        _lastSleepDuration = null;
        _isSleeping = true;
      });
      _startSleepTimer();
      await _saveSleepData();
      _showSnackBar('Sleep tracking started!');
    } else {
      // Ending sleep
      final endTime = DateTime.now();
      setState(() {
        _sleepEnd = endTime;
        if (_sleepStart != null) {
          _lastSleepDuration = endTime.difference(_sleepStart!);
        }
        _isSleeping = false;
      });
      _sleepTimer?.cancel();
      
      // Add to history
      if (_sleepStart != null && _lastSleepDuration != null) {
        _sleepHistory.add(SleepRecord(
          startTime: _sleepStart!,
          endTime: endTime,
          duration: _lastSleepDuration,
        ));
        await _saveSleepHistory();
      }
      
      await _saveSleepData();
      _showSnackBar('Sleep session ended! Duration: ${_formatDuration(_lastSleepDuration!)}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: TColor.primaryColor1,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    int h = duration.inHours;
    int m = duration.inMinutes % 60;
    return '${h}h ${m}m';
  }

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Sleep History'),
        content: const Text('Are you sure you want to clear all sleep history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                _sleepHistory.clear();
              });
              await _saveSleepHistory();
              Navigator.pop(context);
              _showSnackBar('Sleep history cleared');
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  String get _currentSleepDurationText {
    if (!_isSleeping || _sleepStart == null) return '--';
    Duration duration = DateTime.now().difference(_sleepStart!);
    int h = duration.inHours;
    int m = duration.inMinutes % 60;
    return '${h}h ${m}m';
  }

  String get _sleepDurationText {
    if (_isSleeping && _sleepStart != null) {
      return _currentSleepDurationText;
    }
    if (_lastSleepDuration == null) return '--';
    int h = _lastSleepDuration!.inHours;
    int m = _lastSleepDuration!.inMinutes % 60;
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
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
        backgroundColor: TColor.white,
        appBar: AppBar(
          title: const Text(
            'Sleep Tracker',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: TColor.primaryColor1,
          centerTitle: true,
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
          actions: [
            if (_sleepHistory.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_sweep),
                onPressed: _clearHistory,
                tooltip: 'Clear history',
              ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: TColor.primaryG),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: TColor.primaryColor1.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: media.width * 0.5,
                        height: media.width * 0.5,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _sleepDurationText,
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: TColor.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Sleep Duration',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: TColor.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        width: double.maxFinite,
                        height: 60,
                        decoration: BoxDecoration(
                          color:
                              _isSleeping
                                  ? TColor.secondaryColor2
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: _toggleSleep,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isSleeping
                                        ? Icons.wb_sunny
                                        : Icons.bedtime,
                                    color:
                                        _isSleeping
                                            ? Colors.white
                                            : TColor.primaryColor1,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _isSleeping ? 'Wake Up' : 'Go to Sleep',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          _isSleeping
                                              ? Colors.white
                                              : TColor.primaryColor1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                if (_isSleeping && _sleepStart != null)
                  Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: TColor.secondaryColor2.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(
                                Icons.bedtime,
                                color: TColor.secondaryColor2,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Currently Sleeping',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: TColor.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Started at ${DateFormat('HH:mm').format(_sleepStart!)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: TColor.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                if (_sleepHistory.isNotEmpty) ...[
                  const SizedBox(height: 30),
                  Card(
                    elevation: 0,
                    color: TColor.lightgrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.history,
                                color: Colors.deepPurple,
                                size: 22,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Sleep History',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ..._sleepHistory.reversed.take(5).map(
                            (record) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(
                                Icons.bedtime,
                                color: Colors.deepPurple,
                              ),
                              title: Text(
                                record.duration != null 
                                    ? _formatDuration(record.duration!)
                                    : 'Incomplete',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                '${DateFormat('MMM dd, HH:mm').format(record.startTime)} - ${record.endTime != null ? DateFormat('HH:mm').format(record.endTime!) : 'Ongoing'}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
