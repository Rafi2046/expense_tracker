import 'package:flutter/material.dart';

class NoteItem {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final String category; // 'Business', 'Personal', 'General'

  NoteItem({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.category,
  });

  NoteItem copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    String? category,
  }) {
    return NoteItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
    );
  }
}

class NoteProvider extends ChangeNotifier {
  final List<NoteItem> _notes = [
    NoteItem(
      id: '1',
      title: 'Business Startup Plans',
      content: '1. Finalize the budget sheet.\n2. Review target audience demographic.\n3. Apply for local trade licenses.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      category: 'Business',
    ),
    NoteItem(
      id: '2',
      title: 'Monthly Groceries List',
      content: '- Rice & Lentils\n- Fresh Vegetables\n- Almond Milk\n- Olive Oil',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      category: 'Personal',
    ),
    NoteItem(
      id: '3',
      title: 'General Ledger Ideas',
      content: 'Explore combining payment in and payment out ledgers into a single combined view for easier daily balance checks.',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      category: 'General',
    ),
  ];

  List<NoteItem> get notes => List.unmodifiable(_notes);

  void addNote(NoteItem note) {
    _notes.insert(0, note);
    notifyListeners();
  }

  void updateNote(NoteItem updatedNote) {
    final index = _notes.indexWhere((n) => n.id == updatedNote.id);
    if (index != -1) {
      _notes[index] = updatedNote;
      notifyListeners();
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  List<NoteItem> searchNotes(String query) {
    if (query.isEmpty) return notes;
    final lowercaseQuery = query.toLowerCase();
    return _notes.where((n) {
      return n.title.toLowerCase().contains(lowercaseQuery) ||
          n.content.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}
