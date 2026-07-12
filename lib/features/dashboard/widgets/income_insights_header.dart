import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class IncomeInsightsHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBack;

  const IncomeInsightsHeader({super.key, required this.onBack});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      leading: IconButton(
        icon: Icon(
          LucideIcons.arrowLeft,
          color: theme.appBarTheme.iconTheme?.color,
        ),
        onPressed: onBack,
      ),
      title: Text(
        'Income Insights',
        style: AppTextStyles.insightsHeaderTitle.copyWith(
          color: theme.appBarTheme.titleTextStyle?.color,
        ),
      ),
      centerTitle: true,
      backgroundColor: theme.appBarTheme.backgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: theme.dividerTheme.color, height: 1.0),
      ),
    );
  }
}
