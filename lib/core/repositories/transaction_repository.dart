import 'package:expense_tracker/core/models/transaction_models.dart';

abstract class TransactionRepository {
  Future<List<TransactionItem>> getTransactions({required String profileId});
  Future<void> addTransaction(TransactionItem item, {required String profileId, String syncStatus = 'pending_create'});
  Future<void> updateTransaction(TransactionItem item, {required String profileId, String? syncStatus});
  Future<void> deleteTransaction(String id, {required String profileId, bool hardDelete = false});
  Future<List<TransactionItem>> getPendingTransactions({required String profileId});
  Future<List<String>> getPendingDeleteTransactionIds({required String profileId});
  Future<Set<String>> getAllPendingTransactionIds({required String profileId});
  Future<void> markTransactionSynced(String id, {required String profileId});

  Future<List<CategoryItem>> getCategories({required String profileId});
  Future<void> addCategory(CategoryItem item, {required String profileId, String syncStatus = 'pending_create'});
  Future<void> deleteCategory(String id, {required String profileId, bool hardDelete = false});
  Future<void> renameCategory(String oldName, String newName, {required bool isIncome, required String profileId});
  Future<List<CategoryItem>> getPendingCategories({required String profileId});
  Future<List<String>> getPendingDeleteCategoryIds({required String profileId});
  Future<Set<String>> getAllPendingCategoryIds({required String profileId});
  Future<void> markCategorySynced(String id, {required String profileId});
}
