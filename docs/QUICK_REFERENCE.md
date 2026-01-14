# 🚀 Quick Reference Guide - Safe-Lending (TPLN)

**One-page reference for common tasks and commands**

---

## 📦 Installation & Setup

```powershell
# 1. Install Flutter SDK
# Download from: https://docs.flutter.dev/get-started/install/windows
# Add to PATH: C:\src\flutter\bin

# 2. Verify installation
flutter doctor

# 3. Navigate to project
cd "C:\Users\ANSH SINGH\Desktop\safe-lending\Safe-Lending"

# 4. Install dependencies
flutter pub get

# 5. Run app
flutter run
```

---

## 🔥 Firebase Quick Setup

1. **Create project:** https://console.firebase.google.com
2. **Add Android app:** Package name = `com.tpln.app`
3. **Download:** `google-services.json` → `android/app/`
4. **Enable:** Authentication (Email/Password)
5. **Create:** Firestore Database
6. **Set Rules:** Copy from `android/app/FIREBASE_SETUP.md`

---

## 🛠️ Common Commands

### Development
```powershell
# Run app
flutter run

# Run on specific device
flutter run -d <device-id>

# Hot reload (in running app)
# Press 'r' in terminal

# Hot restart (in running app)
# Press 'R' in terminal

# Clean build
flutter clean
flutter pub get
flutter run
```

### Testing
```powershell
# Run all tests
flutter test

# Run specific test
flutter test test/crypto_test.dart

# Run with coverage
flutter test --coverage

# Verbose output
flutter test -v
```

### Building
```powershell
# Build APK (debug)
flutter build apk

# Build APK (release)
flutter build apk --release

# Build App Bundle
flutter build appbundle --release

# Build for web
flutter build web
```

### Debugging
```powershell
# Check devices
flutter devices

# Doctor check
flutter doctor -v

# Analyze code
flutter analyze

# Format code
dart format lib/
```

---

## 📂 Project Structure

```
lib/
├── auth/              # Login, Register, Auth Service
├── contracts/         # Contract CRUD operations
├── crypto/            # RSA, AES, Hash, Signature
├── models/            # Data models
├── screens/           # UI screens
├── services/          # Storage, Repayment
├── utils/             # Constants, Validators
└── main.dart          # Entry point
```

---

## 🔑 Key Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point |
| `lib/auth/auth_service.dart` | Authentication logic |
| `lib/crypto/rsa_service.dart` | RSA cryptography |
| `lib/utils/constants.dart` | App constants |
| `pubspec.yaml` | Dependencies |
| `android/app/build.gradle` | Android config |

---

## 🎨 Color Scheme

```dart
Primary: #6366F1 (Indigo)
Accent:  #10B981 (Green)
Warning: #F59E0B (Amber)
Danger:  #EF4444 (Red)
```

---

## 🔐 Security Features

- **RSA-2048:** Digital signatures
- **AES-256:** Data encryption
- **SHA-256:** Hashing
- **Secure Storage:** Private keys
- **Firebase Auth:** User authentication

---

## 📱 User Flows

### Registration
1. Open app → Register
2. Fill form → Submit
3. Keys generated automatically
4. Auto-login → Home screen

### Create Contract
1. Login → Create Contract
2. Enter borrower email, amount, rate, date
3. Sign contract
4. Contract created & sent to borrower

### Sign Contract
1. Login as borrower
2. View pending contract
3. Review details
4. Sign contract
5. Contract becomes active

### Make Repayment
1. Login as borrower
2. View active contract
3. Make Repayment
4. Enter amount
5. Confirm payment

---

## 🧪 Testing Checklist

- [ ] User registration works
- [ ] User login works
- [ ] Contract creation works
- [ ] Contract signing works
- [ ] Repayment recording works
- [ ] Signatures verify correctly
- [ ] Keys are stored securely

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| Flutter not found | Add to PATH, restart terminal |
| Build failed | `flutter clean && flutter pub get` |
| Firebase error | Check `google-services.json` location |
| Gradle error | Check internet, wait for download |
| Device not found | Enable USB debugging |

---

## 📚 Documentation

- `README.md` - Project overview
- `PROJECT_ANALYSIS.md` - Complete analysis
- `SETUP_GUIDE.md` - Detailed setup
- `TESTING_GUIDE.md` - Testing procedures
- `PROJECT_STATUS.md` - Current status

---

## 🔗 Quick Links

- **Flutter Docs:** https://docs.flutter.dev/
- **Firebase Console:** https://console.firebase.google.com
- **Dart Packages:** https://pub.dev/
- **Material Design:** https://m3.material.io/

---

## 💡 Pro Tips

1. **Hot Reload:** Press `r` for quick UI updates
2. **DevTools:** Run `flutter pub global activate devtools`
3. **Logs:** Use `debugPrint()` for debugging
4. **State:** Use Provider for state management
5. **Async:** Always use `async/await` for Firebase

---

## 🎯 Next Steps

1. ✅ Install Flutter SDK
2. ✅ Configure Firebase
3. ✅ Run `flutter pub get`
4. ✅ Run `flutter run`
5. ✅ Test all features
6. ✅ Read documentation

---

**Quick Reference v1.0** | Last Updated: Jan 14, 2026
