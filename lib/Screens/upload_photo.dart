import 'dart:io';
import 'package:flutter/material.dart';
import '../services/google_drive_service.dart';
import '../services/registration_service.dart';

class UploadPhotoScreen extends StatefulWidget {
  final String userName;
  final String fullName;
  final String email;
  final String password;
  final String confirmPassword;
  final String role;

  const UploadPhotoScreen({
    super.key,
    required this.userName,
    required this.fullName,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.role,
  });

  @override
  State<UploadPhotoScreen> createState() => _UploadPhotoScreenState();
}

class _UploadPhotoScreenState extends State<UploadPhotoScreen> {
  File? _selectedImage;
  bool _isUploading = false;
  bool _isRegistering = false;
  String? _errorMessage;

  void _handleSelectPhoto() async {
    setState(() => _errorMessage = null);

    try {
      final image = await GoogleDriveService.pickImageFromDevice();
      if (image != null) {
        setState(() => _selectedImage = image);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to select image: ${e.toString()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? 'Error'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    }
  }

  void _handleStartRegistration() async {
    if (_selectedImage == null) {
      setState(() => _errorMessage = 'Please select a photo first');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a photo'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      // Upload image to Google Drive
      final driveLink = await GoogleDriveService.uploadImageToGoogleDrive(
        _selectedImage!,
      );

      if (driveLink == null) {
        throw Exception('Failed to upload image to Google Drive');
      }

      setState(() => _isUploading = false);

      // Now register with the Drive link
      if (mounted) {
        setState(() => _isRegistering = true);
      }

      print('=== Registering User ===');
      print('Username: ${widget.userName}');
      print('Email: ${widget.email}');
      print('Full Name: ${widget.fullName}');
      print('Role: ${widget.role}');
      print('Drive Link: $driveLink');
      print('Password Match: ${widget.password == widget.confirmPassword}');

      final result = await RegistrationService.register(
        userName: widget.userName,
        email: widget.email,
        fullName: widget.fullName,
        imageUrl: driveLink,
        password: widget.password,
        confirmPassword: widget.confirmPassword,
        role: widget.role,
      );

      print('=== Registration Result ===');
      print('Success: ${result['success']}');
      print('Message: ${result['message']}');
      print('Message Type: ${result['message'].runtimeType}');

      if (mounted) {
        setState(() => _isRegistering = false);
      }

      if (result['success']) {
        // Show confirmation dialog
        if (mounted) {
          _showConfirmationDialog();
        }
      } else {
        final msg = result['message'];
        String errorMsg = 'Registration failed';

        if (msg is String) {
          errorMsg = msg;
        } else if (msg is Map) {
          errorMsg = msg['message'] ?? msg['massage'] ?? msg.toString();
        } else if (msg != null) {
          errorMsg = msg.toString();
        }

        setState(() => _errorMessage = errorMsg);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage ?? 'Error'),
              backgroundColor: Colors.red.shade400,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _isRegistering = false;
          _errorMessage = 'Error: ${e.toString()}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? 'Error'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade400, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Registration Successful!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: const Text(
            'Please check your email to confirm your account.\n\nWe\'ve sent a confirmation link to your email address.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                // Navigate to login screen
                Navigator.of(context).pushReplacementNamed('/signin');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF002E8A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Go to Login',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
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
              const Text(
                'Upload Profile Photo',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose a photo from your device',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 36),
              // Photo Preview
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E6EA), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child:
                    _selectedImage != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        )
                        : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_outlined,
                              size: 48,
                              color: Colors.blue.shade300,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No photo selected',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
              ),
              const SizedBox(height: 36),
              // Error message
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
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
              // Select Photo Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed:
                      (_isUploading || _isRegistering)
                          ? null
                          : _handleSelectPhoto,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Select Photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF002E8A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(
                        color: Color(0xFF002E8A),
                        width: 1.5,
                      ),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Start Registration Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed:
                      (_isUploading || _isRegistering || _selectedImage == null)
                          ? null
                          : _handleStartRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002E8A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child:
                      (_isUploading || _isRegistering)
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
                            'Start',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
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
