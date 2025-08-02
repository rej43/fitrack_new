# Google OAuth Mobile Implementation Fix

## Current Issue

The Flutter app is getting URL launcher errors when trying to use Google OAuth:
```
I/UrlLauncher( 8784): component name for http://localhost:4000/api/v1/auth/google is null
I/UrlLauncher( 8784): component name for http://flutter.dev is null
```

## Root Cause

The current Google OAuth implementation is designed for web applications, not mobile apps. The issues are:

1. **Wrong OAuth Flow**: Using web-based OAuth flow instead of mobile-specific flow
2. **URL Launcher Issues**: Trying to launch `localhost:4000` URLs on mobile devices
3. **Missing Mobile OAuth Package**: Not using the proper `google_sign_in` package for Flutter

## Current Status

✅ **Fixed Issues:**
- Backend registration and login are working properly
- JWT token generation is fixed
- MongoDB connection is working
- Basic authentication endpoints are functional

❌ **Remaining Issues:**
- Google OAuth is temporarily disabled to avoid URL launcher errors
- Need proper mobile OAuth implementation

## Solution: Proper Mobile OAuth Implementation

### Option 1: Use google_sign_in Package (Recommended)

1. **Add the package to pubspec.yaml:**
```yaml
dependencies:
  google_sign_in: ^6.2.1
```

2. **Update the API service:**
```dart
import 'package:google_sign_in/google_sign_in.dart';

class ApiService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in was cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Send the ID token to your backend
      final response = await _makeRequest('/auth/google/mobile', 'POST', body: {
        'idToken': googleAuth.idToken,
        'accessToken': googleAuth.accessToken,
        'email': googleUser.email,
        'displayName': googleUser.displayName,
      });

      if (response['token'] != null) {
        await saveToken(response['token']);
      }
      
      if (response['user'] != null) {
        await _saveUserData(response['user']);
      }

      return response;
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }
}
```

3. **Add backend endpoint for mobile OAuth:**
```typescript
// In Auth.controller.ts
public googleMobileAuth = asyncHandler(async (req: Request, res: Response) => {
  const { idToken, accessToken, email, displayName } = req.body;
  
  // Verify the ID token with Google
  // Create or update user
  // Return JWT token
});
```

### Option 2: Web-based OAuth with Custom URL Scheme

1. **Add custom URL scheme to Android manifest:**
```xml
<activity>
  <intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="fitrack" />
  </intent-filter>
</activity>
```

2. **Update Google OAuth redirect URL:**
```
fitrack://oauth/callback
```

3. **Handle the callback in Flutter:**
```dart
// Use uni_links package to handle custom URL scheme
```

## Immediate Fix Applied

For now, I've temporarily disabled Google OAuth buttons to prevent URL launcher errors. Users will see a message:

> "Google Sign-In is not available yet. Please use email/password login."

## Testing Current Functionality

✅ **Working Features:**
- Email/password registration
- Email/password login
- JWT token authentication
- User profile management
- Health data endpoints
- Activity tracking endpoints

## Next Steps

1. **For immediate use**: Use email/password authentication (fully working)
2. **For Google OAuth**: Implement Option 1 with `google_sign_in` package
3. **Alternative**: Use Option 2 with custom URL scheme

## Backend Status

The backend is fully functional for:
- ✅ User registration
- ✅ User login  
- ✅ JWT authentication
- ✅ Health data management
- ✅ Activity tracking
- ✅ Google OAuth (web-based, needs mobile adaptation)

The registration and login errors have been completely resolved! 