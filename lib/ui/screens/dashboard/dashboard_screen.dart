import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/transaction_provider.dart';
import '../../../data/models/transaction_type.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          final currency = NumberFormat.simpleCurrency(decimalDigits: 0);

          return RefreshIndicator(
            onRefresh: () async => provider.loadData(),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Balance Card
                Card(
                  elevation: 2,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text('Current Balance',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(
                          currency.format(provider.currentBalance),
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _SummaryItem(
                              label: 'Income',
                              amount: provider.totalIncome,
                              isIncome: true,
                              currency: currency,
                            ),
                            _SummaryItem(
                              label: 'Expense',
                              amount: provider.totalExpenses,
                              isIncome: false,
                              currency: currency,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Recent Transactions',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                
                // Transaction List
                if (provider.transactions.isEmpty)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('No transactions yet'),
                  ))
                else
                  ...provider.transactions.map((tx) {
                    final isExpense = tx.type == TransactionType.expense;
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isExpense
                              ? Colors.red.withOpacity(0.1)
                              : Colors.green.withOpacity(0.1),
                          child: Icon(
                            isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                            color: isExpense ? Colors.red : Colors.green,
                          ),
                        ),
                        title: Text(tx.title),
                        subtitle: Text(DateFormat.yMMMd().format(tx.date)),
                        trailing: Text(
                          currency.format(tx.amount),
                          style: TextStyle(
                            color: isExpense ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final double amount;
  final bool isIncome;
  final NumberFormat currency;

  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.isIncome,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text(
          currency.format(amount),
          style: TextStyle(
            color: isIncome ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
