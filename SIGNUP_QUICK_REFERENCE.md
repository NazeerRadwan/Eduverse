# SignUp Implementation - Quick Reference

## File Structure
```
lib/
├── Screens/
│   ├── signUp_screen.dart              ← Form data collection
│   ├── upload_photo.dart               ← Photo upload + registration
│   ├── signIn_screen.dart              ← Login (already done)
│   └── view_courses_screen.dart        ← Main app
└── services/
    ├── registration_service.dart       ← Validation + API
    ├── google_drive_service.dart       ← Photo upload
    └── auth_service.dart               ← Login
```

## Routes
```dart
'/signin'      → SigninScreen()        // Login
'/signup'      → SignUpPage()          // Signup form
'/view_courses'→ EduversesPage()       // Main app
```

## Key Classes

### RegistrationService
```dart
// Validate form data
Map<String, dynamic> validateRegistration({
  required String userName,
  required String email,
  required String fullName,
  required String password,
  required String confirmPassword,
  required String role,
})

// Register with API
Future<Map<String, dynamic>> register({
  required String userName,
  required String email,
  required String fullName,
  required String imageUrl,      // Google Drive link
  required String password,
  required String confirmPassword,
  required String role,           // 'Instructor' or 'Student'
})
```

### GoogleDriveService
```dart
// Pick image from device
Future<File?> pickImageFromDevice()

// Upload to Google Drive & return public link
Future<String?> uploadImageToGoogleDrive(File imageFile)
// Returns: https://drive.google.com/uc?export=view&id=...

// Sign out (optional cleanup)
Future<void> signOutGoogle()
```

## Flow
```
1. SignUpPage
   └─ Collect: userName, fullName, email, password, role
   
2. UploadPhotoScreen (receives all above data)
   ├─ Pick image via GoogleDriveService.pickImageFromDevice()
   ├─ Upload to Drive via GoogleDriveService.uploadImageToGoogleDrive()
   ├─ Get public link: https://drive.google.com/uc?export=view&id=...
   └─ Register via RegistrationService.register({...all data... + imageUrl})
   
3. Confirmation Dialog
   └─ Navigate to /signin on "Go to Login" tap
```

## API Endpoint
```
POST http://examtime.runasp.net/api/Account/Register

Body:
{
  "userName": "johndoe",
  "email": "john@example.com",
  "fullName": "John Doe",
  "imageUrl": "https://drive.google.com/uc?export=view&id=ABC123",
  "password": "SecurePass123",
  "confirmPassword": "SecurePass123",
  "role": "Student"
}

Response (200):
{
  "status": true,
  "message": "Registration successful...",
  "data": { "id": "...", "email": "..." }
}
```

## Validation Rules
```
✓ Email: valid@email.com format
✓ Username: >= 3 characters
✓ Full Name: >= 3 characters
✓ Password: >= 6 characters
✓ Passwords: must match
✓ Role: 'Instructor' or 'Student'
✓ Image: Must be selected (no null)
```

## States
```dart
_isUploading     // True during Google Drive upload
_isRegistering   // True during API registration call
_errorMessage    // String or null
_selectedImage   // File or null
```

## Buttons
```
SignUpPage:
- "Continue"           → Validate + navigate to upload_photo
- "Already have account? Log in" → Navigate to /signin

UploadPhotoScreen:
- "Select Photo"       → Pick image via gallery
- "Start"              → Upload + register
- Back arrow           → Go back to signup
```

## Error Messages
```
Empty fields          → "Please fill all fields"
Invalid email         → "Invalid email address"
Short password        → "Password must be at least 6 characters"
Password mismatch     → "Passwords must match"
Short username        → "Username must be at least 3 characters"
No image selected     → "Please select a photo"
Upload failed         → "Failed to upload image to Google Drive"
Email exists          → "Email already registered" (from API)
Username taken        → "Username already taken" (from API)
```

## Loading States
```
Photo selection   → Loading spinner on "Select Photo"
Drive upload      → Loading spinner on "Start", shows during upload
API registration  → Loading spinner continues on "Start"
```

## Success Path
1. Form filled & validated ✓
2. Image selected ✓
3. Image uploaded to Drive ✓
4. Public link generated ✓
5. Registration API called ✓
6. Confirmation dialog shown ✓
7. Navigate to login ✓

## Emergency Exit Points
```
❌ On SignUp: Back button
❌ On Upload Photo: Back button  
❌ On Dialog: (No escape, must tap "Go to Login")
```

## Testing Checklist
```
□ Form validation
□ Image picker
□ Image preview
□ Google Drive upload
□ API registration
□ Duplicate email handling
□ Duplicate username handling
□ Error message display
□ Dialog display
□ Navigation to login
□ Offline handling
```

## Common Commands
```bash
# Clean and rebuild
flutter clean && flutter pub get && flutter run

# Run with logs
flutter run -v

# Check lint
flutter analyze

# Format code
dart format lib/
```

## Documentation Files
```
📄 SIGNUP_INTEGRATION_GUIDE.md         ← Complete flow documentation
📄 SERVICE_INTEGRATION_GUIDE.md        ← How services work together
📄 SIGNUP_TESTING_TROUBLESHOOTING.md   ← Testing & common issues
📄 SIGNUP_QUICK_REFERENCE.md           ← This file
```

## Important Notes
- Google Drive requires OAuth (auto-popup on first upload)
- Image URL must be public Drive link in format: `https://drive.google.com/uc?export=view&id=...`
- All 7 fields required for registration API
- Role is case-sensitive: 'Instructor' or 'Student' (not 'instructor')
- Password confirmation is separate field, not just validation
- Email confirmation link sent in response message
- User must tap dialog button to proceed (no auto-close)

## Dependencies
```yaml
http: ^1.1.0                    # HTTP requests
google_sign_in: ^6.1.0          # Google authentication
googleapis: ^11.4.0             # Google Drive API
image_picker: ^1.0.0            # Image gallery
shared_preferences: ^2.2.0      # Token storage (optional)
```
