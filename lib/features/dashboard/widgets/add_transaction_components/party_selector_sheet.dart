import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

String _getInitials(String name) {
  if (name.trim().isEmpty) return '?';
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length == 1) return parts[0].runes.isNotEmpty ? String.fromCharCode(parts[0].runes.first).toUpperCase() : '';
  return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
}

class PartySelectorSheet extends StatelessWidget {
  final Map<String, DebtItem> uniqueParties;
  final String? selectedPartyName;
  final bool isIncome;
  final ValueChanged<String> onSelect;
  final VoidCallback onClear;

  const PartySelectorSheet({
    super.key,
    required this.uniqueParties,
    required this.selectedPartyName,
    required this.isIncome,
    required this.onSelect,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final partyNames = uniqueParties.keys.toList()..sort();
    final accentColor = isIncome ? theme.primaryColor : AppColors.activeRed;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.h16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.translate('link_to_party_optional'),
                style: TextStyle(
                  fontSize: AppFontSizes.size18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (selectedPartyName != null)
                TextButton(
                  onPressed: onClear,
                  child: Text(
                    context.translate('clear'),
                    style: TextStyle(
                      color: AppColors.activeRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.h12),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.40,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: partyNames.length,
              separatorBuilder: (_, _) => Divider(
                color: theme.dividerTheme.color ?? const Color(0xFFF5F5F5),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final name = partyNames[index];
                final party = uniqueParties[name]!;
                final initials = _getInitials(name);
                final isSelected = selectedPartyName == name;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: isSelected
                        ? accentColor
                        : (isDark ? Colors.white12 : Colors.grey.shade100),
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontSize: AppFontSizes.size13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white60 : Colors.black54),
                      ),
                    ),
                  ),
                  title: Text(
                    name,
                    style: TextStyle(
                      fontSize: AppFontSizes.size15,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  subtitle: party.phone != null
                      ? Text(
                          party.phone!,
                          style: TextStyle(
                            fontSize: AppFontSizes.size12,
                            color: isDark ? Colors.white38 : Colors.grey,
                          ),
                        )
                      : null,
                  trailing: isSelected
                      ? Icon(LucideIcons.checkCircle, color: accentColor)
                      : null,
                  onTap: () => onSelect(name),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.h8),
        ],
      ),
    );
  }
}
