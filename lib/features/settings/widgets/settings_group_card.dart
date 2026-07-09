import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class SettingsGroupCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsGroupCard({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF1F1F1);

    final List<Widget> items = [];
    for (int i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i < children.length - 1) {
        items.add(
          Divider(
            color: dividerColor,
            height: 1,
            indent: 52,
            endIndent: 14,
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group Header Title
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.caption.copyWith(
              fontSize: AppFontSizes.size10,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFFB39DDB) : const Color(0xFF6A53A1),
              letterSpacing: 1.2,
            ),
          ),
        ),

        // Group Card Container
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: dividerColor,
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Column(
              children: items,
            ),
          ),
        ),
      ],
    );
  }
}
