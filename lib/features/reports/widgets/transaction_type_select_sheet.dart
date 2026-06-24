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
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(top: 12, bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Text(
              'Select Transaction Type',
              style: GoogleFonts.workSans(
                fontWeight: FontWeight.bold,
                fontSize: 18,
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                title: Text(
                  type,
                  style: GoogleFonts.workSans(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: Colors.black87,
                    fontSize: 15,
                  ),
                ),
                trailing: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.activeGreen : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
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
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
