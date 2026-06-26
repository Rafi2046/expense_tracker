import 'package:expense_tracker/core/models/transaction_models.dart';

abstract class TransactionRepository {
  Future<List<TransactionItem>> getTransactions();
  Future<void> addTransaction(TransactionItem item, {String syncStatus = 'pending_create'});
  Future<void> updateTransaction(TransactionItem item, {String? syncStatus});
  Future<void> deleteTransaction(String id, {bool hardDelete = false});
  Future<List<TransactionItem>> getPendingTransactions();
  Future<List<String>> getPendingDeleteTransactionIds();
  Future<Set<String>> getAllPendingTransactionIds();
  Future<void> markTransactionSynced(String id);

  Future<List<CategoryItem>> getCategories();
  Future<void> addCategory(CategoryItem item, {String syncStatus = 'pending_create'});
  Future<void> deleteCategory(String id, {bool hardDelete = false});
  Future<void> renameCategory(String oldName, String newName, {required bool isIncome});
  Future<List<CategoryItem>> getPendingCategories();
  Future<List<String>> getPendingDeleteCategoryIds();
  Future<Set<String>> getAllPendingCategoryIds();
  Future<void> markCategorySynced(String id);
}
