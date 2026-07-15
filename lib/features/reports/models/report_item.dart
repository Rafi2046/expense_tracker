import 'package:flutter/material.dart';

class ReportItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String titleKey;
  final String subtitleKey;
  final Widget destination;

  const ReportItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.titleKey,
    required this.subtitleKey,
    required this.destination,
  });
}
