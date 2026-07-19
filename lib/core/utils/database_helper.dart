import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/account_model.dart';
import '../providers/note_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/debt_provider.dart';
import 'shared_prefs_helper.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static Completer<void>? _initCompleter;
  static const String _webNotesKey = 'web_notes';
  DatabaseHelper._init();

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite is not supported on Web.');
    }
    if (_database != null) return _database!;
    if (_initCompleter != null) {
      await _initCompleter!.future;
      if (_database != null) return _database!;
    }
    _initCompleter = Completer<void>();
    try {
      _database = await _initDB('notes.db');
      _initCompleter!.complete();
      return _database!;
    } catch (e) {
      _initCompleter!.completeError(e);
      rethrow;
    } finally {
      _initCompleter = null;
    }
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

      return await openDatabase(
        path,
        version: 17,
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
        category TEXT NOT NULL,
        profileId TEXT NOT NULL DEFAULT 'default_profile'
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
        lastModified TEXT NOT NULL,
        profileId TEXT NOT NULL DEFAULT 'default_profile',
        partyName TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE budget (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        syncStatus TEXT NOT NULL DEFAULT 'synced',
        lastModified TEXT NOT NULL,
        profileId TEXT NOT NULL DEFAULT 'default_profile'
      )
    ''');
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        isIncome INTEGER NOT NULL,
        syncStatus TEXT NOT NULL DEFAULT 'synced',
        isDeleted INTEGER NOT NULL DEFAULT 0,
        lastModified TEXT NOT NULL,
        profileId TEXT NOT NULL DEFAULT 'default_profile'
      )
    ''');
    await db.execute('''
      CREATE TABLE debt_items (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        detail TEXT NOT NULL,
        amount REAL NOT NULL,
        isReceive INTEGER NOT NULL,
        isSettled INTEGER NOT NULL DEFAULT 0,
        phone TEXT,
        email TEXT,
        address TEXT,
        vat TEXT,
        createdAt TEXT NOT NULL,
        syncStatus TEXT NOT NULL DEFAULT 'synced',
        isDeleted INTEGER NOT NULL DEFAULT 0,
        profileId TEXT NOT NULL DEFAULT 'default_profile'
      )
    ''');
    await db.execute('''
      CREATE TABLE profiles (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        uid TEXT
      )
    ''');
    await db.insert('profiles', {
      'id': 'default_profile',
      'name': 'Personal',
      'type': 'Personal',
      'createdAt': DateTime.now().toIso8601String(),
    });

    await db.execute('''
      CREATE TABLE accounts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        initialBalance REAL NOT NULL DEFAULT 0.0,
        createdAt TEXT NOT NULL,
        profileId TEXT NOT NULL DEFAULT 'default_profile'
      )
    ''');
    final defaultAccounts = [
      {'id': 'account_cash', 'name': 'Cash', 'type': 'Cash', 'initialBalance': 0.0, 'createdAt': DateTime.now().toIso8601String(), 'profileId': 'default_profile'},
      {'id': 'account_bank', 'name': 'Bank', 'type': 'Bank', 'initialBalance': 0.0, 'createdAt': DateTime.now().toIso8601String(), 'profileId': 'default_profile'},
    ];
    for (final a in defaultAccounts) {
      await db.insert('accounts', a);
    }

    await db.execute('''
      CREATE TABLE tours (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        coverPhoto TEXT,
        currency TEXT NOT NULL DEFAULT 'BDT',
        createdAt TEXT NOT NULL,
        profileId TEXT NOT NULL DEFAULT 'default_profile',
        syncStatus TEXT NOT NULL DEFAULT 'synced',
        isDeleted INTEGER NOT NULL DEFAULT 0,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        lastModified TEXT NOT NULL,
        inviteCode TEXT,
        ownerUid TEXT,
        memberUids TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE tour_participants (
        id TEXT PRIMARY KEY,
        tourId TEXT NOT NULL,
        name TEXT NOT NULL,
        avatarColor INTEGER NOT NULL DEFAULT 0,
        joinedAt TEXT NOT NULL,
        joinedExpenseId TEXT,
        isActive INTEGER NOT NULL DEFAULT 1,
        syncStatus TEXT NOT NULL DEFAULT 'synced',
        isDeleted INTEGER NOT NULL DEFAULT 0,
        lastModified TEXT NOT NULL,
        uid TEXT,
        photoUrl TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE tour_expenses (
        id TEXT PRIMARY KEY,
        tourId TEXT NOT NULL,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        paidBy TEXT NOT NULL,
        splitType TEXT NOT NULL DEFAULT 'equal',
        category TEXT,
        note TEXT,
        date TEXT NOT NULL,
        receiptPath TEXT,
        createdAt TEXT NOT NULL,
        syncStatus TEXT NOT NULL DEFAULT 'synced',
        isDeleted INTEGER NOT NULL DEFAULT 0,
        lastModified TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE tour_expense_shares (
        id TEXT PRIMARY KEY,
        expenseId TEXT NOT NULL,
        participantId TEXT NOT NULL,
        shareAmount REAL NOT NULL,
        customValue REAL,
        isExcluded INTEGER NOT NULL DEFAULT 0,
        syncStatus TEXT NOT NULL DEFAULT 'synced',
        isDeleted INTEGER NOT NULL DEFAULT 0,
        lastModified TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE tour_settlements (
        id TEXT PRIMARY KEY,
        tourId TEXT NOT NULL,
        fromParticipant TEXT NOT NULL,
        toParticipant TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        syncStatus TEXT NOT NULL DEFAULT 'synced',
        isDeleted INTEGER NOT NULL DEFAULT 0,
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
          lastModified TEXT NOT NULL,
          profileId TEXT NOT NULL DEFAULT 'default_profile'
        )
      ''');
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE categories (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          isIncome INTEGER NOT NULL,
          syncStatus TEXT NOT NULL DEFAULT 'synced',
          isDeleted INTEGER NOT NULL DEFAULT 0,
          lastModified TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE debt_items (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          detail TEXT NOT NULL,
          amount REAL NOT NULL,
          isReceive INTEGER NOT NULL,
          isSettled INTEGER NOT NULL DEFAULT 0,
          phone TEXT,
          email TEXT,
          address TEXT,
          vat TEXT,
          createdAt TEXT NOT NULL,
          syncStatus TEXT NOT NULL DEFAULT 'synced',
          isDeleted INTEGER NOT NULL DEFAULT 0
        )
      ''');
    }
    if (oldVersion < 6) {
      await db.execute('''
        ALTER TABLE transactions ADD COLUMN profileId TEXT NOT NULL DEFAULT 'default_profile'
      ''');
      await db.execute('''
        ALTER TABLE categories ADD COLUMN profileId TEXT NOT NULL DEFAULT 'default_profile'
      ''');
      await db.execute('''
        ALTER TABLE debt_items ADD COLUMN profileId TEXT NOT NULL DEFAULT 'default_profile'
      ''');
      await db.execute('''
        ALTER TABLE notes ADD COLUMN profileId TEXT NOT NULL DEFAULT 'default_profile'
      ''');
      await db.execute('''
        CREATE TABLE profiles (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          uid TEXT
        )
      ''');
      await db.insert('profiles', {
        'id': 'default_profile',
        'name': 'Personal',
        'type': 'Personal',
        'createdAt': DateTime.now().toIso8601String(),
      });
    }
    if (oldVersion < 7) {
      final columns = await db.rawQuery('PRAGMA table_info(transactions)');
      final hasPartyName = columns.any((col) => col['name'] == 'partyName');
      if (!hasPartyName) {
        await db.execute('ALTER TABLE transactions ADD COLUMN partyName TEXT');
      }
    }
    if (oldVersion < 8) {
      final columns = await db.rawQuery('PRAGMA table_info(budget)');
      final hasProfileId = columns.any((col) => col['name'] == 'profileId');
      if (!hasProfileId) {
        await db.execute('ALTER TABLE budget ADD COLUMN profileId TEXT NOT NULL DEFAULT \'default_profile\'');
      }
    }
    if (oldVersion < 9) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tours (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          coverPhoto TEXT,
          currency TEXT NOT NULL DEFAULT 'BDT',
          createdAt TEXT NOT NULL,
          profileId TEXT NOT NULL DEFAULT 'default_profile',
          syncStatus TEXT NOT NULL DEFAULT 'synced',
          isDeleted INTEGER NOT NULL DEFAULT 0,
          lastModified TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tour_participants (
          id TEXT PRIMARY KEY,
          tourId TEXT NOT NULL,
          name TEXT NOT NULL,
          avatarColor INTEGER NOT NULL DEFAULT 0,
          joinedAt TEXT NOT NULL,
          joinedExpenseId TEXT,
          isActive INTEGER NOT NULL DEFAULT 1,
          syncStatus TEXT NOT NULL DEFAULT 'synced',
          isDeleted INTEGER NOT NULL DEFAULT 0,
          lastModified TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tour_expenses (
          id TEXT PRIMARY KEY,
          tourId TEXT NOT NULL,
          title TEXT NOT NULL,
          amount REAL NOT NULL,
          paidBy TEXT NOT NULL,
          splitType TEXT NOT NULL DEFAULT 'equal',
          category TEXT,
          note TEXT,
          date TEXT NOT NULL,
          receiptPath TEXT,
          createdAt TEXT NOT NULL,
          syncStatus TEXT NOT NULL DEFAULT 'synced',
          isDeleted INTEGER NOT NULL DEFAULT 0,
          lastModified TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tour_expense_shares (
          id TEXT PRIMARY KEY,
          expenseId TEXT NOT NULL,
          participantId TEXT NOT NULL,
          shareAmount REAL NOT NULL,
          customValue REAL,
          isExcluded INTEGER NOT NULL DEFAULT 0,
          syncStatus TEXT NOT NULL DEFAULT 'synced',
          isDeleted INTEGER NOT NULL DEFAULT 0,
          lastModified TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tour_settlements (
          id TEXT PRIMARY KEY,
          tourId TEXT NOT NULL,
          fromParticipant TEXT NOT NULL,
          toParticipant TEXT NOT NULL,
          amount REAL NOT NULL,
          date TEXT NOT NULL,
          note TEXT,
          syncStatus TEXT NOT NULL DEFAULT 'synced',
          isDeleted INTEGER NOT NULL DEFAULT 0,
          lastModified TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 10) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tours (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          coverPhoto TEXT,
          currency TEXT NOT NULL DEFAULT 'BDT',
          createdAt TEXT NOT NULL,
          profileId TEXT NOT NULL DEFAULT 'default_profile',
          syncStatus TEXT NOT NULL DEFAULT 'synced',
          isDeleted INTEGER NOT NULL DEFAULT 0,
          lastModified TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tour_participants (
          id TEXT PRIMARY KEY,
          tourId TEXT NOT NULL,
          name TEXT NOT NULL,
          avatarColor INTEGER NOT NULL DEFAULT 0,
          joinedAt TEXT NOT NULL,
          joinedExpenseId TEXT,
          isActive INTEGER NOT NULL DEFAULT 1,
          syncStatus TEXT NOT NULL DEFAULT 'synced',
          isDeleted INTEGER NOT NULL DEFAULT 0,
          lastModified TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tour_expenses (
          id TEXT PRIMARY KEY,
          tourId TEXT NOT NULL,
          title TEXT NOT NULL,
          amount REAL NOT NULL,
          paidBy TEXT NOT NULL,
          splitType TEXT NOT NULL DEFAULT 'equal',
          category TEXT,
          note TEXT,
          date TEXT NOT NULL,
          receiptPath TEXT,
          createdAt TEXT NOT NULL,
          syncStatus TEXT NOT NULL DEFAULT 'synced',
          isDeleted INTEGER NOT NULL DEFAULT 0,
          lastModified TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tour_expense_shares (
          id TEXT PRIMARY KEY,
          expenseId TEXT NOT NULL,
          participantId TEXT NOT NULL,
          shareAmount REAL NOT NULL,
          customValue REAL,
          isExcluded INTEGER NOT NULL DEFAULT 0,
          syncStatus TEXT NOT NULL DEFAULT 'synced',
          isDeleted INTEGER NOT NULL DEFAULT 0,
          lastModified TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tour_settlements (
          id TEXT PRIMARY KEY,
          tourId TEXT NOT NULL,
          fromParticipant TEXT NOT NULL,
          toParticipant TEXT NOT NULL,
          amount REAL NOT NULL,
          date TEXT NOT NULL,
          note TEXT,
          syncStatus TEXT NOT NULL DEFAULT 'synced',
          isDeleted INTEGER NOT NULL DEFAULT 0,
          lastModified TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 11) {
      final columns = await db.rawQuery('PRAGMA table_info(tours)');
      final hasCompleted = columns.any((col) => col['name'] == 'isCompleted');
      if (!hasCompleted) {
        await db.execute('ALTER TABLE tours ADD COLUMN isCompleted INTEGER NOT NULL DEFAULT 0');
      }
    }
    if (oldVersion < 12) {
      final columns = await db.rawQuery('PRAGMA table_info(profiles)');
      final hasUid = columns.any((col) => col['name'] == 'uid');
      if (!hasUid) {
        await db.execute('ALTER TABLE profiles ADD COLUMN uid TEXT');
      }
    }
    if (oldVersion < 13) {
      final columns = await db.rawQuery('PRAGMA table_info(tours)');
      final hasCompleted = columns.any((col) => col['name'] == 'isCompleted');
      if (!hasCompleted) {
        await db.execute('ALTER TABLE tours ADD COLUMN isCompleted INTEGER NOT NULL DEFAULT 0');
      }
    }
    if (oldVersion < 14) {
      await db.execute('ALTER TABLE tours ADD COLUMN inviteCode TEXT');
      await db.execute('ALTER TABLE tours ADD COLUMN ownerUid TEXT');
      await db.execute('ALTER TABLE tour_participants ADD COLUMN uid TEXT');
    }
    if (oldVersion < 15) {
      final columns = await db.rawQuery('PRAGMA table_info(tours)');
      final hasMemberUids = columns.any((col) => col['name'] == 'memberUids');
      if (!hasMemberUids) {
        await db.execute('ALTER TABLE tours ADD COLUMN memberUids TEXT');
      }
    }
    if (oldVersion < 16) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS accounts (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          initialBalance REAL NOT NULL DEFAULT 0.0,
          createdAt TEXT NOT NULL,
          profileId TEXT NOT NULL DEFAULT 'default_profile'
        )
      ''');
      final existing = await db.query('accounts', where: 'id = ?', whereArgs: ['account_cash']);
      if (existing.isEmpty) {
        await db.insert('accounts', {
          'id': 'account_cash', 'name': 'Cash', 'type': 'Cash',
          'initialBalance': 0.0, 'createdAt': DateTime.now().toIso8601String(), 'profileId': 'default_profile',
        });
        await db.insert('accounts', {
          'id': 'account_bank', 'name': 'Bank', 'type': 'Bank',
          'initialBalance': 0.0, 'createdAt': DateTime.now().toIso8601String(), 'profileId': 'default_profile',
        });
      }
    }
    if (oldVersion < 17) {
      final columns = await db.rawQuery('PRAGMA table_info(tour_participants)');
      final hasPhotoUrl = columns.any((col) => col['name'] == 'photoUrl');
      if (!hasPhotoUrl) {
        await db.execute('ALTER TABLE tour_participants ADD COLUMN photoUrl TEXT');
      }
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
  Future<void> insertNote(NoteItem note, {String profileId = 'default_profile'}) async {
    if (kIsWeb) {
      final notes = _readWebNotes();
      notes.removeWhere((item) => item.id == note.id);
      notes.insert(0, note);
      await _writeWebNotes(notes);
      return;
    }

    final data = note.toJson()..['profileId'] = profileId;
    final db = await instance.database;
    await db.insert(
      'notes',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all notes
  Future<List<NoteItem>> readAllNotes({String profileId = 'default_profile'}) async {
    if (kIsWeb) {
      final notes = _readWebNotes();
      notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notes;
    }

    final db = await instance.database;
    final maps = await db.query('notes',
      where: 'profileId = ?',
      whereArgs: [profileId],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => NoteItem.fromJson(map)).toList();
  }

  // Update a note
  Future<int> updateNote(NoteItem note, {String profileId = 'default_profile'}) async {
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
      where: 'id = ? AND profileId = ?',
      whereArgs: [note.id, profileId],
    );
  }

  // Delete a note
  Future<int> deleteNote(String id, {String profileId = 'default_profile'}) async {
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
      where: 'id = ? AND profileId = ?',
      whereArgs: [id, profileId],
    );
  }

  // ─── Transaction CRUD ──────────────────────────────────────────

  List<Map<String, dynamic>> _readWebTransactions(String profileId) {
    final key = 'web_transactions_$profileId';
    final jsonString = SharedPrefsHelper.getString(key);
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      return (jsonDecode(jsonString) as List<dynamic>)
          .cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error reading web transactions: $e');
      return [];
    }
  }

  Future<void> _writeWebTransactions(String profileId, List<Map<String, dynamic>> data) async {
    final key = 'web_transactions_$profileId';
    await SharedPrefsHelper.setString(key, jsonEncode(data));
  }

  Future<void> insertTransaction(
    TransactionItem item, {
    String syncStatus = 'pending_create',
    String profileId = 'default_profile',
  }) async {
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

    final db = await instance.database;
    await db.insert('transactions', row,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<TransactionItem>> readAllTransactions({String profileId = 'default_profile'}) async {
    if (kIsWeb) {
      final data = _readWebTransactions(profileId)
          .where((r) => r['isDeleted'] == 0)
          .toList()
        ..sort((a, b) => (b['dateTime'] as String)
            .compareTo(a['dateTime'] as String));
      return data.map((r) => TransactionItem.fromJson(r)).toList();
    }

    final db = await instance.database;
    final maps = await db.query('transactions',
        where: 'isDeleted = 0 AND profileId = ?',
        whereArgs: [profileId],
        orderBy: 'dateTime DESC');
    return maps.map((m) => TransactionItem.fromJson(m)).toList();
  }

  Future<List<TransactionItem>> readPendingSyncs({String profileId = 'default_profile'}) async {
    if (kIsWeb) {
      final data = _readWebTransactions(profileId)
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
            'isDeleted = 0 AND profileId = ? AND syncStatus IN (?, ?)',
        whereArgs: [profileId, 'pending_create', 'pending_update']);
    return maps.map((m) => TransactionItem.fromJson(m)).toList();
  }

  Future<List<String>> readPendingDeleteIds({String profileId = 'default_profile'}) async {
    if (kIsWeb) {
      return _readWebTransactions(profileId)
          .where((r) => r['isDeleted'] == 1 && r['syncStatus'] == 'pending_delete')
          .map((r) => r['id'] as String)
          .toList();
    }

    final db = await instance.database;
    final maps = await db.query('transactions',
        columns: ['id'],
        where: 'isDeleted = 1 AND profileId = ? AND syncStatus = ?',
        whereArgs: [profileId, 'pending_delete']);
    return maps.map((m) => m['id'] as String).toList();
  }

  Future<Set<String>> readAllPendingIds({String profileId = 'default_profile'}) async {
    if (kIsWeb) {
      return _readWebTransactions(profileId)
          .where((r) => r['syncStatus'] != 'synced')
          .map((r) => r['id'] as String)
          .toSet();
    }

    final db = await instance.database;
    final maps = await db.query('transactions',
        columns: ['id'],
        where: 'profileId = ? AND syncStatus != ?',
        whereArgs: [profileId, 'synced']);
    return maps.map((m) => m['id'] as String).toSet();
  }

  Future<void> updateTransaction(
    TransactionItem item, {
    String? syncStatus,
    String profileId = 'default_profile',
  }) async {
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

    final db = await instance.database;
    await db.update('transactions', row,
        where: 'id = ? AND profileId = ?',
        whereArgs: [item.id, profileId]);
  }

  Future<List<String>> getDistinctPaymentMethods({String profileId = 'default_profile'}) async {
    if (kIsWeb) {
      final data = _readWebTransactions(profileId);
      final methods = data.where((r) => r['isDeleted'] == 0).map((r) => r['paymentMethod'] as String).toSet();
      return methods.toList();
    }

    final db = await instance.database;
    final maps = await db.rawQuery(
      'SELECT DISTINCT paymentMethod FROM transactions WHERE isDeleted = 0 AND profileId = ?',
      [profileId],
    );
    return maps.map((m) => m['paymentMethod'] as String).toList();
  }

  Future<void> deleteTransactionsByPaymentMethod(String paymentMethod, {String profileId = 'default_profile'}) async {
    if (kIsWeb) {
      final data = _readWebTransactions(profileId);
      bool changed = false;
      for (int i = 0; i < data.length; i++) {
        if (data[i]['paymentMethod'] == paymentMethod && data[i]['isDeleted'] == 0) {
          data[i] = {...data[i], 'isDeleted': 1, 'syncStatus': 'pending_delete'};
          changed = true;
        }
      }
      if (changed) await _writeWebTransactions(profileId, data);
      return;
    }

    final db = await instance.database;
    await db.update('transactions',
      {'isDeleted': 1, 'syncStatus': 'pending_delete'},
      where: 'paymentMethod = ? AND isDeleted = 0 AND profileId = ?',
      whereArgs: [paymentMethod, profileId],
    );
  }

  Future<void> updateTransactionsPaymentMethod(
    String oldMethod,
    String newMethod, {
    String profileId = 'default_profile',
  }) async {
    if (kIsWeb) {
      final data = _readWebTransactions(profileId);
      bool changed = false;
      for (int i = 0; i < data.length; i++) {
        if (data[i]['paymentMethod'] == oldMethod) {
          data[i] = {...data[i], 'paymentMethod': newMethod, 'syncStatus': 'pending_update'};
          changed = true;
        }
      }
      if (changed) await _writeWebTransactions(profileId, data);
      return;
    }

    final db = await instance.database;
    await db.update('transactions',
      {'paymentMethod': newMethod, 'syncStatus': 'pending_update'},
      where: 'paymentMethod = ? AND profileId = ?',
      whereArgs: [oldMethod, profileId],
    );
  }

  Future<void> softDeleteTransaction(String id, {String profileId = 'default_profile'}) async {
    if (kIsWeb) {
      final data = _readWebTransactions(profileId);
      final index = data.indexWhere((r) => r['id'] == id);
      if (index != -1) {
        data[index] = {
          ...data[index],
          'isDeleted': 1,
          'syncStatus': 'pending_delete',
        };
        await _writeWebTransactions(profileId, data);
      }
      return;
    }

    final db = await instance.database;
    await db.update('transactions',
        {'isDeleted': 1, 'syncStatus': 'pending_delete'},
        where: 'id = ? AND profileId = ?',
        whereArgs: [id, profileId]);
  }

  Future<void> hardDeleteTransaction(String id, {String profileId = 'default_profile'}) async {
    if (kIsWeb) {
      final data = _readWebTransactions(profileId);
      data.removeWhere((r) => r['id'] == id);
      await _writeWebTransactions(profileId, data);
      return;
    }

    final db = await instance.database;
    await db.delete('transactions',
        where: 'id = ? AND profileId = ?',
        whereArgs: [id, profileId]);
  }

  Future<void> markSynced(String id, {String profileId = 'default_profile'}) async {
    if (kIsWeb) {
      final data = _readWebTransactions(profileId);
      final index = data.indexWhere((r) => r['id'] == id);
      if (index != -1) {
        data[index] = {...data[index], 'syncStatus': 'synced'};
        await _writeWebTransactions(profileId, data);
      }
      return;
    }

    final db = await instance.database;
    await db.update('transactions', {'syncStatus': 'synced'},
        where: 'id = ? AND profileId = ?',
        whereArgs: [id, profileId]);
  }

  Future<String?> getSyncStatus(String id, {String profileId = 'default_profile'}) async {
    if (kIsWeb) {
      final data = _readWebTransactions(profileId);
      final index = data.indexWhere((r) => r['id'] == id);
      if (index == -1) return null;
      return data[index]['syncStatus'] as String?;
    }

    final db = await instance.database;
    final maps = await db.query('transactions',
        columns: ['syncStatus'],
        where: 'id = ? AND profileId = ?',
        whereArgs: [id, profileId]);
    if (maps.isEmpty) return null;
    return maps.first['syncStatus'] as String?;
  }

  // ─── Budget CRUD ───────────────────────────────────────────────

  Map<String, dynamic>? _readWebBudget(String profileId) {
    final key = 'web_budget_$profileId';
    final jsonString = SharedPrefsHelper.getString(key);
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error reading web budget: $e');
      return null;
    }
  }

  Future<void> _writeWebBudget(String profileId, Map<String, dynamic>? data) async {
    final key = 'web_budget_$profileId';
    if (data == null) {
      await SharedPrefsHelper.remove(key);
    } else {
      await SharedPrefsHelper.setString(key, jsonEncode(data));
    }
  }

  Future<void> insertOrUpdateBudget(double amount, {String syncStatus = 'pending', String profileId = 'default_profile'}) async {
    final row = {
      'id': 'monthly',
      'amount': amount,
      'syncStatus': syncStatus,
      'lastModified': DateTime.now().toIso8601String(),
      'profileId': profileId,
    };

    if (kIsWeb) {
      await _writeWebBudget(profileId, row);
      return;
    }

    final db = await instance.database;
    await db.insert('budget', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<double?> readBudget({String profileId = 'default_profile'}) async {
    if (kIsWeb) {
      final data = _readWebBudget(profileId);
      if (data == null) return null;
      return (data['amount'] as num).toDouble();
    }

    final db = await instance.database;
    final maps = await db.query('budget',
        where: 'id = ? AND profileId = ?',
        whereArgs: ['monthly', profileId]);
    if (maps.isEmpty) return null;
    return (maps.first['amount'] as num).toDouble();
  }

  Future<String?> getBudgetSyncStatus({String profileId = 'default_profile'}) async {
    if (kIsWeb) {
      final data = _readWebBudget(profileId);
      if (data == null) return null;
      return data['syncStatus'] as String?;
    }

    final db = await instance.database;
    final maps = await db.query('budget',
        columns: ['syncStatus'],
        where: 'id = ? AND profileId = ?',
        whereArgs: ['monthly', profileId]);
    if (maps.isEmpty) return null;
    return maps.first['syncStatus'] as String?;
  }

  Future<void> markBudgetSynced({String profileId = 'default_profile'}) async {
    if (kIsWeb) {
      final data = _readWebBudget(profileId);
      if (data == null) return;
      await _writeWebBudget(profileId, {...data, 'syncStatus': 'synced'});
      return;
    }

    final db = await instance.database;
    await db.update('budget', {'syncStatus': 'synced'},
        where: 'id = ? AND profileId = ?',
        whereArgs: ['monthly', profileId]);
  }

  // ─── Category CRUD ─────────────────────────────────────────────

  List<Map<String, dynamic>> _readWebCategories(String profileId) {
    final key = 'web_categories_$profileId';
    final jsonString = SharedPrefsHelper.getString(key);
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      return (jsonDecode(jsonString) as List<dynamic>).cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error reading web categories: $e');
      return [];
    }
  }

  Future<void> _writeWebCategories(String profileId, List<Map<String, dynamic>> data) async {
    final key = 'web_categories_$profileId';
    await SharedPrefsHelper.setString(key, jsonEncode(data));
  }

  Future<void> insertCategory(
    CategoryItem item, {
    String syncStatus = 'pending_create',
    String profileId = 'default_profile',
  }) async {
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

    final db = await instance.database;
    await db.insert('categories', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<CategoryItem>> readAllCategories({String profileId = 'default_profile'}) async {
    if (kIsWeb) {
      final data = _readWebCategories(profileId)
          .where((r) => r['isDeleted'] == 0)
          .toList();
      return data.map((r) => CategoryItem.fromJson(r)).toList();
    }

    final db = await instance.database;
    final maps = await db.query('categories',
        where: 'isDeleted = 0 AND profileId = ?',
        whereArgs: [profileId]);
    return maps.map((m) => CategoryItem.fromJson(m)).toList();
  }

  Future<List<CategoryItem>> readPendingCategorySyncs({String profileId = 'default_profile'}) async {
    if (kIsWeb) {
      final data = _readWebCategories(profileId)
          .where((r) =>
              r['isDeleted'] == 0 &&
              r['syncStatus'] == 'pending_create')
          .toList();
      return data.map((r) => CategoryItem.fromJson(r)).toList();
    }

    final db = await instance.database;
    final maps = await db.query('categories',
        where: 'isDeleted = 0 AND profileId = ? AND syncStatus = ?',
        whereArgs: [profileId, 'pending_create']);
    return maps.map((m) => CategoryItem.fromJson(m)).toList();
  }

  Future<List<String>> readPendingCategoryDeleteIds({String profileId = 'default_profile'}) async {
    if (kIsWeb) {
      return _readWebCategories(profileId)
          .where((r) => r['isDeleted'] == 1 && r['syncStatus'] == 'pending_delete')
          .map((r) => r['id'] as String)
          .toList();
    }

    final db = await instance.database;
    final maps = await db.query('categories',
        columns: ['id'],
        where: 'isDeleted = 1 AND profileId = ? AND syncStatus = ?',
        whereArgs: [profileId, 'pending_delete']);
    return maps.map((m) => m['id'] as String).toList();
  }

  Future<Set<String>> readAllPendingCategoryIds({String profileId = 'default_profile'}) async {
    if (kIsWeb) {
      return _readWebCategories(profileId)
          .where((r) => r['syncStatus'] != 'synced')
          .map((r) => r['id'] as String)
          .toSet();
    }

    final db = await instance.database;
    final maps = await db.query('categories',
        columns: ['id'],
        where: 'profileId = ? AND syncStatus != ?',
        whereArgs: [profileId, 'synced']);
    return maps.map((m) => m['id'] as String).toSet();
  }

  Future<void> softDeleteCategory(String id, {String profileId = 'default_profile'}) async {
    if (kIsWeb) {
      final data = _readWebCategories(profileId);
      final index = data.indexWhere((r) => r['id'] == id);
      if (index != -1) {
        data[index] = {
          ...data[index],
          'isDeleted': 1,
          'syncStatus': 'pending_delete',
        };
        await _writeWebCategories(profileId, data);
      }
      return;
    }

    final db = await instance.database;
    await db.update('categories',
        {'isDeleted': 1, 'syncStatus': 'pending_delete'},
        where: 'id = ? AND profileId = ?',
        whereArgs: [id, profileId]);
  }

  Future<void> hardDeleteCategory(String id, {String profileId = 'default_profile'}) async {
    if (kIsWeb) {
      final data = _readWebCategories(profileId);
      data.removeWhere((r) => r['id'] == id);
      await _writeWebCategories(profileId, data);
      return;
    }

    final db = await instance.database;
    await db.delete('categories',
        where: 'id = ? AND profileId = ?',
        whereArgs: [id, profileId]);
  }

  Future<void> renameCategory(String oldName, String newName, {required bool isIncome, String profileId = 'default_profile'}) async {
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

    final db = await instance.database;
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

  Future<void> markCategorySynced(String id, {String profileId = 'default_profile'}) async {
    if (kIsWeb) {
      final data = _readWebCategories(profileId);
      final index = data.indexWhere((r) => r['id'] == id);
      if (index != -1) {
        data[index] = {...data[index], 'syncStatus': 'synced'};
        await _writeWebCategories(profileId, data);
      }
      return;
    }

    final db = await instance.database;
    await db.update('categories', {'syncStatus': 'synced'},
        where: 'id = ? AND profileId = ?',
        whereArgs: [id, profileId]);
  }

  // ─── Debt Items CRUD ───────────────────────────────────────────

  List<Map<String, dynamic>> _readWebDebtItems(String profileId) {
    final key = 'web_debt_items_$profileId';
    final jsonString = SharedPrefsHelper.getString(key);
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      return (jsonDecode(jsonString) as List<dynamic>).cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error reading web debt items: $e');
      return [];
    }
  }

  Future<void> _writeWebDebtItems(String profileId, List<Map<String, dynamic>> data) async {
    final key = 'web_debt_items_$profileId';
    await SharedPrefsHelper.setString(key, jsonEncode(data));
  }

  Future<void> insertDebtItem(
    DebtItem item, {
    String syncStatus = 'pending_create',
    String profileId = 'default_profile',
  }) async {
    final row = {
      ...item.toJson(),
      'syncStatus': syncStatus,
      'isDeleted': 0,
      'profileId': profileId,
    };

    if (kIsWeb) {
      final data = _readWebDebtItems(profileId);
      data.removeWhere((r) => r['id'] == item.id);
      data.insert(0, row);
      await _writeWebDebtItems(profileId, data);
      return;
    }

    final db = await instance.database;
    await db.insert('debt_items', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<DebtItem>> readAllDebtItems({String profileId = 'default_profile'}) async {
    if (kIsWeb) {
      final data = _readWebDebtItems(profileId)
          .where((r) => r['isDeleted'] == 0)
          .toList();
      return data.map((r) => DebtItem.fromJson(r)).toList();
    }

    final db = await instance.database;
    final maps = await db.query('debt_items',
        where: 'isDeleted = 0 AND profileId = ?',
        whereArgs: [profileId]);
    return maps.map((m) => DebtItem.fromJson(m)).toList();
  }

  Future<void> updateDebtItem(
    DebtItem item, {
    String? syncStatus,
    String profileId = 'default_profile',
  }) async {
    final row = item.toJson();
    if (syncStatus != null) row['syncStatus'] = syncStatus;

    if (kIsWeb) {
      final data = _readWebDebtItems(profileId);
      final index = data.indexWhere((r) => r['id'] == item.id);
      if (index != -1) {
        data[index] = {...data[index], ...row};
        await _writeWebDebtItems(profileId, data);
      }
      return;
    }

    final db = await instance.database;
    await db.update('debt_items', row,
        where: 'id = ? AND profileId = ?',
        whereArgs: [item.id, profileId]);
  }

  Future<List<DebtItem>> readPendingDebtSyncs({String profileId = 'default_profile'}) async {
    if (kIsWeb) {
      final data = _readWebDebtItems(profileId)
          .where((r) =>
              r['isDeleted'] == 0 &&
              (r['syncStatus'] == 'pending_create' ||
                  r['syncStatus'] == 'pending_update'))
          .toList();
      return data.map((r) => DebtItem.fromJson(r)).toList();
    }

    final db = await instance.database;
    final maps = await db.query('debt_items',
        where: 'isDeleted = 0 AND profileId = ? AND syncStatus IN (?, ?)',
        whereArgs: [profileId, 'pending_create', 'pending_update']);
    return maps.map((m) => DebtItem.fromJson(m)).toList();
  }

  Future<List<String>> readPendingDebtDeleteIds({String profileId = 'default_profile'}) async {
    if (kIsWeb) {
      return _readWebDebtItems(profileId)
          .where((r) => r['isDeleted'] == 1 && r['syncStatus'] == 'pending_delete')
          .map((r) => r['id'] as String)
          .toList();
    }

    final db = await instance.database;
    final maps = await db.query('debt_items',
        columns: ['id'],
        where: 'isDeleted = 1 AND profileId = ? AND syncStatus = ?',
        whereArgs: [profileId, 'pending_delete']);
    return maps.map((m) => m['id'] as String).toList();
  }

  Future<Set<String>> readAllPendingDebtIds({String profileId = 'default_profile'}) async {
    if (kIsWeb) {
      return _readWebDebtItems(profileId)
          .where((r) => r['syncStatus'] != 'synced')
          .map((r) => r['id'] as String)
          .toSet();
    }

    final db = await instance.database;
    final maps = await db.query('debt_items',
        columns: ['id'],
        where: 'profileId = ? AND syncStatus != ?',
        whereArgs: [profileId, 'synced']);
    return maps.map((m) => m['id'] as String).toSet();
  }

  Future<void> softDeleteDebtItem(String id, {String profileId = 'default_profile'}) async {
    if (kIsWeb) {
      final data = _readWebDebtItems(profileId);
      final index = data.indexWhere((r) => r['id'] == id);
      if (index != -1) {
        data[index] = {
          ...data[index],
          'isDeleted': 1,
          'syncStatus': 'pending_delete',
        };
        await _writeWebDebtItems(profileId, data);
      }
      return;
    }

    final db = await instance.database;
    await db.update('debt_items',
        {'isDeleted': 1, 'syncStatus': 'pending_delete'},
        where: 'id = ? AND profileId = ?',
        whereArgs: [id, profileId]);
  }

  Future<void> hardDeleteDebtItem(String id, {String profileId = 'default_profile'}) async {
    if (kIsWeb) {
      final data = _readWebDebtItems(profileId);
      data.removeWhere((r) => r['id'] == id);
      await _writeWebDebtItems(profileId, data);
      return;
    }

    final db = await instance.database;
    await db.delete('debt_items',
        where: 'id = ? AND profileId = ?',
        whereArgs: [id, profileId]);
  }

  Future<void> markDebtSynced(String id, {String profileId = 'default_profile'}) async {
    if (kIsWeb) {
      final data = _readWebDebtItems(profileId);
      final index = data.indexWhere((r) => r['id'] == id);
      if (index != -1) {
        data[index] = {...data[index], 'syncStatus': 'synced'};
        await _writeWebDebtItems(profileId, data);
      }
      return;
    }

    final db = await instance.database;
    await db.update('debt_items', {'syncStatus': 'synced'},
        where: 'id = ? AND profileId = ?',
        whereArgs: [id, profileId]);
  }

  /// Wipes all user-specific data from SQLite (transactions, categories,
  /// debt_items, budget). Leaves profile definitions intact.
  // ─── PROFILES ──────────────────────────────────────────────────

  Future<void> insertProfile(Map<String, dynamic> profile) async {
    if (kIsWeb) return;
    final db = await instance.database;
    await db.insert('profiles', profile, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> readAllProfiles() async {
    if (kIsWeb) return [];
    final db = await instance.database;
    return db.query('profiles', orderBy: 'createdAt ASC');
  }

  Future<void> updateProfile(String id, Map<String, dynamic> updates) async {
    if (kIsWeb) return;
    final db = await instance.database;
    await db.update('profiles', updates, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteProfile(String id) async {
    if (kIsWeb) return;
    final db = await instance.database;
    await db.delete('profiles', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Account CRUD ─────────────────────────────────────────────

  Future<void> insertAccount(
    AccountModel account, {
    String profileId = 'default_profile',
  }) async {
    final row = {
      ...account.toJson(),
      'profileId': profileId,
    };
    final db = await instance.database;
    await db.insert('accounts', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<AccountModel>> readAllAccounts({String profileId = 'default_profile'}) async {
    final db = await instance.database;
    final maps = await db.query('accounts',
      where: 'profileId = ?',
      whereArgs: [profileId],
      orderBy: 'createdAt ASC',
    );
    return maps.map((m) => AccountModel.fromJson(m)).toList();
  }

  Future<void> updateAccount(AccountModel account, {String profileId = 'default_profile'}) async {
    final db = await instance.database;
    await db.update('accounts', account.toJson(),
      where: 'id = ? AND profileId = ?',
      whereArgs: [account.id, profileId],
    );
  }

  Future<void> deleteAccount(String id, {String profileId = 'default_profile'}) async {
    final db = await instance.database;
    await db.delete('accounts',
      where: 'id = ? AND profileId = ?',
      whereArgs: [id, profileId],
    );
  }

  Future<int> getAccountCount({String profileId = 'default_profile'}) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM accounts WHERE profileId = ?',
      [profileId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Deletes a profile and ALL associated data (transactions, categories,
  /// debt_items, budget, notes) in a single transaction.
  Future<void> deleteProfileAndData(String profileId) async {
    if (kIsWeb) {
      for (final key in [
        'web_transactions_', 'web_categories_', 'web_debt_items_', 'web_budget_', 'web_notes_'
      ]) {
        await SharedPrefsHelper.remove('$key$profileId');
      }
      return;
    }
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.delete('transactions', where: 'profileId = ?', whereArgs: [profileId]);
      await txn.delete('categories', where: 'profileId = ?', whereArgs: [profileId]);
      await txn.delete('debt_items', where: 'profileId = ?', whereArgs: [profileId]);
      await txn.delete('budget', where: 'profileId = ?', whereArgs: [profileId]);
      await txn.delete('notes', where: 'profileId = ?', whereArgs: [profileId]);
      await txn.delete('accounts', where: 'profileId = ?', whereArgs: [profileId]);
      await txn.delete('profiles', where: 'id = ?', whereArgs: [profileId]);
    });
  }

  Future<void> clearUserData() async {
    if (kIsWeb) return;
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.delete('transactions');
      await txn.delete('categories');
      await txn.delete('debt_items');
      await txn.delete('budget');
      await txn.delete('notes');
      await txn.delete('tours');
      await txn.delete('tour_participants');
      await txn.delete('tour_expenses');
      await txn.delete('tour_expense_shares');
      await txn.delete('tour_settlements');
      await txn.delete('profiles');
    });
  }

  Future<void> checkDatabaseEmptyStatus() async {
    if (kIsWeb) return;
    final db = await instance.database;
    final tables = [
      'transactions',
      'categories',
      'debt_items',
      'budget',
      'notes',
      'tours',
      'tour_participants',
      'tour_expenses',
      'tour_expense_shares',
      'tour_settlements',
      'profiles',
    ];
    for (final table in tables) {
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $table'),
      );
      debugPrint('$table remaining: $count');
    }
  }

  // Close database connection
  Future close() async {
    if (kIsWeb) return;
    final db = await instance.database;
    db.close();
  }
}
