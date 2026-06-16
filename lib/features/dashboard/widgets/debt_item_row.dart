import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DebtItemRow extends StatelessWidget {
  final DebtItem item;
  final Color themeColor;
  final VoidCallback onEditTap;

  const DebtItemRow({
    super.key,
    required this.item,
    required this.themeColor,
    required this.onEditTap,
  });

  Color _getAvatarBg(String name) {
    final hash = name.hashCode.abs();
    final colors = [
      const Color(0xFFE8F8F5), // soft green
      const Color(0xFFFEE2E2), // soft red/pink
      const Color(0xFFEBF5FB), // soft blue
      const Color(0xFFFEF9E7), // soft yellow
      const Color(0xFFF3E5F5), // soft purple
      const Color(0xFFECEFF1), // soft blue-grey
    ];
    return colors[hash % colors.length];
  }

  Color _getAvatarFg(String name) {
    final hash = name.hashCode.abs();
    final colors = [
      const Color(0xFF2EBD85),
      const Color(0xFFDC3545),
      const Color(0xFF2980B9),
      const Color(0xFFD35400),
      const Color(0xFF8E44AD),
      const Color(0xFF607D8B),
    ];
    return colors[hash % colors.length];
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final debtProvider = context.read<DebtProvider>();

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: themeColor == AppColors.activeRed
              ? const Color(0xFFFEE2E2)
              : const Color(0xFFE8F8F5),
          borderRadius: BorderRadius.circular(AppSpacing.r16),
          border: Border.all(
            color: themeColor == AppColors.activeRed
                ? const Color(0xFFFCA5A5)
                : const Color(0xFFA3E4D7),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Settle',
              style: GoogleFonts.workSans(
                color: themeColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.check_circle_outline,
              color: themeColor,
              size: 24,
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        debtProvider.settleDebtItem(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name}\'s debt settled'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Undo',
              textColor: Colors.yellow,
              onPressed: () {
                debtProvider.toggleSettledStatus(item.id);
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.r16),
          border: Border.all(color: const Color(0xFFF0F0F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _getAvatarBg(item.name),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              _getInitials(item.name),
              style: GoogleFonts.workSans(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: _getAvatarFg(item.name),
              ),
            ),
          ),
          title: Text(
            item.name,
            style: GoogleFonts.workSans(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              item.detail,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '\$${item.amount.toStringAsFixed(2)}',
                style: GoogleFonts.workSans(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onEditTap,
                child: Icon(
                  Icons.edit_outlined,
                  color: Colors.grey.shade400,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
