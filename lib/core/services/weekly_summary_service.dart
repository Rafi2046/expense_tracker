import 'dart:io';

import 'package:expense_tracker/core/services/notification_service.dart';
import 'package:expense_tracker/core/utils/database_helper.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';

class WeeklySummaryService {
  WeeklySummaryService._();

  static const String _lastSummaryDateKey = 'last_weekly_summary_date';
  static const int _notificationId = 4001;

  /// Currency code → symbol lookup (mirrors CurrencyProvider data).
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

  static const Map<String, String> _titles = {
    'en': 'Weekly Summary',
    'bn': 'সাপ্তাহিক সারসংক্ষেপ',
  };

  static const Map<String, String> _bodies = {
    'en': 'You spent {symbol}{amount} last week. Tap to review your habits!',
    'bn': 'গত সপ্তাহে আপনার মোট খরচ ছিল {symbol}{amount}। হিসাব দেখতে ট্যাপ করুন!',
  };

  static Future<({String title, String body})> _buildContent({
    required String profileId,
  }) async {
    final db = DatabaseHelper.instance;
    final summary = await db.getWeeklyExpenseSummary(profileId: profileId);
    final total = (summary['total'] as num?)?.toDouble() ?? 0.0;

    final currencyCode =
        SharedPrefsHelper.getString('selected_currency_code') ?? 'BDT';
    final symbol = _currencySymbols[currencyCode] ?? r'$';

    final locale = _detectLocale();
    final title = _titles[locale] ?? _titles['en']!;
    final body = (_bodies[locale] ?? _bodies['en']!)
        .replaceAll('{symbol}', symbol)
        .replaceAll('{amount}', total.toStringAsFixed(2));

    return (title: title, body: body);
  }

  static Future<void> checkAndGenerate({required String profileId}) async {
    // Only generate on Mondays
    if (DateTime.now().weekday != DateTime.monday) return;

    // Prevent duplicate generation for this week
    final lastDate = SharedPrefsHelper.getString(_lastSummaryDateKey);
    if (lastDate != null) {
      final last = DateTime.tryParse(lastDate);
      if (last != null && _isSameWeek(last, DateTime.now())) return;
    }

    final db = DatabaseHelper.instance;
    final summary = await db.getWeeklyExpenseSummary(profileId: profileId);
    final total = (summary['total'] as num?)?.toDouble() ?? 0.0;

    // No expenses → no notification
    if (total <= 0) return;

    final content = await _buildContent(profileId: profileId);

    // Fire push notification with payload for tap navigation
    await NotificationService.instance.showNotification(
      id: _notificationId,
      title: content.title,
      body: content.body,
      payload: 'weekly_summary',
    );

    // Save to in-app notifications
    await db.insertInAppNotification(
      id: 'weekly_summary_${DateTime.now().millisecondsSinceEpoch}',
      title: content.title,
      body: content.body,
      type: 'weekly_summary',
      profileId: profileId,
    );

    // Mark as generated for this week
    await SharedPrefsHelper.setString(
      _lastSummaryDateKey,
      DateTime.now().toIso8601String(),
    );
  }

  static String _detectLocale() {
    final saved = SharedPrefsHelper.getString('app_language_code');
    if (saved != null) return saved;
    return Platform.localeName.split('_').first;
  }

  static bool _isSameWeek(DateTime a, DateTime b) {
    final ad = a.toUtc();
    final bd = b.toUtc();
    final weekA = ad.difference(DateTime.utc(ad.year, 1, 1)).inDays ~/ 7;
    final weekB = bd.difference(DateTime.utc(bd.year, 1, 1)).inDays ~/ 7;
    return ad.year == bd.year && weekA == weekB;
  }
}
