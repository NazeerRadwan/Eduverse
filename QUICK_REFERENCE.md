# Quick Reference Guide - SignIn Integration

## 🚀 Quick Start

### Test Login Credentials
```
Email: nr1413@fayoum.edu.eg
Password: Radwan_8212
```

### API Endpoint
```
POST http://examtime.runasp.net/api/Account/Login
```

---

## 📂 Key Files

| File | Purpose | Status |
|------|---------|--------|
| `lib/services/auth_service.dart` | Authentication service | ✅ NEW |
| `lib/Screens/signIn_screen.dart` | Login UI & logic | ✅ UPDATED |
| `lib/main.dart` | App routing | ✅ UPDATED |
| `SIGNIN_IMPLEMENTATION.md` | Full documentation | ✅ NEW |
| `INTEGRATION_REPORT.md` | Implementation report | ✅ NEW |
| `lib/services/api_example.dart` | Usage examples | ✅ NEW |

---

## 🔑 Core Methods

### AuthService

```dart
// Login with credentials
final result = await AuthService.login(
  email: 'user@example.com',
  password: 'password123'
);

// Get stored token
final token = await AuthService.getToken();

// Check if logged in
final isLoggedIn = await AuthService.isLoggedIn();

// Logout
await AuthService.logout();
```

### SignIn Screen

```dart
// Validates input
// Shows loading spinner
// Displays errors
// Navigates on success
```

---

## 📊 Data Flow

```
Login Screen
    ↓
User enters email & password
    ↓
Tap "Log in" button
    ↓
Input Validation
├─ Email required? ✓
├─ Password required? ✓
└─ Valid email format? ✓
    ↓
AuthService.login()
    ↓
HTTP POST to API
    ↓
Response Handling
├─ Success (200)
│  ├─ Save token
│  ├─ Save expiration
│  └─ Navigate to /view_courses
└─ Error
   └─ Display error message
```

---

## ⚠️ Error Handling

| Scenario | Error Message | Action |
|----------|---------------|--------|
| Empty email or password | "Please enter both email and password" | Stays on screen |
| Invalid email format | "Please enter a valid email" | Stays on screen |
| Invalid credentials | "Invalid email or password" | Stays on screen |
| Server error | "Server error: XXX" | Stays on screen |
| Network timeout | "Connection timeout" | Stays on screen |
| General error | "An error occurred: ..." | Stays on screen |

---

## 🧪 Testing

### Run Tests
```bash
cd c:\Users\NAZER\Desktop\EduVerse\ui
flutter test
```

### Manual Test Scenarios

1. **✅ Valid Login**
   - Input valid credentials
   - Tap login
   - Expected: Navigate to courses

2. **❌ Invalid Email**
   - Input: `invalidemail`
   - Expected: Validation error

3. **❌ Wrong Password**
   - Input valid email + wrong password
   - Expected: "Invalid email or password"

4. **❌ Network Error**
   - Disable internet
   - Try login
   - Expected: Connection error

---

## 🔐 Token Management

### Token Storage Location
- **Key:** `auth_token`
- **Storage:** SharedPreferences
- **Scope:** Application

### Token Format
```
JWT Token Structure:
Header.Payload.Signature

Example:
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ...
```

### Token Expiration
- Stored in key: `token_expired`
- Format: ISO 8601 (e.g., `2025-11-18T12:02:55Z`)
- Note: Not validated in current implementation

---

## 🚦 Navigation Flow

```
┌─────────────┐
│  Splash     │
│  or SignUp  │
└──────┬──────┘
       │
       ↓
┌─────────────────────┐
│  Sign In Screen     │
│  (New Route)        │
│  Path: /signin      │
└──┬──────────────┬───┘
   │              │
   │ Valid Login  │ Invalid
   ↓              ↓
┌──────────────┐  └─→ Error Message
│ View Courses │  (stay on screen)
│ Path: /view_ │
│ courses      │
└──────────────┘
```

