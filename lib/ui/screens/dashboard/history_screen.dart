import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../data/models/transaction_type.dart';
import '../../../core/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedCategoryId;

  void _showFilterDialog(BuildContext context, List<dynamic> categories) { // simplified dynamic typing for brevity in snippet, will handle properly
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Filter Transactions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const Text('Date Range'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _startDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) setModalState(() => _startDate = picked);
                        },
                        child: Text(_startDate == null ? 'Start Date' : DateFormat('MMM d').format(_startDate!)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _endDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) setModalState(() => _endDate = picked);
                        },
                        child: Text(_endDate == null ? 'End Date' : DateFormat('MMM d').format(_endDate!)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Category'),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Categories')),
                    ...categories.map((c) => DropdownMenuItem(
                      value: c.id, 
                      child: Text(c.name),
                    )),
                  ],
                  onChanged: (val) => setModalState(() => _selectedCategoryId = val),
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      setState(() {}); // Trigger rebuild of main filtering list
                      Navigator.pop(context);
                    },
                    child: const Text('Apply Filters'),
                  ),
                ),
                const SizedBox(height: 10),
                Center(child: TextButton(
                  onPressed: () {
                    setState(() {
                      _startDate = null;
                      _endDate = null;
                      _selectedCategoryId = null;
                    });
                    Navigator.pop(context);
                  }, 
                  child: const Text('Clear Filters')
                )),
              ],
            ),
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final currency = NumberFormat.simpleCurrency(name: settings.currencyCode, decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: AppTheme.backgroundLight,
        actions: [
          Consumer<TransactionProvider>(
            builder: (context, provider, _) => IconButton(
              icon: Icon(Icons.filter_list_rounded, 
                color: (_startDate != null || _endDate != null || _selectedCategoryId != null) 
                  ? AppTheme.accentGreen 
                  : Colors.black),
              onPressed: () => _showFilterDialog(context, provider.categories),
            ),
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          // Apply Filters
          var transactions = provider.transactions;
          
          if (_startDate != null) {
            transactions = transactions.where((t) => t.date.isAfter(_startDate!.subtract(const Duration(days: 1)))).toList();
          }
          if (_endDate != null) {
            transactions = transactions.where((t) => t.date.isBefore(_endDate!.add(const Duration(days: 1)))).toList();
          }
          if (_selectedCategoryId != null) {
            transactions = transactions.where((t) => t.categoryId == _selectedCategoryId).toList();
          }

          if (transactions.isEmpty) {
            return const Center(child: Text('No transactions found'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final tx = transactions[index];
              final isExpense = tx.type == TransactionType.expense;
              final category = provider.categories.firstWhere((c) => c.id == tx.categoryId, orElse: () => provider.categories.first);

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(category.colorValue).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      IconData(int.parse(category.iconCode), fontFamily: 'MaterialIcons'),
                      color: Color(category.colorValue),
                      size: 20,
                    ),
                  ),
                  title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(DateFormat('MMM d, y • h:mm a').format(tx.date)),
                  trailing: Text(
                    '${isExpense ? "-" : "+"}${currency.format(tx.amount)}',
                    style: TextStyle(
                      color: isExpense ? Colors.red : AppTheme.accentGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
