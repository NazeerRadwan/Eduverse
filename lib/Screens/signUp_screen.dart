import 'package:flutter/material.dart';
import '../services/registration_service.dart';
import 'upload_photo.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _userNameCtl = TextEditingController();
  final _fullNameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  final _confirmPassCtl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  String _role = 'Student';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _userNameCtl.dispose();
    _fullNameCtl.dispose();
    _emailCtl.dispose();
    _passCtl.dispose();
    _confirmPassCtl.dispose();
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.6),
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
            color: selected ? Color(0xFF002E8A) : Colors.black87,
          ),
        ),
      ),
    );
  }

  void _handleSignUp() async {
    if (_userNameCtl.text.isEmpty ||
        _fullNameCtl.text.isEmpty ||
        _emailCtl.text.isEmpty ||
        _passCtl.text.isEmpty ||
        _confirmPassCtl.text.isEmpty) {
      setState(() => _errorMessage = 'Please fill all fields');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please fill all fields'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
      return;
    }

    final validation = RegistrationService.validateRegistration(
      userName: _userNameCtl.text,
      email: _emailCtl.text,
      fullName: _fullNameCtl.text,
      password: _passCtl.text,
      confirmPassword: _confirmPassCtl.text,
      role: _role,
    );

    if (validation['valid'] != true) {
      setState(
        () => _errorMessage = validation['message'] ?? 'Validation failed',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validation['message'] ?? 'Validation failed'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
      return;
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => UploadPhotoScreen(
                userName: _userNameCtl.text,
                fullName: _fullNameCtl.text,
                email: _emailCtl.text,
                password: _passCtl.text,
                confirmPassword: _confirmPassCtl.text,
                role: _role,
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Column(
            children: [
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
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                  ),
                ),
              TextField(
                controller: _userNameCtl,
                decoration: _fieldDecoration(hint: 'Username'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _fullNameCtl,
                decoration: _fieldDecoration(hint: 'Full Name'),
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
                obscureText: _obscurePass,
                decoration: _fieldDecoration(
                  hint: 'Password',
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePass
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed:
                        () => setState(() => _obscurePass = !_obscurePass),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _confirmPassCtl,
                obscureText: _obscureConfirm,
                decoration: _fieldDecoration(
                  hint: 'Confirm Password',
                  suffix: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed:
                        () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Join as',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF002E8A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _roleButton('Instructor', 'Instructor'),
              _roleButton('Student', 'Student'),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002E8A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            'Continue',
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
                onPressed: () => Navigator.pushNamed(context, '/signin'),
                child: Row(
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.black54),
                    ),
                    Text(
                      'Log in',
                      style: TextStyle(
                        color: Color(0xFF002E8A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
