import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ClassesService {
  static const String baseUrl = 'http://examtime.runasp.net/api/student/class';

  /// Get user's enrolled classes (My Classes)
  /// Returns a list of classes
  static Future<Map<String, dynamic>> getMyClasses() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
          'data': [],
        };
      }

      print('Fetching my classes with token: $token');

      final response = await http
          .get(
            Uri.parse('$baseUrl/my-classes'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': '*/*',
              'Authorization': 'Bearer $token',
            },
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
          final List<dynamic> classes = jsonResponse['data'] ?? [];

          // Convert to list of maps
          final List<Map<String, dynamic>> classList =
              classes.cast<Map<String, dynamic>>();

          return {
            'success': true,
            'message': jsonResponse['message'],
            'data': classList,
          };
        } else {
          return {
            'success': false,
            'message': jsonResponse['message'] ?? 'Failed to fetch classes',
            'data': [],
          };
        }
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Unauthorized. Please login again',
          'data': [],
        };
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
          'data': [],
        };
      }
    } on Exception catch (e) {
      print('Error fetching classes: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
        'data': [],
      };
    }
  }
}
