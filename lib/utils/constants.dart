import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);
  
  // Accent Colors
  static const Color accent = Color(0xFF10B981); // Green
  static const Color accentDark = Color(0xFF059669);
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color danger = Color(0xFFEF4444); // Red
  
  // Neutral Colors
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E7EB);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
}

class AppStrings {
  // App
  static const String appName = 'TPLN';
  static const String appFullName = 'Trustless Peer-to-Peer Lending Network';
  static const String tagline = 'Cryptographically Secure Lending';
  
  // Auth
  static const String login = 'Login';
  static const String register = 'Register';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String phoneNumber = 'Phone Number';
  static const String forgotPassword = 'Forgot Password?';
  static const String dontHaveAccount = "Don't have an account?";
  static const String alreadyHaveAccount = 'Already have an account?';
  
  // Contracts
  static const String createContract = 'Create Contract';
  static const String myContracts = 'My Contracts';
  static const String contractDetails = 'Contract Details';
  static const String loanAmount = 'Loan Amount';
  static const String interestRate = 'Interest Rate (%)';
  static const String dueDate = 'Due Date';
  static const String borrowerEmail = 'Borrower Email';
  static const String lenderEmail = 'Lender Email';
  static const String signContract = 'Sign Contract';
  static const String viewContract = 'View Contract';
  
  // Repayments
  static const String makeRepayment = 'Make Repayment';
  static const String repaymentHistory = 'Repayment History';
  static const String amountPaid = 'Amount Paid';
  static const String remainingAmount = 'Remaining Amount';
  
  // Status
  static const String pending = 'Pending';
  static const String active = 'Active';
  static const String completed = 'Completed';
  static const String overdue = 'Overdue';
  static const String cancelled = 'Cancelled';
}

class AppConstants {
  // Crypto
  static const int rsaKeySize = 2048;
  static const int aesKeySize = 256;
  static const String hashAlgorithm = 'SHA-256';
  
  // Storage Keys
  static const String privateKeyKey = 'private_key';
  static const String publicKeyKey = 'public_key';
  static const String userIdKey = 'user_id';
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxLoanAmount = 10000000; // 1 Crore
  static const int minLoanAmount = 100;
  static const double maxInterestRate = 36.0;
  static const double minInterestRate = 0.0;
  
  // Date Format
  static const String dateFormat = 'dd MMM yyyy';
  static const String dateTimeFormat = 'dd MMM yyyy, hh:mm a';
}

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String createContract = '/create-contract';
  static const String contractDetails = '/contract-details';
  static const String profile = '/profile';
  static const String repayment = '/repayment';
}
