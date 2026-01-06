import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/category_model.dart';

class CsvService {
  Future<void> exportTransactions(List<TransactionModel> transactions, List<CategoryModel> categories) async {
    List<List<dynamic>> rows = [];
    
    // Header
    rows.add([
      "Date",
      "Title",
      "Amount",
      "Type",
      "Category",
      "Note"
    ]);

    // Data
    for (var tx in transactions) {
      final categoryName = categories
          .firstWhere((c) => c.id == tx.categoryId, orElse: () => CategoryModel(id: '', name: 'Unknown', iconCode: '', budgetLimit: 0, colorValue: 0))
          .name;
          
      rows.add([
        DateFormat('yyyy-MM-dd').format(tx.date),
        tx.title,
        tx.amount.toStringAsFixed(2),
        tx.type.name,
        categoryName,
        tx.note
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);
    
    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/transactions_export.csv";
    final file = File(path);
    await file.writeAsString(csvData);

    // Share/Open
    await Share.shareXFiles([XFile(path)], text: 'Here is your transaction history.');
  }
}
