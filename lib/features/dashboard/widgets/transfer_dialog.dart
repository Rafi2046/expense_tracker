import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';

class TransferDialog extends StatefulWidget {
  final String? initialFromAccount;

  const TransferDialog({super.key, this.initialFromAccount});

  @override
  State<TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends State<TransferDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  late String _fromAccount;
  late String _toAccount;

  @override
  void initState() {
    super.initState();
    _fromAccount = widget.initialFromAccount ?? 'Cash';
    _toAccount = _fromAccount == 'Cash' ? 'Bank' : 'Cash';
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        'Transfer Balance',
        style: GoogleFonts.workSans(
          fontWeight: FontWeight.bold,
          fontSize: 16.5,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _fromAccount,
                  items: const [
                    DropdownMenuItem(
                      value: 'Cash',
                      child: Text('Cash'),
                    ),
                    DropdownMenuItem(
                      value: 'Bank',
                      child: Text('Bank'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _fromAccount = val;
                        _toAccount = val == 'Cash' ? 'Bank' : 'Cash';
                      });
                    }
                  },
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.grey,
                  size: 18,
                ),
                DropdownButton<String>(
                  value: _toAccount,
                  items: const [
                    DropdownMenuItem(
                      value: 'Cash',
                      child: Text('Cash'),
                    ),
                    DropdownMenuItem(
                      value: 'Bank',
                      child: Text('Bank'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _toAccount = val;
                        _fromAccount = val == 'Cash' ? 'Bank' : 'Cash';
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: GoogleFonts.workSans(fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Transfer Amount',
                prefixText: 'Tk. ',
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
                  return 'Enter amount';
                }
                if (double.tryParse(val) == null ||
                    double.parse(val) <= 0) {
                  return 'Enter a valid amount';
                }
                return null;
              },
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
              fontSize: 13,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final amount = double.parse(_amountController.text);
              context.read<TransactionProvider>().transferBalance(
                    amount,
                    _fromAccount,
                    _toAccount,
                  );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Successfully transferred Tk. $amount from $_fromAccount to $_toAccount',
                  ),
                  backgroundColor: const Color(0xFF006C49),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF006C49),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Transfer',
            style: GoogleFonts.workSans(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
