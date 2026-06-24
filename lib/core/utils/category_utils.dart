import 'package:flutter/material.dart';

class CategoryUtils {
  static IconData getIcon(String category) {
    switch (category.toLowerCase()) {
      case 'dining':
      case 'food':
        return Icons.restaurant_rounded;
      case 'transport':
        return Icons.directions_bus_rounded;
      case 'medicine':
        return Icons.medical_services_rounded;
      case 'salary':
        return Icons.payments_rounded;
      case 'freelance':
        return Icons.work_rounded;
      case 'entertainment':
        return Icons.sports_esports_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'investment':
        return Icons.trending_up_rounded;
      case 'rent':
        return Icons.home_rounded;
      default:
        return Icons.category_rounded;
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
