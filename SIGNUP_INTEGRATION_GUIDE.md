# SignUp Flow Integration Documentation

## Overview

This document explains the complete SignUp workflow with photo upload integration. The flow guides users through account registration with profile photo upload to Google Drive.

## Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                   USER SIGNUP FLOW                              │
└─────────────────────────────────────────────────────────────────┘

    1. SignUpPage (signUp_screen.dart)
       ├─ Collect user data:
       │  ├─ Username
       │  ├─ Full Name
       │  ├─ Email
       │  ├─ Password (with confirm)
       │  └─ Role (Instructor/Student)
       └─ Validate form data
           ↓
    2. UploadPhotoScreen (upload_photo.dart)
       ├─ Select photo from device
       ├─ Show image preview
       └─ Upload to Google Drive
           ↓
    3. Register via API (registration_service.dart)
       ├─ POST /api/Account/Register
       ├─ Include: userName, email, fullName, imageUrl, password, role
       └─ Receive confirmation email link
           ↓
    4. Confirmation Dialog
       ├─ Show success message
       ├─ Inform user to check email
       └─ Navigate to login (/signin)
```

## Components

### 1. SignUpPage (lib/Screens/signUp_screen.dart)

**Purpose:** Collect registration form data from user

**Key Features:**
- Form validation before proceeding
- Username, Full Name, Email fields
- Password and Confirm Password with visibility toggle
- Role selection (Instructor/Student)
- Error display with validation messages
- "Continue" button navigates to UploadPhotoScreen with form data

**Form Fields:**
```dart
_userNameCtl          // Username input
_fullNameCtl          // Full name input
_emailCtl             // Email input (type: emailAddress)
_passCtl              // Password input (obscured)
_confirmPassCtl       // Confirm password input (obscured)
_role                 // Role selection: 'Instructor' or 'Student'
```

**Validation:**
- All fields are required
- Uses `RegistrationService.validateRegistration()` for validation
- Checks email format, password length, and password match
- Shows error messages for validation failures

**Navigation:**
- On success: Push to `UploadPhotoScreen` with all form data
- On back: Pop to previous screen
- On "Already have account?": Navigate to `/signin`

---

### 2. UploadPhotoScreen (lib/Screens/upload_photo.dart)

**Purpose:** Handle photo selection and registration API call

**Key Features:**
- Image selection from device gallery
- Photo preview (200x200 box)
- Google Drive upload with loading state
- Registration API call with Drive image link
- Confirmation dialog on success
- Navigation to login on dialog close

**Constructor Parameters:**
```dart
required String userName,        // From SignUpPage
required String fullName,        // From SignUpPage
required String email,           // From SignUpPage
required String password,        // From SignUpPage
required String confirmPassword, // From SignUpPage
required String role,            // From SignUpPage (Instructor/Student)
```

**State Variables:**
```dart
File? _selectedImage      // Selected image file
bool _isUploading         // Google Drive upload in progress
bool _isRegistering       // Registration API call in progress
String? _errorMessage     // Error message display
```

**Key Methods:**

#### `_handleSelectPhoto()`
- Calls `GoogleDriveService.pickImageFromDevice()`
- Handles image picker errors
- Updates `_selectedImage` state
- Shows error snackbar on failure

#### `_handleStartRegistration()`
- Checks if image is selected
- Uploads image to Google Drive via `GoogleDriveService.uploadImageToGoogleDrive()`
- Gets public Drive link from upload response
- Calls `RegistrationService.register()` with all data + Drive link
- Shows confirmation dialog on success
- Shows error snackbar on failure

#### `_showConfirmationDialog()`
- Displays success message with check icon
- Shows "Please check your email to confirm your account" message
- Single button "Go to Login" that:
  - Closes dialog
  - Navigates to `/signin` using `pushReplacementNamed`

**User Flow:**
1. Tap "Select Photo" button
2. Choose image from gallery
3. Image preview appears in 200x200 box
4. Tap "Start" button
5. Loading spinner shows during upload and registration
6. On success: Confirmation dialog appears
7. Tap "Go to Login" to proceed to signin screen

---

### 3. RegistrationService (lib/services/registration_service.dart)

**Purpose:** Handle registration validation and API calls

**Static Methods:**

#### `validateRegistration()`
```dart
static Map<String, dynamic> validateRegistration({
  required String userName,
  required String email,
  required String fullName,
  required String password,
  required String confirmPassword,
  required String role,
})
```

**Returns:**
```dart
{
  'valid': bool,           // true if all validation passes
  'message': String        // Error message if validation fails
}
```

**Validation Rules:**
- All fields required (not empty)
- Email must match pattern: `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`
- Password must be >= 6 characters
- Password and confirmPassword must match
- Username must be >= 3 characters
- Full name must be >= 3 characters
- Role must be 'Instructor' or 'Student'

#### `register()`
```dart
static Future<Map<String, dynamic>> register({
  required String userName,
  required String email,
  required String fullName,
  required String imageUrl,    // Google Drive link
  required String password,
  required String confirmPassword,
  required String role,
})
```

**Returns:**
```dart
{
  'success': bool,          // true on 200 status
  'message': String,        // Response message or error
  'data': dynamic           // Response data if available
}
```

**API Call Details:**
- **Endpoint:** `POST /api/Account/Register`
- **Base URL:** `http://examtime.runasp.net`
- **Content-Type:** `application/json`

