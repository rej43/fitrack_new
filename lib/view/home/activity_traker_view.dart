import 'package:fitrack/common/color_extension.dart';
import 'package:fitrack/common_widget/round_button.dart';
import 'package:flutter/material.dart';
import 'package:fitrack/view/activity_section/calories_view.dart';
import 'package:fitrack/view/activity_section/steps_view.dart';
import 'package:fitrack/view/activity_section/sleep_view.dart';
import 'package:fitrack/view/activity_section/water_view.dart';
class ActivityTrackerView extends StatefulWidget {
  const ActivityTrackerView({super.key});

  @override
  State<ActivityTrackerView> createState() => _ActivityTrackerViewState();
}

class _ActivityTrackerViewState extends State<ActivityTrackerView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Activity Tracker',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: TColor.primaryColor1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildHeader(),
            SizedBox(height: 20),

            RoundButton(title: "Log Sleep", onPressed: _logSleep),
            SizedBox(height: 20),
            RoundButton(title: "Log Steps", onPressed: _logSteps),
            SizedBox(height: 20),
            RoundButton(title: "Log Water", onPressed: _logWater),
            SizedBox(height: 20),
            RoundButton(title: "Log Food", onPressed: _logFood),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      'Track your daily activities',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  void _logSleep() {
     Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SleepView()),
    );
    // Logic to log sleep
  }

  void _logSteps() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StepsView()),
    );
    // Logic to log steps
  }

  void _logWater() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WaterView()),
    );
    // Logic to log water
  }

  void _logFood() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CaloriesView()),
    );
  }
}
