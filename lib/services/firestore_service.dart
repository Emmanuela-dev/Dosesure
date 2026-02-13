import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/medication.dart';
import '../models/dose_log.dart';
import '../models/side_effect.dart';
import '../models/herbal_use.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _medicationsCollection => _firestore.collection('medications');
  CollectionReference get _doseLogsCollection => _firestore.collection('doseLogs');
  CollectionReference get _sideEffectsCollection => _firestore.collection('sideEffects');
  CollectionReference get _herbalUsesCollection => _firestore.collection('herbalUses');

  // ==================== USER METHODS ====================

  // Create user document
  Future<void> createUser(User user) async {
    await _usersCollection.doc(user.id).set(user.toJson());
  }

  // Get user by ID
  Future<User?> getUser(String userId) async {
    final doc = await _usersCollection.doc(userId).get();
    if (!doc.exists) {
      debugPrint('FirestoreService.getUser - Document does not exist for userId: $userId');
      return null;
    }
    final data = doc.data() as Map<String, dynamic>;
    // Ensure the id is set from the document ID
    data['id'] = doc.id;
    debugPrint('FirestoreService.getUser - Raw data: $data');
    return User.fromJson(data);
  }

  // Update user
  Future<void> updateUser(User user) async {
    await _usersCollection.doc(user.id).update(user.toJson());
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    await _usersCollection.doc(userId).delete();
  }

  // Get all clinicians
  Future<List<User>> getClinicians() async {
    final snapshot = await _usersCollection
        .where('role', isEqualTo: UserRole.clinician.index)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return User.fromJson(data);
    }).toList();
  }

  // Get patients for a clinician
  Future<List<User>> getPatientsForClinician(String clinicianId) async {
    final snapshot = await _usersCollection
        .where('role', isEqualTo: UserRole.patient.index)
        .where('doctorId', isEqualTo: clinicianId)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return User.fromJson(data);
    }).toList();
  }

  // ==================== MEDICATION METHODS ====================

  // Add medication for a user
  Future<String> addMedication(String userId, Medication medication) async {
    final docRef = await _medicationsCollection.add({
      ...medication.toJson(),
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  // Get medications for a user
  Stream<List<Medication>> getMedicationsForUser(String userId) {
    return _medicationsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Medication.fromJson({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                }))
            .toList());
  }

  // Get active medications for a user
  Stream<List<Medication>> getActiveMedicationsForUser(String userId) {
    return _medicationsCollection
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Medication.fromJson({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                }))
            .toList());
  }

  // Update medication
  Future<void> updateMedication(Medication medication) async {
    await _medicationsCollection.doc(medication.id).update(medication.toJson());
  }

  // Delete medication
  Future<void> deleteMedication(String medicationId) async {
    await _medicationsCollection.doc(medicationId).delete();
  }

  // ==================== DOSE LOG METHODS ====================

  // Add dose log
  Future<String> addDoseLog(String userId, DoseLog doseLog) async {
    final docRef = await _doseLogsCollection.add({
      ...doseLog.toJson(),
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  // Get dose logs for a user
  Stream<List<DoseLog>> getDoseLogsForUser(String userId) {
    return _doseLogsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('scheduledTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DoseLog.fromJson({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                }))
            .toList());
  }

  // Get dose logs for a medication
  Stream<List<DoseLog>> getDoseLogsForMedication(String medicationId) {
    return _doseLogsCollection
        .where('medicationId', isEqualTo: medicationId)
        .orderBy('scheduledTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DoseLog.fromJson({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                }))
            .toList());
  }

  // Get dose logs for a specific date range
  Future<List<DoseLog>> getDoseLogsForDateRange(
      String userId, DateTime start, DateTime end) async {
    final snapshot = await _doseLogsCollection
        .where('userId', isEqualTo: userId)
        .where('scheduledTime', isGreaterThanOrEqualTo: start)
        .where('scheduledTime', isLessThan: end)
        .orderBy('scheduledTime')
        .get();
    return snapshot.docs
        .map((doc) => DoseLog.fromJson({
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            }))
        .toList();
  }

  // Update dose log
  Future<void> updateDoseLog(DoseLog doseLog) async {
    await _doseLogsCollection.doc(doseLog.id).update(doseLog.toJson());
  }

  // Delete dose log
  Future<void> deleteDoseLog(String doseLogId) async {
    await _doseLogsCollection.doc(doseLogId).delete();
  }

  // ==================== SIDE EFFECT METHODS ====================

  // Add side effect
  Future<String> addSideEffect(String userId, SideEffect sideEffect) async {
    final docRef = await _sideEffectsCollection.add({
      ...sideEffect.toJson(),
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  // Get side effects for a user
  Stream<List<SideEffect>> getSideEffectsForUser(String userId) {
    return _sideEffectsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('reportedDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SideEffect.fromJson({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                }))
            .toList());
  }

  // Get side effects for a medication
  Stream<List<SideEffect>> getSideEffectsForMedication(String medicationId) {
    return _sideEffectsCollection
        .where('medicationId', isEqualTo: medicationId)
        .orderBy('reportedDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SideEffect.fromJson({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                }))
            .toList());
  }

  // Update side effect
  Future<void> updateSideEffect(SideEffect sideEffect) async {
    await _sideEffectsCollection.doc(sideEffect.id).update(sideEffect.toJson());
  }

  // Delete side effect
  Future<void> deleteSideEffect(String sideEffectId) async {
    await _sideEffectsCollection.doc(sideEffectId).delete();
  }

  // ==================== HERBAL USE METHODS ====================

  // Add herbal use
  Future<String> addHerbalUse(String userId, HerbalUse herbalUse) async {
    final docRef = await _herbalUsesCollection.add({
      ...herbalUse.toJson(),
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  // Get herbal uses for a user
  Stream<List<HerbalUse>> getHerbalUsesForUser(String userId) {
    return _herbalUsesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HerbalUse.fromJson({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                }))
            .toList());
  }

  // Update herbal use
  Future<void> updateHerbalUse(HerbalUse herbalUse) async {
    await _herbalUsesCollection.doc(herbalUse.id).update(herbalUse.toJson());
  }

  // Delete herbal use
  Future<void> deleteHerbalUse(String herbalUseId) async {
    await _herbalUsesCollection.doc(herbalUseId).delete();
  }

  // ==================== ANALYTICS METHODS ====================

  // Get adherence rate for a user
  Future<double> getAdherenceRate(String userId, DateTime start, DateTime end) async {
    final snapshot = await _doseLogsCollection
        .where('userId', isEqualTo: userId)
        .where('scheduledTime', isGreaterThanOrEqualTo: start)
        .where('scheduledTime', isLessThan: end)
        .get();

    if (snapshot.docs.isEmpty) return 0.0;

    final takenDoses = snapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      return data?['taken'] == true;
    }).length;
    return (takenDoses / snapshot.docs.length) * 100;
  }

  // Get medication count for a user
  Future<int> getMedicationCount(String userId) async {
    final snapshot = await _medicationsCollection
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .get();
    return snapshot.docs.length;
  }
}
