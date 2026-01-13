import 'package:pointycastle/export.dart';
import 'rsa_service.dart';
import 'hash_service.dart';

class SignatureService {
  /// Sign contract hash with private key
  static String signContract({
    required String contractHash,
    required RSAPrivateKey privateKey,
  }) {
    return RSAService.sign(contractHash, privateKey);
  }

  /// Verify contract signature with public key
  static bool verifyContractSignature({
    required String contractHash,
    required String signature,
    required RSAPublicKey publicKey,
  }) {
    return RSAService.verify(contractHash, signature, publicKey);
  }

  /// Sign repayment hash
  static String signRepayment({
    required String repaymentHash,
    required RSAPrivateKey privateKey,
  }) {
    return RSAService.sign(repaymentHash, privateKey);
  }

  /// Verify repayment signature
  static bool verifyRepaymentSignature({
    required String repaymentHash,
    required String signature,
    required RSAPublicKey publicKey,
  }) {
    return RSAService.verify(repaymentHash, signature, publicKey);
  }

  /// Create complete contract signature package
  static Map<String, String> createContractSignaturePackage({
    required String lenderId,
    required String borrowerId,
    required double amount,
    required double interestRate,
    required DateTime dueDate,
    required RSAPrivateKey privateKey,
    String? notes,
  }) {
    // Generate contract hash
    final contractHash = HashService.generateContractHash(
      lenderId: lenderId,
      borrowerId: borrowerId,
      amount: amount,
      interestRate: interestRate,
      dueDate: dueDate,
      notes: notes,
    );

    // Sign the hash
    final signature = signContract(
      contractHash: contractHash,
      privateKey: privateKey,
    );

    return {
      'hash': contractHash,
      'signature': signature,
    };
  }

  /// Verify complete contract signature package
  static bool verifyContractSignaturePackage({
    required String lenderId,
    required String borrowerId,
    required double amount,
    required double interestRate,
    required DateTime dueDate,
    required String expectedHash,
    required String signature,
    required RSAPublicKey publicKey,
    String? notes,
  }) {
    // Regenerate hash
    final actualHash = HashService.generateContractHash(
      lenderId: lenderId,
      borrowerId: borrowerId,
      amount: amount,
      interestRate: interestRate,
      dueDate: dueDate,
      notes: notes,
    );

    // Verify hash matches
    if (actualHash != expectedHash) {
      return false;
    }

    // Verify signature
    return verifyContractSignature(
      contractHash: actualHash,
      signature: signature,
      publicKey: publicKey,
    );
  }
}
