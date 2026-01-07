import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../data/models/transaction_type.dart';
import '../../../core/app_theme.dart';
import 'budget_list.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppBar(
          title: const Text('Analytics'),
          backgroundColor: AppTheme.backgroundLight,
          elevation: 0,
          bottom: TabBar(
            labelColor: AppTheme.accentDark,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.accentGreen,
            tabs: const [
              Tab(text: 'Expenses'),
              Tab(text: 'Budgets'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBarChart(context),
            const BudgetList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final symbol = settings.currencySymbol;

    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final expenses = provider.transactions
            .where((t) => t.type == TransactionType.expense)
            .toList();
        
        if (expenses.isEmpty) {
          return const Center(child: Text('No expenses to analyze'));
        }

        // Group by Category
        final Map<String, double> categoryTotals = {};
        for (var tx in expenses) {
          categoryTotals[tx.categoryId] = (categoryTotals[tx.categoryId] ?? 0) + tx.amount;
        }

        // Sort by amount desc
        final sortedEntries = categoryTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        
        final topEntries = sortedEntries.take(7).toList(); // Show top 7 categories

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              AspectRatio(
                aspectRatio: 1.5,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: topEntries.first.value * 1.2, // add some headroom
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Colors.grey[800]!, // Fix: Use older API compatible with 0.66.2
                        tooltipPadding: const EdgeInsets.all(8),
                        tooltipMargin: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                           final catId = topEntries[group.x.toInt()].key;
                           final catName = provider.categories.firstWhere((c) => c.id == catId, orElse: () => provider.categories.first).name;
                           return BarTooltipItem(
                             '$catName\n',
                             const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                             children: [TextSpan(text: '$symbol${rod.toY.toStringAsFixed(0)}')],
                           );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= topEntries.length) return const SizedBox.shrink();
                            // Show first letter of category
                            final catId = topEntries[value.toInt()].key;
                            final catName = provider.categories.firstWhere((c) => c.id == catId).name;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                catName.substring(0, 1).toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), // Hide Y axis labels for clean look
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: topEntries.asMap().entries.map((entry) {
                      final index = entry.key;
                      final total = entry.value.value;
                      final catId = entry.value.key;
                      final category = provider.categories.firstWhere((c) => c.id == catId);
                      
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: total,
                            color: Color(category.colorValue), // Use category color
                            width: 16,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: topEntries.first.value * 1.2,
                              color: Colors.grey.withOpacity(0.1), // Track background
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 30),
             // Clean Legend List
             // ... will need to update legend item too in the next chunk if replace_file only handles contiguous blocks

              Expanded(
                child: ListView.separated(
                  itemCount: topEntries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final entry = topEntries[index];
                    final category = provider.categories.firstWhere((c) => c.id == entry.key);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Color(category.colorValue),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Text('$symbol${entry.value.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
