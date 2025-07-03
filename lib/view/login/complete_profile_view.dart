import 'package:fitrack/common/color_extension.dart';
import 'package:fitrack/common_widget/round_textfiled.dart';
import 'package:fitrack/view/login/goal_view.dart';
import 'package:fitrack/view/login/body_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fitrack/common_widget/round_button.dart';
import 'package:fitrack/common_widget/round_input_container.dart';

class CompleteProfileView extends StatefulWidget {
  const CompleteProfileView({super.key});

  @override
  State<CompleteProfileView> createState() => _CompleteProfileViewState();
}

class _CompleteProfileViewState extends State<CompleteProfileView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _dateOfBirthController = TextEditingController();

  String? _selectedGender;
  String? _genderErrorText;

  double _selectedWeight = 60.0;
  double _selectedHeight = 170.0;
  String? _weightErrorText;
  String? _heightErrorText;

  List<double> weightOptions = List.generate(
    1001,
    (index) => 30.0 + index * 0.1,
  );
  List<double> heightOptions = List.generate(
    801,
    (index) => 120.0 + index * 0.1,
  );

  @override
  void dispose() {
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _dateOfBirthController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _showPicker(
    BuildContext context,
    List<double> options,
    double initialValue,
    String type,
  ) {
    FixedExtentScrollController scrollController = FixedExtentScrollController(
      initialItem: options.indexOf(initialValue),
    );

    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: MediaQuery.of(context).copyWith().size.height / 3,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerRight,
                child: CupertinoButton(
                  child: Text(
                    'Done',
                    style: TextStyle(color: TColor.primaryColor1),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: scrollController,
                  itemExtent: 32.0,
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      if (type == "weight") {
                        _selectedWeight = options[index];
                        _weightErrorText = null;
                      } else {
                        _selectedHeight = options[index];
                        _heightErrorText = null;
                      }
                    });
                  },
                  children:
                      options.map((value) {
                        return Text(
                          value.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 20),
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset(
                    "assets/img/complete_profile.png",
                    width: media.width,
                    height: 325,
                  ),
                  Text(
                    "Let's complete your profile",
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    "It will help us to know more about you!",
                    style: TextStyle(color: TColor.black, fontSize: 11),
                  ),
                  SizedBox(height: media.width * 0.05),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: TColor.lightgrey,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    width: 50,
                                    height: 50,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                    ),
                                    child: Image.asset(
                                      "assets/img/gender.png",
                                      width: 20,
                                      height: 20,
                                      fit: BoxFit.contain,
                                      color: TColor.grey,
                                    ),
                                  ),
                                  Expanded(
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedGender,
                                        items:
                                            ["Male", "Female", "Non-binary"]
                                                .map(
                                                  (name) => DropdownMenuItem(
                                                    value: name,
                                                    child: Text(
                                                      name,
                                                      style: TextStyle(
                                                        color: TColor.black,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedGender = value;
                                            _genderErrorText = null;
                                          });
                                        },
                                        isExpanded: true,
                                        hint: Text(
                                          "Choose Gender",
                                          style: TextStyle(
                                            color: TColor.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                              if (_genderErrorText != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 15,
                                    bottom: 8,
                                  ),
                                  child: Text(
                                    _genderErrorText!,
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: media.width * 0.04),
                        RoundTextField(
                          controller: _dateOfBirthController,
                          hitText: "Date of Birth",
                          icon: "assets/img/calendar.png",
                          keyboardType: TextInputType.datetime,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your date of birth.';
                            }
                            return null;
                          },
                          rightIcon: IconButton(
                            icon: Icon(
                              Icons.calendar_today,
                              color: TColor.grey,
                              size: 20,
                            ),
                            onPressed: () => _selectDate(context),
                          ),
                        ),
                        SizedBox(height: media.width * 0.04),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RoundInputContainer(
                              icon: "assets/img/weight.png",
                              mainContent: GestureDetector(
                                onTap: () {
                                  _showPicker(
                                    context,
                                    weightOptions,
                                    _selectedWeight,
                                    "weight",
                                  );
                                },
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "${_selectedWeight.toStringAsFixed(1)} kg",
                                    style: TextStyle(
                                      color: TColor.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (_weightErrorText != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 15,
                                  top: 4,
                                ),
                                child: Text(
                                  _weightErrorText!,
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: media.width * 0.04),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RoundInputContainer(
                              icon: "assets/img/height.png",
                              mainContent: GestureDetector(
                                onTap: () {
                                  _showPicker(
                                    context,
                                    heightOptions,
                                    _selectedHeight,
                                    "height",
                                  );
                                },
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "${_selectedHeight.toStringAsFixed(1)} cm",
                                    style: TextStyle(
                                      color: TColor.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (_heightErrorText != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 15,
                                  top: 4,
                                ),
                                child: Text(
                                  _heightErrorText!,
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: media.width * 0.07),
                        RoundButton(
                          title: "Next >",
                          onPressed: () {
                            bool isFormValid =
                                _formKey.currentState?.validate() ?? false;
                            bool isGenderSelected = _selectedGender != null;

                            setState(() {
                              _genderErrorText =
                                  isGenderSelected
                                      ? null
                                      : 'Please select your gender.';
                              _weightErrorText =
                                  (_selectedWeight == 60.0) &&
                                          (weightOptions.indexOf(60.0) == 0)
                                      ? 'Please select your weight.'
                                      : null;
                              _heightErrorText =
                                  (_selectedHeight == 170.0) &&
                                          (heightOptions.indexOf(170.0) == 0)
                                      ? 'Please select your height.'
                                      : null;
                            });

                            if (isFormValid &&
                                isGenderSelected &&
                                !(_selectedWeight == 60.0 &&
                                    weightOptions.indexOf(60.0) == 0) &&
                                !(_selectedHeight == 170.0 &&
                                    heightOptions.indexOf(170.0) == 0)) {
                              print("Gender: $_selectedGender");
                              print(
                                "Date of Birth: ${_dateOfBirthController.text}",
                              );
                              print("Weight: $_selectedWeight KG");
                              print("Height: $_selectedHeight CM");

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const BodyTypeSelectionPage(),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Please fill in all required fields correctly.",
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
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
      ),
    );
  }
}
