import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/extensions/masking_extensions.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/providers/privacy_provider.dart';

class PrivacyMaskedText extends StatelessWidget {
  final double amount;
  final TextStyle? style;
  final bool? isMasked;

  const PrivacyMaskedText({
    super.key,
    required this.amount,
    this.style,
    this.isMasked,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMasked = isMasked ?? context.watch<PrivacyProvider>().isMasked;
    final formatted = context.formatAmount(amount, listen: false);
    final displayText = effectiveMasked ? formatted.masked : formatted;

    return Text(
      displayText,
      style: style,
      softWrap: false,
    );
  }
}
