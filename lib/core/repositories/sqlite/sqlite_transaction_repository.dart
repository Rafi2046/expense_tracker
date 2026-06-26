import '../../models/transaction_models.dart';
import '../../utils/database_helper.dart';
import '../transaction_repository.dart';

class SqliteTransactionRepository implements TransactionRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  @override
  Future<List<TransactionItem>> getTransactions() => _db.readAllTransactions();

  @override
  Future<void> addTransaction(TransactionItem item, {String syncStatus = 'pending_create'}) =>
      _db.insertTransaction(item, syncStatus: syncStatus);

  @override
  Future<void> updateTransaction(TransactionItem item, {String? syncStatus}) =>
      _db.updateTransaction(item, syncStatus: syncStatus);

  @override
  Future<void> deleteTransaction(String id, {bool hardDelete = false}) {
    if (hardDelete) {
      return _db.hardDeleteTransaction(id);
    } else {
      return _db.softDeleteTransaction(id);
    }
  }

  @override
  Future<List<TransactionItem>> getPendingTransactions() => _db.readPendingSyncs();

  @override
  Future<List<String>> getPendingDeleteTransactionIds() => _db.readPendingDeleteIds();

  @override
  Future<Set<String>> getAllPendingTransactionIds() => _db.readAllPendingIds();

  @override
  Future<void> markTransactionSynced(String id) => _db.markSynced(id);

  // Categories
  @override
  Future<List<CategoryItem>> getCategories() => _db.readAllCategories();

  @override
  Future<void> addCategory(CategoryItem item, {String syncStatus = 'pending_create'}) =>
      _db.insertCategory(item, syncStatus: syncStatus);

  @override
  Future<void> deleteCategory(String id, {bool hardDelete = false}) {
    if (hardDelete) {
      return _db.hardDeleteCategory(id);
    } else {
      return _db.softDeleteCategory(id);
    }
  }

  @override
  Future<void> renameCategory(String oldName, String newName, {required bool isIncome}) =>
      _db.renameCategory(oldName, newName, isIncome: isIncome);

  @override
  Future<List<CategoryItem>> getPendingCategories() => _db.readPendingCategorySyncs();

  @override
  Future<List<String>> getPendingDeleteCategoryIds() => _db.readPendingCategoryDeleteIds();

  @override
  Future<Set<String>> getAllPendingCategoryIds() => _db.readAllPendingCategoryIds();

  @override
  Future<void> markCategorySynced(String id) => _db.markCategorySynced(id);
}
