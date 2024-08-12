import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = Locale('en');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  ThemeProvider() {
    _loadUserPreferences();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    _saveUserPreference('theme', _themeMode == ThemeMode.dark ? 'dark' : 'light');
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
    _saveUserPreference('theme', mode == ThemeMode.dark ? 'dark' : 'light');
  }

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
    _saveUserPreference('language', locale.languageCode);
  }

  void _loadUserPreferences() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        _themeMode = userDoc['theme'] == 'dark' ? ThemeMode.dark : ThemeMode.light;
        _locale = Locale(userDoc['language'] ?? 'en');
      }
    }
    notifyListeners();
  }

  void _saveUserPreference(String key, String value) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        key: value,
      });
    }
  }
}
