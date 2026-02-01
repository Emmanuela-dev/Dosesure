# Firebase Setup Instructions for DoseSure

This guide will help you configure Firebase for your DoseSure application.

## Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project" or select an existing project
3. Enter your project name (e.g., "DoseSure")
4. Follow the setup wizard

## Step 2: Register Your App

### For Android:
1. In Firebase Console, click the Android icon
2. Enter your Android package name: `com.example.dosesure` (or your actual package name from `android/app/build.gradle.kts`)
3. Download `google-services.json`
4. Place it in: `android/app/google-services.json`

### For iOS:
1. In Firebase Console, click the iOS icon
2. Enter your iOS bundle ID: `com.example.dosesure` (or your actual bundle ID from `ios/Runner/Info.plist`)
3. Download `GoogleService-Info.plist`
4. Place it in: `ios/Runner/GoogleService-Info.plist`

### For Web:
1. In Firebase Console, click the Web icon
2. Register your web app
3. Copy the Firebase configuration
4. You'll need to create a `firebase_options.dart` file (see Step 4)

## Step 3: Enable Firebase Services

In Firebase Console, enable the following services:

### Authentication
1. Go to Authentication → Sign-in method
2. Enable "Email/Password"
3. (Optional) Enable other providers as needed

### Cloud Firestore
1. Go to Firestore Database
2. Click "Create database"
3. Start in **test mode** for development (or production mode for production)
4. Choose a location closest to your users

### (Optional) Storage
1. Go to Storage
2. Click "Get started"
3. Start in **test mode** for development

## Step 4: Install FlutterFire CLI and Generate Configuration

The easiest way to configure Firebase for all platforms is using FlutterFire CLI:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Login to Firebase
firebase login

# Configure Firebase for your Flutter app
flutterfire configure
```

This will:
- Create `firebase_options.dart` with your configuration
- Update Android and iOS projects automatically
- Register your app with Firebase

## Step 5: Update Android Configuration

Add the following to `android/build.gradle.kts`:

```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

Add to `android/app/build.gradle.kts`:

```kotlin
plugins {
    // ... existing plugins
    id("com.google.gms.google-services")
}
```

## Step 6: Update iOS Configuration (if needed)

The FlutterFire CLI should handle most iOS configuration, but verify:

1. `GoogleService-Info.plist` is in `ios/Runner/`
2. It's included in Xcode project

## Step 7: Install Dependencies

Run in your project directory:

```bash
flutter pub get
```

## Step 8: Test Firebase Connection

Run your app:

```bash
flutter run
```

The app should initialize Firebase without errors.

## Firestore Security Rules

For development, you can use these rules (update for production):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User documents - users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      // Clinicians can read their patients' data
      allow read: if request.auth != null && 
                     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 0; // 0 = clinician
    }
    
    // Medications - users can manage their own
    match /medications/{medicationId} {
      allow read, write: if request.auth != null && 
                            request.auth.uid == resource.data.userId;
    }
    
    // Dose logs - users can manage their own
    match /doseLogs/{doseLogId} {
      allow read, write: if request.auth != null && 
                            request.auth.uid == resource.data.userId;
    }
    
    // Side effects - users can manage their own
    match /sideEffects/{sideEffectId} {
      allow read, write: if request.auth != null && 
                            request.auth.uid == resource.data.userId;
    }
    
    // Herbal uses - users can manage their own
    match /herbalUses/{herbalUseId} {
      allow read, write: if request.auth != null && 
                            request.auth.uid == resource.data.userId;
    }
  }
}
```

## Troubleshooting

### Common Issues:

1. **"Firebase not initialized" error**
   - Make sure `Firebase.initializeApp()` is called in `main()`
   - Verify `google-services.json` and `GoogleService-Info.plist` are in the correct locations

2. **Build errors on Android**
   - Clean and rebuild: `flutter clean && flutter pub get`
   - Check that `google-services` plugin is added to `build.gradle.kts`

3. **iOS build errors**
   - Run `pod install` in the `ios` directory
   - Clean Xcode build folder

4. **Authentication errors**
   - Verify Email/Password is enabled in Firebase Console
   - Check Firebase Auth configuration

## Next Steps

1. Create some test users in Firebase Console
2. Test registration and login
3. Verify data is being stored in Firestore
4. Update security rules for production before deployment

## Support

For more information:
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
