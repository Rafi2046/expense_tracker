import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';

class CurrencyInfo {
  final String code;
  final String name;
  final String symbol;
  final String flag;
  final String region;

  const CurrencyInfo({
    required this.code,
    required this.name,
    required this.symbol,
    required this.flag,
    required this.region,
  });
}

class CurrencyProvider extends ChangeNotifier {
  static const String _prefsKey = 'selected_currency_code';

  final List<CurrencyInfo> _currencies = const [
    CurrencyInfo(
      code: 'BDT',
      name: 'Bangladeshi Taka',
      symbol: '৳',
      flag: '🇧🇩',
      region: 'ASIA',
    ),
    CurrencyInfo(
      code: 'INR',
      name: 'Indian Rupee',
      symbol: '₹',
      flag: '🇮🇳',
      region: 'ASIA',
    ),
    CurrencyInfo(
      code: 'JPY',
      name: 'Japanese Yen',
      symbol: '¥',
      flag: '🇯🇵',
      region: 'ASIA',
    ),
    CurrencyInfo(
      code: 'AED',
      name: 'Emirati Dirham',
      symbol: 'د.إ',
      flag: '🇦🇪',
      region: 'ASIA',
    ),
    CurrencyInfo(
      code: 'EUR',
      name: 'Euro',
      symbol: '€',
      flag: '🇪🇺',
      region: 'EUROPE',
    ),
    CurrencyInfo(
      code: 'GBP',
      name: 'British Pound',
      symbol: '£',
      flag: '🇬🇧',
      region: 'EUROPE',
    ),
    CurrencyInfo(
      code: 'USD',
      name: 'US Dollar',
      symbol: '\$',
      flag: '🇺🇸',
      region: 'NORTH AMERICA',
    ),
    CurrencyInfo(
      code: 'CAD',
      name: 'Canadian Dollar',
      symbol: '\$',
      flag: '🇨🇦',
      region: 'NORTH AMERICA',
    ),
  ];

  late CurrencyInfo _selectedCurrency;

  CurrencyProvider() {
    final savedCode = SharedPrefsHelper.getString(_prefsKey);
    // Locate saved currency or default to BDT (as requested by user)
    _selectedCurrency = _currencies.firstWhere(
      (c) => c.code == savedCode,
      orElse: () => _currencies.first, // Defaults to BDT
    );
  }

  List<CurrencyInfo> get currencies => _currencies;
  CurrencyInfo get selectedCurrency => _selectedCurrency;

  Future<void> selectCurrency(String code) async {
    final found = _currencies.firstWhere(
      (c) => c.code == code,
      orElse: () => _currencies.first,
    );
    _selectedCurrency = found;
    await SharedPrefsHelper.setString(_prefsKey, code);
    notifyListeners();
  }
}

extension CurrencyFormatter on BuildContext {
  String formatAmount(double amount, {bool listen = true}) {
    final currency = listen
        ? watch<CurrencyProvider>().selectedCurrency
        : read<CurrencyProvider>().selectedCurrency;
    return '${currency.symbol}${amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }

  String formatValueWithoutSymbol(double value) {
    return (value % 1 == 0)
        ? value.toStringAsFixed(0).replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            )
        : value.toStringAsFixed(2).replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            );
  }

  String get currencySymbol => watch<CurrencyProvider>().selectedCurrency.symbol;
}
