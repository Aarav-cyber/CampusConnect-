import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationsProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  NotificationsProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  List<NotificationEntity> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<NotificationEntity> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiClient.get(ApiConstants.notifications);
      if (res is List) {
        _notifications = res
            .map((e) => NotificationEntity.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1 && !_notifications[idx].isRead) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      notifyListeners();

      try {
        await _apiClient.put(ApiConstants.markNotificationRead(id));
      } catch (_) {}
    }
  }
}
