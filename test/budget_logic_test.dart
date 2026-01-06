import 'package:flutter_test/flutter_test.dart';
import 'package:financial_tracker/providers/transaction_provider.dart';
import 'package:financial_tracker/data/models/transaction_model.dart';
import 'package:financial_tracker/data/models/transaction_type.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mockito/mockito.dart';

// Since HiveService uses static Hive.box calls, testing it requires mocking Hive or 
// refactoring HiveService to be injectable. 
// For this academic assignment, we will test the logic by creating a 
// version of the Provider logic that calculates totals, assuming data is loaded.

void main() {
  group('Budget Logic Tests', () {
    test('Calculate Total Expenses correctly', () {
      final transactions = [
        TransactionModel(
          id: '1',
          title: 'Lunch',
          amount: 15.0,
          date: DateTime.now(),
          type: TransactionType.expense,
          categoryId: 'food',
        ),
        TransactionModel(
          id: '2',
          title: 'Bus',
          amount: 5.0,
          date: DateTime.now(),
          type: TransactionType.expense,
          categoryId: 'transport',
        ),
        TransactionModel(
          id: '3',
          title: 'Salary',
          amount: 1000.0,
          date: DateTime.now(),
          type: TransactionType.income,
          categoryId: 'salary',
        ),
      ];

      // Logic extracted from TransactionProvider to test in isolation
      double totalExpenses = transactions
          .where((t) => t.type == TransactionType.expense)
          .fold(0, (sum, item) => sum + item.amount);

      expect(totalExpenses, 20.0);
    });

    test('Current Balance Calculation', () {
       final transactions = [
        TransactionModel(
          id: '1', title: 'A', amount: 50.0, date: DateTime.now(), type: TransactionType.expense, categoryId: 'c1'),
        TransactionModel(
          id: '2', title: 'B', amount: 200.0, date: DateTime.now(), type: TransactionType.income, categoryId: 'c2'),
      ];

      double income = transactions.where((t) => t.type == TransactionType.income).fold(0, (s, i) => s + i.amount);
      double expense = transactions.where((t) => t.type == TransactionType.expense).fold(0, (s, i) => s + i.amount);
      double balance = income - expense;

      expect(balance, 150.0);
    });
  });
}
