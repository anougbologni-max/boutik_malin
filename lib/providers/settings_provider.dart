import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _keyShopName = 'shopName';
  static const _keyOwnerName = 'ownerName';
  static const _keyDefaultThreshold = 'defaultThreshold';
  static const _keyNotificationsEnabled = 'notificationsEnabled';
  static const _keyDarkMode = 'darkMode';
  static const _keyCurrencyCode = 'currencyCode';

  static const currencySymbols = {
    'EUR': '€',
    'USD': '\$',
    'XOF': 'FCFA',
    'MAD': 'DH',
  };

  String shopName = 'Ma Boutique';
  String ownerName = '';
  int defaultThreshold = 5;
  bool notificationsEnabled = true;
  bool darkMode = false;
  String currencyCode = 'EUR';
  bool _isLoaded = false;

  String get currencySymbol => currencySymbols[currencyCode] ?? '€';

  bool get isLoaded => _isLoaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    shopName = prefs.getString(_keyShopName) ?? shopName;
    ownerName = prefs.getString(_keyOwnerName) ?? ownerName;
    defaultThreshold = prefs.getInt(_keyDefaultThreshold) ?? defaultThreshold;
    notificationsEnabled = prefs.getBool(_keyNotificationsEnabled) ?? notificationsEnabled;
    darkMode = prefs.getBool(_keyDarkMode) ?? darkMode;
    currencyCode = prefs.getString(_keyCurrencyCode) ?? currencyCode;
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> updateShopProfile({required String shopName, required String ownerName}) async {
    this.shopName = shopName;
    this.ownerName = ownerName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyShopName, shopName);
    await prefs.setString(_keyOwnerName, ownerName);
    notifyListeners();
  }

  Future<void> updateDefaultThreshold(int value) async {
    defaultThreshold = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDefaultThreshold, value);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationsEnabled, value);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    darkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, value);
    notifyListeners();
  }

  Future<void> setCurrencyCode(String value) async {
    currencyCode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrencyCode, value);
    notifyListeners();
  }
}
