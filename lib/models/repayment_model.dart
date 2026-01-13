import 'package:cloud_firestore/cloud_firestore.dart';

class RepaymentModel {
  final String id;
  final String contractId;
  final String payerId;
  final String payerName;
  final double amount;
  final DateTime paymentDate;
  final String transactionHash;
  final String? notes;
  final DateTime createdAt;

  RepaymentModel({
    required this.id,
    required this.contractId,
    required this.payerId,
    required this.payerName,
    required this.amount,
    required this.paymentDate,
    required this.transactionHash,
    this.notes,
    required this.createdAt,
  });

  factory RepaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RepaymentModel(
      id: doc.id,
      contractId: data['contractId'] ?? '',
      payerId: data['payerId'] ?? '',
      payerName: data['payerName'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      paymentDate: (data['paymentDate'] as Timestamp).toDate(),
      transactionHash: data['transactionHash'] ?? '',
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'contractId': contractId,
      'payerId': payerId,
      'payerName': payerName,
      'amount': amount,
      'paymentDate': Timestamp.fromDate(paymentDate),
      'transactionHash': transactionHash,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
