import 'package:flutter/material.dart';
import 'package:fitrack/common/color_extension.dart';
import 'package:fitrack/common_widget/title_subtitle_cell.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  // Mock notifications
  final List<Map<String, String>> notifications = [
    {
      "title": "Workout Reminder",
      "subtitle": "Don’t forget your 7:00 AM workout today!",
    },
    {
      "title": "Hydration Alert",
      "subtitle": "Time to drink water. Stay hydrated!",
    },
    {
      "title": "Goal Achieved",
      "subtitle": "Congrats! You reached your daily step goal.",
    },
    {
      "title": "New Challenge",
      "subtitle": "Join the 5K Steps Challenge starting tomorrow.",
    },
    {
      "title": "Weekly Summary",
      "subtitle": "Check out your progress for this week.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        elevation: 0,
        iconTheme: IconThemeData(color: TColor.black),
        title: Text(
          "Notifications",
          style: TextStyle(
            color: TColor.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return TitleSubtitleCell(
            title: notification["title"] ?? "",
            subtitle: notification["subtitle"] ?? "",
          );
        },
      ),
    );
  }
}
