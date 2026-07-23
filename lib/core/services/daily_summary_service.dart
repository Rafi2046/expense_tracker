import 'dart:io';

import 'package:expense_tracker/core/providers/notification_provider.dart';
import 'package:expense_tracker/core/services/notification_service.dart';
import 'package:expense_tracker/core/utils/database_helper.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class DailySummaryService {
  DailySummaryService._();

  /// Prefs key: last calendar day (yyyy-MM-dd) we persisted daily summary
  /// into the in-app notification list.
  static const String _lastSummaryDateKey = 'last_daily_summary_date';

  /// Legacy fixed ids from older builds — cancel so they cannot double-fire.
  static const int _legacyScheduleId = 5001;

  /// Local clock time for the daily summary (hour, minute).
  static const int _hour = 23;
  static const int _minute = 30;

  /// Daily Summary always reflects the **main** profile only.
  static const String _mainProfileId = 'default_profile';

  static Future<void>? _updateInFlight;

  static const Map<String, String> _currencySymbols = {
    'BDT': '৳',
    'INR': '₹',
    'JPY': '¥',
    'AED': 'د.إ',
    'EUR': '€',
    'GBP': '£',
    'USD': r'$',
    'CAD': r'$',
  };

  static const Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'daily_summary': 'Daily Summary',
      'spent_today': 'You spent {amount} today',
      'no_expenses_today': 'No expenses logged today.',
    },
    'bn': {
      'daily_summary': 'দৈনিক সারসংক্ষেপ',
      'spent_today': 'আজ আপনি মোট {amount} খরচ করেছেন',
      'no_expenses_today': 'আজ কোনো খরচ লগ হয়নি।',
    },
    'hi': {
      'daily_summary': 'दैनिक सारांश',
      'spent_today': 'आज आपने कुल {amount} खर्च किए',
      'no_expenses_today': 'आज कोई खर्च लॉग नहीं किया गया।',
    },
    'ur': {
      'daily_summary': 'روزانہ کا خلاصہ',
      'spent_today': 'آج آپ نے کل {amount} خرچ کیے',
      'no_expenses_today': 'آج کوئی اخراجات درج نہیں کیے گئے۔',
    },
  };

  static String _detectLocale() {
    final saved = SharedPrefsHelper.getString('app_language_code');
    if (saved != null) return saved;
    return Platform.localeName.split('_').first;
  }

  static String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Unique OS notification id per calendar day so rescheduling tomorrow
  /// does not cancel today's still-visible tray notification.
  static int _notificationIdForDay(DateTime d) =>
      5000000 + (d.year % 100) * 10000 + d.month * 100 + d.day;

  static Future<tz.Location> _deviceLocalLocation() async {
    tz_data.initializeTimeZones();
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      final location = tz.getLocation(timezoneInfo.identifier);
      tz.setLocalLocation(location);
      return location;
    } catch (e) {
      debugPrint('DailySummaryService: timezone fallback UTC ($e)');
      final utc = tz.getLocation('UTC');
      tz.setLocalLocation(utc);
      return utc;
    }
  }

  static Future<({String title, String body, String amountStr, double total})>
      _buildContent() async {
    final db = DatabaseHelper.instance;
    final total = await db.getDailyExpenseTotal(profileId: _mainProfileId);

    final currencyCode =
        SharedPrefsHelper.getString('selected_currency_code') ?? 'BDT';
    final symbol = _currencySymbols[currencyCode] ?? r'$';
    final amountStr = '$symbol${total.toStringAsFixed(0)}';

    final locale = _detectLocale();
    final strings = _localizedStrings[locale] ?? _localizedStrings['en']!;

    final title = strings['daily_summary']!;
    final body = total > 0
        ? strings['spent_today']!.replaceAll('{amount}', amountStr)
        : strings['no_expenses_today']!;

    debugPrint(
      'DailySummaryService: profile=$_mainProfileId todayTotal=$total body="$body"',
    );

    return (title: title, body: body, amountStr: amountStr, total: total);
  }

  /// Schedules the next 11:30 PM alarm and, after that slot, ensures one
  /// in-app notification row exists (does NOT re-post to the OS tray).
  static Future<void> updateDailyNotification({String? profileId}) async {
    if (_updateInFlight != null) {
      await _updateInFlight;
      return;
    }
    _updateInFlight = _updateBody();
    try {
      await _updateInFlight;
    } finally {
      _updateInFlight = null;
    }
  }

  static Future<void> _updateBody() async {
    try {
      // Drop legacy fixed-id schedules that can fire alongside day-based ids.
      await NotificationService.instance.cancelNotification(_legacyScheduleId);

      final content = await _buildContent();
      await _scheduleNext1130(
        title: content.title,
        body: content.body,
      );
      await _persistInAppIfDue(amountStr: content.amountStr);
    } catch (e) {
      debugPrint('DailySummaryService.updateDailyNotification error: $e');
    }
  }

  /// One-shot schedule for the next 11:30 local — unique id per calendar day.
  static Future<void> _scheduleNext1130({
    required String title,
    required String body,
  }) async {
    final location = await _deviceLocalLocation();
    final now = tz.TZDateTime.now(location);

    var scheduledDate = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      _hour,
      _minute,
    );

    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final id = _notificationIdForDay(
      DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day),
    );

    debugPrint(
      'DailySummaryService: schedule id=$id at $scheduledDate '
      '(tz=${location.name}) oneShot',
    );

    await NotificationService.instance.showScheduledNotification(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      payload: 'daily_summary',
      repeatDaily: false,
      autoCancel: false,
    );
  }

  /// After 11:30 local, ensure one in-app row exists for today.
  /// Does not call [showNotification] — that was causing a second tray alert
  /// when the user opened the app after the scheduled one already fired.
  static Future<void> _persistInAppIfDue({
    required String amountStr,
  }) async {
    final location = await _deviceLocalLocation();
    final now = tz.TZDateTime.now(location);
    final slotToday = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      _hour,
      _minute,
    );

    if (now.isBefore(slotToday)) return;

    final todayKey = _dayKey(now);
    final lastKey = SharedPrefsHelper.getString(_lastSummaryDateKey);
    if (lastKey == todayKey) return;

    // Claim the day first so parallel callers cannot insert twice.
    await SharedPrefsHelper.setString(_lastSummaryDateKey, todayKey);

    final inAppProfileId =
        SharedPrefsHelper.getString(SharedPrefsHelper.activeProfileKey) ??
            _mainProfileId;
    await DatabaseHelper.instance.insertInAppNotification(
      id: 'daily_summary_${now.millisecondsSinceEpoch}',
      title: 'notif_daily_summary_title',
      body: 'notif_daily_summary_body',
      type: 'daily_summary',
      profileId: inAppProfileId,
      args: {'amount': amountStr},
    );
    NotificationProvider.notifyDataChanged();
    debugPrint('DailySummaryService: persisted in-app only for $todayKey');
  }
}
