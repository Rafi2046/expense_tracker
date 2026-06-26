import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:expense_tracker/core/models/transaction_models.dart';
import 'package:expense_tracker/core/repositories/transaction_repository.dart';
import 'package:expense_tracker/core/utils/database_helper.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';

class SqliteTransactionRepository implements TransactionRepository {
  static const String _webTxKey = 'web_transactions';
  static const String _webCategoryKey = 'web_categories';

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<Database> get _database => _dbHelper.database;

  // ─── Web helpers ────────────────────────────────────────────────

  List<Map<String, dynamic>> _readWebTransactions() {
    final jsonString = SharedPrefsHelper.getString(_webTxKey);
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      return (jsonDecode(jsonString) as List<dynamic>).cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('SqliteTransactionRepository: error reading web transactions: $e');
      return [];
    }
  }

  Future<void> _writeWebTransactions(List<Map<String, dynamic>> data) async {
    await SharedPrefsHelper.setString(_webTxKey, jsonEncode(data));
  }

  List<Map<String, dynamic>> _readWebCategories() {
    final jsonString = SharedPrefsHelper.getString(_webCategoryKey);
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      return (jsonDecode(jsonString) as List<dynamic>).cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('SqliteTransactionRepository: error reading web categories: $e');
      return [];
    }
  }

  Future<void> _writeWebCategories(List<Map<String, dynamic>> data) async {
    await SharedPrefsHelper.setString(_webCategoryKey, jsonEncode(data));
  }

  // ─── Transactions ───────────────────────────────────────────────

  @override
  Future<List<TransactionItem>> getTransactions() async {
    if (kIsWeb) {
      final data = _readWebTransactions()
          .where((r) => r['isDeleted'] == 0)
          .toList()
        ..sort((a, b) => (b['dateTime'] as String).compareTo(a['dateTime'] as String));
      return data.map((r) => TransactionItem.fromJson(r)).toList();
    }

    final db = await _database;
    final maps = await db.query('transactions',
        where: 'isDeleted = 0', orderBy: 'dateTime DESC');
    return maps.map((m) => TransactionItem.fromJson(m)).toList();
  }

  @override
  Future<void> addTransaction(TransactionItem item, {String syncStatus = 'pending_create'}) async {
    final row = {
      ...item.toJson(),
      'syncStatus': syncStatus,
      'isDeleted': 0,
    };

    if (kIsWeb) {
      final data = _readWebTransactions();
      data.removeWhere((r) => r['id'] == item.id);
      data.insert(0, row);
      await _writeWebTransactions(data);
      return;
    }

    final db = await _database;
    await db.insert('transactions', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> updateTransaction(TransactionItem item, {String? syncStatus}) async {
    final row = item.toJson();
    if (syncStatus != null) row['syncStatus'] = syncStatus;

    if (kIsWeb) {
      final data = _readWebTransactions();
      final index = data.indexWhere((r) => r['id'] == item.id);
      if (index != -1) {
        data[index] = {...data[index], ...row};
        await _writeWebTransactions(data);
      }
      return;
    }

    final db = await _database;
    await db.update('transactions', row, where: 'id = ?', whereArgs: [item.id]);
  }

  @override
  Future<void> deleteTransaction(String id, {bool hardDelete = false}) async {
    if (kIsWeb) {
      final data = _readWebTransactions();
      if (hardDelete) {
        data.removeWhere((r) => r['id'] == id);
      } else {
        final index = data.indexWhere((r) => r['id'] == id);
        if (index != -1) {
          data[index] = {
            ...data[index],
            'isDeleted': 1,
            'syncStatus': 'pending_delete',
          };
        }
      }
      await _writeWebTransactions(data);
      return;
    }

    final db = await _database;
    if (hardDelete) {
      await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
    } else {
      await db.update('transactions',
          {'isDeleted': 1, 'syncStatus': 'pending_delete'},
          where: 'id = ?', whereArgs: [id]);
    }
  }

  @override
  Future<List<TransactionItem>> getPendingTransactions() async {
    if (kIsWeb) {
      final data = _readWebTransactions()
          .where((r) =>
              r['isDeleted'] == 0 &&
              (r['syncStatus'] == 'pending_create' || r['syncStatus'] == 'pending_update'))
          .toList();
      return data.map((r) => TransactionItem.fromJson(r)).toList();
    }

    final db = await _database;
    final maps = await db.query('transactions',
        where: 'isDeleted = 0 AND syncStatus IN (?, ?)',
        whereArgs: ['pending_create', 'pending_update']);
    return maps.map((m) => TransactionItem.fromJson(m)).toList();
  }

  @override
  Future<List<String>> getPendingDeleteTransactionIds() async {
    if (kIsWeb) {
      return _readWebTransactions()
          .where((r) => r['isDeleted'] == 1 && r['syncStatus'] == 'pending_delete')
          .map((r) => r['id'] as String)
          .toList();
    }

    final db = await _database;
    final maps = await db.query('transactions',
        columns: ['id'],
        where: 'isDeleted = 1 AND syncStatus = ?',
        whereArgs: ['pending_delete']);
    return maps.map((m) => m['id'] as String).toList();
  }

  @override
  Future<Set<String>> getAllPendingTransactionIds() async {
    if (kIsWeb) {
      return _readWebTransactions()
          .where((r) => r['syncStatus'] != 'synced')
          .map((r) => r['id'] as String)
          .toSet();
    }

    final db = await _database;
    final maps = await db.query('transactions',
        columns: ['id'],
        where: 'syncStatus != ?',
        whereArgs: ['synced']);
    return maps.map((m) => m['id'] as String).toSet();
  }

  @override
  Future<void> markTransactionSynced(String id) async {
    if (kIsWeb) {
      final data = _readWebTransactions();
      final index = data.indexWhere((r) => r['id'] == id);
      if (index != -1) {
        data[index] = {...data[index], 'syncStatus': 'synced'};
        await _writeWebTransactions(data);
      }
      return;
    }

    final db = await _database;
    await db.update('transactions', {'syncStatus': 'synced'},
        where: 'id = ?', whereArgs: [id]);
  }

  // ─── Categories ─────────────────────────────────────────────────

  @override
  Future<List<CategoryItem>> getCategories() async {
    if (kIsWeb) {
      final data = _readWebCategories()
          .where((r) => r['isDeleted'] == 0)
          .toList();
      return data.map((r) => CategoryItem.fromJson(r)).toList();
    }

    final db = await _database;
    final maps = await db.query('categories', where: 'isDeleted = 0');
    return maps.map((m) => CategoryItem.fromJson(m)).toList();
  }

  @override
  Future<void> addCategory(CategoryItem item, {String syncStatus = 'pending_create'}) async {
    final row = {
      ...item.toJson(),
      'syncStatus': syncStatus,
      'isDeleted': 0,
    };

    if (kIsWeb) {
      final data = _readWebCategories();
      data.removeWhere((r) => r['id'] == item.id);
      data.insert(0, row);
      await _writeWebCategories(data);
      return;
    }

    final db = await _database;
    await db.insert('categories', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> deleteCategory(String id, {bool hardDelete = false}) async {
    if (kIsWeb) {
      final data = _readWebCategories();
      if (hardDelete) {
        data.removeWhere((r) => r['id'] == id);
      } else {
        final index = data.indexWhere((r) => r['id'] == id);
        if (index != -1) {
          data[index] = {
            ...data[index],
            'isDeleted': 1,
            'syncStatus': 'pending_delete',
          };
        }
      }
      await _writeWebCategories(data);
      return;
    }

    final db = await _database;
    if (hardDelete) {
      await db.delete('categories', where: 'id = ?', whereArgs: [id]);
    } else {
      await db.update('categories',
          {'isDeleted': 1, 'syncStatus': 'pending_delete'},
          where: 'id = ?', whereArgs: [id]);
    }
  }

  @override
  Future<void> renameCategory(String oldName, String newName, {required bool isIncome}) async {
    if (oldName == newName) return;

    if (kIsWeb) {
      final categories = _readWebCategories();
      final catIndex = categories.indexWhere(
        (r) => r['name'] == oldName && r['isIncome'] == (isIncome ? 1 : 0) && r['isDeleted'] == 0,
      );
      if (catIndex != -1) {
        categories[catIndex] = {
          ...categories[catIndex],
          'name': newName,
          'syncStatus': 'pending_update',
        };
        await _writeWebCategories(categories);
      }

      final transactions = _readWebTransactions();
      bool changed = false;
      for (int i = 0; i < transactions.length; i++) {
        if (transactions[i]['category'] == oldName && transactions[i]['isDeleted'] == 0) {
          transactions[i] = {
            ...transactions[i],
            'category': newName,
            'syncStatus': 'pending_update',
          };
          changed = true;
        }
      }
      if (changed) {
        await _writeWebTransactions(transactions);
      }
      return;
    }

    final db = await _database;
    await db.transaction((txn) async {
      await txn.update(
        'categories',
        {'name': newName, 'syncStatus': 'pending_update'},
        where: 'name = ? AND isIncome = ? AND isDeleted = 0',
        whereArgs: [oldName, isIncome ? 1 : 0],
      );
      await txn.update(
        'transactions',
        {'category': newName, 'syncStatus': 'pending_update'},
        where: 'category = ? AND isDeleted = 0',
        whereArgs: [oldName],
      );
    });
  }

  @override
  Future<List<CategoryItem>> getPendingCategories() async {
    if (kIsWeb) {
      final data = _readWebCategories()
          .where((r) =>
              r['isDeleted'] == 0 && r['syncStatus'] == 'pending_create')
          .toList();
      return data.map((r) => CategoryItem.fromJson(r)).toList();
    }

    final db = await _database;
    final maps = await db.query('categories',
        where: 'isDeleted = 0 AND syncStatus = ?',
        whereArgs: ['pending_create']);
    return maps.map((m) => CategoryItem.fromJson(m)).toList();
  }

  @override
  Future<List<String>> getPendingDeleteCategoryIds() async {
    if (kIsWeb) {
      return _readWebCategories()
          .where((r) => r['isDeleted'] == 1 && r['syncStatus'] == 'pending_delete')
          .map((r) => r['id'] as String)
          .toList();
    }

    final db = await _database;
    final maps = await db.query('categories',
        columns: ['id'],
        where: 'isDeleted = 1 AND syncStatus = ?',
        whereArgs: ['pending_delete']);
    return maps.map((m) => m['id'] as String).toList();
  }

  @override
  Future<Set<String>> getAllPendingCategoryIds() async {
    if (kIsWeb) {
      return _readWebCategories()
          .where((r) => r['syncStatus'] != 'synced')
          .map((r) => r['id'] as String)
          .toSet();
    }

    final db = await _database;
    final maps = await db.query('categories',
        columns: ['id'],
        where: 'syncStatus != ?',
        whereArgs: ['synced']);
    return maps.map((m) => m['id'] as String).toSet();
  }

  @override
  Future<void> markCategorySynced(String id) async {
    if (kIsWeb) {
      final data = _readWebCategories();
      final index = data.indexWhere((r) => r['id'] == id);
      if (index != -1) {
        data[index] = {...data[index], 'syncStatus': 'synced'};
        await _writeWebCategories(data);
      }
      return;
    }

    final db = await _database;
    await db.update('categories', {'syncStatus': 'synced'},
        where: 'id = ?', whereArgs: [id]);
  }
}
