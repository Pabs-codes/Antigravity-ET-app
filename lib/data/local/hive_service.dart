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
    final defaults = [
      CategoryModel(id: 'food', name: 'Food', iconCode: 'fastfood', budgetLimit: 500, colorValue: 0xFFFF5722),
      CategoryModel(id: 'transport', name: 'Transport', iconCode: 'directions_bus', budgetLimit: 200, colorValue: 0xFF2196F3),
      CategoryModel(id: 'shopping', name: 'Shopping', iconCode: 'shopping_bag', budgetLimit: 300, colorValue: 0xFF9C27B0),
    ];
    
    for (var cat in defaults) {
      await categoryBox.put(cat.id, cat);
    }
  }
}
