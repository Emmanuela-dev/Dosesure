# DoseSure - Firebase Quick Start

## 🚀 Quick Setup (5 minutes)

Your app is ready for Firebase! Follow these steps to get started:

### 1. Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### 2. Login to Firebase
```bash
firebase login
```
(If you don't have Firebase CLI, install it from https://firebase.google.com/docs/cli)

### 3. Configure Firebase
```bash
cd "C:\Users\Emmanuela\Desktop\hackathon\Dose sure\dosesure"
flutterfire configure
```

This command will:
- Prompt you to select or create a Firebase project
- Register your app with Firebase
- Generate `lib/firebase_options.dart` with your configuration
- Configure Android and iOS automatically

### 4. Enable Firebase Services

Go to [Firebase Console](https://console.firebase.google.com/):

#### Authentication
1. Click **Authentication** → **Get Started**
2. Select **Sign-in method** tab
3. Enable **Email/Password**

#### Firestore Database
1. Click **Firestore Database** → **Create database**
2. Choose **Start in test mode** (for development)
3. Select a location

### 5. Run Your App
```bash
flutter run
```

## ✅ What's Already Done

- ✅ Firebase dependencies added to pubspec.yaml
- ✅ Firebase services created (Auth & Firestore)
- ✅ Providers updated to use Firebase
- ✅ Main.dart configured to initialize Firebase
- ✅ Data models ready with JSON serialization

## 📱 Features Now Available

### Authentication
- User registration (patients & clinicians)
- Email/password login
- Password reset
- Doctor-patient linking
- Secure logout

### Data Storage
- **Medications**: Add, edit, delete with real-time sync
- **Dose Logs**: Track medication adherence
- **Side Effects**: Record and monitor
- **Herbal Uses**: Manage supplements
- **User Profiles**: Store user information

### Real-time Updates
- All data syncs automatically across devices
- Changes appear instantly in the UI
- Works offline with automatic sync when online

## 🔐 Security

The app uses Firebase Authentication for user management. Before production:

1. Update Firestore Security Rules (see `FIREBASE_SETUP.md`)
2. Enable only necessary sign-in methods
3. Set up proper password requirements
4. Configure email verification (optional)

## 📚 Documentation

- **FIREBASE_SETUP.md** - Detailed setup instructions
- **FIREBASE_INTEGRATION.md** - How to use Firebase in your code
- **README.md** - Project overview

## 🧪 Testing

### Create Test Users

1. **Create a Clinician:**
   - Run the app
   - Select "I'm a Healthcare Provider"
   - Register with email: `doctor@test.com`
   - Password: `test123`
   - Name: `Dr. Test`

2. **Create a Patient:**
   - Select "I'm a Patient"
   - Register with email: `patient@test.com`
   - Password: `test123`
   - Name: `Test Patient`
   - Doctor Name: `Dr. Test` (must match clinician name)

3. **Test Features:**
   - Add medications
   - Log doses
   - Report side effects
   - View dashboard
   - Check data in Firebase Console

## 🚨 Troubleshooting

### App crashes on startup?
- Make sure you ran `flutterfire configure`
- Check that `lib/firebase_options.dart` exists and has real values (not placeholders)

### "Permission denied" errors?
- Go to Firebase Console → Firestore Database → Rules
- Make sure you're in **test mode** (allows all reads/writes for 30 days)

### Authentication not working?
- Verify Email/Password is enabled in Firebase Console
- Check that you're using a valid email format
- Password must be at least 6 characters

### Can't see data in Firestore?
- Check Firebase Console → Firestore Database
- Look for collections: `users`, `medications`, `doseLogs`, etc.
- Try adding data through the app first

## 📞 Support

Need help?
1. Check the error in VS Code terminal
2. Look at Firebase Console for error messages
3. Review the documentation files
4. Check Firebase Console → Usage for quota/limits

## 🎯 Next Steps

1. ✅ Configure Firebase (you're doing this now!)
2. ⬜ Test registration and login
3. ⬜ Add some medications
4. ⬜ Test dose logging
5. ⬜ Set up production security rules
6. ⬜ Deploy your app

---

**Current Status**: Firebase integration complete, waiting for configuration! 🎉

Run `flutterfire configure` to get started.
