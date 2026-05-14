import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl =
      'https://home-serviceapp-backend.onrender.com/api';

  // Request OTP
  static Future<Map<String, dynamic>> requestOTP(
    String email,
    String phone,
    String userType,
  ) async {
    final url = Uri.parse('$baseUrl/auth/request-otp');
    print(email);
    print(userType);
    print("url : $url");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'phone': phone,
        'userType': userType.toUpperCase(),
      }),
    );
    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // Parse JSON and extract clean message
      try {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to send OTP');
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception('Failed to send OTP');
      }
    }
  }

  // Verify OTP
  static Future<Map<String, dynamic>> verifyOTP(
    String email,
    String otp,
    String fcmToken,
  ) async {
    final url = Uri.parse('$baseUrl/auth/verify-otp');
    // try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp, 'fcmToken': fcmToken}),
    );
    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Failed to verify OTP');
    }
    // } catch (e) {
    //   throw Exception('Error verifying OTP: $e');
    // }
  }
}
