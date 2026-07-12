import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TransactionHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool isSearching;
  final bool isDark;
  final Color onSurface;
  final TextEditingController searchController;
  final VoidCallback onSearchToggle;
  final ValueChanged<String> onSearchChanged;

  const TransactionHeader({
    super.key,
    required this.isSearching,
    required this.isDark,
    required this.onSurface,
    required this.searchController,
    required this.onSearchToggle,
    required this.onSearchChanged,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: isSearching
          ? TextField(
              controller: searchController,
              autofocus: true,
              style: AppTextStyles.h3.copyWith(color: onSurface),
              decoration: InputDecoration(
                hintText: context.translate('search_hint'),
                hintStyle: AppTextStyles.bodyBold.copyWith(
                  fontWeight: FontWeight.w400,
                  color: isDark ? Colors.white38 : Colors.grey.shade400,
                ),
                border: InputBorder.none,
              ),
              onChanged: onSearchChanged,
            )
          : Text(
              context.translate('transactions'),
              style: AppTextStyles.h2.copyWith(
                fontWeight: FontWeight.bold,
                color: onSurface,
              ),
            ),
      actions: [
        IconButton(
          icon: Icon(
            isSearching ? LucideIcons.x : LucideIcons.search,
            color: isDark ? Colors.white70 : const Color(0xFF31394D),
          ),
          onPressed: onSearchToggle,
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: Theme.of(context).dividerTheme.color ?? const Color(0xFFF1F1F1),
          height: 1.0,
        ),
      ),
    );
  }
}
