import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/app_theme.dart';
import '../../core/services/auth_service.dart';
import '../main_wrapper.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _pinController = TextEditingController();
  String _error = '';
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Try biometrics automatically if enabled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBiometrics();
    });
  }

  Future<void> _checkBiometrics() async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    if (settings.isBiometricsEnabled) {
      bool authenticated = await _authService.authenticate();
      if (authenticated && mounted) {
        _goToDashboard();
      }
    }
  }

  void _goToDashboard() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainWrapper()),
    );
  }

  void _verifyPin() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    if (_pinController.text == settings.pinCode) {
      _goToDashboard();
    } else {
      setState(() => _error = 'Incorrect PIN');
      _pinController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.read<SettingsProvider>(); // Read once for text

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.lock_rounded, size: 60, color: AppTheme.accentDark),
              const SizedBox(height: 20),
              Text(
                'Welcome Back, ${settings.username ?? "User"}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 8),
                decoration: InputDecoration(
                  hintText: 'Enter PIN',
                  errorText: _error.isNotEmpty ? _error : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  counterText: "",
                ),
                onChanged: (val) {
                  if (val.length == 4) _verifyPin();
                },
              ),
              
              const SizedBox(height: 20),
              if (settings.isBiometricsEnabled)
                TextButton.icon(
                  onPressed: _checkBiometrics,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Use Biometrics'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
