# TPLN - Firebase Setup Guide

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: **TPLN** (or your preferred name)
4. Disable Google Analytics (optional)
5. Click "Create project"

## Step 2: Add Android App

1. In Firebase Console, click the Android icon
2. Enter package name: `com.tpln.app`
3. Enter app nickname: **TPLN Android**
4. Click "Register app"
5. Download `google-services.json`
6. Place it in: `android/app/google-services.json`

## Step 3: Enable Authentication

1. In Firebase Console, go to **Authentication**
2. Click "Get started"
3. Enable **Email/Password** sign-in method
4. Click "Save"

## Step 4: Create Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click "Create database"
3. Select **Start in test mode** (for development)
4. Choose your preferred location
5. Click "Enable"

## Step 5: Set Up Security Rules

### Firestore Security Rules

Go to **Firestore Database** → **Rules** and paste:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow create: if request.auth.uid == userId;
      allow update: if request.auth.uid == userId;
      allow delete: if false;
    }
    
    // Contracts collection
    match /contracts/{contractId} {
      allow read: if request.auth != null && 
        (resource.data.lenderId == request.auth.uid || 
         resource.data.borrowerId == request.auth.uid);
      
      allow create: if request.auth != null && 
        request.resource.data.lenderId == request.auth.uid;
      
      allow update: if request.auth != null && 
        (resource.data.lenderId == request.auth.uid || 
         resource.data.borrowerId == request.auth.uid);
      
      allow delete: if false;
    }
    
    // Repayments collection
    match /repayments/{repaymentId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if false;
      allow delete: if false;
    }
  }
}
```

Click **Publish**

## Step 6: Install Flutter & Dependencies

### Install Flutter SDK

1. Download Flutter SDK from: https://docs.flutter.dev/get-started/install/windows
2. Extract to `C:\src\flutter`
3. Add to PATH: `C:\src\flutter\bin`
4. Run in terminal:
   ```bash
   flutter doctor
   ```

### Install Dependencies

In the project directory, run:

```bash
flutter pub get
```

## Step 7: Run the App

### Using Android Emulator

1. Open Android Studio
2. Create/Start an emulator (AVD Manager)
3. In project directory, run:
   ```bash
   flutter run
   ```

### Using Physical Device

1. Enable Developer Options on your Android device
2. Enable USB Debugging
3. Connect device via USB
4. Run:
   ```bash
   flutter devices
   flutter run
   ```

## Step 8: Build APK (Optional)

To build a release APK:

```bash
flutter build apk --release
```

The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

## Troubleshooting

### Firebase not initialized

Make sure `google-services.json` is in the correct location:
```
android/app/google-services.json
```

### Gradle build errors

Update `android/gradle/wrapper/gradle-wrapper.properties`:
```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.0-all.zip
```

### Permission errors

Make sure `AndroidManifest.xml` has internet permission:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

## Testing the App

### Test User Registration

1. Launch the app
2. Click "Register"
3. Fill in details:
   - Full Name: Test User
   - Email: test@example.com
   - Phone: 1234567890
   - Password: Test@123
4. Click "Register"
5. RSA keys will be generated automatically

### Test Contract Creation

1. Register two users (lender and borrower)
2. Login as lender
3. Click "Create Contract"
4. Enter borrower's email
5. Fill in loan details
6. Click "Create Contract"
7. Logout and login as borrower
8. View pending contract
9. Click "Sign Contract"
10. Contract becomes active

### Test Repayment

1. Login as borrower
2. Open active contract
3. Click "Make Repayment"
4. Enter amount
5. Confirm payment
6. View repayment history

## Security Notes

- Private keys are stored in device's secure storage
- Never share your private key
- Contracts are cryptographically signed
- All data is encrypted in transit
- Firestore rules prevent unauthorized access

## Support

For issues or questions:
- Check Firebase Console for errors
- Run `flutter doctor` to verify setup
- Check Firestore security rules
- Verify `google-services.json` is present
