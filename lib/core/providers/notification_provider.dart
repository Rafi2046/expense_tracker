import 'package:expense_tracker/core/utils/database_helper.dart';
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

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['body'] as String,
      dateTime: DateTime.parse(map['timestamp'] as String),
      type: _parseType(map['type'] as String),
      isRead: (map['is_read'] as int) == 1,
    );
  }

  static NotificationType _parseType(String value) {
    switch (value) {
      case 'alert':
        return NotificationType.alert;
      case 'update':
        return NotificationType.update;
      case 'credit':
        return NotificationType.credit;
      case 'system':
        return NotificationType.system;
      default:
        return NotificationType.alert;
    }
  }

  static String typeToString(NotificationType type) {
    switch (type) {
      case NotificationType.alert:
        return 'alert';
      case NotificationType.update:
        return 'update';
      case NotificationType.credit:
        return 'credit';
      case NotificationType.system:
        return 'system';
    }
  }
}

class NotificationProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<NotificationItem> _notifications = [];
  String _activeProfileId;
  bool _isLoading = false;

  NotificationProvider({String initialProfileId = 'default_profile'})
      : _activeProfileId = initialProfileId;

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  bool get hasUnread => _notifications.any((n) => !n.isRead);
  bool get isLoading => _isLoading;

  void updateProfileId(String newProfileId) {
    debugPrint('NotificationProvider: updateProfileId: old=$_activeProfileId, new=$newProfileId');
    if (_activeProfileId == newProfileId) return;
    _activeProfileId = newProfileId;
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    final loadingProfileId = _activeProfileId;
    debugPrint('NotificationProvider: loadNotifications starting for $loadingProfileId');
    _isLoading = true;
    notifyListeners();

    final rows = await _db.getInAppNotifications(profileId: loadingProfileId);
    
    // Ignore results from outdated profile loads to prevent race conditions
    if (_activeProfileId != loadingProfileId) {
      debugPrint('NotificationProvider: loadNotifications ABORTED (outdated loading profile: $loadingProfileId, active is $_activeProfileId)');
      return;
    }

    _notifications = rows.map((row) => NotificationItem.fromMap(row)).toList();
    debugPrint('NotificationProvider: loadNotifications finished for $_activeProfileId. Loaded ${_notifications.length} rows.');
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addNotification({
    required String title,
    required String body,
    NotificationType type = NotificationType.alert,
  }) async {
    final id = 'notif_${DateTime.now().millisecondsSinceEpoch}';
    await _db.insertInAppNotification(
      id: id,
      title: title,
      body: body,
      type: NotificationItem.typeToString(type),
      profileId: _activeProfileId,
    );
    await loadNotifications();
  }

  Future<void> markAsRead(String id) async {
    await _db.markInAppNotificationRead(id);
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    await _db.markAllInAppNotificationsRead(profileId: _activeProfileId);
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  Future<void> deleteNotification(String id) async {
    await _db.deleteInAppNotification(id);
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  Future<void> insertNotification(int index, NotificationItem item) async {
    if (index >= 0 && index <= _notifications.length) {
      await _db.insertInAppNotification(
        id: item.id,
        title: item.title,
        body: item.description,
        type: NotificationItem.typeToString(item.type),
        profileId: _activeProfileId,
      );
      _notifications.insert(index, item);
      notifyListeners();
    }
  }
}
