import 'package:flutter/material.dart';
import '../data/local/hive_service.dart';

class SettingsProvider with ChangeNotifier {
  static const String _darkModeKey = 'darkMode';
  static const String _biometricsKey = 'biometrics';
  
  // Directly access the box from HiveService
  final _box = HiveService.settingsBox;

  bool get isDarkMode => _box.get(_darkModeKey, defaultValue: false);
  bool get isBiometricsEnabled => _box.get(_biometricsKey, defaultValue: false);

  Future<void> toggleTheme(bool value) async {
    await _box.put(_darkModeKey, value);
    notifyListeners();
  }

  Future<void> toggleBiometrics(bool value) async {
    await _box.put(_biometricsKey, value);
    notifyListeners();
  }
}
