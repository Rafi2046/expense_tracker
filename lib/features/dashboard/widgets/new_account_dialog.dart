import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class NewAccountDialog extends StatefulWidget {
  const NewAccountDialog({super.key});

  @override
  State<NewAccountDialog> createState() => _NewAccountDialogState();
}

class _NewAccountDialogState extends State<NewAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  String _accountType = 'Bank';

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        'Create Account',
        style: GoogleFonts.workSans(
          fontWeight: FontWeight.bold,
          fontSize: AppFontSizes.size16,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              style: GoogleFonts.workSans(fontSize: AppFontSizes.size14),
              decoration: InputDecoration(
                labelText: 'Account Name',
                hintText: 'e.g. Bkash, DBBL, Cash In Hand',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              validator: (val) => (val == null || val.isEmpty)
                  ? 'Enter account name'
                  : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _balanceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: GoogleFonts.workSans(fontSize: AppFontSizes.size14),
              decoration: InputDecoration(
                labelText: 'Initial Balance',
                prefixText: '${context.currencySymbol} ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Enter initial balance';
                }
                if (double.tryParse(val) == null) {
                  return 'Enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Account Type:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: AppFontSizes.size14,
                  ),
                ),
                DropdownButton<String>(
                  value: _accountType,
                  items: const [
                    DropdownMenuItem(
                      value: 'Cash',
                      child: Text(
                        'Cash',
                        style: TextStyle(fontSize: AppFontSizes.size14),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Bank',
                      child: Text(
                        'Bank',
                        style: TextStyle(fontSize: AppFontSizes.size14),
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _accountType = val;
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.workSans(
              color: Colors.grey,
              fontSize: AppFontSizes.size13,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Account "${_nameController.text}" created successfully!',
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Create',
            style: GoogleFonts.workSans(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: AppFontSizes.size13,
            ),
          ),
        ),
      ],
    );
  }
}
