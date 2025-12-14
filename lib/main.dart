import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:ui/Screens/join_eduverse.dart';
import 'package:ui/Screens/signUp_screen.dart';
import 'package:ui/Screens/signIn_screen.dart';
import 'package:ui/Screens/view_courses_screen.dart';

void main() {
  // runApp(DevicePreview(builder: (context) => const MyApp()));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EduVerse',
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade800),
        useMaterial3: true,
      ),
      // home: JoinEduverse(),
      home: SignUpPage(),
      routes: {
        '/signin': (context) => const SigninScreen(),
        '/join_eduverse': (context) => JoinEduverse(),
        '/view_courses': (context) => const EduversesPage(),
        '/signup': (context) => const SignUpPage(),
      },
    );
  }
}





/*
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';

void main() {
  runApp(DevicePreview(builder: (context) => const MyApp()));
  // runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Courses',
      theme: ThemeData(useMaterial3: true),
      home: ProfileUploadedPage(),
    );
  }
}

class ProfileUploadedPage extends StatelessWidget {
  const ProfileUploadedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 6),
            // back button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(
                    side: BorderSide(
                      color: Colors.grey,
                      width: 1,
                    ), // <- grey border
                  ),
                  elevation: 0,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                    ),
                    onPressed: () => Navigator.maybePop(context),
                    splashRadius: 22,
                    padding: const EdgeInsets.all(6),
                  ),
                ),
              ),
            ),

            // large avatar
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: width * 0.78,
                    height: width * 0.78,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade200,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/me.jpg',
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Icon(
                              Icons.person,
                              size: width * 0.28,
                              color: Colors.grey.shade500,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 10,
                    ), // 👈 أضف السطر ده
                    child: Text(
                      'Your Profile Photo was\nUploaded Successfully',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF002E8A),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Start button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ), // reduced vertical from 28 -> 12
              child: SizedBox(
                width: 310,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.maybePop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002E8A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Start',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/

// View Courses Screen
/*
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';

void main() {
  runApp(DevicePreview(builder: (context) => const MyApp()));
  // runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Courses',
      theme: ThemeData(useMaterial3: true),
      home: EduversesPage(),
    );
  }
}

class EduversesPage extends StatefulWidget {
  const EduversesPage({super.key});

  @override
  State<EduversesPage> createState() => _EduversesPageState();
}

class _EduversesPageState extends State<EduversesPage> {
  int _selectedIndex = 1;

  final List<Map<String, String>> _cards = [
    {
      'image': 'assets/Mohamed_Farouk.jpg',
      'left': '2rd Secondary',
      'title': 'Mohamed Farouk',
      'subtitle': 'English',
    },
    {
      'image': 'assets/Mustafa_Abdallah.jpg',
      'left': '3rd Secondary',
      'title': 'Mustafa Abdallah',
      'subtitle': 'Physics',
    },
    {
      'image': 'assets/Khaled_Helmy.jpg',
      'left': '1st Secondary',
      'title': 'Khaled Helmy',
      'subtitle': 'Chemistry',
    },
    // add more items if needed
  ];

  Widget _buildCard(Map<String, String> item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // <- added to align all text to left
        children: [
          // image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                item['image']!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder:
                    (_, __, ___) => Container(
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
                    ),
              ),
            ),
          ),
          // divider line
          Container(height: 1, color: Colors.grey.shade200),
          // content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start, // ensure inner column is left-aligned
              children: [
                Text(
                  item['left'] ?? '',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 12, color: Colors.black),
                ),
                const SizedBox(height: 6),
                Text(
                  item['title'] ?? '',
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item['subtitle'] ?? '',
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /*Widget _bottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.feed_outlined, 'Feed', 0),
          _navItem(Icons.book_outlined, 'Eduverses', 1),
          _navItem(Icons.person_outline, 'Profile', 2),
          _navItem(Icons.settings_outlined, 'Settings', 3),
        ],
      ),
    );
  }*/

  Widget _navItem(IconData icon, String label, int index) {
    final selected = _selectedIndex == index;
    final color = selected ? Colors.purple.shade700 : Colors.grey.shade600;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            // top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  Material(
                    color: Colors.white,
                    shape: CircleBorder(
                      side: BorderSide(color: Colors.grey, width: 1),
                    ), // <- red border on back button
                    elevation: 0,
                    child: IconButton(
                      padding: const EdgeInsets.all(6),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                      ),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Row(
                      children: [
                        const SizedBox(width: 50),
                        Text(
                          'Your Eduverses',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF002E8A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 8),
                itemCount: _cards.length,
                itemBuilder: (context, i) => _buildCard(_cards[i]),
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: _bottomNav(),
    );
  }
}
// ...existing code...
*/










