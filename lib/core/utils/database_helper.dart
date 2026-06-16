import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../providers/note_provider.dart';
import 'shared_prefs_helper.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static const String _webNotesKey = 'web_notes';

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
      version: 1,
      onCreate: _createDB,
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

  // Close database connection
  Future close() async {
    if (kIsWeb) return;
    final db = await instance.database;
    db.close();
  }
}
