import 'package:flutter/material.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

class TourInsightsToggle extends StatelessWidget {
  final bool isCategory;
  final ValueChanged<bool> onChanged;

  const TourInsightsToggle({
    super.key,
    required this.isCategory,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Segment(
            label: context.translate('by_category'),
            isSelected: isCategory,
            onTap: () => onChanged(true),
          ),
          const SizedBox(width: 2),
          _Segment(
            label: context.translate('by_member'),
            isSelected: !isCategory,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? scheme.secondaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? scheme.onSecondaryContainer
                : scheme.onSurfaceVariant,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
