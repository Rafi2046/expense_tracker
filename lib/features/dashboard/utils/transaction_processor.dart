import 'package:flutter/material.dart';
import 'package:expense_tracker/core/models/transaction_models.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';

class TransactionProcessor {
  static List<Map<String, dynamic>> getProcessedTransactions({
    required List<TransactionItem> allTransactions,
    required List<DebtItem> debts,
    required String accountType,
    required String searchQuery,
    required DateTimeRange? selectedDateRange,
  }) {
    List<dynamic> relevantItems = [];

    for (var tx in allTransactions) {
      if (tx.paymentMethod == accountType) {
        relevantItems.add(tx);
      }
    }

    if (accountType == 'Cash') {
      for (var d in debts) {
        if (!d.isSettled) {
          relevantItems.add(d);
        }
      }
    }

    relevantItems.sort((a, b) {
      DateTime aDate = a is TransactionItem
          ? a.dateTime
          : (a as DebtItem).createdAt;
      DateTime bDate = b is TransactionItem
          ? b.dateTime
          : (b as DebtItem).createdAt;
      return aDate.compareTo(bDate);
    });

    double currentRunningBalance = 0.0;
    List<Map<String, dynamic>> processedList = [];

    for (var item in relevantItems) {
      double amount = 0.0;
      bool isIncome = false;
      String title = '';
      String category = '';
      DateTime dateTime;
      String id = '';
      dynamic originalItem = item;

      if (item is TransactionItem) {
        amount = item.amount;
        isIncome = item.isIncome;
        title = item.note.isNotEmpty ? item.note : item.category;
        category = item.category;
        dateTime = item.dateTime;
        id = item.id;
      } else {
        final debt = item as DebtItem;
        amount = debt.amount;
        isIncome = debt.isReceive;
        title = debt.name.isNotEmpty ? debt.name : 'Debt adjustment';
        category = debt.isReceive ? 'To Receive' : 'To Give';
        dateTime = debt.createdAt;
        id = debt.id;
      }

      if (isIncome) {
        currentRunningBalance += amount;
      } else {
        currentRunningBalance -= amount;
      }

      processedList.add({
        'id': id,
        'amount': amount,
        'isIncome': isIncome,
        'title': title,
        'category': category,
        'dateTime': dateTime,
        'runningBalance': currentRunningBalance,
        'item': originalItem,
      });
    }

    processedList = processedList.reversed.toList();

    if (searchQuery.trim().isNotEmpty) {
      final query = searchQuery.toLowerCase().trim();
      processedList = processedList.where((item) {
        final title = item['title'].toString().toLowerCase();
        final cat = item['category'].toString().toLowerCase();
        return title.contains(query) || cat.contains(query);
      }).toList();
    }

    if (selectedDateRange != null) {
      final start = DateTime(selectedDateRange.start.year,
          selectedDateRange.start.month, selectedDateRange.start.day);
      final end = DateTime(selectedDateRange.end.year,
          selectedDateRange.end.month, selectedDateRange.end.day, 23, 59, 59);
      processedList = processedList.where((item) {
        final date = item['dateTime'] as DateTime;
        return !date.isBefore(start) && !date.isAfter(end);
      }).toList();
    }

    return processedList;
  }

  static double calculateAccountBalance({
    required List<TransactionItem> allTransactions,
    required List<DebtItem> debts,
    required String accountType,
  }) {
    double balance = 0.0;
    for (var tx in allTransactions) {
      if (tx.paymentMethod == accountType) {
        if (tx.isIncome) {
          balance += tx.amount;
        } else {
          balance -= tx.amount;
        }
      }
    }
    if (accountType == 'Cash') {
      for (var d in debts) {
        if (d.isSettled) continue;
        if (d.isReceive) {
          balance += d.amount;
        } else {
          balance -= d.amount;
        }
      }
    }
    return balance;
  }
}
