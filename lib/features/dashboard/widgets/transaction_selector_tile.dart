import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionSelectorTile extends StatelessWidget {
  final IconData leadingIcon;
  final String labelText;
  final String valueText;
  final bool isValueSelected;
  final Color themeColor;
  final IconData trailingIcon;
  final VoidCallback onTap;

  const TransactionSelectorTile({
    super.key,
    required this.leadingIcon,
    required this.labelText,
    required this.valueText,
    required this.isValueSelected,
    required this.themeColor,
    required this.trailingIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Icon(leadingIcon, color: themeColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    labelText,
                    style: GoogleFonts.workSans(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    valueText,
                    style: GoogleFonts.workSans(
                      fontSize: 15,
                      fontWeight: isValueSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isValueSelected
                          ? Colors.black87
                          : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(trailingIcon, color: Colors.grey.shade400, size: 16),
          ],
        ),
      ),
    );
  }
}
