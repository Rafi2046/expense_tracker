import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/features/tours/widgets/expense_category_icon_data.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

Future<Map<String, dynamic>?> showAddCategoryDialog(BuildContext context) async {
  IconData selectedIcon = categoryIcons.first;
  final nameController = TextEditingController();
  var searchQuery = '';

  final result = await showDialog<Map<String, dynamic>?>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.r16),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          context.translate('new_category_title'),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: AppFontSizes.size18,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: context.translate('search_icons'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.r10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.p12,
                    vertical: AppSpacing.p12,
                  ),
                ),
                onChanged: (value) {
                  setDialogState(
                    () => searchQuery = value.trim().toLowerCase(),
                  );
                },
                onSubmitted: (value) {
                  final name = value.trim();
                  if (name.isNotEmpty) {
                    Navigator.pop(ctx, {'name': name, 'icon': selectedIcon});
                  }
                },
              ),
              const SizedBox(height: 6),
              Text(
                context.translate('choose_icon'),
                style: TextStyle(
                  fontSize: AppFontSizes.size12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Builder(
                  builder: (ctx) {
                    final filtered = searchQuery.isEmpty
                        ? categoryIcons
                        : iconSearchData.entries
                              .where((e) => e.value.contains(searchQuery))
                              .map((e) => e.key)
                              .toList();
                    return GridView.builder(
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
                          onTap: () =>
                              setDialogState(() => selectedIcon = icon),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.activeGreen.withValues(
                                      alpha: 0.12,
                                    )
                                  : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.r10,
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
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.translate('cancel_button'),
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(ctx, {'name': name, 'icon': selectedIcon});
              }
            },
            child: Text(
              context.translate('add'),
              style: TextStyle(
                color: AppColors.activeGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  return result;
}
