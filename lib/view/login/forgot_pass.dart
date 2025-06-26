import 'package:fitrack/view/login/login_view.dart';
import 'package:flutter/material.dart';
import 'package:fitrack/common/color_extension.dart';
import 'package:fitrack/common_widget/round_button.dart';
import 'package:fitrack/common_widget/round_textfiled.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  int step = 0;

  final TextEditingController _emailController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _buildEmailStep(BuildContext context, Size media) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: media.width * 0.1),
        Image.asset(
          "assets/img/forgot_pass1.png",
          height: media.width * 0.4,
          fit: BoxFit.contain,
        ),
        SizedBox(height: media.width * 0.05),
        Text(
          "Forgot Password",
          style: TextStyle(
            color: TColor.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: media.width * 0.05),
        Text(
          "Please enter your email address to receive a verification code",
          textAlign: TextAlign.center,
          style: TextStyle(color: TColor.grey, fontSize: 14),
        ),
        SizedBox(height: media.width * 0.05),
        RoundTextField(
          hitText: "Email",
          icon: "assets/img/email.png",
          keyboardType: TextInputType.emailAddress,
          controller: _emailController,
        ),
        const Spacer(),
        RoundButton(
          title: "Verify",
          onPressed: () {
            setState(() => step = 1);
          },
        ),
        SizedBox(height: media.width * 0.04),
      ],
    );
  }

  Widget _buildOtpStep(BuildContext context, Size media) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: media.width * 0.1),
        Image.asset(
          "assets/img/forgot_pass2.png",
          height: media.width * 0.4,
          fit: BoxFit.contain,
        ),
        SizedBox(height: media.width * 0.05),
        Text(
          "Enter 4-digit code",
          style: TextStyle(
            color: TColor.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: media.width * 0.02),
        Text(
          "Enter the 4-digit code that you received on your mail",
          textAlign: TextAlign.center,
          style: TextStyle(color: TColor.grey, fontSize: 14),
        ),
        SizedBox(height: media.width * 0.05),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (i) {
            return SizedBox(
              width: 50,
              child: TextField(
                controller: _otpControllers[i],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                decoration: InputDecoration(
                  counterText: "",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: TColor.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: TColor.primaryColor1),
                  ),
                ),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                onChanged: (val) {
                  if (val.length == 1 && i < 3) {
                    FocusScope.of(context).nextFocus();
                  }
                },
              ),
            );
          }),
        ),
        const Spacer(),
        RoundButton(
          title: "Verify OTP",
          onPressed: () {
            setState(() => step = 2);
          },
        ),
        SizedBox(height: media.width * 0.04),
      ],
    );
  }

  Widget _buildResetStep(BuildContext context, Size media) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: media.width * 0.1),
        Image.asset(
          "assets/img/forgot_pass3.png",
          height: media.width * 0.4,
          fit: BoxFit.contain,
        ),
        SizedBox(height: media.width * 0.05),
        Text(
          "Password Reset",
          style: TextStyle(
            color: TColor.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: media.width * 0.02),
        RoundTextField(
          hitText: "Enter New Password",
          icon: "assets/img/lock.png",
          obscureText: true,
          controller: _newPasswordController,
        ),
        SizedBox(height: media.width * 0.04),
        RoundTextField(
          hitText: "Confirm Password",
          icon: "assets/img/lock.png",
          obscureText: true,
          controller: _confirmPasswordController,
        ),
        const Spacer(),
        RoundButton(
          title: "Reset Password",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginView()),
            );
            // Show success message after navigation
            Future.delayed(const Duration(milliseconds: 300), () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Password reset successful"),
                  backgroundColor: Colors.green,
                ),
              );
            });
          },
        ),
        SizedBox(height: media.width * 0.04),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: SafeArea(
        child: Container(
          height: media.height * 0.9,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child:
              step == 0
                  ? _buildEmailStep(context, media)
                  : step == 1
                  ? _buildOtpStep(context, media)
                  : _buildResetStep(context, media),
        ),
      ),
    );
  }
}
