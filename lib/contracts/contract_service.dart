import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/contract_model.dart';
import '../models/user_model.dart';
import '../crypto/hash_service.dart';
import '../crypto/signature_service.dart';
import '../crypto/rsa_service.dart';
import '../services/storage_service.dart';

class ContractService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a new contract
  Future<String?> createContract({
    required UserModel lender,
    required UserModel borrower,
    required double amount,
    required double interestRate,
    required DateTime dueDate,
    String? notes,
  }) async {
    try {
      // Generate contract hash
      final contractHash = HashService.generateContractHash(
        lenderId: lender.id,
        borrowerId: borrower.id,
        amount: amount,
        interestRate: interestRate,
        dueDate: dueDate,
        notes: notes,
      );

      // Get lender's private key to sign
      final privateKeyPem = await StorageService.getPrivateKey();
      if (privateKeyPem == null) {
        return 'Private key not found';
      }

      final privateKey = RSAService.privateKeyFromPem(privateKeyPem);
      final lenderSignature = SignatureService.signContract(
        contractHash: contractHash,
        privateKey: privateKey,
      );

      // Create contract
      final contract = ContractModel(
        id: '',
        lenderId: lender.id,
        lenderName: lender.fullName,
        lenderEmail: lender.email,
        borrowerId: borrower.id,
        borrowerName: borrower.fullName,
        borrowerEmail: borrower.email,
        amount: amount,
        interestRate: interestRate,
        dueDate: dueDate,
        contractHash: contractHash,
        lenderSignature: lenderSignature,
        status: ContractStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        notes: notes,
      );

      // Save to Firestore
      final docRef =
          await _firestore.collection('contracts').add(contract.toFirestore());

      notifyListeners();
      return docRef.id; // Return contract ID
    } catch (e) {
      debugPrint('Error creating contract: $e');
      return null;
    }
  }

  /// Sign contract as borrower
  Future<bool> signContractAsBorrower(String contractId) async {
    try {
      // Get contract
      final doc =
          await _firestore.collection('contracts').doc(contractId).get();
      if (!doc.exists) {
        return false;
      }

      final contract = ContractModel.fromFirestore(doc);

      // Get borrower's private key
      final privateKeyPem = await StorageService.getPrivateKey();
      if (privateKeyPem == null) {
        return false;
      }

      final privateKey = RSAService.privateKeyFromPem(privateKeyPem);
      final borrowerSignature = SignatureService.signContract(
        contractHash: contract.contractHash,
        privateKey: privateKey,
      );

      // Update contract with borrower signature
      await _firestore.collection('contracts').doc(contractId).update({
        'borrowerSignature': borrowerSignature,
        'status': ContractStatus.active.name,
        'updatedAt': Timestamp.now(),
      });

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error signing contract: $e');
      return false;
    }
  }

  /// Get contracts where user is lender
  Stream<List<ContractModel>> getLenderContracts(String userId) {
    return _firestore
        .collection('contracts')
        .where('lenderId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ContractModel.fromFirestore(doc))
            .toList());
  }

  /// Get contracts where user is borrower
  Stream<List<ContractModel>> getBorrowerContracts(String userId) {
    return _firestore
        .collection('contracts')
        .where('borrowerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ContractModel.fromFirestore(doc))
            .toList());
  }

  /// Get all contracts for user (lender or borrower)
  Stream<List<ContractModel>> getAllUserContracts(String userId) {
    return _firestore
        .collection('contracts')
        .where('lenderId', isEqualTo: userId)
        .snapshots()
        .asyncMap((lenderSnapshot) async {
      final borrowerSnapshot = await _firestore
          .collection('contracts')
          .where('borrowerId', isEqualTo: userId)
          .get();

      final allDocs = [...lenderSnapshot.docs, ...borrowerSnapshot.docs];
      final contracts =
          allDocs.map((doc) => ContractModel.fromFirestore(doc)).toList();

      // Sort by creation date
      contracts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return contracts;
    });
  }

  /// Get single contract
  Future<ContractModel?> getContract(String contractId) async {
    try {
      final doc =
          await _firestore.collection('contracts').doc(contractId).get();
      if (doc.exists) {
        return ContractModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting contract: $e');
      return null;
    }
  }

  /// Verify contract integrity
  Future<bool> verifyContractIntegrity(ContractModel contract) async {
    try {
      // Regenerate hash
      final expectedHash = HashService.generateContractHash(
        lenderId: contract.lenderId,
        borrowerId: contract.borrowerId,
        amount: contract.amount,
        interestRate: contract.interestRate,
        dueDate: contract.dueDate,
        notes: contract.notes,
      );

      // Check if hash matches
      if (expectedHash != contract.contractHash) {
        return false;
      }

      // Get lender's public key
      final lenderDoc =
          await _firestore.collection('users').doc(contract.lenderId).get();
      if (!lenderDoc.exists) {
        return false;
      }

      final lenderPublicKeyPem = lenderDoc.data()!['publicKey'] as String;
      final lenderPublicKey = RSAService.publicKeyFromPem(lenderPublicKeyPem);

      // Verify lender signature
      if (contract.lenderSignature != null) {
        final lenderSigValid = SignatureService.verifyContractSignature(
          contractHash: contract.contractHash,
          signature: contract.lenderSignature!,
          publicKey: lenderPublicKey,
        );
        if (!lenderSigValid) {
          return false;
        }
      }

      // Verify borrower signature if exists
      if (contract.borrowerSignature != null) {
        final borrowerDoc =
            await _firestore.collection('users').doc(contract.borrowerId).get();
        if (!borrowerDoc.exists) {
          return false;
        }

        final borrowerPublicKeyPem = borrowerDoc.data()!['publicKey'] as String;
        final borrowerPublicKey =
            RSAService.publicKeyFromPem(borrowerPublicKeyPem);

        final borrowerSigValid = SignatureService.verifyContractSignature(
          contractHash: contract.contractHash,
          signature: contract.borrowerSignature!,
          publicKey: borrowerPublicKey,
        );
        if (!borrowerSigValid) {
          return false;
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error verifying contract: $e');
      return false;
    }
  }

  /// Cancel contract (only if pending)
  Future<bool> cancelContract(String contractId) async {
    try {
      final doc =
          await _firestore.collection('contracts').doc(contractId).get();
      if (!doc.exists) {
        return false;
      }

      final contract = ContractModel.fromFirestore(doc);
      if (contract.status != ContractStatus.pending) {
        return false;
      }

      await _firestore.collection('contracts').doc(contractId).update({
        'status': ContractStatus.cancelled.name,
        'updatedAt': Timestamp.now(),
      });

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error cancelling contract: $e');
      return false;
    }
  }

  /// Update contract status to overdue if past due date
  Future<void> updateOverdueContracts() async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection('contracts')
          .where('status', isEqualTo: ContractStatus.active.name)
          .get();

      for (final doc in snapshot.docs) {
        final contract = ContractModel.fromFirestore(doc);
        if (contract.dueDate.isBefore(now)) {
          await _firestore.collection('contracts').doc(doc.id).update({
            'status': ContractStatus.overdue.name,
            'updatedAt': Timestamp.now(),
          });
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error updating overdue contracts: $e');
    }
  }
}
