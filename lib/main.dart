import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/local/hive_service.dart';
import 'providers/transaction_provider.dart';
import 'providers/settings_provider.dart';
import 'ui/main_wrapper.dart';
import 'ui/screens/auth/auth_check_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await HiveService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()..loadData()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Offline Financial Tracker',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: settings.isDarkMode ? Brightness.dark : Brightness.light),
              useMaterial3: true,
            ),
            home: const AuthCheckScreen(),
          );
        }
      ),
    );
  }
}
