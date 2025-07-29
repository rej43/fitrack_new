import 'package:fitrack/common/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:fitrack/view/activity_section/calories_view.dart';
import 'package:fitrack/view/activity_section/steps_view.dart' as steps;
import 'package:fitrack/view/activity_section/sleep_view.dart';
import 'package:fitrack/view/activity_section/water_view.dart';

class StepsView extends StatefulWidget {
  const StepsView({super.key});

  @override
  State<StepsView> createState() => _StepsViewState();
}

class _StepsViewState extends State<StepsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: TColor.primaryColor1,
        centerTitle: true,
        title: const Text(
          'Steps',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 20,
            letterSpacing: 1.1,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 18),
              child: Text(
                "Track your daily activities",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            _activityCard(
              icon: Icons.nightlight_round,
              label: "Log Sleep",
              iconColor: Colors.deepPurple,
              onTap: _logSleep,
            ),
            _activityCard(
              icon: Icons.directions_walk,
              label: "Log Steps",
              iconColor: Colors.green,
              onTap: _logSteps,
            ),
            _activityCard(
              icon: Icons.opacity,
              label: "Log Water",
              iconColor: Colors.blue,
              onTap: _logWater,
            ),
            _activityCard(
              icon: Icons.local_fire_department,
              label: "Log Food",
              iconColor: Colors.deepOrange,
              onTap: _logFood,
            ),
          ],
        ),
      ),
    );
  }

  Widget _activityCard({
    required IconData icon,
    required String label,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Card(
        elevation: 0,
        color: TColor.lightgrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(icon, color: iconColor),
          ),
          title: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.black38),
          onTap: onTap,
        ),
      ),
    );
  }

  void _logSleep() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SleepView()),
    );
  }

  void _logSteps() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const steps.StepsView()),
    );
  }

  void _logWater() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WaterView()),
    );
  }

  void _logFood() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CaloriesView()),
    );
  }
}
