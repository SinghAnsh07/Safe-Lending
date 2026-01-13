import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../auth/auth_service.dart';
import '../contracts/contract_service.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

class CreateContractScreen extends StatefulWidget {
  const CreateContractScreen({super.key});

  @override
  State<CreateContractScreen> createState() => _CreateContractScreenState();
}

class _CreateContractScreenState extends State<CreateContractScreen> {
  final _formKey = GlobalKey<FormState>();
  final _borrowerEmailController = TextEditingController();
  final _amountController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDueDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _borrowerEmailController.dispose();
    _amountController.dispose();
    _interestRateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  Future<void> _handleCreateContract() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a due date'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authService = context.read<AuthService>();
    final contractService = context.read<ContractService>();

    // Get borrower by email
    final borrower = await authService.getUserByEmail(
      _borrowerEmailController.text.trim(),
    );

    if (borrower == null) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Borrower not found with this email'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (borrower.id == authService.currentUserModel!.id) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot create a contract with yourself'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Create contract
    final contractId = await contractService.createContract(
      lender: authService.currentUserModel!,
      borrower: borrower,
      amount: double.parse(_amountController.text),
      interestRate: double.parse(_interestRateController.text),
      dueDate: _selectedDueDate!,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (contractId != null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contract created successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create contract'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Contract'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.info.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This contract will be cryptographically signed by both parties',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Borrower Email
              TextFormField(
                controller: _borrowerEmailController,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
                decoration: const InputDecoration(
                  labelText: 'Borrower Email',
                  prefixIcon: Icon(Icons.person_outline),
                  hintText: 'Enter borrower\'s email',
                ),
              ),
              const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                validator: Validators.validateAmount,
                decoration: const InputDecoration(
                  labelText: 'Loan Amount (₹)',
                  prefixIcon: Icon(Icons.currency_rupee),
                  hintText: 'Enter amount',
                ),
              ),
              const SizedBox(height: 16),

              // Interest Rate
              TextFormField(
                controller: _interestRateController,
                keyboardType: TextInputType.number,
                validator: Validators.validateInterestRate,
                decoration: const InputDecoration(
                  labelText: 'Interest Rate (%)',
                  prefixIcon: Icon(Icons.percent),
                  hintText: 'Enter interest rate',
                ),
              ),
              const SizedBox(height: 16),

              // Due Date
              InkWell(
                onTap: _selectDueDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Due Date',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDueDate == null
                        ? 'Select due date'
                        : DateFormat('dd MMM yyyy').format(_selectedDueDate!),
                    style: TextStyle(
                      color: _selectedDueDate == null
                          ? AppColors.textTertiary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  prefixIcon: Icon(Icons.note_outlined),
                  hintText: 'Add any additional notes',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),

              // Summary Card
              if (_amountController.text.isNotEmpty &&
                  _interestRateController.text.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Contract Summary',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryRow(
                        'Principal Amount',
                        '₹${_amountController.text}',
                      ),
                      _buildSummaryRow(
                        'Interest',
                        '₹${_calculateInterest()}',
                      ),
                      const Divider(height: 16),
                      _buildSummaryRow(
                        'Total Amount',
                        '₹${_calculateTotal()}',
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Create Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleCreateContract,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Create Contract',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _calculateInterest() {
    try {
      final amount = double.parse(_amountController.text);
      final rate = double.parse(_interestRateController.text);
      final interest = amount * rate / 100;
      return interest.toStringAsFixed(2);
    } catch (e) {
      return '0.00';
    }
  }

  String _calculateTotal() {
    try {
      final amount = double.parse(_amountController.text);
      final rate = double.parse(_interestRateController.text);
      final total = amount + (amount * rate / 100);
      return total.toStringAsFixed(2);
    } catch (e) {
      return '0.00';
    }
  }
}
