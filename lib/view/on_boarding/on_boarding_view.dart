import 'package:fitrack/common_widget/on_boarding_page.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import '../../common/color_extension.dart';
import 'package:fitrack/view/login/signupview.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
  int selectPage = 0;
  PageController controller = PageController();

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      selectPage = controller.page?.round() ?? 0;
      setState(() {});
    });
  }

  List pageArr = [
    {
      "title": "Your personal guide to stress relief",
      "subtitle":
          "Our app helps you reduce stress, improve sleep, and build habits for healthier mind and body",
      "image": "assets/img/on_1.png",
    },
    {
      "title": "Track your daily progress",
      "subtitle":
          "Save your progress in one aplplication.Track your fitness level",
      "image": "assets/img/on_2.png",
    },
    {
      "title": "Eat Well",
      "subtitle":
          "Let's start a healthy lifestyle with us, we can determine your diet everyday. Healthy eating is fun",
      "image": "assets/img/on_3.png",
    },
  ];
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: Stack(
        alignment: Alignment.bottomRight,
        children: [
          PageView.builder(
            controller: controller,
            itemCount: pageArr.length,
            itemBuilder: (context, index) {
              var pObj = pageArr[index] as Map? ?? {};
              return OnBoardingPage(pObj: pObj);
            },
          ),
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 70,
                  height: 70,
                  child: CircularProgressIndicator(
                    color: TColor.primaryColor1,
                    value: (selectPage + 1) / 3,
                    strokeWidth: 2,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 25,
                  ),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: TColor.primaryColor1,
                    borderRadius: BorderRadius.circular(35),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.navigate_next, color: TColor.white),
                    onPressed: () {
                      if (selectPage < 2) {
                        // If not on the last page, go to the next page
                        selectPage = selectPage + 1;
                        controller.jumpToPage(selectPage);
                        setState(() {});
                      } else {
                        // If on the last page, navigate to SignUpView
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpView(),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
