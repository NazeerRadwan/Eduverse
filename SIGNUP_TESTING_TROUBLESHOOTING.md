# SignUp Feature - Testing & Troubleshooting Guide

## Testing the SignUp Flow

### Quick Test Checklist

#### Form Validation Tests
- [ ] **Empty fields:** Tap Continue without filling any field
  - **Expected:** Error message "Please fill all fields"
  - **Visual:** Red snackbar appears

- [ ] **Invalid email:** Enter "notanemail" in email field
  - **Expected:** Error message "Invalid email address"
  - **When:** Tap Continue button

- [ ] **Short password:** Enter password < 6 characters
  - **Expected:** Error message "Password must be at least 6 characters"

- [ ] **Password mismatch:** Enter different password and confirm
  - **Expected:** Error message "Passwords must match"

- [ ] **Username too short:** Enter username with < 3 characters
  - **Expected:** Error message "Username must be at least 3 characters"

#### Photo Upload Tests
- [ ] **No photo selected:** Tap Start without selecting photo
  - **Expected:** Error message "Please select a photo"
  - **Visual:** Red snackbar at bottom

- [ ] **Select photo:** Tap "Select Photo" button
  - **Expected:** System gallery opens
  - **When:** Choose any image

- [ ] **Photo preview:** After selection
  - **Expected:** Image appears in 200x200 preview box
  - **Visual:** Clear preview of selected image

- [ ] **Large image:** Select high-res photo (3000x3000+)
  - **Expected:** Compressed to max 1024x1024 before upload
  - **Verification:** Check file size is reasonable

#### Google Drive Upload Tests
- [ ] **First upload:** Tap Start with photo selected
  - **Expected:** Google Sign-In prompt appears (if first time)
  - **Visual:** Loading spinner during upload
  - **Duration:** 2-4 seconds typically

- [ ] **Successful upload:** After loading finishes
  - **Expected:** No error message
  - **Next:** Registration API should be called

- [ ] **Network error:** Turn off internet before tapping Start
  - **Expected:** Error message about network
  - **Recovery:** Re-enable internet and try again

#### Registration API Tests
- [ ] **Valid registration:** All data correct, photo uploaded
  - **Expected:** Success dialog appears
  - **Visual:** Green check icon with "Registration Successful!"

- [ ] **Duplicate email:** Register twice with same email
  - **Expected:** Error on second registration
  - **Message:** "Email already registered" or similar

- [ ] **Duplicate username:** Register twice with same username
  - **Expected:** Error on second registration
  - **Message:** "Username already taken"

#### Confirmation Dialog Tests
- [ ] **Dialog displays:** After successful registration
  - **Expected:** Modal dialog with check icon
  - **Message:** "Please check your email to confirm your account"
  - **Button:** "Go to Login"

- [ ] **Tap Go to Login:** Click button in dialog
  - **Expected:** Dialog closes
  - **Navigation:** Navigated to SignIn screen
  - **Visual:** Back at login page

#### Navigation Tests
- [ ] **Back button on SignUp:** Tap back arrow
  - **Expected:** Return to previous screen
  - **Typical:** Either home or previous signup attempt

- [ ] **Back button on Upload Photo:** Tap back arrow
  - **Expected:** Return to SignUp screen
  - **Behavior:** Form data might be lost

- [ ] **Already have account link:** Tap "Already have an account? Log in"
  - **Expected:** Navigate to SignIn screen
  - **Route:** `/signin`

---

## Manual Test Scenarios

### Scenario 1: Happy Path (Normal Registration)

