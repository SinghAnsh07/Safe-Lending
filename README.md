# TRUSTLESS PEER-TO-PEER LENDING NETWORK (TPLN)

A Cryptographically Secure Informal Lending System

## 🚀 Quick Start

### Prerequisites
1. **Install Flutter SDK**
   - Download from: https://docs.flutter.dev/get-started/install/windows
   - Extract to `C:\src\flutter`
   - Add to PATH: `C:\src\flutter\bin`

2. **Install Android Studio**
   - Download from: https://developer.android.com/studio
   - Install Android SDK and emulator

3. **Verify Installation**
   ```bash
   flutter doctor
   ```

### Setup This Project

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Configure Firebase**
   - Create a Firebase project at https://console.firebase.google.com
   - Download `google-services.json` (Android) and place in `android/app/`
   - Download `GoogleService-Info.plist` (iOS) and place in `ios/Runner/`
   - Update `lib/services/firebase_config.dart` with your Firebase config

3. **Run the App**
   ```bash
   flutter run
   ```

## 📱 Features

- ✅ User Authentication (Email/Phone)
- ✅ Digital Loan Contracts
- ✅ RSA Digital Signatures
- ✅ AES Encryption
- ✅ SHA-256 Hashing
- ✅ Secure Local Storage
- ✅ Repayment Tracking
- ✅ Contract History
- ✅ Audit Logs

## 🔐 Security

- **RSA-2048** for digital signatures
- **AES-256** for data encryption
- **SHA-256** for integrity verification
- **Secure Storage** for private keys
- **Firebase Security Rules** for access control

## 📂 Project Structure

```
lib/
├── main.dart                 # App entry point
├── auth/                     # Authentication
│   ├── login_screen.dart
│   ├── register_screen.dart
│   └── auth_service.dart
├── contracts/                # Contract management
│   ├── create_contract_screen.dart
│   ├── contract_details_screen.dart
│   ├── contracts_list_screen.dart
│   └── contract_service.dart
├── crypto/                   # Cryptography
│   ├── rsa_service.dart
│   ├── aes_service.dart
│   ├── hash_service.dart
│   └── signature_service.dart
├── models/                   # Data models
│   ├── user_model.dart
│   ├── contract_model.dart
│   └── repayment_model.dart
├── services/                 # Backend services
│   ├── firebase_service.dart
│   ├── storage_service.dart
│   └── audit_service.dart
├── screens/                  # UI screens
│   ├── home_screen.dart
│   ├── profile_screen.dart
│   └── repayment_screen.dart
└── utils/                    # Utilities
    ├── constants.dart
    └── validators.dart
```

## 🧪 Testing

```bash
flutter test
```

## 📦 Build APK

```bash
flutter build apk --release
```

## 🎯 Development Roadmap

- [x] Week 1: Setup + Auth
- [x] Week 2: Contract UI
- [x] Week 3: Cryptography
- [x] Week 4: Secure Storage
- [x] Week 5: Repayments
- [x] Week 6: Security Hardening
- [ ] Week 7: Testing
- [ ] Week 8: Polish & Deploy

## 📄 License

MIT License
