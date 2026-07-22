import 'dart:io';

import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class BudgetThresholdResult {
  final String title;
  final String body;

  const BudgetThresholdResult({required this.title, required this.body});
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  /// Global navigator key — set from main() and used by MaterialApp.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  tz.Location? _location;

  /// In-memory guard: tracks (profileId, threshold, month) combos already notified
  /// in the current session. Combined with SharedPrefs persistence for app restarts.
  final Set<String> _budgetNotifiedKeys = {};

  // ── Locale-based strings ──

  static const Map<String, String> _morningTitles = {
    'en': 'Morning Greeting',
    'bn': 'সকালের শুভেচ্ছা',
  };

  static const Map<String, String> _morningBodies = {
    'en': 'Good Morning! Start your day fresh.',
    'bn': 'সুপ্রভাত! নতুন দিন শুরু করুন।',
  };

  static const Map<String, String> _eodTitles = {
    'en': 'Daily Reminder',
    'bn': 'দৈনিক রিমাইন্ডার',
  };

  static const Map<String, String> _eodBodies = {
    'en': "Don't forget to log today's expenses!",
    'bn': 'আজকের খরচ লগ করতে ভুলবেন না!',
  };

  /// External handler set by main() to navigate based on notification payload.
  static void Function(String payload)? onNotificationTapHandler;

  /// Called when the user taps a local notification.
  void _onNotificationTap(NotificationResponse response) {
    debugPrint('_onNotificationTap: type=${response.notificationResponseType} '
        'payload=${response.payload} id=${response.id} input=${response.input}');
    final payload = response.payload;
    if (payload == null || payload.isEmpty) {
      debugPrint('_onNotificationTap: payload is null/empty, routing by id=${response.id}');
      // Fallback: route by notification ID
      if (onNotificationTapHandler != null) {
        onNotificationTapHandler!('id:${response.id}');
      }
      return;
    }
    if (onNotificationTapHandler == null) {
      debugPrint('_onNotificationTap: handler is null, skipping');
      return;
    }
    onNotificationTapHandler!(payload);
  }

  // ── Init ──

  Future<void> init() async {
    if (_initialized) return;

    // Timezone setup
    tz_data.initializeTimeZones();
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      _location = tz.getLocation(timezoneInfo.identifier);
    } catch (_) {
      _location = tz.getLocation('UTC');
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Android 13+ runtime permission
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    // Notification channels
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'budget_alerts',
          'Budget Alerts',
          description: 'Notifications about budget thresholds (80% / 100%)',
          importance: Importance.high,
          playSound: true,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'daily_reminders',
          'Daily Reminders',
          description: 'Morning greetings and end-of-day reminders',
          importance: Importance.high,
          playSound: true,
        ),
      );
    }

    // Schedule recurring notifications
    await _scheduleMorningGreeting();
    await _scheduleEodReminder();

    _initialized = true;
  }

  // ── Locale detection ──

  String _detectLocale() {
    final saved = SharedPrefsHelper.getString('app_language_code');
    if (saved != null) return saved;
    return Platform.localeName.split('_').first;
  }

  // ── Morning Greeting (daily at 8:00 AM) ──

  Future<void> _scheduleMorningGreeting() async {
    if (_location == null) return;

    final locale = _detectLocale();
    final title = _morningTitles[locale] ?? _morningTitles['en']!;
    final body = _morningBodies[locale] ?? _morningBodies['en']!;

    final now = tz.TZDateTime.now(_location!);
    var scheduledDate = tz.TZDateTime(
      _location!,
      now.year,
      now.month,
      now.day,
      8,
      0,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: 2001,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminders',
          'Daily Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> rescheduleMorningGreeting() async {
    await _plugin.cancel(id: 2001);
    await _scheduleMorningGreeting();
  }

  // ── End-of-Day Reminder (daily at 10:00 PM) ──

  Future<void> _scheduleEodReminder() async {
    if (_location == null) return;

    final locale = _detectLocale();
    final title = _eodTitles[locale] ?? _eodTitles['en']!;
    final body = _eodBodies[locale] ?? _eodBodies['en']!;

    final now = tz.TZDateTime.now(_location!);
    var scheduledDate = tz.TZDateTime(
      _location!,
      now.year,
      now.month,
      now.day,
      22,
      0,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: 3001,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminders',
          'Daily Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelEodReminderForToday() async {
    await _plugin.cancel(id: 3001);
    // Reschedule starting from tomorrow so future days still fire
    await _scheduleEodStartingTomorrow();
  }

  Future<void> _scheduleEodStartingTomorrow() async {
    if (_location == null) return;

    final locale = _detectLocale();
    final title = _eodTitles[locale] ?? _eodTitles['en']!;
    final body = _eodBodies[locale] ?? _eodBodies['en']!;

    final now = tz.TZDateTime.now(_location!);
    final scheduledDate = tz.TZDateTime(
      _location!,
      now.year,
      now.month,
      now.day + 1,
      22,
      0,
    );

    await _plugin.zonedSchedule(
      id: 3001,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminders',
          'Daily Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // ── Public helper for one-off notifications ──

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminders',
          'Daily Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  /// Returns launch details when the app was opened via a notification tap.
  Future<NotificationAppLaunchDetails?> getNotificationAppLaunchDetails() {
    return _plugin.getNotificationAppLaunchDetails();
  }

  // ── Scheduled notification (used by DailySummaryService) ──

  Future<void> showScheduledNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    String? payload,
  }) async {
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminders',
          'Daily Reminders',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }

  // ── Budget Threshold ──

  Future<BudgetThresholdResult?> checkBudgetThreshold({
    required double budgetAmount,
    required double currentMonthExpense,
    required String currencySymbol,
    String profileId = 'default_profile',
  }) async {
    if (budgetAmount <= 0) return null;

    final ratio = currentMonthExpense / budgetAmount;
    final now = DateTime.now();
    final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    BudgetThresholdResult? result;

    // ── 100% Exceeded (independent check) ──
    if (ratio >= 1.0) {
      result = await _fireIfNotNotified(
        thresholdKey: '100',
        monthKey: monthKey,
        profileId: profileId,
        notificationId: 1001,
        title: 'Budget Exceeded',
        body:
            'You have exceeded your monthly budget of '
            '$currencySymbol${budgetAmount.toStringAsFixed(2)}. '
            'Current spending: $currencySymbol${currentMonthExpense.toStringAsFixed(2)}.',
      );
      if (result != null) return result;
    }

    // ── 80% Warning (independent check) ──
    if (ratio >= 0.8) {
      result = await _fireIfNotNotified(
        thresholdKey: '80',
        monthKey: monthKey,
        profileId: profileId,
        notificationId: 1002,
        title: 'Budget Warning',
        body:
            'You have used ${(ratio * 100).toStringAsFixed(0)}% '
            'of your monthly budget '
            '($currencySymbol${currentMonthExpense.toStringAsFixed(2)} '
            'of $currencySymbol${budgetAmount.toStringAsFixed(2)}).',
      );
    }

    return result;
  }

  Future<BudgetThresholdResult?> _fireIfNotNotified({
    required String thresholdKey,
    required String monthKey,
    required String profileId,
    required int notificationId,
    required String title,
    required String body,
  }) async {
    final notifyKey = '${monthKey}_${profileId}_${thresholdKey}pct';
    if (_budgetNotifiedKeys.contains(notifyKey)) {
      debugPrint('checkBudgetThreshold: SKIP (in-memory) $notifyKey');
      return null;
    }

    final prefsKey = 'budget_${thresholdKey}pct_warned_${monthKey}_$profileId';
    final lastNotified = SharedPrefsHelper.getString(prefsKey);
    if (lastNotified == monthKey) {
      debugPrint('checkBudgetThreshold: SKIP (SharedPrefs) $prefsKey=$monthKey');
      return null;
    }

    debugPrint('checkBudgetThreshold: FIRING $notifyKey | monthKey=$monthKey | prefsKey=$prefsKey');

    try {
      await _plugin.show(
        id: notificationId,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'budget_alerts',
            'Budget Alerts',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint('checkBudgetThreshold: _plugin.show error: $e');
    }

    _budgetNotifiedKeys.add(notifyKey);
    await SharedPrefsHelper.setString(prefsKey, monthKey);
    debugPrint('checkBudgetThreshold: FIRED $notifyKey');

    return BudgetThresholdResult(title: title, body: body);
  }
}
