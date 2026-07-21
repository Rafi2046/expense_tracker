import 'package:flutter/material.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

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
  }) {
    final List<String> insights = [];

    // Insight 1: Today's spending level vs. 7-day average
    if (total == 0) {
      insights.add(context.translate('no_expenses_today'));
    } else if (averageDaily > 0) {
      final diffPercent = ((total - averageDaily) / averageDaily * 100).round();
      if (diffPercent > 20) {
        insights.add(
          'Your spending today is $diffPercent% higher than your recent 7-day daily average of \$${averageDaily.toStringAsFixed(2)}. Consider reviewing your budget!'
        );
      } else if (diffPercent < -20) {
        insights.add(
          'Great job! Your spending today is ${diffPercent.abs()}% lower than your recent 7-day daily average.'
        );
      } else {
        insights.add(
          'Your daily spending is right on track, matching your recent 7-day average of \$${averageDaily.toStringAsFixed(2)}.'
        );
      }
    } else {
      insights.add(
        'You started logging today. Keep tracking daily to see average spending insights!'
      );
    }

    // Insight 2: Top category
    if (topCategory != null && total > 0) {
      final share = (topAmount / total * 100).round();
      insights.add(
        'Most of your money today went into $topCategory, which accounts for $share% of your total spending (\$${topAmount.toStringAsFixed(2)}).'
      );
    }

    // Insight 3: Single high transaction warning
    if (highestAmount > 0 && total > 0) {
      final highestShare = (highestAmount / total * 100).round();
      if (highestShare > 50 && total > 10.0) {
        insights.add(
          'A single large expense today represents $highestShare% of your daily spending. Be mindful of one-off large purchases.'
        );
      }
    }

    return insights;
  }
}