```
Step 1: Fill SignUp Form
├─ Username: "johndoe2024"
├─ Full Name: "John Doe"
├─ Email: "john.doe.2024@example.com"
├─ Password: "SecurePass123!"
├─ Confirm Password: "SecurePass123!"
└─ Role: Student

Step 2: Tap "Continue"
└─ Should navigate to UploadPhotoScreen

Step 3: Select Photo
├─ Tap "Select Photo" button
├─ Choose image from gallery (any JPEG/PNG)
└─ Preview should show selected image

Step 4: Tap "Start"
├─ Loading spinner appears
├─ Google Sign-In might popup (first time)
├─ Google Drive upload completes
├─ Loading spinner continues for registration
└─ Completes when API returns

Step 5: Success Dialog
├─ Dialog appears with check mark ✓
├─ Title: "Registration Successful!"
├─ Message: "Please check your email to confirm"
└─ Button: "Go to Login"

Step 6: Tap "Go to Login"
├─ Dialog closes
├─ Navigated to SignIn screen
└─ Test complete ✓
```

### Scenario 2: Validation Error

```
Step 1: Open SignUp Form

Step 2: Fill with invalid data
├─ Email: "not-an-email" (missing @)
├─ Password: "123" (too short)
└─ Confirm: "456" (doesn't match)

Step 3: Tap "Continue"
├─ Red error message appears
├─ Message indicates first validation error
└─ Remains on SignUp screen

Step 4: Correct errors
└─ Fix email and password fields

Step 5: Tap "Continue" again
└─ Should proceed if all valid
```

### Scenario 3: Photo Upload Failure

```
Step 1: Fill SignUp and navigate to UploadPhoto

Step 2: Disable Internet
└─ Turn off WiFi/mobile data

Step 3: Select photo and tap "Start"
├─ Loading spinner appears
├─ After timeout, error message shows
└─ Error: Network related message

Step 4: Enable Internet and retry
├─ Photo still selected
├─ Tap "Start" again
└─ Should succeed this time
```

### Scenario 4: Duplicate Email

```
Step 1: Register with email "test@example.com"
├─ Complete entire flow successfully
├─ Receive confirmation dialog
└─ Navigate to login

Step 2: SignUp again with same email
├─ Fill form with same "test@example.com"
├─ Select photo and tap Start
├─ Upload completes
└─ API returns error

Step 3: Error handling
├─ Error dialog/snackbar shows
├─ Message: "Email already registered"
├─ User can tap back and try different email
```

---

## Device Testing

### Test on Different Devices

#### Small Phone (iPhone SE / 5.4" Android)
- [ ] Text is readable
- [ ] Buttons are easily tappable
- [ ] Scrolling works smoothly
- [ ] Images fit in preview box
- [ ] Dialog appears properly

#### Standard Phone (iPhone 12 / 6.1" Android)
- [ ] Layout looks balanced
- [ ] No UI overflow
- [ ] Fields have good spacing
- [ ] Loading spinners visible

#### Large Phone (iPhone Pro Max / 6.7" Android)
- [ ] Content doesn't feel stretched
- [ ] Good use of screen space
- [ ] Preview image not oversized

#### Tablet (iPad / Android Tablet)
- [ ] Form centered or properly scaled
- [ ] Still usable (might look strange if not optimized)
- [ ] Dialogs positioned correctly

---

## Common Issues & Solutions

### Issue 1: "Google Sign-In Failed"

**Symptoms:**
- Popup says "Sign-in unsuccessful"
- Or: "Unable to sign in to Google"

**Causes:**
1. Google credentials not configured
2. Internet connectivity issue
3. Google account problem

**Solutions:**
```
① Check internet connection
② Verify Google Account is accessible
③ Clear app cache:
   - Android: Settings → Apps → [YourApp] → Storage → Clear Cache
   - iOS: Delete and reinstall app
④ Verify Google Cloud project configured with:
   - OAuth 2.0 Client ID
   - Correct bundle ID / package name
```

---

### Issue 2: "Photo Upload Times Out"

**Symptoms:**
- Loading spinner for > 30 seconds
- Or: Upload fails after timeout

**Causes:**
1. Poor internet connection
2. Image file too large
3. Google Drive API rate limit

