import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt_lib;

class AESService {
  /// Generate a random AES-256 key
  static encrypt_lib.Key generateKey() {
    return encrypt_lib.Key.fromSecureRandom(32); // 256 bits
  }

  /// Generate a random IV (Initialization Vector)
  static encrypt_lib.IV generateIV() {
    return encrypt_lib.IV.fromSecureRandom(16); // 128 bits
  }

  /// Encrypt data using AES-256
  static String encrypt(String plainText, encrypt_lib.Key key) {
    final iv = generateIV();
    final encrypter = encrypt_lib.Encrypter(
      encrypt_lib.AES(key, mode: encrypt_lib.AESMode.cbc),
    );
    
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    
    // Combine IV and encrypted data
    final combined = {
      'iv': iv.base64,
      'data': encrypted.base64,
    };
    
    return base64Encode(utf8.encode(json.encode(combined)));
  }

  /// Decrypt data using AES-256
  static String decrypt(String encryptedData, encrypt_lib.Key key) {
    try {
      final jsonString = utf8.decode(base64Decode(encryptedData));
      final combined = json.decode(jsonString) as Map<String, dynamic>;
      
      final iv = encrypt_lib.IV.fromBase64(combined['iv']);
      final encrypted = encrypt_lib.Encrypted.fromBase64(combined['data']);
      
      final encrypter = encrypt_lib.Encrypter(
        encrypt_lib.AES(key, mode: encrypt_lib.AESMode.cbc),
      );
      
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  /// Encrypt bytes
  static Uint8List encryptBytes(Uint8List plainBytes, encrypt_lib.Key key) {
    final iv = generateIV();
    final encrypter = encrypt_lib.Encrypter(
      encrypt_lib.AES(key, mode: encrypt_lib.AESMode.cbc),
    );
    
    final encrypted = encrypter.encryptBytes(plainBytes, iv: iv);
    
    // Combine IV and encrypted data
    final combined = Uint8List(iv.bytes.length + encrypted.bytes.length);
    combined.setRange(0, iv.bytes.length, iv.bytes);
    combined.setRange(iv.bytes.length, combined.length, encrypted.bytes);
    
    return combined;
  }

  /// Decrypt bytes
  static Uint8List decryptBytes(Uint8List encryptedBytes, encrypt_lib.Key key) {
    try {
      // Extract IV and encrypted data
      final iv = encrypt_lib.IV(encryptedBytes.sublist(0, 16));
      final encrypted = encrypt_lib.Encrypted(encryptedBytes.sublist(16));
      
      final encrypter = encrypt_lib.Encrypter(
        encrypt_lib.AES(key, mode: encrypt_lib.AESMode.cbc),
      );
      
      return Uint8List.fromList(encrypter.decryptBytes(encrypted, iv: iv));
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  /// Convert key to base64 string for storage
  static String keyToString(encrypt_lib.Key key) {
    return key.base64;
  }

  /// Convert base64 string to key
  static encrypt_lib.Key keyFromString(String keyString) {
    return encrypt_lib.Key.fromBase64(keyString);
  }
}
