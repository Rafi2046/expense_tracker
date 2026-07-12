import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/features/dashboard/widgets/premium_feature_tile.dart';

class PremiumFeatureList extends StatelessWidget {
  const PremiumFeatureList({super.key});

  static const _features = [
    (LucideIcons.users, 'Unlimited Profiles'),
    (LucideIcons.barChart, 'Advanced Analytics & Reports'),
    (LucideIcons.fileText, 'Export PDF Reports'),
    (LucideIcons.cloudSync, 'Priority Cloud Sync'),
    (LucideIcons.headphones, 'Priority Support'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _features
          .map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: PremiumFeatureTile(icon: f.$1, text: f.$2),
            ),
          )
          .toList(),
    );
  }
}
