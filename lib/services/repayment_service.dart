import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/repayment_model.dart';
import '../models/contract_model.dart';
import '../crypto/hash_service.dart';

class RepaymentService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Make a repayment
  Future<bool> makeRepayment({
    required String contractId,
    required String payerId,
    required String payerName,
    required double amount,
    String? notes,
  }) async {
    try {
      // Get contract
      final contractDoc = await _firestore
          .collection('contracts')
          .doc(contractId)
          .get();

      if (!contractDoc.exists) {
        return false;
      }

      final contract = ContractModel.fromFirestore(contractDoc);

      // Validate amount
      if (amount <= 0 || amount > contract.remainingAmount) {
        return false;
      }

      // Generate repayment hash
      final paymentDate = DateTime.now();
      final transactionHash = HashService.generateRepaymentHash(
        contractId: contractId,
        payerId: payerId,
        amount: amount,
        paymentDate: paymentDate,
      );

      // Create repayment record
      final repayment = RepaymentModel(
        id: '',
        contractId: contractId,
        payerId: payerId,
        payerName: payerName,
        amount: amount,
        paymentDate: paymentDate,
        transactionHash: transactionHash,
        notes: notes,
        createdAt: DateTime.now(),
      );

      // Save repayment
      await _firestore
          .collection('repayments')
          .add(repayment.toFirestore());

      // Update contract
      final newAmountPaid = contract.amountPaid + amount;
      final isFullyPaid = newAmountPaid >= contract.totalAmount;

      await _firestore.collection('contracts').doc(contractId).update({
        'amountPaid': newAmountPaid,
        'status': isFullyPaid
            ? ContractStatus.completed.name
            : contract.status.name,
        'updatedAt': Timestamp.now(),
      });

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error making repayment: $e');
      return false;
    }
  }

  /// Get repayments for a contract
  Stream<List<RepaymentModel>> getContractRepayments(String contractId) {
    return _firestore
        .collection('repayments')
        .where('contractId', isEqualTo: contractId)
        .orderBy('paymentDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RepaymentModel.fromFirestore(doc))
            .toList());
  }

  /// Get all repayments made by a user
  Stream<List<RepaymentModel>> getUserRepayments(String userId) {
    return _firestore
        .collection('repayments')
        .where('payerId', isEqualTo: userId)
        .orderBy('paymentDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RepaymentModel.fromFirestore(doc))
            .toList());
  }

  /// Get total repayments for a contract
  Future<double> getTotalRepayments(String contractId) async {
    try {
      final snapshot = await _firestore
          .collection('repayments')
          .where('contractId', isEqualTo: contractId)
          .get();

      double total = 0;
      for (final doc in snapshot.docs) {
        final repayment = RepaymentModel.fromFirestore(doc);
        total += repayment.amount;
      }

      return total;
    } catch (e) {
      debugPrint('Error getting total repayments: $e');
      return 0;
    }
  }

  /// Verify repayment integrity
  Future<bool> verifyRepaymentIntegrity(RepaymentModel repayment) async {
    try {
      // Regenerate hash
      final expectedHash = HashService.generateRepaymentHash(
        contractId: repayment.contractId,
        payerId: repayment.payerId,
        amount: repayment.amount,
        paymentDate: repayment.paymentDate,
      );

      return expectedHash == repayment.transactionHash;
    } catch (e) {
      debugPrint('Error verifying repayment: $e');
      return false;
    }
  }

  /// Get repayment statistics for a user
  Future<Map<String, dynamic>> getRepaymentStats(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('repayments')
          .where('payerId', isEqualTo: userId)
          .get();

      double totalPaid = 0;
      int paymentCount = 0;

      for (final doc in snapshot.docs) {
        final repayment = RepaymentModel.fromFirestore(doc);
        totalPaid += repayment.amount;
        paymentCount++;
      }

      return {
        'totalPaid': totalPaid,
        'paymentCount': paymentCount,
        'averagePayment': paymentCount > 0 ? totalPaid / paymentCount : 0,
      };
    } catch (e) {
      debugPrint('Error getting repayment stats: $e');
      return {
        'totalPaid': 0.0,
        'paymentCount': 0,
        'averagePayment': 0.0,
      };
    }
  }
}
