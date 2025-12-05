import 'dart:convert';
import 'package:http/http.dart' as http;

class RegistrationService {
  static const String baseUrl = 'http://examtime.runasp.net/api/Account';

  /// Register new user with all details
  /// Returns a map with 'success' and optional 'message'
  static Future<Map<String, dynamic>> register({
    required String userName,
    required String email,
    required String fullName,
    required String imageUrl,
    required String password,
    required String confirmPassword,
    required String role,
  }) async {
    try {
      // Validate passwords match
      if (password != confirmPassword) {
        return {'success': false, 'message': 'Passwords do not match'};
      }

      final payload = {
        'userName': userName,
        'email': email,
        'fullName': fullName,
        'imageUrl': imageUrl,
        'password': password,
        'confirmPassword': confirmPassword,
        'role': role,
      };

      final headers = {
        'Content-Type': 'application/json',
        'Accept': '*/*',
      };

      // Debug: print headers and payload being sent
      print('=== Registration Request ===');
      print('URL: $baseUrl/Register');
      print('Request Headers: $headers');
      print('Request Body: ${jsonEncode(payload)}');

      final response = await http
          .post(
            Uri.parse('$baseUrl/Register'),
            headers: headers,
            body: jsonEncode(payload),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Connection timeout'),
          );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        print('=== Registration Response ===');
        print('Status Code: ${response.statusCode}');
        print('Full Response Body: ${response.body}');
        print('Status: ${jsonResponse['status']}');
        print('Message Type: ${jsonResponse['message'].runtimeType}');
        print('Message Value: ${jsonResponse['message']}');

        // طبع كل المفاتيح في الرد
        print('Response Keys: ${jsonResponse.keys}');
        jsonResponse.forEach((key, value) {
          print('$key: $value (${value.runtimeType})');
        });

        if (jsonResponse['status'] == true) {
          final message = jsonResponse['message'];
          String messageText =
              'User registered successfully. Please check your email.';

          if (message is String) {
            messageText = message;
          } else if (message is Map) {
            messageText =
                message['massage'] ??
                message['message'] ??
                message.toString() ??
                messageText;
          } else {
            messageText = message.toString();
          }

          return {'success': true, 'message': messageText};
        } else {
          final errorMsg = jsonResponse['message'];
          String errorText = 'Registration failed';

          if (errorMsg is String) {
            errorText = errorMsg;
          } else if (errorMsg is Map) {
            // تحويل Map إلى String بشكل صحيح
            errorText =
                errorMsg['masage'] ??
                errorMsg['massage'] ??
                errorMsg['message'] ??
                errorMsg.toString();
          } else if (errorMsg != null) {
            errorText = errorMsg.toString();
          }

          return {'success': false, 'message': errorText};
        }
      } else if (response.statusCode == 400) {
        final jsonResponse = jsonDecode(response.body);
        final msg = jsonResponse['message'];
        String errorText = 'Invalid input data';

        if (msg is String) {
          errorText = msg;
        } else if (msg is Map) {
          errorText = msg['message'] ?? msg['masage'] ?? msg.toString();
        } else if (msg != null) {
          errorText = msg.toString();
        }

        return {'success': false, 'message': errorText};
      } else if (response.statusCode == 409) {
        return {
          'success': false,
          'message': 'Email or username already exists',
        };
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } on Exception catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  /// Validate registration data
  /// Returns a map with 'valid' (bool) and 'message' (String) keys
  static Map<String, dynamic> validateRegistration({
    required String userName,
    required String email,
    required String fullName,
    required String password,
    required String confirmPassword,
    required String role,
  }) {
    // Username validation
    if (userName.isEmpty) {
      return {'valid': false, 'message': 'Username is required'};
    } else if (userName.length < 3) {
      return {
        'valid': false,
        'message': 'Username must be at least 3 characters',
      };
    }

    // Email validation
    if (email.isEmpty) {
      return {'valid': false, 'message': 'Email is required'};
    } else if (!_isValidEmail(email)) {
      return {'valid': false, 'message': 'Invalid email format'};
    }

    // Full name validation
    if (fullName.isEmpty) {
      return {'valid': false, 'message': 'Full name is required'};
    }

    // Password validation
    if (password.isEmpty) {
      return {'valid': false, 'message': 'Password is required'};
    } else if (password.length < 6) {
      return {
        'valid': false,
        'message': 'Password must be at least 6 characters',
      };
    }

    // Confirm password validation
    if (confirmPassword.isEmpty) {
      return {'valid': false, 'message': 'Confirm password is required'};
    } else if (password != confirmPassword) {
      return {'valid': false, 'message': 'Passwords do not match'};
    }

    // Role validation
    if (role.isEmpty) {
      return {'valid': false, 'message': 'Please select a role'};
    }

    // All validations passed
    return {'valid': true, 'message': 'Validation successful'};
  }

  static bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
