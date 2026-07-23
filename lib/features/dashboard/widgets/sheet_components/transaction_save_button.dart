import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';



class TransactionSaveButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Color themeColor;
  final String title;
  final bool isEditing;
  final IconData? icon;

  const TransactionSaveButton({
    super.key,
    required this.onPressed,
    required this.themeColor,
    required this.title,
    this.isEditing = false,
    this.icon,
  });

  @override
  State<TransactionSaveButton> createState() => _TransactionSaveButtonState();
}

class _TransactionSaveButtonState extends State<TransactionSaveButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build gradient from the themeColor
    final gradientStart = widget.themeColor;
    final gradientEnd = HSLColor.fromColor(widget.themeColor)
        .withLightness(
          (HSLColor.fromColor(widget.themeColor).lightness - 0.08).clamp(
            0.0,
            1.0,
          ),
        )
        .toColor();

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onPressed();
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [gradientStart, gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.r12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon ??
                    (widget.isEditing
                        ? LucideIcons.checkCircle
                        : LucideIcons.save),
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.s8),
              Text(
                widget.title,
                style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
