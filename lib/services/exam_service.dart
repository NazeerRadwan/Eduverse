import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class ExamService {
  static const String baseUrl = 'http://examtime.runasp.net/api/student/exam';

  /// Get token using AuthService helper (keeps key consistent)
  static Future<String?> _getToken() async {
    final token = await AuthService.getToken();
    // debug print to help diagnose missing token
    print(
      'ExamService: retrieved token = ${token == null ? 'null' : token.substring(0, 10) + '...'}',
    );
    return token;
  }

  /// Get exam status for a specific class
  /// Returns a map with 'success', 'message', and 'data' (list of exams with status)
  static Future<Map<String, dynamic>> getExamStatus({
    required int classId,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Unauthorized. Please login again',
        };
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/class/$classId/exams/status'),
            headers: {'Accept': '*/*', 'Authorization': 'Bearer $token'},
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
            'summary': jsonResponse['summary'],
          };
        } else {
          return {
            'success': false,
            'message': jsonResponse['message'] ?? 'Failed to fetch exam status',
          };
        }
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Unauthorized. Please login again',
        };
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'Class not found'};
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

  /// Fetch exams for a specific class
  /// Returns a map with 'success', 'message', and 'data' (list of exams)
  static Future<Map<String, dynamic>> getExamsByClass({
    required int classId,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Unauthorized. Please login again',
        };
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/class/$classId'),
            headers: {'Accept': '*/*', 'Authorization': 'Bearer $token'},
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
            'message': jsonResponse['message'] ?? 'Failed to fetch exams',
          };
        }
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Unauthorized. Please login again',
        };
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'Class not found'};
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

  /// Start an exam
  /// Returns a map with 'success' and 'message'
  static Future<Map<String, dynamic>> startExam({
    required int examId,
    required int classId,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Unauthorized. Please login again',
        };
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/start'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': '*/*',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'examId': examId, 'classId': classId}),
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
            'message': jsonResponse['message'] ?? 'Failed to start exam',
          };
        }
      } else if (response.statusCode == 400) {
        try {
          final errorResponse = jsonDecode(response.body);
          final errorMessage = errorResponse['message'] ?? 'Bad request';
          return {'success': false, 'message': errorMessage};
        } catch (e) {
          return {'success': false, 'message': 'Bad request'};
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

  /// Get exam questions
  /// Returns a map with 'success', 'message', and 'data' (exam with questions)
  static Future<Map<String, dynamic>> getExamQuestions({
    required int examId,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Unauthorized. Please login again',
        };
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/questions/$examId'),
            headers: {'Accept': '*/*', 'Authorization': 'Bearer $token'},
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
            'message': jsonResponse['message'] ?? 'Failed to fetch questions',
          };
        }
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Unauthorized. Please login again',
        };
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'Exam not found'};
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

  /// Save answer for a question
  /// Returns a map with 'success' and 'message'
  static Future<Map<String, dynamic>> saveAnswer({
    required int questionId,
    required List<int> selectedOptionIds,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Unauthorized. Please login again',
        };
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/save-answer'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': '*/*',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'questionId': questionId,
              'selectedOptionIds': selectedOptionIds,
            }),
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
            'message': jsonResponse['message'] ?? 'Failed to save answer',
          };
        }
      } else if (response.statusCode == 400) {
        try {
          final errorResponse = jsonDecode(response.body);
          final errorMessage = errorResponse['message'] ?? 'Bad request';
          return {'success': false, 'message': errorMessage};
        } catch (e) {
          return {'success': false, 'message': 'Bad request'};
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

  /// Submit exam
  /// Returns a map with 'success' and 'message'
  static Future<Map<String, dynamic>> submitExam({required int examId}) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Unauthorized. Please login again',
        };
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/submit/$examId'),
            headers: {'Accept': '*/*', 'Authorization': 'Bearer $token'},
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
          return {'success': true, 'message': jsonResponse['message']};
        } else {
          return {
            'success': false,
            'message': jsonResponse['message'] ?? 'Failed to submit exam',
          };
        }
      } else if (response.statusCode == 400) {
        try {
          final errorResponse = jsonDecode(response.body);
          final errorMessage = errorResponse['message'] ?? 'Bad request';
          return {'success': false, 'message': errorMessage};
        } catch (e) {
          return {'success': false, 'message': 'Bad request'};
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
