import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';



class CategoryBreakdownHeader extends StatelessWidget {
  final String suffixText;

  const CategoryBreakdownHeader({super.key, required this.suffixText});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6A53A1), Color(0xFF32235B)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.r8),
              ),
            ),
            const SizedBox(width: AppSpacing.s8),
            Text(
              context.translate('categories_breakdown'),
              style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700,
                color: onSurface),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s4),
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.p12),
          child: Text(
            suffixText,
            style: AppTextStyles.label.copyWith(color: Colors.grey.shade500),
          ),
        ),
      ],
    );
  }
}
