import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../data/models/transaction_type.dart';
import 'budget_list.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Statistics'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Expenses'),
              Tab(text: 'Budgets'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildChart(context),
            const BudgetList(),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    return Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          final expenses = provider.transactions
              .where((t) => t.type == TransactionType.expense)
              .toList();
          
          if (expenses.isEmpty) {
            return const Center(child: Text('No expenses to show'));
          }

          // Group by Category
          final Map<String, double> categoryTotals = {};
          for (var tx in expenses) {
            categoryTotals[tx.categoryId] = (categoryTotals[tx.categoryId] ?? 0) + tx.amount;
          }

          final showingSections = categoryTotals.entries.map((entry) {
             final isLarge = categoryTotals.length < 6;
             // Find category name/color from provider (requires lookup, simplified here)
             final category = provider.categories.firstWhere((c) => c.id == entry.key, orElse: () => provider.categories.first); // fallback
             
             return PieChartSectionData(
               color: Color(category.colorValue),
               value: entry.value,
               title: '\$${entry.value.toStringAsFixed(0)}',
               radius: isLarge ? 60 : 50,
               titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
             );
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: showingSections,
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Legend
                Expanded(
                  child: ListView(
                    children: categoryTotals.entries.map((e) {
                      final category = provider.categories.firstWhere((c) => c.id == e.key, orElse: () => provider.categories.first);
                      return ListTile(
                        leading: CircleAvatar(backgroundColor: Color(category.colorValue), radius: 8),
                        title: Text(category.name),
                        trailing: Text('\$${e.value.toStringAsFixed(2)}'),
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
          );
        },
      );
  }
}
