import 'package:flutter/material.dart';
import '../data/local/hive_service.dart';

class SettingsProvider with ChangeNotifier {
  static const String _darkModeKey = 'darkMode';
  static const String _biometricsKey = 'biometrics';
  
  // Directly access the box from HiveService
  final _box = HiveService.settingsBox;

  static const String _usernameKey = 'username';
  static const String _pinCodeKey = 'pinCode';
  static const String _currencyKey = 'currency';

  static const Map<String, String> currencySymbols = {
    'USD': '\$', 'EUR': '€', 'GBP': '£', 'JPY': '¥', 'AUD': 'A\$', 'CAD': 'C\$',
    'CHF': 'CHF', 'CNY': '¥', 'INR': '₹', 'SGD': 'S\$', 'NZD': 'NZ\$',
    'SEK': 'kr', 'NOK': 'kr', 'DKK': 'kr', 'ZAR': 'R', 'MYR': 'RM',
    'HKD': 'HK\$', 'KRW': '₩', 'AED': 'د.إ', 'LKR': 'Rs'
  };

  bool get isDarkMode => _box.get(_darkModeKey, defaultValue: false);
  bool get isBiometricsEnabled => _box.get(_biometricsKey, defaultValue: false);
  String get currencyCode => _box.get(_currencyKey, defaultValue: 'USD');
  String get currencySymbol => currencySymbols[currencyCode] ?? '\$';
  
  String? get username => _box.get(_usernameKey);
  String? get pinCode => _box.get(_pinCodeKey);
  bool get hasAccount => username != null && pinCode != null;

  Future<void> toggleTheme(bool value) async {
    await _box.put(_darkModeKey, value);
    notifyListeners();
  }

  Future<void> toggleBiometrics(bool value) async {
    await _box.put(_biometricsKey, value);
    notifyListeners();
  }

  Future<void> setCurrency(String code) async {
    await _box.put(_currencyKey, code);
    notifyListeners();
  }

  Future<void> createAccount(String name, String pin) async {
    await _box.put(_usernameKey, name);
    await _box.put(_pinCodeKey, pin);
    notifyListeners();
  }
}
