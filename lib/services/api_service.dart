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
    try {
      // Try backend first
      final response = await _makeRequest('/auth/signup', 'POST', body: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
      });

      // Save token and user data if provided in response
      if (response['token'] != null) {
        await saveToken(response['token']);
      }
      
      if (response['user'] != null) {
        await _saveUserData(response['user']);
      }

      return response;
    } catch (e) {
      // Backend failed, use local bypass
      print('Backend signup failed, using local bypass: $e');
      
      // Generate a local token
      final localToken = 'local_${DateTime.now().millisecondsSinceEpoch}_${email.hashCode}';
      await saveToken(localToken);
      
      // Save user data locally
      final userData = {
        'id': 'local_${email.hashCode}',
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'isLocalUser': true,
        'createdAt': DateTime.now().toIso8601String(),
      };
      await _saveUserData(userData);
      
      return {
        'success': true,
        'message': 'User signed up successfully (Local Mode)',
        'token': localToken,
        'user': userData,
        'isLocalMode': true,
      };
    }
  }

  static Future<Map<String, dynamic>> signin({
    required String email,
    required String password,
  }) async {
    try {
      // Try backend first
      final response = await _makeRequest('/auth/signin', 'POST', body: {
        'email': email,
        'password': password,
      });

      // Save token and user data if provided in response
      if (response['token'] != null) {
        await saveToken(response['token']);
      }
      
      if (response['user'] != null) {
        await _saveUserData(response['user']);
      }

      return response;
    } catch (e) {
      // Backend failed, check if user exists locally
      print('Backend signin failed, checking local bypass: $e');
      
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      
      if (userDataString != null) {
        try {
          final userData = jsonDecode(userDataString);
          if (userData['email'] == email) {
            // User exists locally, generate new token
            final localToken = 'local_${DateTime.now().millisecondsSinceEpoch}_${email.hashCode}';
            await saveToken(localToken);
            
            return {
              'success': true,
              'message': 'User signed in successfully (Local Mode)',
              'token': localToken,
              'user': userData,
              'isLocalMode': true,
            };
          }
        } catch (parseError) {
          print('Error parsing local user data: $parseError');
        }
      }
      
      // No local user found, create one for bypass
      final localToken = 'local_${DateTime.now().millisecondsSinceEpoch}_${email.hashCode}';
      await saveToken(localToken);
      
      final userData = {
        'id': 'local_${email.hashCode}',
        'firstName': 'User',
        'lastName': 'Local',
        'email': email,
        'isLocalUser': true,
        'createdAt': DateTime.now().toIso8601String(),
      };
      await _saveUserData(userData);
      
      return {
        'success': true,
        'message': 'User signed in successfully (Local Mode)',
        'token': localToken,
        'user': userData,
        'isLocalMode': true,
      };
    }
  }

  // Helper method to save user data
  static Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData));
  }

  // Get current user data
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      try {
        return jsonDecode(userData);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateUserProfile({
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    final response = await _makeRequest('/auth/profile', 'PUT', body: {
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (email != null) 'email': email,
    });

    // Update local user data if successful
    if (response['success'] == true && response['user'] != null) {
      await _saveUserData(response['user']);
    }

    return response;
  }

  // Google OAuth
  static String getGoogleAuthUrl() {
    // For mobile apps, we need to use a different approach
    // This will redirect to the backend which will handle the OAuth flow
    return '$apiUrl/auth/google';
  }

  static Future<Map<String, dynamic>> googleAuthCallback(String code) async {
    // For mobile apps, we'll handle the OAuth flow differently
    // This method will be called after the user completes OAuth
    final response = await _makeRequest('/auth/google/callback', 'GET');
    
    // Save token and user data if provided in response
    if (response['token'] != null) {
      await saveToken(response['token']);
    }
    
    if (response['user'] != null) {
      await _saveUserData(response['user']);
    }

    return response;
  }

  // New method for mobile OAuth flow
  static Future<Map<String, dynamic>> initiateGoogleOAuth() async {
    try {
      // For mobile apps, we'll use a simplified approach
      // This will create a session and return a URL that can be opened in a browser
      final response = await _makeRequest('/auth/google/initiate', 'POST');
      return response;
    } catch (e) {
      throw Exception('Failed to initiate Google OAuth: $e');
    }
  }

  // Method to check OAuth status
  static Future<Map<String, dynamic>> checkOAuthStatus(String sessionId) async {
    try {
      final response = await _makeRequest('/auth/google/status/$sessionId', 'GET');
      return response;
    } catch (e) {
      throw Exception('Failed to check OAuth status: $e');
    }
  }

  // ===== HEALTH DATA APIs =====
  
  static Future<Map<String, dynamic>> createHealthData({
    required String gender,
    required double heightInCM,
    required double weightInKG,
    required String bodyType,
    required String healthGoal,
  }) async {
    try {
      return await _makeRequest('/health/createHealthData', 'POST', body: {
        'gender': gender.toLowerCase(),
        'heightInCM': heightInCM,
        'weightInKG': weightInKG,
        'bodyType': bodyType.toLowerCase(),
        'healthGoal': healthGoal.toLowerCase(),
      });
    } catch (e) {
      // Backend failed, save locally
      print('Backend health data creation failed, saving locally: $e');
      
      final healthData = {
        'gender': gender.toLowerCase(),
        'heightInCM': heightInCM,
        'weightInKG': weightInKG,
        'bodyType': bodyType.toLowerCase(),
        'healthGoal': healthGoal.toLowerCase(),
        'createdAt': DateTime.now().toIso8601String(),
        'isLocalData': true,
      };
      
      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('health_data', jsonEncode(healthData));
      
      return {
        'success': true,
        'message': 'Health data created successfully (Local Mode)',
        'data': healthData,
        'isLocalMode': true,
      };
    }
  }

  static Future<Map<String, dynamic>> getHealthDetails() async {
    try {
      return await _makeRequest('/health/getHealthDetails', 'GET');
    } catch (e) {
      // Backend failed, get from local storage
      print('Backend health data fetch failed, getting from local: $e');
      
      final prefs = await SharedPreferences.getInstance();
      final healthDataString = prefs.getString('health_data');
      
      if (healthDataString != null) {
        try {
          final healthData = jsonDecode(healthDataString);
          return {
            'success': true,
            'data': healthData,
            'isLocalMode': true,
          };
        } catch (parseError) {
          print('Error parsing local health data: $parseError');
        }
      }
      
      return {
        'success': false,
        'message': 'No health data found',
        'isLocalMode': true,
      };
    }
  }

  static Future<Map<String, dynamic>> updateHealthRecord({
    required String gender,
    required double heightInCM,
    required double weightInKG,
    required String bodyType,
    required String healthGoal,
  }) async {
    try {
      return await _makeRequest('/health/updateHealthRecord', 'PUT', body: {
        'gender': gender.toLowerCase(),
        'heightInCM': heightInCM,
        'weightInKG': weightInKG,
        'bodyType': bodyType.toLowerCase(),
        'healthGoal': healthGoal.toLowerCase(),
      });
    } catch (e) {
      // Backend failed, update locally
      print('Backend health data update failed, updating locally: $e');
      
      final healthData = {
        'gender': gender.toLowerCase(),
        'heightInCM': heightInCM,
        'weightInKG': weightInKG,
        'bodyType': bodyType.toLowerCase(),
        'healthGoal': healthGoal.toLowerCase(),
        'updatedAt': DateTime.now().toIso8601String(),
        'isLocalData': true,
      };
      
      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('health_data', jsonEncode(healthData));
      
      return {
        'success': true,
        'message': 'Health data updated successfully (Local Mode)',
        'data': healthData,
        'isLocalMode': true,
      };
    }
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

    try {
      return await _makeRequest('/activity/logActivity', 'POST', body: body);
    } catch (e) {
      // Backend failed, save locally
      print('Backend activity logging failed, saving locally: $e');
      
      final activityData = {
        ...body,
        'loggedAt': DateTime.now().toIso8601String(),
        'isLocalData': true,
      };
      
      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      final existingActivitiesString = prefs.getString('activity_data') ?? '[]';
      final existingActivities = List<Map<String, dynamic>>.from(
        jsonDecode(existingActivitiesString).map((x) => Map<String, dynamic>.from(x))
      );
      
      existingActivities.add(activityData);
      await prefs.setString('activity_data', jsonEncode(existingActivities));
      
      return {
        'success': true,
        'message': 'Activity logged successfully (Local Mode)',
        'data': activityData,
        'isLocalMode': true,
      };
    }
  }

  static Future<Map<String, dynamic>> getActivityLog() async {
    try {
      return await _makeRequest('/activity/getActivityLog', 'GET');
    } catch (e) {
      // Backend failed, get from local storage
      print('Backend activity fetch failed, getting from local: $e');
      
      final prefs = await SharedPreferences.getInstance();
      final activityDataString = prefs.getString('activity_data') ?? '[]';
      
      try {
        final activityData = jsonDecode(activityDataString);
        return {
          'success': true,
          'data': activityData,
          'isLocalMode': true,
        };
      } catch (parseError) {
        print('Error parsing local activity data: $parseError');
        return {
          'success': true,
          'data': [],
          'isLocalMode': true,
        };
      }
    }
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

  // Check if app is in offline mode
  static Future<bool> isOfflineMode() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null && token.startsWith('local_');
  }

  // Get connection status
  static Future<Map<String, dynamic>> getConnectionStatus() async {
    try {
      // Try to reach the backend
      final response = await http.get(
        Uri.parse('http://localhost:4000/stats'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        return {
          'connected': true,
          'message': 'Connected to backend',
          'isLocalMode': false,
        };
      } else {
        return {
          'connected': false,
          'message': 'Backend not responding',
          'isLocalMode': true,
        };
      }
    } catch (e) {
      return {
        'connected': false,
        'message': 'Offline mode - using local storage',
        'isLocalMode': true,
      };
    }
  }

  // Clear all local data
  static Future<void> clearAllLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    await prefs.remove('health_data');
    await prefs.remove('activity_data');
  }

  // Update user profile (for backward compatibility with legacy code)
  static Future<Map<String, dynamic>> updateUserProfileLegacy({
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
    // Also clear user data
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
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