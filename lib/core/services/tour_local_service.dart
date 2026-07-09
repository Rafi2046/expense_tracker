import 'package:sqflite/sqflite.dart';
import 'package:expense_tracker/core/models/tour.dart';
import 'package:expense_tracker/core/models/tour_participant.dart';
import 'package:expense_tracker/core/models/tour_expense.dart';
import 'package:expense_tracker/core/models/tour_expense_share.dart';

class TourLocalService {
  final Database db;

  TourLocalService(this.db);

  Future<void> saveJoinedTourLocally(
    Tour tour,
    List<TourParticipant> participants,
    {List<TourExpense> expenses = const [],
    List<TourExpenseShare> shares = const []}
  ) async {
    await db.transaction((txn) async {
      await txn.insert(
        'tours',
        tour.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (final p in participants) {
        await txn.insert(
          'tour_participants',
          p.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // Remove stale shares for this tour before inserting fresh data
      final expenseIds = expenses.map((e) => e.id).toList();
      if (expenseIds.isNotEmpty) {
        final placeholders = expenseIds.map((_) => '?').join(',');
        await txn.delete(
          'tour_expense_shares',
          where: 'expenseId IN ($placeholders)',
          whereArgs: expenseIds,
        );
      }

      for (final e in expenses) {
        await txn.insert(
          'tour_expenses',
          e.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      for (final s in shares) {
        await txn.insert(
          'tour_expense_shares',
          s.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> upsertTour(Tour tour) async {
    await db.insert(
      'tours',
      tour.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> upsertParticipant(TourParticipant participant) async {
    await db.insert(
      'tour_participants',
      participant.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> upsertExpenseWithShares(
    TourExpense expense,
    List<TourExpenseShare> shares,
  ) async {
    await db.transaction((txn) async {
      await txn.insert(
        'tour_expenses',
        expense.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      // Delete any existing shares for this expense first to prevent
      // orphan accumulation when share IDs change across sync cycles.
      await txn.delete(
        'tour_expense_shares',
        where: 'expenseId = ?',
        whereArgs: [expense.id],
      );
      for (final s in shares) {
        await txn.insert(
          'tour_expense_shares',
          s.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}
