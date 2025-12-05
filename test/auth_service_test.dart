import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthService Tests', () {
    test('Email validation - valid emails', () {
      final validEmails = [
        'user@example.com',
        'test.email@domain.co.uk',
        'user+tag@example.com',
        'nr1413@fayoum.edu.eg',
      ];

      final emailRegex =
          RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

      for (final email in validEmails) {
        expect(emailRegex.hasMatch(email), true,
            reason: 'Email $email should be valid');
      }
    });

    test('Email validation - invalid emails', () {
      final invalidEmails = [
        'notanemail',
        '@example.com',
        'user@',
        'user @example.com',
        'user@.com',
      ];

      final emailRegex =
          RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

      for (final email in invalidEmails) {
        expect(emailRegex.hasMatch(email), false,
            reason: 'Email $email should be invalid');
      }
    });

    test('API Response parsing', () {
      final mockResponse = {
        'status': true,
        'message': {
          'massage': 'Login successful.',
          'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
          'expired': '2025-11-18T12:02:55Z'
        }
      };

      expect(mockResponse['status'], true);
      final message = mockResponse['message'] as Map<String, dynamic>?;
      expect(message?['massage'], contains('successful'));
      expect(message?['token'], isNotEmpty);
      expect(message?['expired'], isNotEmpty);
    });

    test('Error Response parsing', () {
      final errorResponse = {
        'status': false,
        'message': 'Invalid credentials'
      };

      expect(errorResponse['status'], false);
      expect(errorResponse['message'], isNotEmpty);
    });
  });
}

