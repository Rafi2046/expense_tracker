import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:expense_tracker/core/models/transaction_models.dart';
import 'package:expense_tracker/core/repositories/transaction_repository.dart';
import 'package:expense_tracker/core/utils/database_helper.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';

class SqliteTransactionRepository implements TransactionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<Database> get _database => _dbHelper.database;

  // ─── Web helpers ────────────────────────────────────────────────

  List<Map<String, dynamic>> _readWebTransactions(String profileId) {
    final key = 'web_transactions_$profileId';
    final jsonString = SharedPrefsHelper.getString(key);
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      return (jsonDecode(jsonString) as List<dynamic>).cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('SqliteTransactionRepository: error reading web transactions: $e');
      return [];
    }
  }

  Future<void> _writeWebTransactions(String profileId, List<Map<String, dynamic>> data) async {
    final key = 'web_transactions_$profileId';
    await SharedPrefsHelper.setString(key, jsonEncode(data));
  }

  List<Map<String, dynamic>> _readWebCategories(String profileId) {
    final key = 'web_categories_$profileId';
    final jsonString = SharedPrefsHelper.getString(key);
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      return (jsonDecode(jsonString) as List<dynamic>).cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('SqliteTransactionRepository: error reading web categories: $e');
      return [];
    }
  }

  Future<void> _writeWebCategories(String profileId, List<Map<String, dynamic>> data) async {
    final key = 'web_categories_$profileId';
    await SharedPrefsHelper.setString(key, jsonEncode(data));
  }

  // ─── Transactions ───────────────────────────────────────────────

  @override
  Future<List<TransactionItem>> getTransactions({required String profileId}) async {
    if (kIsWeb) {
      final data = _readWebTransactions(profileId)
          .where((r) => r['isDeleted'] == 0)
          .toList()
        ..sort((a, b) => (b['dateTime'] as String).compareTo(a['dateTime'] as String));
      return data.map((r) => TransactionItem.fromJson(r)).toList();
    }

    final db = await _database;
    final maps = await db.query('transactions',
        where: 'isDeleted = 0 AND profileId = ?',
        whereArgs: [profileId],
        orderBy: 'dateTime DESC');
    return maps.map((m) => TransactionItem.fromJson(m)).toList();
  }

  @override
  Future<void> addTransaction(TransactionItem item, {required String profileId, String syncStatus = 'pending_create'}) async {
    final row = {
      ...item.toJson(),
      'syncStatus': syncStatus,
      'isDeleted': 0,
      'profileId': profileId,
    };

    if (kIsWeb) {
      final data = _readWebTransactions(profileId);
      data.removeWhere((r) => r['id'] == item.id);
      data.insert(0, row);
      await _writeWebTransactions(profileId, data);
      return;
    }

    final db = await _database;
    await db.insert('transactions', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> updateTransaction(TransactionItem item, {required String profileId, String? syncStatus}) async {
    final row = item.toJson();
    if (syncStatus != null) row['syncStatus'] = syncStatus;

    if (kIsWeb) {
      final data = _readWebTransactions(profileId);
      final index = data.indexWhere((r) => r['id'] == item.id);
      if (index != -1) {
        data[index] = {...data[index], ...row};
        await _writeWebTransactions(profileId, data);
      }
      return;
    }

    final db = await _database;
    await db.update('transactions', row,
        where: 'id = ? AND profileId = ?',
        whereArgs: [item.id, profileId]);
  }

  @override
  Future<void> deleteTransaction(String id, {required String profileId, bool hardDelete = false}) async {
    if (kIsWeb) {
      final data = _readWebTransactions(profileId);
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
      await _writeWebTransactions(profileId, data);
      return;
    }

    final db = await _database;
    if (hardDelete) {
      await db.delete('transactions',
          where: 'id = ? AND profileId = ?',
          whereArgs: [id, profileId]);
    } else {
      await db.update('transactions',
          {'isDeleted': 1, 'syncStatus': 'pending_delete'},
          where: 'id = ? AND profileId = ?',
          whereArgs: [id, profileId]);
    }
  }

  @override
  Future<List<TransactionItem>> getPendingTransactions({required String profileId}) async {
    if (kIsWeb) {
      final data = _readWebTransactions(profileId)
          .where((r) =>
              r['isDeleted'] == 0 &&
              (r['syncStatus'] == 'pending_create' || r['syncStatus'] == 'pending_update'))
          .toList();
      return data.map((r) => TransactionItem.fromJson(r)).toList();
    }

    final db = await _database;
    final maps = await db.query('transactions',
        where: 'isDeleted = 0 AND profileId = ? AND syncStatus IN (?, ?)',
        whereArgs: [profileId, 'pending_create', 'pending_update']);
    return maps.map((m) => TransactionItem.fromJson(m)).toList();
  }

  @override
  Future<List<String>> getPendingDeleteTransactionIds({required String profileId}) async {
    if (kIsWeb) {
      return _readWebTransactions(profileId)
          .where((r) => r['isDeleted'] == 1 && r['syncStatus'] == 'pending_delete')
          .map((r) => r['id'] as String)
          .toList();
    }

    final db = await _database;
    final maps = await db.query('transactions',
        columns: ['id'],
        where: 'isDeleted = 1 AND profileId = ? AND syncStatus = ?',
        whereArgs: [profileId, 'pending_delete']);
    return maps.map((m) => m['id'] as String).toList();
  }

  @override
  Future<Set<String>> getAllPendingTransactionIds({required String profileId}) async {
    if (kIsWeb) {
      return _readWebTransactions(profileId)
          .where((r) => r['syncStatus'] != 'synced')
          .map((r) => r['id'] as String)
          .toSet();
    }

    final db = await _database;
    final maps = await db.query('transactions',
        columns: ['id'],
        where: 'profileId = ? AND syncStatus != ?',
        whereArgs: [profileId, 'synced']);
    return maps.map((m) => m['id'] as String).toSet();
  }

  @override
  Future<void> markTransactionSynced(String id, {required String profileId}) async {
    if (kIsWeb) {
      final data = _readWebTransactions(profileId);
      final index = data.indexWhere((r) => r['id'] == id);
      if (index != -1) {
        data[index] = {...data[index], 'syncStatus': 'synced'};
        await _writeWebTransactions(profileId, data);
      }
      return;
    }

    final db = await _database;
    await db.update('transactions', {'syncStatus': 'synced'},
        where: 'id = ? AND profileId = ?',
        whereArgs: [id, profileId]);
  }

  // ─── Categories ─────────────────────────────────────────────────

  @override
  Future<List<CategoryItem>> getCategories({required String profileId}) async {
    if (kIsWeb) {
      final data = _readWebCategories(profileId)
          .where((r) => r['isDeleted'] == 0)
          .toList();
      return data.map((r) => CategoryItem.fromJson(r)).toList();
    }

    final db = await _database;
    final maps = await db.query('categories',
        where: 'isDeleted = 0 AND profileId = ?',
        whereArgs: [profileId]);
    return maps.map((m) => CategoryItem.fromJson(m)).toList();
  }

  @override
  Future<void> addCategory(CategoryItem item, {required String profileId, String syncStatus = 'pending_create'}) async {
    final row = {
      ...item.toJson(),
      'syncStatus': syncStatus,
      'isDeleted': 0,
      'profileId': profileId,
    };

    if (kIsWeb) {
      final data = _readWebCategories(profileId);
      data.removeWhere((r) => r['id'] == item.id);
      data.insert(0, row);
      await _writeWebCategories(profileId, data);
      return;
    }

    final db = await _database;
    await db.insert('categories', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> deleteCategory(String id, {required String profileId, bool hardDelete = false}) async {
    if (kIsWeb) {
      final data = _readWebCategories(profileId);
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
      await _writeWebCategories(profileId, data);
      return;
    }

    final db = await _database;
    if (hardDelete) {
      await db.delete('categories',
          where: 'id = ? AND profileId = ?',
          whereArgs: [id, profileId]);
    } else {
      await db.update('categories',
          {'isDeleted': 1, 'syncStatus': 'pending_delete'},
          where: 'id = ? AND profileId = ?',
          whereArgs: [id, profileId]);
    }
  }

  @override
  Future<void> renameCategory(String oldName, String newName, {required bool isIncome, required String profileId}) async {
    if (oldName == newName) return;

    if (kIsWeb) {
      final categories = _readWebCategories(profileId);
      final catIndex = categories.indexWhere(
        (r) => r['name'] == oldName && r['isIncome'] == (isIncome ? 1 : 0) && r['isDeleted'] == 0,
      );
      if (catIndex != -1) {
        categories[catIndex] = {
          ...categories[catIndex],
          'name': newName,
          'syncStatus': 'pending_update',
        };
        await _writeWebCategories(profileId, categories);
      }

      final transactions = _readWebTransactions(profileId);
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
        await _writeWebTransactions(profileId, transactions);
      }
      return;
    }

    final db = await _database;
    await db.transaction((txn) async {
      await txn.update(
        'categories',
        {'name': newName, 'syncStatus': 'pending_update'},
        where: 'name = ? AND isIncome = ? AND isDeleted = 0 AND profileId = ?',
        whereArgs: [oldName, isIncome ? 1 : 0, profileId],
      );
      await txn.update(
        'transactions',
        {'category': newName, 'syncStatus': 'pending_update'},
        where: 'category = ? AND isDeleted = 0 AND profileId = ?',
        whereArgs: [oldName, profileId],
      );
    });
  }

  @override
  Future<List<CategoryItem>> getPendingCategories({required String profileId}) async {
    if (kIsWeb) {
      final data = _readWebCategories(profileId)
          .where((r) =>
              r['isDeleted'] == 0 && r['syncStatus'] == 'pending_create')
          .toList();
      return data.map((r) => CategoryItem.fromJson(r)).toList();
    }

    final db = await _database;
    final maps = await db.query('categories',
        where: 'isDeleted = 0 AND profileId = ? AND syncStatus = ?',
        whereArgs: [profileId, 'pending_create']);
    return maps.map((m) => CategoryItem.fromJson(m)).toList();
  }

  @override
  Future<List<String>> getPendingDeleteCategoryIds({required String profileId}) async {
    if (kIsWeb) {
      return _readWebCategories(profileId)
          .where((r) => r['isDeleted'] == 1 && r['syncStatus'] == 'pending_delete')
          .map((r) => r['id'] as String)
          .toList();
    }

    final db = await _database;
    final maps = await db.query('categories',
        columns: ['id'],
        where: 'isDeleted = 1 AND profileId = ? AND syncStatus = ?',
        whereArgs: [profileId, 'pending_delete']);
    return maps.map((m) => m['id'] as String).toList();
  }

  @override
  Future<Set<String>> getAllPendingCategoryIds({required String profileId}) async {
    if (kIsWeb) {
      return _readWebCategories(profileId)
          .where((r) => r['syncStatus'] != 'synced')
          .map((r) => r['id'] as String)
          .toSet();
    }

    final db = await _database;
    final maps = await db.query('categories',
        columns: ['id'],
        where: 'profileId = ? AND syncStatus != ?',
        whereArgs: [profileId, 'synced']);
    return maps.map((m) => m['id'] as String).toSet();
  }

  @override
  Future<void> markCategorySynced(String id, {required String profileId}) async {
    if (kIsWeb) {
      final data = _readWebCategories(profileId);
      final index = data.indexWhere((r) => r['id'] == id);
      if (index != -1) {
        data[index] = {...data[index], 'syncStatus': 'synced'};
        await _writeWebCategories(profileId, data);
      }
      return;
    }

    final db = await _database;
    await db.update('categories', {'syncStatus': 'synced'},
        where: 'id = ? AND profileId = ?',
        whereArgs: [id, profileId]);
  }
}
