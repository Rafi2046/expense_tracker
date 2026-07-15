import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

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
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              context.translate('categories_breakdown'),
              style: TextStyle(
                fontSize: AppFontSizes.size16,
                fontWeight: FontWeight.w700,
                color: onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Text(
            suffixText,
            style: TextStyle(
              fontSize: AppFontSizes.size12,
              color: Colors.grey.shade500,
            ),
          ),
        ),
      ],
    );
  }
}
