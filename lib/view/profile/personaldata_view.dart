import 'package:fitrack/common_widget/round_button.dart';
import 'package:flutter/material.dart';
import 'package:fitrack/common/color_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  // ignore_for_file: unused_import
  final FocusNode _focusNode = FocusNode();
  bool isLoading = true;
  
  // Add controllers for proper data persistence
  late TextEditingController disabilityController;
  late TextEditingController sugarController;
  late TextEditingController bpController;
  late TextEditingController notesController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    disabilityController = TextEditingController();
    sugarController = TextEditingController();
    bpController = TextEditingController();
    notesController = TextEditingController();
    _loadPersonalData();
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    disabilityController.dispose();
    sugarController.dispose();
    bpController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _loadPersonalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        disability = prefs.getString('personal_disability') ?? '';
        sugar = prefs.getString('personal_sugar') ?? '';
        bp = prefs.getString('personal_bp') ?? '';
        notes = prefs.getString('personal_notes') ?? '';
        
        // Set controller values
        disabilityController.text = disability ?? '';
        sugarController.text = sugar ?? '';
        bpController.text = bp ?? '';
        notesController.text = notes ?? '';
        
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      FocusScope.of(context).unfocus();
      
      try {
        // Get values from controllers
        final disabilityValue = disabilityController.text;
        final sugarValue = sugarController.text;
        final bpValue = bpController.text;
        final notesValue = notesController.text;
        
        // Save personal data to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('personal_disability', disabilityValue);
        await prefs.setString('personal_sugar', sugarValue);
        await prefs.setString('personal_bp', bpValue);
        await prefs.setString('personal_notes', notesValue);
        
        // Update local variables
        setState(() {
          disability = disabilityValue;
          sugar = sugarValue;
          bp = bpValue;
          notes = notesValue;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Personal data saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving data: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
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
              _buildTextFieldWithController('Disability (if any)', disabilityController),
              const SizedBox(height: 12),
              _buildTextFieldWithController('Sugar Level', sugarController),
              const SizedBox(height: 12),
              _buildTextFieldWithController('Blood Pressure', bpController),
              const SizedBox(height: 12),
              _buildTextFieldWithController('Other Notes', notesController),
              const SizedBox(height: 24),
              RoundButton(title: 'Save', onPressed: _saveData),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldWithController(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
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
      onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
    );
  }
}
