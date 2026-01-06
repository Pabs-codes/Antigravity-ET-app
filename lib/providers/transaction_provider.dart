import 'package:flutter/material.dart';
import '../data/models/transaction_model.dart';
import '../data/models/category_model.dart';
import '../data/local/hive_service.dart';
import '../data/models/transaction_type.dart';

class TransactionProvider with ChangeNotifier {
  final HiveService _hiveService = HiveService();
  
  List<TransactionModel> _transactions = [];
  List<CategoryModel> _categories = [];
  
  List<TransactionModel> get transactions => _transactions;
  List<CategoryModel> get categories => _categories;
  
  // Dashboard Metrics
  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, item) => sum + item.amount);

  double get totalExpenses => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, item) => sum + item.amount);
      
  double get currentBalance => totalIncome - totalExpenses;

  // Load Initial Data
  void loadData() {
    _transactions = _hiveService.getAllTransactions();
    _categories = _hiveService.getAllCategories();
    // Sort transactions by date descending
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  // CRUD
  Future<void> addTransaction(TransactionModel transaction) async {
    await _hiveService.addTransaction(transaction);
    loadData(); // Refresh list
  }
  
  Future<void> deleteTransaction(String id) async {
    await _hiveService.deleteTransaction(id);
    loadData();
  }

  // Categories
  Future<void> addCategory(CategoryModel category) async {
    await _hiveService.addCategory(category);
    loadData();
  }

  Future<void> updateCategoryBudget(String id, double newLimit) async {
    final index = _categories.indexWhere((c) => c.id == id);
    if (index != -1) {
      final old = _categories[index];
      final newCat = CategoryModel(
        id: old.id,
        name: old.name,
        iconCode: old.iconCode,
        budgetLimit: newLimit,
        colorValue: old.colorValue,
      );
      await _hiveService.addCategory(newCat); // Overwrite
      loadData();
    }
  }
}
