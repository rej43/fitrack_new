import 'package:flutter/material.dart';
import 'package:fitrack/common/color_extension.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:fitrack/view/home/activity_traker_view.dart';

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

  void _logWater() {
    final ml = int.tryParse(_mlController.text.trim());
    if (ml != null && ml > 0) {
      setState(() {
        _logs.add(_WaterLog(ml: ml, timestamp: DateTime.now()));
        _mlController.clear();
      });
    }
  }

  void _setGoal() {
    final g = int.tryParse(_goalController.text.trim());
    if (g != null && g > 0) {
      setState(() {
        _goal = g;
      });
    }
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

  // Mock analytics data for demonstration
  List<FlSpot> get _chartData {
    if (_selectedPeriod == 'Daily') {
      // Last 7 days mock data
      return [
        FlSpot(0, 1200),
        FlSpot(1, 1500),
        FlSpot(2, 1800),
        FlSpot(3, 2000),
        FlSpot(4, 1700),
        FlSpot(5, 2100),
        FlSpot(6, 1900),
      ];
    } else if (_selectedPeriod == 'Weekly') {
      return [
        FlSpot(0, 11000),
        FlSpot(1, 12500),
        FlSpot(2, 13000),
        FlSpot(3, 14000),
      ];
    } else {
      // Monthly
      return List.generate(
        30,
        (i) => FlSpot(i.toDouble(), 1500 + (i % 7) * 100),
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
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ActivityTrackerView()),
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
                  builder: (context) => const ActivityTrackerView(),
                ),
                (route) => false,
              );
            },
          ),
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
                  child: LineChart(
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
}
