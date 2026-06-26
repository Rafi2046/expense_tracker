import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PartyStatementProfileHeader extends StatelessWidget {
  const PartyStatementProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final debtProvider = context.watch<DebtProvider>();
    final partyName = reportsProvider.selectedPartyNameForStatement;
    final theme = Theme.of(context);

    if (partyName == null) return const SizedBox.shrink();

    final partyItem = debtProvider.items.cast<DebtItem?>().firstWhere(
      (d) => d!.name == partyName,
      orElse: () => null,
    );

    final initial = partyName.isNotEmpty ? partyName[0].toUpperCase() : '?';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  initial,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  partyName,
                  style: AppTextStyles.reportTransactionTitle.copyWith(
                    fontSize: 17,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          if (partyItem != null) ...[
            const SizedBox(height: 14),
            Divider(height: 1, color: theme.dividerColor),
            const SizedBox(height: 10),
            if (partyItem.phone != null && partyItem.phone!.trim().isNotEmpty)
              _ContactRow(
                icon: Symbols.call,
                label: partyItem.phone!,
                theme: theme,
              ),
            if (partyItem.email != null && partyItem.email!.trim().isNotEmpty)
              _ContactRow(
                icon: Symbols.mail,
                label: partyItem.email!,
                theme: theme,
              ),
            if (partyItem.address != null && partyItem.address!.trim().isNotEmpty)
              _ContactRow(
                icon: Symbols.location_on,
                label: partyItem.address!,
                theme: theme,
              ),
            if (partyItem.vat != null && partyItem.vat!.trim().isNotEmpty)
              _ContactRow(
                icon: Symbols.description,
                label: partyItem.vat!,
                theme: theme,
              ),
          ],
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final dynamic icon;
  final String label;
  final ThemeData theme;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.reportTransactionSubtitle.copyWith(
                fontSize: 12.5,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
