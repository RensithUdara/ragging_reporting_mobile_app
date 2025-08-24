import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class StorageService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(),
  );

  // Secure Storage Methods (for sensitive data)
  
  // Store access token
  static Future<void> storeAccessToken(String token) async {
    await _secureStorage.write(key: AppConstants.accessTokenKey, value: token);
  }

  // Get access token
  static Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: AppConstants.accessTokenKey);
  }

  // Store refresh token
  static Future<void> storeRefreshToken(String token) async {
    await _secureStorage.write(key: AppConstants.refreshTokenKey, value: token);
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: AppConstants.refreshTokenKey);
  }

  // Store user data (as JSON string)
  static Future<void> storeUserData(String userData) async {
    await _secureStorage.write(key: AppConstants.userDataKey, value: userData);
  }

  // Get user data
  static Future<String?> getUserData() async {
    return await _secureStorage.read(key: AppConstants.userDataKey);
  }

  // Clear all secure storage
  static Future<void> clearSecureStorage() async {
    await _secureStorage.deleteAll();
  }

  // Delete specific secure key
  static Future<void> deleteSecureKey(String key) async {
    await _secureStorage.delete(key: key);
  }

  // Check if secure key exists
  static Future<bool> hasSecureKey(String key) async {
    return await _secureStorage.containsKey(key: key);
  }

  // Shared Preferences Methods (for app settings)
  
  // Store theme preference
  static Future<void> storeThemePreference(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.themeKey, theme);
  }

  // Get theme preference
  static Future<String?> getThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.themeKey);
  }

  // Store language preference
  static Future<void> storeLanguagePreference(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.languageKey, language);
  }

  // Get language preference
  static Future<String?> getLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.languageKey);
  }

  // Store notification enabled status
  static Future<void> storeNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.notificationKey, enabled);
  }

  // Get notification enabled status
  static Future<bool> getNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.notificationKey) ?? true;
  }

  // Store string value
  static Future<void> storeString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  // Get string value
  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  // Store boolean value
  static Future<void> storeBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  // Get boolean value
  static Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? defaultValue;
  }

  // Store integer value
  static Future<void> storeInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  // Get integer value
  static Future<int> getInt(String key, {int defaultValue = 0}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key) ?? defaultValue;
  }

  // Store double value
  static Future<void> storeDouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  // Get double value
  static Future<double> getDouble(String key, {double defaultValue = 0.0}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key) ?? defaultValue;
  }

  // Store string list
  static Future<void> storeStringList(String key, List<String> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, value);
  }

  // Get string list
  static Future<List<String>> getStringList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key) ?? [];
  }

  // Remove key from shared preferences
  static Future<void> removeKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // Check if key exists in shared preferences
  static Future<bool> hasKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

  // Clear all shared preferences
  static Future<void> clearSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Get all keys from shared preferences
  static Future<Set<String>> getAllKeys() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getKeys();
  }

  // Complete logout - clear all stored data
  static Future<void> clearAllData() async {
    await clearSecureStorage();
    await clearSharedPreferences();
  }
}
