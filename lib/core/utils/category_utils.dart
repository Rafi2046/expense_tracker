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

  static Color getColor(String category) {
    switch (category.toLowerCase()) {
      case 'dining':
      case 'food':
        return const Color(0xFFF39C12);
      case 'transport':
        return const Color(0xFF3498DB);
      case 'medicine':
        return const Color(0xFFE74C3C);
      case 'salary':
        return const Color(0xFF2ECC71);
      case 'freelance':
        return const Color(0xFF1ABC9C);
      case 'entertainment':
        return const Color(0xFF9B59B6);
      case 'shopping':
        return const Color(0xFFE91E63);
      case 'investment':
        return const Color(0xFF27AE60);
      case 'rent':
        return const Color(0xFFE67E22);
      default:
        return const Color(0xFF95A5A6);
    }
  }
}
