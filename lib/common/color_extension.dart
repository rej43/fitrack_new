import 'package:flutter/material.dart';

class TColor {
  static Color get primaryColor1 => const Color.fromARGB(255, 173, 246, 212);
  static Color get primaryColor2 => const Color.fromARGB(255, 130, 224, 163);

  static Color get secondaryColor1 => const Color.fromARGB(255, 255, 182, 173);
  static Color get secondaryColor2 => const Color.fromARGB(255, 140, 158, 255);
  static List<Color> get primaryG => [primaryColor2, primaryColor1];
  static List<Color> get secondaryG => [secondaryColor2, secondaryColor1];
  static Color get white => Colors.white;
  static Color get black => Colors.black;
  static Color get grey => const Color.fromARGB(255, 82, 81, 81);
  static Color get lightgrey => const Color.fromARGB(255, 239, 238, 238);
}
