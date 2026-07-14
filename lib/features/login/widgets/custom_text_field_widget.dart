import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CustomTextFieldWidget extends StatefulWidget {
  final String label;
  final String hintText;
  final bool obscureText;
  final Widget? trailingLabelWidget;
  final TextEditingController? controller;

  const CustomTextFieldWidget({
    super.key,
    required this.label,
    required this.hintText,
    this.obscureText = false,
    this.trailingLabelWidget,
    this.controller,
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
        const SizedBox(height: 4),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          style: AppTextStyles.textFieldHint.copyWith(
            color: isDark ? Colors.white : null,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
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
                    icon: Icon(
                      _obscureText ? LucideIcons.eye : LucideIcons.eyeOff,
                      color: isDark ? Colors.grey.shade400 : null,
                    ),
                  )
                : null,

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade600 : AppColors.borderColor,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade500 : AppColors.borderColor,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
