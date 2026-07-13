import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../models/sync_progress.dart';
import '../utils/database_helper.dart';

class SyncService {
  final _progressController = StreamController<SyncProgress>();

  Stream<SyncProgress> get progress => _progressController.stream;

  Future<void> sync(String uid) async {
    try {
      _progressController.add(
        const SyncProgress(currentTable: 'Checking local data…'),
      );

      final db = DatabaseHelper.instance;
      final count = Sqflite.firstIntValue(
        await (await db.database).rawQuery('SELECT COUNT(*) FROM transactions'),
      );
      if (count != null && count > 0) {
        _progressController.add(const SyncProgress(isComplete: true));
        return;
      }

      _progressController.add(
        const SyncProgress(currentTable: 'Clearing local data…'),
      );
      await db.clearUserData();

      final firestore = FirebaseFirestore.instance;
      final collections = {
        'transactions': firestore
            .collection('users')
            .doc(uid)
            .collection('transactions')
            .get(),
        'categories': firestore
            .collection('users')
            .doc(uid)
            .collection('categories')
            .get(),
        'debt_items': firestore
            .collection('users')
            .doc(uid)
            .collection('debt_items')
            .get(),
        'budget': firestore
            .collection('users')
            .doc(uid)
            .collection('budget')
            .get(),
        'notes': firestore
            .collection('users')
            .doc(uid)
            .collection('notes')
            .get(),
        'profiles': firestore
            .collection('users')
            .doc(uid)
            .collection('profiles')
            .get(),
      };

      final results = <String, QuerySnapshot>{};
      for (final entry in collections.entries) {
        _progressController.add(
          SyncProgress(currentTable: 'Fetching ${entry.key}…'),
        );
        results[entry.key] = await entry.value;
      }

      final database = await db.database;
      await database.transaction((txn) async {
        for (final entry in results.entries) {
          final table = entry.key;
          final snapshot = entry.value;
          final docs = snapshot.docs;
          if (docs.isEmpty) continue;

          _progressController.add(
            SyncProgress(
              currentTable: 'Restoring $table (${docs.length} records)…',
              documentsFetched: docs.length,
            ),
          );

          for (final doc in docs) {
            final row = _buildRow(table, doc);
            if (row != null) {
              await txn.insert(
                table,
                row,
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
          }
        }
      });

      final profileCount = Sqflite.firstIntValue(
        await database.rawQuery('SELECT COUNT(*) FROM profiles'),
      );
      if (profileCount == null || profileCount == 0) {
        await db.insertProfile({
          'id': 'default_profile',
          'name': 'Personal',
          'type': 'Personal',
          'createdAt': DateTime.now().toIso8601String(),
        });
      }

      if (kDebugMode) {
        await db.checkDatabaseEmptyStatus();
      }

      _progressController.add(const SyncProgress(isComplete: true));
    } catch (e) {
      _progressController.add(
        SyncProgress(isComplete: true, error: e.toString()),
      );
    }
  }

  Map<String, dynamic>? _buildRow(String table, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return null;

    switch (table) {
      case 'transactions':
        return {
          'id': doc.id,
          'amount': data['amount'],
          'category': data['category'] ?? '',
          'note': data['note'] ?? '',
          'isIncome': data['isIncome'] == true ? 1 : 0,
          'dateTime': data['dateTime'],
          'incomeMonth': data['incomeMonth'],
          'paymentMethod': data['paymentMethod'] ?? 'Cash',
          'syncStatus': 'synced',
          'isDeleted': 0,
          'lastModified': data['lastModified'] ?? data['dateTime'],
          'profileId': data['profileId'] ?? 'default_profile',
          'partyName': data['partyName'],
        };

      case 'categories':
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'isIncome': data['isIncome'] == true ? 1 : 0,
          'syncStatus': 'synced',
          'isDeleted': 0,
          'lastModified':
              data['lastModified'] ?? DateTime.now().toIso8601String(),
          'profileId': data['profileId'] ?? 'default_profile',
        };

      case 'debt_items':
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'detail': data['detail'] ?? '',
          'amount': data['amount'],
          'isReceive': data['isReceive'] == true ? 1 : 0,
          'isSettled': data['isSettled'] == true ? 1 : 0,
          'phone': data['phone'],
          'email': data['email'],
          'address': data['address'],
          'vat': data['vat'],
          'createdAt': data['createdAt'],
          'syncStatus': 'synced',
          'isDeleted': 0,
          'profileId': data['profileId'] ?? 'default_profile',
        };

      case 'budget':
        return {
          'id': 'monthly',
          'amount': data['amount'],
          'syncStatus': 'synced',
          'lastModified':
              data['lastModified'] ?? DateTime.now().toIso8601String(),
          'profileId': data['profileId'] ?? _extractProfileId(doc.id),
        };

      case 'notes':
        return {
          'id': doc.id,
          'title': data['title'] ?? '',
          'content': data['content'] ?? '',
          'createdAt': data['createdAt'] ?? DateTime.now().toIso8601String(),
          'category': data['category'] ?? 'General',
          'profileId': data['profileId'] ?? 'default_profile',
        };

      case 'profiles':
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Personal',
          'type': data['type'] ?? 'Personal',
          'createdAt': data['createdAt'] ?? DateTime.now().toIso8601String(),
          'uid': FirebaseAuth.instance.currentUser?.uid,
        };

      default:
        return null;
    }
  }

  String _extractProfileId(String docId) {
    if (docId.startsWith('monthly_')) {
      return docId.substring(8);
    }
    return 'default_profile';
  }

  void dispose() {
    _progressController.close();
  }
}
