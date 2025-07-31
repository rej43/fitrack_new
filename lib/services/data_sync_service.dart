import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitrack/services/api_service.dart';
import 'package:fitrack/models/user_model.dart';

class DataSyncService {
  static const String _calorieDataKey = 'food_logs';
  static const String _waterDataKey = 'water_logs';
  static const String _sleepDataKey = 'sleep_data';
  static const String _stepsDataKey = 'steps_data';
  static const String _healthDataKey = 'health_data';
  static const String _userDataKey = 'user_data';

  // ===== LOCAL DATA MANAGEMENT =====

  // Save calorie data locally
  static Future<void> saveCalorieDataLocally(List<Map<String, dynamic>> calorieData) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = calorieData.map((data) => jsonEncode(data)).toList();
    await prefs.setStringList(_calorieDataKey, jsonData);
  }

  // Load calorie data from local storage
  static Future<List<Map<String, dynamic>>> loadCalorieDataLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getStringList(_calorieDataKey) ?? [];
    
    return jsonData.map((json) {
      try {
        return jsonDecode(json) as Map<String, dynamic>;
      } catch (e) {
        return <String, dynamic>{};
      }
    }).where((data) => data.isNotEmpty).toList();
  }

  // Save water data locally
  static Future<void> saveWaterDataLocally(List<Map<String, dynamic>> waterData) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = waterData.map((data) => jsonEncode(data)).toList();
    await prefs.setStringList(_waterDataKey, jsonData);
  }

  // Load water data from local storage
  static Future<List<Map<String, dynamic>>> loadWaterDataLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getStringList(_waterDataKey) ?? [];
    
    return jsonData.map((json) {
      try {
        return jsonDecode(json) as Map<String, dynamic>;
      } catch (e) {
        return <String, dynamic>{};
      }
    }).where((data) => data.isNotEmpty).toList();
  }

  // Save sleep data locally
  static Future<void> saveSleepDataLocally(String sleepDuration) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sleepDataKey, sleepDuration);
  }

  // Load sleep data from local storage
  static Future<String> loadSleepDataLocally() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sleepDataKey) ?? '0h 0m';
  }

  // Save steps data locally
  static Future<void> saveStepsDataLocally(int steps) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_stepsDataKey, steps);
  }

  // Load steps data from local storage
  static Future<int> loadStepsDataLocally() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_stepsDataKey) ?? 0;
  }

  // Save health data locally
  static Future<void> saveHealthDataLocally(HealthData healthData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_healthDataKey, jsonEncode(healthData.toJson()));
  }

  // Load health data from local storage
  static Future<HealthData?> loadHealthDataLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getString(_healthDataKey);
    if (jsonData != null) {
      try {
        return HealthData.fromJson(jsonDecode(jsonData));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Save user data locally
  static Future<void> saveUserDataLocally(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, jsonEncode(user.toJson()));
  }

  // Load user data from local storage
  static Future<User?> loadUserDataLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getString(_userDataKey);
    if (jsonData != null) {
      try {
        return User.fromJson(jsonDecode(jsonData));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // ===== BACKEND SYNC METHODS =====

  // Sync all local data with backend
  static Future<void> syncAllDataWithBackend() async {
    try {
      // Check if user is authenticated
      if (!await ApiService.isAuthenticated()) {
        throw Exception('User not authenticated');
      }

      // Sync calorie data
      await syncCalorieDataWithBackend();
      
      // Sync water data
      await syncWaterDataWithBackend();
      
      // Sync sleep data
      await syncSleepDataWithBackend();
      
      // Sync steps data
      await syncStepsDataWithBackend();
      
      print('All data synced successfully with backend');
    } catch (e) {
      print('Error syncing data with backend: $e');
      throw Exception('Failed to sync data with backend: $e');
    }
  }

  // Sync calorie data with backend
  static Future<void> syncCalorieDataWithBackend() async {
    try {
      final localCalories = await loadCalorieDataLocally();
      if (localCalories.isNotEmpty) {
        await ApiService.syncCalorieData(localCalories);
        print('Calorie data synced with backend');
      }
    } catch (e) {
      print('Error syncing calorie data: $e');
    }
  }

  // Sync water data with backend
  static Future<void> syncWaterDataWithBackend() async {
    try {
      final localWater = await loadWaterDataLocally();
      if (localWater.isNotEmpty) {
        await ApiService.syncWaterData(localWater);
        print('Water data synced with backend');
      }
    } catch (e) {
      print('Error syncing water data: $e');
    }
  }

  // Sync sleep data with backend
  static Future<void> syncSleepDataWithBackend() async {
    try {
      final sleepDuration = await loadSleepDataLocally();
      if (sleepDuration != '0h 0m') {
        await ApiService.syncSleepData(sleepDuration);
        print('Sleep data synced with backend');
      }
    } catch (e) {
      print('Error syncing sleep data: $e');
    }
  }

  // Sync steps data with backend
  static Future<void> syncStepsDataWithBackend() async {
    try {
      final steps = await loadStepsDataLocally();
      if (steps > 0) {
        await ApiService.syncStepsData(steps);
        print('Steps data synced with backend');
      }
    } catch (e) {
      print('Error syncing steps data: $e');
    }
  }

  // ===== HYBRID DATA MANAGEMENT =====

  // Add calorie data (both local and backend)
  static Future<void> addCalorieData(Map<String, dynamic> calorieData) async {
    try {
      // Save locally first
      final localData = await loadCalorieDataLocally();
      localData.add(calorieData);
      await saveCalorieDataLocally(localData);

      // Try to sync with backend
      if (await ApiService.isAuthenticated()) {
        await syncCalorieDataWithBackend();
      }
    } catch (e) {
      print('Error adding calorie data: $e');
    }
  }

  // Add water data (both local and backend)
  static Future<void> addWaterData(Map<String, dynamic> waterData) async {
    try {
      // Save locally first
      final localData = await loadWaterDataLocally();
      localData.add(waterData);
      await saveWaterDataLocally(localData);

      // Try to sync with backend
      if (await ApiService.isAuthenticated()) {
        await syncWaterDataWithBackend();
      }
    } catch (e) {
      print('Error adding water data: $e');
    }
  }

  // Update sleep data (both local and backend)
  static Future<void> updateSleepData(String sleepDuration) async {
    try {
      // Save locally first
      await saveSleepDataLocally(sleepDuration);

      // Try to sync with backend
      if (await ApiService.isAuthenticated()) {
        await syncSleepDataWithBackend();
      }
    } catch (e) {
      print('Error updating sleep data: $e');
    }
  }

  // Update steps data (both local and backend)
  static Future<void> updateStepsData(int steps) async {
    try {
      // Save locally first
      await saveStepsDataLocally(steps);

      // Try to sync with backend
      if (await ApiService.isAuthenticated()) {
        await syncStepsDataWithBackend();
      }
    } catch (e) {
      print('Error updating steps data: $e');
    }
  }

  // ===== DATA MIGRATION =====

  // Migrate existing local data to new format
  static Future<void> migrateLocalData() async {
    try {
      // Migrate calorie data
      final calorieData = await loadCalorieDataLocally();
      if (calorieData.isNotEmpty) {
        // Ensure all entries have the correct format
        final migratedData = calorieData.map((data) {
          return {
            'foodName': data['foodName'] ?? data['food'] ?? 'Unknown Food',
            'calories': data['calories'] ?? 0,
            'timestamp': data['timestamp'] ?? DateTime.now().toIso8601String(),
          };
        }).toList();
        
        await saveCalorieDataLocally(migratedData);
        print('Calorie data migrated successfully');
      }

      // Migrate water data
      final waterData = await loadWaterDataLocally();
      if (waterData.isNotEmpty) {
        // Ensure all entries have the correct format
        final migratedData = waterData.map((data) {
          return {
            'ml': data['ml'] ?? 0,
            'timestamp': data['timestamp'] ?? DateTime.now().toIso8601String(),
          };
        }).toList();
        
        await saveWaterDataLocally(migratedData);
        print('Water data migrated successfully');
      }
    } catch (e) {
      print('Error migrating local data: $e');
    }
  }

  // ===== UTILITY METHODS =====

  // Clear all local data
  static Future<void> clearAllLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_calorieDataKey);
    await prefs.remove(_waterDataKey);
    await prefs.remove(_sleepDataKey);
    await prefs.remove(_stepsDataKey);
    await prefs.remove(_healthDataKey);
    await prefs.remove(_userDataKey);
  }

  // Get data summary for today
  static Future<Map<String, dynamic>> getTodayDataSummary() async {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    // Get calorie data for today
    final calorieData = await loadCalorieDataLocally();
    int todayCalories = 0;
    for (final data in calorieData) {
      final timestamp = DateTime.parse(data['timestamp']);
      if (timestamp.isAfter(todayStart)) {
        todayCalories += ((data['calories'] ?? 0) as num).toInt();
      }
    }

    // Get water data for today
    final waterData = await loadWaterDataLocally();
    double todayWater = 0;
    for (final data in waterData) {
      final timestamp = DateTime.parse(data['timestamp']);
      if (timestamp.isAfter(todayStart)) {
        todayWater += data['ml'] ?? 0;
      }
    }

    return {
      'calories': todayCalories,
      'water': todayWater,
      'sleep': await loadSleepDataLocally(),
      'steps': await loadStepsDataLocally(),
    };
  }
} 