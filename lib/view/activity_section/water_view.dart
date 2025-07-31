import 'package:flutter/material.dart';
import 'package:fitrack/common/color_extension.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:fitrack/view/main_tab/maintab_view.dart';

class WaterView extends StatefulWidget {
  const WaterView({super.key});

  @override
  State<WaterView> createState() => _WaterViewState();
}

class _WaterViewState extends State<WaterView> {
  final TextEditingController _mlController = TextEditingController();
  final TextEditingController _goalController = TextEditingController(
    text: '2000',
  );
  final List<_WaterLog> _logs = [];
  int _goal = 2000;
  String _selectedPeriod = 'Daily';
  final List<String> _periods = ['Daily', 'Weekly', 'Monthly'];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLogs = prefs.getStringList('water_logs') ?? [];
    final savedGoal = prefs.getInt('water_goal') ?? 2000;
    
    setState(() {
      _goal = savedGoal;
      _goalController.text = savedGoal.toString();
      _logs.clear();
      for (final logString in savedLogs) {
        try {
          final logData = jsonDecode(logString);
          _logs.add(_WaterLog.fromJson(logData));
        } catch (e) {
          // Skip invalid entries
        }
      }
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final logsJson = _logs.map((log) => jsonEncode(log.toJson())).toList();
    await prefs.setStringList('water_logs', logsJson);
    await prefs.setInt('water_goal', _goal);
  }

  void _logWater() {
    final mlText = _mlController.text.trim();
    if (mlText.isEmpty) {
      _showSnackBar('Please enter water amount');
      return;
    }
    
    final ml = int.tryParse(mlText);
    if (ml == null || ml <= 0) {
      _showSnackBar('Please enter a valid water amount');
      return;
    }
    
    setState(() {
      _logs.add(_WaterLog(ml: ml, timestamp: DateTime.now()));
      _mlController.clear();
    });
    
    _saveData();
    _showSnackBar('Water logged successfully!');
  }

  void _setGoal() {
    final goalText = _goalController.text.trim();
    if (goalText.isEmpty) {
      _showSnackBar('Please enter a goal amount');
      return;
    }
    
    final goal = int.tryParse(goalText);
    if (goal == null || goal <= 0) {
      _showSnackBar('Please enter a valid goal amount');
      return;
    }
    
    setState(() {
      _goal = goal;
    });
    
    _saveData();
    _showSnackBar('Goal updated successfully!');
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

  void _clearAllLogs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Logs'),
        content: const Text('Are you sure you want to clear all water logs?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _logs.clear();
              });
              _saveData();
              Navigator.pop(context);
              _showSnackBar('All logs cleared');
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  int get _todayTotal {
    final now = DateTime.now();
    return _logs
        .where(
          (log) =>
              log.timestamp.day == now.day &&
              log.timestamp.month == now.month &&
              log.timestamp.year == now.year,
        )
        .fold(0, (sum, log) => sum + log.ml);
  }

  double get _progress => (_todayTotal / _goal).clamp(0, 1);

  // Real analytics data based on actual water logs
  List<FlSpot> get _chartData {
    if (_logs.isEmpty) return [];
    
    if (_selectedPeriod == 'Daily') {
      // Show last 7 days
      final now = DateTime.now();
      return List.generate(7, (index) {
        final date = now.subtract(Duration(days: 6 - index));
        final dayWater = _logs
            .where((log) =>
                log.timestamp.day == date.day &&
                log.timestamp.month == date.month &&
                log.timestamp.year == date.year)
            .fold(0, (sum, log) => sum + log.ml);
        return FlSpot(index.toDouble(), dayWater.toDouble());
      });
    } else if (_selectedPeriod == 'Weekly') {
      // Show last 4 weeks
      final now = DateTime.now();
      return List.generate(4, (index) {
        final weekStart = now.subtract(Duration(days: (3 - index) * 7));
        final weekEnd = weekStart.add(const Duration(days: 6));
        final weekWater = _logs
            .where((log) =>
                log.timestamp.isAfter(weekStart.subtract(const Duration(days: 1))) &&
                log.timestamp.isBefore(weekEnd.add(const Duration(days: 1))))
            .fold(0, (sum, log) => sum + log.ml);
        return FlSpot(index.toDouble(), weekWater.toDouble());
      });
    } else {
      // Show last 30 days
      final now = DateTime.now();
      return List.generate(30, (index) {
        final date = now.subtract(Duration(days: 29 - index));
        final dayWater = _logs
            .where((log) =>
                log.timestamp.day == date.day &&
                log.timestamp.month == date.month &&
                log.timestamp.year == date.year)
            .fold(0, (sum, log) => sum + log.ml);
        return FlSpot(index.toDouble(), dayWater.toDouble());
      });
    }
  }

  List<String> get _xLabels {
    if (_selectedPeriod == 'Daily') {
      return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    } else if (_selectedPeriod == 'Weekly') {
      return ['W1', 'W2', 'W3', 'W4'];
    } else {
      return List.generate(30, (i) => (i + 1).toString());
    }
  }

  String _formatYAxis(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}L';
    } else {
      return '${value.toInt()}ml';
    }
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
        appBar: AppBar(
          title: const Text(
            'Water Intake',
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
            if (_logs.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_sweep),
                onPressed: _clearAllLogs,
                tooltip: 'Clear all logs',
              ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _mlController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Enter water (ml)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _logWater,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColor.primaryColor2,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                      child: const Text('Log', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _goalController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Set daily goal (ml)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _setGoal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColor.secondaryColor2,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                      child: const Text('Set', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Center(
                  child: SizedBox(
                    width: media.width * 0.5,
                    height: media.width * 0.5,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SimpleCircularProgressBar(
                          progressStrokeWidth: 16,
                          backStrokeWidth: 16,
                          progressColors: TColor.primaryG,
                          backColor: Colors.grey.shade100,
                          valueNotifier: ValueNotifier(_progress * 100),
                          startAngle: -90,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$_todayTotal ml',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: TColor.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Today',
                              style: TextStyle(
                                fontSize: 18,
                                color: TColor.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'of $_goal ml goal',
                              style: TextStyle(
                                fontSize: 14,
                                color: TColor.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                if (_logs.isNotEmpty) ...[
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
                                Icons.water_drop,
                                color: Colors.blue,
                                size: 22,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Water Log',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ..._logs.reversed.take(5).map(
                            (log) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(
                                Icons.water_drop,
                                color: Colors.blue,
                              ),
                              title: Text(
                                '${log.ml} ml',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                DateFormat(
                                  'yyyy-MM-dd HH:mm',
                                ).format(log.timestamp),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Analytics',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: TColor.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedPeriod,
                        underline: const SizedBox(),
                        borderRadius: BorderRadius.circular(16),
                        items:
                            _periods
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedPeriod = val!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: (_chartData.isEmpty || _chartData.every((spot) => spot.y == 0))
                      ? const Center(
                          child: Text(
                            'No water data to display.',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        )
                      : LineChart(
                          LineChartData(
                            minY: 0,
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: true,
                              getDrawingHorizontalLine:
                                  (value) => FlLine(
                                    color: TColor.white.withOpacity(0.2),
                                    strokeWidth: 1,
                                  ),
                              getDrawingVerticalLine:
                                  (value) => FlLine(
                                    color: TColor.white.withOpacity(0.2),
                                    strokeWidth: 1,
                                  ),
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 50,
                                  getTitlesWidget:
                                      (value, meta) => Text(
                                        _formatYAxis(value),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: TColor.black.withOpacity(0.7),
                                        ),
                                      ),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 32,
                                  interval: _selectedPeriod == 'Monthly' ? 4 : 1,
                                  getTitlesWidget: (value, meta) {
                                    final labels = _xLabels;
                                    final idx = value.toInt();
                                    if (_selectedPeriod == 'Monthly') {
                                      const showIdx = [0, 4, 8, 12, 16, 20, 24, 29];
                                      if (!showIdx.contains(idx)) {
                                        return const SizedBox.shrink();
                                      }
                                    }
                                    if (idx < 0 || idx >= labels.length) {
                                      return const SizedBox.shrink();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        labels[idx],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: TColor.black.withOpacity(0.7),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: _chartData,
                                isCurved: true,
                                barWidth: 4,
                                color: TColor.secondaryColor2,
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      TColor.secondaryColor2.withOpacity(0.3),
                                      TColor.primaryColor1.withOpacity(0.1),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                                dotData: FlDotData(show: true),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WaterLog {
  final int ml;
  final DateTime timestamp;
  
  _WaterLog({required this.ml, required this.timestamp});

  Map<String, dynamic> toJson() => {
    'ml': ml,
    'timestamp': timestamp.toIso8601String(),
  };

  factory _WaterLog.fromJson(Map<String, dynamic> json) => _WaterLog(
    ml: json['ml'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}
