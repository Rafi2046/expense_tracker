import 'dart:convert';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'category': category,
    };
  }

  factory NoteItem.fromJson(Map<String, dynamic> json) {
    return NoteItem(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      category: json['category'] as String,
    );
  }
}

class NoteProvider extends ChangeNotifier {
  List<NoteItem> _notes = [];
  bool _isLoading = true;

  NoteProvider() {
    _loadNotes();
  }

  List<NoteItem> get notes => List.unmodifiable(_notes);
  bool get isLoading => _isLoading;

  void _loadNotes() {
    try {
      final notesString = SharedPrefsHelper.getString('saved_notes');
      if (notesString != null) {
        final List<dynamic> jsonList = jsonDecode(notesString);
        _notes = jsonList.map((item) => NoteItem.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        // Initial mock notes for first launch
        _notes = [
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
        _saveNotesToPrefs();
      }
    } catch (e) {
      debugPrint('Error loading notes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _saveNotesToPrefs() {
    try {
      final notesString = jsonEncode(_notes.map((n) => n.toJson()).toList());
      SharedPrefsHelper.setString('saved_notes', notesString);
    } catch (e) {
      debugPrint('Error saving notes: $e');
    }
  }

  void addNote(NoteItem note) {
    _notes.insert(0, note);
    notifyListeners();
    _saveNotesToPrefs();
  }

  void insertNote(int index, NoteItem note) {
    if (index >= 0 && index <= _notes.length) {
      _notes.insert(index, note);
    } else {
      _notes.add(note);
    }
    notifyListeners();
    _saveNotesToPrefs();
  }

  void updateNote(NoteItem updatedNote) {
    final index = _notes.indexWhere((n) => n.id == updatedNote.id);
    if (index != -1) {
      _notes[index] = updatedNote;
      notifyListeners();
      _saveNotesToPrefs();
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
    _saveNotesToPrefs();
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
