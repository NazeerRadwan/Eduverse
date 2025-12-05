# Architecture & Flow Diagrams

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter App (EduVerse)                   │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │          UI Layer (Screens)                          │  │
│  ├──────────────────────────────────────────────────────┤  │
│  │  • SigninScreen (signin_screen.dart)                │  │
│  │  • ViewCoursesScreen (view_courses_screen.dart)    │  │
│  │  • SignupScreen (signup_screen.dart)               │  │
│  └──────────┬───────────────────────────────┬──────────┘  │
│             │ Uses                          │ Uses         │
│  ┌──────────▼──────────────┐  ┌────────────▼──────────┐  │
│  │   Auth Service          │  │   API Services        │  │
│  │ (auth_service.dart)     │  │ (api_example.dart)    │  │
│  ├─────────────────────────┤  ├─────────────────────────┤ │
│  │ • login()               │  │ • getCourses()        │  │
│  │ • getToken()            │  │ • getCourseDetail()   │  │
│  │ • logout()              │  │ • enrollCourse()      │  │
│  │ • isLoggedIn()          │  │ • ...                 │  │
│  └──────────┬──────────────┘  └────────────┬───────────┘  │
│             │                              │                 │
│             │ Uses                         │ Uses            │
│  ┌──────────▼──────────────┐  ┌────────────▼──────────┐  │
│  │  Local Storage           │  │   HTTP Client        │  │
│  │ (SharedPreferences)      │  │ (package:http)       │  │
│  ├─────────────────────────┤  ├─────────────────────────┤ │
│  │ • auth_token            │  │ • POST requests       │  │
│  │ • token_expired         │  │ • GET requests        │  │
│  │ • user_data (optional)  │  │ • Headers & body      │  │
│  └─────────────────────────┘  └────────────┬───────────┘  │
│                                             │                 │
└─────────────────────────────────────────────┼─────────────────┘
                                              │
                                              ↓
                        ┌─────────────────────────────┐
                        │   API Server                │
                        │ examtime.runasp.net         │
                        ├─────────────────────────────┤
                        │ • POST /api/Account/Login   │
                        │ • POST /api/Courses/Enroll  │
                        │ • GET /api/Courses          │
                        │ • ...                       │
                        └─────────────────────────────┘
```

---

## Login Flow Diagram

```
┌─────────────────────┐
│  SignIn Screen      │
│  - Email input      │
│  - Password input   │
└──────────┬──────────┘
           │
           ▼
    ┌──────────────────┐
    │  User taps       │
    │  "Log in"        │
    │  button          │
    └──────────┬───────┘
               │
               ▼
        ┌─────────────────────┐
        │ _handleLogin()      │
        │ called              │
        └──────────┬──────────┘
                   │
                   ▼
        ┌─────────────────────┐
        │ Validation Phase    │
        ├─────────────────────┤
        │ ✓ Email not empty?  │
        │ ✓ Password not empty?│
        │ ✓ Valid email format?│
        └─────────┬───────────┘
                  │
        ┌─────────┴──────────────┐
        │                        │
   NO   ↓                        ↓ YES
  ┌──────────┐           ┌────────────────┐
  │ Show     │           │ Set loading=true│
  │ error    │           │ Clear errors    │
  │ message  │           └────────┬────────┘
  └──────────┘                    │
                                  ▼
                        ┌─────────────────────┐
                        │ AuthService.login() │
                        │ Makes HTTP POST     │
                        │ request to API      │
                        └─────────┬───────────┘
                                  │
        ┌─────────────────────────┼─────────────────────────┐
        │                         │                         │
        ▼                         ▼                         ▼
  ┌──────────────┐          ┌──────────────┐        ┌──────────────┐
  │ Success (200)│          │ Error (401)  │        │ Error (500+) │
  ├──────────────┤          ├──────────────┤        ├──────────────┤
  │ • Parse JSON │          │ • Invalid    │        │ • Server     │
  │ • Extract    │          │   creds      │        │   error      │
  │   token      │          │ • Show error │        │ • Show error │
  │ • Save token │          │   message    │        │   message    │
  │ • Save expiry│          └──────────────┘        └──────────────┘
  │ • Set        │                 │                       │
  │   loading=   │                 │                       │
  │   false      │                 │                       │
  └──────┬───────┘                 │                       │
         │                         └──────────┬────────────┘
         │                                    │
         ▼                                    ▼
   ┌──────────────┐              ┌──────────────────┐
   │ Navigate to  │              │ Set loading=false│
   │ /view_courses│              │ Display error    │
   │ (replace)    │              │ message          │
   └──────────────┘              └──────────────────┘
         │                                    │
         └─────────────────────┬──────────────┘
                               │
                        ┌──────▼──────┐
                        │ User stays  │
                        │ on SignIn   │
                        │ screen &    │
                        │ can retry   │
                        └─────────────┘
