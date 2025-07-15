import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:fitrack/common/color_extension.dart';
import 'package:fl_chart/fl_chart.dart';

class StepsView extends StatefulWidget {
  const StepsView({Key? key}) : super(key: key);

  @override
  State<StepsView> createState() => _StepsViewState();
}

class _StepsViewState extends State<StepsView> {
  int _steps = 0;
  Stream<StepCount>? _stepCountStream;
  String _status = 'Initializing...';
  String _selectedPeriod = 'Daily';
  final List<String> _periods = ['Daily', 'Weekly', 'Monthly'];

  // Mock analytics data for demonstration
  List<FlSpot> get _chartData {
    if (_selectedPeriod == 'Daily') {
      // Last 7 days mock data
      return [
        FlSpot(0, 3500),
        FlSpot(1, 4200),
        FlSpot(2, 5000),
        FlSpot(3, 3000),
        FlSpot(4, 7000),
        FlSpot(5, 8000),
        FlSpot(6, 6000),
      ];
    } else if (_selectedPeriod == 'Weekly') {
      return [
        FlSpot(0, 25000),
        FlSpot(1, 32000),
        FlSpot(2, 28000),
        FlSpot(3, 35000),
      ];
    } else {
      // Monthly
      return List.generate(
        30,
        (i) => FlSpot(i.toDouble(), 3000 + (i % 7) * 1000),
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
  void initState() {
    super.initState();
    _initPedometer();
  }

  void _initPedometer() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream?.listen(_onStepCount).onError(_onStepCountError);
  }

  void _onStepCount(StepCount event) {
    setState(() {
      _steps = event.steps;
      _status = 'Steps detected!';
    });
  }

  void _onStepCountError(error) {
    setState(() {
      _status = 'Step Count not available';
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Step Tracker',
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
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: TColor.primaryG),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: TColor.grey.withOpacity(0.2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.directions_walk,
                      size: 64,
                      color: TColor.secondaryColor2,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$_steps',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: TColor.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Steps',
                      style: TextStyle(
                        fontSize: 20,
                        color: TColor.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(_status, style: TextStyle(color: TColor.grey, fontSize: 16)),
              const SizedBox(height: 32),
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
