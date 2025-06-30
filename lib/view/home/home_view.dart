import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:fitrack/common/color_extension.dart';
import 'package:fitrack/common_widget/round_button.dart';
import 'package:fitrack/view/home/Set_goals.dart';
import 'package:fitrack/view/home/activity_traker_view.dart';
import 'package:fitrack/view/home/view_more.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:fitrack/view/home/notification_view.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List waterArr = [
    {"title": "6am - 8am", "subtitle": "600ml"},
    {"title": "9am - 11am", "subtitle": "500ml"},
    {"title": "11am - 2pm", "subtitle": "1000ml"},
    {"title": "2pm - 4pm", "subtitle": "700ml"},
    {"title": "4pm - now", "subtitle": "900ml"},
  ];
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome Back,",
                          style: TextStyle(color: TColor.grey, fontSize: 15),
                        ),
                        Text(
                          "Joe Goldberg",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationView(),
                          ),
                        );
                      },
                      icon: Image.asset(
                        "assets/img/notification.png",
                        width: 25,
                        height: 25,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: media.width * 0.05),
                Container(
                  height: media.width * 0.4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: TColor.primaryG),
                    borderRadius: BorderRadius.circular(media.width * 0.075),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 25,
                    horizontal: 25,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "BMI (Body Mass Index)",
                            style: TextStyle(
                              color: TColor.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            "You have a normal weight",
                            style: TextStyle(
                              color: TColor.grey,
                              fontWeight: FontWeight.w300,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: media.width * 0.05),
                          SizedBox(
                            width: 150,
                            height: 35,
                            child: RoundButton(
                              title: "View More",
                              type: RoundButtonType.bgSGradient,
                              fontSize: 12,
                              fontWeight: FontWeight.w100,
                              onPressed: () {
                                 Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BMIDetailPage(),
                    ),
                );
                              },
                            ),
                          ),
                        ],
                      ),
                      AspectRatio(
                        aspectRatio: 1,
                        child: PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback:
                                  (FlTouchEvent event, pieTouchResponse) {},
                            ),
                            startDegreeOffset: 250,
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 1,
                            centerSpaceRadius: 0,
                            sections: showingSections(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: media.width * 0.05),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 15,
                  ),
                  decoration: BoxDecoration(
                    color: TColor.primaryColor2.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Today's Target",
                        style: TextStyle(
                          color: TColor.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(
                        width: 95,
                        height: 30,
                        child: RoundButton(
                          title: "Check",
                          type: RoundButtonType.bgGradient,
                          fontSize: 12,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SetGoalsView(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: media.width * 0.05),
                Text(
                  "Activity Status",
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: media.width * 0.02),
                SizedBox(height: media.width * 0.05),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: media.width * 0.95,
                        padding: const EdgeInsets.symmetric(
                          vertical: 25,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(color: TColor.grey, blurRadius: 2),
                          ],
                        ),
                        child: Row(
                          children: [
                            SimpleAnimationProgressBar(
                              height: media.width * 0.85,
                              width: media.width * 0.07,
                              backgroundColor: Colors.grey.shade100,
                              foregroundColor: Colors.purple,
                              ratio: 0.5,
                              direction: Axis.vertical,
                              curve: Curves.fastLinearToSlowEaseIn,
                              duration: const Duration(seconds: 3),
                              borderRadius: BorderRadius.circular(15),
                              gradientColor: LinearGradient(
                                colors: TColor.primaryG,
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Water Intake",
                                    style: TextStyle(
                                      color: TColor.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  ShaderMask(
                                    blendMode: BlendMode.srcIn,
                                    shaderCallback: (bounds) {
                                      return LinearGradient(
                                        colors: TColor.primaryG,
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ).createShader(
                                        Rect.fromLTRB(
                                          0,
                                          0,
                                          bounds.width,
                                          bounds.height,
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "4 Liters",
                                      style: TextStyle(
                                        color: TColor.white.withOpacity(0.7),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children:
                                        waterArr.map((wObj) {
                                          var isLast = wObj == waterArr.last;
                                          return Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 4,
                                                        ),
                                                    width: 10,
                                                    height: 10,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          TColor
                                                              .secondaryColor1,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            5,
                                                          ),
                                                    ),
                                                  ),
                                                  if (!isLast)
                                                    DottedDashedLine(
                                                      height:
                                                          media.width * 0.078,
                                                      width: 0,
                                                      dashColor:
                                                          TColor
                                                              .secondaryColor1,
                                                      axis: Axis.vertical,
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(width: 10),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    wObj["title"].toString(),
                                                    style: TextStyle(
                                                      color: TColor.grey,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                  ShaderMask(
                                                    blendMode: BlendMode.srcIn,
                                                    shaderCallback: (bounds) {
                                                      return LinearGradient(
                                                        colors:
                                                            TColor.secondaryG,
                                                        begin:
                                                            Alignment
                                                                .centerLeft,
                                                        end:
                                                            Alignment
                                                                .centerRight,
                                                      ).createShader(
                                                        Rect.fromLTRB(
                                                          0,
                                                          0,
                                                          bounds.width,
                                                          bounds.height,
                                                        ),
                                                      );
                                                    },
                                                    child: Text(
                                                      wObj["subtitle"]
                                                          .toString(),
                                                      style: TextStyle(
                                                        color: TColor.white
                                                            .withOpacity(0.7),
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: media.width * 0.05),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: double.maxFinite,
                            height: media.width * 0.45,
                            padding: const EdgeInsets.symmetric(
                              vertical: 25,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(color: TColor.grey, blurRadius: 2),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Sleep",
                                  style: TextStyle(
                                    color: TColor.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                ShaderMask(
                                  blendMode: BlendMode.srcIn,
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                      colors: TColor.primaryG,
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ).createShader(
                                      Rect.fromLTRB(
                                        0,
                                        0,
                                        bounds.width,
                                        bounds.height,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "8h 20m",
                                    style: TextStyle(
                                      color: TColor.white.withOpacity(0.7),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Image.asset(
                                  "assets/img/sleep_grap.png",
                                  width: double.maxFinite,
                                  fit: BoxFit.fitWidth,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: media.width * 0.05),
                          Container(
                            width: double.maxFinite,
                            height: media.width * 0.45,
                            padding: const EdgeInsets.symmetric(
                              vertical: 25,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(color: TColor.grey, blurRadius: 2),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Calories",
                                  style: TextStyle(
                                    color: TColor.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                ShaderMask(
                                  blendMode: BlendMode.srcIn,
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                      colors: TColor.primaryG,
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ).createShader(
                                      Rect.fromLTRB(
                                        0,
                                        0,
                                        bounds.width,
                                        bounds.height,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "760 kCal",
                                    style: TextStyle(
                                      color: TColor.white.withOpacity(0.7),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    width: media.width * 0.2,
                                    height: media.width * 0.2,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: media.width * 0.16,
                                          height: media.width * 0.16,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: TColor.primaryG,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              media.width * 0.075,
                                            ),
                                          ),
                                          child: FittedBox(
                                            child: Text(
                                              "230kCal\nleft",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: TColor.white,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SimpleCircularProgressBar(
                                          progressStrokeWidth: 10,
                                          backStrokeWidth: 10,
                                          progressColors: TColor.primaryG,
                                          backColor: Colors.grey.shade100,
                                          valueNotifier: ValueNotifier(50),
                                          startAngle: -180,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: media.width * 0.1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(2, (i) {
      var color0 = TColor.secondaryColor1;

      switch (i) {
        case 0:
          return PieChartSectionData(
            color: color0,
            value: 33,
            title: '',
            radius: 55,
            titlePositionPercentageOffset: 0.55,
            badgeWidget: Text(
              "19.1",
              style: TextStyle(
                color: TColor.black,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.white,
            value: 75,
            title: '',
            radius: 45,
            titlePositionPercentageOffset: 0.55,
          );

        default:
          throw Error();
      }
    });
  }
}