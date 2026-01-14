# 🚀 Quick Setup Guide for Safe-Lending (TPLN)

This guide will help you set up and run the Safe-Lending project on your machine.

---

## ✅ Prerequisites Checklist

Before starting, ensure you have:

- [ ] Windows 10/11 (64-bit)
- [ ] At least 10GB free disk space
- [ ] Stable internet connection
- [ ] Administrator access (for installations)

---

## 📥 Step 1: Install Flutter SDK

### Option A: Using Installer (Recommended)
1. Download Flutter SDK from: https://docs.flutter.dev/get-started/install/windows
2. Extract the zip file to `C:\src\flutter`
3. Add Flutter to PATH:
   - Open "Edit system environment variables"
   - Click "Environment Variables"
   - Under "User variables", find "Path"
   - Click "Edit" → "New"
   - Add: `C:\src\flutter\bin`
   - Click "OK" on all dialogs

### Option B: Using PowerShell
```powershell
# Create directory
New-Item -ItemType Directory -Path "C:\src" -Force

# Download Flutter (replace with latest version)
# Visit https://docs.flutter.dev/get-started/install/windows for download link

# Extract to C:\src\flutter
# Then add to PATH as described above
```

### Verify Installation
```powershell
flutter doctor
```

Expected output:
```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.x.x, on Microsoft Windows...)
[✗] Android toolchain - develop for Android devices
[✗] Chrome - develop for the web
[✗] Visual Studio - develop Windows apps
[✓] VS Code (version x.x.x)
```

---

## 📱 Step 2: Install Android Studio (for Android development)

1. Download from: https://developer.android.com/studio
2. Run the installer
3. During installation, ensure these are selected:
   - Android SDK
   - Android SDK Platform
   - Android Virtual Device (AVD)
4. Complete the setup wizard
5. Open Android Studio → More Actions → SDK Manager
6. Install:
   - Android SDK Platform 34 (or latest)
   - Android SDK Build-Tools
   - Android Emulator

### Configure Android SDK
```powershell
flutter doctor --android-licenses
# Accept all licenses by typing 'y'
```

---

## 🔥 Step 3: Set Up Firebase

### 3.1 Create Firebase Project
1. Go to https://console.firebase.google.com
2. Click "Add project"
3. Project name: `TPLN-Safe-Lending` (or your choice)
4. Disable Google Analytics (optional)
5. Click "Create project"

### 3.2 Add Android App
1. In Firebase Console, click Android icon
2. **Android package name**: `com.tpln.app` (MUST match exactly)
3. App nickname: `TPLN Android`
4. Click "Register app"
5. Download `google-services.json`
6. Place file in: `android/app/google-services.json`
7. Delete the `FIREBASE_SETUP.md` file in that directory

### 3.3 Enable Firebase Services

#### Enable Authentication
1. In Firebase Console → Build → Authentication
2. Click "Get started"
3. Click "Email/Password" → Enable → Save

#### Create Firestore Database
1. In Firebase Console → Build → Firestore Database
2. Click "Create database"
3. Select "Start in production mode"
4. Choose location (closest to your users)
5. Click "Enable"

#### Set Firestore Security Rules
1. Go to Firestore → Rules tab
2. Replace with:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    match /contracts/{contractId} {
      allow read: if request.auth != null && 
        (resource.data.lenderId == request.auth.uid || 
         resource.data.borrowerId == request.auth.uid);
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        (resource.data.lenderId == request.auth.uid || 
         resource.data.borrowerId == request.auth.uid);
      allow delete: if request.auth != null && 
        resource.data.lenderId == request.auth.uid;
    }
    
    match /repayments/{repaymentId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
    }
  }
}
```
3. Click "Publish"

---

## 📦 Step 4: Install Project Dependencies

Open PowerShell in the project directory:

```powershell
# Navigate to project
cd "C:\Users\ANSH SINGH\Desktop\safe-lending\Safe-Lending"

# Install dependencies
flutter pub get
```

Expected output:
```
Running "flutter pub get" in Safe-Lending...
Resolving dependencies... 
Got dependencies!
```

---

## 🏃 Step 5: Run the App

### Option A: Using Android Emulator

1. **Create Emulator** (first time only):
   ```powershell
   # List available devices
   flutter emulators
   
   # Create emulator (if none exist)
   flutter emulators --create
   ```

2. **Start Emulator**:
   - Open Android Studio
   - Click "Device Manager" (phone icon)
   - Click ▶️ next to your emulator

3. **Run App**:
   ```powershell
   flutter run
   ```

### Option B: Using Physical Device

1. **Enable Developer Options** on your Android phone:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
   - Go back → Developer Options
   - Enable "USB Debugging"

2. **Connect phone via USB**

3. **Verify connection**:
   ```powershell
   flutter devices
   ```

4. **Run app**:
   ```powershell
   flutter run
   ```

### Option C: Using Chrome (Web)

```powershell
flutter run -d chrome
```

---

## 🧪 Step 6: Test the App

### Create Test Account
1. Click "Register" on login screen
2. Fill in:
   - Full Name: Test User
   - Email: test@example.com
   - Phone: +1234567890
   - Password: Test@123456
3. Click "Register"

### Create Test Contract
1. After login, click "Create Contract"
2. Fill in contract details
3. Sign the contract
4. Verify it appears in "My Contracts"

---

## 🔧 Troubleshooting

### Issue: "Flutter not found"
**Solution**: Ensure Flutter is added to PATH and restart PowerShell

### Issue: "Android licenses not accepted"
**Solution**: Run `flutter doctor --android-licenses`

### Issue: "Firebase error"
**Solution**: 
- Verify `google-services.json` is in `android/app/`
- Package name matches: `com.tpln.app`
- Firebase services are enabled

### Issue: "Build failed"
**Solution**:
```powershell
flutter clean
flutter pub get
flutter run
```

### Issue: "Gradle build failed"
**Solution**: Check internet connection, Gradle downloads dependencies

---

## 📊 Verify Setup

Run Flutter doctor:
```powershell
flutter doctor -v
```

All checks should be ✓ (green) except:
- Visual Studio (only needed for Windows desktop apps)
- Xcode (only needed for iOS apps on Mac)

---

## 🎯 Next Steps

1. ✅ Explore the app features
2. ✅ Read `PROJECT_ANALYSIS.md` for detailed documentation
3. ✅ Check `README.md` for project overview
4. ✅ Review code in `lib/` directory
5. ✅ Add custom assets to `assets/` directory

---

## 📚 Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase for Flutter](https://firebase.google.com/docs/flutter/setup)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Material Design 3](https://m3.material.io/)

---

## 💬 Need Help?

- Check `PROJECT_ANALYSIS.md` for detailed project information
- Review Flutter documentation
- Check Firebase console for service status
- Run `flutter doctor` to diagnose issues

---

**Setup Guide Version:** 1.0  
**Last Updated:** January 14, 2026  
**Estimated Setup Time:** 30-60 minutes (first time)

Good luck! 🚀
