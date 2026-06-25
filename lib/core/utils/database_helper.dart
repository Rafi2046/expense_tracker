import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../providers/note_provider.dart';
import '../providers/transaction_provider.dart';
import 'shared_prefs_helper.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static const String _webNotesKey = 'web_notes';
  static const String _webBudgetKey = 'web_budget';

  DatabaseHelper._init();

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite is not supported on Web.');
    }
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        category TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        note TEXT NOT NULL,
        isIncome INTEGER NOT NULL,
        dateTime TEXT NOT NULL,
        incomeMonth TEXT,
        paymentMethod TEXT NOT NULL DEFAULT 'Cash',
        syncStatus TEXT NOT NULL DEFAULT 'synced',
        isDeleted INTEGER NOT NULL DEFAULT 0,
        lastModified TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE budget (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        syncStatus TEXT NOT NULL DEFAULT 'synced',
        lastModified TEXT NOT NULL
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE transactions (
          id TEXT PRIMARY KEY,
          amount REAL NOT NULL,
          category TEXT NOT NULL,
          note TEXT NOT NULL,
          isIncome INTEGER NOT NULL,
          dateTime TEXT NOT NULL,
          incomeMonth TEXT,
          paymentMethod TEXT NOT NULL DEFAULT 'Cash',
          syncStatus TEXT NOT NULL DEFAULT 'synced',
          isDeleted INTEGER NOT NULL DEFAULT 0,
          lastModified TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE budget (
          id TEXT PRIMARY KEY,
          amount REAL NOT NULL,
          syncStatus TEXT NOT NULL DEFAULT 'synced',
          lastModified TEXT NOT NULL
        )
      ''');
    }
  }

  // Helper method to read web notes
  List<NoteItem> _readWebNotes() {
    final jsonString = SharedPrefsHelper.getString(_webNotesKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((map) => NoteItem.fromJson(map as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error reading web notes: $e');
      return [];
    }
  }

  // Helper method to save web notes
  Future<void> _writeWebNotes(List<NoteItem> notes) async {
    final jsonString = jsonEncode(notes.map((note) => note.toJson()).toList());
    await SharedPrefsHelper.setString(_webNotesKey, jsonString);
  }

  // Insert a note
  Future<void> insertNote(NoteItem note) async {
    if (kIsWeb) {
      final notes = _readWebNotes();
      notes.removeWhere((item) => item.id == note.id);
      notes.insert(0, note);
      await _writeWebNotes(notes);
      return;
    }

    final db = await instance.database;
    await db.insert(
      'notes',
      note.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all notes
  Future<List<NoteItem>> readAllNotes() async {
    if (kIsWeb) {
      final notes = _readWebNotes();
      notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notes;
    }

    final db = await instance.database;
    final maps = await db.query('notes', orderBy: 'createdAt DESC');

    return maps.map((map) => NoteItem.fromJson(map)).toList();
  }

  // Update a note
  Future<int> updateNote(NoteItem note) async {
    if (kIsWeb) {
      final notes = _readWebNotes();
      final index = notes.indexWhere((item) => item.id == note.id);
      if (index != -1) {
        notes[index] = note;
        await _writeWebNotes(notes);
        return 1;
      }
      return 0;
    }

    final db = await instance.database;
    return await db.update(
      'notes',
      note.toJson(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // Delete a note
  Future<int> deleteNote(String id) async {
    if (kIsWeb) {
      final notes = _readWebNotes();
      final lengthBefore = notes.length;
      notes.removeWhere((item) => item.id == id);
      final lengthAfter = notes.length;
      if (lengthBefore != lengthAfter) {
        await _writeWebNotes(notes);
        return 1;
      }
      return 0;
    }

    final db = await instance.database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─── Transaction CRUD ──────────────────────────────────────────

  static const String _webTxKey = 'web_transactions';

  List<Map<String, dynamic>> _readWebTransactions() {
    final jsonString = SharedPrefsHelper.getString(_webTxKey);
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      return (jsonDecode(jsonString) as List<dynamic>)
          .cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error reading web transactions: $e');
      return [];
    }
  }

  Future<void> _writeWebTransactions(List<Map<String, dynamic>> data) async {
    await SharedPrefsHelper.setString(_webTxKey, jsonEncode(data));
  }

  Future<void> insertTransaction(
    TransactionItem item, {
    String syncStatus = 'pending_create',
  }) async {
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

    final db = await instance.database;
    await db.insert('transactions', row,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<TransactionItem>> readAllTransactions() async {
    if (kIsWeb) {
      final data = _readWebTransactions()
          .where((r) => r['isDeleted'] == 0)
          .toList()
        ..sort((a, b) => (b['dateTime'] as String)
            .compareTo(a['dateTime'] as String));
      return data.map((r) => TransactionItem.fromJson(r)).toList();
    }

    final db = await instance.database;
    final maps = await db.query('transactions',
        where: 'isDeleted = 0', orderBy: 'dateTime DESC');
    return maps.map((m) => TransactionItem.fromJson(m)).toList();
  }

  Future<List<TransactionItem>> readPendingSyncs() async {
    if (kIsWeb) {
      final data = _readWebTransactions()
          .where((r) =>
              r['isDeleted'] == 0 &&
              (r['syncStatus'] == 'pending_create' ||
                  r['syncStatus'] == 'pending_update'))
          .toList();
      return data.map((r) => TransactionItem.fromJson(r)).toList();
    }

    final db = await instance.database;
    final maps = await db.query('transactions',
        where:
            'isDeleted = 0 AND syncStatus IN (?, ?)',
        whereArgs: ['pending_create', 'pending_update']);
    return maps.map((m) => TransactionItem.fromJson(m)).toList();
  }

  Future<List<String>> readPendingDeleteIds() async {
    if (kIsWeb) {
      return _readWebTransactions()
          .where((r) => r['isDeleted'] == 1 && r['syncStatus'] == 'pending_delete')
          .map((r) => r['id'] as String)
          .toList();
    }

    final db = await instance.database;
    final maps = await db.query('transactions',
        columns: ['id'],
        where: 'isDeleted = 1 AND syncStatus = ?',
        whereArgs: ['pending_delete']);
    return maps.map((m) => m['id'] as String).toList();
  }

  Future<Set<String>> readAllPendingIds() async {
    if (kIsWeb) {
      return _readWebTransactions()
          .where((r) => r['syncStatus'] != 'synced')
          .map((r) => r['id'] as String)
          .toSet();
    }

    final db = await instance.database;
    final maps = await db.query('transactions',
        columns: ['id'],
        where: 'syncStatus != ?',
        whereArgs: ['synced']);
    return maps.map((m) => m['id'] as String).toSet();
  }

  Future<void> updateTransaction(
    TransactionItem item, {
    String? syncStatus,
  }) async {
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

    final db = await instance.database;
    await db.update('transactions', row,
        where: 'id = ?', whereArgs: [item.id]);
  }

  Future<void> softDeleteTransaction(String id) async {
    if (kIsWeb) {
      final data = _readWebTransactions();
      final index = data.indexWhere((r) => r['id'] == id);
      if (index != -1) {
        data[index] = {
          ...data[index],
          'isDeleted': 1,
          'syncStatus': 'pending_delete',
        };
        await _writeWebTransactions(data);
      }
      return;
    }

    final db = await instance.database;
    await db.update('transactions',
        {'isDeleted': 1, 'syncStatus': 'pending_delete'},
        where: 'id = ?',
        whereArgs: [id]);
  }

  Future<void> hardDeleteTransaction(String id) async {
    if (kIsWeb) {
      final data = _readWebTransactions();
      data.removeWhere((r) => r['id'] == id);
      await _writeWebTransactions(data);
      return;
    }

    final db = await instance.database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markSynced(String id) async {
    if (kIsWeb) {
      final data = _readWebTransactions();
      final index = data.indexWhere((r) => r['id'] == id);
      if (index != -1) {
        data[index] = {...data[index], 'syncStatus': 'synced'};
        await _writeWebTransactions(data);
      }
      return;
    }

    final db = await instance.database;
    await db.update('transactions', {'syncStatus': 'synced'},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<String?> getSyncStatus(String id) async {
    if (kIsWeb) {
      final data = _readWebTransactions();
      final index = data.indexWhere((r) => r['id'] == id);
      if (index == -1) return null;
      return data[index]['syncStatus'] as String?;
    }

    final db = await instance.database;
    final maps = await db.query('transactions',
        columns: ['syncStatus'],
        where: 'id = ?',
        whereArgs: [id]);
    if (maps.isEmpty) return null;
    return maps.first['syncStatus'] as String?;
  }

  // ─── Budget CRUD ───────────────────────────────────────────────

  Map<String, dynamic>? _readWebBudget() {
    final jsonString = SharedPrefsHelper.getString(_webBudgetKey);
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error reading web budget: $e');
      return null;
    }
  }

  Future<void> _writeWebBudget(Map<String, dynamic>? data) async {
    if (data == null) {
      await SharedPrefsHelper.remove(_webBudgetKey);
    } else {
      await SharedPrefsHelper.setString(_webBudgetKey, jsonEncode(data));
    }
  }

  Future<void> insertOrUpdateBudget(double amount, {String syncStatus = 'pending'}) async {
    final row = {
      'id': 'monthly',
      'amount': amount,
      'syncStatus': syncStatus,
      'lastModified': DateTime.now().toIso8601String(),
    };

    if (kIsWeb) {
      await _writeWebBudget(row);
      return;
    }

    final db = await instance.database;
    await db.insert('budget', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<double?> readBudget() async {
    if (kIsWeb) {
      final data = _readWebBudget();
      if (data == null) return null;
      return (data['amount'] as num).toDouble();
    }

    final db = await instance.database;
    final maps = await db.query('budget', where: 'id = ?', whereArgs: ['monthly']);
    if (maps.isEmpty) return null;
    return (maps.first['amount'] as num).toDouble();
  }

  Future<String?> getBudgetSyncStatus() async {
    if (kIsWeb) {
      final data = _readWebBudget();
      if (data == null) return null;
      return data['syncStatus'] as String?;
    }

    final db = await instance.database;
    final maps = await db.query('budget',
        columns: ['syncStatus'],
        where: 'id = ?',
        whereArgs: ['monthly']);
    if (maps.isEmpty) return null;
    return maps.first['syncStatus'] as String?;
  }

  Future<void> markBudgetSynced() async {
    if (kIsWeb) {
      final data = _readWebBudget();
      if (data == null) return;
      await _writeWebBudget({...data, 'syncStatus': 'synced'});
      return;
    }

    final db = await instance.database;
    await db.update('budget', {'syncStatus': 'synced'},
        where: 'id = ?', whereArgs: ['monthly']);
  }

  // Close database connection
  Future close() async {
    if (kIsWeb) return;
    final db = await instance.database;
    db.close();
  }
}
