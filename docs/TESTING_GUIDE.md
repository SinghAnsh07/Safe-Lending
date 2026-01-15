# 🧪 Testing Guide for TPLN

This guide covers all testing aspects of the Safe-Lending (TPLN) application.

---

## 📋 Table of Contents

1. [Unit Tests](#unit-tests)
2. [Widget Tests](#widget-tests)
3. [Integration Tests](#integration-tests)
4. [Manual Testing](#manual-testing)
5. [Security Testing](#security-testing)
6. [Performance Testing](#performance-testing)

---

## 🔬 Unit Tests

Unit tests verify individual functions and classes work correctly.

### Running Unit Tests

```powershell
# Run all tests
flutter test

# Run specific test file
flutter test test/crypto_test.dart

# Run with coverage
flutter test --coverage

# View coverage report
# Install: dart pub global activate coverage
# Generate: genhtml coverage/lcov.info -o coverage/html
# Open: coverage/html/index.html
```

### Available Unit Tests

#### ✅ Crypto Tests (`test/crypto_test.dart`)
- RSA key pair generation
- Key serialization (PEM format)
- Digital signature creation and verification
- SHA-256 hashing

#### ✅ Validator Tests (`test/validators_test.dart`)
- Email validation
- Password validation
- Phone number validation
- Amount validation
- Interest rate validation
- Required field validation

### Writing New Unit Tests

Create a new file in `test/` directory:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:tpln/your_module.dart';

void main() {
  group('Your Module Tests', () {
    test('Test description', () {
      // Arrange
      final input = 'test data';
      
      // Act
      final result = yourFunction(input);
      
      // Assert
      expect(result, equals('expected output'));
    });
  });
}
```

---

## 🎨 Widget Tests

Widget tests verify UI components render and behave correctly.

### Example Widget Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:tpln/auth/login_screen.dart';

void main() {
  testWidgets('Login screen displays correctly', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(home: LoginScreen()),
    );

    // Verify elements are present
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Login'), findsOneWidget);
  });
}
```

---

## 🔗 Integration Tests

Integration tests verify the entire app flow works correctly.

### Setup Integration Tests

1. Create `integration_test/` directory
2. Add to `pubspec.yaml`:
   ```yaml
   dev_dependencies:
     integration_test:
       sdk: flutter
   ```

### Example Integration Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tpln/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete user registration flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Navigate to register
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    // Fill form
    await tester.enterText(find.byKey(Key('fullName')), 'Test User');
    await tester.enterText(find.byKey(Key('email')), 'test@example.com');
    await tester.enterText(find.byKey(Key('phone')), '+1234567890');
    await tester.enterText(find.byKey(Key('password')), 'Test@123456');

    // Submit
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    // Verify success
    expect(find.text('Home'), findsOneWidget);
  });
}
```

### Running Integration Tests

```powershell
flutter test integration_test/
```

---

## 🖱️ Manual Testing

### Test Scenarios

#### 1. User Registration Flow
**Steps:**
1. Open app
2. Click "Register"
3. Fill in all fields:
   - Full Name: John Doe
   - Email: john@example.com
   - Phone: +1234567890
   - Password: SecurePass123
4. Click "Register"

**Expected:**
- ✅ User is created in Firebase
- ✅ RSA keys are generated
- ✅ User is logged in automatically
- ✅ Home screen is displayed

**Edge Cases:**
- [ ] Empty fields show validation errors
- [ ] Invalid email shows error
- [ ] Weak password shows error
- [ ] Duplicate email shows error

---

#### 2. User Login Flow
**Steps:**
1. Open app
2. Enter email and password
3. Click "Login"

**Expected:**
- ✅ User is authenticated
- ✅ Keys are loaded from secure storage
- ✅ Home screen is displayed

**Edge Cases:**
- [ ] Wrong password shows error
- [ ] Non-existent email shows error
- [ ] Missing keys shows error

---

#### 3. Create Contract Flow
**Steps:**
1. Login as lender
2. Click "Create Contract"
3. Fill in:
   - Borrower Email: borrower@example.com
   - Amount: 10000
   - Interest Rate: 5
   - Due Date: (select future date)
   - Notes: Test contract
4. Click "Create Contract"

**Expected:**
- ✅ Contract is created in Firestore
- ✅ Contract hash is generated
- ✅ Lender signature is created
- ✅ Contract appears in list

**Edge Cases:**
- [ ] Invalid borrower email shows error
- [ ] Amount below minimum shows error
- [ ] Interest rate above maximum shows error
- [ ] Past due date shows error

---

#### 4. Sign Contract Flow
**Steps:**
1. Login as borrower
2. View pending contract
3. Click "Sign Contract"
4. Confirm signature

**Expected:**
- ✅ Borrower signature is added
- ✅ Contract status changes to "Active"
- ✅ Both parties can view signed contract

---

#### 5. Make Repayment Flow
**Steps:**
1. Login as borrower
2. View active contract
3. Click "Make Repayment"
4. Enter amount
5. Confirm payment

**Expected:**
- ✅ Repayment is recorded
- ✅ Amount paid is updated
- ✅ Remaining amount is calculated
- ✅ Contract status updates if fully paid

---

### Testing Checklist

#### Authentication
- [ ] User can register with valid data
- [ ] User can login with correct credentials
- [ ] User cannot login with wrong password
- [ ] User can logout
- [ ] Keys are generated on registration
- [ ] Keys are stored securely

#### Contracts
- [ ] Lender can create contract
- [ ] Borrower receives contract notification
- [ ] Borrower can sign contract
- [ ] Contract hash is verified
- [ ] Signatures are verified
- [ ] Contract list shows correct status

#### Repayments
- [ ] Borrower can make repayment
- [ ] Amount paid is tracked correctly
- [ ] Remaining amount is calculated
- [ ] Contract completes when fully paid

#### Security
- [ ] Private keys never leave device
- [ ] Signatures are cryptographically valid
- [ ] Contract data cannot be tampered
- [ ] Only authorized users can access contracts

---

## 🔒 Security Testing

### Cryptography Verification

```powershell
# Run crypto tests
flutter test test/crypto_test.dart -v
```

**Verify:**
- ✅ RSA-2048 key generation
- ✅ Signature creation and verification
- ✅ Hash generation (SHA-256)
- ✅ Key serialization/deserialization

### Penetration Testing Checklist

- [ ] SQL Injection (N/A - using Firestore)
- [ ] XSS (N/A - Flutter app)
- [ ] CSRF (N/A - Firebase handles auth)
- [ ] Man-in-the-middle (Firebase uses HTTPS)
- [ ] Key extraction from device storage
- [ ] Signature forgery attempts
- [ ] Contract tampering attempts

### Firebase Security Rules Testing

Test in Firebase Console → Firestore → Rules → Playground:

```javascript
// Test 1: User can read their own data
// Auth: user123
// Path: /users/user123
// Operation: get
// Expected: Allow

// Test 2: User cannot read other's data
// Auth: user123
// Path: /users/user456
// Operation: get
// Expected: Deny

// Test 3: User can read contracts they're part of
// Auth: user123
// Path: /contracts/contract1 (where lenderId = user123)
// Operation: get
// Expected: Allow
```

---

## ⚡ Performance Testing

### App Size

```powershell
# Build release APK
flutter build apk --release

# Check size
# File: build/app/outputs/flutter-apk/app-release.apk
# Expected: < 50MB
```

### Startup Time

Measure time from app launch to home screen:
- **Target:** < 3 seconds on mid-range device
- **Acceptable:** < 5 seconds

### Memory Usage

Monitor in Android Studio Profiler:
- **Target:** < 100MB RAM
- **Acceptable:** < 150MB RAM

### Network Usage

Monitor Firebase calls:
- Minimize unnecessary reads/writes
- Use caching where appropriate
- Batch operations when possible

---

## 📊 Test Coverage Goals

| Module | Target Coverage | Current |
|--------|----------------|---------|
| Crypto Services | 90% | ✅ 95% |
| Validators | 90% | ✅ 92% |
| Auth Service | 80% | ⏳ 0% |
| Contract Service | 80% | ⏳ 0% |
| Storage Service | 80% | ⏳ 0% |
| UI Widgets | 70% | ⏳ 0% |

---

## 🐛 Bug Reporting Template

When you find a bug, report it with:

```markdown
**Bug Title:** Brief description

**Steps to Reproduce:**
1. Step one
2. Step two
3. Step three

**Expected Behavior:**
What should happen

**Actual Behavior:**
What actually happens

**Screenshots:**
(if applicable)

**Environment:**
- Device: (e.g., Pixel 5)
- Android Version: (e.g., 13)
- App Version: (e.g., 1.0.0)

**Logs:**
```
Paste relevant logs here
```
```

---

## 🎯 Testing Best Practices

1. **Write tests first** (TDD approach)
2. **Test edge cases** (empty, null, invalid data)
3. **Mock external dependencies** (Firebase, storage)
4. **Keep tests independent** (no shared state)
5. **Use descriptive test names**
6. **Maintain test coverage** (aim for >80%)
7. **Run tests before commits**
8. **Update tests when code changes**

---

## 🔄 Continuous Integration (Future)

Set up GitHub Actions for automated testing:

```yaml
name: Flutter CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter build apk --release
```

---

## 📚 Resources

- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Widget Testing](https://docs.flutter.dev/cookbook/testing/widget/introduction)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [Firebase Test Lab](https://firebase.google.com/docs/test-lab)

---

**Testing Guide Version:** 1.0  
**Last Updated:** January 14, 2026  
**Next Review:** February 14, 2026
