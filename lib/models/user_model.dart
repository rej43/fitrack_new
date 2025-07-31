import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Legacy UserModel class for backward compatibility
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

// New User class for backend integration
class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? googleId;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.googleId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      googleId: json['googleId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'googleId': googleId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';
}

// Health Data Model
class HealthData {
  final String id;
  final String gender;
  final double heightInCM;
  final double weightInKG;
  final String bodyType;
  final String healthGoal;
  final DateTime createdAt;
  final DateTime updatedAt;

  HealthData({
    required this.id,
    required this.gender,
    required this.heightInCM,
    required this.weightInKG,
    required this.bodyType,
    required this.healthGoal,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HealthData.fromJson(Map<String, dynamic> json) {
    return HealthData(
      id: json['_id'] ?? json['id'],
      gender: json['gender'] ?? '',
      heightInCM: (json['heightInCM'] ?? 0).toDouble(),
      weightInKG: (json['weightInKG'] ?? 0).toDouble(),
      bodyType: json['bodyType'] ?? '',
      healthGoal: json['healthGoal'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gender': gender,
      'heightInCM': heightInCM,
      'weightInKG': weightInKG,
      'bodyType': bodyType,
      'healthGoal': healthGoal,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  double get bmi {
    final heightInMeters = heightInCM / 100;
    return weightInKG / (heightInMeters * heightInMeters);
  }
}

// Activity Data Model
class ActivityData {
  final String id;
  final String userId;
  final DateTime date;
  final double? sleepHours;
  final int? steps;
  final double? waterIntake;
  final double? foodCalories;
  final DateTime createdAt;
  final DateTime updatedAt;

  ActivityData({
    required this.id,
    required this.userId,
    required this.date,
    this.sleepHours,
    this.steps,
    this.waterIntake,
    this.foodCalories,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ActivityData.fromJson(Map<String, dynamic> json) {
    return ActivityData(
      id: json['_id'] ?? json['id'],
      userId: json['userId'] ?? '',
      date: DateTime.parse(json['date']),
      sleepHours: json['sleepHours']?.toDouble(),
      steps: json['steps'],
      waterIntake: json['waterIntake']?.toDouble(),
      foodCalories: json['foodCalories']?.toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'sleepHours': sleepHours,
      'steps': steps,
      'waterIntake': waterIntake,
      'foodCalories': foodCalories,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// API Response Models
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? token;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.token,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>)? fromJson) {
    return ApiResponse<T>(
      success: json['success'] ?? true,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJson != null ? fromJson(json['data']) : null,
      token: json['token'],
    );
  }
}

// Enums for data validation
enum Gender {
  male,
  female,
}

enum BodyType {
  skinny,
  fat,
  normal,
  athlete,
  bulky,
  muscular,
  obese,
}

enum HealthGoal {
  muscle_gain,
  fat_loss,
  building_strength,
  bulking,
}

// Extension methods for enum conversion
extension GenderExtension on Gender {
  String get value {
    switch (this) {
      case Gender.male:
        return 'male';
      case Gender.female:
        return 'female';
    }
  }

  static Gender fromString(String value) {
    switch (value.toLowerCase()) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      default:
        return Gender.male;
    }
  }
}

extension BodyTypeExtension on BodyType {
  String get value {
    switch (this) {
      case BodyType.skinny:
        return 'skinny';
      case BodyType.fat:
        return 'fat';
      case BodyType.normal:
        return 'normal';
      case BodyType.athlete:
        return 'athlete';
      case BodyType.bulky:
        return 'bulky';
      case BodyType.muscular:
        return 'muscular';
      case BodyType.obese:
        return 'obese';
    }
  }

  static BodyType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'skinny':
        return BodyType.skinny;
      case 'fat':
        return BodyType.fat;
      case 'normal':
        return BodyType.normal;
      case 'athlete':
        return BodyType.athlete;
      case 'bulky':
        return BodyType.bulky;
      case 'muscular':
        return BodyType.muscular;
      case 'obese':
        return BodyType.obese;
      default:
        return BodyType.normal;
    }
  }
}

extension HealthGoalExtension on HealthGoal {
  String get value {
    switch (this) {
      case HealthGoal.muscle_gain:
        return 'muscle_gain';
      case HealthGoal.fat_loss:
        return 'fat_loss';
      case HealthGoal.building_strength:
        return 'building_strength';
      case HealthGoal.bulking:
        return 'bulking';
    }
  }

  static HealthGoal fromString(String value) {
    switch (value.toLowerCase()) {
      case 'muscle_gain':
        return HealthGoal.muscle_gain;
      case 'fat_loss':
        return HealthGoal.fat_loss;
      case 'building_strength':
        return HealthGoal.building_strength;
      case 'bulking':
        return HealthGoal.bulking;
      default:
        return HealthGoal.muscle_gain;
    }
  }
} 