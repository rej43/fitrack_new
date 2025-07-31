import 'package:fitrack/common/color_extension.dart';

import 'package:fitrack/common_widget/setting_row.dart';
import 'package:fitrack/common_widget/title_subtitle_cell.dart';
import 'package:fitrack/view/profile/personaldata_view.dart';
import 'package:flutter/material.dart';
//ignore_for_file: unused_import
import 'package:fitrack/common_widget/round_button.dart';

import 'package:fitrack/models/user_model.dart';
import 'package:fitrack/view/on_boarding/started_view.dart';
import 'package:fitrack/models/user_model.dart';
import 'package:fitrack/services/api_service.dart';
import 'package:fitrack/view/login/login_view.dart';
import 'package:fitrack/view/main_tab/maintab_view.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  UserModel? user;
  bool isLoading = true;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  List accountArr = [
    {"image": "assets/img/user.png", "name": "Personal Data", "tag": "1"},
  ];

  List otherArr = [
    {"image": "assets/img/contact-mail.png", "name": "Contact Us", "tag": "5"},
    {"image": "assets/img/privacy.png", "name": "Privacy Policy", "tag": "6"},
    {"image": "assets/img/setting.png", "name": "Logout", "tag": "7"},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _refreshUserData() async {
    await _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await UserModel.loadFromLocal();
      setState(() {
        user = userData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showEditProfileDialog() {
    final heightController = TextEditingController(
      text: user?.height?.toString() ?? '',
    );
    final weightController = TextEditingController(
      text: user?.weight?.toString() ?? '',
    );
    String? selectedGender = user?.gender;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: TColor.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Edit Profile',
              style: TextStyle(
                color: TColor.black,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: TColor.lightgrey,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      controller: heightController,
                      decoration: InputDecoration(
                        labelText: 'Height (cm)',
                        labelStyle: TextStyle(color: TColor.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: TColor.black),
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: TColor.lightgrey,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      controller: weightController,
                      decoration: InputDecoration(
                        labelText: 'Weight (kg)',
                        labelStyle: TextStyle(color: TColor.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: TColor.black),
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: TColor.lightgrey,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedGender,
                      decoration: InputDecoration(
                        labelText: 'Gender',
                        labelStyle: TextStyle(color: TColor.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                      dropdownColor: TColor.white,
                      style: TextStyle(color: TColor.black),
                      items:
                          ['Male', 'Female', 'Non-binary'].map((gender) {
                            return DropdownMenuItem(
                              value: gender,
                              child: Text(
                                gender,
                                style: TextStyle(color: TColor.black),
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        selectedGender = value;
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: TColor.grey)),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: TColor.primaryG),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    final newHeight = double.tryParse(heightController.text);
                    final newWeight = double.tryParse(weightController.text);

                    if (newHeight != null &&
                        newWeight != null &&
                        selectedGender != null) {
                      // Update user data
                      final updatedUser = user?.copyWith(
                        height: newHeight,
                        weight: newWeight,
                        gender: selectedGender,
                      );

                      if (updatedUser != null) {
                        await updatedUser.saveToLocal();
                        setState(() {
                          user = updatedUser;
                        });

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Profile updated successfully!'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );

                        Navigator.pop(context);
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please fill all fields correctly'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: TColor.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: TColor.white,
          centerTitle: true,
          elevation: 0,
          title: Text(
            "Profile",
            style: TextStyle(
              color: TColor.black,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: TColor.black),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainTabView()),
              (route) => false,
            );
          },
        ),
        title: Text(
          "Profile",
          style: TextStyle(
            color: TColor.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: TColor.primaryG),
              borderRadius: BorderRadius.circular(12),
            ),
            child: GestureDetector(
              onTap: () {
                _showEditProfileDialog();
              },
              child: Container(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.edit, color: TColor.white, size: 20),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: TColor.white,
      body: RefreshIndicator(
        onRefresh: _refreshUserData,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child:
                            _profileImage != null
                                ? Image.file(
                                  _profileImage!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                                : Image.asset(
                                  "assets/img/u1.png",
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? "Loading...",
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
                Row(
                  children: [
                    Expanded(
                      child: TitleSubtitleCell(
                        title: "${user?.height?.toStringAsFixed(0) ?? '--'}cm",
                        subtitle: "Height",
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: TitleSubtitleCell(
                        title: "${user?.weight?.toStringAsFixed(1) ?? '--'}kg",
                        subtitle: "Weight",
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: TitleSubtitleCell(
                        title: "${user?.age ?? '--'}yo",
                        subtitle: "Age",
                      ),
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
                                          'Email: support@fitrackapp.com\nPhone: +977 9886649109\nAddress: Ekantakuna, Lalitpur, Nepal',
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
                                            onPressed: () async {
                                              try {
                                                await ApiService.logout();
                                                await UserModel.clearFromLocal();
                                              } catch (e) {
                                                if (mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Logout error: ${e.toString()}',
                                                      ),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                }
                                              } finally {
                                                if (mounted) {
                                                  Navigator.of(
                                                    context,
                                                  ).pushAndRemoveUntil(
                                                    MaterialPageRoute(
                                                      builder:
                                                          (_) =>
                                                              const LoginView(),
                                                    ),
                                                    (route) => false,
                                                  );
                                                }
                                              }
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
      ),
    );
  }
}
