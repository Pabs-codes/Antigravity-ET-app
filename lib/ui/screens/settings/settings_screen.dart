import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../core/services/csv_service.dart';
import '../../../core/services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: settings.isDarkMode,
            onChanged: (val) => settings.toggleTheme(val),
          ),
          SwitchListTile(
            title: const Text('Biometric Authentication'),
            subtitle: const Text('Secure app on launch'),
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
