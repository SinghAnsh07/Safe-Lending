import 'package:flutter_test/flutter_test.dart';
import 'package:tpln/crypto/rsa_service.dart';
import 'package:tpln/crypto/hash_service.dart';

void main() {
  group('RSA Service Tests', () {
    test('Generate RSA key pair', () {
      final keyPair = RSAService.generateKeyPair();
      
      expect(keyPair.publicKey, isNotNull);
      expect(keyPair.privateKey, isNotNull);
      expect(keyPair.publicKey.modulus, isNotNull);
      expect(keyPair.privateKey.modulus, isNotNull);
    });

    test('Convert keys to PEM and back', () {
      final keyPair = RSAService.generateKeyPair();
      
      // Convert to PEM
      final publicPem = RSAService.publicKeyToPem(keyPair.publicKey);
      final privatePem = RSAService.privateKeyToPem(keyPair.privateKey);
      
      expect(publicPem, isNotEmpty);
      expect(privatePem, isNotEmpty);
      
      // Convert back from PEM
      final publicKey = RSAService.publicKeyFromPem(publicPem);
      final privateKey = RSAService.privateKeyFromPem(privatePem);
      
      expect(publicKey.modulus, equals(keyPair.publicKey.modulus));
      expect(privateKey.modulus, equals(keyPair.privateKey.modulus));
    });

    test('Sign and verify data', () {
      final keyPair = RSAService.generateKeyPair();
      final testData = 'This is a test message';
      
      // Sign data
      final signature = RSAService.sign(testData, keyPair.privateKey);
      expect(signature, isNotEmpty);
      
      // Verify signature
      final isValid = RSAService.verify(testData, signature, keyPair.publicKey);
      expect(isValid, isTrue);
      
      // Verify with wrong data should fail
      final isInvalid = RSAService.verify('Wrong data', signature, keyPair.publicKey);
      expect(isInvalid, isFalse);
    });
  });

  group('Hash Service Tests', () {
    test('Generate SHA-256 hash', () {
      final data = 'Test data';
      final hash = HashService.sha256(data);
      
      expect(hash, isNotEmpty);
      expect(hash.length, equals(64)); // SHA-256 produces 64 hex characters
    });

    test('Same data produces same hash', () {
      final data = 'Consistent data';
      final hash1 = HashService.sha256(data);
      final hash2 = HashService.sha256(data);
      
      expect(hash1, equals(hash2));
    });

    test('Different data produces different hash', () {
      final hash1 = HashService.sha256('Data 1');
      final hash2 = HashService.sha256('Data 2');
      
      expect(hash1, isNot(equals(hash2)));
    });
  });
}
