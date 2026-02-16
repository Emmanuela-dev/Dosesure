import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/drug.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();
  
  User? _currentUser;
  List<User> _clinicians = [];
  List<Drug> _drugs = [];
  bool _isLoading = false;

  User? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;
  
  bool get isLoading => _isLoading;

  List<User> get clinicians => _clinicians;

  List<Drug> get drugs => _drugs;

  // Initialize auth state listener
  void initAuthStateListener() {
    _authService.authStateChanges.listen((firebaseUser) async {
      debugPrint('AuthProvider.authStateListener - Firebase user changed: ${firebaseUser?.uid}');
      if (firebaseUser != null) {
        final user = await _firestoreService.getUser(firebaseUser.uid);
        debugPrint('AuthProvider.authStateListener - Fetched user from Firestore: ${user?.name}');
        // Only update if we don't already have the user loaded
        if (_currentUser == null || _currentUser!.id != firebaseUser.uid) {
          _currentUser = user;
          notifyListeners();
        }
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  // Load clinicians from Firestore
  Future<void> loadClinicians() async {
    try {
      debugPrint('AuthProvider.loadClinicians - Loading clinicians...');
      _clinicians = await _firestoreService.getClinicians();
      debugPrint('AuthProvider.loadClinicians - Loaded ${_clinicians.length} clinicians');
      notifyListeners();
    } catch (e) {
      debugPrint('AuthProvider.loadClinicians - Error: $e');
      rethrow;
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

  // Load drugs from Firestore
  Future<void> loadDrugs() async {
    try {
      debugPrint('AuthProvider.loadDrugs - Loading drugs from Firestore...');
      _drugs = await _firestoreService.getAllDrugs();
      debugPrint('AuthProvider.loadDrugs - Loaded ${_drugs.length} drugs');
      for (final drug in _drugs) {
        debugPrint('AuthProvider.loadDrugs - Drug: ${drug.name} (${drug.category})');
      }
      notifyListeners();
    } catch (e) {
      debugPrint('AuthProvider.loadDrugs - Error: $e');
      rethrow;
    }
  }

  // Initialize default drugs (call on app start)
  Future<void> initializeDefaultDrugs() async {
    try {
      debugPrint('AuthProvider.initializeDefaultDrugs - Starting initialization...');
      await _firestoreService.initializeDefaultDrugs();
      // Reload drugs after initialization
      await loadDrugs();
      debugPrint('AuthProvider.initializeDefaultDrugs - Complete');
    } catch (e) {
      debugPrint('AuthProvider.initializeDefaultDrugs - Error: $e');
    }
  }

  Future<void> login(String email, String password, UserRole role) async {
    try {
      _isLoading = true;
      notifyListeners();

      _currentUser = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
        defaultRole: role, // Pass the expected role for auto-creation
      );

      debugPrint('AuthProvider.login - User logged in: ${_currentUser?.name}, Email: ${_currentUser?.email}');

      // If role doesn't match, update it in Firestore
      if (_currentUser!.role != role) {
        debugPrint('AuthProvider.login - Role mismatch, updating role from ${_currentUser!.role} to $role');
        _currentUser = User(
          id: _currentUser!.id,
          name: _currentUser!.name,
          email: _currentUser!.email,
          role: role,
          doctorId: _currentUser!.doctorId,
        );
        await _firestoreService.updateUser(_currentUser!);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', _currentUser!.id);

      _isLoading = false;
      notifyListeners();
      debugPrint('AuthProvider.login - Final currentUser name: ${_currentUser?.name}');
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

  // Alias for logout
  Future<void> signOut() async {
    await logout();
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