import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../core/services/auth_service.dart';
import '../../main_wrapper.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  // bool _isAuthenticating = false; // This variable is no longer needed

  @override
  void initState() {
    super.initState();
    // Fix: Wait for the first frame before attempting navigation
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _checkAuth();
    // });

    // Add artificial delay for splash effect
    _performAuthCheck();
  }

  Future<void> _performAuthCheck() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final settings = Provider.of<SettingsProvider>(context, listen: false);

    if (settings.hasAccount) {
      // Account exists -> Go to Sign In (which handles Biometrics)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
      );
    } else {
      // No account -> Go to Sign Up
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SignUpScreen()),
      );
    }
  }

  // Future<void> _checkAuth() async { // This method is no longer needed
  //   final settings = Provider.of<SettingsProvider>(context, listen: false);
    
  //   // If biometrics disabled, go straight to app
  //   if (!settings.isBiometricsEnabled) {
  //     _navigateToApp();
  //     return;
  //   }

  //   // Try authenticate
  //   setState(() => _isAuthenticating = true);
  //   final auth = AuthService();
  //   final authenticated = await auth.authenticate();

  //   if (authenticated) {
  //     _navigateToApp();
  //   } else {
  //     // Show error or retry button
  //     setState(() => _isAuthenticating = false);
  //   }
  // }

  // void _navigateToApp() { // This method is no longer needed
  //   Navigator.of(context).pushReplacement(
  //     MaterialPageRoute(builder: (_) => const MainWrapper()),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