```

---

## Component Interaction Diagram

```
┌──────────────────────────────────────┐
│      SigninScreen Widget             │
├──────────────────────────────────────┤
│                                      │
│  State:                              │
│  • _emailCtl: TextEditingController  │
│  • _passCtl: TextEditingController   │
│  • _isLoading: bool                  │
│  • _errorMessage: String?            │
│  • _obscure: bool                    │
│                                      │
│  Methods:                            │
│  • _handleLogin()         ──┐        │
│  • _isValidEmail()        ──┤        │
│  • _dec()                 ──┤        │
│  • _googleSignInButton()  ──┤        │
│  • _socialButton()        ──┤        │
│  • build()                ──┤        │
│                             │        │
│  UI Elements:           ┌───┘        │
│  • TextField (email)    │            │
│  • TextField (password) │            │
│  • ElevatedButton       │            │
│  • Text (error message) │            │
│  • Spinner (loading)    │            │
└────────────┬────────────┘            │
             │ calls                   │
             │ (on login button tap)   │
             │                         │
             ▼                         │
    ┌────────────────────────┐        │
    │  _handleLogin()        │        │
    ├────────────────────────┤        │
    │                        │        │
    │ 1. Validate inputs     │        │
    │ 2. Set loading state   │        │
    │ 3. Call AuthService    │        │
    │    .login()            │        │
    │ 4. Handle response:    │        │
    │    • Success: Navigate │        │
    │    • Error: Show msg   │        │
    │ 5. Set loading false   │        │
    │                        │        │
    │ Uses: AuthService      │        │
    └────────────┬───────────┘        │
                 │ calls              │
                 │                    │
                 ▼                    │
    ┌───────────────────────────┐    │
    │  AuthService.login()      │    │
    ├───────────────────────────┤    │
    │                           │    │
    │ 1. Create request body    │    │
    │ 2. Set headers:           │    │
    │    - Content-Type         │    │
    │    - Accept               │    │
    │ 3. POST to API            │    │
    │ 4. Parse response         │    │
    │ 5. If success:            │    │
    │    • Save token           │    │
    │    • Save expiry          │    │
    │    • Return result        │    │
    │ 6. If error:              │    │
    │    • Parse error msg      │    │
    │    • Return error result  │    │
    │                           │    │
    │ Uses:                     │    │
    │ • http.post()             │    │
    │ • SharedPreferences       │    │
    └───────────┬───────────────┘    │
                │ HTTP POST           │
                │                    │
                ▼                    │
    ┌──────────────────────────┐    │
    │  API Server              │    │
    │  /api/Account/Login      │    │
    ├──────────────────────────┤    │
    │                          │    │
    │ Receives:                │    │
    │ • email                  │    │
    │ • password               │    │
    │                          │    │
    │ Returns:                 │    │
    │ • status (bool)          │    │
    │ • message.massage        │    │
    │ • message.token (JWT)    │    │
    │ • message.expired        │    │
    │                          │    │
    └──────────────────────────┘    │
                                      │
└──────────────────────────────────────┘
```

---

## Data Flow: Login Request

```
User Input                 Validation              API Call
┌─────────────────┐   ┌──────────────────┐   ┌─────────────────┐
│  email: string  │──▶│ Email not empty  │──▶│  HTTP POST      │
│                 │   │ & valid format   │   │                 │
│ password:string │   │                  │   │  Headers:       │
│                 │   │ Password not     │   │  • Content-Type │
│                 │   │ empty            │   │  • Accept       │
│                 │   │                  │   │                 │
└─────────────────┘   └──────────────────┘   │  Body:          │
                            │                │  {email,password}│
                            │                │                 │
                            ▼                │                 │
                      ┌─────────────┐        │                 │
                      │  Valid?     │        │                 │
                      │             │        │                 │
                      └─┬───────┬───┘        │                 │
                        │       │           │                 │
                       NO      YES          │                 │
                        │       │           │                 │
                        │       └───────────▶ http.post()      │
                        │                      │               │