**Solutions:**
```
① Check network signal (WiFi or 4G/5G)
② Try smaller image (~1-2 MB)
③ Wait 5 minutes and retry (API rate limit recovery)
④ Check Google API quotas in Cloud Console
```

---

### Issue 3: "Email Already Registered"

**Symptoms:**
- After upload completes, error appears
- Error message: "Email already in use"

**Causes:**
1. Email already registered in database
2. Testing with old email addresses
3. Database not cleared between tests

**Solutions:**
```
① Use new email for each test:
   - test+timestamp@example.com
   - test+1@example.com, test+2@example.com, etc.
② Ask admin to clear database
③ Use staging/test database instead of production
```

---

### Issue 4: "Confirmation Dialog Not Showing"

**Symptoms:**
- Upload completes successfully (no errors)
- But no dialog appears
- Stuck on UploadPhotoScreen

**Causes:**
1. Registration successful but dialog code has issue
2. Race condition between screens
3. Widget disposed during navigation

**Solutions:**
```dart
① Check logs: `flutter logs | grep "dialog\|confirmation"`
② Verify mounted check in code:
   if (mounted) {
     _showConfirmationDialog();
   }
③ Ensure navigation uses context correctly:
   Navigator.of(context).pushReplacementNamed('/signin');
```

---

### Issue 5: "Photo Picker Permissions"

**Symptoms:**
- "Select Photo" button does nothing
- Or: iOS shows permission denied

**Causes:**
1. App permissions not granted
2. Platform-specific permission issue
3. iOS pod cache issue

**Solutions - Android:**
```
① Grant permission at runtime:
   Settings → Apps → [YourApp] → Permissions → Photos ✓
```

**Solutions - iOS:**
```
① Open Settings
② Privacy → Photos
③ [YourApp] → Read and Write
```

**Solutions - Both:**
```
① Clear build cache: flutter clean
② Rebuild: flutter pub get && flutter run
③ If still fails, check Info.plist (iOS):
   - NSPhotoLibraryUsageDescription
   - NSPhotoLibraryAddUsageDescription
```

---

### Issue 6: "API Returns 400 Bad Request"

**Symptoms:**
- Error message: "400 Bad Request"
- Or: Response shows validation error

**Causes:**
1. Missing required field
2. Invalid field format
3. API version mismatch

**Solutions:**
```
① Check all 7 fields are provided:
   - userName ✓
   - email ✓
   - fullName ✓
   - imageUrl ✓ (must be valid URL)
   - password ✓
   - confirmPassword ✓
   - role ✓ (Instructor or Student)

② Verify imageUrl format:
   https://drive.google.com/uc?export=view&id=<fileId>

③ Check API documentation for updated requirements
```

---

### Issue 7: "Navigation to Login Doesn't Work"

**Symptoms:**
- "Go to Login" button tapped
- Dialog closes but screen doesn't change
- Or: Navigation error in console

**Causes:**
1. Route not defined in main.dart
2. Wrong route name used
3. Context issue

**Solutions:**
```dart
① Verify main.dart has route:
   routes: {
     '/signin': (context) => const SigninScreen(),
     ...
   }

② Check navigation code:
   Navigator.of(context).pushReplacementNamed('/signin');
   // Not: Navigator.push(...)

③ Verify SigninScreen import exists
```

---

## Debugging Tips

### Enable Verbose Logging
```bash
# Run with verbose output
flutter run -v

# Filter for specific errors
flutter run -v 2>&1 | grep "error\|Error\|ERROR"
```

### Add Debug Print Statements
```dart
// In upload_photo.dart
void _handleStartRegistration() async {
  print('DEBUG: Starting registration');
  print('DEBUG: Image selected: $_selectedImage');
  
  try {
    print('DEBUG: Uploading to Drive...');
    final driveLink = await GoogleDriveService.uploadImageToGoogleDrive(_selectedImage!);
    print('DEBUG: Drive link: $driveLink');
    
    print('DEBUG: Calling registration API...');
    final result = await RegistrationService.register(...);
    print('DEBUG: Registration result: $result');
    
    if (result['success']) {
      print('DEBUG: Success! Showing dialog...');
      _showConfirmationDialog();
    }
  } catch (e) {
    print('DEBUG: Error occurred: $e');
    print('DEBUG: Stack trace: ${StackTrace.current}');
  }
}
```

