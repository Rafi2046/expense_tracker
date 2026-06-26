import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.label, style: AppTextStyles.textFieldLabel),

            if (widget.trailingLabelWidget != null) widget.trailingLabelWidget!,
          ],
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          style: AppTextStyles.textFieldHint,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(color: AppColors.loginLabelColor),

            suffixIcon: widget.obscureText
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                    icon: Icon(
                      _obscureText ? Symbols.visibility_off : Symbols.visibility,
                    ),
                  )
                : null,

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: AppColors.borderColor, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.borderColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
