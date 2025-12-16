// Example: How to use the saved authentication token in other API calls
// This shows best practices for making authenticated requests

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';

/// Example API Service for making authenticated requests
class CoursesApiService {
  static const String baseUrl = 'http://examtime.runasp.net/api';

  /// Get user's courses with authentication
  static Future<List<Course>> getUserCourses() async {
    try {
      // Get the stored token
      final token = await AuthService.getToken();

      if (token == null) {
        throw Exception('No authentication token found. Please login first.');
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/Courses'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token', // Include token in header
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        // Parse and return courses
        List<Course> courses =
            (jsonResponse['data'] as List)
                .map((c) => Course.fromJson(c))
                .toList();
        return courses;
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        await AuthService.logout();
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception('Failed to load courses: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading courses: $e');
    }
  }

  /// Get course details with authentication
  static Future<CourseDetail> getCourseDetail(int courseId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/Courses/$courseId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return CourseDetail.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        throw Exception('Session expired');
      } else {
        throw Exception('Failed to load course');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Example: POST request with authentication (e.g., enrolling in a course)
  static Future<void> enrollCourse(int courseId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http
          .post(
            Uri.parse('$baseUrl/Courses/$courseId/Enroll'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'courseId': courseId}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        // Success
        print('Enrolled successfully');
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        throw Exception('Session expired');
      } else {
        throw Exception('Enrollment failed');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}

// Model classes
class Course {
  final int id;
  final String title;
  final String description;
  final String instructor;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      instructor: json['instructor'],
    );
  }
}

class CourseDetail {
  final int id;
  final String title;
  final String description;
  final String instructor;
  final int students;
  final List<String> topics;

  CourseDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.students,
    required this.topics,
  });

  factory CourseDetail.fromJson(Map<String, dynamic> json) {
    return CourseDetail(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      instructor: json['instructor'],
      students: json['students'] ?? 0,
      topics: List<String>.from(json['topics'] ?? []),
    );
  }
}

// ============================================================
// USAGE EXAMPLES IN WIDGETS
// ============================================================

/*
// Example 1: Using in a StatefulWidget
class CoursesListScreen extends StatefulWidget {
  const CoursesListScreen({super.key});

  @override
  State<CoursesListScreen> createState() => _CoursesListScreenState();
}

class _CoursesListScreenState extends State<CoursesListScreen> {
  late Future<List<Course>> _coursesFuture;

  @override
  void initState() {
    super.initState();
    _coursesFuture = CoursesApiService.getUserCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Courses')),
      body: FutureBuilder<List<Course>>(
        future: _coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final courses = snapshot.data ?? [];
          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(courses[index].title),
                subtitle: Text(courses[index].instructor),
              );
            },
          );
        },
      ),
    );
  }
}

// Example 2: Checking authentication before making request
Future<void> checkAndFetch() async {
  final isLoggedIn = await AuthService.isLoggedIn();
  if (!isLoggedIn) {
    // Redirect to login
    Navigator.of(context).pushReplacementNamed('/signin');
    return;
  }
  
  // Make authenticated request
  try {
    final courses = await CoursesApiService.getUserCourses();
    print('Loaded ${courses.length} courses');
  } catch (e) {
    print('Error: $e');
  }
}

// Example 3: Logout and clean up
Future<void> logout() async {
  await AuthService.logout();
  // Navigate back to login
  Navigator.of(context).pushReplacementNamed('/signin');
}
*/

// ============================================================
// BEST PRACTICES FOR AUTHENTICATION
// ============================================================

/*

1. ALWAYS check token existence before making requests:
   final token = await AuthService.getToken();
   if (token == null) {
     // Handle not logged in
   }

2. HANDLE 401 responses by logging out:
   if (response.statusCode == 401) {
     await AuthService.logout();
     // Redirect to login
   }

3. INCLUDE token in Authorization header:
   headers: {
     'Authorization': 'Bearer $token',
   }

4. WRAP requests in try-catch:
   try {
     // API call
   } catch (e) {
     // Handle error
   }

5. ADD timeouts to prevent hanging requests:
   .timeout(const Duration(seconds: 30))

6. TEST with both valid and expired tokens

7. IMPLEMENT automatic logout on 401

8. CONSIDER token refresh for long-lived sessions

9. LOG API errors for debugging (in development)

10. NEVER hardcode tokens in your code
    NEVER log sensitive data in production
    NEVER store tokens in plain text

*/
