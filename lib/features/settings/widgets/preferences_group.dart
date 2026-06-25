import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/settings/pages/currency_selection_screen.dart';
import 'package:expense_tracker/features/settings/widgets/language_selector_sheet.dart';
import 'package:expense_tracker/features/settings/widgets/settings_group_card.dart';
import 'package:expense_tracker/features/settings/widgets/settings_option_row.dart';
import 'package:expense_tracker/features/settings/widgets/theme_dropdown_row.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          icon: Icons.payments_rounded,
          iconBgColor: const Color(0xFFE0F2F1),
          iconColor: const Color(0xFF00796B),
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
          icon: Icons.language_rounded,
          iconBgColor: const Color(0xFFFFFDE7),
          iconColor: const Color(0xFFFBC02D),
          title: context.translate('change_language'),
          trailingText: '${currentLanguage.flag} ${currentLanguage.name}',
          trailingIcon: Icons.keyboard_arrow_down_rounded,
          onTap: () {
            LanguageSelectorSheet.show(context);
          },
        ),
      ],
    );
  }
}
