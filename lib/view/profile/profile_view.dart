import 'package:fitrack/common/color_extension.dart';

import 'package:fitrack/common_widget/setting_row.dart';
import 'package:fitrack/common_widget/title_subtitle_cell.dart';
import 'package:fitrack/view/profile/personaldata_view.dart';
import 'package:flutter/material.dart';
import 'package:fitrack/common_widget/round_button.dart';

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:fitrack/view/on_boarding/started_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool positive = false;

  List accountArr = [
    {"image": "assets/img/user.png", "name": "Personal Data", "tag": "1"},
  ];

  List otherArr = [
    {"image": "assets/img/contact-mail.png", "name": "Contact Us", "tag": "5"},
    {"image": "assets/img/privacy.png", "name": "Privacy Policy", "tag": "6"},
    {"image": "assets/img/setting.png", "name": "Logout", "tag": "7"},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leadingWidth: 0,
        title: Text(
          "Profile",
          style: TextStyle(
            color: TColor.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          InkWell(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: TColor.lightgrey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                "assets/img/more.png",
                width: 15,
                height: 15,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset(
                      "assets/img/u1.png",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Joe Goldberg",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Row(
                children: [
                  Expanded(
                    child: TitleSubtitleCell(
                      title: "180cm",
                      subtitle: "Height",
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: TitleSubtitleCell(title: "65kg", subtitle: "Weight"),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: TitleSubtitleCell(title: "22yo", subtitle: "Age"),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: TColor.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: TColor.grey, blurRadius: 2)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Account",
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: accountArr.length,
                      itemBuilder: (context, index) {
                        var iObj = accountArr[index] as Map? ?? {};
                        return SettingRow(
                          icon: iObj["image"].toString(),
                          title: iObj["name"].toString(),
                          onPressed: () {
                            final tag = iObj["tag"].toString();
                            if (tag == "1") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PersonalDataScreen(),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: TColor.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: TColor.grey, blurRadius: 2)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Notification",
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 30,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/img/notification.png",
                            height: 15,
                            width: 15,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              "Pop-up Notification",
                              style: TextStyle(
                                color: TColor.black,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          CustomAnimatedToggleSwitch<bool>(
                            current: positive,
                            values: [false, true],
                            dif: 0.0,
                            indicatorSize: Size.square(30.0),
                            animationDuration: const Duration(
                              milliseconds: 200,
                            ),
                            animationCurve: Curves.linear,
                            onChanged: (b) => setState(() => positive = b),
                            iconBuilder: (context, local, global) {
                              return const SizedBox();
                            },
                            defaultCursor: SystemMouseCursors.click,
                            onTap: () => setState(() => positive = !positive),
                            iconsTappable: false,
                            wrapperBuilder: (context, global, child) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  Positioned(
                                    left: 10.0,
                                    right: 10.0,

                                    height: 30.0,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: TColor.secondaryG,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(50.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                  child,
                                ],
                              );
                            },
                            foregroundIndicatorBuilder: (context, global) {
                              return SizedBox.fromSize(
                                size: const Size(10, 10),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: TColor.white,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(50.0),
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black38,
                                        spreadRadius: 0.05,
                                        blurRadius: 1.1,
                                        offset: Offset(0.0, 0.8),
                                      ),
                                    ],
                                  ),
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
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: TColor.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: TColor.grey, blurRadius: 2)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Other",
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: otherArr.length,
                      itemBuilder: (context, index) {
                        var iObj = otherArr[index] as Map? ?? {};
                        return SettingRow(
                          icon: iObj["image"].toString(),
                          title: iObj["name"].toString(),
                          onPressed: () {
                            final tag = iObj["tag"].toString();
                            if (tag == "5") {
                              showDialog(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text('Contact Us'),
                                      content: const Text(
                                        'Email: support@fitrackapp.com\nPhone: +1 234 567 8901\nAddress: 123 Fit St, Wellness City',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                              );
                            } else if (tag == "6") {
                              showDialog(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text('Privacy Policy'),
                                      content: const Text(
                                        'We value your privacy. Your data is secure and never shared with third parties. For more info, visit our website.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                              );
                            } else if (tag == "7") {
                              // Show logout confirmation dialog
                              showDialog(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text('Logout'),
                                      content: const Text(
                                        'Are you sure you want to logout?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: const Text('No'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(
                                              context,
                                            ).pushAndRemoveUntil(
                                              MaterialPageRoute(
                                                builder:
                                                    (_) => const StartedView(),
                                              ),
                                              (route) => false,
                                            );
                                          },
                                          child: const Text('Yes'),
                                        ),
                                      ],
                                    ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
