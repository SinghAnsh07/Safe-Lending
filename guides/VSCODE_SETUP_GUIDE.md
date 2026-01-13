# 🚀 Complete VS Code Setup Guide for Flutter

## Step-by-Step Installation (Following Official Guide)

### Step 1: Install Flutter SDK (Required - One Time Only)

#### Option A: Using VS Code Extension (Easiest)

1. **Open VS Code**
2. **Install Flutter Extension:**
   - Press `Ctrl+Shift+X` (Extensions)
   - Search for "Flutter"
   - Click **Install** on "Flutter" by Dart Code
   - This will also install the Dart extension

3. **Download Flutter SDK via VS Code:**
   - Press `Ctrl+Shift+P` (Command Palette)
   - Type: `Flutter: New Project`
   - VS Code will prompt: "Flutter SDK not found"
   - Click **"Download SDK"**
   - Choose location: `C:\src\flutter`
   - Wait for download (this is the 1.6 GB download - unavoidable)

#### Option B: Manual Download (For Resume Support)

1. **Download Flutter SDK:**
   - Go to: https://docs.flutter.dev/get-started/install/windows
   - Download the zip file (use a download manager for resume support)
   - Extract to: `C:\src\flutter`

2. **Add to System PATH:**
   - Press `Windows + R`
   - Type: `sysdm.cpl` and press Enter
   - Go to **Advanced** tab → **Environment Variables**
   - Under **System Variables**, find **Path**
   - Click **Edit** → **New**
   - Add: `C:\src\flutter\bin`
   - Click **OK** on all dialogs

3. **Verify Installation:**
   - Open **new** Command Prompt or PowerShell
   - Run:
     ```bash
     flutter doctor
     ```

---

### Step 2: Install VS Code Extensions

1. **Open VS Code**
2. **Install Required Extensions:**
   - Press `Ctrl+Shift+X`
   - Install these extensions:
     - ✅ **Flutter** (by Dart Code)
     - ✅ **Dart** (by Dart Code - auto-installed with Flutter)

---

### Step 3: Setup Your Project

1. **Open Your Project in VS Code:**
   - File → Open Folder
   - Navigate to: `C:\Users\ANSH SINGH\Desktop\fluttersprint`
   - Click **Select Folder**

2. **Install Dependencies:**
   - Open Terminal in VS Code: `Ctrl+` ` (backtick)
   - Run:
     ```bash
     flutter pub get
     ```

---

### Step 4: Setup Firebase (Required for This App)

1. **Create Firebase Project:**
   - Go to: https://console.firebase.google.com/
   - Click **"Add project"**
   - Name: `TPLN`
   - Follow the wizard

2. **Add Android App:**
   - Click **Android icon**
   - Package name: `com.tpln.app`
   - Download `google-services.json`
   - Place in: `fluttersprint/android/app/google-services.json`

3. **Enable Firebase Services:**
   - **Authentication:**
     - Go to Authentication → Get Started
     - Enable **Email/Password**
   - **Firestore:**
     - Go to Firestore Database → Create Database
     - Start in **Test mode**
     - Select region → Enable

---

### Step 5: Setup Android Emulator (Choose One)

#### Option A: Use Android Studio Emulator (Recommended)

1. **Install Android Studio:**
   - Download: https://developer.android.com/studio
   - Install with default options
   - Open Android Studio
   - Go to: Tools → Device Manager
   - Click **Create Device**
   - Choose: Pixel 5 → Next
   - Download System Image: Android 13 (API 33)
   - Finish setup

2. **Start Emulator:**
   - Open Device Manager in Android Studio
   - Click ▶️ Play button on your device

#### Option B: Use Physical Android Device

1. **Enable Developer Options:**
   - Go to Settings → About Phone
   - Tap **Build Number** 7 times
   - Go back → Developer Options

2. **Enable USB Debugging:**
   - In Developer Options
   - Turn on **USB Debugging**

3. **Connect Device:**
   - Connect phone via USB
   - Allow USB debugging on phone
   - In VS Code terminal, verify:
     ```bash
     flutter devices
     ```

---

### Step 6: Run Your App! 🎉

#### Method 1: Using VS Code UI (Easiest)

1. **Select Device:**
   - Look at bottom-right of VS Code
   - Click on device selector
   - Choose your emulator or physical device

2. **Run App:**
   - Press `F5` (or)
   - Press `Ctrl+Shift+D` → Click ▶️ **Start Debugging**

#### Method 2: Using Terminal

```bash
# See available devices
flutter devices

# Run on connected device
flutter run

# Run on specific device
flutter run -d <device-id>

# Run on Chrome (for web testing)
flutter run -d chrome
```

#### Method 3: Using Command Palette

1. Press `Ctrl+Shift+P`
2. Type: `Flutter: Select Device`
3. Choose your device
4. Press `Ctrl+Shift+P` again
5. Type: `Flutter: Run Flutter Doctor`
6. Then: `Flutter: Launch Emulator`

---

## 🎯 Quick Commands Reference

### In VS Code Terminal:

```bash
# Install dependencies
flutter pub get

# Run app
flutter run

# Run on web
flutter run -d chrome

# Check setup
flutter doctor

# Clean build
flutter clean

# Build APK
flutter build apk

# Hot reload (while app is running)
# Press 'r' in terminal

# Hot restart (while app is running)
# Press 'R' in terminal

# Quit app
# Press 'q' in terminal
```

---

## 🔥 First Run Test

After running the app, you should see:

1. **Splash Screen** with TPLN logo
2. **Login/Register** screen
3. Try registering a new user:
   - Email: `test@example.com`
   - Password: `Test@123`
   - Name: `Test User`
   - Phone: `1234567890`

---

## 🐛 Troubleshooting

### "Flutter SDK not found"
- Verify PATH is set correctly
- Restart VS Code
- Run `flutter doctor` in terminal

### "No devices found"
- Start Android emulator first
- Or connect physical device with USB debugging
- Run `flutter devices` to check

### "Build failed"
```bash
flutter clean
flutter pub get
flutter run
```

### "Firebase error"
- Verify `google-services.json` is in `android/app/`
- Check Firebase project is created
- Verify Authentication and Firestore are enabled

### "Gradle error"
- Check internet connection
- Wait for Gradle download (first time only)
- May take 5-10 minutes on first run

---

## 💡 VS Code Shortcuts

- `F5` - Start Debugging
- `Ctrl+F5` - Run Without Debugging
- `Shift+F5` - Stop Debugging
- `Ctrl+Shift+P` - Command Palette
- `Ctrl+` ` - Toggle Terminal
- `Ctrl+Shift+D` - Debug View

---

## 🌟 You're All Set!

Your Flutter development environment is ready in VS Code!

**Next Steps:**
1. Run the app with `F5`
2. Test user registration
3. Create a loan contract
4. Explore the features!

**Happy Coding!** 🚀
