import 'package:flutter/material.dart';
import 'package:fitrack/common/color_extension.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:fitrack/view/main_tab/maintab_view.dart';

class FoodLog {
  final String food;
  final int calories;
  final DateTime timestamp;

  FoodLog({
    required this.food,
    required this.calories,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'food': food,
    'calories': calories,
    'timestamp': timestamp.toIso8601String(),
  };

  factory FoodLog.fromJson(Map<String, dynamic> json) => FoodLog(
    food: json['food'],
    calories: json['calories'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

class CaloriesView extends StatefulWidget {
  const CaloriesView({super.key});

  @override
  State<CaloriesView> createState() => _CaloriesViewState();
}

class _CaloriesViewState extends State<CaloriesView> {
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _calorieController = TextEditingController();
  final List<FoodLog> _foodLogs = [];
  String _selectedPeriod = 'Daily';
  final List<String> _periods = ['Daily', 'Weekly', 'Monthly'];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLogs = prefs.getStringList('food_logs') ?? [];
    
    setState(() {
      _foodLogs.clear();
      for (final logString in savedLogs) {
        try {
          final logData = jsonDecode(logString);
          _foodLogs.add(FoodLog.fromJson(logData));
        } catch (e) {
          // Skip invalid entries
        }
      }
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final logsJson = _foodLogs.map((log) => jsonEncode(log.toJson())).toList();
    await prefs.setStringList('food_logs', logsJson);
  }

  int get _todayCalories {
    final now = DateTime.now();
    return _foodLogs
        .where(
          (log) =>
              log.timestamp.day == now.day &&
              log.timestamp.month == now.month &&
              log.timestamp.year == now.year,
        )
        .fold(0, (sum, log) => sum + log.calories);
  }

  // Real analytics data based on actual food logs
  List<FlSpot> get _chartData {
    if (_foodLogs.isEmpty) return [];
    
    if (_selectedPeriod == 'Daily') {
      // Show last 7 days
      final now = DateTime.now();
      return List.generate(7, (index) {
        final date = now.subtract(Duration(days: 6 - index));
        final dayCalories = _foodLogs
            .where((log) =>
                log.timestamp.day == date.day &&
                log.timestamp.month == date.month &&
                log.timestamp.year == date.year)
            .fold(0, (sum, log) => sum + log.calories);
        return FlSpot(index.toDouble(), dayCalories.toDouble());
      });
    } else if (_selectedPeriod == 'Weekly') {
      // Show last 4 weeks
      final now = DateTime.now();
      return List.generate(4, (index) {
        final weekStart = now.subtract(Duration(days: (3 - index) * 7));
        final weekEnd = weekStart.add(const Duration(days: 6));
        final weekCalories = _foodLogs
            .where((log) =>
                log.timestamp.isAfter(weekStart.subtract(const Duration(days: 1))) &&
                log.timestamp.isBefore(weekEnd.add(const Duration(days: 1))))
            .fold(0, (sum, log) => sum + log.calories);
        return FlSpot(index.toDouble(), weekCalories.toDouble());
      });
    } else {
      // Show last 30 days
      final now = DateTime.now();
      return List.generate(30, (index) {
        final date = now.subtract(Duration(days: 29 - index));
        final dayCalories = _foodLogs
            .where((log) =>
                log.timestamp.day == date.day &&
                log.timestamp.month == date.month &&
                log.timestamp.year == date.year)
            .fold(0, (sum, log) => sum + log.calories);
        return FlSpot(index.toDouble(), dayCalories.toDouble());
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

  void _addFoodToLog() {
    final food = _foodController.text.trim();
    final caloriesText = _calorieController.text.trim();
    
    if (food.isEmpty) {
      _showSnackBar('Please enter a food item');
      return;
    }
    
    if (caloriesText.isEmpty) {
      _showSnackBar('Please enter calories');
      return;
    }
    
    final calories = int.tryParse(caloriesText);
    if (calories == null || calories <= 0) {
      _showSnackBar('Please enter a valid calorie amount');
      return;
    }
    
    setState(() {
      _foodLogs.add(
        FoodLog(food: food, calories: calories, timestamp: DateTime.now()),
      );
      _foodController.clear();
      _calorieController.clear();
    });
    
    _saveData();
    _showSnackBar('Food logged successfully!');
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
        content: const Text('Are you sure you want to clear all food logs?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _foodLogs.clear();
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
          elevation: 1,
          backgroundColor: TColor.primaryColor1,
          centerTitle: true,
          title: const Text(
            'Calorie Tracker',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 20,
              letterSpacing: 1.1,
            ),
          ),
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
            if (_foodLogs.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_sweep),
                onPressed: _clearAllLogs,
                tooltip: 'Clear all logs',
              ),
          ],
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 18),
                  child: Text(
                    "Enter the food and calories (kcal):",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Card(
                  elevation: 0,
                  color: TColor.lightgrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _foodController,
                                decoration: const InputDecoration(
                                  hintText: 'e.g. 2 eggs, 1 apple',
                                  border: InputBorder.none,
                                  prefixIcon: Icon(
                                    Icons.fastfood,
                                    color: Colors.grey,
                                  ),
                                ),
                                keyboardType: TextInputType.text,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _calorieController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Calories (kcal)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(
                              Icons.local_fire_department,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColor.primaryColor1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                          ),
                          onPressed: _addFoodToLog,
                          icon: const Icon(Icons.add, color: Colors.black87),
                          label: const Text(
                            'Add to Log',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 0,
                  color: TColor.lightgrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 18,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          color: Colors.deepOrange,
                          size: 32,
                        ),
                        const SizedBox(width: 18),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Today's Calories",
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              '$_todayCalories kCal',
                              style: TextStyle(
                                color: TColor.primaryColor1,
                                fontWeight: FontWeight.w700,
                                fontSize: 22,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_foodLogs.isNotEmpty) ...[
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
                                Icons.list_alt,
                                color: Colors.deepOrange,
                                size: 22,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Food Log',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ..._foodLogs.reversed.map(
                            (log) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(
                                Icons.fastfood,
                                color: Colors.deepOrange,
                              ),
                              title: Text(
                                log.food,
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
                              trailing: Text(
                                '${log.calories} kcal',
                                style: const TextStyle(
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                Card(
                  elevation: 0,
                  color: TColor.lightgrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.show_chart,
                                  color: Colors.deepOrange,
                                  size: 22,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Analytics',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                            DropdownButton<String>(
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
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child:
                              (_chartData.isEmpty ||
                                      _chartData.every((spot) => spot.y == 0))
                                  ? const Center(
                                    child: Text(
                                      'No calorie data to display.',
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
                                              color: Colors.grey.withOpacity(0.2),
                                              strokeWidth: 1,
                                            ),
                                        getDrawingVerticalLine:
                                            (value) => FlLine(
                                              color: Colors.grey.withOpacity(0.2),
                                              strokeWidth: 1,
                                            ),
                                      ),
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 36,
                                            getTitlesWidget:
                                                (value, meta) => Text(
                                                  value.toInt().toString(),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black
                                                        .withOpacity(0.7),
                                                  ),
                                                ),
                                          ),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 32,
                                            interval:
                                                _selectedPeriod == 'Monthly'
                                                    ? 4
                                                    : 1,
                                            getTitlesWidget: (value, meta) {
                                              final labels = _xLabels;
                                              final idx = value.toInt();
                                              if (_selectedPeriod == 'Monthly') {
                                                const showIdx = [
                                                  0,
                                                  4,
                                                  8,
                                                  12,
                                                  16,
                                                  20,
                                                  24,
                                                  29,
                                                ];
                                                if (!showIdx.contains(idx)) {
                                                  return const SizedBox.shrink();
                                                }
                                              }
                                              if (idx < 0 || idx >= labels.length) {
                                                return const SizedBox.shrink();
                                              }
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 8.0,
                                                ),
                                                child: Text(
                                                  labels[idx],
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black
                                                        .withOpacity(0.7),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        topTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),
                                        rightTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: _chartData,
                                          isCurved: true,
                                          barWidth: 4,
                                          color: Colors.deepOrange,
                                          belowBarData: BarAreaData(
                                            show: true,
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.deepOrange.withOpacity(
                                                  0.3,
                                                ),
                                                Colors.orangeAccent.withOpacity(
                                                  0.1,
                                                ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
