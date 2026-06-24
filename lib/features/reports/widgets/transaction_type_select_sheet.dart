import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionTypeSelectSheet extends StatelessWidget {
  final String selectedType;

  const TransactionTypeSelectSheet({
    super.key,
    required this.selectedType,
  });

  static Future<String?> show(
    BuildContext context, {
    required String selectedType,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionTypeSelectSheet(
        selectedType: selectedType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final types = [
      'All Transactions',
      'Payment In',
      'Payment Out',
      'Expense',
      'Income',
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
            child: Text(
              'Select Transaction Type',
              style: GoogleFonts.workSans(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          const Divider(color: Color(0xFFF1F1F1), height: 1),

          // Options List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: types.length,
            separatorBuilder: (context, index) => const Divider(
              color: Color(0xFFF8FAFC),
              height: 1,
            ),
            itemBuilder: (context, index) {
              final type = types[index];
              final isSelected = selectedType == type;

              return ListTile(
                onTap: () => Navigator.pop(context, type),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                title: Text(
                  type,
                  style: GoogleFonts.workSans(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
                trailing: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.activeGreen : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.activeGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
