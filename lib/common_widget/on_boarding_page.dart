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
          SizedBox(height: media.width * 0.09),
          Image.asset(
            pObj["image"].toString(),
            width: media.width,
            fit: BoxFit.fitWidth,
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
