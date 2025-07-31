# 🔗 Backend Integration Guide for FiTrack Flutter App

This guide explains how to integrate your Flutter app with the FiTrack backend API.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Backend Setup](#backend-setup)
3. [API Integration](#api-integration)
4. [Data Models](#data-models)
5. [Usage Examples](#usage-examples)
6. [Migration Guide](#migration-guide)
7. [Troubleshooting](#troubleshooting)

## ✅ Prerequisites

- Flutter app with existing local data storage
- Backend server running on `http://localhost:4000`
- Network connectivity for API calls
- JWT token management

## 🚀 Backend Setup

### 1. Install Dependencies
```bash
cd backend/fitTrack-backend
npm install
```

### 2. Configure Environment Variables
The `.env` file should contain:
```env
PORT=4000
MONGODB_URI=your_mongodb_connection_string
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
CLIENT_URL=http://localhost:8080
JWT_SECRET=your_secure_jwt_secret
GOOGLE_CLIENT_REDIRECT=http://localhost:4000/api/v1/auth/google/callback
```

### 3. Start the Backend Server
```bash
npm run dev
```

## 🔌 API Integration

### Updated Files

1. **`lib/services/api_service.dart`** - Updated with backend endpoints
2. **`lib/models/user_model.dart`** - New data models for backend integration
3. **`lib/services/data_sync_service.dart`** - New service for data synchronization
4. **`lib/services/integration_example.dart`** - Example usage and integration patterns

### Key Features

- **Offline-First Approach**: Data is saved locally first, then synced to backend
- **Automatic Token Management**: JWT tokens are automatically handled
- **Data Migration**: Existing local data is migrated to new format
- **Error Handling**: Comprehensive error handling for network issues

## 📊 Data Models

### User Model
```dart
class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? googleId;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### Health Data Model
```dart
class HealthData {
  final String id;
  final String gender;
  final double heightInCM;
  final double weightInKG;
  final String bodyType;
  final String healthGoal;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### Activity Data Model
```dart
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
}
```

## 💡 Usage Examples

### 1. User Authentication

```dart
// User Registration
await ApiService.signup(
  firstName: 'John',
  lastName: 'Doe',
  email: 'john@example.com',
  password: 'password123',
);

// User Login
await ApiService.signin(
  email: 'john@example.com',
  password: 'password123',
);
```

### 2. Health Data Management

```dart
// Create Health Profile
await ApiService.createHealthData(
  gender: 'male',
  heightInCM: 175.0,
  weightInKG: 70.0,
  bodyType: 'normal',
  healthGoal: 'muscle_gain',
);

// Get Health Details
final healthData = await ApiService.getHealthDetails();
```

### 3. Activity Logging

```dart
// Log Daily Activity
await ApiService.logActivity(
  date: DateTime.now(),
  sleepHours: 8.0,
  steps: 10000,
  waterIntake: 2000.0,
  foodCalories: 1800.0,
);

// Get Activity Logs
final activityLogs = await ApiService.getActivityLog();
```

### 4. Data Synchronization

```dart
// Sync all local data with backend
await DataSyncService.syncAllDataWithBackend();

// Add calorie data (saves locally and syncs to backend)
await DataSyncService.addCalorieData({
  'foodName': 'Apple',
  'calories': 95,
  'timestamp': DateTime.now().toIso8601String(),
});
```

## 🔄 Migration Guide

### Step 1: Initialize Migration
Add this to your app's initialization:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Migrate existing data
  await DataMigrationHelper.migrateExistingData();
  
  runApp(MyApp());
}
```

### Step 2: Update Existing Views
Replace direct SharedPreferences calls with DataSyncService:

**Before:**
```dart
// Direct SharedPreferences usage
final prefs = await SharedPreferences.getInstance();
await prefs.setStringList('food_logs', jsonData);
```

**After:**
```dart
// Using DataSyncService
await DataSyncService.addCalorieData(calorieData);
```

### Step 3: Update API Calls
Replace old API calls with new backend endpoints:

**Before:**
```dart
await ApiService.login(email: email, password: password);
```

**After:**
```dart
await ApiService.signin(email: email, password: password);
```

## 🔧 Integration with Existing Views

### 1. Update Login View
```dart
// In your login view
Future<void> _login() async {
  try {
    await ApiService.signin(
      email: _emailController.text,
      password: _passwordController.text,
    );
    
    // Navigate to home on success
    Navigator.pushReplacementNamed(context, '/home');
  } catch (e) {
    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login failed: $e')),
    );
  }
}
```

### 2. Update Calorie View
```dart
// In your calorie view
Future<void> _addFoodLog() async {
  try {
    await DataSyncService.addCalorieData({
      'foodName': _foodController.text,
      'calories': int.parse(_calorieController.text),
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    // Clear form and show success
    _foodController.clear();
    _calorieController.clear();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Food logged successfully!')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to log food: $e')),
    );
  }
}
```

### 3. Update Home View
```dart
// In your home view
Future<void> _loadData() async {
  try {
    // Get today's summary
    final summary = await DataSyncService.getTodayDataSummary();
    
    setState(() {
      _todayCalories = summary['calories'] ?? 0;
      _todayWater = summary['water'] ?? 0;
      _sleepDuration = summary['sleep'] ?? '0h 0m';
      _steps = summary['steps'] ?? 0;
    });
  } catch (e) {
    print('Failed to load data: $e');
  }
}
```

## 🚨 Troubleshooting

### Common Issues

1. **Connection Refused**
   - Ensure backend server is running on port 4000
   - Check if the server is accessible at `http://localhost:4000`

2. **Authentication Errors**
   - Verify JWT token is being sent in Authorization header
   - Check if token is expired
   - Ensure user is properly logged in

3. **Data Sync Issues**
   - Check network connectivity
   - Verify backend API endpoints are working
   - Check console logs for specific error messages

4. **CORS Errors**
   - Ensure `CLIENT_URL` in backend `.env` matches your Flutter app URL
   - For Flutter web: `http://localhost:8080`
   - For mobile: Use appropriate localhost or IP address

### Debug Commands

```bash
# Test backend health
curl http://localhost:4000/stats

# Test authentication endpoint
curl -X POST http://localhost:4000/api/v1/auth/signin \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'

# Test activity endpoint (requires auth token)
curl -X GET http://localhost:4000/api/v1/activity/getActivityLog \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## 📱 Testing

### 1. Test Authentication
```dart
// Test user registration
await ApiService.signup(
  firstName: 'Test',
  lastName: 'User',
  email: 'test@example.com',
  password: 'password123',
);

// Test user login
await ApiService.signin(
  email: 'test@example.com',
  password: 'password123',
);
```

### 2. Test Data Sync
```dart
// Test calorie logging
await DataSyncService.addCalorieData({
  'foodName': 'Test Food',
  'calories': 100,
  'timestamp': DateTime.now().toIso8601String(),
});

// Test data retrieval
final summary = await DataSyncService.getTodayDataSummary();
print('Today\'s calories: ${summary['calories']}');
```

## 🔒 Security Considerations

1. **JWT Token Storage**: Tokens are stored securely in SharedPreferences
2. **HTTPS**: Use HTTPS in production for secure communication
3. **Input Validation**: Validate all user inputs before sending to API
4. **Error Handling**: Don't expose sensitive information in error messages

## 📈 Performance Optimization

1. **Offline-First**: Data is saved locally first for better performance
2. **Batch Sync**: Sync data in batches to reduce API calls
3. **Caching**: Cache frequently accessed data
4. **Lazy Loading**: Load data only when needed

## 🎯 Next Steps

1. **Implement the integration** in your existing views
2. **Test all endpoints** with your backend server
3. **Add error handling** for network issues
4. **Implement offline mode** for better user experience
5. **Add data validation** for all inputs
6. **Test with real devices** to ensure compatibility

## 📞 Support

If you encounter any issues:

1. Check the console logs for error messages
2. Verify backend server is running and accessible
3. Test API endpoints directly with curl or Postman
4. Ensure all environment variables are properly configured
5. Check network connectivity and firewall settings

---

**Happy Coding! 🚀** 