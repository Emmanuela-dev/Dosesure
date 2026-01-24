import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

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

  Future<void> register(String name, String email, String password, UserRole role) async {
    // Simulate register
    _currentUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      role: role,
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