import 'dart:io';

import 'package:expense_tracker/core/services/notification_service.dart';
import 'package:expense_tracker/core/utils/database_helper.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';

class MonthlySummaryService {
  MonthlySummaryService._();

  static const int _notificationId = 6001;
  static const String _lastSummaryDateKey = 'last_monthly_summary_date';

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
    'en': 'Monthly Summary',
    'bn': 'মাসিক সারসংক্ষেप',
    'hi': 'मासिक सारांश',
    'ur': 'ماہانہ خلاصہ',
  };

  static const Map<String, String> _bodies = {
    'en': 'You spent {symbol}{amount} this month. Tap to review your habits!',
    'bn': 'এই মাসে আপনার মোট খরচ ছিল {symbol}{amount}। হিসাব দেখতে ট্যাপ করুন!',
    'hi': 'इस महीने आपने कुल {symbol}{amount} खर्च किए। अपनी आदतों की समीक्षा करने के लिए टैप करें!',
    'ur': 'اس مہینے آپ نے کل {symbol}{amount} خرچ کیے۔ اپنی عادات کا جائزہ لینے کے لیے ٹیپ کریں!',
  };

  static Future<void> checkAndGenerate({required String profileId}) async {
    final now = DateTime.now();

    // Only generate on the 1st of each month
    if (now.day != 1) return;

    // Prevent duplicate generation for this month
    final lastDate = SharedPrefsHelper.getString(_lastSummaryDateKey);
    if (lastDate != null) {
      final last = DateTime.tryParse(lastDate);
      if (last != null && last.year == now.year && last.month == now.month) return;
    }

    final db = DatabaseHelper.instance;
    final summary = await db.getMonthlyExpenseSummary(profileId: profileId);
    final total = (summary['total'] as num?)?.toDouble() ?? 0.0;

    // No expenses → no notification
    if (total <= 0) return;

    // Resolve currency symbol
    final currencyCode =
        SharedPrefsHelper.getString('selected_currency_code') ?? 'BDT';
    final symbol = _currencySymbols[currencyCode] ?? r'$';

    // Detect locale for localized message
    final locale = _detectLocale();

    final title = _titles[locale] ?? _titles['en']!;
    final body = (_bodies[locale] ?? _bodies['en']!)
        .replaceAll('{symbol}', symbol)
        .replaceAll('{amount}', total.toStringAsFixed(2));

    // Fire push notification with payload for tap navigation
    await NotificationService.instance.showNotification(
      id: _notificationId,
      title: title,
      body: body,
      payload: 'monthly_summary',
    );

    // Save to in-app notifications
    await db.insertInAppNotification(
      id: 'monthly_summary_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      type: 'alert',
      profileId: profileId,
    );

    // Mark as generated for this month
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
}
