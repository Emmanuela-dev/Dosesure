import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import 'firestore_service.dart';

class FirebaseAuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get current Firebase user
  firebase_auth.User? get currentFirebaseUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  // Register new user with email and password
  Future<User> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? doctorId,
  }) async {
    try {
      // Create Firebase auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(name);

      // Create user document in Firestore
      final user = User(
        id: credential.user!.uid,
        name: name,
        email: email,
        role: role,
        doctorId: doctorId,
      );

      await _firestoreService.createUser(user);

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with email and password
  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
    UserRole? defaultRole,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('Firebase Auth - User UID: ${credential.user!.uid}');
      debugPrint('Firebase Auth - Display Name: ${credential.user!.displayName}');

      // Get user data from Firestore
      var user = await _firestoreService.getUser(credential.user!.uid);
      
      debugPrint('Firestore User - Name: ${user?.name}, Email: ${user?.email}, Role: ${user?.role}');
      
      // If user document doesn't exist in Firestore, create it
      if (user == null) {
        debugPrint('User not found in Firestore, creating new document...');
        user = User(
          id: credential.user!.uid,
          name: credential.user!.displayName ?? 'User',
          email: credential.user!.email!,
          role: defaultRole ?? UserRole.patient, // Use specified role or default to patient
          doctorId: null,
        );
        
        await _firestoreService.createUser(user);
      } else if (user.name == 'User' && credential.user!.displayName != null && credential.user!.displayName!.isNotEmpty) {
        // If Firestore has default name but Firebase Auth has display name, update it
        debugPrint('Updating user name from Firebase Auth displayName: ${credential.user!.displayName}');
        user = User(
          id: user.id,
          name: credential.user!.displayName!,
          email: user.email,
          role: user.role,
          doctorId: user.doctorId,
        );
        await _firestoreService.updateUser(user);
      }

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      // Handle other exceptions (Firestore errors, network issues, etc.)
      debugPrint('Login error: $e');
      throw 'Login failed: ${e.toString()}';
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Delete user data from Firestore first
        await _firestoreService.deleteUser(user.uid);
        // Then delete Firebase auth account
        await user.delete();
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
