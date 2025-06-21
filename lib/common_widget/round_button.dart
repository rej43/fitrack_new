import 'package:fitrack/common/color_extension.dart';
import 'package:flutter/material.dart';

class RoundButtton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const RoundButtton({super.key, required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      height: 50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      textColor: TColor.primaryColor1,
      minWidth: double.maxFinite,
      color: TColor.grey,
      child: Text(
        title,
        style: TextStyle(
          color: TColor.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
