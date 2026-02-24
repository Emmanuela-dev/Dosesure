# Drug Loading Fix Guide

## Problem
Drugs not loading from Firestore database - showing "Error loading drugs" or empty dropdown.

## Quick Fix Steps

### Step 1: Test Database Connection
```bash
cd dosesure
flutter run scripts/test_database.dart
```

This will tell you:
- ✅ If Firebase is connected
- ✅ How many drugs are in database
- ✅ If drugs can be parsed correctly
- ❌ What's wrong if it fails

### Step 2: Populate Database (if empty)
```bash
flutter run scripts/populate_drugs.dart
```

### Step 3: Check Firestore Rules

Your rules should allow reading drugs:
```javascript
match /drugs/{drugId} {
  allow read: if true;  // ✅ This is correct
  allow write: if isAuthenticated();
}
```

### Step 4: Verify in Firebase Console

1. Go to https://console.firebase.google.com
2. Select your project
3. Click "Firestore Database"
4. Look for "drugs" collection
5. Should see 26 documents

### Step 5: Check App Logs

When opening prescription screen, you should see:
```
AuthProvider.loadDrugs - Loading drugs from database...
DrugDatabaseService.getAllDrugs - Found 26 documents
DrugDatabaseService.getAllDrugs - Successfully parsed 26 drugs
AuthProvider.loadDrugs - Loaded 26 drugs
```

## Common Issues & Solutions

### Issue 1: "No drugs found"
**Solution:** Run populate script
```bash
flutter run scripts/populate_drugs.dart
```

### Issue 2: "Permission denied"
**Solution:** Check Firestore rules allow read:
```javascript
match /drugs/{drugId} {
  allow read: if true;
}
```

### Issue 3: "Error parsing drug"
**Solution:** Check drug document structure in Firestore. Each drug needs:
- id (string)
- name (string)
- category (string)
- genericName (string)
- isHighAlert (boolean)
- commonDosages (array)
- interactions (array)
- warnings (string)

### Issue 4: "Firebase not initialized"
**Solution:** Run flutterfire configure
```bash
flutterfire configure
```

### Issue 5: Dropdown still empty after loading
**Solution:** 
1. Check console logs for actual drug count
2. Restart the app completely
3. Clear app data and reinstall

## Manual Verification

### Check if drugs exist in Firestore:
```dart
// In Firebase Console > Firestore
// You should see:
drugs/
  ├── amoxicillin
  ├── warfarin
  ├── ibuprofen
  └── ... (23 more)
```

### Check drug document structure:
```json
{
  "id": "amoxicillin",
  "name": "Amoxicillin",
  "genericName": "Amoxicillin",
  "category": "antibiotic",
  "isHighAlert": false,
  "commonDosages": ["250mg", "500mg", "875mg"],
  "interactions": ["warfarin", "methotrexate"],
  "warnings": "Complete full course. Check for penicillin allergy."
}
```

## Still Not Working?

1. **Clear app data:**
   - Uninstall app
   - Reinstall app
   - Try again

2. **Check internet connection:**
   - Firestore requires active internet
   - Check device/emulator connection

3. **Verify Firebase project:**
   - Ensure project is active
   - Check billing (if applicable)
   - Verify Firestore is enabled

4. **Check app logs:**
   ```bash
   flutter run --verbose
   ```
   Look for errors related to Firestore or drug loading

## Success Indicators

✅ Test script shows 26 drugs
✅ Prescription screen shows category dropdown
✅ Selecting category shows drug dropdown
✅ Drugs have warnings and dosages
✅ No errors in console

## Need More Help?

Run the test script and share the output:
```bash
flutter run scripts/test_database.dart > test_output.txt
```
