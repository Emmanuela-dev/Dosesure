import 'dart:async';
import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../models/dose_log.dart';
import '../models/side_effect.dart';
import '../models/herbal_use.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class HealthDataProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();
  
  List<Medication> _medications = [];
  List<DoseLog> _doseLogs = [];
  List<SideEffect> _sideEffects = [];
  List<HerbalUse> _herbalUses = [];
  
  StreamSubscription<List<Medication>>? _medicationsSubscription;
  StreamSubscription<List<DoseLog>>? _doseLogsSubscription;
  StreamSubscription<List<SideEffect>>? _sideEffectsSubscription;
  StreamSubscription<List<HerbalUse>>? _herbalUsesSubscription;

  bool _isLoading = false;

  List<Medication> get medications => _medications;
  List<DoseLog> get doseLogs => _doseLogs;
  List<SideEffect> get sideEffects => _sideEffects;
  List<HerbalUse> get herbalUses => _herbalUses;
  bool get isLoading => _isLoading;

  // Initialize listeners for a user
  void initializeForUser(String userId) {
    // Cancel existing subscriptions
    disposeSubscriptions();

    // Subscribe to medications
    _medicationsSubscription = _firestoreService
        .getActiveMedicationsForUser(userId)
        .listen((medications) {
      _medications = medications;
      // Schedule reminders for all active medications
      _notificationService.scheduleAllMedicationReminders(medications);
      notifyListeners();
    });

    // Subscribe to dose logs
    _doseLogsSubscription = _firestoreService
        .getDoseLogsForUser(userId)
        .listen((doseLogs) {
      _doseLogs = doseLogs;
      notifyListeners();
    });

    // Subscribe to side effects
    _sideEffectsSubscription = _firestoreService
        .getSideEffectsForUser(userId)
        .listen((sideEffects) {
      _sideEffects = sideEffects;
      notifyListeners();
    });

    // Subscribe to herbal uses
    _herbalUsesSubscription = _firestoreService
        .getHerbalUsesForUser(userId)
        .listen((herbalUses) {
      _herbalUses = herbalUses;
      notifyListeners();
    });
  }

  // Dispose subscriptions
  void disposeSubscriptions() {
    _medicationsSubscription?.cancel();
    _doseLogsSubscription?.cancel();
    _sideEffectsSubscription?.cancel();
    _herbalUsesSubscription?.cancel();
  }

  @override
  void dispose() {
    disposeSubscriptions();
    super.dispose();
  }

  // Get today's medications
  List<Medication> getTodaysMedications() {
    return _medications.where((med) => med.isActive).toList();
  }

  // Get dose logs for a medication
  List<DoseLog> getDoseLogsForMedication(String medicationId) {
    return _doseLogs.where((log) => log.medicationId == medicationId).toList();
  }

  // Get side effects for a medication
  List<SideEffect> getSideEffectsForMedication(String medicationId) {
    return _sideEffects.where((effect) => effect.medicationId == medicationId).toList();
  }

  // Add medication
  Future<void> addMedication(String userId, Medication medication) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _firestoreService.addMedication(userId, medication);
      
      // Schedule medication reminders
      await _notificationService.scheduleMedicationReminders(medication);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update medication
  Future<void> updateMedication(Medication medication) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _firestoreService.updateMedication(medication);
      
      // Reschedule medication reminders (will cancel existing and create new ones)
      await _notificationService.scheduleMedicationReminders(medication);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Delete medication
  Future<void> deleteMedication(String medicationId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _firestoreService.deleteMedication(medicationId);
      
      // Cancel medication reminders
      await _notificationService.cancelMedicationReminders(medicationId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Log dose
  Future<void> logDose(String userId, DoseLog doseLog) async {
    try {
      await _firestoreService.addDoseLog(userId, doseLog);
    } catch (e) {
      rethrow;
    }
  }

  // Update dose log
  Future<void> updateDoseLog(DoseLog doseLog) async {
    try {
      await _firestoreService.updateDoseLog(doseLog);
    } catch (e) {
      rethrow;
    }
  }

  // Add side effect
  Future<void> addSideEffect(String userId, SideEffect sideEffect) async {
    try {
      await _firestoreService.addSideEffect(userId, sideEffect);
    } catch (e) {
      rethrow;
    }
  }

  // Add herbal use
  Future<void> addHerbalUse(String userId, HerbalUse herbalUse) async {
    try {
      await _firestoreService.addHerbalUse(userId, herbalUse);
    } catch (e) {
      rethrow;
    }
  }

  // Update herbal use
  Future<void> updateHerbalUse(HerbalUse herbalUse) async {
    try {
      await _firestoreService.updateHerbalUse(herbalUse);
    } catch (e) {
      rethrow;
    }
  }

  // Delete herbal use
  Future<void> deleteHerbalUse(String herbalId) async {
    try {
      await _firestoreService.deleteHerbalUse(herbalId);
    } catch (e) {
      rethrow;
    }
  }

  // Get adherence percentage
  double getAdherencePercentage() {
    if (_doseLogs.isEmpty) return 0.0;
    final takenDoses = _doseLogs.where((log) => log.taken).length;
    return (takenDoses / _doseLogs.length) * 100;
  }

  // Get adherence rate for date range
  Future<double> getAdherenceRate(String userId, DateTime start, DateTime end) async {
    try {
      return await _firestoreService.getAdherenceRate(userId, start, end);
    } catch (e) {
      return 0.0;
    }
  }

  // Get dose logs for date range
  Future<List<DoseLog>> getDoseLogsForDateRange(
      String userId, DateTime start, DateTime end) async {
    try {
      return await _firestoreService.getDoseLogsForDateRange(userId, start, end);
    } catch (e) {
      return [];
    }
  }
}