import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/local/hive_service.dart';
import 'providers/transaction_provider.dart';
import 'providers/settings_provider.dart';
import 'ui/main_wrapper.dart';
import 'ui/screens/auth/auth_check_screen.dart';
import 'core/app_theme.dart';

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
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme, 
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const AuthCheckScreen(),
          );
        }
      ),
    );
  }
}
