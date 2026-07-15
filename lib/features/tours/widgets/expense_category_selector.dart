import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

class ExpenseCategorySelector extends StatelessWidget {
  final ThemeData theme;
  final String? selectedCategory;
  final List<Map<String, dynamic>> customCategories;
  final ValueChanged<String?> onCategorySelected;
  final VoidCallback onAddCategory;

  static const _categories = [
    ('Food', LucideIcons.utensilsCrossed),
    ('Transport', LucideIcons.car),
    ('Accommodation', LucideIcons.hotel),
    ('Activities', LucideIcons.mountain),
    ('Shopping', LucideIcons.shoppingBag),
    ('Drinks', LucideIcons.beer),
    ('Groceries', LucideIcons.shoppingCart),
    ('Fuel', LucideIcons.fuel),
    ('Tickets', LucideIcons.ticket),
    ('Other', LucideIcons.moreHorizontal),
  ];

  const ExpenseCategorySelector({
    super.key,
    required this.theme,
    required this.selectedCategory,
    required this.customCategories,
    required this.onCategorySelected,
    required this.onAddCategory,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.translate('category_section_label'),
            style: AppTextStyles.caption.copyWith(
              fontSize: AppFontSizes.size10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 1.3,
            ),
            itemCount: _categories.length + customCategories.length + 1,
            itemBuilder: (context, index) {
              if (index < _categories.length) {
                final (label, icon) = _categories[index];
                return _buildGridItem(label, icon, selectedCategory == label, () {
                  onCategorySelected(selectedCategory == label ? null : label);
                });
              }
              final ci = index - _categories.length;
              if (ci < customCategories.length) {
                final cat = customCategories[ci];
                return _buildGridItem(
                  cat['name'] as String, cat['icon'] as IconData,
                  selectedCategory == cat['name'],
                  () {
                    onCategorySelected(selectedCategory == cat['name'] ? null : cat['name'] as String);
                  },
                );
              }
              return _buildAddGridItem(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(String label, IconData icon, bool selected, VoidCallback onTap) {
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.activeGreen.withValues(alpha: 0.12)
              : (isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF0F0F0)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppColors.activeGreen.withValues(alpha: 0.3)
                : (isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE5E5E5)),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected
                  ? AppColors.activeGreen
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                fontSize: AppFontSizes.size9,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected
                    ? AppColors.activeGreen
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddGridItem(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onAddCategory,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE5E5E5),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.plus,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 3),
            Text(
              context.translate('add'),
              style: AppTextStyles.caption.copyWith(
                fontSize: AppFontSizes.size9,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
