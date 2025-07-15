import 'package:flutter/material.dart';
import 'package:fitrack/common/color_extension.dart';
import 'package:fitrack/common_widget/round_textfiled.dart';
import 'package:fitrack/common_widget/round_button.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

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
  const CaloriesView({Key? key}) : super(key: key);

  @override
  State<CaloriesView> createState() => _CaloriesViewState();
}

class _CaloriesViewState extends State<CaloriesView> {
  final TextEditingController _foodController = TextEditingController();
  String? _caloriesResult;
  bool _loading = false;
  String? _error;
  final List<FoodLog> _foodLogs = [];
  String _selectedPeriod = 'Daily';
  final List<String> _periods = ['Daily', 'Weekly', 'Monthly'];

  Future<void> _fetchCalories() async {
    setState(() {
      _loading = true;
      _error = null;
      _caloriesResult = null;
    });
    final food = _foodController.text.trim();
    if (food.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Please enter a food item.';
      });
      return;
    }
    try {
      // Open Food Facts API (no key required)
      final response = await http.get(
        Uri.parse(
          'https://world.openfoodfacts.org/cgi/search.pl?search_terms=' +
              Uri.encodeComponent(food) +
              '&search_simple=1&action=process&json=1',
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = data['products'] as List<dynamic>?;
        if (products != null && products.isNotEmpty) {
          // Try to find a product with calorie info
          final productWithCalories = products.firstWhere(
            (p) =>
                p['nutriments'] != null &&
                (p['nutriments']['energy-kcal_100g'] != null ||
                    p['nutriments']['energy-kcal'] != null),
            orElse: () => null,
          );
          if (productWithCalories != null) {
            final nutriments = productWithCalories['nutriments'];
            // Prefer per 100g if available
            final calories =
                nutriments['energy-kcal_100g'] ?? nutriments['energy-kcal'];
            setState(() {
              _caloriesResult =
                  'Food: ${productWithCalories['product_name'] ?? food}\nCalories: $calories kcal (per 100g)';
            });
          } else {
            setState(() {
              _caloriesResult =
                  'Food: $food\nCalories info not available for this food.';
            });
          }
        } else {
          setState(() {
            _error = 'No data found for "$food".';
          });
        }
      } else {
        setState(() {
          _error = 'Failed to fetch data. (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _addFoodToLog() {
    if (_caloriesResult == null) return;
    // Prevent logging if calories info is not available
    if (_caloriesResult!.contains('Calories info not available')) return;
    final match = RegExp(r'Calories: (\d+) kcal').firstMatch(_caloriesResult!);
    final calories = match != null ? int.parse(match.group(1)!) : 0;
    final foodMatch = RegExp(r'Food: ([^\n]+)').firstMatch(_caloriesResult!);
    final food =
        foodMatch != null ? foodMatch.group(1)! : _foodController.text.trim();
    setState(() {
      _foodLogs.add(
        FoodLog(food: food, calories: calories, timestamp: DateTime.now()),
      );
      _caloriesResult = null;
      _foodController.clear();
    });
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

  // Mock analytics data for demonstration
  List<FlSpot> get _chartData {
    if (_selectedPeriod == 'Daily') {
      // Last 7 days mock data
      return [
        FlSpot(0, 350),
        FlSpot(1, 420),
        FlSpot(2, 500),
        FlSpot(3, 300),
        FlSpot(4, 700),
        FlSpot(5, 800),
        FlSpot(6, 600),
      ];
    } else if (_selectedPeriod == 'Weekly') {
      return [
        FlSpot(0, 2500),
        FlSpot(1, 3200),
        FlSpot(2, 2800),
        FlSpot(3, 3500),
      ];
    } else {
      // Monthly
      return List.generate(
        30,
        (i) => FlSpot(i.toDouble(), 300 + (i % 7) * 100),
      );
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

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calorie Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: TColor.primaryColor1,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Enter the food you ate to log its calories:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: RoundTextField(
                      controller: _foodController,
                      hitText: 'e.g. 2 eggs, 1 apple',
                      icon: 'assets/img/food.png',
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _loading ? null : _fetchCalories,
                    child: Text(_loading ? 'Loading...' : 'Search'),
                  ),
                ],
              ),
              if (_caloriesResult != null)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: TColor.primaryColor1.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _caloriesResult!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _addFoodToLog,
                        child: const Text('Add to Log'),
                      ),
                    ],
                  ),
                ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                'Today\'s Calories',
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) {
                  return LinearGradient(
                    colors: TColor.primaryG,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ).createShader(
                    Rect.fromLTRB(0, 0, bounds.width, bounds.height),
                  );
                },
                child: Text(
                  '$_todayCalories kCal',
                  style: TextStyle(
                    color: TColor.white.withOpacity(0.7),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_foodLogs.isNotEmpty) ...[
                const Text(
                  'Food Log:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ..._foodLogs.reversed.map(
                  (log) => ListTile(
                    title: Text(log.food),
                    subtitle: Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(log.timestamp),
                    ),
                    trailing: Text('${log.calories} kcal'),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Analytics',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
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
                child:
                    (_chartData.isEmpty ||
                            _chartData.every((spot) => spot.y == 0))
                        ? Center(
                          child: Text(
                            'No calorie data to display.',
                            style: TextStyle(color: TColor.grey, fontSize: 14),
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
                                  reservedSize: 36,
                                  getTitlesWidget:
                                      (value, meta) => Text(
                                        value.toInt().toString(),
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
                                  interval:
                                      _selectedPeriod == 'Monthly' ? 4 : 1,
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
                                      if (!showIdx.contains(idx))
                                        return const SizedBox.shrink();
                                    }
                                    if (idx < 0 || idx >= labels.length)
                                      return const SizedBox.shrink();
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
    );
  }
}
