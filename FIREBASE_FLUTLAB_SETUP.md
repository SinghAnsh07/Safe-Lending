# 🔥 Firebase Setup for FlutLab - Complete Guide

## Overview

You need to set up Firebase to use authentication and database features in your TPLN app. Here's how to do it step-by-step.

---

## Part 1: Create Firebase Project (5 minutes)

### Step 1: Go to Firebase Console

1. **Open your browser**
2. **Go to:** https://console.firebase.google.com/
3. **Sign in** with your Google account

### Step 2: Create New Project

1. **Click:** "Add project" or "Create a project"
2. **Enter project name:** `TPLN` (or `Safe-Lending`)
3. **Click:** Continue
4. **Google Analytics:** You can disable it for now (toggle off)
5. **Click:** Create project
6. **Wait** 30-60 seconds for project creation
7. **Click:** Continue when ready

---

## Part 2: Setup Android App (10 minutes)

### Step 1: Register Android App

1. **In Firebase Console**, click the **Android icon** (robot)
2. **Fill in the form:**
   - **Android package name:** `com.tpln.app`
   - **App nickname (optional):** `TPLN Android`
   - **Debug signing certificate (optional):** Leave blank for now
3. **Click:** Register app

### Step 2: Download google-services.json

1. **Click:** "Download google-services.json"
2. **Save the file** to your Downloads folder
3. **Important:** Keep this file safe, you'll need it!

### Step 3: Upload to Your Project

**Option A: If Using FlutLab**
1. Open your project in FlutLab
2. In the file explorer (left side), navigate to: `android/app/`
3. Right-click on the `app` folder
4. Click "Upload files"
5. Select the `google-services.json` file you downloaded
6. Confirm upload

**Option B: If Using Local Files**
1. Copy `google-services.json` from Downloads
2. Paste it into: `C:\Users\ANSH SINGH\Desktop\fluttersprint\android\app\`
3. The file should be at: `android/app/google-services.json`

### Step 4: Skip the SDK Instructions

Firebase will show you some code to add. **You can skip this** because your project already has Firebase configured in `pubspec.yaml` and the Android build files.

Just click **"Next"** → **"Continue to console"**

---

## Part 3: Setup Web App (For FlutLab Web Preview) (5 minutes)

### Step 1: Register Web App

1. **In Firebase Console**, click the **Web icon** (`</>`)
2. **Fill in the form:**
   - **App nickname:** `TPLN Web`
   - **Firebase Hosting:** Leave unchecked
3. **Click:** Register app

### Step 2: Copy Firebase Config

You'll see a code snippet like this:

```javascript
const firebaseConfig = {
  apiKey: "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  authDomain: "tpln-xxxxx.firebaseapp.com",
  projectId: "tpln-xxxxx",
  storageBucket: "tpln-xxxxx.appspot.com",
  messagingSenderId: "123456789012",
  appId: "1:123456789012:web:xxxxxxxxxxxxx"
};
```

**Copy this entire config object!**

### Step 3: Create Firebase Options File

1. **Create a new file** in your project: `lib/firebase_options.dart`
2. **Paste this code** (replace with YOUR config values):

```dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Replace these values with YOUR Firebase config!
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXX', // YOUR API KEY
    appId: '1:123456789012:web:xxxxxxxxxxxxx', // YOUR APP ID
    messagingSenderId: '123456789012', // YOUR SENDER ID
    projectId: 'tpln-xxxxx', // YOUR PROJECT ID
    authDomain: 'tpln-xxxxx.firebaseapp.com', // YOUR AUTH DOMAIN
    storageBucket: 'tpln-xxxxx.appspot.com', // YOUR STORAGE BUCKET
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXX', // YOUR ANDROID API KEY
    appId: '1:123456789012:android:xxxxxxxxxxxxx', // YOUR ANDROID APP ID
    messagingSenderId: '123456789012', // YOUR SENDER ID
    projectId: 'tpln-xxxxx', // YOUR PROJECT ID
    storageBucket: 'tpln-xxxxx.appspot.com', // YOUR STORAGE BUCKET
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXX', // YOUR IOS API KEY
    appId: '1:123456789012:ios:xxxxxxxxxxxxx', // YOUR IOS APP ID
    messagingSenderId: '123456789012', // YOUR SENDER ID
    projectId: 'tpln-xxxxx', // YOUR PROJECT ID
    storageBucket: 'tpln-xxxxx.appspot.com', // YOUR STORAGE BUCKET
    iosBundleId: 'com.tpln.app',
  );
}
```

**Important:** Replace all the `XXXXX` values with your actual Firebase config values!

---

## Part 4: Enable Firebase Services (5 minutes)

### Step 1: Enable Authentication

1. **In Firebase Console**, click **"Authentication"** in left menu
2. **Click:** "Get started"
3. **Click:** "Sign-in method" tab
4. **Click:** "Email/Password"
5. **Toggle ON:** "Email/Password"
6. **Click:** "Save"

### Step 2: Enable Firestore Database

1. **In Firebase Console**, click **"Firestore Database"** in left menu
2. **Click:** "Create database"
3. **Select:** "Start in test mode" (for development)
4. **Click:** "Next"
5. **Select location:** Choose closest to you (e.g., `asia-south1` for India)
6. **Click:** "Enable"
7. **Wait** 1-2 minutes for database creation

### Step 3: Configure Firestore Rules (Important!)

1. **Click:** "Rules" tab in Firestore
2. **Replace** the rules with this:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Contracts collection
    match /contracts/{contractId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        (resource.data.lenderId == request.auth.uid || 
         resource.data.borrowerId == request.auth.uid);
      allow delete: if request.auth != null && 
        resource.data.lenderId == request.auth.uid;
    }
    
    // Repayments collection
    match /repayments/{repaymentId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
    }
  }
}
```

