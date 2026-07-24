import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../models/tour.dart';
import '../models/tour_participant.dart';
import '../models/tour_expense.dart';
import '../models/tour_expense_share.dart';
import '../models/tour_settlement.dart';
import '../utils/database_helper.dart';
import '../utils/shared_prefs_helper.dart';
import '../constants/app_constants.dart';
import '../services/invite_code_service.dart';
import '../services/tour_local_service.dart';
import '../../features/tours/utils/tour_image_codec.dart';

class TourProvider extends ChangeNotifier {
  static void Function(String message)? onNotification;

  final DatabaseHelper _db = DatabaseHelper.instance;
  final InviteCodeService _inviteCodeService = InviteCodeService();

  String _activeProfileId;
  bool _isLoading = true;

  List<Tour> _tours = [];
  String? _selectedTourId;

  List<TourParticipant> _participants = [];
  List<TourExpense> _expenses = [];
  List<TourExpenseShare> _shares = [];
  List<TourSettlement> _settlements = [];

  final Map<String, List<StreamSubscription>> _tourSubscriptions = {};

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
    // Cancel all active Firestore listeners for the previous profile
    // before switching — avoids leaking subscriptions across profiles.
    clear();
    _activeProfileId = id;
    _loadTours();
  }

  // ─── Tour CRUD ─────────────────────────────────────────────────────

  Future<void> _loadTours() async {
    try {
      // 1. Load local tours first for instant rendering
      final db = await _db.database;
      final maps = await db.query(
        'tours',
        where: 'isDeleted = 0 AND profileId = ?',
        whereArgs: [_activeProfileId],
        orderBy: 'createdAt DESC',
      );
      _tours = maps.map((m) => Tour.fromJson(m)).toList();
      for (final tour in _tours) {
        _initRealTimeListenerForTour(tour.id);
      }
      _isLoading = false;
      notifyListeners();

      // 2. Fetch/sync latest tours from Firestore in the background
      await _syncToursFromFirestore();

      // 3. Reload local tours from SQLite to reflect any background additions
      final updatedMaps = await db.query(
        'tours',
        where: 'isDeleted = 0 AND profileId = ?',
        whereArgs: [_activeProfileId],
        orderBy: 'createdAt DESC',
      );
      _tours = updatedMaps.map((m) => Tour.fromJson(m)).toList();
      for (final tour in _tours) {
        _initRealTimeListenerForTour(tour.id);
      }

      // 4. Upload any covers that only exist locally so other devices see them
      await _healMissingCloudCovers();
    } catch (e) {
      debugPrint('TourProvider._loadTours error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshTours() async {
    _isLoading = true;
    notifyListeners();
    await _loadTours();
  }

  /// Uploads a cover photo to Firebase Storage.
  /// Accepts either a `b64:` Base64 string or a legacy local file path.
  Future<String> _uploadTourCoverPhoto(String tourId, String coverValue) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('tour_covers')
        .child('$tourId.jpg');

    if (TourImageCodec.isBase64(coverValue)) {
      final bytes = TourImageCodec.decode(coverValue);
      if (bytes == null || bytes.isEmpty) {
        throw Exception('Cover photo Base64 is empty or invalid');
      }
      final TaskSnapshot snapshot = await storageRef.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await snapshot.ref.getDownloadURL();
    }

    String cleanedPath = coverValue;
    if (cleanedPath.startsWith('file://')) {
      cleanedPath = cleanedPath.replaceFirst('file://', '');
    }
    final file = File(cleanedPath);
    if (!await file.exists()) {
      throw Exception('Cover photo file does not exist locally: $cleanedPath');
    }

    final UploadTask uploadTask = storageRef.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> createTour(Tour tour) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    final code = uid != null
        ? await _inviteCodeService.generateUniqueCode()
        : null;

    // 1. Save locally first (cover may be Base64 until Storage upload completes)
    final enriched = tour.copyWith(
      inviteCode: code,
      ownerUid: uid,
      memberUids: uid != null ? [uid] : [],
    );

    final db = await _db.database;
    await db.insert(
      'tours',
      enriched.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _tours.insert(0, enriched);
    _selectedTourId = tour.id;
    _participants.clear();

    // Auto-create creator as participant
    if (uid != null) {
      final currentUser = FirebaseAuth.instance.currentUser;
      final photoUrl = currentUser?.photoURL ?? (currentUser != null ? SharedPrefsHelper.getString('local_profile_photo_${currentUser.uid}') : null);
      final creator = TourParticipant(
        id: '${tour.id}_creator',
        tourId: tour.id,
        name: currentUser?.displayName ?? 'You',
        joinedAt: DateTime.now(),
        uid: uid,
        photoUrl: photoUrl,
      );
      await db.insert(
        'tour_participants',
        creator.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      if (_selectedTourId == tour.id) {
        _participants.add(creator);
      }
      _syncParticipantToSharedCollection(creator);
    }

    notifyListeners();

    // 2. Upload cover to Storage first, then sync once (with https URL when possible).
    //    Never full-replace Firestore without merge — that wiped cloud covers before.
    var toSync = enriched;
    final cover = enriched.coverPhoto;
    if (cover != null && cover.isNotEmpty && !cover.startsWith('http')) {
      toSync = await _ensureCoverUploaded(enriched);
    }
    try {
      await _syncTourToSharedCollection(toSync);
      await _syncTourToFirestore(toSync);
    } catch (e) {
      debugPrint('TourProvider.createTour sync error: $e');
    }
    notifyListeners();
    _initRealTimeListenerForTour(tour.id);
  }

  Future<void> updateTour(Tour tour) async {
    final db = await _db.database;

    // 1. Save locally first (Base64, HTTP URL, or legacy path)
    final updated = tour.copyWith(
      lastModified: DateTime.now(),
    );
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

    // 2. Upload cover then sync (merge) so cloud keeps an https URL for other devices.
    var toSync = updated;
    final cover = updated.coverPhoto;
    if (cover != null && cover.isNotEmpty && !cover.startsWith('http')) {
      toSync = await _ensureCoverUploaded(updated);
    }
    try {
      await _syncTourToFirestore(toSync);
      if (toSync.inviteCode != null || toSync.ownerUid != null) {
        await _syncTourToSharedCollection(toSync);
      }
    } catch (e) {
      debugPrint('TourProvider.updateTour sync error: $e');
    }
    notifyListeners();
  }

  Future<bool> toggleTourCompletion(String tourId, bool completed) async {
    final tour = _tours.firstWhere(
      (t) => t.id == tourId,
      orElse: () =>
          Tour(id: '', name: '', currency: '', createdAt: DateTime.now()),
    );
    if (tour.id.isEmpty) return false;
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (tour.ownerUid != null &&
        currentUid != null &&
        tour.ownerUid != currentUid) {
      return false;
    }
    final db = await _db.database;
    final now = DateTime.now().toIso8601String();
    await db.update(
      'tours',
      {'isCompleted': completed ? 1 : 0, 'lastModified': now},
      where: 'id = ?',
      whereArgs: [tourId],
    );
    final idx = _tours.indexWhere((t) => t.id == tourId);
    if (idx != -1) {
      _tours[idx] = _tours[idx].copyWith(
        isCompleted: completed,
        lastModified: DateTime.now(),
      );
    }
    if (_selectedTourId == tourId) {
      _selectedTourId = tourId;
    }
    notifyListeners();
    if (idx != -1) {
      await _syncTourToSharedCollection(_tours[idx]);
    }
    return true;
  }

  Future<void> _deleteTourLocally(String tourId) async {
    final now = DateTime.now().toIso8601String();
    final db = await _db.database;

    await db.transaction((txn) async {
      await txn.update(
        'tours',
        {'isDeleted': 1, 'lastModified': now},
        where: 'id = ?',
        whereArgs: [tourId],
      );
      await txn.delete(
        'tour_participants',
        where: 'tourId = ?',
        whereArgs: [tourId],
      );
      await txn.delete(
        'tour_expenses',
        where: 'tourId = ?',
        whereArgs: [tourId],
      );
      await txn.delete(
        'tour_expense_shares',
        where: 'expenseId IN (SELECT id FROM tour_expenses WHERE tourId = ?)',
        whereArgs: [tourId],
      );
      await txn.delete(
        'tour_settlements',
        where: 'tourId = ?',
        whereArgs: [tourId],
      );
    });

    _tours.removeWhere((t) => t.id == tourId);
    if (_selectedTourId == tourId) {
      _selectedTourId = null;
      _participants.clear();
      _expenses.clear();
      _shares.clear();
      _settlements.clear();
    }
    _cancelRealTimeListenerForTour(tourId);
    notifyListeners();
  }

  void _cancelRealTimeListenerForTour(String tourId) {
    final subs = _tourSubscriptions.remove(tourId);
    if (subs != null) {
      for (final sub in subs) {
        sub.cancel();
      }
    }
  }

  Future<void> deleteTour(String tourId) async {
    final tourIdx = _tours.indexWhere((t) => t.id == tourId);
    Tour? tour;
    if (tourIdx != -1) {
      tour = _tours[tourIdx];
    }

    await _deleteTourLocally(tourId);

    if (tour != null) {
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      final isOwner = tour.ownerUid != null && currentUid != null && tour.ownerUid == currentUid;
      if (isOwner) {
        try {
          await _sharedToursCollection.doc(tourId).delete();
        } catch (e) {
          debugPrint('Error deleting tour from Firestore: $e');
        }
      } else if (currentUid != null) {
        try {
          final updatedUids = List<String>.from(tour.memberUids)..remove(currentUid);
          await _sharedToursCollection.doc(tourId).update({
            'memberUids': updatedUids,
          });

          final participantQuery = await _sharedToursCollection
              .doc(tourId)
              .collection('participants')
              .where('uid', isEqualTo: currentUid)
              .get();
          for (final doc in participantQuery.docs) {
            await doc.reference.delete();
          }
        } catch (e) {
          debugPrint('Error leaving tour in Firestore: $e');
        }
      }
    }
  }

  // ─── Join via code with verification/approval ──────────────────────

  Future<Tour> requestToJoinTourByCode(String code) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('You must be signed in to join a tour.');

    _isLoading = true;
    notifyListeners();

    try {
      final tour = await _inviteCodeService.getTourByCode(code);
      if (tour == null) {
        throw Exception('Invalid or expired invite code.');
      }

      if (tour.memberUids.contains(currentUser.uid)) {
        throw Exception('You are already a member of this tour.');
      }

      // Create a join request in Firestore
      await _sharedToursCollection
          .doc(tour.id)
          .collection('join_requests')
          .doc(currentUser.uid)
          .set({
        'uid': currentUser.uid,
        'name': currentUser.displayName ?? 'Friend',
        'email': currentUser.email ?? '',
        'photoUrl': currentUser.photoURL ?? SharedPrefsHelper.getString('local_profile_photo_${currentUser.uid}') ?? '',
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      });

      return tour;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeJoinAfterApproval(Tour tour) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Fetch all existing participants, expenses, shares first
      List<TourParticipant> participants = [];
      List<TourExpense> expenses = [];
      List<TourExpenseShare> shares = [];
      try {
        final participantSnapshot = await _sharedToursCollection
            .doc(tour.id)
            .collection('participants')
            .get();
        participants = participantSnapshot.docs
            .map((doc) => TourParticipant.fromMap(doc.id, doc.data()))
            .toList();

        final expenseSnapshot = await _sharedToursCollection
            .doc(tour.id)
            .collection('expenses')
            .get();
        expenses = expenseSnapshot.docs
            .map((doc) => TourExpense.fromMap(doc.id, doc.data()))
            .toList();

        final expenseIds = expenses.map((e) => e.id).toList();
        if (expenseIds.isNotEmpty) {
          shares = expenses
              .where((e) => e.shares != null)
              .expand((e) => e.shares!)
              .toList();
        }
      } catch (_) {
        debugPrint(
          'No participants/expenses found in shared_tours for ${tour.id}',
        );
      }

      // Check if current user already has a participant entry (same uid)
      final existing = participants.where((p) => p.uid == uid).toList();
      if (existing.isEmpty) {
        // Check if a dummy (uid=null) can be claimed
        final dummy = participants.where((p) => p.uid == null).toList();
        if (dummy.isNotEmpty) {
          // The owner's app will update Firestore. We prepare the local list state here.
          final claimed = dummy.first;
          final currentUser = FirebaseAuth.instance.currentUser;
          final joinerPhotoUrl = currentUser?.photoURL ?? (currentUser != null ? SharedPrefsHelper.getString('local_profile_photo_${currentUser.uid}') : null);
          final idx = participants.indexWhere((p) => p.id == claimed.id);
          if (idx != -1) {
            participants[idx] = claimed.copyWith(
              uid: uid,
              name: currentUser?.displayName ?? claimed.name,
              photoUrl: joinerPhotoUrl,
            );
          }
        } else {
          // Create new participant locally to resolve sync delay, no Firestore write
          final currentUser = FirebaseAuth.instance.currentUser;
          final joinerPhotoUrl = currentUser?.photoURL ?? (currentUser != null ? SharedPrefsHelper.getString('local_profile_photo_${currentUser.uid}') : null);
          final joiner = TourParticipant(
            id: '${tour.id}_member_$uid',
            tourId: tour.id,
            name: currentUser?.displayName ?? 'New Member',
            joinedAt: DateTime.now(),
            uid: uid,
            photoUrl: joinerPhotoUrl,
          );
          participants.add(joiner);
        }
      }

      final updatedTour = tour.copyWith(
        memberUids: {...tour.memberUids, uid}.toList(),
        profileId: _activeProfileId,
      );

      final db = await _db.database;
      final localService = TourLocalService(db);
      await localService.saveJoinedTourLocally(
        updatedTour,
        participants,
        expenses: expenses,
        shares: shares,
      );

      _tours.insert(0, updatedTour);
      notifyListeners();
      _initRealTimeListenerForTour(tour.id);
      await _loadTours();
    } catch (e) {
      debugPrint('TourProvider.completeJoinAfterApproval error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> approveJoinRequest(Tour tour, String requesterUid, String requesterName) async {
    try {
      // 1. Update request status to approved and fetch photoUrl
      final reqDoc = await _sharedToursCollection
          .doc(tour.id)
          .collection('join_requests')
          .doc(requesterUid)
          .get();
      final requesterPhotoUrl = (reqDoc.data()?['photoUrl'] as String?) ?? '';
      await _sharedToursCollection
          .doc(tour.id)
          .collection('join_requests')
          .doc(requesterUid)
          .update({'status': 'approved'});

      // 2. Add to memberUids in Firestore
      final updatedUids = {...tour.memberUids, requesterUid}.toList();
      await _sharedToursCollection.doc(tour.id).update({
        'memberUids': updatedUids,
      });

      // 3. Create or claim participant entry
      final participantSnapshot = await _sharedToursCollection
          .doc(tour.id)
          .collection('participants')
          .get();
      final participants = participantSnapshot.docs
          .map((doc) => TourParticipant.fromMap(doc.id, doc.data()))
          .toList();

      final existing = participants.where((p) => p.uid == requesterUid).toList();
      if (existing.isEmpty) {
        final dummy = participants.where((p) => p.uid == null).toList();
        if (dummy.isNotEmpty) {
          final claimed = dummy.first;
          await _sharedToursCollection
              .doc(tour.id)
              .collection('participants')
              .doc(claimed.id)
              .update({
                'uid': requesterUid,
                'name': requesterName,
              });
        } else {
          final joiner = TourParticipant(
            id: '${tour.id}_member_$requesterUid',
            tourId: tour.id,
            name: requesterName,
            joinedAt: DateTime.now(),
            uid: requesterUid,
            photoUrl: requesterPhotoUrl,
          );
          await _sharedToursCollection
              .doc(tour.id)
              .collection('participants')
              .doc(joiner.id)
              .set(joiner.toMap());
        }
      }
    } catch (e) {
      debugPrint('Error approving join request: $e');
      rethrow;
    }
  }

  Future<void> rejectJoinRequest(String tourId, String requesterUid) async {
    try {
      await _sharedToursCollection
          .doc(tourId)
          .collection('join_requests')
          .doc(requesterUid)
          .update({'status': 'rejected'});
    } catch (e) {
      debugPrint('Error rejecting join request: $e');
      rethrow;
    }
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
      _participants = participantMaps
          .map((m) => TourParticipant.fromJson(m))
          .toList();

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
      _settlements = settlementMaps
          .map((m) => TourSettlement.fromJson(m))
          .toList();

      // Reconcile participants AFTER all data is loaded so
      // paidBy/participantId reassignments actually take effect.
      _reconcileParticipants(tourId);
    } catch (e) {
      debugPrint('TourProvider._loadTourDetails error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Merges participants that share the same non-null [uid] so the same
  /// real person doesn't appear as two separate balance entries.
  /// Keeps the first participant, reassigns all expense/settlement references
  /// to that survivor, and removes the duplicates from memory.
  void _reconcileParticipants(String tourId) {
    final uidToParticipants = <String, List<int>>{};
    for (var i = 0; i < _participants.length; i++) {
      final u = _participants[i].uid;
      if (u == null) continue;
      uidToParticipants.putIfAbsent(u, () => []).add(i);
    }

    for (final entry in uidToParticipants.entries) {
      final indices = entry.value;
      if (indices.length < 2) continue;

      // Keep the first participant, merge others into it
      final keepIdx = indices.first;
      final keep = _participants[keepIdx];
      final removeIds = indices.skip(1).map((i) => _participants[i].id).toSet();

      // Reassign paidBy in expenses
      for (var i = 0; i < _expenses.length; i++) {
        var changed = false;
        final updatedPaidBy = <String, double>{};
        for (final entry in _expenses[i].paidBy.entries) {
          if (removeIds.contains(entry.key)) {
            updatedPaidBy[keep.id] =
                (updatedPaidBy[keep.id] ?? 0) + entry.value;
            changed = true;
          } else {
            updatedPaidBy[entry.key] = entry.value;
          }
        }
        if (changed) {
          _expenses[i] = _expenses[i].copyWith(paidBy: updatedPaidBy);
        }
      }

      // Reassign participantId in shares
      for (var i = 0; i < _shares.length; i++) {
        if (removeIds.contains(_shares[i].participantId)) {
          _shares[i] = _shares[i].copyWith(participantId: keep.id);
        }
      }

      // Reassign settlements
      for (var i = 0; i < _settlements.length; i++) {
        if (removeIds.contains(_settlements[i].fromParticipant)) {
          _settlements[i] = _settlements[i].copyWith(fromParticipant: keep.id);
        }
        if (removeIds.contains(_settlements[i].toParticipant)) {
          _settlements[i] = _settlements[i].copyWith(toParticipant: keep.id);
        }
      }

      // Remove duplicate participants (descending to preserve indices)
      final toRemove = indices.skip(1).toList()..sort((a, b) => b.compareTo(a));
      for (final idx in toRemove) {
        _participants.removeAt(idx);
      }

      debugPrint(
        'Reconciled ${removeIds.length} duplicate(s) into ${keep.id} (uid: ${entry.key})',
      );
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

  /// Reloads all detail data for the currently selected tour from SQLite.
  /// Call this after any mutation (add/remove participant, add expense, etc.)
  /// to guarantee the in-memory lists match the database.
  Future<void> refreshTourData() async {
    if (_selectedTourId == null) return;
    await _loadTourDetails(_selectedTourId!);
  }

  // ─── Participant CRUD ───────────────────────────────────────────────

  Future<void> addParticipant(TourParticipant participant) async {
    final db = await _db.database;
    await db.insert(
      'tour_participants',
      participant.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    if (_selectedTourId == participant.tourId) {
      await refreshTourData();
    } else {
      _participants.add(participant);
      notifyListeners();
    }
    _syncParticipantToFirestore(participant);
    _syncParticipantToSharedCollection(participant);
  }

  Future<void> updateParticipant(TourParticipant participant) async {
    final db = await _db.database;
    await db.update(
      'tour_participants',
      participant.toJson(),
      where: 'id = ?',
      whereArgs: [participant.id],
    );
    if (_selectedTourId == participant.tourId) {
      await refreshTourData();
    } else {
      final idx = _participants.indexWhere((p) => p.id == participant.id);
      if (idx != -1) {
        _participants[idx] = participant;
      }
      notifyListeners();
    }
    _syncParticipantToFirestore(participant);
    _syncParticipantToSharedCollection(participant);
  }

  Future<void> removeParticipant(String participantId) async {
    String? tourId;
    final idx = _participants.indexWhere((p) => p.id == participantId);
    if (idx != -1) {
      tourId = _participants[idx].tourId;
    }
    // Optimistic UI: remove immediately so list updates instantly
    _participants.removeWhere((p) => p.id == participantId);
    notifyListeners();
    final now = DateTime.now().toIso8601String();
    try {
      final db = await _db.database;
      await db.update(
        'tour_participants',
        {'isDeleted': 1, 'lastModified': now},
        where: 'id = ?',
        whereArgs: [participantId],
      );
      if (tourId != null && _selectedTourId == tourId) {
        await refreshTourData();
      }
      if (tourId != null) {
        _softDeleteDoc(tourId, 'participants', participantId, now);
        _sharedToursCollection
            .doc(tourId)
            .collection('participants')
            .doc(participantId)
            .set({
              'isDeleted': 1,
              'lastModified': now,
            }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('removeParticipant error: $e');
    }
  }

  // ─── Expense CRUD ───────────────────────────────────────────────────

  Future<bool> addExpense(
    TourExpense expense,
    List<TourExpenseShare> shares,
  ) async {
    if (shares.isEmpty) {
      debugPrint('ERROR: addExpense called with zero shares — aborting');
      return false;
    }
    final tour = _tours.firstWhere(
      (t) => t.id == expense.tourId,
      orElse: () =>
          Tour(id: '', name: '', currency: '', createdAt: DateTime.now()),
    );
    if (tour.isCompleted) {
      debugPrint('ERROR: cannot add expense to a completed tour');
      return false;
    }
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.insert(
        'tour_expenses',
        expense.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      for (final share in shares) {
        await txn.insert(
          'tour_expense_shares',
          share.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
    await refreshTourData();
    _syncExpenseToFirestore(expense, shares);
    return true;
  }

  Future<bool> updateExpense(
    TourExpense expense,
    List<TourExpenseShare> shares,
  ) async {
    final tour = _tours.firstWhere(
      (t) => t.id == expense.tourId,
      orElse: () =>
          Tour(id: '', name: '', currency: '', createdAt: DateTime.now()),
    );
    if (tour.isCompleted) {
      debugPrint('ERROR: cannot update expense in a completed tour');
      return false;
    }
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.update(
        'tour_expenses',
        expense.toJson(),
        where: 'id = ?',
        whereArgs: [expense.id],
      );
      await txn.delete(
        'tour_expense_shares',
        where: 'expenseId = ?',
        whereArgs: [expense.id],
      );
      for (final share in shares) {
        await txn.insert(
          'tour_expense_shares',
          share.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
    await refreshTourData();
    _syncExpenseToFirestore(expense, shares);
    return true;
  }

  Future<bool> deleteExpense(String expenseId) async {
    final idx = _expenses.indexWhere((e) => e.id == expenseId);
    final String? tourId = idx != -1 ? _expenses[idx].tourId : null;
    if (tourId == null) return false;

    final tour = _tours.firstWhere(
      (t) => t.id == tourId,
      orElse: () =>
          Tour(id: '', name: '', currency: '', createdAt: DateTime.now()),
    );
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (tour.ownerUid != null &&
        currentUid != null &&
        tour.ownerUid != currentUid) {
      return false;
    }

    final original = _expenses[idx];
    final now = DateTime.now().toIso8601String();
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
    if (_selectedTourId == tourId) {
      await refreshTourData();
    } else {
      _expenses.removeWhere((e) => e.id == expenseId);
      _shares.removeWhere((s) => s.expenseId == expenseId);
      notifyListeners();
    }
    final deleted = original.copyWith(
      isDeleted: true,
      lastModified: DateTime.now(),
    );
    await _sharedToursCollection
        .doc(tourId)
        .collection('expenses')
        .doc(expenseId)
        .set(deleted.toMap());
    return true;
  }

  /// Pure calculation of shares for a given expense and active participants.
  /// Does NOT persist — returns the computed share list for the caller to
  /// pass to [addExpense] or [updateExpense].
  ///
  /// The caller is responsible for passing [excludedIds] (includes late-joiner
  /// exclusions). Supports split types: equal, exact, percentage, exclusion,
  /// transfer.
  ///
  /// Throws if [activeParticipants] is empty or if all participants are
  /// excluded, because at least one person must be included for a valid split.
  List<TourExpenseShare> calculateShares({
    required TourExpense expense,
    required List<TourParticipant> activeParticipants,
    Map<String, double>? customValues,
    List<String>? excludedIds,
  }) {
    if (activeParticipants.isEmpty) {
      throw StateError('calculateShares: activeParticipants is empty');
    }

    final excludedSet = excludedIds ?? <String>{};
    final included = <TourParticipant>[];
    final excluded = <TourParticipant>[];
    for (final p in activeParticipants) {
      if (excludedSet.contains(p.id)) {
        excluded.add(p);
      } else {
        included.add(p);
      }
    }

    if (included.isEmpty) {
      throw StateError(
        'calculateShares: all ${activeParticipants.length} participants '
        'are excluded — at least one must be included',
      );
    }

    final result = <TourExpenseShare>[];
    final shareId = DateTime.now().microsecondsSinceEpoch;

    switch (expense.splitType) {
      case 'equal':
        result.addAll(_splitEqually(expense, included, shareId));
        break;

      case 'exact':
        for (final p in included) {
          final value = customValues?[p.id] ?? 0;
          debugPrint('CALCULATE_SHARES_DEBUG: p=${p.id} value=$value');
          result.add(
            TourExpenseShare(
              id: 'share_${shareId}_${p.id}',
              expenseId: expense.id,
              participantId: p.id,
              shareAmount: (value * 100).round() / 100.0,
              customValue: value,
            ),
          );
        }
        break;

      case 'percentage':
        debugPrint('CALCULATE_SHARES_DEBUG: case=percentage');
        for (final p in included) {
          final pct = customValues?[p.id] ?? 0;
          final amount = expense.amount * pct / 100;
          result.add(
            TourExpenseShare(
              id: 'share_${shareId}_${p.id}',
              expenseId: expense.id,
              participantId: p.id,
              shareAmount: (amount * 100).round() / 100.0,
              customValue: pct,
            ),
          );
        }
        break;

      case 'exclusion':
        result.addAll(_splitEqually(expense, included, shareId));
        for (final p in excluded) {
          result.add(
            TourExpenseShare(
              id: 'share_${shareId}_excluded_${p.id}',
              expenseId: expense.id,
              participantId: p.id,
              shareAmount: 0,
              isExcluded: true,
            ),
          );
        }
        break;

      case 'transfer':
        result.addAll(_splitTransfer(expense, included, excluded, shareId));
        break;
    }

    return result;
  }

  /// Splits [expense.amount] equally (in cents) across [included] participants.
  /// Any leftover cents (from rounding) are distributed one-by-one across
  /// participants instead of always dumping the whole remainder on the first
  /// person — fairer over many expenses.
  List<TourExpenseShare> _splitEqually(
    TourExpense expense,
    List<TourParticipant> included,
    int shareId,
  ) {
    if (included.isEmpty) return [];

    final totalCents = (expense.amount * 100).round();
    final baseCents = totalCents ~/ included.length;
    final remainderCents = totalCents - (baseCents * included.length);

    final startOffset = shareId % included.length;

    final result = <TourExpenseShare>[];
    for (var i = 0; i < included.length; i++) {
      final rotatedIndex = (i + startOffset) % included.length;
      final cents = baseCents + (i < remainderCents ? 1 : 0);
      result.add(
        TourExpenseShare(
          id: 'share_${shareId}_${included[rotatedIndex].id}',
          expenseId: expense.id,
          participantId: included[rotatedIndex].id,
          shareAmount: cents / 100.0,
        ),
      );
    }
    return result;
  }

  /// Handles the 'transfer' split type: the payer transfers the full expense
  /// amount to exactly one other participant. The transferred-to participant
  /// gets a single share equal to the full expense amount. The payer does not
  /// receive a share — they paid out of pocket, and the entire burden is on
  /// the transfer recipient.
  List<TourExpenseShare> _splitTransfer(
    TourExpense expense,
    List<TourParticipant> included,
    List<TourParticipant> excluded,
    int shareId,
  ) {
    final result = <TourExpenseShare>[];

    final target = included
        .where((p) => !expense.paidBy.containsKey(p.id))
        .toList();
    for (final p in target) {
      result.add(
        TourExpenseShare(
          id: 'share_${shareId}_transfer_${p.id}',
          expenseId: expense.id,
          participantId: p.id,
          shareAmount: expense.amount,
          customValue: expense.amount,
        ),
      );
    }

    for (final p in excluded) {
      result.add(
        TourExpenseShare(
          id: 'share_${shareId}_excluded_${p.id}',
          expenseId: expense.id,
          participantId: p.id,
          shareAmount: 0,
          isExcluded: true,
        ),
      );
    }

    return result;
  }

  // ─── Settlement CRUD ────────────────────────────────────────────────

  Future<void> addSettlement(TourSettlement settlement) async {
    final db = await _db.database;
    await db.insert(
      'tour_settlements',
      settlement.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    if (_selectedTourId == settlement.tourId) {
      await refreshTourData();
    } else {
      _settlements.add(settlement);
      notifyListeners();
    }
    _syncSettlementToFirestore(settlement);
  }

  Future<void> removeSettlement(String settlementId) async {
    final now = DateTime.now().toIso8601String();
    final idx = _settlements.indexWhere((s) => s.id == settlementId);
    final String? tourId = idx != -1 ? _settlements[idx].tourId : null;

    final db = await _db.database;
    await db.update(
      'tour_settlements',
      {'isDeleted': 1, 'lastModified': now},
      where: 'id = ?',
      whereArgs: [settlementId],
    );
    if (tourId != null && _selectedTourId == tourId) {
      await refreshTourData();
    } else {
      _settlements.removeWhere((s) => s.id == settlementId);
      notifyListeners();
    }
    if (tourId != null) {
      _softDeleteDoc(tourId, 'settlements', settlementId, now);
    }
  }

  // ─── Fund calculations ──────────────────────────────────────────────

  /// Sum of all settlement amounts for the tour — total money that has
  /// moved through settlements.
  double totalFundCollected(String tourId) {
    return _settlements
        .where((s) => s.tourId == tourId)
        .fold(0.0, (a, s) => a + s.amount);
  }

  /// Gross amount spent across all expenses in this tour — regardless
  /// of who paid or how it was split.
  double totalSpent(String tourId) {
    return _expenses
        .where((e) => e.tourId == tourId)
        .fold(0.0, (a, e) => a + e.amount);
  }

  /// Total amount still outstanding across the whole tour. Sums only the
  /// positive side of net balances — how much money still needs to change
  /// hands to fully settle this tour.
  double totalOutstanding(String tourId) {
    final balances = netBalances(tourId);
    return balances.values.where((v) => v > 0).fold(0.0, (a, v) => a + v);
  }

  /// Net cash a given participant holds: what they received minus what
  /// they paid out across all settlements. Positive = they hold money
  /// (are owed), negative = they owe.
  ///
  /// IMPORTANT: call as cashInHand(participantId, tourId).
  double cashInHand(String participantId, String tourId) {
    final received = _settlements
        .where((s) => s.tourId == tourId && s.toParticipant == participantId)
        .fold(0.0, (a, s) => a + s.amount);
    final paid = _settlements
        .where((s) => s.tourId == tourId && s.fromParticipant == participantId)
        .fold(0.0, (a, s) => a + s.amount);
    return ((received - paid) * 100).round() / 100;
  }

  /// Total amount [participantId] paid out of pocket (as `paidBy` in expenses)
  /// for the given tour. Includes all expense types (equal, exact, transfer, etc.).
  double effectivePaid(String participantId, String tourId) {
    double total = 0;
    for (final e in _expenses) {
      if (e.tourId != tourId || e.isDeleted) continue;
      total += e.paidBy[participantId] ?? 0;
    }
    return total;
  }

  /// Total cost [participantId] is actually responsible for — the sum of all
  /// their share amounts across every expense in the tour. Settlements are
  /// NOT included here (they are accounted for in [balance]).
  double finalShare(String participantId, String tourId) {
    final expenseIds = _expenses
        .where((e) => e.tourId == tourId && !e.isDeleted)
        .map((e) => e.id)
        .toSet();
    return _shares
        .where(
          (s) =>
              expenseIds.contains(s.expenseId) &&
              s.participantId == participantId &&
              !s.isDeleted &&
              !s.isExcluded,
        )
        .fold(0.0, (a, s) => a + s.shareAmount);
  }

  /// Net balance for [participantId]:
  ///   effectivePaid - finalShare + netSettlementPosition
  ///
  /// Positive = the person is owed money (should get money back).
  /// Negative = the person owes money (should pay others).
  ///
  /// Includes settlements: money received (+) and sent (-) are factored in.
  double balance(String participantId, String tourId) {
    final paid = effectivePaid(participantId, tourId);
    final share = finalShare(participantId, tourId);
    final received = _settlements
        .where(
          (s) =>
              s.tourId == tourId &&
              s.toParticipant == participantId &&
              !s.isDeleted,
        )
        .fold(0.0, (a, s) => a + s.amount);
    final sent = _settlements
        .where(
          (s) =>
              s.tourId == tourId &&
              s.fromParticipant == participantId &&
              !s.isDeleted,
        )
        .fold(0.0, (a, s) => a + s.amount);
    return ((paid - share - received + sent) * 100).round() / 100.0;
  }

  /// Net balance per participant for the entire tour:
  /// (total paid in expenses) - (total share of expenses) + (net settlement position).
  Map<String, double> netBalances(String tourId) {
    final balances = <String, double>{};
    for (final p in _participants.where((p) => p.tourId == tourId)) {
      balances[p.id] = 0;
    }

    for (final expense in _expenses.where((e) => e.tourId == tourId)) {
      for (final entry in expense.paidBy.entries) {
        balances.update(
          entry.key,
          (v) => v + entry.value,
          ifAbsent: () => entry.value,
        );
      }
    }

    final expenseById = {for (final e in _expenses) e.id: e};

    for (final share in _shares) {
      final expense = expenseById[share.expenseId];
      if (expense == null || expense.tourId != tourId) continue;
      balances.update(
        share.participantId,
        (v) => v - share.shareAmount,
        ifAbsent: () => -share.shareAmount,
      );
    }

    for (final settlement in _settlements.where((s) => s.tourId == tourId)) {
      balances.update(
        settlement.fromParticipant,
        (v) => v + settlement.amount,
        ifAbsent: () => settlement.amount,
      );
      balances.update(
        settlement.toParticipant,
        (v) => v - settlement.amount,
        ifAbsent: () => -settlement.amount,
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

  CollectionReference get _sharedToursCollection =>
      FirebaseFirestore.instance.collection(AppConstants.toursCollection);

  Future<void> _syncToursFromFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final querySnapshot = await _sharedToursCollection
          .where('memberUids', arrayContains: uid)
          .get();

      final db = await _db.database;
      final localService = TourLocalService(db);

      // Keep track of Firestore tour IDs to prune deleted/left local tours
      final Set<String> firestoreTourIds = {};

      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) continue;
        final tour = Tour.fromMap(doc.id, data);
        firestoreTourIds.add(tour.id);

        // Check if this tour already exists in local SQLite to preserve profileId & local coverPhoto
        final localTourMaps = await db.query(
          'tours',
          where: 'id = ?',
          whereArgs: [tour.id],
        );

        String targetProfileId = _activeProfileId;
        String? existingCover;
        if (localTourMaps.isNotEmpty) {
          targetProfileId =
              localTourMaps.first['profileId'] as String? ?? _activeProfileId;
          existingCover = localTourMaps.first['coverPhoto'] as String?;
        }

        String? finalCover = tour.coverPhoto;
        // Prefer cloud https URL when present (works on every device).
        // Otherwise keep a valid local Base64/file cover and heal later.
        final existingTour = _tours.where((t) => t.id == tour.id).firstOrNull;
        final currentCover = existingTour?.coverPhoto;
        final cloudHasHttp =
            finalCover != null && finalCover.startsWith('http');
        if (cloudHasHttp) {
          // keep finalCover from Firestore
        } else if (currentCover != null && currentCover.isNotEmpty) {
          finalCover = currentCover;
        } else if (existingCover != null && existingCover.isNotEmpty) {
          finalCover = existingCover;
        }

        final updatedTour = tour.copyWith(
          profileId: targetProfileId,
          coverPhoto: finalCover,
        );

        // Fetch participants and expenses
        final participantSnapshot = await _sharedToursCollection
            .doc(tour.id)
            .collection('participants')
            .get();
        final participants = participantSnapshot.docs
            .map((doc) => TourParticipant.fromMap(doc.id, doc.data()))
            .toList();

        final expenseSnapshot = await _sharedToursCollection
            .doc(tour.id)
            .collection('expenses')
            .get();
        final expenses = expenseSnapshot.docs
            .map((doc) => TourExpense.fromMap(doc.id, doc.data()))
            .toList();

        final shares = expenses
            .where((e) => e.shares != null)
            .expand((e) => e.shares!)
            .toList();

        await localService.saveJoinedTourLocally(
          updatedTour,
          participants,
          expenses: expenses,
          shares: shares,
        );
      }

      // Prune local shared tours that are no longer in Firestore (deleted by owner or user left)
      final localTourMaps = await db.query(
        'tours',
        where: 'isDeleted = 0 AND profileId = ?',
        whereArgs: [_activeProfileId],
      );
      final localTours = localTourMaps.map((m) => Tour.fromJson(m)).toList();

      for (final localTour in localTours) {
        final isShared = localTour.inviteCode != null || localTour.ownerUid != null;
        if (isShared && !firestoreTourIds.contains(localTour.id)) {
          // Deleted remotely or user left — delete locally
          await _deleteTourLocally(localTour.id);
        }
      }
    } catch (e) {
      debugPrint('TourProvider._syncToursFromFirestore error: $e');
    }
  }

  Future<void> _syncTourToSharedCollection(Tour tour) async {
    final map = tour.toMap();
    if (tour.coverPhoto != null && !tour.coverPhoto!.startsWith('http')) {
      // Keep any existing https cover on the server — never wipe it by
      // omitting the field in a full document replace.
      map.remove('coverPhoto');
    }
    await _sharedToursCollection
        .doc(tour.id)
        .set(map, SetOptions(merge: true));
  }

  Future<void> _syncTourToFirestore(Tour tour) async {
    final col = _toursCollection;
    if (col == null) return;
    final map = tour.toMap();
    if (tour.coverPhoto != null && !tour.coverPhoto!.startsWith('http')) {
      map.remove('coverPhoto');
    }
    await col.doc(tour.id).set(map, SetOptions(merge: true));
  }

  /// Uploads a local Base64 / file cover to Storage and persists the https URL.
  Future<Tour> _ensureCoverUploaded(Tour tour) async {
    final cover = tour.coverPhoto;
    if (cover == null || cover.isEmpty || cover.startsWith('http')) {
      return tour;
    }
    try {
      final httpUrl = await _uploadTourCoverPhoto(tour.id, cover);
      final withUrl = tour.copyWith(coverPhoto: httpUrl);
      final db = await _db.database;
      await db.update(
        'tours',
        withUrl.toJson(),
        where: 'id = ?',
        whereArgs: [tour.id],
      );
      final idx = _tours.indexWhere((t) => t.id == tour.id);
      if (idx != -1) {
        _tours[idx] = withUrl;
      }
      return withUrl;
    } catch (e) {
      debugPrint('TourProvider._ensureCoverUploaded (${tour.id}): $e');
      return tour;
    }
  }

  /// Re-upload any covers that only exist locally so other devices can load them.
  /// Also recovers https URLs from Storage when Firestore is missing the field
  /// (common after device switch / incomplete sync).
  Future<void> _healMissingCloudCovers() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    var changed = false;
    for (final tour in List<Tour>.from(_tours)) {
      final cover = tour.coverPhoto;

      // Case A: local Base64/file — upload to Storage + write https into cloud.
      if (cover != null && cover.isNotEmpty && !cover.startsWith('http')) {
        final withUrl = await _ensureCoverUploaded(tour);
        if (withUrl.coverPhoto != null &&
            withUrl.coverPhoto!.startsWith('http')) {
          try {
            await _syncTourToFirestore(withUrl);
            await _syncTourToSharedCollection(withUrl);
          } catch (e) {
            debugPrint('TourProvider._healMissingCloudCovers sync (${tour.id}): $e');
          }
          changed = true;
        }
        continue;
      }

      // Case B: no cover locally — try recover from Storage path if previously uploaded.
      if (cover == null || cover.isEmpty) {
        try {
          final url = await FirebaseStorage.instance
              .ref()
              .child('tour_covers')
              .child('${tour.id}.jpg')
              .getDownloadURL();
          final withUrl = tour.copyWith(coverPhoto: url);
          final db = await _db.database;
          await db.update(
            'tours',
            withUrl.toJson(),
            where: 'id = ?',
            whereArgs: [tour.id],
          );
          final idx = _tours.indexWhere((t) => t.id == tour.id);
          if (idx != -1) {
            _tours[idx] = withUrl;
          }
          try {
            await _syncTourToFirestore(withUrl);
            await _syncTourToSharedCollection(withUrl);
          } catch (e) {
            debugPrint(
              'TourProvider._healMissingCloudCovers recover-sync (${tour.id}): $e',
            );
          }
          changed = true;
          debugPrint(
            'TourProvider: recovered cover URL from Storage for ${tour.id}',
          );
        } catch (_) {
          // No object in Storage — nothing to recover.
        }
      }
    }
    if (changed) notifyListeners();
  }

  Future<void> _syncExpenseToFirestore(
    TourExpense expense,
    List<TourExpenseShare> shares,
  ) async {
    await _sharedToursCollection
        .doc(expense.tourId)
        .collection('expenses')
        .doc(expense.id)
        .set(expense.copyWith(shares: shares).toMap());
  }

  Future<void> _syncSettlementToFirestore(TourSettlement settlement) async {
    await _sharedToursCollection
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

  Future<void> _syncParticipantToSharedCollection(
    TourParticipant participant,
  ) async {
    await _sharedToursCollection
        .doc(participant.tourId)
        .collection('participants')
        .doc(participant.id)
        .set(participant.toMap());
  }

  Future<void> _softDeleteDoc(
    String tourId,
    String subcollection,
    String docId,
    String now,
  ) async {
    final col = _toursCollection;
    if (col == null) return;
    await col.doc(tourId).collection(subcollection).doc(docId).set({
      'isDeleted': 1,
      'lastModified': now,
    }, SetOptions(merge: true));
  }

  // ─── Real-time Firestore listener ──────────────────────────────────

  void _initRealTimeListenerForTour(String tourId) {
    if (_tourSubscriptions.containsKey(tourId)) return;

    final docRef = _sharedToursCollection.doc(tourId);
    final participantsRef = docRef.collection('participants');
    final expensesRef = docRef.collection('expenses');

    final subs = <StreamSubscription>[
      docRef.snapshots().listen((snapshot) async {
        if (!snapshot.exists) {
          final tour = _tours.firstWhere((t) => t.id == tourId, orElse: () => Tour(id: '', name: '', currency: '', createdAt: DateTime.now()));
          final tourName = tour.name.isNotEmpty ? tour.name : 'Tour';
          await _deleteTourLocally(tourId);
          final notif = TourProvider.onNotification;
          notif?.call('"$tourName" has been deleted by the creator');
          return;
        }
        final data = snapshot.data();
        if (data == null) return;
        final tour = Tour.fromMap(snapshot.id, data as Map<String, dynamic>);

        final db = await _db.database;
        final localTourMaps = await db.query(
          'tours',
          where: 'id = ?',
          whereArgs: [tour.id],
        );
        String targetProfileId = _activeProfileId;
        String? existingCover;
        if (localTourMaps.isNotEmpty) {
          targetProfileId =
              localTourMaps.first['profileId'] as String? ?? _activeProfileId;
          existingCover = localTourMaps.first['coverPhoto'] as String?;
        }

        String? finalCover = tour.coverPhoto;
        // Prefer cloud https URL; otherwise preserve local Base64/file.
        final idx = _tours.indexWhere((t) => t.id == tourId);
        final currentTour = idx != -1 ? _tours[idx] : null;
        final currentCover = currentTour?.coverPhoto;
        final cloudHasHttp =
            finalCover != null && finalCover.startsWith('http');
        if (cloudHasHttp) {
          // keep finalCover from Firestore
        } else if (currentCover != null && currentCover.isNotEmpty) {
          finalCover = currentCover;
        } else if (existingCover != null && existingCover.isNotEmpty) {
          finalCover = existingCover;
        }

        final updatedTour = tour.copyWith(
          profileId: targetProfileId,
          coverPhoto: finalCover,
        );

        final localService = TourLocalService(db);
        await localService.upsertTour(updatedTour);
        if (idx != -1) {
          final old = _tours[idx];
          _tours[idx] = updatedTour;
          notifyListeners();
          final currentUid = FirebaseAuth.instance.currentUser?.uid;
          if (tour.isCompleted &&
              !old.isCompleted &&
              tour.ownerUid != null &&
              currentUid != null &&
              tour.ownerUid != currentUid) {
            final notif = TourProvider.onNotification;
            notif?.call('Tour marked as completed by the creator');
          }
        }
      }, onError: (e) => debugPrint('Tour stream error: $e')),

      participantsRef.snapshots().listen((snapshot) async {
        final localService = TourLocalService(await _db.database);
        final currentUid = FirebaseAuth.instance.currentUser?.uid;
        for (final change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.removed) {
            final db = await _db.database;
            await db.delete(
              'tour_participants',
              where: 'id = ?',
              whereArgs: [change.doc.id],
            );
            final data = change.doc.data();
            if (data != null) {
              final participant = TourParticipant.fromMap(change.doc.id, data);
              if (participant.uid != null && participant.uid != currentUid) {
                final notif = TourProvider.onNotification;
                notif?.call('${participant.name} left the tour');
              }
            }
            continue;
          }
          final data = change.doc.data();
          if (data == null) continue;
          final participant = TourParticipant.fromMap(change.doc.id, data);
          await localService.upsertParticipant(participant);

          if (change.type == DocumentChangeType.added &&
              participant.uid != null &&
              participant.uid != currentUid) {
            final notif = TourProvider.onNotification;
            notif?.call('${participant.name} joined the tour!');
          }
        }
        if (_selectedTourId == tourId) {
          await _loadTourDetails(tourId);
        }
      }, onError: (e) => debugPrint('Participants stream error: $e')),

      expensesRef.snapshots().listen((snapshot) async {
        final localService = TourLocalService(await _db.database);
        final currentUid = FirebaseAuth.instance.currentUser?.uid;
        final tourOwnerUid = _tours
            .firstWhere(
              (t) => t.id == tourId,
              orElse: () => Tour(
                id: '',
                name: '',
                currency: '',
                createdAt: DateTime.now(),
              ),
            )
            .ownerUid;
        for (final change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.removed) continue;
          try {
            final data = change.doc.data();
            if (data == null) continue;
            final expense = TourExpense.fromMap(change.doc.id, data);
            final shares = expense.shares ?? [];
            await localService.upsertExpenseWithShares(expense, shares);
            if (change.type == DocumentChangeType.modified &&
                expense.isDeleted &&
                tourOwnerUid != null &&
                currentUid != null &&
                tourOwnerUid != currentUid) {
              final notif = TourProvider.onNotification;
              notif?.call('An expense was deleted by the tour creator');
            }
          } catch (e) {
            debugPrint('Expenses listener error: $e');
          }
        }
        if (_selectedTourId == tourId) {
          await _loadTourDetails(tourId);
        }
      }, onError: (e) => debugPrint('Expenses stream error: $e')),
    ];

    _tourSubscriptions[tourId] = subs;
  }

  void disposeTourListener(String tourId) {
    final subs = _tourSubscriptions.remove(tourId);
    if (subs != null) {
      for (final sub in subs) {
        sub.cancel();
      }
    }
  }

  // ─── Lifecycle ──────────────────────────────────────────────────────

  void clear() {
    for (final subs in _tourSubscriptions.values) {
      for (final sub in subs) {
        sub.cancel();
      }
    }
    _tourSubscriptions.clear();
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
