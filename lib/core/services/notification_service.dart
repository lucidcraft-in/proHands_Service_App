import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';
import 'auth_service.dart';
import 'storage_service.dart';

class NotificationService {
  final String baseUrl = AuthService.baseUrl;

  // Get headers with token
  Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get Notifications
  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final url = Uri.parse('$baseUrl/notifications?page=$page&limit=$limit');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> notificationsJson = data['notifications'] ?? [];
          final List<NotificationModel> notifications =
              notificationsJson
                  .map((json) => NotificationModel.fromJson(json))
                  .toList();
          return {
            'notifications': notifications,
            'unreadCount': data['unreadCount'] ?? 0,
            'total': data['total'] ?? 0,
          };
        } else {
          throw Exception(data['message'] ?? 'Failed to load notifications');
        }
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching notifications: $e');
    }
  }

  // Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    final url = Uri.parse('$baseUrl/notifications/$notificationId/read');
    try {
      final headers = await _getHeaders();
      final response = await http.patch(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        throw Exception(
          'Failed to mark notification as read: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error marking notification as read: $e');
    }
  }

  // Mark all as read
  Future<bool> markAllAsRead() async {
    final url = Uri.parse('$baseUrl/notifications/read-all');
    try {
      final headers = await _getHeaders();
      final response = await http.patch(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        throw Exception('Failed to mark all as read: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error marking all as read: $e');
    }
  }
}
