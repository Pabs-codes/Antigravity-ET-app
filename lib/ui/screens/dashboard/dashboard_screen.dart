import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/transaction_provider.dart';
import '../../../data/models/transaction_type.dart';
import '../../../core/app_theme.dart';
import '../add_transaction/add_transaction_screen.dart';
import 'history_screen.dart';
import '../settings/settings_screen.dart';
import '../../../providers/settings_provider.dart';
import '../../../core/services/csv_service.dart';
import 'package:share_plus/share_plus.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Currency format
    // Currency format
    final settings = Provider.of<SettingsProvider>(context);
    final currency = NumberFormat.currency(symbol: settings.currencySymbol, decimalDigits: 0);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false, // Let list scroll behind floating nav
        child: Consumer<TransactionProvider>(
          builder: (context, provider, child) {
            return RefreshIndicator(
              onRefresh: () async => provider.loadData(),
              child: ListView(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 100), // Bottom padding for floating nav
                children: [
                   // Header / Greeting
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Back,',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            'My Financials',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.headlineSmall?.color,
                            ),
                          ),
                        ],
                      ),
                      // Profile or Notification Icon placeholer
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                           color: Theme.of(context).canvasColor,
                           shape: BoxShape.circle,
                           border: Border.all(color: Theme.of(context).dividerColor),
                        ),
                        child: Icon(Icons.notifications_none_rounded, color: Theme.of(context).iconTheme.color),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Dark Balance Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).cardColor : AppTheme.accentDark,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentDark.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.wallet_rounded, color: Colors.white70),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Main Wallet',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Total Balance',
                          style: TextStyle(color: Colors.white60, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currency.format(provider.currentBalance),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins', 
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Action Buttons Row (Add, etc)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _ActionButton(
                              icon: Icons.add,
                              label: 'Add',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
                                );
                              },
                            ),
                            _ActionButton(
                              icon: Icons.arrow_outward_rounded,
                              label: 'Transfer',
                              onTap: () {
                                // For now, transfer is just adding a transaction (maybe link to Add with specific type later)
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
                                );
                              },
                            ),
                            _ActionButton(
                              icon: Icons.history_rounded,
                              label: 'History',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const HistoryScreen()),
                                );
                              },
                            ),
                             _ActionButton(
                              icon: Icons.more_horiz_rounded,
                              label: 'More',
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) => Container(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: const Icon(Icons.file_download),
                                          title: const Text('Export to CSV'),
                                          onTap: () async {
                                            Navigator.pop(context);
                                            await CsvService().exportTransactions(
                                              provider.transactions,
                                              provider.categories,
                                            );
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.settings),
                                          title: const Text('Settings'),
                                          onTap: () {
                                            Navigator.pop(context);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => const SettingsScreen()),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Transactions Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const HistoryScreen()),
                          );
                        }, 
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Transaction List
                  if (provider.transactions.isEmpty)
                   Container(
                     padding: const EdgeInsets.all(40),
                     alignment: Alignment.center,
                     child: Column(
                       children: [
                         Icon(Icons.receipt_long_rounded, size: 60, color: Colors.grey[300]),
                         const SizedBox(height: 10),
                         Text('No transactions yet', style: TextStyle(color: Colors.grey[500])),
                       ],
                     ),
                   )
                  else
                    ...provider.transactions.take(10).map((tx) {
                      final isExpense = tx.type == TransactionType.expense;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isExpense 
                                  ? Colors.red.withOpacity(0.1) 
                                  : AppTheme.accentGreen.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isExpense ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                              color: isExpense ? Colors.red : AppTheme.accentGreen,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            tx.title, 
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          subtitle: Text(
                            DateFormat('MMM d, y').format(tx.date),
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          ),
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
                    }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white, // Always white to pop against dark card
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF1A1A1A), size: 22), // Always dark icon
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12), // Always white text
          ),
        ],
      ),
    );
  }
}
