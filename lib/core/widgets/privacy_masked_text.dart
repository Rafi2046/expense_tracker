import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/extensions/masking_extensions.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/providers/privacy_provider.dart';

class PrivacyMaskedText extends StatelessWidget {
  final double amount;
  final TextStyle? style;

  const PrivacyMaskedText({
    super.key,
    required this.amount,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final isMasked = context.watch<PrivacyProvider>().isMasked;
    final formatted = context.formatAmount(amount, listen: false);
    final displayText = isMasked ? formatted.masked : formatted;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
      child: Text(
        displayText,
        key: ValueKey<bool>(isMasked),
        style: style,
      ),
    );
  }
}