### Use DevTools
```bash
flutter pub global activate devtools
devtools

# In another terminal
flutter run --observatory-port=50300
# Then open: http://localhost:9100
```

---

## Network Inspection

### Capture API Requests

**Option 1: Proxy (Charles/Fiddler)**
```
1. Configure device proxy
2. Monitor requests/responses
3. Check headers and body
```

**Option 2: Add logging to service**
```dart
// In registration_service.dart
print('DEBUG: POST ${Uri.parse(...)}');
print('DEBUG: Headers: $headers');
print('DEBUG: Body: $body');
print('DEBUG: Response: ${response.statusCode}');
print('DEBUG: Response body: ${response.body}');
```

---

## Test Data

### Valid Test Emails
```
test1@example.com
test2@example.com
user.test@gmail.com
validate.test@hotmail.com
```

### Valid Test Usernames
```
johndoe
jdoe2024
testuser_123
user123abc
```

### Valid Passwords
```
TestPass123!
SecurePassword@2024
P@ssw0rd123
ValidPass#2024
```

### Test Roles
```
Student
Instructor
```

---

## Performance Benchmarks

### Expected Timings

| Operation | Time | Notes |
|-----------|------|-------|
| Form validation | < 100ms | Instant |
| Image picker open | 500-1000ms | OS dependent |
| Image compression | 200-500ms | Depends on image size |
| Google OAuth popup | 2-5s | First time only |
| Google Drive upload | 2-10s | Depends on image size & network |
| Registration API | 1-3s | Server processing time |
| Total flow | 10-20s | Typical happy path |

**Optimization Tips:**
- Use faster internet (4G/5G vs 3G)
- Use smaller images for testing
- Clear Google cache if slow
- Use staging server if available

---

## Regression Testing

### After Each Update, Test:

1. **Form validation** - Still catches invalid inputs?
2. **Google Drive** - Still uploads successfully?
3. **Registration API** - Still calls with correct data?
4. **Error handling** - Still shows proper error messages?
5. **Navigation** - Still navigates correctly?
6. **UI responsiveness** - Still smooth with loading indicators?

---

## Test Report Template

```
SignUp Feature - Test Report
Date: _______________
Tester: ______________
Device: _______________

Results:
┌─────────────────┬─────────┬──────────────────┐
│ Test Case       │ Status  │ Notes            │
├─────────────────┼─────────┼──────────────────┤
│ Form validation │ ✓/✗     │ _______________  │
│ Photo upload    │ ✓/✗     │ _______________  │
│ Google Drive    │ ✓/✗     │ _______________  │
│ Registration    │ ✓/✗     │ _______________  │
│ Navigation      │ ✓/✗     │ _______________  │
│ Dialog display  │ ✓/✗     │ _______________  │
└─────────────────┴─────────┴──────────────────┘

Issues Found:
1. _____________________________________
2. _____________________________________
3. _____________________________________

Overall Status: ✓ PASS / ✗ FAIL
```

---

## Support & Escalation

### Getting Help

**For Development Team:**
1. Check this troubleshooting guide first
2. Add debug prints and share output
3. Check Flutter logs: `flutter logs`
4. Share device info: OS version, app version
5. Share exact error message/screenshot

**Information to Provide:**
```
Device: [iOS/Android] [Version]
Flutter Version: [flutter --version]
Error: [Exact error message]
Logs: [Last 50 lines of flutter logs]
Screenshot: [If applicable]
Steps to Reproduce: [1., 2., 3., ...]
Expected: [What should happen]
Actual: [What actually happened]
```

