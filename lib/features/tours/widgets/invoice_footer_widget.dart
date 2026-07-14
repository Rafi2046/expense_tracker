import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class InvoiceFooterWidget extends StatelessWidget {
  const InvoiceFooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.wallet, size: 13, color: Colors.grey.shade400),
          const SizedBox(width: 6),
          Text(
            'Generated via BudgetMint',
            style: AppTextStyles.caption.copyWith(
              fontSize: AppFontSizes.size9,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
