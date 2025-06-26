import 'package:fitrack/view/login/welcome_view.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../common/color_extension.dart';
import '../../common_widget/round_button.dart';

class GoalView extends StatefulWidget {
  const GoalView({super.key});

  @override
  State<GoalView> createState() => _GoalViewState();
}

class _GoalViewState extends State<GoalView> {
  final CarouselSliderController buttonCarouselController =
      CarouselSliderController();

  List goalArr = [
    {
      "image": "assets/img/goal_1.png",
      "title": "Improve Shape",
      "subtitle":
          "I have a low amount of body fat\nand need / want to build more\nmuscle",
    },
    {
      "image": "assets/img/goal_2.png",
      "title": "Lose Fat",
      "subtitle":
          "I have over 20 lbs to lose. I want to\ndrop all this fat and gain muscle\nmass",
    },
    {
      "image": "assets/img/goal_3.png",
      "title": "Better Sleep",
      "subtitle":
          "I want to improve my sleep quality\nand maintain a healthy sleep\nschedule for better recovery.",
    },
    {
      "image": "assets/img/goal_4.jpg",
      "title": "Bulking Up",
      "subtitle":
          "I want to gain significant muscle\nmass and increase my overall\nstrength.",
    },
    {
      "image": "assets/img/goal_5.jpg",
      "title": "Stay Healthy",
      "subtitle":
          "I want to maintain my current fitness\nlevel, improve overall well-being, and\nlive a healthy lifestyle.",
    },
    {
      "image": "assets/img/goal_6.jpg",
      "title": "Increase Endurance",
      "subtitle":
          "I want to improve my stamina and\ncardiovascular fitness for various\nactivities.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: CarouselSlider(
                items:
                    goalArr
                        .map(
                          (gObj) => Container(
                            decoration: BoxDecoration(
                              color: TColor.primaryColor1,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: media.width * 0.1,
                              horizontal: 25,
                            ),
                            alignment: Alignment.center,
                            child: FittedBox(
                              child: Column(
                                children: [
                                  Image.asset(
                                    gObj["image"].toString(),
                                    width: media.width * 0.5,
                                    fit: BoxFit.fitWidth,
                                  ),
                                  SizedBox(height: media.width * 0.1),
                                  Text(
                                    gObj["title"].toString(),
                                    style: TextStyle(
                                      color: TColor.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Container(
                                    width: media.width * 0.1,
                                    height: 1,
                                    color: TColor.white,
                                  ),
                                  SizedBox(height: media.width * 0.02),
                                  Text(
                                    gObj["subtitle"].toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: TColor.black,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                carouselController: buttonCarouselController,

                options: CarouselOptions(
                  autoPlay: false,
                  enlargeCenterPage: true,
                  viewportFraction: 0.7,
                  aspectRatio: 0.74,
                  initialPage: 0,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              width: media.width,
              child: Column(
                children: [
                  SizedBox(height: media.width * 0.05),
                  Text(
                    "What is your goal ?",
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(height: media.width * 0.05),
                  RoundButton(
                    title: "Confirm",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const WelcomeView(firstName: ''),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
