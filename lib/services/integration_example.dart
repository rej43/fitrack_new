import 'package:flutter/material.dart';
import 'package:fitrack/services/api_service.dart';
import 'package:fitrack/services/data_sync_service.dart';
import 'package:fitrack/models/user_model.dart';

// Example of how to integrate the backend API with your Flutter app

class BackendIntegrationExample {
  
  // ===== AUTHENTICATION INTEGRATION =====
  
  // Example: User registration
  static Future<void> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiService.signup(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );
      
      print('User registered successfully: ${response['message']}');
      
      // Save user data locally
      if (response['data'] != null) {
        final user = User.fromJson(response['data']);
        await DataSyncService.saveUserDataLocally(user);
      }
      
    } catch (e) {
      print('Registration failed: $e');
      rethrow;
    }
  }
  
  // Example: User login
  static Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiService.signin(
        email: email,
        password: password,
      );
      
      print('User logged in successfully: ${response['message']}');
      
      // Save user data locally
      if (response['data'] != null) {
        final user = User.fromJson(response['data']);
        await DataSyncService.saveUserDataLocally(user);
      }
      
      // Sync existing local data with backend
      await DataSyncService.syncAllDataWithBackend();
      
    } catch (e) {
      print('Login failed: $e');
      rethrow;
    }
  }
  
  // ===== HEALTH DATA INTEGRATION =====
  
  // Example: Create health profile
  static Future<void> createHealthProfile({
    required Gender gender,
    required double heightInCM,
    required double weightInKG,
    required BodyType bodyType,
    required HealthGoal healthGoal,
  }) async {
    try {
      final response = await ApiService.createHealthData(
        gender: gender.value,
        heightInCM: heightInCM,
        weightInKG: weightInKG,
        bodyType: bodyType.value,
        healthGoal: healthGoal.value,
      );
      
      print('Health profile created: ${response['message']}');
      
      // Save health data locally
      if (response['data'] != null) {
        final healthData = HealthData.fromJson(response['data']);
        await DataSyncService.saveHealthDataLocally(healthData);
      }
      
    } catch (e) {
      print('Health profile creation failed: $e');
      rethrow;
    }
  }
  
  // ===== ACTIVITY DATA INTEGRATION =====
  
  // Example: Log calorie data
  static Future<void> logCalorieData({
    required String foodName,
    required int calories,
  }) async {
    try {
      // Create calorie data entry
      final calorieData = {
        'foodName': foodName,
        'calories': calories,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      // Add to local storage and sync with backend
      await DataSyncService.addCalorieData(calorieData);
      
      print('Calorie data logged successfully');
      
    } catch (e) {
      print('Failed to log calorie data: $e');
      rethrow;
    }
  }
  
  // Example: Log water intake
  static Future<void> logWaterIntake({
    required double ml,
  }) async {
    try {
      // Create water data entry
      final waterData = {
        'ml': ml,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      // Add to local storage and sync with backend
      await DataSyncService.addWaterData(waterData);
      
      print('Water intake logged successfully');
      
    } catch (e) {
      print('Failed to log water intake: $e');
      rethrow;
    }
  }
  
  // Example: Log sleep data
  static Future<void> logSleepData({
    required int hours,
    required int minutes,
  }) async {
    try {
      final sleepDuration = '${hours}h ${minutes}m';
      
      // Update local storage and sync with backend
      await DataSyncService.updateSleepData(sleepDuration);
      
      print('Sleep data logged successfully');
      
    } catch (e) {
      print('Failed to log sleep data: $e');
      rethrow;
    }
  }
  
  // Example: Log steps data
  static Future<void> logStepsData({
    required int steps,
  }) async {
    try {
      // Update local storage and sync with backend
      await DataSyncService.updateStepsData(steps);
      
      print('Steps data logged successfully');
      
    } catch (e) {
      print('Failed to log steps data: $e');
      rethrow;
    }
  }
  
  // ===== DATA RETRIEVAL INTEGRATION =====
  
  // Example: Get today's activity summary
  static Future<Map<String, dynamic>> getTodaySummary() async {
    try {
      // Get local data summary
      final localSummary = await DataSyncService.getTodayDataSummary();
      
      // If authenticated, also get backend data
      if (await ApiService.isAuthenticated()) {
        try {
          final backendActivity = await ApiService.getActivityLog();
          // Merge backend data with local data if needed
          print('Backend activity data retrieved');
        } catch (e) {
          print('Failed to get backend activity data: $e');
        }
      }
      
      return localSummary;
      
    } catch (e) {
      print('Failed to get today summary: $e');
      rethrow;
    }
  }
  
  // ===== OFFLINE-FIRST APPROACH =====
  
  // Example: Handle offline scenario
  static Future<void> handleOfflineData() async {
    try {
      // Always save data locally first
      final calorieData = {
        'foodName': 'Apple',
        'calories': 95,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await DataSyncService.addCalorieData(calorieData);
      
      // Try to sync with backend when online
      if (await ApiService.isAuthenticated()) {
        try {
          await DataSyncService.syncCalorieDataWithBackend();
          print('Data synced with backend');
        } catch (e) {
          print('Backend sync failed, data saved locally: $e');
        }
      }
      
    } catch (e) {
      print('Failed to handle offline data: $e');
    }
  }
}

// ===== WIDGET INTEGRATION EXAMPLES =====

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await BackendIntegrationExample.loginUser(
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      // Navigate to home screen on success
      Navigator.pushReplacementNamed(context, '/home');
      
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading 
                ? CircularProgressIndicator()
                : Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class CalorieLoggingWidget extends StatefulWidget {
  @override
  _CalorieLoggingWidgetState createState() => _CalorieLoggingWidgetState();
}

class _CalorieLoggingWidgetState extends State<CalorieLoggingWidget> {
  final _foodController = TextEditingController();
  final _calorieController = TextEditingController();

  Future<void> _logCalories() async {
    try {
      await BackendIntegrationExample.logCalorieData(
        foodName: _foodController.text,
        calories: int.parse(_calorieController.text),
      );
      
      // Clear form
      _foodController.clear();
      _calorieController.clear();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Calories logged successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to log calories: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _foodController,
              decoration: InputDecoration(labelText: 'Food Name'),
            ),
            TextField(
              controller: _calorieController,
              decoration: InputDecoration(labelText: 'Calories'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _logCalories,
              child: Text('Log Calories'),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== MIGRATION HELPER =====

class DataMigrationHelper {
  // Run this when the app starts to migrate existing data
  static Future<void> migrateExistingData() async {
    try {
      print('Starting data migration...');
      
      // Migrate local data to new format
      await DataSyncService.migrateLocalData();
      
      // Check if user is authenticated
      if (await ApiService.isAuthenticated()) {
        // Sync all data with backend
        await DataSyncService.syncAllDataWithBackend();
        print('Data migration completed successfully');
      } else {
        print('User not authenticated, data saved locally only');
      }
      
    } catch (e) {
      print('Data migration failed: $e');
    }
  }
} 