import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/providers/tour_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/tours/utils/tour_export_service.dart';
import 'package:expense_tracker/features/tours/utils/tour_invoice_generator.dart';
import 'package:expense_tracker/features/tours/pages/tour_invoice_screen.dart';
import 'package:expense_tracker/core/utils/debt_simplifier.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TourExportOptionsSheet extends StatelessWidget {
  final String tourId;

  const TourExportOptionsSheet({super.key, required this.tourId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TourProvider>();
    final tour = provider.selectedTour;
    if (tour == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;

    final participants = provider.participants;
    final expenses = provider.expenses;
    final netBalances = provider.netBalances(tour.id);
    final totalSpent = provider.totalSpent(tour.id);
    final totalOutstanding = provider.totalOutstanding(tour.id);
    final settlements = simplifyDebts(netBalances);

    final bottomInset = MediaQuery.of(context).padding.bottom;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.r24),
          topRight: Radius.circular(AppSpacing.r24),
        ),
        border: Border.all(
          color: scheme.outline,
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.p24,
          AppSpacing.p12,
          AppSpacing.p24,
          viewInsets + bottomInset + AppSpacing.p8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                Center(
                  child: Container(
                    width: AppSpacing.w40,
                    height: AppSpacing.h4,
                    margin: const EdgeInsets.only(bottom: AppSpacing.s24),
                    decoration: BoxDecoration(
                      color: scheme.outlineVariant,
                      borderRadius: BorderRadius.circular(AppSpacing.r8),
                    ),
                  ),
                ),
                Text(
                  context.translate('export_report_title'),
                  style: AppTextStyles.h1.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  context.translate('export_report_subtitle'),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),
                _ExportOptionTile(
                  icon: LucideIcons.image,
                  title: context.translate('share_balances_image'),
                  subtitle: context.translate('share_balances_image_desc'),
                  gradientColors: [scheme.primary, scheme.secondary],
                  onTap: () {
                    Navigator.pop(context);
                    TourExportService.shareReport(context, tourId);
                  },
                ),
                const SizedBox(height: AppSpacing.s12),
                _ExportOptionTile(
                  icon: LucideIcons.fileText,
                  title: context.translate('view_detailed_invoice_title'),
                  subtitle: context.translate('view_detailed_invoice_desc'),
                  gradientColors: [scheme.secondary, scheme.tertiary],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TourInvoiceScreen(tourId: tour.id),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.s12),
                _ExportOptionTile(
                  icon: LucideIcons.file,
                  title: context.translate('download_pdf_invoice_title'),
                  subtitle: context.translate('download_pdf_invoice_desc'),
                  gradientColors: [scheme.error, scheme.errorContainer],
                  onTap: () {
                    Navigator.pop(context);
                    TourInvoiceGenerator.generateAndShare(
                      tour: tour,
                      participants: participants,
                      expenses: expenses,
                      settlements: settlements,
                      totalSpent: totalSpent,
                      totalOutstanding: totalOutstanding,
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.s12),
              ],
            ),
          ),
    );
  }
}

class _ExportOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _ExportOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.r8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.p16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppSpacing.r8),
            border: Border.all(
              color: scheme.outline,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: AppSpacing.w48,
                height: AppSpacing.h48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.r16),
                ),
                child: Icon(icon, color: scheme.onPrimary, size: 22),
              ),
              const SizedBox(width: AppSpacing.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.reportTileTitle.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.h4),
                    Text(
                      subtitle,
                      style: AppTextStyles.label.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                color: scheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
