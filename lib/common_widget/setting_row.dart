import 'package:fitrack/common/color_extension.dart';
import 'package:flutter/material.dart';


class SettingRow extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onPressed;
  const SettingRow({
    super.key,
    required this.icon,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,      // <-- provides the Material for InkWell
      child: InkWell(
        onTap: onPressed,
        child: Container(             // <-- use Container instead of SizedBox
          height: 48,                 // <-- increased tappable height
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(icon, height: 20, width: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 14,
                  ),
                ),
              ),
              Image.asset(
                "assets/img/next.png",
                height: 16,
                width: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
