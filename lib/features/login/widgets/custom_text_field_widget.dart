import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CustomTextFieldWidget extends StatefulWidget {
  final String label;
  final String hintText;
  final bool obscureText;
  final Widget? trailingLabelWidget;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  const CustomTextFieldWidget({
    super.key,
    required this.label,
    required this.hintText,
    this.obscureText = false,
    this.trailingLabelWidget,
    this.controller,
    this.keyboardType,
  });

  @override
  State<CustomTextFieldWidget> createState() => _CustomTextFieldWidgetState();
}

class _CustomTextFieldWidgetState extends State<CustomTextFieldWidget> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldRadius = BorderRadius.circular(AppSpacing.authFieldBorderRadius);
    final borderSide = BorderSide(
      color: isDark ? Colors.grey.shade600 : AppColors.borderColor,
      width: 1.5,
    );
    final focusedBorderSide = BorderSide(
      color: isDark ? Colors.grey.shade500 : AppColors.borderColor,
      width: 1.5,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: AppTextStyles.textFieldLabel.copyWith(
                color: isDark ? Colors.grey.shade300 : null,
              ),
            ),

            if (widget.trailingLabelWidget != null) widget.trailingLabelWidget!,
          ],
        ),
        const SizedBox(height: AppSpacing.s4),
        SizedBox(
          height: AppSpacing.authFieldHeight,
          child: TextFormField(
            controller: widget.controller,
            obscureText: _obscureText,
            keyboardType: widget.keyboardType,
            style: AppTextStyles.textFieldHint.copyWith(
              color: isDark ? Colors.white : null,
            ),
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: widget.hintText,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.p12,
                vertical: AppSpacing.p16,
              ),
              hintStyle: TextStyle(
                color: isDark ? Colors.grey.shade400 : AppColors.loginLabelColor,
              ),

              suffixIcon: widget.obscureText
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      tooltip: _obscureText
                          ? 'Show password'
                          : 'Hide password',
                      icon: Icon(
                        // State-based: eyeOff while hidden, eye while visible.
                        _obscureText ? LucideIcons.eyeOff : LucideIcons.eye,
                        size: 20,
                        color: isDark
                            ? Colors.grey.shade400
                            : AppColors.loginLabelColor,
                      ),
                    )
                  : null,
              suffixIconConstraints: const BoxConstraints(
                minWidth: 44,
                minHeight: AppSpacing.authFieldHeight,
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: fieldRadius,
                borderSide: borderSide,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: fieldRadius,
                borderSide: focusedBorderSide,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: fieldRadius,
                borderSide: borderSide,
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: fieldRadius,
                borderSide: focusedBorderSide,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