3. **Click:** "Publish"

---

## Part 5: Verify Setup (2 minutes)

### Checklist:

✅ **Firebase project created**  
✅ **Android app registered**  
✅ **`google-services.json` downloaded and placed in `android/app/`**  
✅ **Web app registered**  
✅ **`firebase_options.dart` created with your config**  
✅ **Authentication enabled (Email/Password)**  
✅ **Firestore Database created**  
✅ **Firestore Rules configured**  

---

## 🎯 Quick Reference

### File Locations:

```
fluttersprint/
├── android/
│   └── app/
│       └── google-services.json  ← Android Firebase config
├── lib/
│   └── firebase_options.dart     ← Web/iOS Firebase config
└── pubspec.yaml                   ← Dependencies already configured
```

### Firebase Console URLs:

- **Main Console:** https://console.firebase.google.com/
- **Your Project:** https://console.firebase.google.com/project/YOUR-PROJECT-ID
- **Authentication:** https://console.firebase.google.com/project/YOUR-PROJECT-ID/authentication
- **Firestore:** https://console.firebase.google.com/project/YOUR-PROJECT-ID/firestore

---

## 🐛 Troubleshooting

### "Firebase not initialized"
- Check `firebase_options.dart` exists
- Verify `main.dart` calls `Firebase.initializeApp()`
- Make sure you replaced the placeholder values

### "google-services.json not found"
- Verify file is in `android/app/google-services.json`
- Check file name is exactly `google-services.json`
- Re-download from Firebase Console if needed

### "Permission denied" in Firestore
- Check Firestore Rules are published
- Verify user is authenticated before accessing data
- Check rules allow the operation you're trying

### "API key invalid"
- Double-check you copied the correct values
- Make sure no extra spaces or quotes
- Regenerate keys in Firebase Console if needed

---

## 🌟 You're All Set!

Your Firebase is now configured! You can:

✅ **Register users** with email/password  
✅ **Store contracts** in Firestore  
✅ **Track repayments** in real-time  
✅ **Verify data** with security rules  

---

## 📝 Next Steps

1. **Run your app** in FlutLab
2. **Test registration** with a test email
3. **Create a contract** and see it in Firestore Console
4. **Monitor data** in Firebase Console

**Happy Coding!** 🚀
