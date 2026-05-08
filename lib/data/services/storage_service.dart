import 'dart:convert';
import '../../core/values/app_value.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure Storage Service for sensitive data
class StorageService extends GetxService {
  late final FlutterSecureStorage _secureStorage;

  /// Initialize storage services
  Future<StorageService> init() async {
    _secureStorage = const FlutterSecureStorage();
    return this;
  }

  // ==================== SECURE STORAGE ====================
  // For sensitive data like tokens

  /// Save token securely
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: AppValues.keyToken, value: token);
  }

  /// Get token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: AppValues.keyToken);
  }

  /// Save refresh token securely
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: AppValues.keyRefreshToken, value: token);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: AppValues.keyRefreshToken);
  }

  /// Clear all secure data
  Future<void> clearSecureData() async {
    await _secureStorage.deleteAll();
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    await _secureStorage.write(key: AppValues.keyUserId, value: userId);
  }

  /// Get user ID
  Future<String?> getUserId() async {
    return await _secureStorage.read(key: AppValues.keyUserId);
  }

  /// Save current user JSON payload
  Future<void> saveCurrentUser(Map<String, dynamic> userJson) async {
    await _secureStorage.write(
      key: AppValues.keyCurrentUser,
      value: jsonEncode(userJson),
    );
  }

  /// Get current user JSON payload
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final raw = await _secureStorage.read(key: AppValues.keyCurrentUser);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      // Ignore invalid cache
    }
    return null;
  }

  /// Clear current user cache only
  Future<void> clearCurrentUser() async {
    await _secureStorage.delete(key: AppValues.keyCurrentUser);
  }

  /// Save language preference
  Future<void> saveLanguage(String language) async {
    await _secureStorage.write(key: AppValues.keyLanguage, value: language);
  }

  /// Get language preference
  Future<String> getLanguage() async {
    return await _secureStorage.read(key: AppValues.keyLanguage) ?? 'fr';
  }

  /// Save theme mode
  Future<void> saveThemeMode(String themeMode) async {
    await _secureStorage.write(key: AppValues.keyThemeMode, value: themeMode);
  }

  /// Get theme mode
  Future<String> getThemeMode() async {
    return await _secureStorage.read(key: AppValues.keyThemeMode) ?? 'light';
  }

  /// Save string value
  Future<void> saveString(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  /// Get string value
  Future<String?> getString(String key) async {
    return await _secureStorage.read(key: key);
  }

  /// Save boolean value
  Future<void> saveBool(String key, bool value) async {
    await _secureStorage.write(key: key, value: value ? 'true' : 'false');
  }

  /// Get boolean value
  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final raw = await _secureStorage.read(key: key);
    if (raw == null) return defaultValue;
    return raw.toLowerCase() == 'true';
  }

  /// Save integer value
  Future<void> saveInt(String key, int value) async {
    await _secureStorage.write(key: key, value: value.toString());
  }

  /// Get integer value
  Future<int> getInt(String key, {int defaultValue = 0}) async {
    final raw = await _secureStorage.read(key: key);
    if (raw == null) return defaultValue;
    return int.tryParse(raw) ?? defaultValue;
  }

  /// Clear all stored data
  Future<void> clearPreferences() async {
    await _secureStorage.deleteAll();
  }

  /// Clear all data (secure storage)
  Future<void> clearAll() async {
    await clearSecureData();
  }

  /// Remove specific key
  Future<void> remove(String key) async {
    await _secureStorage.delete(key: key);
  }
}
