import 'package:fitrack/common/color_extension.dart';
import 'package:fitrack/common_widget/tab_button.dart';
import 'package:fitrack/view/home/home_view.dart';

import 'package:flutter/material.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int selectTab = 0;
  final PageStorageBucket pageBucket = PageStorageBucket();
  Widget currentTab = const HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: PageStorage(bucket: pageBucket, child: currentTab),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: TColor.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          // safe area for bottom notch
          child: SizedBox(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TabButton(
                  icon: "assets/img/home.png",
                  label: 'Home',
                  isActive: selectTab == 0,
                  onTap: () {
                    setState(() {
                      selectTab = 0;
                      currentTab = const HomeView();
                    });
                  },
                ),
                TabButton(
                  icon: "assets/img/activity.png",
                  label: 'Activity',
                  isActive: selectTab == 1,
                  onTap: () {
                    setState(() {
                      selectTab = 1;
                      currentTab = const HomeView(); // placeholder
                    });
                  },
                ),
                TabButton(
                  icon: "assets/img/analysis.png",
                  label: 'Analytics',
                  isActive: selectTab == 2,
                  onTap: () {
                    setState(() {
                      selectTab = 2;
                      currentTab = const HomeView(); // placeholder
                    });
                  },
                ),
                TabButton(
                  icon: "assets/img/user.png",
                  label: 'Profile',
                  isActive: selectTab == 3,
                  onTap: () {
                    setState(() {
                      selectTab = 3;
                      currentTab = const HomeView(); // placeholder
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
