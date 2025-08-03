import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'isEnglish';
  bool _isEnglish = false;
  late SharedPreferences _prefs;

  LanguageProvider() {
    _loadLanguagePreference();
  }

  bool get isEnglish => _isEnglish;

  Future<void> _loadLanguagePreference() async {
    _prefs = await SharedPreferences.getInstance();
    _isEnglish = _prefs.getBool(_languageKey) ?? false;
    notifyListeners();
  }

  Future<void> setLanguage(bool value) async {
    _isEnglish = value;
    await _prefs.setBool(_languageKey, value);
    notifyListeners();
  }
} 