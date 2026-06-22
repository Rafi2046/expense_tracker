import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LanguageSelectorSheet extends StatelessWidget {
  const LanguageSelectorSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LanguageSelectorSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final languages = languageProvider.supportedLanguages;
    final currentLanguage = languageProvider.currentLanguage;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 32.0),
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
                  color: Colors.grey.shade300,
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
                    color: AppColors.selectionGreenBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.translate_rounded,
                    color: AppColors.buttonColor,
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
                        style: GoogleFonts.workSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.loginTitle,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Select your preferred interface language',
                        style: GoogleFonts.workSans(
                          fontSize: 12.5,
                          color: AppColors.loginSubTitle,
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

    return GestureDetector(
      onTap: () {
        provider.changeLanguage(lang.code);
        Navigator.pop(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.selectionGreenBg : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? AppColors.activeGreen 
                : const Color(0xFFE5E7EB),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? AppColors.activeGreen.withValues(alpha: 0.05) 
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
                  style: const TextStyle(fontSize: 34),
                ),
                const SizedBox(height: 14),
                
                // Name
                Text(
                  lang.name,
                  style: GoogleFonts.workSans(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 15.5,
                    color: AppColors.loginTitle,
                  ),
                ),
                const SizedBox(height: 2),

                // Native Subtitle
                Text(
                  _getNativeName(lang.code),
                  style: GoogleFonts.workSans(
                    fontSize: 12.5,
                    color: AppColors.loginSubTitle,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            if (isSelected)
              const Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.activeGreen,
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
