import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  // Mock list of existing clinicians - in real app, this would come from API
  final List<Map<String, String>> _clinicians = [
    {'id': 'clinician_1', 'name': 'Dr. Smith', 'email': 'dr.smith@example.com'},
    {'id': 'clinician_2', 'name': 'Dr. Johnson', 'email': 'dr.johnson@example.com'},
    {'id': 'clinician_3', 'name': 'Dr. Williams', 'email': 'dr.williams@example.com'},
  ];

  List<Map<String, String>> get clinicians => _clinicians;

  // Get clinician by ID
  Map<String, String>? getClinicianById(String id) {
    return _clinicians.firstWhere((clinician) => clinician['id'] == id);
  }

  // Get clinician by name
  Map<String, String>? getClinicianByName(String name) {
    return _clinicians.firstWhere((clinician) => clinician['name'] == name);
  }

  Future<void> login(String email, String password, UserRole role) async {
    // Simulate login - in real app, call API
    // For demo, create a user
    _currentUser = User(
      id: '1',
      name: 'John Doe',
      email: email,
      role: role,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', _currentUser!.toJson().toString());

    notifyListeners();
  }

  Future<void> register(String name, String email, String password, UserRole role, {String? doctorName}) async {
    // Validate doctor exists if doctorName is provided
    String? doctorId;
    if (doctorName != null && doctorName.isNotEmpty) {
      final clinician = getClinicianByName(doctorName);
      if (clinician == null) {
        throw Exception('Doctor "$doctorName" not found. Please ensure the doctor has an account in the app.');
      }
      doctorId = clinician['id'];
    }

    // Simulate register
    _currentUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      role: role,
      doctorId: doctorId,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', _currentUser!.toJson().toString());

    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    notifyListeners();
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');
    if (userString != null) {
      // Parse user - simplified
      _currentUser = User(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        role: UserRole.patient,
      );
    }
  }
}