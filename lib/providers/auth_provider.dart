import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();
  
  User? _currentUser;
  List<User> _clinicians = [];
  bool _isLoading = false;

  User? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;
  
  bool get isLoading => _isLoading;

  List<User> get clinicians => _clinicians;

  // Initialize auth state listener
  void initAuthStateListener() {
    _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        _currentUser = await _firestoreService.getUser(firebaseUser.uid);
        notifyListeners();
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  // Load clinicians from Firestore
  Future<void> loadClinicians() async {
    try {
      _clinicians = await _firestoreService.getClinicians();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading clinicians: $e');
    }
  }

  // Get clinician by ID
  User? getClinicianById(String id) {
    try {
      return _clinicians.firstWhere((clinician) => clinician.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get clinician by name
  User? getClinicianByName(String name) {
    try {
      return _clinicians.firstWhere((clinician) => clinician.name == name);
    } catch (e) {
      return null;
    }
  }

  Future<void> login(String email, String password, UserRole role) async {
    try {
      _isLoading = true;
      notifyListeners();

      _currentUser = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Verify role matches
      if (_currentUser!.role != role) {
        await _authService.signOut();
        _currentUser = null;
        throw Exception('Invalid credentials for this user type');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', _currentUser!.id);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> register(String name, String email, String password, UserRole role, {String? doctorName}) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Validate doctor exists if doctorName is provided
      String? doctorId;
      if (doctorName != null && doctorName.isNotEmpty) {
        // Clinicians should already be loaded, but check just in case
        final clinician = getClinicianByName(doctorName);
        if (clinician == null) {
          throw Exception('Doctor "$doctorName" not found. Please ensure the doctor has an account in the app.');
        }
        doctorId = clinician.id;
      }

      _currentUser = await _authService.registerWithEmailAndPassword(
        name: name,
        email: email,
        password: password,
        role: role,
        doctorId: doctorId,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', _currentUser!.id);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.signOut();
      _currentUser = null;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId != null) {
        _currentUser = await _firestoreService.getUser(userId);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
    } catch (e) {
      rethrow;
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      await _authService.deleteAccount();
      _currentUser = null;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}