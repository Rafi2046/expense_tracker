import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PartyStatementProfileHeader extends StatelessWidget {
  const PartyStatementProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final debtProvider = context.watch<DebtProvider>();
    final partyName = reportsProvider.selectedPartyNameForStatement;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    if (partyName == null) return const SizedBox.shrink();

    final partyItem = debtProvider.items.cast<DebtItem?>().firstWhere(
      (d) => d!.name == partyName,
      orElse: () => null,
    );

    final initial = partyName.isNotEmpty ? partyName[0].toUpperCase() : '?';

    // Collect available contact details for the grid
    final List<_ContactChipData> contactDetails = [];
    if (partyItem != null) {
      if (partyItem.phone != null && partyItem.phone!.trim().isNotEmpty) {
        contactDetails.add(_ContactChipData(
          icon: LucideIcons.phoneCall,
          label: partyItem.phone!,
          title: 'Phone',
        ));
      }
      if (partyItem.email != null && partyItem.email!.trim().isNotEmpty) {
        contactDetails.add(_ContactChipData(
          icon: LucideIcons.mail,
          label: partyItem.email!,
          title: 'Email',
        ));
      }
      if (partyItem.address != null && partyItem.address!.trim().isNotEmpty) {
        contactDetails.add(_ContactChipData(
          icon: LucideIcons.mapPin,
          label: partyItem.address!,
          title: 'Address',
        ));
      }
      if (partyItem.vat != null && partyItem.vat!.trim().isNotEmpty) {
        contactDetails.add(_ContactChipData(
          icon: LucideIcons.fileText,
          label: partyItem.vat!,
          title: 'VAT / Tax ID',
        ));
      }
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.35)
                : primaryColor.withValues(alpha: 0.08),
            blurRadius: 32,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.18)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Avatar & Name Section ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              children: [
                // Glowing avatar ring
                Container(
                  padding: const EdgeInsets.all(3.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        primaryColor.withValues(alpha: 0.6),
                        primaryColor.withValues(alpha: 0.15),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.25),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 34,
                    backgroundColor: isDark
                        ? primaryColor.withValues(alpha: 0.15)
                        : primaryColor.withValues(alpha: 0.08),
                    child: Text(
                      initial,
                      style: AppTextStyles.reportLargeValue.copyWith(
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Party Name
                Text(
                  partyName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -0.3,
                    height: 1.25,
                  ),
                ),

                // Subtle "Party Account" label
                const SizedBox(height: 4),
                Text(
                  'Party Account',
                  style: AppTextStyles.label.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),

          // ── Contact Details Grid ──
          if (contactDetails.isNotEmpty) ...[
            // Soft gradient divider instead of a harsh line
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      theme.colorScheme.onSurface.withValues(alpha: 0.07),
                      theme.colorScheme.onSurface.withValues(alpha: 0.07),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.2, 0.8, 1.0],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Use 2-column grid if we have enough width, else single column
                  final useTwoColumns = constraints.maxWidth > 300;

                  if (useTwoColumns) {
                    // Build rows of 2 chips each
                    final List<Widget> rows = [];
                    for (int i = 0; i < contactDetails.length; i += 2) {
                      rows.add(
                        Row(
                          children: [
                            Expanded(
                              child: _ContactChip(
                                data: contactDetails[i],
                                primaryColor: primaryColor,
                                theme: theme,
                                isDark: isDark,
                              ),
                            ),
                            if (i + 1 < contactDetails.length) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: _ContactChip(
                                  data: contactDetails[i + 1],
                                  primaryColor: primaryColor,
                                  theme: theme,
                                  isDark: isDark,
                                ),
                              ),
                            ] else
                              const Expanded(child: SizedBox.shrink()),
                          ],
                        ),
                      );
                      if (i + 2 < contactDetails.length) {
                        rows.add(const SizedBox(height: 10));
                      }
                    }
                    return Column(children: rows);
                  } else {
                    // Single column fallback
                    return Column(
                      children: contactDetails
                          .map((data) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _ContactChip(
                                  data: data,
                                  primaryColor: primaryColor,
                                  theme: theme,
                                  isDark: isDark,
                                ),
                              ))
                          .toList(),
                    );
                  }
                },
              ),
            ),
          ] else
            const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Data holder for contact chips ──
class _ContactChipData {
  final IconData icon;
  final String label;
  final String title;

  const _ContactChipData({
    required this.icon,
    required this.label,
    required this.title,
  });
}

// ── Premium Contact Chip Widget ──
class _ContactChip extends StatelessWidget {
  final _ContactChipData data;
  final Color primaryColor;
  final ThemeData theme;
  final bool isDark;

  const _ContactChip({
    required this.data,
    required this.primaryColor,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.onSurface.withValues(alpha: 0.05)
            : primaryColor.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? theme.colorScheme.onSurface.withValues(alpha: 0.07)
              : primaryColor.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon badge
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              data.icon,
              size: 17,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 10),
          // Label text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.title,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: AppFontSizes.size10,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
