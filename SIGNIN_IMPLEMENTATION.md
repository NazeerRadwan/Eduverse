# SignIn Implementation Guide

## Overview
This document describes the integration of the API endpoint `/api/Account/Login` with the Flutter SignIn screen. After successful authentication, users are navigated to the `view_courses_screen`.

## Files Created/Modified

### 1. **Auth Service** (`lib/services/auth_service.dart`) - NEW
This service handles all authentication-related API calls.

**Key Features:**
- `login()` - Posts email and password to the API and returns the authentication token
- `_saveToken()` - Stores JWT token and expiration date in local storage
- `getToken()` - Retrieves the stored authentication token
- `logout()` - Clears the stored token
- `isLoggedIn()` - Checks if user is currently logged in

**API Endpoint:**
```
POST http://examtime.runasp.net/api/Account/Login
Headers: 
  - Content-Type: application/json
  - Accept: */*
Body:
  {
    "email": "user@example.com",
    "password": "password"
  }
```

**Expected Response (Success - 200):**
```json
{
  "status": true,
  "message": {
    "massage": "Login successful.",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expired": "2025-11-18T12:02:55Z"
  }
}
```

### 2. **SignIn Screen** (`lib/Screens/signIn_screen.dart`) - MODIFIED
Updated to include API integration and user feedback.

**New Features:**
- **Input Validation:**
  - Email and password cannot be empty
  - Email format validation using regex
  
- **Loading State:**
  - Login button shows loading spinner while request is in progress
  - Button is disabled during loading
  
- **Error Handling:**
  - Displays error messages in a styled red container
  - Handles network errors, timeout, and server errors
  - Shows user-friendly error messages
  
- **Navigation:**
  - On successful login, navigates to `/view_courses` route
  - Uses `pushReplacementNamed()` to prevent back navigation

- **Token Management:**
  - JWT token is automatically saved to SharedPreferences
  - Token can be retrieved for subsequent API requests

**State Variables:**
```dart
bool _isLoading = false;           // Loading state during login
String? _errorMessage;             // Error message display
final _emailCtl = TextEditingController();
final _passCtl = TextEditingController();
bool _obscure = true;              // Password visibility toggle
```

### 3. **Main App** (`lib/main.dart`) - MODIFIED
Added routing configuration for named routes.

**Routes Added:**
```dart
'/signin': SigninScreen()
'/view_courses': EduversesPage()
'/signup': SignUpPage()
```

**Cleaned up:**
- Removed unused imports (dart:convert, dart:io, etc.)
- Kept only essential dependencies

## Implementation Details

### Login Flow

1. **User enters credentials** → Email and password fields
2. **User taps Login button** → `_handleLogin()` is called
3. **Input validation** → Checks for empty fields and valid email format
4. **API Call** → `AuthService.login()` sends POST request
5. **Success Path:**
   - Token is saved to local storage
   - User is navigated to `/view_courses` (EduversesPage)
6. **Error Path:**
   - Error message is displayed to user
   - User can try again

### Error Handling

The `_handleLogin()` method handles:
- **Validation Errors:** Empty fields, invalid email format
- **API Errors:** 401 (Invalid credentials), 500+ (Server errors)
- **Network Errors:** Connection timeout, network failures
- **Runtime Errors:** General exceptions during the process

### Token Persistence

After successful login:
1. JWT token is saved via `SharedPreferences` with key `auth_token`
2. Token expiration date is saved with key `token_expired`
3. Token can be retrieved using `AuthService.getToken()`
4. Token is cleared on logout using `AuthService.logout()`

## Testing

### Manual Testing Steps:

1. **Test Valid Login:**
   - Email: `nr1413@fayoum.edu.eg`
   - Password: `Radwan_8212`
   - Expected: Navigate to courses screen

2. **Test Invalid Email:**
   - Email: `invalid-email`
   - Password: `any_password`
   - Expected: Error message "Please enter a valid email"

3. **Test Empty Fields:**
   - Leave email or password empty
   - Expected: Error message "Please enter both email and password"

4. **Test Invalid Credentials:**
   - Email: `valid@example.com`
   - Password: `wrong_password`
   - Expected: Error message "Invalid email or password"

5. **Test Network Error:**
   - Disconnect internet
   - Try to login
   - Expected: Error message about connection

### Debug Tips:

```dart
// In SignIn screen, you can add debug prints:
print('Login attempt: ${_emailCtl.text}');
print('API Response: $result');
print('Token saved: ${await AuthService.getToken()}');
```

## Dependencies Used

- `http: ^1.2.2` - For HTTP requests
- `shared_preferences: ^2.3.2` - For local token storage
- `flutter: ^3.7.2` - Flutter framework

All dependencies are already included in `pubspec.yaml`.

## Navigation Flow

```
SignUpPage (home)
    ↓
SigninScreen (/signin)
    ├─ Valid Login → EduversesPage (/view_courses)
    └─ Invalid Login → Error message (stay on SigninScreen)
```

## Security Considerations

1. **Token Storage:** JWT is stored in SharedPreferences (sufficient for development)
   - For production: Use Secure Storage (flutter_secure_storage package)

2. **Password Storage:** Never store passwords locally - only store the JWT token

3. **HTTPS:** The API endpoint should use HTTPS in production

4. **Token Expiration:** Implement token refresh logic for expired tokens

## Future Enhancements

1. **Token Refresh:**
   ```dart
   // Implement endpoint for token refresh
   // Call before token expiration
   ```

2. **Biometric Authentication:**
   ```dart
   // Add fingerprint/face recognition login
   ```

3. **Remember Me Feature:**
   ```dart
   // Store credentials securely for auto-login
   ```

4. **Social Login Integration:**
   - Google Sign-In (already configured in pubspec.yaml)
   - Implement `_googleSignInButton` tap handler

5. **Forgot Password:**
   - Implement password reset flow

## API Documentation Reference

**Base URL:** `http://examtime.runasp.net`

**Endpoint:** `POST /api/Account/Login`

**Request Body:**
```json
{
  "email": "string",
  "password": "string"
}
```

**Response (200 OK):**
```json
{
  "status": boolean,
  "message": {
    "massage": "string (note: typo in API response)",
    "token": "JWT Token",
    "expired": "ISO 8601 DateTime"
  }
}
```

**Error Responses:**
- `401 Unauthorized` - Invalid credentials
- `400 Bad Request` - Invalid input format
- `500 Internal Server Error` - Server error

## Troubleshooting

### Issue: "Connection timeout"
- Check internet connection
- Verify API server is running
- Check if base URL is correct

### Issue: "Invalid email or password"
- Verify email is registered
- Check password is correct
- Ensure email format is valid

### Issue: Navigation not working
- Verify route names in main.dart
- Check MaterialApp has routes configured
- Ensure screen class names are correct

### Issue: Token not being saved
- Verify SharedPreferences is installed
- Check for file system permissions
- Test `SharedPreferences` directly:
  ```dart
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('test', 'value');
  print(prefs.getString('test'));
  ```

## Support

For issues or questions about the implementation:
1. Check this documentation
2. Review the code comments in `auth_service.dart` and `signIn_screen.dart`
3. Verify API endpoint availability
4. Check Flutter/Dart documentation for specific APIs used
