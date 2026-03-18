import 'package:flutter/material.dart';
import '../../../core/models/notification_model.dart';
import '../../../core/services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _notificationService.getNotifications();
      _notifications = data['notifications'];
      _unreadCount = data['unreadCount'];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final success = await _notificationService.markAsRead(notificationId);
      if (success) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1 && !_notifications[index].isRead) {
          _notifications[index] = NotificationModel(
            id: _notifications[index].id,
            recipient: _notifications[index].recipient,
            type: _notifications[index].type,
            title: _notifications[index].title,
            message: _notifications[index].message,
            data: _notifications[index].data,
            isRead: true,
            isGlobal: _notifications[index].isGlobal,
            targetGroup: _notifications[index].targetGroup,
            createdAt: _notifications[index].createdAt,
            updatedAt: DateTime.now(),
          );
          _unreadCount = (_unreadCount > 0) ? _unreadCount - 1 : 0;
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final success = await _notificationService.markAllAsRead();
      if (success) {
        _notifications =
            _notifications.map((n) {
              return NotificationModel(
                id: n.id,
                recipient: n.recipient,
                type: n.type,
                title: n.title,
                message: n.message,
                data: n.data,
                isRead: true,
                isGlobal: n.isGlobal,
                targetGroup: n.targetGroup,
                createdAt: n.createdAt,
                updatedAt: DateTime.now(),
              );
            }).toList();
        _unreadCount = 0;
        notifyListeners();
      }
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }
}
