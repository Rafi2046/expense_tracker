import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/models/tour.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/tours/pages/tour_dashboard_screen.dart';
import 'package:expense_tracker/features/tours/widgets/invoice_format_utils.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Premium "All Tours" bottom sheet launched from the Tours header View All action.
class AllToursSheet {
  AllToursSheet._();

  static Future<void> show(
    BuildContext context, {
    required List<Tour> tours,
    required Map<String, int> memberCounts,
    required Map<String, double> totalSpent,
  }) {
    if (tours.isEmpty) return Future.value();

    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.r16)),
      ),
      builder: (ctx) => _AllToursSheetBody(
        tours: tours,
        memberCounts: memberCounts,
        totalSpent: totalSpent,
      ),
    );
  }
}

class _AllToursSheetBody extends StatelessWidget {
  final List<Tour> tours;
  final Map<String, int> memberCounts;
  final Map<String, double> totalSpent;

  const _AllToursSheetBody({
    required this.tours,
    required this.memberCounts,
    required this.totalSpent,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.72;
    final badgeText = '${tours.length} ${context.translate('tours')}';

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.p24,
          0,
          AppSpacing.p24,
          AppSpacing.p24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.translate('all_tours'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ) ??
                        AppTextStyles.h2.copyWith(color: scheme.onSurface),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.p12,
                    vertical: AppSpacing.p4,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.r24),
                  ),
                  child: Text(
                    badgeText,
                    style: AppTextStyles.label.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: tours.length,
                itemBuilder: (context, index) {
                  final tour = tours[index];
                  final members = memberCounts[tour.id] ?? 0;
                  final spent = totalSpent[tour.id] ?? 0;
                  final memberLabel = members == 1
                      ? context.translate('member')
                      : context.translate('members');
                  final isCompleted = tour.isCompleted;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.p4,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TourDashboardScreen(tourId: tour.id),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundColor: scheme.primaryContainer,
                      child: Icon(
                        LucideIcons.mapPinned,
                        size: 20,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    title: Text(
                      tour.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.p4),
                      child: Text(
                        '$members $memberLabel  •  ${formatAmount(spent, tour.currency)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.p8,
                        vertical: AppSpacing.p4,
                      ),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? scheme.surfaceContainerHighest
                            : AppColors.activeGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppSpacing.r24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCompleted
                                  ? scheme.onSurfaceVariant
                                  : AppColors.activeGreen,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s4),
                          Text(
                            isCompleted
                                ? context.translate('completed')
                                : context.translate('active'),
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isCompleted
                                  ? scheme.onSurfaceVariant
                                  : AppColors.activeGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
