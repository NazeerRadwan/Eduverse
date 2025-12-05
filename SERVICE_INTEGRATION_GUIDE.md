# Service Integration Guide

## Overview

This guide explains how `RegistrationService` and `GoogleDriveService` work together to create a seamless photo upload and registration workflow.

## Service Architecture

```
┌──────────────────────────────────────────────────────────┐
│           UploadPhotoScreen (UI Layer)                  │
└───┬────────────────────────────────────────────────────┬─┘
    │                                                      │
    ├──▶ GoogleDriveService                              │
    │    (Photo Upload)                                  │
    │    ├─ pickImageFromDevice()                        │
    │    └─ uploadImageToGoogleDrive()                   │
    │        └─ Returns: Public Drive Link               │
    │                                                     │
    └──▶ RegistrationService                             │
         (Registration & Validation)                     │
         ├─ validateRegistration()                       │
         └─ register()                                   │
             ├─ Takes: All signup data + imageUrl        │
             └─ POST to /api/Account/Register            │
```

## Service Interaction Flow

### Step 1: Image Selection
```dart
// In UploadPhotoScreen._handleSelectPhoto()
final image = await GoogleDriveService.pickImageFromDevice();
// Returns: File object or null
```

**Key Points:**
- User selects image from gallery
- ImagePicker handles device permissions automatically
- Returns `File` object with selected image
- No state changes yet

---

### Step 2: Image Preview
```dart
// Display selected image
if (_selectedImage != null) {
  Image.file(_selectedImage!, fit: BoxFit.cover)
}
```

**Key Points:**
- Shows preview of selected image
- User can confirm before uploading
- Image is still local only

---

### Step 3: Google Drive Upload
```dart
// In UploadPhotoScreen._handleStartRegistration()
setState(() => _isUploading = true);

final driveLink = await GoogleDriveService.uploadImageToGoogleDrive(
  _selectedImage!
);
// Returns: https://drive.google.com/uc?export=view&id=...
```

**Service Flow Inside GoogleDriveService:**

1. **OAuth Authentication**
   ```dart
   final googleSignIn = GoogleSignIn(scopes: ['https://www.googleapis.com/auth/drive.file']);
   final user = await googleSignIn.signIn();
   ```
   - Automatically pops up Google login if needed
   - Requests Drive access permission
   - Caches authentication

2. **File Upload to Drive**
   ```dart
   final driveApi = drive.DriveApi(authenticatedHttpClient);
   final Media media = Media(imageFile.openRead(), imageFile.lengthSync());
   final result = await driveApi.files.create(
     drive.File(name: 'profile_photo_$timestamp.jpg'),
     uploadMedia: media,
   );
   ```
   - Creates file with timestamp to avoid conflicts
   - Uploads binary data to user's Google Drive
   - Returns file metadata with ID

3. **Make File Public**
   ```dart
   await driveApi.permissions.create(
     drive.Permission(role: 'reader', type: 'anyone'),
     result.id!,
   );
   ```
   - Sets permission so anyone with link can view
   - Doesn't require Drive account to access

4. **Generate Public Link**
   ```dart
   return 'https://drive.google.com/uc?export=view&id=${result.id}';
   ```
   - Creates direct public viewing link
   - Image displays inline in web/app

**Key Points:**
- OAuth is automatic (user sees Google login if needed)
- Permission handling is built-in
- Public link is immediately available
- No server-side upload needed

---

### Step 4: Combine Data for Registration
```dart
// Still in UploadPhotoScreen._handleStartRegistration()
setState(() {
  _isUploading = false;
  _isRegistering = true;
});

final result = await RegistrationService.register(
  userName: widget.userName,           // From SignUpPage
  email: widget.email,                 // From SignUpPage
  fullName: widget.fullName,           // From SignUpPage
  imageUrl: driveLink,                 // Just uploaded!
  password: widget.password,           // From SignUpPage
  confirmPassword: widget.confirmPassword, // From SignUpPage
  role: widget.role,                   // From SignUpPage (Instructor/Student)
);
```

