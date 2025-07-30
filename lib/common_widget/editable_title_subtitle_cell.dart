import 'package:flutter/material.dart';
import 'package:fitrack/common/color_extension.dart';

class EditableTitleSubtitleCell extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const EditableTitleSubtitleCell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: TColor.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: TColor.grey, blurRadius: 2)],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        colors: TColor.primaryG,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ).createShader(
                        Rect.fromLTRB(0, 0, bounds.width, bounds.height),
                      );
                    },
                    child: Text(
                      title,
                      style: TextStyle(
                        color: TColor.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: TColor.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.edit, color: TColor.grey, size: 18),
          ],
        ),
      ),
    );
  }
}
