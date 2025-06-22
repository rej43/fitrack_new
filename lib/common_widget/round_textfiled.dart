import 'package:flutter/material.dart';
import 'package:fitrack/common/color_extension.dart';

class RoundTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hitText;
  final String icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? rightIcon;
  final FormFieldValidator<String>? validator;

  const RoundTextField({
    super.key,
    this.controller,
    required this.hitText,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.rightIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TColor.lightgrey,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 15,
          ),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: hitText,
          hintStyle: TextStyle(color: TColor.grey, fontSize: 12),
          prefixIcon: Container(
            alignment: Alignment.center,
            width: 20,
            height: 20,
            child: Image.asset(
              icon,
              width: 20,
              height: 20,
              fit: BoxFit.contain,
              color: TColor.grey,
            ),
          ),
          suffixIcon: rightIcon,
        ),
      ),
    );
  }
}
