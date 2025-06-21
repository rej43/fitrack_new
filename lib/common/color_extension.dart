import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TColor {
  static Color get primaryColor1 => const Color.fromARGB(255, 173, 246, 212);
  static Color get primaryColor2 => const Color.fromARGB(255, 95, 205, 134);
  static List<Color> get primaryG => [primaryColor2, primaryColor1];
  static Color get white => Colors.white;
  static Color get black => Colors.black;
  static Color get grey => const Color.fromARGB(255, 82, 81, 81);
  static Color get lightgrey => const Color.fromARGB(255, 239, 238, 238);
}
