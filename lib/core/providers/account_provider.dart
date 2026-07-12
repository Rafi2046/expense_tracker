import 'dart:async';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/model/account_model.dart';
import 'package:expense_tracker/core/utils/database_helper.dart';

class AccountProvider extends ChangeNotifier {
  List<AccountModel> _accounts = [];
  String? _currentProfileId;

  List<AccountModel> get accounts => _accounts;
  int get count => _accounts.length;

  AccountProvider() {
    _loadFromDb();
  }

  Future<void> _loadFromDb({String profileId = 'default_profile'}) async {
    _accounts = await DatabaseHelper.instance.readAllAccounts(profileId: profileId);
    notifyListeners();
    _cleanupOrphanedTransactions(profileId: profileId);
  }

  Future<void> _cleanupOrphanedTransactions({String profileId = 'default_profile'}) async {
    final accountNames = _accounts.map((a) => a.name).toSet();
    final allPaymentMethods = await DatabaseHelper.instance.getDistinctPaymentMethods(profileId: profileId);
    for (final pm in allPaymentMethods) {
      if (!accountNames.contains(pm)) {
        await DatabaseHelper.instance.deleteTransactionsByPaymentMethod(pm, profileId: profileId);
      }
    }
  }

  void updateProfileId(String newProfileId) {
    if (_currentProfileId == newProfileId) return;
    _currentProfileId = newProfileId;
    _loadFromDb(profileId: newProfileId);
  }

  void loadAccounts({String profileId = 'default_profile'}) {
    _loadFromDb(profileId: profileId);
  }

  Future<AccountModel> createAccount({
    required String name,
    required String type,
    double initialBalance = 0.0,
    String profileId = 'default_profile',
  }) async {
    final account = AccountModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      type: type,
      initialBalance: initialBalance,
      createdAt: DateTime.now().toIso8601String(),
      profileId: profileId,
    );
    await DatabaseHelper.instance.insertAccount(account, profileId: profileId);
    await _loadFromDb(profileId: profileId);
    return account;
  }

  Future<void> deleteAccount(String id, {String profileId = 'default_profile'}) async {
    await DatabaseHelper.instance.deleteAccount(id, profileId: profileId);
    await _loadFromDb(profileId: profileId);
  }

  Future<void> deleteAccountByName(String name, {String profileId = 'default_profile'}) async {
    final id = getAccountIdByName(name);
    if (id == null) return;
    await DatabaseHelper.instance.deleteTransactionsByPaymentMethod(name, profileId: profileId);
    await deleteAccount(id, profileId: profileId);
  }

  String? getAccountIdByName(String name) {
    final idx = _accounts.indexWhere((a) => a.name == name);
    if (idx == -1) return null;
    return _accounts[idx].id;
  }

  String? getAccountNameById(String id) {
    final idx = _accounts.indexWhere((a) => a.id == id);
    if (idx == -1) return null;
    return _accounts[idx].name;
  }
}