---

## 💾 SharedPreferences Usage

```dart
// Save token (done automatically)
await prefs.setString('auth_token', token);
await prefs.setString('token_expired', expiredDate);

// Get token
final token = prefs.getString('auth_token');

// Clear token (logout)
await prefs.remove('auth_token');
await prefs.remove('token_expired');

// Check if exists
final exists = prefs.containsKey('auth_token');
```

---

## 🐛 Debugging Tips

### Enable Debug Logging
```dart
// Add to auth_service.dart
print('Login attempt: $email');
print('Response status: ${response.statusCode}');
print('Response body: ${response.body}');
```

### Check Stored Token
```dart
final token = await AuthService.getToken();
print('Stored token: $token');

final isLoggedIn = await AuthService.isLoggedIn();
print('Is logged in: $isLoggedIn');
```

### Clear Local Storage (Reset)
```dart
import 'package:shared_preferences/shared_preferences.dart';

// Clear all stored data
final prefs = await SharedPreferences.getInstance();
await prefs.clear();
```

---

## 🔗 API Integration Pattern

### Making Authenticated Requests

```dart
// 1. Get token
final token = await AuthService.getToken();
if (token == null) return;

// 2. Make request with Authorization header
final response = await http.get(
  Uri.parse(url),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  },
);

// 3. Handle 401 (unauthorized)
if (response.statusCode == 401) {
  await AuthService.logout();
  // Redirect to login
}
```

---

## 📝 Code Examples

### Check Login Status
```dart
bool isLoggedIn = await AuthService.isLoggedIn();
if (isLoggedIn) {
  // Show dashboard
} else {
  // Show login screen
}
```

### Logout User
```dart
await AuthService.logout();
Navigator.of(context).pushReplacementNamed('/signin');
```

### Handle Login Response
```dart
final result = await AuthService.login(
  email: email,
  password: password,
);

if (result['success']) {
  final token = result['token'];
  // Navigate to next screen
} else {
  final error = result['message'];
  // Show error to user
}
```

---

## ✅ Checklist

- [ ] AuthService created and working
- [ ] SignIn screen updated with API call
- [ ] Input validation implemented
- [ ] Error handling working
- [ ] Loading state shows spinner
- [ ] Token saved after login
- [ ] Navigation to courses works
- [ ] Tests written and passing
- [ ] Documentation complete

---

## 🚨 Common Issues

### "Connection timeout"
```
✓ Check internet connection
✓ Verify API server is running
✓ Check base URL is correct
✓ Check firewall/proxy settings
```

### "Invalid email or password"
```
✓ Verify email is registered
✓ Check password is correct
✓ Verify credentials case-sensitivity
✓ Try resetting password on server
```

### "Navigation not working"
```
✓ Check route names match
✓ Verify MaterialApp has routes
✓ Check screen class names
✓ Verify imports are correct
```

### "Token not saving"
```
✓ Check SharedPreferences installed
✓ Verify file system permissions
✓ Test SharedPreferences directly
✓ Check for exceptions in logs
```

---

## 📞 Next Steps

1. **Test the login** with provided credentials
2. **Verify token storage** in SharedPreferences
3. **Test navigation** to courses page
4. **Create other API services** using the pattern
5. **Implement token refresh** for production
6. **Add biometric login** (optional)
7. **Deploy to production** (update URLs)

---

## 📚 Related Documentation

- `SIGNIN_IMPLEMENTATION.md` - Full implementation guide
- `INTEGRATION_REPORT.md` - Integration report
- `lib/services/api_example.dart` - API usage examples
- `test/auth_service_test.dart` - Unit tests

---

## 🎯 Success Criteria

✅ Users can log in with valid credentials
✅ Invalid credentials show error
✅ Token is saved securely
✅ User navigates to courses page
✅ Logout clears token
✅ App remembers logged-in state

---

*Last Updated: November 12, 2025*
