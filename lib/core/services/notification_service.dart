import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class BudgetThresholdResult {
  /// Localized strings for the OS tray notification (frozen at fire time).
  final String title;
  final String body;

  /// Translation keys + args for in-app SQLite storage.
  final String titleKey;
  final String bodyKey;
  final Map<String, String> args;

  const BudgetThresholdResult({
    required this.title,
    required this.body,
    required this.titleKey,
    required this.bodyKey,
    required this.args,
  });
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

  /// Exact when permitted; otherwise inexact so schedules still register on Android 14+.
  AndroidScheduleMode _androidScheduleMode =
      AndroidScheduleMode.exactAllowWhileIdle;

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
      tz.setLocalLocation(_location!);
    } catch (_) {
      _location = tz.getLocation('UTC');
      tz.setLocalLocation(_location!);
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

    // Android 13+ runtime permission + Android 14+ exact-alarm access
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();

      // Without this, exactAllowWhileIdle schedules are silently dropped on Android 14+.
      final canExact = await androidPlugin.canScheduleExactNotifications();
      debugPrint('NotificationService: canScheduleExactNotifications=$canExact');
      if (canExact != true) {
        await androidPlugin.requestExactAlarmsPermission();
      }
      final canExactAfter =
          await androidPlugin.canScheduleExactNotifications();
      _androidScheduleMode = canExactAfter == true
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;
      debugPrint(
        'NotificationService: androidScheduleMode=$_androidScheduleMode',
      );

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
          importance: Importance.max,
          playSound: true,
        ),
      );
    }

    // Schedule recurring notifications
    await _scheduleMorningGreeting();
    await _scheduleEodReminder();

    _initialized = true;
  }

  Future<void> _safeZonedSchedule({
    required int id,
    required String? title,
    required String? body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: _androidScheduleMode,
        payload: payload,
        matchDateTimeComponents: matchDateTimeComponents,
      );
    } catch (e) {
      debugPrint(
        'NotificationService: zonedSchedule exact failed ($e), retrying inexact',
      );
      _androidScheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload,
        matchDateTimeComponents: matchDateTimeComponents,
      );
    }
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

    await _safeZonedSchedule(
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

    await _safeZonedSchedule(
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
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancels a pending or delivered notification by [id].
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id: id);
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

    await _safeZonedSchedule(
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
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // ── Public helper for one-off notifications ──

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    bool autoCancel = true,
  }) async {
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminders',
          'Daily Reminders',
          importance: Importance.high,
          priority: Priority.high,
          autoCancel: autoCancel,
        ),
        iOS: const DarwinNotificationDetails(
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

  /// Schedules a local notification at [scheduledDate] in the device timezone.
  ///
  /// When [repeatDaily] is true, uses [DateTimeComponents.time] so it fires
  /// every day at that local clock time.
  /// [autoCancel] false keeps the notification in the shade until the user
  /// dismisses it (Daily Summary).
  Future<void> showScheduledNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    String? payload,
    bool repeatDaily = false,
    bool autoCancel = true,
  }) async {
    await _safeZonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminders',
          'Daily Reminders',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          autoCancel: autoCancel,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
      matchDateTimeComponents:
          repeatDaily ? DateTimeComponents.time : null,
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
    final dayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final budgetFormatted =
        '$currencySymbol${budgetAmount.toStringAsFixed(2)}';
    final amountFormatted =
        '$currencySymbol${currentMonthExpense.toStringAsFixed(2)}';
    final percentFormatted = (ratio * 100).toStringAsFixed(0);

    // ── 100% Exceeded ──
    // If already at/over budget, only attempt the 100% alert.
    // Never fall through to 80% when 100% is skipped (already warned today).
    if (ratio >= 1.0) {
      return _fireIfNotNotified(
        thresholdKey: '100',
        dayKey: dayKey,
        profileId: profileId,
        notificationId: 1001,
        titleKey: 'notif_budget_exceeded_title',
        bodyKey: 'notif_budget_exceeded_body',
        args: {
          'budget': budgetFormatted,
          'amount': amountFormatted,
        },
      );
    }

    // ── 80% Warning (only when not yet fully exceeded) ──
    if (ratio >= 0.8) {
      return _fireIfNotNotified(
        thresholdKey: '80',
        dayKey: dayKey,
        profileId: profileId,
        notificationId: 1002,
        titleKey: 'notif_budget_warning_title',
        bodyKey: 'notif_budget_warning_body',
        args: {
          'percent': percentFormatted,
          'amount': amountFormatted,
          'budget': budgetFormatted,
        },
      );
    }

    return null;
  }

  Future<BudgetThresholdResult?> _fireIfNotNotified({
    required String thresholdKey,
    required String dayKey,
    required String profileId,
    required int notificationId,
    required String titleKey,
    required String bodyKey,
    required Map<String, String> args,
  }) async {
    // Once per calendar day per profile (survives cold starts via SharedPrefs).
    final memoryKey = 'budget_day_${dayKey}_$profileId';
    if (_budgetNotifiedKeys.contains(memoryKey)) {
      debugPrint('checkBudgetThreshold: SKIP (in-memory) $memoryKey');
      return null;
    }

    final prefsKey = 'budget_warned_today_${dayKey}_$profileId';
    if (SharedPrefsHelper.getBool(prefsKey) == true) {
      debugPrint('checkBudgetThreshold: SKIP (SharedPrefs) $prefsKey=true');
      _budgetNotifiedKeys.add(memoryKey);
      return null;
    }

    // Resolve OS tray text in the current app language at fire time.
    final title = tr(titleKey);
    final body = tr(bodyKey, namedArgs: args);

    debugPrint(
      'checkBudgetThreshold: FIRING ${thresholdKey}pct | $memoryKey | prefsKey=$prefsKey',
    );

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

    _budgetNotifiedKeys.add(memoryKey);
    final saved = await SharedPrefsHelper.setBool(prefsKey, true);
    if (!saved) {
      debugPrint(
        'checkBudgetThreshold: WARNING failed to persist daily flag $prefsKey',
      );
    }
    debugPrint('checkBudgetThreshold: FIRED ${thresholdKey}pct | saved=$saved');

    return BudgetThresholdResult(
      title: title,
      body: body,
      titleKey: titleKey,
      bodyKey: bodyKey,
      args: args,
    );
  }
}
