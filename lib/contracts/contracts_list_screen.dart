import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_service.dart';
import '../contracts/contract_service.dart';
import '../contracts/contract_details_screen.dart';
import '../models/contract_model.dart';
import '../utils/constants.dart';
import 'package:intl/intl.dart';

class ContractsListScreen extends StatefulWidget {
  const ContractsListScreen({super.key});

  @override
  State<ContractsListScreen> createState() => _ContractsListScreenState();
}

class _ContractsListScreenState extends State<ContractsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final contractService = context.watch<ContractService>();
    final userId = authService.currentUserModel?.id ?? '';

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Lending'),
            Tab(text: 'Borrowing'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // All Contracts
              StreamBuilder<List<ContractModel>>(
                stream: contractService.getAllUserContracts(userId),
                builder: (context, snapshot) {
                  return _buildContractList(snapshot, userId);
                },
              ),
              // Lending Contracts
              StreamBuilder<List<ContractModel>>(
                stream: contractService.getLenderContracts(userId),
                builder: (context, snapshot) {
                  return _buildContractList(snapshot, userId);
                },
              ),
              // Borrowing Contracts
              StreamBuilder<List<ContractModel>>(
                stream: contractService.getBorrowerContracts(userId),
                builder: (context, snapshot) {
                  return _buildContractList(snapshot, userId);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContractList(
    AsyncSnapshot<List<ContractModel>> snapshot,
    String userId,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Error loading contracts',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 80,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No contracts found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a new contract to get started',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    final contracts = snapshot.data!;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: contracts.length,
      itemBuilder: (context, index) {
        final contract = contracts[index];
        return _ContractListItem(
          contract: contract,
          userId: userId,
        );
      },
    );
  }
}

class _ContractListItem extends StatelessWidget {
  final ContractModel contract;
  final String userId;

  const _ContractListItem({
    required this.contract,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final isLender = contract.lenderId == userId;
    final otherParty = isLender ? contract.borrowerName : contract.lenderName;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ContractDetailsScreen(contractId: contract.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Direction Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isLender ? AppColors.success : AppColors.warning)
                          .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isLender ? Icons.arrow_upward : Icons.arrow_downward,
                      color: isLender ? AppColors.success : AppColors.warning,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Amount and Party
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '₹${contract.amount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${isLender ? 'To' : 'From'} $otherParty',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(contract.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(contract.status),
                      style: TextStyle(
                        color: _getStatusColor(contract.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Details Row
              Row(
                children: [
                  _buildDetailChip(
                    Icons.percent,
                    '${contract.interestRate}% interest',
                  ),
                  const SizedBox(width: 8),
                  _buildDetailChip(
                    Icons.calendar_today,
                    'Due ${DateFormat('dd MMM').format(contract.dueDate)}',
                  ),
                ],
              ),

              // Progress Bar (for active contracts)
              if (contract.status == ContractStatus.active ||
                  contract.status == ContractStatus.overdue)
                Column(
                  children: [
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: contract.amountPaid / contract.totalAmount,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          contract.status == ContractStatus.overdue
                              ? AppColors.danger
                              : AppColors.success,
                        ),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${contract.amountPaid.toStringAsFixed(0)} paid',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        Text(
                          '₹${contract.remainingAmount.toStringAsFixed(0)} remaining',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textTertiary),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
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

  String _getStatusText(ContractStatus status) {
    switch (status) {
      case ContractStatus.pending:
        return 'Pending';
      case ContractStatus.active:
        return 'Active';
      case ContractStatus.completed:
        return 'Completed';
      case ContractStatus.overdue:
        return 'Overdue';
      case ContractStatus.cancelled:
        return 'Cancelled';
    }
  }
}
