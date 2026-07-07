import 'package:flutter/material.dart';

class ReportItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget destination;

  const ReportItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.destination,
  });
}
