import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const double _tabBarHeight = 46.0;

class ManageCategoriesHeader extends StatelessWidget
    implements PreferredSizeWidget {
  final TabController tabController;
  final Color primaryTabColor;
  final VoidCallback onBack;

  const ManageCategoriesHeader({
    super.key,
    required this.tabController,
    required this.primaryTabColor,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: theme.cardColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(LucideIcons.arrowLeft,
            color: theme.colorScheme.onSurface),
        onPressed: onBack,
      ),
      title: Text(
        context.translate('manage_categories'),
        style: AppTextStyles.h2
            .copyWith(color: theme.colorScheme.onSurface),
      ),
      centerTitle: true,
      bottom: TabBar(
        controller: tabController,
        labelColor: primaryTabColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: primaryTabColor,
        labelStyle: AppTextStyles.bodyBold,
        tabs: [
          Tab(text: context.translate('expense')),
          Tab(text: context.translate('income')),
        ],
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + _tabBarHeight);
}
