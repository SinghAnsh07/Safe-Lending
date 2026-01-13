# TPLN - Technical Documentation

## Architecture Overview

### System Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter UI Layer                      │
│  (Screens, Widgets, Forms, Navigation)                  │
└─────────────────────────────────────────────────────────┘
                          │
┌─────────────────────────────────────────────────────────┐
│                  State Management Layer                  │
│  (Provider: AuthService, ContractService, etc.)         │
└─────────────────────────────────────────────────────────┘
                          │
┌─────────────────────────────────────────────────────────┐
│                  Business Logic Layer                    │
│  (Contract Creation, Signing, Verification)             │
└─────────────────────────────────────────────────────────┘
                          │
┌─────────────────────────────────────────────────────────┐
│                  Cryptography Layer                      │
│  (RSA, AES, SHA-256, Digital Signatures)                │
└─────────────────────────────────────────────────────────┘
                          │
┌─────────────────────────────────────────────────────────┐
│                   Storage Layer                          │
│  (Secure Storage, Firestore, Local Cache)               │
└─────────────────────────────────────────────────────────┘
                          │
┌─────────────────────────────────────────────────────────┐
│                   Backend (Firebase)                     │
│  (Authentication, Firestore, Cloud Functions)           │
└─────────────────────────────────────────────────────────┘
```

## Cryptographic Implementation

### 1. RSA Digital Signatures (2048-bit)

**Purpose**: Ensure non-repudiation and authenticity

**Implementation**:
- Key Generation: `RSAService.generateKeyPair()`
- Signing: `RSAService.sign(data, privateKey)`
- Verification: `RSAService.verify(data, signature, publicKey)`

**Key Storage**:
- Private Key: Stored in device's secure storage (never transmitted)
- Public Key: Stored in Firestore (publicly accessible)

### 2. SHA-256 Hashing

**Purpose**: Ensure data integrity

**Implementation**:
- Contract Hash: `HashService.generateContractHash(...)`
- Repayment Hash: `HashService.generateRepaymentHash(...)`

**Hash Components** (Contract):
```dart
{
  'lenderId': string,
  'borrowerId': string,
  'amount': double,
  'interestRate': double,
  'dueDate': DateTime,
  'notes': string?
}
```

### 3. AES-256 Encryption

**Purpose**: Protect sensitive data at rest

**Implementation**:
- Encryption: `AESService.encrypt(plainText, key)`
- Decryption: `AESService.decrypt(encryptedData, key)`

**Use Cases**:
- Encrypting private keys before storage
- Encrypting sensitive contract notes

## Data Models

### User Model

```dart
{
  id: string,
  email: string,
  fullName: string,
  phoneNumber: string,
  publicKey: string (PEM format),
  createdAt: DateTime,
  updatedAt: DateTime
}
```

### Contract Model

```dart
{
  id: string,
  lenderId: string,
  lenderName: string,
  lenderEmail: string,
  borrowerId: string,
  borrowerName: string,
  borrowerEmail: string,
  amount: double,
  interestRate: double,
  dueDate: DateTime,
  contractHash: string (SHA-256),
  lenderSignature: string? (RSA signature),
  borrowerSignature: string? (RSA signature),
  status: ContractStatus,
  amountPaid: double,
  createdAt: DateTime,
  updatedAt: DateTime,
  notes: string?
}
```

### Repayment Model

```dart
{
  id: string,
  contractId: string,
  payerId: string,
  payerName: string,
  amount: double,
  paymentDate: DateTime,
  transactionHash: string (SHA-256),
  notes: string?,
  createdAt: DateTime
}
```

## Contract Lifecycle

### 1. Creation Phase

```
Lender → Create Contract
  ↓
Generate Contract Hash (SHA-256)
  ↓
Sign Hash with Lender's Private Key (RSA)
  ↓
Store in Firestore (Status: PENDING)
```

### 2. Signing Phase

```
Borrower → View Contract
  ↓
Verify Contract Hash
  ↓
Sign Hash with Borrower's Private Key (RSA)
  ↓
Update Contract (Status: ACTIVE)
```

### 3. Repayment Phase

```
Borrower → Make Repayment
  ↓
Generate Repayment Hash (SHA-256)
  ↓
Create Repayment Record
  ↓
Update Contract Amount Paid
  ↓
If Fully Paid → Status: COMPLETED
```

## Security Features

### 1. Key Management

- **Private Keys**: Never leave the device
- **Public Keys**: Stored in Firestore for verification
- **Secure Storage**: Uses platform-specific secure storage
  - Android: EncryptedSharedPreferences
  - iOS: Keychain

### 2. Contract Integrity

Every contract read operation verifies:
1. Hash matches contract data
2. Lender signature is valid
3. Borrower signature is valid (if signed)

### 3. Attack Prevention

| Attack Type | Prevention Method |
|-------------|-------------------|
| Contract Modification | Hash verification fails |
| Signature Forgery | RSA verification fails |
| Replay Attacks | Timestamp checks |
| Man-in-the-Middle | HTTPS + Firebase Security |
| Data Tampering | Cryptographic signatures |

## Firebase Security Rules

### Firestore Rules

```javascript
// Users: Read all, write own
match /users/{userId} {
  allow read: if request.auth != null;
  allow create: if request.auth.uid == userId;
  allow update: if request.auth.uid == userId;
}

