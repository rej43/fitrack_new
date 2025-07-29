import 'package:fitrack/common/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BMIDetailPage extends StatelessWidget {
  const BMIDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    double bmi = 19.1; // Static example BMI

    String category = "Normal Weight";
    Color categoryColor = Colors.green;

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
                      _ChartData('BMI', bmi),
                      _ChartData('Remaining', 40 - bmi),
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
