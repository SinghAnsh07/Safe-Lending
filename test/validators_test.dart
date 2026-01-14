import 'package:flutter_test/flutter_test.dart';
import 'package:tpln/utils/validators.dart';

void main() {
  group('Validators Tests', () {
    group('Email Validation', () {
      test('Valid email addresses', () {
        expect(Validators.validateEmail('test@example.com'), isNull);
        expect(Validators.validateEmail('user.name@domain.co.uk'), isNull);
        expect(Validators.validateEmail('user+tag@example.com'), isNull);
      });

      test('Invalid email addresses', () {
        expect(Validators.validateEmail(''), isNotNull);
        expect(Validators.validateEmail('invalid'), isNotNull);
        expect(Validators.validateEmail('@example.com'), isNotNull);
        expect(Validators.validateEmail('user@'), isNotNull);
        expect(Validators.validateEmail('user @example.com'), isNotNull);
      });
    });

    group('Password Validation', () {
      test('Valid passwords', () {
        expect(Validators.validatePassword('Password123'), isNull);
        expect(Validators.validatePassword('SecureP@ss1'), isNull);
        expect(Validators.validatePassword('12345678'), isNull);
      });

      test('Invalid passwords', () {
        expect(Validators.validatePassword(''), isNotNull);
        expect(Validators.validatePassword('short'), isNotNull);
        expect(Validators.validatePassword('1234567'), isNotNull);
      });
    });

    group('Phone Number Validation', () {
      test('Valid phone numbers', () {
        expect(Validators.validatePhone('+1234567890'), isNull);
        expect(Validators.validatePhone('1234567890'), isNull);
        expect(Validators.validatePhone('+91 9876543210'), isNull);
      });

      test('Invalid phone numbers', () {
        expect(Validators.validatePhone(''), isNotNull);
        expect(Validators.validatePhone('123'), isNotNull);
        expect(Validators.validatePhone('abcdefghij'), isNotNull);
      });
    });

    group('Amount Validation', () {
      test('Valid amounts', () {
        expect(Validators.validateAmount('1000'), isNull);
        expect(Validators.validateAmount('100.50'), isNull);
        expect(Validators.validateAmount('9999999'), isNull);
      });

      test('Invalid amounts', () {
        expect(Validators.validateAmount(''), isNotNull);
        expect(Validators.validateAmount('0'), isNotNull);
        expect(Validators.validateAmount('-100'), isNotNull);
        expect(Validators.validateAmount('abc'), isNotNull);
        expect(Validators.validateAmount('99'), isNotNull); // Below minimum
      });
    });

    group('Interest Rate Validation', () {
      test('Valid interest rates', () {
        expect(Validators.validateInterestRate('0'), isNull);
        expect(Validators.validateInterestRate('5.5'), isNull);
        expect(Validators.validateInterestRate('36'), isNull);
      });

      test('Invalid interest rates', () {
        expect(Validators.validateInterestRate(''), isNotNull);
        expect(Validators.validateInterestRate('-5'), isNotNull);
        expect(Validators.validateInterestRate('37'), isNotNull); // Above maximum
        expect(Validators.validateInterestRate('abc'), isNotNull);
      });
    });

    group('Required Field Validation', () {
      test('Valid required fields', () {
        expect(Validators.validateRequired('Some text', 'Field'), isNull);
        expect(Validators.validateRequired('123', 'Field'), isNull);
      });

      test('Invalid required fields', () {
        expect(Validators.validateRequired('', 'Field'), isNotNull);
        expect(Validators.validateRequired('   ', 'Field'), isNotNull);
        expect(Validators.validateRequired(null, 'Field'), isNotNull);
      });
    });
  });
}
