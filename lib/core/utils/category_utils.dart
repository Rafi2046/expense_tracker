import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CategoryUtils {
  static IconData getIcon(String category) {
    switch (category.toLowerCase()) {
      case 'dining':
      case 'food':
        return LucideIcons.utensilsCrossed;
      case 'transport':
        return LucideIcons.bus;
      case 'medicine':
        return LucideIcons.heartPulse;
      case 'salary':
        return LucideIcons.creditCard;
      case 'freelance':
        return LucideIcons.briefcase;
      case 'entertainment':
        return LucideIcons.gamepad2;
      case 'shopping':
        return LucideIcons.shoppingBag;
      case 'investment':
        return LucideIcons.trendingUp;
      case 'rent':
        return LucideIcons.home;
      default:
        return LucideIcons.grid;
    }
  }

  /// Category accents mapped to the consolidated brand / error tokens
  /// (no orphan amber, purple, or rainbow hexes).
  static Color getColor(String category) {
    switch (category.toLowerCase()) {
      case 'dining':
      case 'food':
        return AppColors.activeGreen;
      case 'transport':
        return AppColors.notificationIcon;
      case 'medicine':
        return AppColors.activeRed;
      case 'salary':
        return AppColors.activeGreen;
      case 'freelance':
        return AppColors.buttonColor;
      case 'entertainment':
        return AppColors.selectedColor;
      case 'shopping':
        return AppColors.activeRed;
      case 'investment':
        return AppColors.buttonColor;
      case 'rent':
        return AppColors.notificationIcon;
      default:
        return AppColors.textMuted;
    }
  }
}
