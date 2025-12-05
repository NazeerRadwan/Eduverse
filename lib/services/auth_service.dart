import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://examtime.runasp.net/api/Account';

  /// Login with email and password
  /// Returns a map with 'success' and optional 'message' and 'token'
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/Login'),
            headers: {'Content-Type': 'application/json', 'Accept': '*/*'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Connection timeout'),
          );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status'] == true) {
          final token = jsonResponse['message']['token'];
          final expiredDate = jsonResponse['message']['expired'];

          // Save token to local storage
          await _saveToken(token, expiredDate);

          return {
            'success': true,
            'message': jsonResponse['message']['massage'],
            'token': token,
            'expired': expiredDate,
          };
        } else {
          return {
            'success': false,
            'message': jsonResponse['message'] ?? 'Login failed',
          };
        }
      } else if (response.statusCode == 401) {
        return {'success': false, 'message': 'Invalid email or password'};
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

  /// Save token to SharedPreferences
  static Future<void> _saveToken(String token, String expiredDate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('token_expired', expiredDate);
  }

  /// Get saved token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Clear token on logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('token_expired');
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Join a class with access code
  static Future<Map<String, dynamic>> joinClass({
    required String accessCode,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      print('Token: $token');
      print('Access Code: $accessCode');

      final response = await http
          .post(
            Uri.parse('http://examtime.runasp.net/api/student/class/join'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': '*/*',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'accessCode': accessCode}),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Connection timeout'),
          );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true) {
          return {
            'success': true,
            'message': jsonResponse['message'],
            'data': jsonResponse['data'],
          };
        } else {
          return {
            'success': false,
            'message': jsonResponse['message'] ?? 'Failed to join class',
          };
        }
      } else if (response.statusCode == 400) {
        try {
          final errorResponse = jsonDecode(response.body);
          final errorMessage =
              errorResponse['detail'] ??
              errorResponse['message'] ??
              'Invalid access code';
          return {'success': false, 'message': errorMessage};
        } catch (e) {
          return {'success': false, 'message': 'Invalid access code'};
        }
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Unauthorized. Please login again',
        };
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } on Exception catch (e) {
      print('Error: $e');
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }
}
