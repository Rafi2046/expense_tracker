import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';

class PartySelectSheet extends StatefulWidget {
  final String? selectedPartyName;

  const PartySelectSheet({
    super.key,
    this.selectedPartyName,
  });

  static Future<String?> show(
    BuildContext context, {
    String? selectedPartyName,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PartySelectSheet(
        selectedPartyName: selectedPartyName,
      ),
    );
  }

  @override
  State<PartySelectSheet> createState() => _PartySelectSheetState();
}

class _PartySelectSheetState extends State<PartySelectSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].runes.isNotEmpty ? String.fromCharCode(parts[0].runes.first).toUpperCase() : '';
    }
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final debtProvider = context.watch<DebtProvider>();
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Group items by name to get unique parties
    final Map<String, DebtItem> uniqueParties = {};
    for (var item in debtProvider.items) {
      // Keep the item with the phone number if available
      if (!uniqueParties.containsKey(item.name) ||
          (uniqueParties[item.name]?.phone == null && item.phone != null)) {
        uniqueParties[item.name] = item;
      }
    }

    // Filter by search query
    final filteredParties = uniqueParties.values.where((party) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final hasNameMatch = party.name.toLowerCase().contains(q);
      final hasPhoneMatch = party.phone?.toLowerCase().contains(q) ?? false;
      return hasNameMatch || hasPhoneMatch;
    }).toList();

    return Container(
      height: mediaQuery.size.height * 0.75,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.r24),
          topRight: Radius.circular(AppSpacing.r24),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: AppSpacing.p8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(AppSpacing.r12),
              ),
            ),
          ),

          // Header row
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.p16, right: AppSpacing.p16, top: AppSpacing.p12, bottom: AppSpacing.p8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    context.translate('select_party_to_view_report'),
                    style: AppTextStyles.h3.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                TextButton(
                  onPressed: () => Navigator.pop(context, 'clear_selection'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p8, vertical: AppSpacing.p4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    context.translate('clear').toUpperCase(),
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.activeRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: theme.dividerTheme.color ?? const Color(0xFFF1F1F1), height: 1),

          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16, vertical: AppSpacing.p8),
            child: TextFormField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              style: AppTextStyles.body.copyWith(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: context.translate('search_parties'),
                hintStyle: AppTextStyles.body.copyWith(color: isDark ? Colors.white30 : Colors.grey.shade400),
                prefixIcon: Icon(LucideIcons.search, color: isDark ? Colors.white30 : Colors.grey.shade400, size: AppSpacing.s16),
                filled: true,
                fillColor: isDark ? theme.colorScheme.onSurface.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.p8, horizontal: AppSpacing.p16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.r12),
                  borderSide: BorderSide(color: theme.dividerTheme.color ?? Colors.grey.shade100, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.r12),
                  borderSide: BorderSide(color: theme.dividerTheme.color ?? Colors.grey.shade100, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.r12),
                  borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
                ),
              ),
            ),
          ),

          // Parties list
          Expanded(
            child: filteredParties.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.users, color: isDark ? Colors.white24 : Colors.grey.shade300, size: 48),
                        const SizedBox(height: AppSpacing.s12),
                        Text(
                          context.translate('no_parties_found'),
                          style: AppTextStyles.reportTileTitle.copyWith(
                            color: isDark ? Colors.white60 : Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16, vertical: AppSpacing.p8),
                    itemCount: filteredParties.length,
                    separatorBuilder: (context, index) => Divider(
                      color: theme.dividerTheme.color ?? const Color(0xFFF8FAFC),
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final party = filteredParties[index];
                      final isSelected = widget.selectedPartyName == party.name;

                      return ListTile(
                        onTap: () => Navigator.pop(context, party.name),
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.p8, vertical: AppSpacing.p4),
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isDark ? theme.colorScheme.onSurface.withValues(alpha: 0.08) : const Color(0xFFF1F2F4),
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: theme.primaryColor, width: 1.5)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              _getInitials(party.name),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          party.name,
                          style: AppTextStyles.bodyBold.copyWith(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          party.phone ?? context.translate('no_phone_number'),
                          style: AppTextStyles.reportTransactionSubtitle.copyWith(
                            color: isDark ? Colors.white60 : Colors.grey.shade500,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                LucideIcons.checkCircle,
                                color: theme.primaryColor,
                                size: 18,
                              )
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
