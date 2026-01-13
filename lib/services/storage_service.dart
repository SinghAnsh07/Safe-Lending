import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // Secure Storage Keys
  static const String _privateKeyKey = 'private_key';
  static const String _publicKeyKey = 'public_key';
  static const String _userIdKey = 'user_id';
  static const String _aesKeyKey = 'aes_key';

  /// Save private key securely
  static Future<void> savePrivateKey(String privateKey) async {
    await _secureStorage.write(key: _privateKeyKey, value: privateKey);
  }

  /// Get private key
  static Future<String?> getPrivateKey() async {
    return await _secureStorage.read(key: _privateKeyKey);
  }

  /// Save public key
  static Future<void> savePublicKey(String publicKey) async {
    await _secureStorage.write(key: _publicKeyKey, value: publicKey);
  }

  /// Get public key
  static Future<String?> getPublicKey() async {
    return await _secureStorage.read(key: _publicKeyKey);
  }

  /// Save user ID
  static Future<void> saveUserId(String userId) async {
    await _secureStorage.write(key: _userIdKey, value: userId);
  }

  /// Get user ID
  static Future<String?> getUserId() async {
    return await _secureStorage.read(key: _userIdKey);
  }

  /// Save AES encryption key
  static Future<void> saveAESKey(String aesKey) async {
    await _secureStorage.write(key: _aesKeyKey, value: aesKey);
  }

  /// Get AES encryption key
  static Future<String?> getAESKey() async {
    return await _secureStorage.read(key: _aesKeyKey);
  }

  /// Clear all secure data (logout)
  static Future<void> clearSecureData() async {
    await _secureStorage.deleteAll();
  }

  /// Check if keys exist
  static Future<bool> hasKeys() async {
    final privateKey = await getPrivateKey();
    final publicKey = await getPublicKey();
    return privateKey != null && publicKey != null;
  }

  // SharedPreferences for non-sensitive data
  
  /// Save string value
  static Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  /// Get string value
  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  /// Save boolean value
  static Future<void> saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  /// Get boolean value
  static Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  /// Save integer value
  static Future<void> saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  /// Get integer value
  static Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  /// Clear all preferences
  static Future<void> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Clear all data (secure + preferences)
  static Future<void> clearAllData() async {
    await clearSecureData();
    await clearPreferences();
  }
}
