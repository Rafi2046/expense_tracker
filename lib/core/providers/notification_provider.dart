import 'package:expense_tracker/core/utils/database_helper.dart';
import 'package:expense_tracker/core/services/weekly_summary_service.dart';
import 'package:expense_tracker/core/services/daily_summary_service.dart';
import 'package:expense_tracker/core/services/monthly_summary_service.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

enum NotificationType {
  alert,
  update,
  credit,
  system,
}

class NotificationItem {
  final String id;
  /// Translation key for new rows, or legacy plain-text title.
  final String title;
  /// Translation key for new rows, or legacy plain-text body.
  final String description;
  final DateTime dateTime;
  final NotificationType type;
  /// Named args for localization (e.g. preformatted `{amount}`, `{budget}`).
  final Map<String, String> args;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.type,
    this.args = const {},
    this.isRead = false,
  });

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['body'] as String,
      dateTime: DateTime.parse(map['timestamp'] as String),
      type: _parseType(map['type'] as String),
      args: _parseArgs(map['args_json']),
      isRead: (map['is_read'] as int) == 1,
    );
  }

  static Map<String, String> _parseArgs(dynamic raw) {
    if (raw == null) return const {};
    final text = raw is String ? raw : raw.toString();
    if (text.isEmpty) return const {};
    try {
      final decoded = jsonDecode(text);
      if (decoded is! Map) return const {};
      return decoded.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    } catch (_) {
      return const {};
    }
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
  int _unreadCount = 0;

  /// Wired from main() so external writers (budget alerts, summaries)
  /// can refresh the badge without a BuildContext.
  static VoidCallback? onDataChanged;

  /// Call after inserting in-app notifications outside this provider.
  static void notifyDataChanged() => onDataChanged?.call();

  NotificationProvider({String initialProfileId = 'default_profile'})
      : _activeProfileId = initialProfileId;

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _unreadCount;
  bool get hasUnread => _unreadCount > 0;
  bool get isLoading => _isLoading;

  Future<void> _refreshUnreadCount({String? profileId}) async {
    final targetProfileId = profileId ?? _activeProfileId;
    final count = await _db.getUnreadNotificationCount(
      profileId: targetProfileId,
    );
    if (_activeProfileId != targetProfileId) return;
    _unreadCount = count;
  }

  void updateProfileId(String newProfileId) {
    debugPrint('NotificationProvider: updateProfileId: old=$_activeProfileId, new=$newProfileId');
    if (_activeProfileId == newProfileId) return;
    _activeProfileId = newProfileId;
    loadNotifications();
    _generateSummariesForProfile();
  }

  Future<void> _generateSummariesForProfile() async {
    final profileId = _activeProfileId;
    await WeeklySummaryService.checkAndGenerate(profileId: profileId);
    await DailySummaryService.updateDailyNotification(profileId: profileId);
    await MonthlySummaryService.checkAndGenerate(profileId: profileId);
    if (_activeProfileId == profileId) {
      final rows = await _db.getInAppNotifications(profileId: profileId);
      _notifications = rows.map((row) => NotificationItem.fromMap(row)).toList();
      await _refreshUnreadCount(profileId: profileId);
      notifyListeners();
    }
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
    await _refreshUnreadCount(profileId: loadingProfileId);
    if (_activeProfileId != loadingProfileId) {
      debugPrint('NotificationProvider: loadNotifications ABORTED after unread count (outdated)');
      return;
    }
    debugPrint('NotificationProvider: loadNotifications finished for $_activeProfileId. Loaded ${_notifications.length} rows. Unread=$_unreadCount');
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addNotification({
    required String title,
    required String body,
    NotificationType type = NotificationType.alert,
    Map<String, String>? args,
  }) async {
    final id = 'notif_${DateTime.now().millisecondsSinceEpoch}';
    await _db.insertInAppNotification(
      id: id,
      title: title,
      body: body,
      type: NotificationItem.typeToString(type),
      profileId: _activeProfileId,
      args: args,
    );
    await loadNotifications();
  }

  Future<void> markAsRead(String id) async {
    await _db.markInAppNotificationRead(id);
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
    }
    await _refreshUnreadCount();
    notifyListeners();
  }

  Future<void> markAllAsRead() async {
    await _db.markAllInAppNotificationsRead(profileId: _activeProfileId);
    for (var n in _notifications) {
      n.isRead = true;
    }
    await _refreshUnreadCount();
    notifyListeners();
  }

  Future<void> deleteNotification(String id) async {
    await _db.deleteInAppNotification(id);
    _notifications.removeWhere((n) => n.id == id);
    await _refreshUnreadCount();
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
        args: item.args.isEmpty ? null : item.args,
      );
      _notifications.insert(index, item);
      await _refreshUnreadCount();
      notifyListeners();
    }
  }
}
