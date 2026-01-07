import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../core/services/csv_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/models/category_model.dart';
import 'dart:math';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showCurrencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select Currency'),
          children: ['USD', 'EUR', 'GBP', 'INR', 'JPY', 'CAD', 'AUD'].map((code) {
            return SimpleDialogOption(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(code, style: const TextStyle(fontSize: 16)),
              ),
              onPressed: () {
                Provider.of<SettingsProvider>(context, listen: false).setCurrency(code);
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      }
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    int selectedColor = 0xFF4CAF50; // default green
    String selectedIcon = '0xe532'; // default fastfood

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Category'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     TextField(
                       controller: nameController,
                       decoration: const InputDecoration(labelText: 'Category Name', border: OutlineInputBorder()),
                     ),
                     const SizedBox(height: 20),
                     const Text('Select Color'),
                     const SizedBox(height: 10),
                     Wrap(
                       spacing: 10,
                       runSpacing: 10,
                       children: [
                         0xFFF44336, 0xFFE91E63, 0xFF9C27B0, 0xFF673AB7,
                         0xFF3F51B5, 0xFF2196F3, 0xFF009688, 0xFF4CAF50,
                         0xFFFFC107, 0xFFFF9800, 0xFFFF5722, 0xFF795548, 0xFF607D8B
                       ].map((color) => GestureDetector(
                         onTap: () => setState(() => selectedColor = color),
                         child: Container(
                           width: 32, height: 32,
                           decoration: BoxDecoration(
                             color: Color(color),
                             shape: BoxShape.circle,
                             border: selectedColor == color ? Border.all(width: 3, color: Colors.black) : null,
                           ),
                         ),
                       )).toList(),
                     ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context), 
                  child: const Text('Cancel')
                ),
                FilledButton(
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      final newCat = CategoryModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text.trim(),
                        iconCode: '0xeac6', // default icon for custom
                        budgetLimit: 0, // default no budget
                        colorValue: selectedColor
                      );
                      // Access internal HiveService via Provider or directly if needed, 
                      // but ideally we should expose addCategory in TransactionProvider
                      // For now, we'll hack it nicely by adding to the box directly or updating provider
                      final provider = Provider.of<TransactionProvider>(context, listen: false);
                      provider.addCategory(newCat); 
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Theme
          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: const Icon(Icons.dark_mode),
            value: settings.isDarkMode,
            onChanged: (val) => settings.toggleTheme(val),
          ),
          
          // Currency
          ListTile(
            title: const Text('Currency'),
            subtitle: Text(settings.currencyCode),
            leading: const Icon(Icons.attach_money),
            onTap: () => _showCurrencyDialog(context),
          ),

          const Divider(),

          // Categories
          ListTile(
            title: const Text('Add New Category'),
            leading: const Icon(Icons.category),
            onTap: () => _showAddCategoryDialog(context),
          ),

          const Divider(),

          // Security
          SwitchListTile(
            title: const Text('Biometric Authentication'),
            subtitle: const Text('Secure app on launch'),
            secondary: const Icon(Icons.fingerprint),
            value: settings.isBiometricsEnabled,
            onChanged: (val) async {
              if (val) {
                // Verify supports biometrics first
                final auth = AuthService();
                final available = await auth.isBiometricAvailable();
                if (!available) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Biometrics not available on this device')),
                    );
                  }
                  return;
                }
              }
              settings.toggleBiometrics(val);
            },
          ),
          
          const Divider(),

          // Data
          ListTile(
            title: const Text('Export to CSV'),
            subtitle: const Text('Save your transaction history'),
            leading: const Icon(Icons.file_download),
            onTap: () async {
              final txProvider = Provider.of<TransactionProvider>(context, listen: false);
              final csvService = CsvService();
              await csvService.exportTransactions(txProvider.transactions, txProvider.categories);
            },
          ),
        ],
      ),
    );
  }
}

