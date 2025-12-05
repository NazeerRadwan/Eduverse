import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});
  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;
  String? _errorMessage;

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

  Future<void> _handleLogin() async {
    // Validate inputs
    if (_emailCtl.text.isEmpty || _passCtl.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both email and password';
      });
      return;
    }

    // Basic email validation
    if (!_isValidEmail(_emailCtl.text)) {
      setState(() {
        _errorMessage = 'Please enter a valid email';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await AuthService.login(
        email: _emailCtl.text.trim(),
        password: _passCtl.text,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        // Navigate to joinEduverse screen
        Navigator.of(context).pushReplacementNamed('/join_eduverse');
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Login failed';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An error occurred: $e';
          _isLoading = false;
        });
      }
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
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

              // Error message display
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    border: Border.all(color: Colors.red.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                  ),
                ),

              // Log in button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002E8A),
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text(
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
