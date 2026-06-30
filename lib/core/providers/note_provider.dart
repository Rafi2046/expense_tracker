import 'package:expense_tracker/core/utils/database_helper.dart';
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
  String _activeProfileId = 'default_profile';

  NoteProvider() {
    _loadNotes();
  }

  List<NoteItem> get notes => List.unmodifiable(_notes);
  bool get isLoading => _isLoading;

  Future<void> _loadNotes() async {
    try {
      _notes = await DatabaseHelper.instance.readAllNotes(profileId: _activeProfileId);
    } catch (e) {
      debugPrint('Error loading notes from SQLite: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateProfileId(String newProfileId) {
    if (newProfileId == _activeProfileId) return;
    _activeProfileId = newProfileId;
    _notes.clear();
    _isLoading = true;
    notifyListeners();
    _loadNotes();
  }

  Future<void> addNote(NoteItem note) async {
    _notes.insert(0, note);
    notifyListeners();
    await DatabaseHelper.instance.insertNote(note, profileId: _activeProfileId);
  }

  Future<void> insertNote(int index, NoteItem note) async {
    if (index >= 0 && index <= _notes.length) {
      _notes.insert(index, note);
    } else {
      _notes.add(note);
    }
    notifyListeners();
    await DatabaseHelper.instance.insertNote(note, profileId: _activeProfileId);
  }

  Future<void> updateNote(NoteItem updatedNote) async {
    final index = _notes.indexWhere((n) => n.id == updatedNote.id);
    if (index != -1) {
      _notes[index] = updatedNote;
      notifyListeners();
      await DatabaseHelper.instance.updateNote(updatedNote, profileId: _activeProfileId);
    }
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
    await DatabaseHelper.instance.deleteNote(id, profileId: _activeProfileId);
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
