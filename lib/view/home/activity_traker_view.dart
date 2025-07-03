import 'package:fitrack/common/color_extension.dart';
import 'package:fitrack/common_widget/round_button.dart';
import 'package:fitrack/view/home/calories_view.dart';
import 'package:flutter/material.dart';

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
           
            RoundButton(
                title: "Go To Home",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NutritionPage(),
                    ),
                  );
                },
              ),
            SizedBox(height: 20),
            RoundButton(title: "Log Workout", onPressed: _logWorkout),
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
    // Logic to log sleep
  }

  void _logWorkout() {
    // Logic to log workout
  }

  void _logWater() {
    // Logic to log water
  }

  void _logFood() {
    // Logic to log food
  }
}
