import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/providers/notification_provider.dart';
import 'package:flutter/material.dart';

/// Resolves in-app notification title/body for display.
///
/// New rows store translation keys (e.g. `notif_budget_warning_title`) plus
/// `args`. Legacy rows store already-localized plain text and are passed
/// through unchanged forever.
class NotificationLocalizer {
  NotificationLocalizer._();

  /// Known in-app notification translation keys.
  static const Set<String> knownKeys = {
    'notif_budget_exceeded_title',
    'notif_budget_exceeded_body',
    'notif_budget_warning_title',
    'notif_budget_warning_body',
    'notif_weekly_summary_title',
    'notif_weekly_summary_body',
    'notif_monthly_summary_title',
    'notif_monthly_summary_body',
  };

  /// True when [value] is a localizable key (not legacy plain text).
  static bool isTranslationKey(String value) {
    if (value.isEmpty || value.contains(' ')) return false;
    if (knownKeys.contains(value)) return true;
    // Forward-compatible: accept future `notif_*` keys without spaces.
    return value.startsWith('notif_') && RegExp(r'^[a-z0-9_]+$').hasMatch(value);
  }

  /// Returns display title/body for [item] in the current app locale.
  static ({String title, String body}) resolve(
    BuildContext context,
    NotificationItem item,
  ) {
    final title = isTranslationKey(item.title)
        ? context.translate(item.title)
        : item.title;

    final body = isTranslationKey(item.description)
        ? context.translate(
            item.description,
            namedArgs: item.args.isEmpty ? null : item.args,
          )
        : item.description;

    return (title: title, body: body);
  }

  static String resolveTitle(BuildContext context, NotificationItem item) {
    return resolve(context, item).title;
  }

  static String resolveBody(BuildContext context, NotificationItem item) {
    return resolve(context, item).body;
  }
}