// Contracts: Read/write only if involved
match /contracts/{contractId} {
  allow read: if request.auth != null && 
    (resource.data.lenderId == request.auth.uid || 
     resource.data.borrowerId == request.auth.uid);
  allow create: if request.auth.uid == resource.data.lenderId;
  allow update: if request.auth.uid in [
    resource.data.lenderId, 
    resource.data.borrowerId
  ];
}

// Repayments: Read all, create only
match /repayments/{repaymentId} {
  allow read: if request.auth != null;
  allow create: if request.auth != null;
}
```

## API Reference

### AuthService

```dart
// Register new user
Future<String?> register({
  required String email,
  required String password,
  required String fullName,
  required String phoneNumber,
})

// Login user
Future<String?> login({
  required String email,
  required String password,
})

// Logout user
Future<void> logout()

// Get user by email
Future<UserModel?> getUserByEmail(String email)
```

### ContractService

```dart
// Create contract
Future<String?> createContract({
  required UserModel lender,
  required UserModel borrower,
  required double amount,
  required double interestRate,
  required DateTime dueDate,
  String? notes,
})

// Sign contract as borrower
Future<bool> signContractAsBorrower(String contractId)

// Verify contract integrity
Future<bool> verifyContractIntegrity(ContractModel contract)

// Get user contracts
Stream<List<ContractModel>> getAllUserContracts(String userId)
```

### RepaymentService

```dart
// Make repayment
Future<bool> makeRepayment({
  required String contractId,
  required String payerId,
  required String payerName,
  required double amount,
  String? notes,
})

// Get contract repayments
Stream<List<RepaymentModel>> getContractRepayments(String contractId)

// Verify repayment integrity
Future<bool> verifyRepaymentIntegrity(RepaymentModel repayment)
```

## Testing Strategy

### Unit Tests

- Cryptography functions (RSA, AES, SHA-256)
- Hash generation and verification
- Signature creation and validation
- Data model serialization

### Integration Tests

- Contract creation flow
- Signing workflow
- Repayment processing
- Firebase integration

### Security Tests

- Contract tampering detection
- Signature forgery attempts
- Hash collision resistance
- Key storage security

## Performance Considerations

### Optimization Strategies

1. **Lazy Loading**: Load contracts on-demand
2. **Caching**: Cache user data and public keys
3. **Pagination**: Limit contract list queries
4. **Indexing**: Firestore composite indexes for queries

### Cryptographic Performance

| Operation | Time (avg) |
|-----------|-----------|
| RSA Key Generation | ~500ms |
| RSA Signing | ~50ms |
| RSA Verification | ~20ms |
| SHA-256 Hashing | <1ms |
| AES Encryption | ~5ms |

## Deployment Checklist

- [ ] Flutter SDK installed
- [ ] Firebase project created
- [ ] `google-services.json` added
- [ ] Firestore security rules deployed
- [ ] Authentication enabled
- [ ] Dependencies installed (`flutter pub get`)
- [ ] App tested on emulator
- [ ] App tested on physical device
- [ ] Release APK built
- [ ] Security audit completed

## Future Enhancements

1. **Multi-signature Contracts**: Support for witnesses
2. **Partial Repayments**: Installment tracking
3. **Contract Templates**: Pre-defined loan types
4. **Risk Scoring**: Borrower credit rating
5. **Dispute Resolution**: Mediation system
6. **Export Contracts**: PDF generation
7. **Notifications**: Push notifications for due dates
8. **Biometric Auth**: Fingerprint/Face ID
9. **Backup & Recovery**: Cloud backup for keys
10. **Multi-currency**: Support for different currencies

## Troubleshooting

### Common Issues

**Issue**: Private key not found after login
**Solution**: Keys are device-specific. Re-register on new device.

**Issue**: Contract verification fails
**Solution**: Check if contract data was modified. Verify signatures.

**Issue**: Firebase connection error
**Solution**: Check internet connection and Firebase configuration.

**Issue**: Gradle build fails
**Solution**: Update Gradle version and sync dependencies.

## License

MIT License - See LICENSE file for details

## Contributors

- Your Name - Lead Developer
- TPLN Team - Architecture & Design

## Support

For technical support:
- Email: support@tpln.app
- GitHub Issues: github.com/tpln/issues
- Documentation: docs.tpln.app
