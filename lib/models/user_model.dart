import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserModel {
  final String? id;
  final String? name;
  final String? email;
  final String? profilePicture;
  final DateTime? dateOfBirth;
  final String? gender;
  final double? height; // in cm
  final double? weight; // in kg
  final String? bodyType;
  final List<String>? fitnessGoals;
  final bool isProfileComplete;
  final DateTime? lastLogin;
  final String? disability; // Personal health data
  final String? sugarLevel; // Personal health data
  final String? bloodPressure; // Personal health data
  final String? healthNotes; // Personal health data

  UserModel({
    this.id,
    this.name,
    this.email,
    this.profilePicture,
    this.dateOfBirth,
    this.gender,
    this.height,
    this.weight,
    this.bodyType,
    this.fitnessGoals,
    this.isProfileComplete = false,
    this.lastLogin,
    this.disability,
    this.sugarLevel,
    this.bloodPressure,
    this.healthNotes,
  });

  // Calculate BMI
  double? get bmi {
    if (height != null && weight != null && height! > 0) {
      final heightInMeters = height! / 100;
      return weight! / (heightInMeters * heightInMeters);
    }
    return null;
  }

  // Get BMI category
  String? get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue == null) return null;
    
    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25) return 'Normal';
    if (bmiValue < 30) return 'Overweight';
    return 'Obese';
  }

  // Get age
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month || 
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'height': height,
      'weight': weight,
      'bodyType': bodyType,
      'fitnessGoals': fitnessGoals,
      'isProfileComplete': isProfileComplete,
      'lastLogin': lastLogin?.toIso8601String(),
      'disability': disability,
      'sugarLevel': sugarLevel,
      'bloodPressure': bloodPressure,
      'healthNotes': healthNotes,
    };
  }

  // Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      email: json['email'],
      profilePicture: json['profilePicture'],
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      gender: json['gender'],
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      bodyType: json['bodyType'],
      fitnessGoals: json['fitnessGoals'] != null 
          ? List<String>.from(json['fitnessGoals'])
          : null,
      isProfileComplete: json['isProfileComplete'] ?? false,
      lastLogin: json['lastLogin'] != null 
          ? DateTime.parse(json['lastLogin'])
          : null,
      disability: json['disability'],
      sugarLevel: json['sugarLevel'],
      bloodPressure: json['bloodPressure'],
      healthNotes: json['healthNotes'],
    );
  }

  // Create copy with updated fields
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? profilePicture,
    DateTime? dateOfBirth,
    String? gender,
    double? height,
    double? weight,
    String? bodyType,
    List<String>? fitnessGoals,
    bool? isProfileComplete,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      bodyType: bodyType ?? this.bodyType,
      fitnessGoals: fitnessGoals ?? this.fitnessGoals,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  // Save to SharedPreferences
  Future<void> saveToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(toJson()));
  }

  // Load from SharedPreferences
  static Future<UserModel?> loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      try {
        return UserModel.fromJson(jsonDecode(userData));
      } catch (e) {
        print('Error loading user data: $e');
        return null;
      }
    }
    return null;
  }

  // Clear from SharedPreferences
  static Future<void> clearFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }
} 