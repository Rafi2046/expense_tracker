import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:flutter/material.dart';

class SortBySheet extends StatelessWidget {
  final ReportSortOption currentOption;

  const SortBySheet({
    super.key,
    required this.currentOption,
  });

  static Future<ReportSortOption?> show(
    BuildContext context, {
    required ReportSortOption currentOption,
  }) {
    return showModalBottomSheet<ReportSortOption>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SortBySheet(currentOption: currentOption),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Text(
                'Sort By:',
                style: AppTextStyles.dialogTitle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(color: Color(0xFFF1F1F1)),
            _buildOption(
              context: context,
              title: 'Latest',
              option: ReportSortOption.latest,
              icon: Icons.swap_vert_rounded,
            ),
            _buildOption(
              context: context,
              title: 'Oldest',
              option: ReportSortOption.oldest,
              icon: Icons.swap_vert_rounded,
            ),
            _buildOption(
              context: context,
              title: 'Amount: High to Low',
              option: ReportSortOption.amountHighToLow,
              icon: Icons.sort_rounded,
            ),
            _buildOption(
              context: context,
              title: 'Amount: Low to High',
              option: ReportSortOption.amountLowToHigh,
              icon: Icons.sort_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required String title,
    required ReportSortOption option,
    required IconData icon,
  }) {
    final isSelected = currentOption == option;

    return InkWell(
      onTap: () => Navigator.pop(context, option),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.grey.shade600,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.reportTileTitle.copyWith(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.black87 : Colors.grey.shade700,
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.activeGreen : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.activeGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
