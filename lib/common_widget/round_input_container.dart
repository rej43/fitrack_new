import 'package:flutter/material.dart';
import 'package:fitrack/common/color_extension.dart'; // Make sure this path is correct

class RoundInputContainer extends StatelessWidget {
  final Widget mainContent;
  final String icon;
  final Widget? rightWidget; // Optional widget on the right (like KG/CM button)
  final double height; // To ensure consistent height

  const RoundInputContainer({
    super.key,
    required this.mainContent,
    required this.icon,
    this.rightWidget,
    this.height = 50, // Default height to match RoundTextField
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: TColor.lightgrey,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            alignment: Alignment.center,
            width: 50, // Standard width for prefix icon
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Image.asset(
              icon,
              width: 20,
              height: 20,
              fit: BoxFit.contain,
              color: TColor.grey,
            ),
          ),
          Expanded(
            child: mainContent, // This will be our GestureDetector with Text
          ),
          if (rightWidget != null)
            rightWidget!, // Show right widget if provided
        ],
      ),
    );
  }
}
