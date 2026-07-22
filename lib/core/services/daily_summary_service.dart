import 'dart:io';

import 'package:expense_tracker/core/services/notification_service.dart';
import 'package:expense_tracker/core/utils/database_helper.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';
import 'package:flutter/foundation.dart';
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

  static Future<({String title, String body, String payload})> _buildContent({
    required String profileId,
  }) async {
    final db = DatabaseHelper.instance;
    final total = await db.getDailyExpenseTotal(profileId: profileId);

    final currencyCode =
        SharedPrefsHelper.getString('selected_currency_code') ?? 'BDT';
    final symbol = _currencySymbols[currencyCode] ?? r'$';
    final amountStr = '$symbol${total.toStringAsFixed(2)}';

    final locale = _detectLocale();
    final strings = _localizedStrings[locale] ?? _localizedStrings['en']!;

    final title = strings['daily_summary']!;
    final body = total > 0
        ? strings['spent_today']!.replaceAll('{amount}', amountStr)
        : strings['no_expenses_today']!;

    return (title: title, body: body, payload: 'daily_summary');
  }

  static Future<void> updateDailyNotification({
    required String profileId,
  }) async {
    try {
      final content = await _buildContent(profileId: profileId);

      // Schedule (or re-schedule) tonight's 11:59 PM local notification with
      // the up-to-date total. No in-app notification is inserted here —
      // the daily summary notification fires exactly once per night.
      await _scheduleTonightNotification(
        id: _notificationId,
        title: content.title,
        body: content.body,
        payload: content.payload,
      );
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

    await NotificationService.instance.showScheduledNotification(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      payload: payload,
    );
  }
}