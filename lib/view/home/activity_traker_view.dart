import 'package:fitrack/common_widget/round_button.dart';
import 'package:flutter/material.dart';

class ActivityTrakerView extends StatefulWidget {
  const ActivityTrakerView({super.key});

  @override
  State<ActivityTrakerView> createState() => _ActivityTrakerViewState();
}

class _ActivityTrakerViewState extends State<ActivityTrakerView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Activity Tracker', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 20),
        RoundButton(
          title: "Log Sleep",
          onPressed: () {
            // Logic to log sleep
          },
        ),
        SizedBox(height: 10),
        RoundButton(
          title: 'Log Calories',
          onPressed: () {
            // Logic to log calories
          },
        ),
        SizedBox(height: 10),
        RoundButton(
          title: 'Log Steps',
          onPressed: () {
            // Logic to log steps
          },
        ),
        SizedBox(height: 10),
        RoundButton(
          title: 'Log Water Intake',
          onPressed: () {
            // Logic to log water intake
          },
        ),
      ],
    );
  }
}
