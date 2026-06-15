import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../providers/note_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
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

  // Insert a note
  Future<void> insertNote(NoteItem note) async {
    final db = await instance.database;
    await db.insert(
      'notes',
      note.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all notes
  Future<List<NoteItem>> readAllNotes() async {
    final db = await instance.database;
    final maps = await db.query('notes', orderBy: 'createdAt DESC');

    return maps.map((map) => NoteItem.fromJson(map)).toList();
  }

  // Update a note
  Future<int> updateNote(NoteItem note) async {
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
    final db = await instance.database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Close database connection
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
