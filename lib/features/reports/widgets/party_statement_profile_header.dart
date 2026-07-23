import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'party_statement_contact_chip_data.dart';
import 'party_statement_contact_details_grid.dart';
import 'party_statement_profile_avatar.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


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

    final initial = partyName.isNotEmpty ? String.fromCharCode(partyName.runes.first).toUpperCase() : '?';

    final List<ContactChipData> contactDetails = [];
    if (partyItem != null) {
      if (partyItem.phone != null && partyItem.phone!.trim().isNotEmpty) {
        contactDetails.add(ContactChipData(
          icon: LucideIcons.phoneCall,
          label: partyItem.phone!,
          title: context.translate('phone'),
        ));
      }
      if (partyItem.email != null && partyItem.email!.trim().isNotEmpty) {
        contactDetails.add(ContactChipData(
          icon: LucideIcons.mail,
          label: partyItem.email!,
          title: context.translate('email'),
        ));
      }
      if (partyItem.address != null && partyItem.address!.trim().isNotEmpty) {
        contactDetails.add(ContactChipData(
          icon: LucideIcons.mapPin,
          label: partyItem.address!,
          title: context.translate('party_address'),
        ));
      }
      if (partyItem.vat != null && partyItem.vat!.trim().isNotEmpty) {
        contactDetails.add(ContactChipData(
          icon: LucideIcons.fileText,
          label: partyItem.vat!,
          title: context.translate('vat_number'),
        ));
      }
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.r24),
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
          ProfileAvatarSection(
            partyName: partyName,
            initial: initial,
          ),
          ContactDetailsGrid(contactDetails: contactDetails),
        ],
      ),
    );
  }
}
