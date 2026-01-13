import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class HashService {
  /// Generate SHA-256 hash of input data
  static String generateHash(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate hash from contract data
  static String generateContractHash({
    required String lenderId,
    required String borrowerId,
    required double amount,
    required double interestRate,
    required DateTime dueDate,
    String? notes,
  }) {
    final contractData = {
      'lenderId': lenderId,
      'borrowerId': borrowerId,
      'amount': amount.toString(),
      'interestRate': interestRate.toString(),
      'dueDate': dueDate.toIso8601String(),
      'notes': notes ?? '',
    };

    final jsonString = json.encode(contractData);
    return generateHash(jsonString);
  }

  /// Verify hash integrity
  static bool verifyHash(String data, String expectedHash) {
    final actualHash = generateHash(data);
    return actualHash == expectedHash;
  }

  /// Generate hash from bytes
  static String hashBytes(Uint8List bytes) {
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate hash for repayment
  static String generateRepaymentHash({
    required String contractId,
    required String payerId,
    required double amount,
    required DateTime paymentDate,
  }) {
    final repaymentData = {
      'contractId': contractId,
      'payerId': payerId,
      'amount': amount.toString(),
      'paymentDate': paymentDate.toIso8601String(),
    };

    final jsonString = json.encode(repaymentData);
    return generateHash(jsonString);
  }
}
