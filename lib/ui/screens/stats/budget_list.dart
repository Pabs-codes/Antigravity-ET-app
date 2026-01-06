import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/transaction_provider.dart';
import '../../../data/models/transaction_type.dart';
import 'edit_category_dialog.dart';

class BudgetList extends StatelessWidget {
  const BudgetList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final categories = provider.categories;
        final transactions = provider.transactions;
        final currency = NumberFormat.simpleCurrency(decimalDigits: 0);
        
        return ListView.builder(
          itemCount: categories.length,
          padding: const EdgeInsets.only(bottom: 80),
          itemBuilder: (context, index) {
            final cat = categories[index];
            
            // Calculate spent amount for this category (Expenses only)
            final spent = transactions
                .where((t) => t.type == TransactionType.expense && t.categoryId == cat.id)
                .fold(0.0, (sum, t) => sum + t.amount);
            
            final limit = cat.budgetLimit;
            final progress = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
            final isExceeded = spent > limit;
            
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                             CircleAvatar(
                               radius: 16,
                               backgroundColor: Color(cat.colorValue).withOpacity(0.2),
                               child: Icon(IconData(int.tryParse(cat.iconCode) ?? 0, fontFamily: 'MaterialIcons'), size: 18, color: Color(cat.colorValue)),
                             ),
                             const SizedBox(width: 12),
                             Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () {
                            showDialog(
                              context: context, 
                              builder: (_) => EditCategoryDialog(
                                categoryId: cat.id,
                                name: cat.name,
                                currentLimit: cat.budgetLimit,
                                onSave: (newLimit) {
                                  provider.updateCategoryBudget(cat.id, newLimit);
                                },
                              )
                            );
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      color: isExceeded ? Colors.red : Color(cat.colorValue),
                      backgroundColor: Colors.grey[200],
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Spent: ${currency.format(spent)}', 
                          style: TextStyle(color: isExceeded ? Colors.red : Colors.grey[700])
                        ),
                        Text('Limit: ${currency.format(limit)}', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