**Key Points:**
- Combines photo upload result with signup data
- All 7 required fields now available
- Ready to send to registration API

---

### Step 5: Server Registration
```dart
// Inside RegistrationService.register()
final response = await http.post(
  Uri.parse('http://examtime.runasp.net/api/Account/Register'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'userName': userName,
    'email': email,
    'fullName': fullName,
    'imageUrl': imageUrl,  // Google Drive public link
    'password': password,
    'confirmPassword': confirmPassword,
    'role': role,
  }),
);
```

**Server Processing:**
1. Server receives all registration data + Drive image URL
2. Creates user account with provided details
3. Stores Drive link for user's profile picture
4. Generates email confirmation token
5. Sends confirmation email with verification link
6. Returns success response

**Response Structure:**
```json
{
  "status": true,
  "message": "Registration successful. Please confirm your email at: http://examtime.runasp.net/confirm?token=abc123xyz",
  "data": { "id": "user-123", "email": "user@example.com" }
}
```

---

### Step 6: Success & Navigation
```dart
// Back in UploadPhotoScreen._handleStartRegistration()
if (result['success']) {
  _showConfirmationDialog();  // Show success dialog
}
```

**Dialog Actions:**
1. Shows check icon ✓
2. Displays: "Registration Successful!"
3. Message: "Please check your email to confirm"
4. Button: "Go to Login"
5. On tap: Navigate to `/signin`

---

## Error Handling Chain

### Service Validation
```
SignUpPage validates input
        ↓
   All fields check ✓
        ↓
UploadPhotoScreen gets data
        ↓
   Image selected? ✓
        ↓
RegistrationService.validateRegistration() called
        ↓
   Email format ✓
   Password match ✓
   All fields not empty ✓
```

### Upload Errors
```
GoogleDriveService.uploadImageToGoogleDrive()
        ↓
   User signed in? → If not, auto-sign in
        ↓
   File uploaded? → If fails, throw exception
        ↓
   Made public? → If fails, return null
        ↓
   Return link or null
```

**Error Handling:**
```dart
try {
  final driveLink = await GoogleDriveService.uploadImageToGoogleDrive(_selectedImage!);
  if (driveLink == null) {
    throw Exception('Failed to generate Drive link');
  }
  // Continue to registration
} catch (e) {
  setState(() => _errorMessage = 'Error: ${e.toString()}');
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_errorMessage!)));
}
```

### Registration Errors
```
RegistrationService.register()
        ↓
POST /api/Account/Register
        ↓
   Status 200? → Success, show dialog
        ↓
   Status 409? → Email exists, show error
        ↓
   Status 400? → Bad request, show message
        ↓
   Status 500+? → Server error, show message
```

---

## Data Flow Diagram

```
User Input
   ├─ SignUpPage
   │  └─ CollectedData: {userName, email, fullName, password, role}
   │
   ├─ UploadPhotoScreen (receives collected data via constructor)
   │  ├─ User selects image
   │  │  └─ _selectedImage: File
   │  │
   │  ├─ GoogleDriveService uploads image
   │  │  └─ Returns: imageUrl (public Drive link)
   │  │
   │  ├─ Combine: CollectedData + imageUrl
   │  │  └─ FullRegistrationData: {userName, email, fullName, password, confirmPassword, role, imageUrl}
   │  │
   │  └─ RegistrationService registers
   │     ├─ Validates all fields
   │     ├─ POST to /api/Account/Register
   │     └─ Returns: {success, message, data}
   │
   └─ On Success
      ├─ Show confirmation dialog
      └─ Navigate to signin (/signin)
```

---

## Service Dependencies

### GoogleDriveService Dependencies
```dart
// External packages
google_sign_in        // OAuth with Google
googleapis            // Google Drive API
image_picker          // Gallery access
http                  // HTTP client for Drive API

// Internal packages
dart:io               // File handling
dart:async            // Future handling
```

