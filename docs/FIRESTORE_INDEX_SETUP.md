# Firestore Index Setup Guide

## 🔴 Problem: Missing Firestore Indexes

The "Error loading contracts" issue is caused by missing Firestore composite indexes. Firestore requires indexes for queries that use `where` + `orderBy` combinations.

## ✅ Solution: Create the Required Indexes

### **Method 1: Use the Auto-Generated Link (EASIEST)**

1. **Copy the URL** from the error message in the app (it's the long URL starting with `https://console.firebase.google.com/...`)

2. **Open the URL in your browser** - Firebase will automatically:
   - Take you to the Firebase Console
   - Pre-fill the index configuration
   - Show you a "Create Index" button

3. **Click "Create Index"**

4. **Wait 1-2 minutes** for the index to build (you'll see a progress indicator)

5. **Repeat for all tabs**:
   - Click on "Lending" tab → Copy the new URL → Create index
   - Click on "Borrowing" tab → Copy the new URL → Create index
   - Click on "All" tab → If it shows an error, create that index too

6. **Restart the app** (press `R` in the terminal or `q` then `flutter run`)

### **Method 2: Create Indexes Manually in Firebase Console**

1. **Go to Firebase Console**: https://console.firebase.google.com/

2. **Select your project**: `tpln-safe-lending`

3. **Navigate to**: Firestore Database → Indexes tab

4. **Click "Create Index"** and add these indexes:

#### Index 1: Lender Contracts
```
Collection ID: contracts
Fields to index:
  - lenderId (Ascending)
  - createdAt (Descending)
Query scope: Collection
```

#### Index 2: Borrower Contracts
```
Collection ID: contracts
Fields to index:
  - borrowerId (Ascending)
  - createdAt (Descending)
Query scope: Collection
```

#### Index 3: Contract Repayments
```
Collection ID: repayments
Fields to index:
  - contractId (Ascending)
  - paymentDate (Descending)
Query scope: Collection
```

#### Index 4: User Repayments
```
Collection ID: repayments
Fields to index:
  - payerId (Ascending)
  - paymentDate (Descending)
Query scope: Collection
```

5. **Wait for all indexes to build** (usually 1-2 minutes each)

6. **Restart the app**

### **Method 3: Using Firebase CLI (If Installed)**

If you have Firebase CLI installed:

```bash
cd Safe-Lending
firebase deploy --only firestore:indexes
```

The `firestore.indexes.json` file has already been created in your project.

## 📋 Verification

After creating the indexes:

1. **Check index status** in Firebase Console → Firestore → Indexes
2. All indexes should show "Enabled" (green checkmark)
3. **Restart the app** and navigate to Contracts tab
4. The "Lending" and "Borrowing" tabs should now load successfully

## 🎯 Why This Happened

Firestore requires indexes for queries that:
- Combine `where` clauses with `orderBy`
- Use multiple `orderBy` clauses
- Use inequality operators on different fields

Your app queries contracts like:
```dart
.where('lenderId', isEqualTo: userId)
.orderBy('createdAt', descending: true)
```

This requires a composite index on `(lenderId, createdAt)`.

## ⚡ Quick Fix (Recommended)

**Just use Method 1** - it's the fastest:
1. Copy the URL from the error in the app
2. Open it in browser
3. Click "Create Index"
4. Wait 1-2 minutes
5. Repeat for each tab that shows an error
6. Restart the app

That's it! 🎉