// Login Screen
/*
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';

void main() {
  runApp(DevicePreview(builder: (context) => const MyApp()));
  // runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login UI',
      theme: ThemeData(useMaterial3: true),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtl.dispose();
    _passCtl.dispose();
    super.dispose();
  }

  InputDecoration _dec({required String hint, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixIcon: suffix,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E6EA)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF002E8A), width: 1.6),
      ),
    );
  }

  Widget _socialButton(IconData icon, Color bg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _googleSignInButton(VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 52, // نفس ارتفاع زر Log in
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(
            // color: Color(0xFFE2E6EA),
            color: Colors.grey.shade700,
            width: 1.6,
          ), ///////////////////////////////////////////////////////////////////////////
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // أيقونة Google (استبدل بـ asset محلي لو حابب)
            Image.asset(
              'assets/Google.png',
              width: 24,
              height: 24,
              fit: BoxFit.contain,
              errorBuilder:
                  (_, __, ___) => const SizedBox(width: 24, height: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Sign in with Google',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hp = 20.0;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: hp, vertical: 18),
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Illustration (responsive height)
              SizedBox(
                width: double.infinity,
                height:
                    MediaQuery.of(context).size.height *
                    0.38, // تقريباً 38% من ارتفاع الشاشة
                child: Center(
                  child: Image.asset(
                    'assets/illustration.jpg',
                    fit: BoxFit.contain,
                    errorBuilder:
                        (_, __, ___) => const Icon(
                          Icons.person_outline,
                          size: 96,
                          color: Colors.blueGrey,
                        ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
              const Text(
                'Log in',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),

              const SizedBox(height: 12),

              // Email
              TextField(
                controller: _emailCtl,
                keyboardType: TextInputType.emailAddress,
                decoration: _dec(hint: 'Email'),
              ),
              const SizedBox(height: 12),
              // Password
              TextField(
                controller: _passCtl,
                obscureText: _obscure,
                decoration: _dec(
                  hint: 'Password',
                  suffix: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.black54),
                ),
              ),

              const SizedBox(height: 8),
              // Log in button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002E8A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Log in',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Google sign-in placed under the Log in button (full width, same height)
              _googleSignInButton(() {
                // handle google sign-in
              }),

              const SizedBox(height: 12),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Sign up',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
*/





// Register Screen
/*
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';

void main() {
  runApp(DevicePreview(builder: (context) => const MyApp()));
  // runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sign Up UI',
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade800),
        useMaterial3: true,
      ),
      home: const SignUpPage(),
    );
  }
}


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  bool _obscure = true;
  String _role = ''; // 'instructor' or 'student'

  @override
  void dispose() {
    _nameCtl.dispose();
    _emailCtl.dispose();
    _passCtl.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration({required String hint, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      suffixIcon: suffix,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E6EA)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue.shade800, width: 1.6),
      ),
    );
  }

  Widget _roleButton(String label, String value) {
    final selected = _role == value;
    return GestureDetector(
      onTap: () => setState(() => _role = value),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 18),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.blue.shade800 : const Color(0xFFD9DDE0),
            width: selected ? 2 : 1,
          ),
          boxShadow:
              selected
                  ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.blue.shade800 : Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = 24.0;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 18,
          ),
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE6E9EC)),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                    ),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // Illustration
              SizedBox(
                height: 220,
                child: Center(
                  child: Image.asset(
                    'assets/illustration.jpg',
                    fit: BoxFit.contain,
                    errorBuilder:
                        (_, __, ___) => const Icon(
                          Icons.person_add_alt_1_outlined,
                          size: 96,
                          color: Colors.blueGrey,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Title
              const Text(
                'Sign up',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                'Create your account',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 18),
              // Fields
              TextField(
                controller: _nameCtl,
                decoration: _fieldDecoration(hint: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailCtl,
                keyboardType: TextInputType.emailAddress,
                decoration: _fieldDecoration(hint: 'E-mail'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passCtl,
                obscureText: _obscure,
                decoration: _fieldDecoration(
                  hint: 'Password',
                  suffix: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passCtl,
                obscureText: _obscure,
                decoration: _fieldDecoration(
                  hint: 'Confirm Password',
                  suffix: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              // const SizedBox(height: 18),
              // Join as
              /*Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Join as',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _roleButton('Instructor', 'instructor'),
              _roleButton('Student', 'student'),*/
              const SizedBox(height: 18),
              // Sign up button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Signing up as ${_role.isEmpty ? 'no role' : _role}',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF002E8A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Sign up',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  // navigate to login
                },
                child: const Text(
                  'Log in',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
*/