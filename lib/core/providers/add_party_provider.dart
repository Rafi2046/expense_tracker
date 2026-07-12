import 'dart:typed_data';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddPartyProvider extends ChangeNotifier {
  // Text Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController vatController = TextEditingController();

  // State Variables
  int _activeTabIndex = 0;
  bool _isReceive = true;
  DateTime _asOfDate = DateTime.now();
  String? _pickedImagePath;
  Uint8List? _pickedImageBytes;
  bool _isNameNotEmpty = false;
  bool _isEditing = false;
  String? _editingItemId;

  int get activeTabIndex => _activeTabIndex;
  bool get isReceive => _isReceive;
  DateTime get asOfDate => _asOfDate;
  String? get pickedImagePath => _pickedImagePath;
  Uint8List? get pickedImageBytes => _pickedImageBytes;
  bool get isNameNotEmpty => _isNameNotEmpty;
  bool get isEditing => _isEditing;

  AddPartyProvider() {
    dateController.text = DateFormat('dd MMM yyyy').format(_asOfDate);
    nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    final isNotEmpty = nameController.text.trim().isNotEmpty;
    if (isNotEmpty != _isNameNotEmpty) {
      _isNameNotEmpty = isNotEmpty;
      notifyListeners();
    }
  }

  void initializeForEdit(DebtItem item) {
    _isEditing = true;
    _editingItemId = item.id;
    nameController.text = item.name;
    phoneController.text = item.phone ?? '';
    balanceController.text = item.amount.toString();
    _asOfDate = item.createdAt;
    dateController.text = DateFormat('dd MMM yyyy').format(_asOfDate);
    _isReceive = item.isReceive;
    emailController.text = item.email ?? '';
    addressController.text = item.address ?? '';
    vatController.text = item.vat ?? '';
    _isNameNotEmpty = true;
    _activeTabIndex = 0;
    notifyListeners();
  }

  void setPickedImage(String? path, Uint8List? bytes) {
    _pickedImagePath = path;
    _pickedImageBytes = bytes;
    notifyListeners();
  }

  void setReceive(bool value) {
    _isReceive = value;
    notifyListeners();
  }

  void setTabIndex(int index) {
    _activeTabIndex = index;
    notifyListeners();
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _asOfDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.activeGreen,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _asOfDate) {
      _asOfDate = picked;
      dateController.text = DateFormat('dd MMM yyyy').format(_asOfDate);
      notifyListeners();
    }
  }

  void saveParty(BuildContext context, DebtProvider debtProvider) {
    final name = nameController.text.trim();
    final balanceText = balanceController.text.trim();
    final double balance = balanceText.isEmpty ? 0.0 : (double.tryParse(balanceText) ?? 0.0);
    final phone = phoneController.text.trim();

    // Phone: at least 10 digits if not empty
    if (phone.isNotEmpty && phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number must be at least 10 digits'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Zero-balance confirmation
    if (balance == 0) {
      showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Zero Balance'),
          content: const Text(
            'Are you sure you want to add a party with zero balance?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Yes, Add Party'),
            ),
          ],
        ),
      ).then((confirmed) {
        if (confirmed == true) {
          // ignore: use_build_context_synchronously
          _commitSave(context, debtProvider, name, balance, phone);
        }
      });
      return;
    }

    _commitSave(context, debtProvider, name, balance, phone);
  }

  void _commitSave(BuildContext context, DebtProvider debtProvider, String name,
      double balance, String phone) {
    if (_isEditing && _editingItemId != null) {
      final updatedDebt = DebtItem(
        id: _editingItemId!,
        name: name,
        detail: balance > 0 ? 'Opening Balance' : 'Register Party',
        amount: balance,
        isReceive: _isReceive,
        isSettled: false,
        createdAt: _asOfDate,
        phone: phone.isEmpty ? null : phone,
        email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
        address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
        vat: vatController.text.trim().isEmpty ? null : vatController.text.trim(),
      );
      debtProvider.updateDebtItem(updatedDebt);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Party "$name" updated successfully!'),
          backgroundColor: AppColors.activeGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      final newDebt = DebtItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        detail: balance > 0 ? 'Opening Balance' : 'Register Party',
        amount: balance,
        isReceive: _isReceive,
        isSettled: false,
        createdAt: _asOfDate,
        phone: phone.isEmpty ? null : phone,
        email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
        address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
        vat: vatController.text.trim().isEmpty ? null : vatController.text.trim(),
      );
      debtProvider.addDebtItem(newDebt);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Party "$name" added successfully!'),
          backgroundColor: AppColors.activeGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    nameController.removeListener(_onNameChanged);
    nameController.dispose();
    phoneController.dispose();
    balanceController.dispose();
    dateController.dispose();
    emailController.dispose();
    addressController.dispose();
    vatController.dispose();
    super.dispose();
  }
}
