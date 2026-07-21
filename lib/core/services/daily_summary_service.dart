import 'dart:io';

import 'package:expense_tracker/core/utils/database_helper.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class DailySummaryService {
  DailySummaryService._();

  static const int _notificationId = 5001;

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
      'daily_reminder_body': "Don't forget to log today's expenses!",
    },
    'bn': {
      'daily_summary': 'দৈনিক সারসংক্ষেপ',
      'spent_today': 'আজ আপনি মোট {amount} খরচ করেছেন',
      'daily_reminder_body': 'আজকের খরচ লগ করতে ভুলবেন না!',
    },
    'hi': {
      'daily_summary': 'दैनिक सारांश',
      'spent_today': 'आज आपने कुल {amount} खर्च किए',
      'daily_reminder_body': 'आज के खर्चों को दर्ज करना न भूलें!',
    },
    'ur': {
      'daily_summary': 'روزانہ کا خلاصہ',
      'spent_today': 'آج آپ نے کل {amount} خرچ کیے',
      'daily_reminder_body': 'آج کے اخراجات درج کرنا نہ بھولیں!',
    },
  };

  static String _detectLocale() {
    final saved = SharedPrefsHelper.getString('app_language_code');
    if (saved != null) return saved;
    return Platform.localeName.split('_').first;
  }

  static Future<void> updateDailyNotification({
    required String profileId,
  }) async {
    try {
      final db = DatabaseHelper.instance;
      // Get today's total expenses
      final total = await db.getDailyExpenseTotal(profileId: profileId);

      final currencyCode =
          SharedPrefsHelper.getString('selected_currency_code') ?? 'BDT';
      final symbol = _currencySymbols[currencyCode] ?? r'$';
      final amountStr = '$symbol${total.toStringAsFixed(2)}';

      final locale = _detectLocale();
      final strings = _localizedStrings[locale] ?? _localizedStrings['en']!;

      final title = strings['daily_summary']!;

      final String body;
      final String payload;
      if (total > 0) {
        body = strings['spent_today']!.replaceAll('{amount}', amountStr);
        payload = 'daily_summary';
      } else {
        body = strings['daily_reminder_body']!;
        payload = 'daily_reminder';
      }

      // Schedule tonight's local notification
      await _scheduleTonightNotification(
        id: _notificationId,
        title: title,
        body: body,
        payload: payload,
      );

      // Save/update today's in-app notification if total > 0
      if (total > 0) {
        final now = DateTime.now();
        final dateKey =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

        await db.insertInAppNotification(
          id: 'daily_summary_$dateKey',
          title: title,
          body: body,
          type: 'alert', // Changed from 'update' to 'alert' to make the icon red like weekly summary
          profileId: profileId,
        );
      }
    } catch (e) {
      debugPrint('DailySummaryService.updateDailyNotification error: $e');
    }
  }

  static Future<void> _scheduleTonightNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    final plugin = FlutterLocalNotificationsPlugin();

    // Timezone setup
    tz_data.initializeTimeZones();
    tz.Location location;
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      location = tz.getLocation(timezoneInfo.identifier);
    } catch (_) {
      location = tz.getLocation('UTC');
    }

    final now = tz.TZDateTime.now(location);
    var scheduledDate = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      23, // 11 PM
      59, // 59 minutes
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await plugin.zonedSchedule(
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
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }
}