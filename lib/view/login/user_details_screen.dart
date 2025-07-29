// lib/view/onboarding/user_details_screen.dart
import 'package:fitrack/common_widget/body_type_selector.dart.dart';
import 'package:fitrack/common_widget/round_button.dart';
import 'package:flutter/material.dart';
import 'package:fitrack/view/home/home_view.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  BodyType? selectedBodyType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            BodyTypeSelector(
              onChanged: (type) {
                setState(() => selectedBodyType = type);
              },
            ),
            const Spacer(),
            RoundButton(
              title: 'Continue',
              onPressed:
                  selectedBodyType == null
                      ? () {}
                      : () {
                        // Save body type and navigate to home
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeView(),
                          ),
                        );
                      },
            ),
          ],
        ),
      ),
    );
  }
}
