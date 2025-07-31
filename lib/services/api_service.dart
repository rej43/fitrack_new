import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';
  static const String baseUrlEmulator = 'http://10.0.2.2:5000/api';
  
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

  // Authentication APIs
  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _makeRequest('/auth/signup', 'POST', body: {
      'name': name,
      'email': email,
      'password': password,
    });

    if (response['success'] && response['data']['token'] != null) {
      await saveToken(response['data']['token']);
    }

    return response;
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _makeRequest('/auth/login', 'POST', body: {
      'email': email,
      'password': password,
    });

    if (response['success'] && response['data']['token'] != null) {
      await saveToken(response['data']['token']);
    }

    return response;
  }

  static Future<Map<String, dynamic>> googleLogin({
    required String googleId,
    required String name,
    required String email,
    String? profilePicture,
  }) async {
    final response = await _makeRequest('/auth/google', 'POST', body: {
      'googleId': googleId,
      'name': name,
      'email': email,
      if (profilePicture != null) 'profilePicture': profilePicture,
    });

    if (response['success'] && response['data']['token'] != null) {
      await saveToken(response['data']['token']);
    }

    return response;
  }

  static Future<Map<String, dynamic>> facebookLogin({
    required String facebookId,
    required String name,
    required String email,
    String? profilePicture,
  }) async {
    final response = await _makeRequest('/auth/facebook', 'POST', body: {
      'facebookId': facebookId,
      'name': name,
      'email': email,
      if (profilePicture != null) 'profilePicture': profilePicture,
    });

    if (response['success'] && response['data']['token'] != null) {
      await saveToken(response['data']['token']);
    }

    return response;
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    return await _makeRequest('/auth/me', 'GET');
  }

  static Future<Map<String, dynamic>> logout() async {
    final response = await _makeRequest('/auth/logout', 'POST');
    await removeToken();
    return response;
  }

  // User Profile APIs
  static Future<Map<String, dynamic>> getUserProfile() async {
    return await _makeRequest('/user/profile', 'GET');
  }

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

    return await _makeRequest('/user/profile', 'PUT', body: body);
  }

  // Fitness Data APIs
  static Future<Map<String, dynamic>> saveFitnessData({
    required DateTime date,
    int? steps,
    double? calories,
    double? waterIntake,
    double? sleepHours,
    double? weight,
  }) async {
    final body = <String, dynamic>{
      'date': date.toIso8601String(),
    };
    
    if (steps != null) body['steps'] = steps;
    if (calories != null) body['calories'] = calories;
    if (waterIntake != null) body['waterIntake'] = waterIntake;
    if (sleepHours != null) body['sleepHours'] = sleepHours;
    if (weight != null) body['weight'] = weight;

    return await _makeRequest('/fitness/data', 'POST', body: body);
  }

  static Future<Map<String, dynamic>> getTodayFitnessData() async {
    return await _makeRequest('/fitness/data/today', 'GET');
  }

  static Future<Map<String, dynamic>> getFitnessData({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    
    if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
    if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
    if (limit != null) queryParams['limit'] = limit.toString();

    final queryString = queryParams.isNotEmpty 
        ? '?${Uri(queryParameters: queryParams).query}'
        : '';

    return await _makeRequest('/fitness/data$queryString', 'GET');
  }

  static Future<Map<String, dynamic>> getFitnessStats({
    String period = 'week',
  }) async {
    return await _makeRequest('/fitness/stats?period=$period', 'GET');
  }

  // Health check
  static Future<Map<String, dynamic>> healthCheck() async {
    return await _makeRequest('/health', 'GET');
  }
} 