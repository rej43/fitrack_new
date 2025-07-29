import 'package:flutter/material.dart';
import 'package:fitrack/common/color_extension.dart';
import 'package:fitrack/common_widget/body_type_selector.dart.dart';
import 'package:fitrack/common_widget/round_button.dart';
import 'package:fitrack/view/login/goal_view.dart';

class BodyTypeSelectionPage extends StatefulWidget {
  const BodyTypeSelectionPage({super.key});

  @override
  _BodyTypeSelectionPageState createState() => _BodyTypeSelectionPageState();
}

class _BodyTypeSelectionPageState extends State<BodyTypeSelectionPage> {
  BodyType? _selectedBodyType;

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              SizedBox(height: media.width * 0.05),
              Image.asset(
                "assets/img/complete_profile.png",
                width: media.width,
                height: 200,
              ),
              SizedBox(height: media.width * 0.05),
              Text(
                "Select your body type",
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                "This helps us personalize your fitness journey",
                style: TextStyle(color: TColor.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: media.width * 0.08),
              Expanded(
                child: BodyTypeSelector(
                  onChanged: (BodyType? type) {
                    setState(() {
                      _selectedBodyType = type;
                    });
                  },
                ),
              ),
              SizedBox(height: media.width * 0.05),
              RoundButton(
                title: "Continue",
                onPressed:
                    _selectedBodyType != null
                        ? () {
                          // Navigate to next screen or save the body type
                          print("Selected body type: $_selectedBodyType");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GoalView(),
                            ),
                          );
                        }
                        : () {},
              ),
              SizedBox(height: media.width * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