Response Handling       │                      ▼               │
                        │              ┌──────────────────┐    │
                        │              │ API Server       │    │
                        │              │ Processes request│    │
                        │              └──────┬───────────┘    │
                        │                     │                 │
         ┌──────────────┴─────────────────────┴──────┐          │
         │                                           │          │
         ▼                                           ▼          │
    ┌─────────────┐                            ┌──────────────┐│
    │ Error:      │                            │ Success:     ││
    │ Show message│                            │ Return token ││
    │ Stay on page│                            │ & expiry     ││
    └─────────────┘                            └──────┬───────┘│
         │                                           │          │
         │                                           ▼          │
         │                                    ┌──────────────┐  │
         │                                    │ Save token to│  │
         │                                    │ SharedPrefs  │  │
         │                                    └──────┬───────┘  │
         │                                           │          │
         └───────────────────────┬───────────────────┘          │
                                 │                              │
                                 ▼                              │
                         ┌──────────────┐                      │
                         │ Navigate to  │                      │
                         │ /view_courses│                      │
                         └──────────────┘                      │
```

---

## State Management Flow

```
╔═══════════════════════════════════════════════════════════════╗
║              SigninScreen State Changes                        ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  Initial State:                                               ║
║  ┌─────────────────────────────────────────────────────┐     ║
║  │ _isLoading = false                                  │     ║
║  │ _errorMessage = null                               │     ║
║  │ _emailCtl.text = ""                                │     ║
║  │ _passCtl.text = ""                                │     ║
║  │ _obscure = true                                    │     ║
║  └─────────────────────────────────────────────────────┘     ║
║                           │                                  ║
║                           ▼ (User taps login)                ║
║                                                              ║
║  Loading State:                                             ║
║  ┌─────────────────────────────────────────────────────┐     ║
║  │ _isLoading = true          ◄─ setState()            │     ║
║  │ _errorMessage = null       ◄─ setState()            │     ║
║  │                                                    │     ║
║  │ UI Changes:                                        │     ║
║  │ • Button shows spinner                            │     ║
║  │ • Button disabled                                 │     ║
║  │ • No error message                                │     ║
║  └─────────────────────────────────────────────────────┘     ║
║                           │                                  ║
║         ┌─────────────────┼─────────────────┐               ║
║         │ API Response    │                 │               ║
║         │                                  │                ║
║    Success (200)                      Error (Any)            ║
║         │                                  │                ║
║         ▼                                  ▼                ║
║                                                              ║
║  Success State:            Error State:                     ║
║  ┌─────────────────┐      ┌──────────────────────┐          ║
║  │ _isLoading=false│      │ _isLoading = false   │          ║
║  │ Navigate to     │      │ _errorMessage =      │          ║
║  │ /view_courses   │      │  error from API      │          ║
║  │                 │      │                      │          ║
║  │ UI Changes:     │      │ UI Changes:          │          ║
║  │ • Screen        │      │ • Error box shown    │          ║
║  │   changes       │      │ • Button enabled     │          ║
║  │ • New route     │      │ • User can retry     │          ║
║  │                 │      │                      │          ║
║  └─────────────────┘      └──────────────────────┘          ║
║                                                              ║
╚═══════════════════════════════════════════════════════════════╝
```

---

## File Dependencies

```
main.dart
  ├── imports SigninScreen
  ├── imports EduversesPage
  ├── imports SignUpPage
  └── creates routes

signIn_screen.dart
  ├── imports AuthService
  ├── uses TextEditingController
  ├── uses TextField
  ├── uses ElevatedButton
  ├── calls AuthService.login()
  └── navigates via Navigator

auth_service.dart
  ├── imports http package
  ├── imports SharedPreferences
  ├── imports jsonDecode
  ├── defines base URL
  ├── provides login()
  ├── provides getToken()
  ├── provides logout()
  └── provides isLoggedIn()

SharedPreferences (Device Storage)
  └── stores 'auth_token' & 'token_expired'

HTTP Request
  └── sends to 'http://examtime.runasp.net/api/Account/Login'
