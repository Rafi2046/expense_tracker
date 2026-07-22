import 'package:expense_tracker/core/utils/database_helper.dart';
import 'package:flutter/material.dart';

class CategoryBreakdownItem {
  final String name;
  final double amount;
  final double percentage;

  const CategoryBreakdownItem({
    required this.name,
    required this.amount,
    required this.percentage,
  });
}

class MemberBreakdownItem {
  final String name;
  final double amount;
  final double percentage;
  final Color color;

  const MemberBreakdownItem({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.color,
  });
}

class TourInsightsData {
  final String tourId;
  final double grandTotal;
  final List<CategoryBreakdownItem> categoryBreakdown;
  final List<MemberBreakdownItem> memberBreakdown;

  const TourInsightsData({
    required this.tourId,
    required this.grandTotal,
    required this.categoryBreakdown,
    required this.memberBreakdown,
  });

  static const _memberColors = [
    Color(0xFFAF52DE),
    Color(0xFF34C759),
    Color(0xFFFF9500),
    Color(0xFF5856D6),
    Color(0xFFFF2D55),
    Color(0xFF32ADE6),
    Color(0xFF00C7BE),
    Color(0xFFFFCC00),
    Color(0xFFFF3B30),
    Color(0xFF64D2FF),
  ];

  static Color _colorForIndex(int index) =>
      _memberColors[index % _memberColors.length];

  static Future<TourInsightsData?> load(String tourId) async {
    final db = await DatabaseHelper.instance.database;

    final categoryRows = await db.rawQuery(
      '''SELECT COALESCE(category, 'Other') as category,
                SUM(amount) as total
         FROM tour_expenses
         WHERE tourId = ? AND isDeleted = 0
         GROUP BY category
         ORDER BY total DESC''',
      [tourId],
    );

    final memberRows = await db.rawQuery(
      '''SELECT s.participantId,
                SUM(s.shareAmount) as total
         FROM tour_expense_shares s
         INNER JOIN tour_expenses e ON e.id = s.expenseId
         WHERE e.tourId = ? AND e.isDeleted = 0 AND s.isExcluded = 0 AND s.isDeleted = 0
         GROUP BY s.participantId
         ORDER BY total DESC''',
      [tourId],
    );

    final totalResult = await db.rawQuery(
      '''SELECT COALESCE(SUM(amount), 0.0) as grandTotal
         FROM tour_expenses
         WHERE tourId = ? AND isDeleted = 0''',
      [tourId],
    );

    final grandTotal = (totalResult.first['grandTotal'] as num).toDouble();

    final categoryBreakdown = categoryRows.map((row) {
      final amount = (row['total'] as num).toDouble();
      return CategoryBreakdownItem(
        name: row['category'] as String,
        amount: amount,
        percentage: grandTotal > 0 ? amount / grandTotal : 0.0,
      );
    }).toList();

    if (memberRows.isEmpty || grandTotal == 0) {
      return TourInsightsData(
        tourId: tourId,
        grandTotal: grandTotal,
        categoryBreakdown: categoryBreakdown,
        memberBreakdown: const [],
      );
    }

    final participantIds =
        memberRows.map((r) => r['participantId'] as String).toList();

    final placeholders = participantIds.map((_) => '?').join(',');
    final nameMap = <String, String>{};
    if (participantIds.isNotEmpty) {
      final participantRows = await db.rawQuery(
        'SELECT id, name FROM tour_participants WHERE id IN ($placeholders)',
        participantIds,
      );
      for (final row in participantRows) {
        nameMap[row['id'] as String] = row['name'] as String;
      }
    }

    final memberBreakdown = memberRows.map((row) {
      final participantId = row['participantId'] as String;
      final amount = (row['total'] as num).toDouble();
      final idx = participantIds.indexOf(participantId);
      return MemberBreakdownItem(
        name: nameMap[participantId] ?? participantId,
        amount: amount,
        percentage: grandTotal > 0 ? amount / grandTotal : 0.0,
        color: _colorForIndex(idx),
      );
    }).toList();

    return TourInsightsData(
      tourId: tourId,
      grandTotal: grandTotal,
      categoryBreakdown: categoryBreakdown,
      memberBreakdown: memberBreakdown,
    );
  }
}
