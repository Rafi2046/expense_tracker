import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LanguageSelectorSheet extends StatelessWidget {
  const LanguageSelectorSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: false,
      backgroundColor: Colors.transparent,
      builder: (context) => const LanguageSelectorSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final languages = languageProvider.supportedLanguages;
    final currentLanguage = languageProvider.currentLanguage;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconBgColor = isDark ? const Color(0xFF10B981).withValues(alpha: 0.15) : AppColors.selectionGreenBg;
    final iconColor = isDark ? const Color(0xFF10B981) : AppColors.buttonColor;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        padding: EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 32.0 + MediaQuery.of(context).padding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Drag Handle
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Header Section with premium layout
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.languages,
                    color: iconColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.translate('change_language'),
                        style: AppTextStyles.h2.copyWith(color: theme.colorScheme.onSurface),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.translate('language_select_subtitle'),
                        style: AppTextStyles.label.copyWith(
                          color: isDark ? Colors.grey.shade400 : AppColors.loginSubTitle,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 2x2 Language Selection Cards
            Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildLanguageCard(context, languages[0], currentLanguage, languageProvider)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildLanguageCard(context, languages[1], currentLanguage, languageProvider)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildLanguageCard(context, languages[2], currentLanguage, languageProvider)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildLanguageCard(context, languages[3], currentLanguage, languageProvider)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard(
    BuildContext context,
    AppLanguage lang,
    AppLanguage currentLanguage,
    LanguageProvider provider,
  ) {
    final isSelected = currentLanguage.code == lang.code;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeGreenColor = isDark ? const Color(0xFF10B981) : AppColors.activeGreen;
    final cardBg = isSelected 
        ? (isDark ? const Color(0xFF1B2A22) : AppColors.selectionGreenBg)
        : theme.cardColor;
    final borderColor = isSelected 
        ? activeGreenColor 
        : (isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB));

    return GestureDetector(
      onTap: () async {
        await provider.changeLanguage(lang.code, context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? activeGreenColor.withValues(alpha: 0.05) 
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Flag display
                Text(
                  lang.flag,
                  style: const TextStyle(fontSize: AppFontSizes.size36),
                ),
                const SizedBox(height: 14),
                
                // Name
                Text(
                  lang.name,
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),

                // Native Subtitle
                Text(
                  _getNativeName(lang.code),
                  style: AppTextStyles.label.copyWith(
                    color: isDark ? Colors.grey.shade400 : AppColors.loginSubTitle,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  LucideIcons.checkCircle,
                  color: activeGreenColor,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getNativeName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'bn':
        return 'বাংলা';
      case 'hi':
        return 'हिन्दी';
      case 'ur':
        return 'اردو';
      default:
        return '';
    }
  }
}
