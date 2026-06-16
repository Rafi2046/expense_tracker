import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryInputRow extends StatelessWidget {
  final TextEditingController controller;
  final Color themeColor;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback onAddPressed;

  const CategoryInputRow({
    super.key,
    required this.controller,
    required this.themeColor,
    this.onSubmitted,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Add new category...',
                hintStyle: GoogleFonts.workSans(color: Colors.grey.shade400, fontSize: 14),
                border: InputBorder.none,
              ),
              onSubmitted: onSubmitted,
            ),
          ),
          IconButton(
            icon: Icon(Icons.add_circle, color: themeColor, size: 28),
            onPressed: onAddPressed,
          ),
        ],
      ),
    );
  }
}
