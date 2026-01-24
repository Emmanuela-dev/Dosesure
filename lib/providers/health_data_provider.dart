import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../models/dose_log.dart';
import '../models/side_effect.dart';
import '../models/herbal_use.dart';

class HealthDataProvider with ChangeNotifier {
  final List<Medication> _medications = [
    Medication(
      id: '1',
      name: 'Aspirin',
      dosage: '100mg',
      frequency: 'Once daily',
      times: ['08:00'],
      instructions: 'Take with food',
      startDate: DateTime.now().subtract(const Duration(days: 30)),
    ),
    Medication(
      id: '2',
      name: 'Metformin',
      dosage: '500mg',
      frequency: 'Twice daily',
      times: ['08:00', '20:00'],
      instructions: 'Take with meals',
      startDate: DateTime.now().subtract(const Duration(days: 30)),
    ),
    Medication(
      id: '3',
      name: 'Lisinopril',
      dosage: '10mg',
      frequency: 'Once daily',
      times: ['08:00'],
      instructions: 'Take in the morning',
      startDate: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ];

  final List<DoseLog> _doseLogs = [];
  final List<SideEffect> _sideEffects = [];
  final List<HerbalUse> _herbalUses = [];

  List<Medication> get medications => _medications;
  List<DoseLog> get doseLogs => _doseLogs;
  List<SideEffect> get sideEffects => _sideEffects;
  List<HerbalUse> get herbalUses => _herbalUses;

  // Get today's medications
  List<Medication> getTodaysMedications() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
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
  void addMedication(Medication medication) {
    _medications.add(medication);
    notifyListeners();
  }

  // Update medication
  void updateMedication(Medication updatedMedication) {
    final index = _medications.indexWhere((med) => med.id == updatedMedication.id);
    if (index != -1) {
      _medications[index] = updatedMedication;
      notifyListeners();
    }
  }

  // Delete medication
  void deleteMedication(String medicationId) {
    _medications.removeWhere((med) => med.id == medicationId);
    notifyListeners();
  }

  // Log dose
  void logDose(DoseLog doseLog) {
    _doseLogs.add(doseLog);
    notifyListeners();
  }

  // Update dose log
  void updateDoseLog(DoseLog updatedLog) {
    final index = _doseLogs.indexWhere((log) => log.id == updatedLog.id);
    if (index != -1) {
      _doseLogs[index] = updatedLog;
      notifyListeners();
    }
  }

  // Add side effect
  void addSideEffect(SideEffect sideEffect) {
    _sideEffects.add(sideEffect);
    notifyListeners();
  }

  // Add herbal use
  void addHerbalUse(HerbalUse herbalUse) {
    _herbalUses.add(herbalUse);
    notifyListeners();
  }

  // Update herbal use
  void updateHerbalUse(HerbalUse updatedHerbal) {
    final index = _herbalUses.indexWhere((herbal) => herbal.id == updatedHerbal.id);
    if (index != -1) {
      _herbalUses[index] = updatedHerbal;
      notifyListeners();
    }
  }

  // Delete herbal use
  void deleteHerbalUse(String herbalId) {
    _herbalUses.removeWhere((herbal) => herbal.id == herbalId);
    notifyListeners();
  }

  // Get adherence percentage
  double getAdherencePercentage() {
    if (_doseLogs.isEmpty) return 0.0;
    final takenDoses = _doseLogs.where((log) => log.taken).length;
    return (takenDoses / _doseLogs.length) * 100;
  }
}