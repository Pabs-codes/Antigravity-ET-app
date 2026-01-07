import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/transaction_type.dart';

class HiveService {
  static const String transactionBoxName = 'transactions';
  static const String categoryBoxName = 'categories';
  static const String settingsBoxName = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register Adapters
    Hive.registerAdapter(TransactionModelAdapter());
    Hive.registerAdapter(CategoryModelAdapter());
    Hive.registerAdapter(TransactionTypeAdapter());

    // Open Boxes
    await Hive.openBox<TransactionModel>(transactionBoxName);
    await Hive.openBox<CategoryModel>(categoryBoxName);
    await Hive.openBox(settingsBoxName);
  }

  static Box<TransactionModel> get transactionBox =>
      Hive.box<TransactionModel>(transactionBoxName);

  static Box<CategoryModel> get categoryBox =>
      Hive.box<CategoryModel>(categoryBoxName);

  static Box get settingsBox => Hive.box(settingsBoxName);

  // --- Transaction Operations ---
  
  Future<void> addTransaction(TransactionModel transaction) async {
    await transactionBox.put(transaction.id, transaction);
  }

  Future<void> deleteTransaction(String id) async {
    await transactionBox.delete(id);
  }

  List<TransactionModel> getAllTransactions() {
    return transactionBox.values.toList();
  }

  // --- Category Operations ---

  Future<void> addCategory(CategoryModel category) async {
    await categoryBox.put(category.id, category);
  }

  List<CategoryModel> getAllCategories() {
    if (categoryBox.isEmpty) {
      _seedDefaultCategories();
    }
    return categoryBox.values.toList();
  }
  
  Future<void> _seedDefaultCategories() async {
    final expenseDefaults = [
      CategoryModel(id: 'food', name: 'Food', iconCode: '0xe532', budgetLimit: 500, colorValue: 0xFFFF5722, type: 'expense'),
      CategoryModel(id: 'groceries', name: 'Groceries', iconCode: '0xe8cc', budgetLimit: 400, colorValue: 0xFF4CAF50, type: 'expense'),
      CategoryModel(id: 'transport', name: 'Transport', iconCode: '0xe530', budgetLimit: 200, colorValue: 0xFF2196F3, type: 'expense'),
      CategoryModel(id: 'rent', name: 'Rent', iconCode: '0xe88a', budgetLimit: 1000, colorValue: 0xFF795548, type: 'expense'),
      CategoryModel(id: 'utilities', name: 'Utilities', iconCode: '0xe3a8', budgetLimit: 150, colorValue: 0xFFFFC107, type: 'expense'),
      CategoryModel(id: 'healthcare', name: 'Healthcare', iconCode: '0xe3ae', budgetLimit: 200, colorValue: 0xFFF44336, type: 'expense'),
      CategoryModel(id: 'shopping', name: 'Shopping', iconCode: '0xe8f6', budgetLimit: 300, colorValue: 0xFF9C27B0, type: 'expense'),
      CategoryModel(id: 'entertainment', name: 'Entertainment', iconCode: '0xe406', budgetLimit: 150, colorValue: 0xFF3F51B5, type: 'expense'),
      CategoryModel(id: 'education', name: 'Education', iconCode: '0xe80c', budgetLimit: 500, colorValue: 0xFF009688, type: 'expense'),
      CategoryModel(id: 'misc', name: 'Miscellaneous', iconCode: '0xeac6', budgetLimit: 100, colorValue: 0xFF607D8B, type: 'expense'),
    ];

    final incomeDefaults = [
      CategoryModel(id: 'salary', name: 'Salary', iconCode: '0xe250', budgetLimit: 0, colorValue: 0xFF4CAF50, type: 'income'), // attach_money
      CategoryModel(id: 'business', name: 'Business', iconCode: '0xeb3f', budgetLimit: 0, colorValue: 0xFF2196F3, type: 'income'), // business_center
      CategoryModel(id: 'other_income', name: 'Other', iconCode: '0xe3c9', budgetLimit: 0, colorValue: 0xFF9C27B0, type: 'income'), // attach_file -> tune ? using misc icon equivalent
    ];
    
    for (var cat in expenseDefaults) {
      await categoryBox.put(cat.id, cat);
    }
    for (var cat in incomeDefaults) {
      await categoryBox.put(cat.id, cat);
    }
  }
}
