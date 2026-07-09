import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class ThemeDropdownRow extends StatefulWidget {
  final Function(String) onSnackBar;

  const ThemeDropdownRow({super.key, required this.onSnackBar});

  @override
  State<ThemeDropdownRow> createState() => _ThemeDropdownRowState();
}

class _ThemeDropdownRowState extends State<ThemeDropdownRow> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final currentMode = themeProvider.themeMode;
    final isDark = theme.brightness == Brightness.dark;

    final themeLightLabel = context.translate('theme_light');
    final themeDarkLabel = context.translate('theme_dark');
    final themeSystemLabel = context.translate('theme_system');

    // Get current theme label
    String currentThemeLabel;
    switch (currentMode) {
      case ThemeMode.light:
        currentThemeLabel = themeLightLabel;
        break;
      case ThemeMode.dark:
        currentThemeLabel = themeDarkLabel;
        break;
      case ThemeMode.system:
        currentThemeLabel = themeSystemLabel;
        break;
    }

    return Column(
      children: [
        // Main expandable row header
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                // Squircle moon icon
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE8EAF6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Symbols.dark_mode,
                    color: isDark ? Colors.white70 : const Color(0xFF3F51B5),
                    size: 14,
                  ),
                ),
                const SizedBox(width: 10),
                
                // Title
                Expanded(
                  child: Text(
                    context.translate('Change Theme'),
                    style: GoogleFonts.workSans(
                  fontSize: AppFontSizes.size12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),

                // Trailing text showing selected theme mode, only when collapsed
                if (!_isExpanded) ...[
                  Text(
                    currentThemeLabel,
                    style: GoogleFonts.workSans(
                      fontSize: AppFontSizes.size11,
                      color: isDark
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                          : const Color(0xFF888888),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                
                // Expand / Collapse Chevron
                Icon(
                  _isExpanded
                      ? Symbols.keyboard_arrow_up_rounded
                      : Symbols.keyboard_arrow_down_rounded,
                  color: isDark ? Colors.white60 : Colors.grey.shade400,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
        
        // Expanded radio list
        if (_isExpanded) ...[
          _buildThemeOption(
            context: context,
            mode: ThemeMode.light,
            label: themeLightLabel,
            isSelected: currentMode == ThemeMode.light,
            onTap: () {
              themeProvider.setThemeMode(ThemeMode.light);
              widget.onSnackBar('$themeLightLabel Selected');
            },
          ),
          _buildThemeOption(
            context: context,
            mode: ThemeMode.dark,
            label: themeDarkLabel,
            isSelected: currentMode == ThemeMode.dark,
            onTap: () {
              themeProvider.setThemeMode(ThemeMode.dark);
              widget.onSnackBar('$themeDarkLabel Selected');
            },
          ),
          _buildThemeOption(
            context: context,
            mode: ThemeMode.system,
            label: themeSystemLabel,
            isSelected: currentMode == ThemeMode.system,
            onTap: () {
              themeProvider.setThemeMode(ThemeMode.system);
              widget.onSnackBar('$themeSystemLabel Selected');
            },
          ),
        ],
      ],
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required ThemeMode mode,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            const SizedBox(width: 36), // Alignment offset with parent icon
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.workSans(
                  fontSize: AppFontSizes.size12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            
            // Custom Radio Circle Check
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF8B5CF6) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Symbols.check,
                      color: Colors.white,
                      size: 12,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
