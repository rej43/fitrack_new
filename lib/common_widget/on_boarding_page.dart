import 'package:fitrack/common/color_extension.dart';
import 'package:flutter/material.dart';

class OnBoardingPage extends StatelessWidget {
  final Map pObj;
  const OnBoardingPage({super.key, required this.pObj});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return SizedBox(
      width: media.width,
      height: media.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Push image slightly below top (use height instead of width for better vertical control)
          SizedBox(height: media.height * 0.12),
          SizedBox(
            width: media.width * 0.9,
            height: media.height * 0.45,
            child: Image.asset(pObj["image"].toString(), fit: BoxFit.cover),
          ),

         SizedBox(height: media.width * 0.01),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              pObj["title"].toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TColor.black,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          SizedBox(height: 6),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              pObj["subtitle"].toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: TColor.black, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
