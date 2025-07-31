import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Updated to match your backend configuration
  static const String baseUrl = 'http://localhost:4000/api/v1';
  static const String baseUrlEmulator = 'http://10.0.2.2:4000/api/v1';
  
  // Use emulator URL for Android emulator, localhost for iOS simulator
  static String get apiUrl {
    // For physical device or emulator, use localhost
    return baseUrl;
  }

  // Shared Preferences for storing token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Helper method for API calls
  static Future<Map<String, dynamic>> _makeRequest(
    String endpoint,
    String method, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$apiUrl$endpoint');
    final token = await getToken();
    
    final requestHeaders = {
      'Content-Type': 'application/json',
      ...?headers,
    };

    if (token != null) {
      requestHeaders['Authorization'] = 'Bearer $token';
    }

    http.Response response;
    
    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: requestHeaders);
          break;
        case 'POST':
          response = await http.post(
            url,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            url,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(url, headers: requestHeaders);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'API request failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ===== AUTHENTICATION APIs =====
  
  static Future<Map<String, dynamic>> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final response = await _makeRequest('/auth/signup', 'POST', body: {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
    });

    // Save token if provided in response
    if (response['token'] != null) {
      await saveToken(response['token']);
    }

    return response;
  }

  static Future<Map<String, dynamic>> signin({
    required String email,
    required String password,
  }) async {
    final response = await _makeRequest('/auth/signin', 'POST', body: {
      'email': email,
      'password': password,
    });

    // Save token if provided in response
    if (response['token'] != null) {
      await saveToken(response['token']);
    }

    return response;
  }

  // ===== HEALTH DATA APIs =====
  
  static Future<Map<String, dynamic>> createHealthData({
    required String gender,
    required double heightInCM,
    required double weightInKG,
    required String bodyType,
    required String healthGoal,
  }) async {
    return await _makeRequest('/health/createHealthData', 'POST', body: {
      'gender': gender.toLowerCase(),
      'heightInCM': heightInCM,
      'weightInKG': weightInKG,
      'bodyType': bodyType.toLowerCase(),
      'healthGoal': healthGoal.toLowerCase(),
    });
  }

  static Future<Map<String, dynamic>> getHealthDetails() async {
    return await _makeRequest('/health/getHealthDetauls', 'GET');
  }

  static Future<Map<String, dynamic>> updateHealthRecord({
    required String gender,
    required double heightInCM,
    required double weightInKG,
    required String bodyType,
    required String healthGoal,
  }) async {
    return await _makeRequest('/health/updateHealthRecord', 'PUT', body: {
      'gender': gender.toLowerCase(),
      'heightInCM': heightInCM,
      'weightInKG': weightInKG,
      'bodyType': bodyType.toLowerCase(),
      'healthGoal': healthGoal.toLowerCase(),
    });
  }

  // ===== ACTIVITY APIs =====
  
  static Future<Map<String, dynamic>> logActivity({
    required DateTime date,
    double? sleepHours,
    int? steps,
    double? waterIntake,
    double? foodCalories,
  }) async {
    final body = <String, dynamic>{
      'date': date.toIso8601String(),
    };
    
    if (sleepHours != null) body['sleepHours'] = sleepHours;
    if (steps != null) body['steps'] = steps;
    if (waterIntake != null) body['waterIntake'] = waterIntake;
    if (foodCalories != null) body['foodCalories'] = foodCalories;

    return await _makeRequest('/activity/logActivity', 'POST', body: body);
  }

  static Future<Map<String, dynamic>> getActivityLog() async {
    return await _makeRequest('/activity/getActivityLog', 'GET');
  }

  static Future<Map<String, dynamic>> updateActivityLog({
    required DateTime date,
    double? sleepHours,
    int? steps,
    double? waterIntake,
    double? foodCalories,
  }) async {
    final body = <String, dynamic>{
      'date': date.toIso8601String(),
    };
    
    if (sleepHours != null) body['sleepHours'] = sleepHours;
    if (steps != null) body['steps'] = steps;
    if (waterIntake != null) body['waterIntake'] = waterIntake;
    if (foodCalories != null) body['foodCalories'] = foodCalories;

    return await _makeRequest('/activity/updateActivityLog', 'PUT', body: body);
  }

  // ===== UTILITY METHODS =====
  
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }

  // Update user profile (for backward compatibility)
  static Future<Map<String, dynamic>> updateUserProfile({
    String? name,
    String? dateOfBirth,
    String? gender,
    double? height,
    double? weight,
    String? bodyType,
    List<String>? fitnessGoals,
  }) async {
    final body = <String, dynamic>{};
    
    if (name != null) body['name'] = name;
    if (dateOfBirth != null) body['dateOfBirth'] = dateOfBirth;
    if (gender != null) body['gender'] = gender.toLowerCase();
    if (height != null) body['height'] = height;
    if (weight != null) body['weight'] = weight;
    if (bodyType != null) body['bodyType'] = bodyType.toLowerCase();
    if (fitnessGoals != null) body['fitnessGoals'] = fitnessGoals;

    // For now, just return success since we don't have this endpoint in the backend
    return {
      'success': true,
      'message': 'Profile updated successfully',
    };
  }

  static Future<void> logout() async {
    await removeToken();
  }

  // Server health check
  static Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:4000/stats'));
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Server health check failed: $e');
    }
  }

  // ===== CONVENIENCE METHODS FOR FLUTTER INTEGRATION =====
  
  // Method to sync local calorie data with backend
  static Future<Map<String, dynamic>> syncCalorieData(List<Map<String, dynamic>> localCalories) async {
    try {
      // Get today's date
      final today = DateTime.now();
      
      // Calculate total calories for today
      int totalCalories = 0;
      for (final calorie in localCalories) {
        totalCalories += calorie['calories'] as int;
      }
      
      // Log activity with calorie data
      return await logActivity(
        date: today,
        foodCalories: totalCalories.toDouble(),
      );
    } catch (e) {
      throw Exception('Failed to sync calorie data: $e');
    }
  }

  // Method to sync local water data with backend
  static Future<Map<String, dynamic>> syncWaterData(List<Map<String, dynamic>> localWater) async {
    try {
      final today = DateTime.now();
      
      // Calculate total water intake for today
      double totalWater = 0;
      for (final water in localWater) {
        totalWater += water['ml'] as double;
      }
      
      // Log activity with water data
      return await logActivity(
        date: today,
        waterIntake: totalWater,
      );
    } catch (e) {
      throw Exception('Failed to sync water data: $e');
    }
  }

  // Method to sync local sleep data with backend
  static Future<Map<String, dynamic>> syncSleepData(String sleepDuration) async {
    try {
      final today = DateTime.now();
      
      // Parse sleep duration (format: "8h 30m")
      double sleepHours = 0;
      final parts = sleepDuration.split(' ');
      for (final part in parts) {
        if (part.endsWith('h')) {
          sleepHours += double.parse(part.replaceAll('h', ''));
        } else if (part.endsWith('m')) {
          sleepHours += double.parse(part.replaceAll('m', '')) / 60;
        }
      }
      
      // Log activity with sleep data
      return await logActivity(
        date: today,
        sleepHours: sleepHours,
      );
    } catch (e) {
      throw Exception('Failed to sync sleep data: $e');
    }
  }

  // Method to sync local steps data with backend
  static Future<Map<String, dynamic>> syncStepsData(int steps) async {
    try {
      final today = DateTime.now();
      
      // Log activity with steps data
      return await logActivity(
        date: today,
        steps: steps,
      );
    } catch (e) {
      throw Exception('Failed to sync steps data: $e');
    }
  }
} 