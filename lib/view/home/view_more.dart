import 'package:fitrack/common/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:fitrack/models/user_model.dart';

class BMIDetailPage extends StatefulWidget {
  const BMIDetailPage({super.key});

  @override
  State<BMIDetailPage> createState() => _BMIDetailPageState();
}

class _BMIDetailPageState extends State<BMIDetailPage> {
  UserModel? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await UserModel.loadFromLocal();
      setState(() {
        user = userData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: TColor.primaryColor1,
          title: const Text("BMI Details"),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final bmi = user?.bmi ?? 19.1; // Fallback to static value if no user data
    final category = user?.bmiCategory ?? "Normal Weight";
    Color categoryColor = Colors.green;
    
    // Set color based on BMI category
    if (category == "Underweight") {
      categoryColor = Colors.blue;
    } else if (category == "Overweight") {
      categoryColor = Colors.orange;
    } else if (category == "Obese") {
      categoryColor = Colors.red;
    }
    
    // Calculate BMI percentage for chart
    final bmiPercentage = (bmi / 40.0) * 100; // Assuming max BMI of 40 for visualization

    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.primaryColor1,
        title: const Text("BMI Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              "Your BMI",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            // Large Doughnut Chart
            SizedBox(
              height: 250,
              child: SfCircularChart(
                annotations: <CircularChartAnnotation>[
                  CircularChartAnnotation(
                    widget: Container(
                      child: Text(
                        bmi.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: TColor.secondaryColor2,
                        ),
                      ),
                    ),
                  ),
                ],
                series: <DoughnutSeries<_ChartData, String>>[
                  DoughnutSeries<_ChartData, String>(
                    dataSource: [
                      _ChartData('BMI', bmiPercentage),
                      _ChartData('Remaining', 100 - bmiPercentage),
                    ],
                    pointColorMapper: (_ChartData data, _) {
                      if (data.label == 'BMI') {
                        return TColor.secondaryColor2;
                      }
                      return Colors.grey[300];
                    },
                    xValueMapper: (_ChartData data, _) => data.label,
                    yValueMapper: (_ChartData data, _) => data.value,
                    radius: '90%',
                    innerRadius: '70%',
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: false,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              category,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: categoryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "BMI is a measure of body fat based on height and weight. "
              "Maintaining a BMI between 18.5 and 24.9 is considered healthy.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: TColor.black),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper class for chart data
class _ChartData {
  final String label;
  final double value;

  _ChartData(this.label, this.value);
}
