import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';

class RSAService {
  /// Generate RSA key pair (2048-bit)
  static AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateKeyPair() {
    final keyGen = RSAKeyGenerator()
      ..init(
        ParametersWithRandom(
          RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64),
          _getSecureRandom(),
        ),
      );

    final pair = keyGen.generateKeyPair();
    return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(
      pair.publicKey as RSAPublicKey,
      pair.privateKey as RSAPrivateKey,
    );
  }

  /// Convert public key to PEM format string
  static String publicKeyToPem(RSAPublicKey publicKey) {
    final modulus = publicKey.modulus!;
    final exponent = publicKey.exponent!;
    
    final modulusBytes = _encodeBigInt(modulus);
    final exponentBytes = _encodeBigInt(exponent);
    
    final keyData = {
      'modulus': base64Encode(modulusBytes),
      'exponent': base64Encode(exponentBytes),
    };
    
    return base64Encode(utf8.encode(json.encode(keyData)));
  }

  /// Convert private key to PEM format string
  static String privateKeyToPem(RSAPrivateKey privateKey) {
    final modulus = privateKey.modulus!;
    final exponent = privateKey.exponent!;
    final p = privateKey.p!;
    final q = privateKey.q!;
    
    final keyData = {
      'modulus': base64Encode(_encodeBigInt(modulus)),
      'exponent': base64Encode(_encodeBigInt(exponent)),
      'p': base64Encode(_encodeBigInt(p)),
      'q': base64Encode(_encodeBigInt(q)),
    };
    
    return base64Encode(utf8.encode(json.encode(keyData)));
  }

  /// Parse public key from PEM format
  static RSAPublicKey publicKeyFromPem(String pem) {
    final jsonString = utf8.decode(base64Decode(pem));
    final keyData = json.decode(jsonString) as Map<String, dynamic>;
    
    final modulus = _decodeBigInt(base64Decode(keyData['modulus']));
    final exponent = _decodeBigInt(base64Decode(keyData['exponent']));
    
    return RSAPublicKey(modulus, exponent);
  }

  /// Parse private key from PEM format
  static RSAPrivateKey privateKeyFromPem(String pem) {
    final jsonString = utf8.decode(base64Decode(pem));
    final keyData = json.decode(jsonString) as Map<String, dynamic>;
    
    final modulus = _decodeBigInt(base64Decode(keyData['modulus']));
    final exponent = _decodeBigInt(base64Decode(keyData['exponent']));
    final p = _decodeBigInt(base64Decode(keyData['p']));
    final q = _decodeBigInt(base64Decode(keyData['q']));
    
    return RSAPrivateKey(modulus, exponent, p, q);
  }

  /// Sign data with private key
  static String sign(String data, RSAPrivateKey privateKey) {
    final signer = RSASigner(SHA256Digest(), '0609608648016503040201');
    signer.init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey));
    
    final dataBytes = utf8.encode(data);
    final signature = signer.generateSignature(Uint8List.fromList(dataBytes));
    
    return base64Encode(signature.bytes);
  }

  /// Verify signature with public key
  static bool verify(String data, String signature, RSAPublicKey publicKey) {
    try {
      final signer = RSASigner(SHA256Digest(), '0609608648016503040201');
      signer.init(false, PublicKeyParameter<RSAPublicKey>(publicKey));
      
      final dataBytes = utf8.encode(data);
      final signatureBytes = base64Decode(signature);
      
      return signer.verifySignature(
        Uint8List.fromList(dataBytes),
        RSASignature(signatureBytes),
      );
    } catch (e) {
      return false;
    }
  }

  /// Get secure random number generator
  static SecureRandom _getSecureRandom() {
    final secureRandom = FortunaRandom();
    final random = Random.secure();
    final seeds = List<int>.generate(32, (_) => random.nextInt(256));
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
    return secureRandom;
  }

  /// Encode BigInt to bytes
  static Uint8List _encodeBigInt(BigInt number) {
    final bytes = <int>[];
    var value = number;
    while (value > BigInt.zero) {
      bytes.insert(0, (value & BigInt.from(0xff)).toInt());
      value = value >> 8;
    }
    return Uint8List.fromList(bytes.isEmpty ? [0] : bytes);
  }

  /// Decode bytes to BigInt
  static BigInt _decodeBigInt(List<int> bytes) {
    var result = BigInt.zero;
    for (var byte in bytes) {
      result = (result << 8) | BigInt.from(byte);
    }
    return result;
  }
}