```

---

## Error Handling Tree

```
_handleLogin() called
    │
    ├─ Validation Errors
    │  ├─ Email empty → Show: "Please enter both email and password"
    │  ├─ Password empty → Show: "Please enter both email and password"
    │  └─ Invalid format → Show: "Please enter a valid email"
    │
    ├─ API Call
    │  ├─ Try Block
    │  │  ├─ HTTP POST request
    │  │  │  ├─ 200 OK
    │  │  │  │  ├─ status == true → Navigate to /view_courses
    │  │  │  │  └─ status == false → Show: message from API
    │  │  │  │
    │  │  │  ├─ 401 Unauthorized
    │  │  │  │  └─ Show: "Invalid email or password"
    │  │  │  │
    │  │  │  ├─ 500+ Server Error
    │  │  │  │  └─ Show: "Server error: XXX"
    │  │  │  │
    │  │  │  └─ Timeout (30 seconds)
    │  │  │     └─ Show: "Connection timeout"
    │  │  │
    │  │  └─ json decode error → Show error message
    │  │
    │  └─ Catch Block
    │     └─ Exception caught → Show: "Error: $e"
    │
    └─ Finally (not used, but would cleanup)
```

---

## Token Lifecycle

```
┌──────────────────────────────────────────────────────────────┐
│                    Token Lifecycle                            │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  1. LOGIN SUCCESSFUL                                         │
│     ├─ API returns JWT token & expiration date              │
│     ├─ Token stored in SharedPreferences                    │
│     │  • Key: 'auth_token'                                  │
│     │  • Value: 'eyJhbGciOiJI...'                          │
│     ├─ Expiration stored:                                   │
│     │  • Key: 'token_expired'                               │
│     │  • Value: '2025-11-18T12:02:55Z'                     │
│     └─ Ready for use                                        │
│                                                              │
│  2. MAKING AUTHENTICATED REQUESTS                            │
│     ├─ Retrieve token: AuthService.getToken()              │
│     ├─ Add to header: 'Authorization': 'Bearer $token'     │
│     ├─ Send request                                         │
│     └─ Handle responses                                     │
│                                                              │
│  3. TOKEN USAGE                                              │
│     ├─ Used for: CoursesApiService.getUserCourses()        │
│     ├─ Used for: CoursesApiService.getCourseDetail()       │
│     ├─ Used for: Any protected endpoint                    │
│     └─ Valid until: token_expired date                     │
│                                                              │
│  4. TOKEN EXPIRATION (Future Implementation)                 │
│     ├─ Check expiration date before request                │
│     ├─ If expired: Refresh token                           │
│     ├─ If refresh fails: Logout user                       │
│     └─ Redirect to login                                   │
│                                                              │
│  5. LOGOUT                                                   │
│     ├─ Call: AuthService.logout()                          │
│     ├─ Actions:                                             │
│     │  • Remove 'auth_token' from SharedPreferences        │
│     │  • Remove 'token_expired' from SharedPreferences     │
│     │  • Clear any cached user data                        │
│     └─ Redirect to login screen                            │
│                                                              │
│  6. SESSION EXPIRED                                          │
│     ├─ API returns 401 Unauthorized                        │
│     ├─ On detection:                                        │
│     │  • Call AuthService.logout()                         │
│     │  • Show message: "Session expired. Please login"    │
│     └─ Redirect to login screen                            │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## Security Flow

```
┌─────────────────────────────────────────────────────────────┐
│              Security Considerations                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Input                                                      │
│  ├─ Email validated with regex pattern                     │
│  ├─ Password required (non-empty)                          │
│  ├─ Trimmed before sending                                 │
│  └─ Never logged in production                             │
│                                                             │
│  Transport                                                  │
│  ├─ HTTP → Should be HTTPS in production                  │
│  ├─ Content-Type: application/json                         │
│  ├─ Standard HTTP headers                                  │
│  └─ No extra metadata in headers                           │
│                                                             │
│  Server Communication                                       │
│  ├─ 30-second timeout                                      │
│  ├─ TLS/SSL certificate verification                       │
│  ├─ Standard HTTP status codes                             │
│  └─ JSON response parsing                                  │
│                                                             │
│  Storage                                                    │
│  ├─ Token stored in SharedPreferences                      │
│  │  ⚠️  Note: Not encrypted in current version             │
│  │  ✅ For production: Use flutter_secure_storage         │
│  ├─ Key: 'auth_token'                                      │
│  ├─ Device-specific (not synced)                           │
│  └─ Cleared on logout                                      │
│                                                             │
│  Usage                                                      │
│  ├─ Token passed in Authorization header                   │
│  ├─ Format: 'Bearer $token'                               │
│  ├─ Included with every authenticated request              │
│  └─ Validated by server on each request                    │
│                                                             │
│  Error Handling                                             │
│  ├─ Never expose sensitive data in errors                  │
│  ├─ User-friendly error messages                           │
│  ├─ Log exceptions in development only                     │
│  └─ 401 triggers automatic logout                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

*Diagrams generated for SignIn API Integration - November 12, 2025*
