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

  int get activeTabIndex => _activeTabIndex;
  bool get isReceive => _isReceive;
  DateTime get asOfDate => _asOfDate;
  String? get pickedImagePath => _pickedImagePath;
  Uint8List? get pickedImageBytes => _pickedImageBytes;
  bool get isNameNotEmpty => _isNameNotEmpty;

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

    if (balance > 0) {
      final newDebt = DebtItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        detail: 'Opening Balance',
        amount: balance,
        isReceive: _isReceive,
        isSettled: false,
        createdAt: _asOfDate,
      );
      debtProvider.addDebtItem(newDebt);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Party "$name" added successfully!'),
        backgroundColor: AppColors.activeGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );

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
