import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/settings/pages/currency_selection_screen.dart';
import 'package:expense_tracker/features/settings/widgets/language_selector_sheet.dart';
import 'package:expense_tracker/features/settings/widgets/settings_group_card.dart';
import 'package:expense_tracker/features/settings/widgets/settings_option_row.dart';
import 'package:expense_tracker/features/settings/widgets/theme_dropdown_row.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PreferencesGroup extends StatelessWidget {
  final Function(String) onSnackBar;

  const PreferencesGroup({super.key, required this.onSnackBar});

  @override
  Widget build(BuildContext context) {
    final currencyProvider = context.watch<CurrencyProvider>();
    final selectedCurrency = currencyProvider.selectedCurrency;
    final languageProvider = context.watch<LanguageProvider>();
    final currentLanguage = languageProvider.currentLanguage;

    return SettingsGroupCard(
      title: context.translate('preferences'),
      children: [
        SettingsOptionRow(
          icon: LucideIcons.creditCard,
          title: context.translate('currency'),
          trailingText: '${selectedCurrency.code} (${selectedCurrency.symbol})',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CurrencySelectionScreen(),
              ),
            );
          },
        ),
        ThemeDropdownRow(
          onSnackBar: onSnackBar,
        ),
        SettingsOptionRow(
          icon: LucideIcons.languages,
          title: context.translate('change_language'),
          trailingText: '${currentLanguage.flag} ${currentLanguage.name}',
          trailingIcon: LucideIcons.chevronDown,
          onTap: () {
            LanguageSelectorSheet.show(context);
          },
        ),
      ],
    );
  }
}
