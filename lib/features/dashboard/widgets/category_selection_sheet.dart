import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/profile_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';



class CategorySelectionSheetContent extends StatelessWidget {
  final Function(String) onCategorySelected;

  const CategorySelectionSheetContent({
    super.key,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final filteredCategories = provider.filteredCategories;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.p16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(AppSpacing.r12),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),

            Text(
              context.translate('select_business_category'),
            style: AppTextStyles.h1.copyWith(fontWeight: FontWeight.w800,
              color: theme.textTheme.titleLarge?.color),
          ),
          const SizedBox(height: AppSpacing.s16),

          TextField(
            style: AppTextStyles.body.copyWith(color: theme.textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              hintText: context.translate('search_category'),
              hintStyle: TextStyle(color: theme.textTheme.bodySmall?.color),
              prefixIcon: Icon(
                LucideIcons.search,
                color: theme.textTheme.bodySmall?.color,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.p12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.r8),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.r8),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.r8),
                borderSide: const BorderSide(
                  color: AppColors.activeGreen,
                  width: 2,
                ),
              ),
              fillColor: theme.cardColor,
              filled: true,
            ),
            onChanged: (val) {
              provider.setCategorySearchQuery(val);
            },
          ),
          const SizedBox(height: AppSpacing.s16),

          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredCategories.length,
              itemBuilder: (context, index) {
                final cat = filteredCategories[index];
                final isSelected = cat == provider.selectedCategory;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    cat,
                    style: AppTextStyles.body.copyWith(color: theme.textTheme.bodyLarge?.color),
                  ),
                  trailing: Icon(
                    isSelected
                        ? LucideIcons.circleDot
                        : LucideIcons.circle,
                    color: isSelected
                        ? AppColors.activeGreen
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.3)
                            : Colors.grey.shade300),
                  ),
                  onTap: () {
                    provider.setSelectedCategory(cat);

                    Future.delayed(const Duration(milliseconds: 200), () {
                      onCategorySelected(cat);
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
