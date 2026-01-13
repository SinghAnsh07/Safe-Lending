import 'package:cloud_firestore/cloud_firestore.dart';

enum ContractStatus {
  pending,
  active,
  completed,
  overdue,
  cancelled,
}

class ContractModel {
  final String id;
  final String lenderId;
  final String lenderName;
  final String lenderEmail;
  final String borrowerId;
  final String borrowerName;
  final String borrowerEmail;
  final double amount;
  final double interestRate;
  final DateTime dueDate;
  final String contractHash;
  final String? lenderSignature;
  final String? borrowerSignature;
  final ContractStatus status;
  final double amountPaid;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;

  ContractModel({
    required this.id,
    required this.lenderId,
    required this.lenderName,
    required this.lenderEmail,
    required this.borrowerId,
    required this.borrowerName,
    required this.borrowerEmail,
    required this.amount,
    required this.interestRate,
    required this.dueDate,
    required this.contractHash,
    this.lenderSignature,
    this.borrowerSignature,
    required this.status,
    this.amountPaid = 0.0,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
  });

  double get totalAmount => amount + (amount * interestRate / 100);
  double get remainingAmount => totalAmount - amountPaid;
  bool get isFullySigned => lenderSignature != null && borrowerSignature != null;
  bool get isOverdue => DateTime.now().isAfter(dueDate) && status == ContractStatus.active;

  factory ContractModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ContractModel(
      id: doc.id,
      lenderId: data['lenderId'] ?? '',
      lenderName: data['lenderName'] ?? '',
      lenderEmail: data['lenderEmail'] ?? '',
      borrowerId: data['borrowerId'] ?? '',
      borrowerName: data['borrowerName'] ?? '',
      borrowerEmail: data['borrowerEmail'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      interestRate: (data['interestRate'] ?? 0).toDouble(),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      contractHash: data['contractHash'] ?? '',
      lenderSignature: data['lenderSignature'],
      borrowerSignature: data['borrowerSignature'],
      status: ContractStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ContractStatus.pending,
      ),
      amountPaid: (data['amountPaid'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'lenderId': lenderId,
      'lenderName': lenderName,
      'lenderEmail': lenderEmail,
      'borrowerId': borrowerId,
      'borrowerName': borrowerName,
      'borrowerEmail': borrowerEmail,
      'amount': amount,
      'interestRate': interestRate,
      'dueDate': Timestamp.fromDate(dueDate),
      'contractHash': contractHash,
      'lenderSignature': lenderSignature,
      'borrowerSignature': borrowerSignature,
      'status': status.name,
      'amountPaid': amountPaid,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'notes': notes,
    };
  }

  ContractModel copyWith({
    String? id,
    String? lenderId,
    String? lenderName,
    String? lenderEmail,
    String? borrowerId,
    String? borrowerName,
    String? borrowerEmail,
    double? amount,
    double? interestRate,
    DateTime? dueDate,
    String? contractHash,
    String? lenderSignature,
    String? borrowerSignature,
    ContractStatus? status,
    double? amountPaid,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
  }) {
    return ContractModel(
      id: id ?? this.id,
      lenderId: lenderId ?? this.lenderId,
      lenderName: lenderName ?? this.lenderName,
      lenderEmail: lenderEmail ?? this.lenderEmail,
      borrowerId: borrowerId ?? this.borrowerId,
      borrowerName: borrowerName ?? this.borrowerName,
      borrowerEmail: borrowerEmail ?? this.borrowerEmail,
      amount: amount ?? this.amount,
      interestRate: interestRate ?? this.interestRate,
      dueDate: dueDate ?? this.dueDate,
      contractHash: contractHash ?? this.contractHash,
      lenderSignature: lenderSignature ?? this.lenderSignature,
      borrowerSignature: borrowerSignature ?? this.borrowerSignature,
      status: status ?? this.status,
      amountPaid: amountPaid ?? this.amountPaid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
    );
  }
}
