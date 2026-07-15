import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:expense_tracker/features/analytics/widgets/monthly_comparison_card.dart';
import 'package:expense_tracker/features/analytics/widgets/spending_overview_card.dart';
import 'package:expense_tracker/features/analytics/widgets/top_spending_categories_card.dart';
import 'package:expense_tracker/features/analytics/widgets/top_spending_category_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  static bool _localMasked = false;
  bool _isScreenLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() { _isScreenLoading = false; });
      }
    });
  }

  static const _colorPalette = [
    Color(0xFF1EA97C),
    Color(0xFF2EBD85),
    Color(0xFF80E2B9),
    Color(0xFFD2F8E7),
    Color(0xFFE24361),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFF6366F1),
    Color(0xFF06B6D4),
  ];

  static const _namedCategoryColors = <String, Color>{
    'housing': Color(0xFF1EA97C),
    'food': Color(0xFF2EBD85),
    'transport': Color(0xFF80E2B9),
    'utilities': Color(0xFFD2F8E7),
    'entertainment': Color(0xFFE24361),
    'shopping': Color(0xFFF59E0B),
    'health': Color(0xFFEF4444),
    'education': Color(0xFF8B5CF6),
    'salary': Color(0xFF2EBD85),
    'investment': Color(0xFF6366F1),
  };

  static const _namedCategoryIcons = <String, IconData>{
    'housing': LucideIcons.home,
    'food': LucideIcons.utensilsCrossed,
    'transport': LucideIcons.car,
    'utilities': LucideIcons.zap,
    'entertainment': LucideIcons.clapperboard,
    'shopping': LucideIcons.shoppingBag,
    'health': LucideIcons.heartPulse,
    'education': LucideIcons.graduationCap,
    'salary': LucideIcons.creditCard,
    'investment': LucideIcons.trendingUp,
  };

  Color _categoryColor(String category, int index) {
    final key = category.toLowerCase();
    return _namedCategoryColors[key] ?? _colorPalette[index % _colorPalette.length];
  }

  IconData _categoryIcon(String category) {
    return _namedCategoryIcons[category.toLowerCase()] ?? LucideIcons.receipt;
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final isLoading = txProvider.isLoading || _isScreenLoading;

    final double totalExpense = isLoading ? 0.0 : txProvider.monthlyExpense;
    final double prevExpense = isLoading ? 0.0 : txProvider.previousMonthExpense;
    final String changeText = isLoading
        ? '+0.0%'
        : txProvider.expenseTrendDisplay;

    final List<SpendingDistributionItem> spendingItems = isLoading
        ? List.generate(4, (i) => SpendingDistributionItem(
            category: [context.translate('food'), context.translate('transport'), context.translate('shopping'), context.translate('entertainment')][i],
            percentage: 0.0,
            amount: 0.0,
            color: _colorPalette[i],
          ))
        : () {
      const int maxSlices = 11;
      final sorted = txProvider.categoryExpenseBreakdown.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final List<MapEntry<String, double>> top;
      final double othersTotal;
      if (sorted.length <= maxSlices) {
        top = sorted;
        othersTotal = 0;
      } else {
        top = sorted.take(maxSlices - 1).toList();
        othersTotal = sorted.skip(maxSlices - 1).fold(0.0, (s, e) => s + e.value);
      }

      final items = <SpendingDistributionItem>[];
      for (int i = 0; i < top.length; i++) {
        final e = top[i];
        items.add(SpendingDistributionItem(
          category: e.key,
          percentage: txProvider.monthlyExpense > 0 ? (e.value / txProvider.monthlyExpense) * 100 : 0.0,
          amount: e.value,
          color: _categoryColor(e.key, i),
        ));
      }
      if (othersTotal > 0) {
        items.add(SpendingDistributionItem(
          category: context.translate('other_category'),
          percentage: txProvider.monthlyExpense > 0 ? (othersTotal / txProvider.monthlyExpense) * 100 : 0.0,
          amount: othersTotal,
          color: _colorPalette.last,
        ));
      }
      return items;
    }();

    final List<TopSpendingCategoryItem> topItems = isLoading
        ? List.generate(4, (i) => TopSpendingCategoryItem(
            title: [context.translate('food'), context.translate('transport'), context.translate('shopping'), context.translate('entertainment')][i],
            subtitle: '',
            amount: 0.0,
            percentage: 0.0,
            icon: _categoryIcon([context.translate('food'), context.translate('transport'), context.translate('shopping'), context.translate('entertainment')][i]),
          ))
        : txProvider.topSpendingCategories(5).map((t) {
            final (name, amount, pct) = t;
            return TopSpendingCategoryItem(
              title: name, subtitle: '', amount: amount, percentage: pct, icon: _categoryIcon(name),
            );
          }).toList();

    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          context.translate('analytics'),
          style: AppTextStyles.h2.copyWith(
            fontWeight: FontWeight.w700,
            color: onSurface,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _localMasked ? LucideIcons.shield : LucideIcons.shieldOff,
              size: 20,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() => _localMasked = !_localMasked);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Theme.of(context).dividerTheme.color ?? const Color(0xFFF0F0F0),
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
            child: Skeletonizer(
              enabled: isLoading,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SpendingOverviewCard(
                    totalAmount: PrivacyMaskedText(
                      amount: totalExpense,
                      isMasked: _localMasked,
                      style: AppTextStyles.bodyBold.copyWith(color: onSurface),
                    ),
                    items: spendingItems,
                  ),
                  const SizedBox(height: 18),
                  MonthlyComparisonCard(
                    currentAmount: totalExpense,
                    previousAmount: prevExpense,
                    netChangeText: changeText,
                    isMasked: _localMasked,
                  ),
                  const SizedBox(height: 18),
                  TopSpendingCategoriesCard(
                    items: topItems,
                    isMasked: _localMasked,
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
