import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/features/tours/widgets/expense_category_icon_data.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';


Future<Map<String, dynamic>?> showAddCategoryDialog(BuildContext context) async {
  IconData selectedIcon = categoryIcons.first;
  final nameController = TextEditingController();
  var searchQuery = '';
  var hasName = false;

  final result = await showDialog<Map<String, dynamic>?>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          scrollable: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.r16),
          ),
          backgroundColor: Theme.of(ctx).colorScheme.surface,
          title: Text(
            context.translate('new_category_title'),
            style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w600),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: context.translate('category_name'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.r12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.p12,
                      vertical: AppSpacing.p12,
                    ),
                  ),
                  onChanged: (value) {
                    setDialogState(() {
                      searchQuery = value.trim().toLowerCase();
                      hasName = value.trim().isNotEmpty;
                    });
                  },
                  onSubmitted: (value) {
                    final name = value.trim();
                    if (name.isNotEmpty) {
                      Navigator.pop(ctx, {'name': name, 'icon': selectedIcon});
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  context.translate('choose_icon'),
                  style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey.shade400 : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                Builder(
                    builder: (ctx) {
                      final filtered = searchQuery.isEmpty
                          ? categoryIcons
                          : iconSearchData.entries
                                .where((e) => e.value.contains(searchQuery))
                                .map((e) => e.key)
                                .toList();
                      return GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6,
                              crossAxisSpacing: 6,
                              mainAxisSpacing: 6,
                            ),
                        itemCount: filtered.length,
                        itemBuilder: (ctx, i) {
                          final icon = filtered[i];
                          final isSelected = icon == selectedIcon;
                          return GestureDetector(
                            onTap: () {
                              final name = iconSearchData[icon]?.split(' ').first ?? '';
                              nameController.text = name;
                              nameController.selection = TextSelection.fromPosition(
                                TextPosition(offset: name.length),
                              );
                              setDialogState(() {
                                selectedIcon = icon;
                                hasName = name.isNotEmpty;
                                searchQuery = '';
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.activeGreen.withValues(
                                        alpha: 0.12,
                                      )
                                    : (isDark
                                        ? Colors.grey.shade800
                                        : const Color(0xFFF3F4F6)),
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.r12,
                                ),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.activeGreen
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                icon,
                                size: 22,
                                color: isSelected
                                    ? AppColors.activeGreen
                                    : (isDark
                                        ? Colors.grey.shade400
                                        : const Color(0xFF6B7280)),
                              ),
                            ),
                          );
                        },
                      );
                      },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                context.translate('cancel_button'),
                style: TextStyle(color: isDark ? Colors.grey.shade400 : const Color(0xFF6B7280)),
              ),
            ),
            TextButton(
              onPressed: hasName
                  ? () => Navigator.pop(ctx, {'name': nameController.text.trim(), 'icon': selectedIcon})
                  : null,
              child: Text(
                context.translate('add'),
                style: TextStyle(
                  color: hasName
                      ? AppColors.activeGreen
                      : (isDark ? Colors.grey.shade600 : const Color(0xFF9CA3AF)),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    ),
  );

  return result;
}
