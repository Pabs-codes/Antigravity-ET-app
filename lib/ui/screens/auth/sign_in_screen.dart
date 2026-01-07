import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/settings_provider.dart';
import '../../../core/services/auth_service.dart';
import '../../main_wrapper.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with SingleTickerProviderStateMixin {
  final _pinController = TextEditingController();
  final AuthService _authService = AuthService();
  String _error = '';

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();

    // Check biometrics after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBiometrics();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
      setState(() {
        _error = 'Incorrect PIN';
        _pinController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      body: Stack(
        children: [
           // 1. Premium Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1a1f2c), Color(0xFF121212)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          // 2. Decorative Blurred Orbs
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF9b87f5).withOpacity(0.2),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: const Icon(Icons.lock_outline_rounded, size: 48, color: Colors.white),
                        ),
                        const SizedBox(height: 30),
                        
                        // Welcome Text
                        Text(
                          'Welcome Back, ${settings.username ?? "User"}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                         const SizedBox(height: 10),
                         Text(
                          'Enter your PIN to access your finances',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white60,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // PIN Input
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                              ),
                              child: TextField(
                                controller: _pinController,
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                maxLength: 4,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 16,
                                ),
                                decoration: InputDecoration(
                                  hintText: '••••',
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.white24,
                                    letterSpacing: 16,
                                  ),
                                  counterText: "",
                                  border: InputBorder.none,
                                  errorText: _error.isNotEmpty ? _error : null,
                                  errorStyle: GoogleFonts.poppins(color: const Color(0xFFCF6679)),
                                ),
                                onChanged: (val) {
                                  if (val.length == 4) _verifyPin();
                                  if (_error.isNotEmpty) setState(() => _error = '');
                                },
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Biometrics Link
                        if (settings.isBiometricsEnabled)
                          TextButton.icon(
                            onPressed: _checkBiometrics,
                            icon: const Icon(Icons.fingerprint, color: Color(0xFF9b87f5)),
                            label: Text(
                              'Use Biometrics', 
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF9b87f5), 
                                fontWeight: FontWeight.bold
                              )
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
