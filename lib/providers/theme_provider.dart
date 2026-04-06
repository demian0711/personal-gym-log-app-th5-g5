import 'package:flutter/material.dart';

import '../services/local_storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  final LocalStorageService _storage;

  bool _isDarkMode = false;
  bool _isLoading = true;

  ThemeProvider(this._storage) {
    _load();
  }

  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> _load() async {
    _isDarkMode = await _storage.getDarkModeEnabled();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    await _storage.setDarkModeEnabled(value);
  }
}
