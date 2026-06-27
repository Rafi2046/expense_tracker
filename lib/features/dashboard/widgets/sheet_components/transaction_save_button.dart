import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionSaveButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Color themeColor;
  final String title;

  const TransactionSaveButton({
    super.key,
    required this.onPressed,
    required this.themeColor,
    required this.title,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [gradientStart, gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.title.contains('Update')
                    ? Symbols.check_circle_rounded
                    : Symbols.save_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                widget.title,
                style: GoogleFonts.workSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
