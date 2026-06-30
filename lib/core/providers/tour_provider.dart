import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../models/tour.dart';
import '../models/tour_participant.dart';
import '../models/tour_expense.dart';
import '../models/tour_expense_share.dart';
import '../models/tour_settlement.dart';
import '../utils/database_helper.dart';

class TourProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  String _activeProfileId;
  bool _isLoading = true;

  List<Tour> _tours = [];
  String? _selectedTourId;

  List<TourParticipant> _participants = [];
  List<TourExpense> _expenses = [];
  List<TourExpenseShare> _shares = [];
  List<TourSettlement> _settlements = [];

  TourProvider({required String initialProfileId})
      : _activeProfileId = initialProfileId {
    _loadTours();
  }

  // ─── Getters ──────────────────────────────────────────────────────

  bool get isLoading => _isLoading;
  String get activeProfileId => _activeProfileId;
  List<Tour> get tours => List.unmodifiable(_tours);
  String? get selectedTourId => _selectedTourId;
  List<TourParticipant> get participants => List.unmodifiable(_participants);
  List<TourExpense> get expenses => List.unmodifiable(_expenses);
  List<TourExpenseShare> get shares => List.unmodifiable(_shares);
  List<TourSettlement> get settlements => List.unmodifiable(_settlements);

  bool get hasSelectedTour => _selectedTourId != null;

  Tour? get selectedTour {
    if (_selectedTourId == null) return null;
    return _tours.cast<Tour?>().firstWhere(
      (t) => t!.id == _selectedTourId,
      orElse: () => null,
    );
  }

  // ─── Profile switching ─────────────────────────────────────────────

  void updateProfileId(String id) {
    if (id == _activeProfileId) return;
    _activeProfileId = id;
    _tours.clear();
    _selectedTourId = null;
    _participants.clear();
    _expenses.clear();
    _shares.clear();
    _settlements.clear();
    _isLoading = true;
    notifyListeners();
    _loadTours();
  }

  // ─── Tour CRUD ─────────────────────────────────────────────────────

  Future<void> _loadTours() async {
    try {
      final db = await _db.database;
      final maps = await db.query(
        'tours',
        where: 'isDeleted = 0 AND profileId = ?',
        whereArgs: [_activeProfileId],
        orderBy: 'createdAt DESC',
      );
      _tours = maps.map((m) => Tour.fromJson(m)).toList();
    } catch (e) {
      debugPrint('TourProvider._loadTours error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTour(Tour tour) async {
    final db = await _db.database;
    await db.insert('tours', tour.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    _tours.insert(0, tour);
    notifyListeners();
    _syncTourToFirestore(tour);
  }

  Future<void> updateTour(Tour tour) async {
    final db = await _db.database;
    final updated = tour.copyWith(lastModified: DateTime.now());
    await db.update(
      'tours',
      updated.toJson(),
      where: 'id = ?',
      whereArgs: [tour.id],
    );
    final idx = _tours.indexWhere((t) => t.id == tour.id);
    if (idx != -1) {
      _tours[idx] = updated;
    }
    if (_selectedTourId == tour.id) {
      _selectedTourId = tour.id;
    }
    notifyListeners();
    _syncTourToFirestore(updated);
  }

  Future<void> deleteTour(String tourId) async {
    final now = DateTime.now().toIso8601String();
    final db = await _db.database;

    await db.transaction((txn) async {
      await txn.update(
        'tours',
        {'isDeleted': 1, 'lastModified': now},
        where: 'id = ?',
        whereArgs: [tourId],
      );
      await txn.delete('tour_participants', where: 'tourId = ?', whereArgs: [tourId]);
      await txn.delete('tour_expenses', where: 'tourId = ?', whereArgs: [tourId]);
      await txn.delete('tour_expense_shares',
          where: 'expenseId IN (SELECT id FROM tour_expenses WHERE tourId = ?)',
          whereArgs: [tourId]);
      await txn.delete('tour_settlements', where: 'tourId = ?', whereArgs: [tourId]);
    });

    _tours.removeWhere((t) => t.id == tourId);
    if (_selectedTourId == tourId) {
      _selectedTourId = null;
      _participants.clear();
      _expenses.clear();
      _shares.clear();
      _settlements.clear();
    }
    notifyListeners();
  }

  // ─── Tour detail loading ────────────────────────────────────────────

  Future<void> selectTour(String tourId) async {
    _selectedTourId = tourId;
    _isLoading = true;
    notifyListeners();
    await _loadTourDetails(tourId);
  }

  Future<void> _loadTourDetails(String tourId) async {
    try {
      final db = await _db.database;

      final participantMaps = await db.query(
        'tour_participants',
        where: 'tourId = ? AND isDeleted = 0',
        whereArgs: [tourId],
        orderBy: 'joinedAt ASC',
      );
      _participants = participantMaps.map((m) => TourParticipant.fromJson(m)).toList();

      final expenseMaps = await db.query(
        'tour_expenses',
        where: 'tourId = ? AND isDeleted = 0',
        whereArgs: [tourId],
        orderBy: 'date DESC',
      );
      _expenses = expenseMaps.map((m) => TourExpense.fromJson(m)).toList();

      final expenseIds = _expenses.map((e) => e.id).toList();
      if (expenseIds.isNotEmpty) {
        final placeholders = expenseIds.map((_) => '?').join(',');
        final shareMaps = await db.rawQuery(
          'SELECT * FROM tour_expense_shares WHERE expenseId IN ($placeholders) AND isDeleted = 0',
          expenseIds,
        );
        _shares = shareMaps.map((m) => TourExpenseShare.fromJson(m)).toList();
      } else {
        _shares.clear();
      }

      final settlementMaps = await db.query(
        'tour_settlements',
        where: 'tourId = ? AND isDeleted = 0',
        whereArgs: [tourId],
        orderBy: 'date ASC',
      );
      _settlements = settlementMaps.map((m) => TourSettlement.fromJson(m)).toList();
    } catch (e) {
      debugPrint('TourProvider._loadTourDetails error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelection() {
    _selectedTourId = null;
    _participants.clear();
    _expenses.clear();
    _shares.clear();
    _settlements.clear();
    notifyListeners();
  }

  // ─── Participant CRUD ───────────────────────────────────────────────

  Future<void> addParticipant(TourParticipant participant) async {
    final db = await _db.database;
    await db.insert(
      'tour_participants',
      participant.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _participants.add(participant);
    notifyListeners();
    _syncParticipantToFirestore(participant);
  }

  Future<void> updateParticipant(TourParticipant participant) async {
    final db = await _db.database;
    await db.update(
      'tour_participants',
      participant.toJson(),
      where: 'id = ?',
      whereArgs: [participant.id],
    );
    final idx = _participants.indexWhere((p) => p.id == participant.id);
    if (idx != -1) {
      _participants[idx] = participant;
    }
    notifyListeners();
    _syncParticipantToFirestore(participant);
  }

  Future<void> removeParticipant(String participantId) async {
    final now = DateTime.now().toIso8601String();
    final db = await _db.database;
    await db.update(
      'tour_participants',
      {'isDeleted': 1, 'lastModified': now},
      where: 'id = ?',
      whereArgs: [participantId],
    );
    final tourId = _participants.firstWhere((p) => p.id == participantId).tourId;
    _participants.removeWhere((p) => p.id == participantId);
    notifyListeners();
    _softDeleteDoc(tourId, 'participants', participantId, now);
  }

  // ─── Expense CRUD ───────────────────────────────────────────────────

  Future<void> addExpense(TourExpense expense, List<TourExpenseShare> shares) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.insert('tour_expenses', expense.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      for (final share in shares) {
        await txn.insert('tour_expense_shares', share.toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
    _expenses.insert(0, expense);
    _shares.addAll(shares);
    notifyListeners();
    _syncExpenseToFirestore(expense, shares);
  }

  Future<void> updateExpense(TourExpense expense, List<TourExpenseShare> shares) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.update(
        'tour_expenses',
        expense.toJson(),
        where: 'id = ?',
        whereArgs: [expense.id],
      );
      await txn.delete('tour_expense_shares',
          where: 'expenseId = ?', whereArgs: [expense.id]);
      for (final share in shares) {
        await txn.insert('tour_expense_shares', share.toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
    final idx = _expenses.indexWhere((e) => e.id == expense.id);
    if (idx != -1) {
      _expenses[idx] = expense;
    }
    _shares.removeWhere((s) => s.expenseId == expense.id);
    _shares.addAll(shares);
    notifyListeners();
    _syncExpenseToFirestore(expense, shares);
  }

  Future<void> deleteExpense(String expenseId) async {
    final now = DateTime.now().toIso8601String();
    final expense = _expenses.firstWhere((e) => e.id == expenseId);
    final tourId = expense.tourId;
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.update(
        'tour_expenses',
        {'isDeleted': 1, 'lastModified': now},
        where: 'id = ?',
        whereArgs: [expenseId],
      );
      await txn.update(
        'tour_expense_shares',
        {'isDeleted': 1, 'lastModified': now},
        where: 'expenseId = ?',
        whereArgs: [expenseId],
      );
    });
    _expenses.removeWhere((e) => e.id == expenseId);
    _shares.removeWhere((s) => s.expenseId == expenseId);
    notifyListeners();
    _softDeleteDoc(tourId, 'expenses', expenseId, now);
  }

  /// Pure calculation of shares for a given expense and active participants.
  /// Does NOT persist — returns the computed share list for the caller to
  /// pass to [addExpense] or [updateExpense].
  List<TourExpenseShare> calculateShares({
    required TourExpense expense,
    required List<TourParticipant> activeParticipants,
    Map<String, double>? customValues,
    List<String>? excludedIds,
  }) {
    final included = activeParticipants
        .where((p) => !(excludedIds?.contains(p.id) ?? false))
        .toList();
    if (included.isEmpty) return [];

    final excluded = activeParticipants
        .where((p) => excludedIds?.contains(p.id) ?? false)
        .toList();

    final result = <TourExpenseShare>[];
    final shareId = DateTime.now().microsecondsSinceEpoch;

    switch (expense.splitType) {
      case 'equal':
        final perHead = (expense.amount / included.length * 100).round() / 100.0;
        final remainder =
            (expense.amount * 100).round() - (perHead * included.length * 100).round();
        for (var i = 0; i < included.length; i++) {
          final amount = (i == 0) ? (perHead + remainder / 100.0) : perHead;
          result.add(TourExpenseShare(
            id: 'share_${shareId}_${included[i].id}',
            expenseId: expense.id,
            participantId: included[i].id,
            shareAmount: (amount * 100).round() / 100.0,
          ));
        }
        break;

      case 'exact':
        for (final p in included) {
          final value = customValues?[p.id] ?? 0;
          result.add(TourExpenseShare(
            id: 'share_${shareId}_${p.id}',
            expenseId: expense.id,
            participantId: p.id,
            shareAmount: (value * 100).round() / 100.0,
            customValue: value,
          ));
        }
        break;

      case 'percentage':
        for (final p in included) {
          final pct = customValues?[p.id] ?? 0;
          final amount = expense.amount * pct / 100;
          result.add(TourExpenseShare(
            id: 'share_${shareId}_${p.id}',
            expenseId: expense.id,
            participantId: p.id,
            shareAmount: (amount * 100).round() / 100.0,
            customValue: pct,
          ));
        }
        break;

      case 'exclusion':
        final perHead = (expense.amount / included.length * 100).round() / 100.0;
        final remainder =
            (expense.amount * 100).round() - (perHead * included.length * 100).round();
        for (var i = 0; i < included.length; i++) {
          final amount = (i == 0) ? (perHead + remainder / 100.0) : perHead;
          result.add(TourExpenseShare(
            id: 'share_${shareId}_${included[i].id}',
            expenseId: expense.id,
            participantId: included[i].id,
            shareAmount: (amount * 100).round() / 100.0,
          ));
        }
        for (final p in excluded) {
          result.add(TourExpenseShare(
            id: 'share_${shareId}_${p.id}',
            expenseId: expense.id,
            participantId: p.id,
            shareAmount: 0,
            isExcluded: true,
          ));
        }
        break;
    }

    return result;
  }

  // ─── Settlement CRUD ────────────────────────────────────────────────

  Future<void> addSettlement(TourSettlement settlement) async {
    final db = await _db.database;
    await db.insert('tour_settlements', settlement.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    _settlements.add(settlement);
    notifyListeners();
    _syncSettlementToFirestore(settlement);
  }

  Future<void> removeSettlement(String settlementId) async {
    final now = DateTime.now().toIso8601String();
    final settlement = _settlements.firstWhere((s) => s.id == settlementId);
    final tourId = settlement.tourId;
    final db = await _db.database;
    await db.update(
      'tour_settlements',
      {'isDeleted': 1, 'lastModified': now},
      where: 'id = ?',
      whereArgs: [settlementId],
    );
    _settlements.removeWhere((s) => s.id == settlementId);
    notifyListeners();
    _softDeleteDoc(tourId, 'settlements', settlementId, now);
  }

  // ─── Fund calculations ──────────────────────────────────────────────

  /// Sum of all settlement amounts for the tour — total money that has
  /// moved through settlements.
  double totalFundCollected(String tourId) {
    return _settlements
        .where((s) => s.tourId == tourId)
        .fold(0.0, (sum, s) => sum + s.amount);
  }

  /// Net cash a given participant holds: what they received minus what
  /// they paid out across all settlements. Positive = they hold money
  /// (are owed), negative = they owe.
  double cashInHand(String participantId, String tourId) {
    final received = _settlements
        .where((s) => s.tourId == tourId && s.toParticipant == participantId)
        .fold(0.0, (sum, s) => sum + s.amount);
    final paid = _settlements
        .where((s) => s.tourId == tourId && s.fromParticipant == participantId)
        .fold(0.0, (sum, s) => sum + s.amount);
    return (received - paid) * 100.roundToDouble() / 100;
  }

  /// Net balance per participant for the entire tour:
  /// (total paid in expenses) - (total share of expenses) + (net settlement position).
  Map<String, double> netBalances(String tourId) {
    final balances = <String, double>{};
    for (final p in _participants.where((p) => p.tourId == tourId)) {
      balances[p.id] = 0;
    }

    for (final expense in _expenses.where((e) => e.tourId == tourId)) {
      balances.update(
        expense.paidBy,
        (v) => v + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    for (final share in _shares) {
      final expense = _expenses.firstWhere(
        (e) => e.id == share.expenseId,
        orElse: () => _expenses.first,
      );
      if (expense.tourId != tourId) continue;
      balances.update(
        share.participantId,
        (v) => v - share.shareAmount,
        ifAbsent: () => -share.shareAmount,
      );
    }

    for (final settlement in _settlements.where((s) => s.tourId == tourId)) {
      balances.update(
        settlement.fromParticipant,
        (v) => v - settlement.amount,
        ifAbsent: () => -settlement.amount,
      );
      balances.update(
        settlement.toParticipant,
        (v) => v + settlement.amount,
        ifAbsent: () => settlement.amount,
      );
    }

    for (final key in balances.keys.toList()) {
      balances[key] = (balances[key]! * 100).round() / 100.0;
    }
    return balances;
  }

  // ─── Firestore sync ────────────────────────────────────────────────

  CollectionReference? get _toursCollection {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('tours');
  }

  Future<void> _syncTourToFirestore(Tour tour) async {
    final col = _toursCollection;
    if (col == null) return;
    await col.doc(tour.id).set(tour.toMap());
  }

  Future<void> _syncExpenseToFirestore(
      TourExpense expense, List<TourExpenseShare> shares) async {
    final col = _toursCollection;
    if (col == null) return;
    await col.doc(expense.tourId).collection('expenses').doc(expense.id).set(expense.toMap());
    final batch = FirebaseFirestore.instance.batch();
    for (final share in shares) {
      final ref = col.doc(expense.tourId).collection('shares').doc(share.id);
      batch.set(ref, share.toMap());
    }
    await batch.commit();
  }

  Future<void> _syncSettlementToFirestore(TourSettlement settlement) async {
    final col = _toursCollection;
    if (col == null) return;
    await col
        .doc(settlement.tourId)
        .collection('settlements')
        .doc(settlement.id)
        .set(settlement.toMap());
  }

  Future<void> _syncParticipantToFirestore(TourParticipant participant) async {
    final col = _toursCollection;
    if (col == null) return;
    await col
        .doc(participant.tourId)
        .collection('participants')
        .doc(participant.id)
        .set(participant.toMap());
  }

  Future<void> _softDeleteDoc(
      String tourId, String subcollection, String docId, String now) async {
    final col = _toursCollection;
    if (col == null) return;
    await col
        .doc(tourId)
        .collection(subcollection)
        .doc(docId)
        .set({'isDeleted': 1, 'lastModified': now}, SetOptions(merge: true));
  }

  // ─── Lifecycle ──────────────────────────────────────────────────────

  void clear() {
    _tours.clear();
    _selectedTourId = null;
    _participants.clear();
    _expenses.clear();
    _shares.clear();
    _settlements.clear();
    _isLoading = true;
    notifyListeners();
  }


}
