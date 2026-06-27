import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecentActivityItem {
  final String title;
  final String category;
  final String timeText;
  final double amount;
  final bool isIncome;
  final IconData icon;

  RecentActivityItem({
    required this.title,
    required this.category,
    required this.timeText,
    required this.amount,
    required this.isIncome,
    required this.icon,
  });
}

class DashboardRecentActivity extends StatelessWidget {
  final List<RecentActivityItem> items;
  final VoidCallback onViewAllTap;
  final Function(RecentActivityItem) onItemTap;

  const DashboardRecentActivity({
    super.key,
    required this.items,
    required this.onViewAllTap,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row — outside the card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.translate('recent_activity'),
                style: GoogleFonts.workSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              GestureDetector(
                onTap: onViewAllTap,
                behavior: HitTestBehavior.opaque,
                child: Text(
                  context.translate('view_all'),
                  style: GoogleFonts.workSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.activeGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: Theme.of(context).dividerTheme.color ?? const Color(0xFFF0F0F0),
              width: 1,
            ),
          ),
          child: Column(children: _buildListItems(context)),
        ),
      ],
    );
  }

  List<Widget> _buildListItems(BuildContext context) {
    final List<Widget> widgets = [];
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final isInc = item.isIncome;

      widgets.add(
        InkWell(
          onTap: () => onItemTap(item),
          borderRadius: BorderRadius.vertical(
            top: i == 0 ? const Radius.circular(14) : Radius.zero,
            bottom: i == items.length - 1
                ? const Radius.circular(14)
                : Radius.zero,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 11.0,
            ),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isInc
                        ? AppColors.activeGreen.withValues(alpha: 0.08)
                        : (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color(0xFFF3F4F6)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    color: isInc
                        ? AppColors.activeGreen
                        : (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : const Color(0xFF4A5568)),
                    size: 17,
                  ),
                ),
                const SizedBox(width: 12),

                // Title + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: GoogleFonts.workSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${context.translate(item.category.toLowerCase())}  •  ${item.timeText}',
                        style: GoogleFonts.workSans(
                          fontSize: 10.5,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                // Amount
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isInc ? '+' : '-',
                      style: GoogleFonts.workSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isInc
                            ? AppColors.activeGreen
                            : AppColors.expensePink,
                      ),
                    ),
                    PrivacyMaskedText(
                      amount: item.amount,
                      style: GoogleFonts.workSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isInc
                            ? AppColors.activeGreen
                            : AppColors.expensePink,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      if (i < items.length - 1) {
        widgets.add(
          Divider(
            color: Theme.of(context).dividerTheme.color ?? const Color(0xFFF1F1F1),
            height: 1,
            indent: 62,
            endIndent: 14,
          ),
        );
      }
    }
    return widgets;
  }
}
