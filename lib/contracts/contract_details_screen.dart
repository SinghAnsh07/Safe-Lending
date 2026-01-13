import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../auth/auth_service.dart';
import '../contracts/contract_service.dart';
import '../services/repayment_service.dart';
import '../models/contract_model.dart';
import '../models/repayment_model.dart';
import '../utils/constants.dart';

class ContractDetailsScreen extends StatefulWidget {
  final String contractId;

  const ContractDetailsScreen({super.key, required this.contractId});

  @override
  State<ContractDetailsScreen> createState() => _ContractDetailsScreenState();
}

class _ContractDetailsScreenState extends State<ContractDetailsScreen> {
  bool _isVerifying = false;
  bool? _isVerified;

  Future<void> _verifyContract(ContractModel contract) async {
    setState(() => _isVerifying = true);

    final contractService = context.read<ContractService>();
    final isValid = await contractService.verifyContractIntegrity(contract);

    setState(() {
      _isVerifying = false;
      _isVerified = isValid;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isValid
              ? '✓ Contract verified successfully'
              : '✗ Contract verification failed',
        ),
        backgroundColor: isValid ? AppColors.success : AppColors.error,
      ),
    );
  }

  Future<void> _signContract(ContractModel contract) async {
    final contractService = context.read<ContractService>();
    final success = await contractService.signContractAsBorrower(widget.contractId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contract signed successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to sign contract'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _makeRepayment(ContractModel contract) async {
    final amountController = TextEditingController();
    final notesController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Make Repayment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount (₹)',
                hintText: 'Max: ₹${contract.remainingAmount.toStringAsFixed(2)}',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Pay'),
          ),
        ],
      ),
    );

    if (result != true) return;

    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid amount'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authService = context.read<AuthService>();
    final repaymentService = context.read<RepaymentService>();

    final success = await repaymentService.makeRepayment(
      contractId: widget.contractId,
      payerId: authService.currentUserModel!.id,
      payerName: authService.currentUserModel!.fullName,
      amount: amount,
      notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Repayment recorded successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to record repayment'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final contractService = context.watch<ContractService>();
    final userId = authService.currentUserModel?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contract Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share
            },
          ),
        ],
      ),
      body: FutureBuilder<ContractModel?>(
        future: contractService.getContract(widget.contractId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Contract not found'));
          }

          final contract = snapshot.data!;
          final isLender = contract.lenderId == userId;
          final isBorrower = contract.borrowerId == userId;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Status Banner
                Container(
                  padding: const EdgeInsets.all(20),
                  color: _getStatusColor(contract.status).withOpacity(0.1),
                  child: Row(
                    children: [
                      Icon(
                        _getStatusIcon(contract.status),
                        color: _getStatusColor(contract.status),
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getStatusText(contract.status),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(contract.status),
                              ),
                            ),
                            Text(
                              _getStatusDescription(contract.status),
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Contract Details
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Amount Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Principal Amount',
                                    style: TextStyle(color: AppColors.textSecondary),
                                  ),
                                  Text(
                                    '₹${contract.amount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Interest (${contract.interestRate}%)',
                                    style: TextStyle(color: AppColors.textSecondary),
                                  ),
                                  Text(
                                    '₹${(contract.amount * contract.interestRate / 100).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Amount',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '₹${contract.totalAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Parties
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Parties',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildPartyRow(
                                'Lender',
                                contract.lenderName,
                                contract.lenderEmail,
                                Icons.arrow_upward,
                                AppColors.success,
                              ),
                              const Divider(height: 24),
                              _buildPartyRow(
                                'Borrower',
                                contract.borrowerName,
                                contract.borrowerEmail,
                                Icons.arrow_downward,
                                AppColors.warning,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Timeline
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Timeline',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildTimelineRow(
                                'Created',
                                DateFormat('dd MMM yyyy, hh:mm a').format(contract.createdAt),
                              ),
                              _buildTimelineRow(
                                'Due Date',
                                DateFormat('dd MMM yyyy').format(contract.dueDate),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Cryptographic Info
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Cryptographic Verification',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (_isVerified != null)
                                    Icon(
                                      _isVerified! ? Icons.verified : Icons.error,
                                      color: _isVerified! ? AppColors.success : AppColors.error,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildHashRow('Contract Hash', contract.contractHash),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    contract.lenderSignature != null
                                        ? Icons.check_circle
                                        : Icons.pending,
                                    size: 16,
                                    color: contract.lenderSignature != null
                                        ? AppColors.success
                                        : AppColors.warning,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Lender Signature',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    contract.borrowerSignature != null
                                        ? Icons.check_circle
                                        : Icons.pending,
                                    size: 16,
                                    color: contract.borrowerSignature != null
                                        ? AppColors.success
                                        : AppColors.warning,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Borrower Signature',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _isVerifying
                                      ? null
                                      : () => _verifyContract(contract),
                                  icon: _isVerifying
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Icon(Icons.verified_user),
                                  label: const Text('Verify Contract'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Repayment History
                      if (contract.status == ContractStatus.active ||
                          contract.status == ContractStatus.completed ||
                          contract.status == ContractStatus.overdue)
                        Column(
                          children: [
                            const SizedBox(height: 16),
                            _RepaymentHistory(contractId: widget.contractId),
                          ],
                        ),

                      // Notes
                      if (contract.notes != null && contract.notes!.isNotEmpty)
                        Column(
                          children: [
                            const SizedBox(height: 16),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Notes',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      contract.notes!,
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                      // Action Buttons
                      const SizedBox(height: 24),
                      if (isBorrower && contract.status == ContractStatus.pending)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () => _signContract(contract),
                            icon: const Icon(Icons.draw),
                            label: const Text('Sign Contract'),
                          ),
                        ),
                      if (isBorrower &&
                          (contract.status == ContractStatus.active ||
                              contract.status == ContractStatus.overdue) &&
                          contract.remainingAmount > 0)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () => _makeRepayment(contract),
                            icon: const Icon(Icons.payment),
                            label: const Text('Make Repayment'),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPartyRow(
    String role,
    String name,
    String email,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                role,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                email,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildHashRow(String label, String hash) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: hash));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Hash copied to clipboard')),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hash,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.copy, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(ContractStatus status) {
    switch (status) {
      case ContractStatus.pending:
        return AppColors.warning;
      case ContractStatus.active:
        return AppColors.info;
      case ContractStatus.completed:
        return AppColors.success;
      case ContractStatus.overdue:
        return AppColors.danger;
      case ContractStatus.cancelled:
        return AppColors.textTertiary;
    }
  }

  IconData _getStatusIcon(ContractStatus status) {
    switch (status) {
      case ContractStatus.pending:
        return Icons.pending;
      case ContractStatus.active:
        return Icons.check_circle;
      case ContractStatus.completed:
        return Icons.done_all;
      case ContractStatus.overdue:
        return Icons.warning;
      case ContractStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusText(ContractStatus status) {
    switch (status) {
      case ContractStatus.pending:
        return 'Pending Signature';
      case ContractStatus.active:
        return 'Active Contract';
      case ContractStatus.completed:
        return 'Completed';
      case ContractStatus.overdue:
        return 'Overdue';
      case ContractStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _getStatusDescription(ContractStatus status) {
    switch (status) {
      case ContractStatus.pending:
        return 'Waiting for borrower signature';
      case ContractStatus.active:
        return 'Contract is currently active';
      case ContractStatus.completed:
        return 'All payments completed';
      case ContractStatus.overdue:
        return 'Payment is overdue';
      case ContractStatus.cancelled:
        return 'Contract was cancelled';
    }
  }
}

class _RepaymentHistory extends StatelessWidget {
  final String contractId;

  const _RepaymentHistory({required this.contractId});

  @override
  Widget build(BuildContext context) {
    final repaymentService = context.watch<RepaymentService>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Repayment History',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<RepaymentModel>>(
              stream: repaymentService.getContractRepayments(contractId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text(
                    'No repayments yet',
                    style: TextStyle(color: AppColors.textSecondary),
                  );
                }

                final repayments = snapshot.data!;

                return Column(
                  children: repayments.map((repayment) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.payment,
                            color: AppColors.success,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '₹${repayment.amount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  DateFormat('dd MMM yyyy, hh:mm a')
                                      .format(repayment.paymentDate),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
