# Firestore Setup Required

## Issue
Cloud Firestore API is not enabled for your project `bitelab-ab051`.

## Quick Fix

### Step 1: Enable Firestore API
Click this link and click "Enable":
https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=bitelab-ab051

**OR**

1. Go to https://console.firebase.google.com
2. Select project "bitelab-ab051"
3. Click "Firestore Database" in the left sidebar
4. Click "Create Database"
5. Choose a location (e.g., us-central, europe-west, asia-southeast)
6. Select "Start in test mode" for now
7. Click "Enable"

### Step 2: Set Firestore Rules
Once Firestore is created:

1. In Firebase Console, go to Firestore Database → Rules
2. Replace the rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users full access (for testing)
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

3. Click "Publish"

### Step 3: Wait & Restart
- Wait 2-3 minutes for the changes to propagate
- Stop your Flutter app (Ctrl+C in terminal)
- Run `flutter run` again
- The app should now work!

## What This Does
- Enables Cloud Firestore database for your Firebase project
- Allows authenticated users to read/write data
- Stores user accounts, medications, dose logs, side effects, etc.

## Note
The current rules allow any authenticated user to access all data. 
For production, use the more secure rules in `firestore.rules` file.