**Request Body:**
```json
{
  "userName": "user@example",
  "email": "user@example.com",
  "fullName": "John Doe",
  "imageUrl": "https://drive.google.com/uc?export=view&id=...",
  "password": "password123",
  "confirmPassword": "password123",
  "role": "Student"
}
```

**Response Handling:**
- **200 (Success):** Returns `{success: true, message: "...", data: {...}}`
  - Response typically includes email confirmation link
- **400 (Bad Request):** Returns `{success: false, message: "..."}`
  - Example: "Passwords do not match"
- **409 (Conflict):** Returns `{success: false, message: "..."}`
  - Example: "Email already exists" or "Username already taken"
- **500+ (Server Error):** Returns `{success: false, message: "..."}`

---

### 4. GoogleDriveService (lib/services/google_drive_service.dart)

**Purpose:** Handle photo upload to Google Drive and image selection

**Static Methods:**

#### `pickImageFromDevice()`
```dart
static Future<File?> pickImageFromDevice()
```

**Features:**
- Opens device gallery for image selection
- Maximum image size: 1024x1024 pixels
- JPEG quality: 85%
- Returns selected image as File or null if cancelled

**Returns:** `Future<File?>` - Selected image file or null

#### `uploadImageToGoogleDrive()`
```dart
static Future<String?> uploadImageToGoogleDrive(File imageFile)
```

**Features:**
- Authenticates with Google via GoogleSignIn
- Uploads file to user's Google Drive
- Makes uploaded file publicly accessible
- Generates shareable public link

**Returns:** 
```
https://drive.google.com/uc?export=view&id={fileId}
```
- This link is publicly accessible and embedded in images

**Error Handling:**
- Throws exception if not signed in
- Throws exception if upload fails
- Shows user-friendly error messages

**Internal Details:**
- Uses `googleapis` package for Drive API
- Creates custom `_AuthenticatedClient` with Bearer token
- Sets MIME type: `application/octet-stream`
- Makes file public with `webContentLink`

#### `signOutGoogle()`
```dart
static Future<void> signOutGoogle()
```

**Purpose:** Sign out from Google account (optional cleanup)

---

## Dependencies

### Required Packages
```yaml
dependencies:
  flutter: sdk: flutter
  http: ^1.1.0                    # HTTP requests
  google_sign_in: ^6.1.0          # Google authentication
  googleapis: ^11.4.0             # Google Drive API
  image_picker: ^1.0.0            # Image gallery picker
  shared_preferences: ^2.2.0      # Token storage
```

### Imports in Service Files
```dart
// registration_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

// google_drive_service.dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

// upload_photo.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/google_drive_service.dart';
import '../services/registration_service.dart';

// signUp_screen.dart
import 'package:flutter/material.dart';
import '../services/registration_service.dart';
import 'upload_photo.dart';
```

---

## Configuration

### Google OAuth Setup
For Google Drive upload to work:

