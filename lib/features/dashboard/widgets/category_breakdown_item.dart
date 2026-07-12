import 'package:flutter/material.dart';

class CategoryBreakdownItem {
  final String name;
  final double amount;
  final double percentage;
  final Color color;

  CategoryBreakdownItem({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.color,
  });
}
