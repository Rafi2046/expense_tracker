import 'package:flutter/material.dart';

enum NotificationType {
  alert,
  update,
  credit,
  system,
}

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final NotificationType type;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.type,
    this.isRead = false,
  });
}

class NotificationProvider extends ChangeNotifier {
  final List<NotificationItem> _notifications = [];

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);

  bool get hasUnread => _notifications.any((n) => !n.isRead);

  void markAllAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void insertNotification(int index, NotificationItem item) {
    if (index >= 0 && index <= _notifications.length) {
      _notifications.insert(index, item);
      notifyListeners();
    }
  }

  void addNotification(NotificationItem item) {
    _notifications.add(item);
    notifyListeners();
  }
}