1. **Android Setup** (`android/app/build.gradle`):
   ```gradle
   // Ensure minSdkVersion is at least 19
   minSdkVersion = 19
   ```

2. **iOS Setup** (if targeting iOS):
   - Configure OAuth in XCode
   - Add Google URL scheme

3. **Google Cloud Console**:
   - Create OAuth 2.0 credentials
   - Add app package name/bundle ID
   - Download configuration files

### API Configuration
- Base URL: `http://examtime.runasp.net`
- Register Endpoint: `/api/Account/Register`
- All requests use JSON

---

## Error Scenarios

### Image Selection Errors
```
❌ User cancels image picker → Silently ignored, no image selected
❌ Permission denied → Show error: "Failed to access gallery"
❌ File too large → Show error: "Image too large (max 1024x1024)"
```

### Google Drive Upload Errors
```
❌ User not signed in → Automatically trigger GoogleSignIn
❌ Upload fails → Show error: "Failed to upload image to Google Drive"
❌ Network error → Show error: "Network error during upload"
```

### Registration API Errors
```
❌ Email already exists → Show: "Email already registered"
❌ Username taken → Show: "Username already taken"
❌ Passwords don't match → Show: "Passwords must match"
❌ Invalid email format → Show: "Invalid email address"
❌ Server error → Show: "Registration failed. Please try again"
```

---

## User Experience

### Success Path
1. User fills signup form with 5 fields
2. Taps "Continue" button
3. Navigate to photo upload screen
4. Taps "Select Photo" and picks image
5. Image preview shown
6. Taps "Start" button
7. Loading spinner during upload (2-3 seconds typically)
8. Loading spinner during registration (1-2 seconds)
9. Success dialog appears with check icon
10. User taps "Go to Login" to proceed
11. Navigated to signin screen

### Failure Recovery
- All errors show snackbar with error message
- User can retry immediately
- Back button always available to go back and fix issues

---

## Testing Checklist

- [ ] Form validation works (try missing fields)
- [ ] Email validation works (try invalid emails)
- [ ] Password match validation works
- [ ] Image picker opens correctly
- [ ] Image preview displays after selection
- [ ] Google Drive upload works
- [ ] Public link is generated correctly
- [ ] Registration API call succeeds
- [ ] Confirmation dialog shows
- [ ] Navigation to login works
- [ ] Error messages display properly
- [ ] Loading spinners show during uploads

---

## Common Issues

### Image not uploading to Google Drive
**Issue:** Upload fails with authentication error
**Solution:** Ensure Google Sign-In is properly configured and user is authenticated

### Registration fails with "Email already exists"
**Issue:** Email used is already registered
**Solution:** Use a different email address or retrieve password if user exists

### Confirmation email not received
**Issue:** Email confirmation step not working
**Solution:** Check spam folder or wait 5-10 minutes for email delivery

---

## API Response Examples

### Success Response (200)
```json
{
  "status": true,
  "message": "Registration successful. Please check your email for confirmation link: http://example.com/confirm?token=...",
  "data": {
    "id": "user-123",
    "email": "user@example.com",
    "userName": "username"
  }
}
```

### Email Conflict (409)
```json
{
  "status": false,
  "message": "Email 'user@example.com' is already registered. Please use a different email or login if you have an existing account."
}
```

### Bad Request (400)
```json
{
  "status": false,
  "message": "Passwords do not match. Please ensure password and confirm password are identical."
}
```

---

## File Structure

```
lib/
├── Screens/
│   ├── signUp_screen.dart         # Form data collection
│   ├── upload_photo.dart          # Photo selection & registration
│   ├── signIn_screen.dart         # Login screen
│   └── view_courses_screen.dart   # Main app screen
├── services/
│   ├── registration_service.dart  # Registration & validation
│   ├── google_drive_service.dart  # Photo upload to Drive
│   ├── auth_service.dart          # Login & token management
│   └── api_example.dart           # API usage examples
└── main.dart                      # App entry & routing
```

---

## Next Steps

1. Test the complete flow with real API
2. Implement email confirmation verification
3. Add photo cropping/editing features
4. Add profile completion flow
5. Implement account recovery flow
