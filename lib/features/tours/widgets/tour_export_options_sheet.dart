import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/providers/tour_provider.dart';
import 'package:expense_tracker/features/tours/utils/tour_export_service.dart';
import 'package:expense_tracker/features/tours/utils/tour_invoice_generator.dart';
import 'package:expense_tracker/features/tours/pages/tour_invoice_screen.dart';
import 'package:expense_tracker/core/utils/debt_simplifier.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class TourExportOptionsSheet extends StatelessWidget {
  final String tourId;

  const TourExportOptionsSheet({super.key, required this.tourId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TourProvider>();
    final tour = provider.selectedTour;
    if (tour == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D3D) : const Color(0xFFF1F5F9),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 12, 24, viewInsets + bottomInset + 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Export Report',
                  style: TextStyle(
                    fontSize: AppFontSizes.size20,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose how to share your tour details',
                  style: TextStyle(
                    fontSize: AppFontSizes.size13,
                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 20),
                _ExportOptionTile(
                  icon: Icons.image_rounded,
                  title: 'Share Balances Image',
                  subtitle: 'A snapshot showing who owes whom',
                  gradientColors: const [Color(0xFF059669), Color(0xFF0F766E)],
                  onTap: () {
                    Navigator.pop(context);
                    TourExportService.shareReport(context, tourId);
                  },
                ),
                const SizedBox(height: 12),
                _ExportOptionTile(
                  icon: Icons.description_rounded,
                  title: 'View Detailed Invoice',
                  subtitle: 'Full report with category breakdown & ledger table',
                  gradientColors: const [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TourInvoiceScreen(tourId: tour.id),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _ExportOptionTile(
                  icon: Icons.picture_as_pdf_rounded,
                  title: 'Download Detailed Invoice (PDF)',
                  subtitle: 'Export as PDF file to share or print',
                  gradientColors: const [Color(0xFFDC2626), Color(0xFFB91C1C)],
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
                const SizedBox(height: 12),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? const Color(0xFF2D2D3D) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: AppFontSizes.size15,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: AppFontSizes.size12,
                        color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? const Color(0xFF4B5563) : const Color(0xFF9CA3AF),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
