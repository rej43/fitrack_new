import 'package:fitrack/common/color_extension.dart';
import 'package:fitrack/common_widget/tab_button.dart';
import 'package:fitrack/view/home/activity_traker_view.dart';
import 'package:fitrack/view/home/home_view.dart';
import 'package:fitrack/view/profile/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:fitrack/view/community/community_view.dart';

class MainTabView extends StatefulWidget {
  final int initialTab;
  const MainTabView({super.key, this.initialTab = 0});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  late int selectTab;
  final PageStorageBucket pageBucket = PageStorageBucket();
  late Widget currentTab;

  @override
  void initState() {
    super.initState();
    selectTab = widget.initialTab;
    currentTab = _getTabWidget(selectTab);
  }

  Widget _getTabWidget(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return const HomeView();
      case 1:
        return const ActivityTrackerView();
      case 3:
        return const ProfileView();
      default:
        return const HomeView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Added to prevent bottom overflow
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
        // Removed SafeArea to fix bottom overflow
        child: SizedBox(
          height: 70, // Increased height to prevent text overflow
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
                    currentTab = _getTabWidget(0);
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
                    currentTab = _getTabWidget(1);
                  });
                },
              ),
              TabButton(
                icon: "assets/img/united.png",
                label: 'Community',
                isActive: selectTab == 2,
                onTap: () {
                  setState(() {
                    selectTab = 2;
                    currentTab = const CommunityView();
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
                    currentTab = _getTabWidget(3);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
