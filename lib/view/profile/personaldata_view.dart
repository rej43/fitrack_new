import 'package:fitrack/common_widget/round_button.dart';
import 'package:flutter/material.dart';
import 'package:fitrack/common/color_extension.dart';

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({Key? key}) : super(key: key);

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  final _formKey = GlobalKey<FormState>();
  String? disability;
  String? sugar;
  String? bp;
  String? notes;

  final FocusNode _focusNode = FocusNode();

  void _saveData() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Personal data saved.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.primaryColor1,
        title: const Text(
          'Personal Health Data',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Your Health Details',
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField('Disability (if any)', (val) => disability = val),
              const SizedBox(height: 12),
              _buildTextField('Sugar Level', (val) => sugar = val),
              const SizedBox(height: 12),
              _buildTextField('Blood Pressure', (val) => bp = val),
              const SizedBox(height: 12),
              _buildTextField('Other Notes', (val) => notes = val),
              const SizedBox(height: 24),
              RoundButton(title: 'Save', onPressed: _saveData),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, Function(String?) onSaved) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: TColor.black),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: TColor.primaryColor1),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: TColor.primaryColor1),
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: TColor.white,
      ),
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
      onSaved: onSaved,
      onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
    );
  }
}
