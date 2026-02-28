import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl =
      'https://home-serviceapp-backend.onrender.com/api';

  // Request OTP
  static Future<Map<String, dynamic>> requestOTP(
    String phone,
    String userType,
  ) async {
    final url = Uri.parse('$baseUrl/auth/request-otp');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'userType': userType.toUpperCase()}),
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
    String phone,
    String otp,
  ) async {
    final url = Uri.parse('$baseUrl/auth/verify-otp');
    // try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'otp': otp}),
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