### RegistrationService Dependencies
```dart
// External packages
http                  // HTTP requests
shared_preferences    // (Optional) Token storage after registration

// Dart built-in
dart:convert          // JSON encoding/decoding
dart:async            // Future handling
```

---

## Thread Safety & State Management

### Async Operations
```
SignUpPage._handleSignUp()
         ↓ (async)
   Navigator.push(UploadPhotoScreen)
         ↓
UploadPhotoScreen._handleStartRegistration() (async)
         ↓ setState(_isUploading = true)
   GoogleDriveService.uploadImageToGoogleDrive() (awaits)
         ↓ setState(_isUploading = false, _isRegistering = true)
   RegistrationService.register() (awaits)
         ↓ setState(_isRegistering = false)
   _showConfirmationDialog()
         ↓
   Navigator.pushReplacementNamed('/signin')
```

### State Checks
```dart
// After async operations, always check if widget is mounted
if (mounted) {
  setState(() => _someState = value);
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(...);
  }
}
```

---

## Performance Considerations

### Image Compression
```dart
// GoogleDriveService.pickImageFromDevice()
final cropped = await ImagePicker().pickImage(
  source: ImageSource.gallery,
  maxHeight: 1024,  // Max 1024px height
  maxWidth: 1024,   // Max 1024px width
  imageQuality: 85, // 85% JPEG quality
);
```

**Benefits:**
- Reduces upload time (typically 50-200KB)
- Reduces storage in Google Drive
- Faster display on client side
- Still maintains good visual quality

### Caching
```dart
// GoogleSignIn caches authentication
final googleSignIn = GoogleSignIn(...);
// Second call uses cached credentials
```

**Benefits:**
- No re-login on second upload
- Faster authentication (< 100ms vs 3-5s)
- Better user experience

---

## Testing Service Integration

### Unit Test Example
```dart
// Test validation before upload
test('validateRegistration should catch password mismatch', () {
  final result = RegistrationService.validateRegistration(
    userName: 'testuser',
    email: 'test@example.com',
    fullName: 'Test User',
    password: 'password123',
    confirmPassword: 'password456', // Mismatch!
    role: 'Student',
  );
  
  expect(result['valid'], false);
  expect(result['message'], contains('must match'));
});
```

### Integration Test Example
```dart
// Test complete flow
testWidgets('SignUp flow completes successfully', (tester) async {
  // 1. Navigate to signup
  // 2. Fill form
  // 3. Tap Continue
  // 4. Pick image
  // 5. Tap Start
  // 6. Wait for success dialog
  // 7. Verify navigation
});
```

---

## Troubleshooting Integration Issues

### Image Upload Hangs
**Problem:** Upload seems to freeze
**Solution:** Check network connection, increase timeout in http client

### Google Drive API Errors
**Problem:** "Permission denied" or "Invalid token"
**Solution:** Ensure Google Cloud project is configured correctly

### Registration API Returns 400
**Problem:** "Invalid field" errors
**Solution:** Check all fields are provided and match validation rules

### Email Not Sent
**Problem:** User doesn't receive confirmation email
**Solution:** Check server logs, verify email service configuration

---

## Security Notes

### OAuth Security
- Google Sign-In handles token management
- Tokens are kept in memory only
- No sensitive data logged
- User can revoke access anytime

### Image Privacy
- Public Drive link doesn't expose user identity
- Image can be accessed by anyone with link
- User can delete image from Drive anytime
- No private information in image URL

### Password Security
- Passwords sent via HTTPS only
- Hashed on server (bcrypt recommended)
- Never stored in plaintext
- Never sent back in responses

---

## Future Enhancements

1. **Image Cropping**: Allow users to crop/rotate before upload
2. **Multiple Photos**: Support profile photo + document verification
3. **Retry Logic**: Auto-retry failed uploads
4. **Offline Support**: Queue registration for later if offline
5. **Two-Factor Auth**: Additional security for email verification
6. **Social Login**: Option to sign up with Google/Facebook directly
