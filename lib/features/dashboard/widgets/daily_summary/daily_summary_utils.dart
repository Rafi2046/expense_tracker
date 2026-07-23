import 'package:flutter/material.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

enum SummaryInsightPeriod { daily, monthly }

class DailySummaryUtils {
  DailySummaryUtils._();

  static const List<Color> _palette = [
    Color(0xFF8E75C8),
    Color(0xFF00BFA5),
    Color(0xFFFF8A65),
    Color(0xFF4FC3F7),
    Color(0xFFFFD54F),
    Color(0xFFD4E157),
    Color(0xFFBA68C8),
  ];

  static Color getCategoryColor(String category, int index) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'food & dining':
        return const Color(0xFFFF8A65);
      case 'shopping':
        return const Color(0xFFBA68C8);
      case 'transport':
      case 'transportation':
        return const Color(0xFF4FC3F7);
      case 'bills':
      case 'utilities':
        return const Color(0xFFFFD54F);
      case 'entertainment':
        return const Color(0xFF8E75C8);
      default:
        return _palette[index % _palette.length];
    }
  }

  static List<String> generateInsights({
    required BuildContext context,
    required double total,
    required double averageDaily,
    required String? topCategory,
    required double topAmount,
    required double highestAmount,
    SummaryInsightPeriod period = SummaryInsightPeriod.daily,
  }) {
    if (period == SummaryInsightPeriod.monthly) {
      return _generateMonthlyInsights(
        context: context,
        total: total,
        averageDaily: averageDaily,
        topCategory: topCategory,
        topAmount: topAmount,
        highestAmount: highestAmount,
      );
    }
    return _generateDailyInsights(
      context: context,
      total: total,
      averageDaily: averageDaily,
      topCategory: topCategory,
      topAmount: topAmount,
      highestAmount: highestAmount,
    );
  }

  static List<String> _generateDailyInsights({
    required BuildContext context,
    required double total,
    required double averageDaily,
    required String? topCategory,
    required double topAmount,
    required double highestAmount,
  }) {
    final List<String> insights = [];
    final sym = context.currencySymbol;
    final avgText = '$sym${averageDaily.toStringAsFixed(2)}';

    if (total == 0) {
      insights.add(context.translate('no_expenses_today'));
    } else if (averageDaily > 0) {
      final diffPercent = ((total - averageDaily) / averageDaily * 100).round();
      if (diffPercent > 20) {
        insights.add(context.translate(
          'insight_spend_higher_than_avg',
          namedArgs: {
            'percent': '$diffPercent',
            'amount': avgText,
          },
        ));
      } else if (diffPercent < -20) {
        insights.add(context.translate(
          'insight_spend_lower_than_avg',
          namedArgs: {'percent': '${diffPercent.abs()}'},
        ));
      } else {
        insights.add(context.translate(
          'insight_spend_on_track',
          namedArgs: {'amount': avgText},
        ));
      }
    } else {
      insights.add(context.translate('insight_started_logging_today'));
    }

    if (topCategory != null && total > 0) {
      final share = (topAmount / total * 100).round();
      insights.add(context.translate(
        'insight_top_category_today',
        namedArgs: {
          'category': topCategory,
          'share': '$share',
          'amount': '$sym${topAmount.toStringAsFixed(2)}',
        },
      ));
    }

    if (highestAmount > 0 && total > 0) {
      final highestShare = (highestAmount / total * 100).round();
      if (highestShare > 50 && total > 10.0) {
        insights.add(context.translate(
          'insight_large_expense_today',
          namedArgs: {'share': '$highestShare'},
        ));
      }
    }

    return insights;
  }

  static List<String> _generateMonthlyInsights({
    required BuildContext context,
    required double total,
    required double averageDaily,
    required String? topCategory,
    required double topAmount,
    required double highestAmount,
  }) {
    final List<String> insights = [];
    final sym = context.currencySymbol;

    if (total == 0) {
      insights.add(context.translate('no_expenses_this_month'));
      return insights;
    }

    insights.add(context.translate(
      'insight_month_total',
      namedArgs: {'amount': '$sym${total.toStringAsFixed(2)}'},
    ));

    if (averageDaily > 0) {
      insights.add(context.translate(
        'insight_month_daily_avg',
        namedArgs: {'amount': '$sym${averageDaily.toStringAsFixed(2)}'},
      ));
    }

    if (topCategory != null) {
      final share = (topAmount / total * 100).round();
      insights.add(context.translate(
        'insight_top_category_month',
        namedArgs: {
          'category': topCategory,
          'share': '$share',
          'amount': '$sym${topAmount.toStringAsFixed(2)}',
        },
      ));
    }

    if (highestAmount > 0) {
      final highestShare = (highestAmount / total * 100).round();
      if (highestShare > 40 && total > 10.0) {
        insights.add(context.translate(
          'insight_large_expense_month',
          namedArgs: {'share': '$highestShare'},
        ));
      }
    }

    return insights;
  }
}
