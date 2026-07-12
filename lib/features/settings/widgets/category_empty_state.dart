import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

class CategoryEmptyState extends StatelessWidget {
  final bool isDark;

  const CategoryEmptyState({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AppImages.categoriesIcon,
            width: 100,
            height: 100,
          ),
          const SizedBox(height: 8),
          Text(
            context.translate('no_categories_yet'),
            style: AppTextStyles.body.copyWith(
              fontFamily: GoogleFonts.workSans().fontFamily,
              color: isDark
                  ? Colors.grey.shade500
                  : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
