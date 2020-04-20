import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

const String _storageKey = "toledscovid_";

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

Preferences preferences = Preferences();

class Preferences {
  /// ----------------------------------------------------------
  /// Generic routine to fetch a preference
  /// ----------------------------------------------------------
  Future<String> _getApplicationSavedInformation(String name) async {
    final SharedPreferences prefs = await _prefs;

    return prefs.getString(_storageKey + name) ?? '';
  }

  /// ----------------------------------------------------------
  /// Generic routine to saves a preference
  /// ----------------------------------------------------------
  Future<bool> _setApplicationSavedInformation(String name, String value) async {
    final SharedPreferences prefs = await _prefs;

    return prefs.setString(_storageKey + name, value);
  }

  /// ----------------------------------------------------------
  /// Method that saves/restores the data
  /// ----------------------------------------------------------
  Future<String> getData(String key) async {
    return _getApplicationSavedInformation(key);
  }

  Future<bool> setData(String key, String value) async {
    return _setApplicationSavedInformation(key, value);
  }

  Future<bool> getBoolean(String key) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getBool(_storageKey + key);
  }

  Future<bool> setBoolean(String key, bool value) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setBool(_storageKey + key, value);
  }

  /// ----------------------------------------------------------
  /// Method that saves/restores the encrypted data
  /// ----------------------------------------------------------
  getDecryptedData(String key) async {
    return _getApplicationSavedInformation(key);
  }

  setEncryptedData(String key, String value) async {
    return _setApplicationSavedInformation(key, value);
  }

  /// ----------------------------------------------------------
  /// Method to remove data
  /// ----------------------------------------------------------
  Future<bool> remove(String key) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.remove(_storageKey + key);
  }

  /// ----------------------------------------------------------
  /// Method to remove data
  /// ----------------------------------------------------------
  Future<bool> clear() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.clear();
  }


  // ------------------ SINGLETON -----------------------
  static final Preferences _preferences = Preferences._internal();
  factory Preferences() {
    return _preferences;
  }
  Preferences._internal();
}
