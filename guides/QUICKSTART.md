# 🚀 Quick Start Guide - TPLN

## Get Started in 5 Minutes!

### Step 1: Install Flutter (5 minutes)

**Windows:**
1. Download Flutter SDK: https://docs.flutter.dev/get-started/install/windows
2. Extract to `C:\src\flutter`
3. Add to System PATH:
   - Search "Environment Variables" in Windows
   - Edit "Path" variable
   - Add: `C:\src\flutter\bin`
4. Open new terminal and run:
   ```bash
   flutter doctor
   ```

### Step 2: Setup Firebase (3 minutes)

1. Go to: https://console.firebase.google.com/
2. Click "Add project" → Name it "TPLN" → Create
3. Click Android icon → Package name: `com.tpln.app`
4. Download `google-services.json`
5. Place file in: `android/app/google-services.json`
6. Enable Authentication:
   - Go to Authentication → Get Started
   - Enable "Email/Password"
7. Create Firestore:
   - Go to Firestore Database → Create Database
   - Start in "Test mode" → Enable

### Step 3: Install Dependencies (1 minute)

Open terminal in project folder:
```bash
cd fluttersprint
flutter pub get
```

### Step 4: Run the App! (30 seconds)

**Option A: Android Emulator**
```bash
flutter run
```

**Option B: Physical Device**
1. Enable USB Debugging on phone
2. Connect via USB
3. Run: `flutter run`

---

## 🎉 That's It!

Your app is now running! You can:

1. **Register** a new account
2. **Create** a loan contract
3. **Sign** contracts digitally
4. **Track** repayments
5. **Verify** cryptographic signatures

---

## 🔥 Quick Test

### Test Scenario: Create Your First Contract

1. **Register User 1 (Lender)**
   - Email: `lender@test.com`
   - Password: `Test@123`
   - Name: `John Lender`
   - Phone: `1234567890`

2. **Register User 2 (Borrower)**
   - Email: `borrower@test.com`
   - Password: `Test@123`
   - Name: `Jane Borrower`
   - Phone: `0987654321`

3. **Login as Lender**
   - Click "Create Contract"
   - Borrower Email: `borrower@test.com`
   - Amount: `10000`
   - Interest: `12`
   - Due Date: Select future date
   - Click "Create Contract"

4. **Login as Borrower**
   - View pending contract
   - Click "Sign Contract"
   - Contract becomes active!

5. **Make Repayment**
   - Click contract
   - Click "Make Repayment"
   - Enter amount: `5000`
   - Confirm

6. **Verify Contract**
   - Click "Verify Contract"
   - See cryptographic verification ✓

---

## 📱 App Features

### ✅ What You Can Do

- **Secure Registration**: RSA keys generated automatically
- **Create Contracts**: Specify amount, interest, due date
- **Digital Signatures**: Cryptographically signed contracts
- **Track Payments**: Real-time repayment tracking
- **Verify Integrity**: Check contract hasn't been tampered
- **View History**: See all your contracts and payments

---

## 🔐 Security Highlights

- **RSA-2048**: Military-grade encryption
- **SHA-256**: Tamper-proof hashing
- **AES-256**: Secure data storage
- **Private Keys**: Never leave your device
- **Firebase**: Enterprise-grade backend

---

## 🐛 Troubleshooting

### "Flutter not recognized"
- Add Flutter to PATH (see Step 1)
- Restart terminal

### "No devices found"
- Start Android emulator, OR
- Enable USB debugging on phone

### "Firebase error"
- Check `google-services.json` is in `android/app/`
- Verify Firebase project is created

### "Build failed"
- Run: `flutter clean`
- Run: `flutter pub get`
- Try again: `flutter run`

---

## 📚 Documentation

- **README.md** - Overview
- **FIREBASE_SETUP.md** - Detailed Firebase setup
- **TECHNICAL_DOCS.md** - Architecture & API
- **PROJECT_SUMMARY.md** - What's included

---

## 🎯 Next Steps

1. **Customize**: Change colors in `lib/utils/constants.dart`
2. **Extend**: Add more features
3. **Deploy**: Build APK with `flutter build apk`
4. **Share**: Distribute your app!

---

## 💡 Pro Tips

- Use **Chrome DevTools** for debugging
- Check **Firebase Console** for data
- View **logs** with `flutter logs`
- **Hot reload** with `r` in terminal

---

## 🌟 You're All Set!

Enjoy your cryptographically secure lending app!

**Questions?** Check the documentation files or Firebase console for errors.

**Happy Coding!** 🚀
