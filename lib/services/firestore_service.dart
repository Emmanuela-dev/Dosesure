import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/medication.dart';
import '../models/dose_log.dart';
import '../models/side_effect.dart';
import '../models/herbal_use.dart';
import '../models/drug.dart';
import '../models/drug_interaction.dart';
import '../models/dose_intake.dart';
import '../models/comment.dart';

class FirestoreService {
      CollectionReference get _commentsCollection => _firestore.collection('comments');

      // Add a comment (for side effect or herbal use)
      Future<void> addComment(Comment comment) async {
        await _commentsCollection.add(comment.toJson());
      }

      // Get comments for a target (side effect or herbal use)
      Stream<List<Comment>> getCommentsForTarget(String targetId) {
        return _commentsCollection
            .where('targetId', isEqualTo: targetId)
            .orderBy('createdAt', descending: false)
            .snapshots()
            .map((snapshot) => snapshot.docs
                .map((doc) => Comment.fromJson({
                      ...doc.data() as Map<String, dynamic>,
                      'id': doc.id,
                    }))
                .toList());
      }

      // Get comments for a user (patient)
      Stream<List<Comment>> getCommentsForUser(String userId) {
        return _commentsCollection
            .where('targetOwnerId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .snapshots()
            .map((snapshot) => snapshot.docs
                .map((doc) => Comment.fromJson({
                      ...doc.data() as Map<String, dynamic>,
                      'id': doc.id,
                    }))
                .toList());
      }

      // Mark comment as read
      Future<void> markCommentAsRead(String commentId) async {
        await _commentsCollection.doc(commentId).update({'isRead': true});
      }
    // Add a new patient (auto-generate ID)
    Future<User> addPatient(User user, {String? doctorId}) async {
      final docRef = await _usersCollection.add({
        ...user.toJson(),
        'role': UserRole.patient.index,
        if (doctorId != null) 'doctorId': doctorId,
      });
      final newUser = user.copyWith(id: docRef.id, doctorId: doctorId);
      return newUser;
    }
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _medicationsCollection => _firestore.collection('medications');
  CollectionReference get _doseLogsCollection => _firestore.collection('doseLogs');
  CollectionReference get _sideEffectsCollection => _firestore.collection('sideEffects');
  CollectionReference get _herbalUsesCollection => _firestore.collection('herbalUses');
  CollectionReference get _drugsCollection => _firestore.collection('drugs');
  CollectionReference get _doseIntakesCollection => _firestore.collection('doseIntakes');

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
    try {
      debugPrint('FirestoreService.getClinicians - Fetching clinicians...');
      debugPrint('FirestoreService.getClinicians - UserRole.clinician.index = ${UserRole.clinician.index}');
      
      // Try to get clinicians with role = 1 (clinician enum index)
      var snapshot = await _usersCollection
          .where('role', isEqualTo: 1)
          .get();
      
      debugPrint('FirestoreService.getClinicians - Found ${snapshot.docs.length} clinicians with role=1');
      
      // If no clinicians found, also try role = 0 (in case the enum was reversed in the database)
      if (snapshot.docs.isEmpty) {
        debugPrint('FirestoreService.getClinicians - No clinicians with role=1, trying role=0...');
        snapshot = await _usersCollection
            .where('role', isEqualTo: 0)
            .get();
        debugPrint('FirestoreService.getClinicians - Found ${snapshot.docs.length} users with role=0');
        
        // If still empty, try fetching all users and filtering
        if (snapshot.docs.isEmpty) {
          debugPrint('FirestoreService.getClinicians - No users found with role filter, fetching all users...');
          final allUsersSnapshot = await _usersCollection.get();
          debugPrint('FirestoreService.getClinicians - Total users in database: ${allUsersSnapshot.docs.length}');
          
          for (var doc in allUsersSnapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;
            debugPrint('FirestoreService.getClinicians - User: ${data['name']}, role: ${data['role']}, email: ${data['email']}');
          }
        }
      }
      
      final clinicians = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        debugPrint('FirestoreService.getClinicians - Clinician: ${data['name']} (${data['email']}) role: ${data['role']}');
        return User.fromJson(data);
      }).toList();
      
      return clinicians;
    } catch (e) {
      debugPrint('FirestoreService.getClinicians - Error: $e');
      rethrow;
    }
  }

  // Get patients for a clinician
  Future<List<User>> getPatientsForClinician(String clinicianId) async {
    try {
      debugPrint('getPatientsForClinician - Fetching patients for clinician: $clinicianId');
      debugPrint('getPatientsForClinician - UserRole.patient.index = ${UserRole.patient.index}');
      
      // Try the compound query first
      final snapshot = await _usersCollection
          .where('role', isEqualTo: UserRole.patient.index)
          .where('doctorId', isEqualTo: clinicianId)
          .get();
      
      debugPrint('getPatientsForClinician - Found ${snapshot.docs.length} patients with compound query');
      
      final patients = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        debugPrint('getPatientsForClinician - Patient: ${data['name']} (${data['email']}) doctorId: ${data['doctorId']}');
        return User.fromJson(data);
      }).toList();
      
      return patients;
    } catch (e) {
      // If compound query fails (likely index issue), fall back to simpler query
      debugPrint('getPatientsForClinician - Compound query failed, trying fallback: $e');
      try {
        final snapshot = await _usersCollection
            .where('doctorId', isEqualTo: clinicianId)
            .get();
        
        debugPrint('getPatientsForClinician - Fallback found ${snapshot.docs.length} users with doctorId');
        
        final patients = snapshot.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              debugPrint('getPatientsForClinician - User: ${data['name']} role: ${data['role']}');
              return User.fromJson(data);
            })
            .where((user) => user.role == UserRole.patient)
            .toList();
        
        debugPrint('getPatientsForClinician - Filtered to ${patients.length} patients');
        return patients;
      } catch (e2) {
        debugPrint('getPatientsForClinician - Fallback query also failed: $e2');
        
        // Last resort: get all users and filter
        debugPrint('getPatientsForClinician - Trying to fetch all users...');
        final allSnapshot = await _usersCollection.get();
        debugPrint('getPatientsForClinician - Total users: ${allSnapshot.docs.length}');
        
        final patients = allSnapshot.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return User.fromJson(data);
            })
            .where((user) => user.role == UserRole.patient && user.doctorId == clinicianId)
            .toList();
        
        debugPrint('getPatientsForClinician - Final filtered patients: ${patients.length}');
        return patients;
      }
    }
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

  // Get medications for a user (Future-based)
  Future<List<Medication>> getMedicationsForUserFuture(String userId) async {
    try {
      final snapshot = await _medicationsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => Medication.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      debugPrint('getMedicationsForUserFuture - Error: $e');
      // Fallback without orderBy
      final snapshot = await _medicationsCollection
          .where('userId', isEqualTo: userId)
          .get();
      
      final medications = snapshot.docs
          .map((doc) => Medication.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
      
      medications.sort((a, b) => b.startDate.compareTo(a.startDate));
      return medications;
    }
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

  // Get medications for a patient (Future-based, for clinician view)
  Future<List<Medication>> getMedicationsForPatient(String patientId) async {
    try {
      final snapshot = await _medicationsCollection
          .where('userId', isEqualTo: patientId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => Medication.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      debugPrint('getMedicationsForPatient - Index query failed, trying fallback: $e');
      // Fallback: get without orderBy and sort client-side
      final snapshot = await _medicationsCollection
          .where('userId', isEqualTo: patientId)
          .get();
      
      final medications = snapshot.docs
          .map((doc) => Medication.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
      
      // Sort by startDate descending (since createdAt may not be in the medication object)
      medications.sort((a, b) => b.startDate.compareTo(a.startDate));
      return medications;
    }
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

  // ==================== DOSE INTAKE METHODS ====================

  // Record dose intake
  Future<String> recordDoseIntake(String userId, DoseIntake intake) async {
    final docRef = await _doseIntakesCollection.add({
      ...intake.toJson(),
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  // Get dose intakes for a medication
  Stream<List<DoseIntake>> getDoseIntakesForMedication(String medicationId) {
    return _doseIntakesCollection
        .where('medicationId', isEqualTo: medicationId)
        .orderBy('takenAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DoseIntake.fromJson({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                }))
            .toList());
  }

  // Get latest dose intake for a medication
  Future<DoseIntake?> getLatestDoseIntake(String medicationId) async {
    final snapshot = await _doseIntakesCollection
        .where('medicationId', isEqualTo: medicationId)
        .orderBy('takenAt', descending: true)
        .limit(1)
        .get();
    
    if (snapshot.docs.isEmpty) return null;
    
    final doc = snapshot.docs.first;
    return DoseIntake.fromJson({
      ...doc.data() as Map<String, dynamic>,
      'id': doc.id,
    });
  }

  // ==================== DRUG METHODS ====================

  // Get all drugs
  Future<List<Drug>> getAllDrugs() async {
    final snapshot = await _drugsCollection.orderBy('name').get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Drug.fromJson(data);
    }).toList();
  }

  // Get drugs by category
  Future<List<Drug>> getDrugsByCategory(String category) async {
    final snapshot = await _drugsCollection
        .where('category', isEqualTo: category)
        .orderBy('name')
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Drug.fromJson(data);
    }).toList();
  }

  // Check for drug interactions
  Future<List<Map<String, dynamic>>> checkDrugInteractions(
    String newDrugId,
    String patientId,
  ) async {
    List<Map<String, dynamic>> interactions = [];
    
    // Get patient's current active medications
    final medications = await getMedicationsForUserFuture(patientId);
    final activeMeds = medications.where((m) => m.isActive).toList();
    
    if (activeMeds.isEmpty) {
      return interactions; // No interactions if no active medications
    }
    
    // Get the new drug details
    final newDrugDoc = await _drugsCollection.doc(newDrugId).get();
    if (!newDrugDoc.exists) return interactions;
    
    final newDrugData = newDrugDoc.data() as Map<String, dynamic>;
    newDrugData['id'] = newDrugDoc.id;
    final newDrug = Drug.fromJson(newDrugData);
    
    // Get all drugs to match medication names
    final allDrugs = await getAllDrugs();
    final drugMap = {for (var d in allDrugs) d.name.toLowerCase(): d};
    
    // Check interactions with each active medication
    for (var med in activeMeds) {
      final medDrug = drugMap[med.name.toLowerCase()];
      if (medDrug == null) continue;
      
      // Check if new drug interacts with this medication
      for (var interaction in newDrug.detailedInteractions) {
        if (interaction.interactingDrugId == medDrug.id ||
            interaction.interactingDrugName.toLowerCase() == medDrug.name.toLowerCase()) {
          interactions.add({
            'existingDrug': medDrug.name,
            'newDrug': newDrug.name,
            'description': interaction.description,
            'severity': interaction.severity.name,
          });
        }
      }
      
      // Check if existing medication interacts with new drug
      for (var interaction in medDrug.detailedInteractions) {
        if (interaction.interactingDrugId == newDrug.id ||
            interaction.interactingDrugName.toLowerCase() == newDrug.name.toLowerCase()) {
          // Avoid duplicates
          bool alreadyAdded = interactions.any((i) => 
            i['existingDrug'] == medDrug.name && i['newDrug'] == newDrug.name);
          if (!alreadyAdded) {
            interactions.add({
              'existingDrug': medDrug.name,
              'newDrug': newDrug.name,
              'description': interaction.description,
              'severity': interaction.severity.name,
            });
          }
        }
      }
    }
    
    return interactions;
  }

  // Initialize default drugs (call this once on first app start)
  Future<void> initializeDefaultDrugs() async {
    try {
      debugPrint('FirestoreService.initializeDefaultDrugs - Checking if drugs exist...');
      
      // Check if anticoagulants exist
      bool drugsExist = false;
      try {
        final snapshot = await _drugsCollection
            .where('category', isEqualTo: 'anticoagulant')
            .limit(1)
            .get();
        drugsExist = snapshot.docs.isNotEmpty;
        debugPrint('FirestoreService.initializeDefaultDrugs - Anticoagulants exist: $drugsExist');
      } catch (e) {
        debugPrint('FirestoreService.initializeDefaultDrugs - Could not check existing drugs: $e');
      }
      
      if (drugsExist) {
        debugPrint('FirestoreService.initializeDefaultDrugs - Drugs already exist, skipping');
        return;
      }

      debugPrint('FirestoreService.initializeDefaultDrugs - Creating anticoagulant drugs...');
      
      // Define anticoagulant drugs with detailed interactions
      final anticoagulants = _getAnticoagulantDrugs();
      
      // Add all drugs to Firestore
      for (final drug in anticoagulants) {
        try {
          await _drugsCollection.doc(drug.id).set(drug.toJson());
          debugPrint('FirestoreService.initializeDefaultDrugs - Added drug: ${drug.name}');
        } catch (e) {
          debugPrint('FirestoreService.initializeDefaultDrugs - Failed to add ${drug.name}: $e');
        }
      }
      debugPrint('FirestoreService.initializeDefaultDrugs - Complete');
    } catch (e) {
      debugPrint('FirestoreService.initializeDefaultDrugs - Error: $e');
    }
  }
  
  List<Drug> _getAnticoagulantDrugs() {
    return [
      Drug(
        id: 'warfarin',
        name: 'Warfarin',
        genericName: 'Warfarin',
        brandNames: ['Coumadin', 'Jantoven'],
        category: DrugCategory.anticoagulant,
        isHighAlert: true,
        commonDosages: ['1mg', '3mg', '5mg'],
        use: 'Vitamin K antagonist used to treat venous thromboembolism, pulmonary embolism, thromboembolism with atrial fibrillation',
        indications: 'Prophylaxis and treatment of venous thromboembolism, thromboembolism with atrial fibrillation, cardiac valve replacement, post-MI',
        warnings: 'High-alert anticoagulant. Monitor INR regularly. Risk of bleeding.',
        interactions: [],
        detailedInteractions: [
          DrugInteraction(
            interactingDrugId: 'abacavir',
            interactingDrugName: 'Abacavir',
            description: 'Abacavir may decrease the excretion rate of Warfarin which could result in a higher serum level.',
            severity: InteractionSeverity.moderate,
          ),
          DrugInteraction(
            interactingDrugId: 'abametapir',
            interactingDrugName: 'Abametapir',
            description: 'The serum concentration of Warfarin can be increased when it is combined with Abametapir.',
            severity: InteractionSeverity.moderate,
          ),
          DrugInteraction(
            interactingDrugId: 'abatacept',
            interactingDrugName: 'Abatacept',
            description: 'The serum concentration of Warfarin can be increased when it is combined with Abatacept.',
            severity: InteractionSeverity.moderate,
          ),
          DrugInteraction(
            interactingDrugId: 'abciximab',
            interactingDrugName: 'Abciximab',
            description: 'The risk or severity of bleeding can be increased when Abciximab is combined with Warfarin.',
            severity: InteractionSeverity.high,
          ),
          DrugInteraction(
            interactingDrugId: 'abemaciclib',
            interactingDrugName: 'Abemaciclib',
            description: 'The metabolism of Abemaciclib can be increased when combined with Warfarin.',
            severity: InteractionSeverity.moderate,
          ),
          DrugInteraction(
            interactingDrugId: 'vitamin_k_foods',
            interactingDrugName: 'Vitamin K-rich foods',
            description: 'Vitamin K in foods such as leafy vegetables can reduce warfarin efficacy.',
            severity: InteractionSeverity.moderate,
          ),
          DrugInteraction(
            interactingDrugId: 'grapefruit',
            interactingDrugName: 'Grapefruit Juice',
            description: 'May interfere with warfarin metabolism and increase INR, increasing the risk of bleeding.',
            severity: InteractionSeverity.moderate,
          ),
          DrugInteraction(
            interactingDrugId: 'st_johns_wort',
            interactingDrugName: 'St. John\'s Wort',
            description: 'This drug may reduce warfarin efficacy.',
            severity: InteractionSeverity.moderate,
          ),
          DrugInteraction(
            interactingDrugId: 'herbal_anticoagulants',
            interactingDrugName: 'Garlic, ginger, bilberry, danshen, piracetam, ginkgo biloba',
            description: 'Avoid herbs and supplements with anticoagulant/antiplatelet activity.',
            severity: InteractionSeverity.moderate,
          ),
        ],
      ),
      Drug(
        id: 'heparin',
        name: 'Heparin Sodium',
        genericName: 'Heparin',
        brandNames: ['Defencath', 'Heparin Leo'],
        category: DrugCategory.anticoagulant,
        isHighAlert: true,
        commonDosages: ['5mL Vial'],
        use: 'Anticoagulant for thromboprophylaxis and treatment of thrombosis',
        indications: 'Prophylaxis and treatment of venous thrombosis, prevention of post-operative DVT and PE, prevention of clotting in arterial and cardiac surgery, atrial fibrillation',
        warnings: 'High-alert anticoagulant. Monitor aPTT. Risk of bleeding and thrombocytopenia.',
        interactions: [],
        detailedInteractions: [
          DrugInteraction(
            interactingDrugId: 'abciximab',
            interactingDrugName: 'Abciximab',
            description: 'The risk or severity of bleeding can be increased when Abciximab is combined with Heparin.',
            severity: InteractionSeverity.high,
          ),
          DrugInteraction(
            interactingDrugId: 'acebutolol',
            interactingDrugName: 'Acebutolol',
            description: 'The risk or severity of hyperkalemia can be increased when Heparin is combined with Acebutolol.',
            severity: InteractionSeverity.moderate,
          ),
          DrugInteraction(
            interactingDrugId: 'aceclofenac',
            interactingDrugName: 'Aceclofenac',
            description: 'The risk or severity of bleeding and hemorrhage can be increased when Aceclofenac is combined with Heparin.',
            severity: InteractionSeverity.high,
          ),
          DrugInteraction(
            interactingDrugId: 'acemetacin',
            interactingDrugName: 'Acemetacin',
            description: 'The risk or severity of bleeding and hemorrhage can be increased when Heparin is combined with Acemetacin.',
            severity: InteractionSeverity.high,
          ),
          DrugInteraction(
            interactingDrugId: 'acenocoumarol',
            interactingDrugName: 'Acenocoumarol',
            description: 'The risk or severity of bleeding can be increased when Heparin is combined with Acenocoumarol.',
            severity: InteractionSeverity.high,
          ),
          DrugInteraction(
            interactingDrugId: 'calcium_supplement',
            interactingDrugName: 'Calcium Supplement',
            description: 'Heparin decreases calcium levels. Administer calcium supplement.',
            severity: InteractionSeverity.low,
          ),
          DrugInteraction(
            interactingDrugId: 'herbal_anticoagulants',
            interactingDrugName: 'Garlic, ginger, bilberry, danshen, piracetam, ginkgo biloba',
            description: 'Avoid herbs and supplements with anticoagulant/antiplatelet activity.',
            severity: InteractionSeverity.moderate,
          ),
        ],
      ),
      Drug(
        id: 'enoxaparin',
        name: 'Enoxaparin',
        genericName: 'Enoxaparin',
        category: DrugCategory.anticoagulant,
        isHighAlert: true,
        commonDosages: ['40mg/0.4mL', '80mg/0.8mL'],
        use: 'Low molecular weight heparin for DVT prophylaxis and ischemic complications',
        indications: 'Prevention of ischemic complications in unstable angina, non-Q-wave MI, DVT prophylaxis in surgery, treatment of DVT with or without PE',
        warnings: 'High-alert anticoagulant. Monitor anti-Xa levels if needed. Risk of bleeding.',
        interactions: [],
        detailedInteractions: [
          DrugInteraction(
            interactingDrugId: 'abciximab',
            interactingDrugName: 'Abciximab',
            description: 'The risk or severity of bleeding can be increased when Abciximab is combined with Enoxaparin.',
            severity: InteractionSeverity.high,
          ),
          DrugInteraction(
            interactingDrugId: 'acebutolol',
            interactingDrugName: 'Acebutolol',
            description: 'The risk or severity of hyperkalemia can be increased when Acebutolol is combined with Enoxaparin.',
            severity: InteractionSeverity.moderate,
          ),
          DrugInteraction(
            interactingDrugId: 'aceclofenac',
            interactingDrugName: 'Aceclofenac',
            description: 'The risk or severity of bleeding and hemorrhage can be increased when Aceclofenac is combined with Enoxaparin.',
            severity: InteractionSeverity.high,
          ),
          DrugInteraction(
            interactingDrugId: 'acemetacin',
            interactingDrugName: 'Acemetacin',
            description: 'The risk or severity of bleeding and hemorrhage can be increased when Enoxaparin is combined with Acemetacin.',
            severity: InteractionSeverity.high,
          ),
          DrugInteraction(
            interactingDrugId: 'acenocoumarol',
            interactingDrugName: 'Acenocoumarol',
            description: 'The risk or severity of bleeding can be increased when Enoxaparin is combined with Acenocoumarol.',
            severity: InteractionSeverity.high,
          ),
          DrugInteraction(
            interactingDrugId: 'herbal_anticoagulants',
            interactingDrugName: 'Garlic, ginger, bilberry, danshen, piracetam, ginkgo biloba',
            description: 'Avoid herbs and supplements with anticoagulant/antiplatelet activity.',
            severity: InteractionSeverity.moderate,
          ),
        ],
      ),
      Drug(
        id: 'rivaroxaban',
        name: 'Rivaroxaban',
        genericName: 'Rivaroxaban',
        brandNames: ['Rivaroxaban Accord', 'Rivaroxaban Mylan', 'Xarelto'],
        category: DrugCategory.anticoagulant,
        isHighAlert: true,
        commonDosages: ['10mg', '15mg', '20mg'],
        use: 'Factor Xa inhibitor for DVT, PE treatment and prevention',
        indications: 'Prevention of VTE post-surgery, stroke prevention in atrial fibrillation, treatment of DVT/PE, reduction of cardiovascular events in CAD/PAD',
        warnings: 'High-alert anticoagulant. Not recommended in severe renal impairment (<30mL/min). Risk of bleeding.',
        interactions: [],
        detailedInteractions: [
          DrugInteraction(
            interactingDrugId: 'abacavir',
            interactingDrugName: 'Abacavir',
            description: 'Abacavir may decrease the excretion rate of Rivaroxaban which could result in a higher serum level.',
            severity: InteractionSeverity.moderate,
          ),
          DrugInteraction(
            interactingDrugId: 'abametapir',
            interactingDrugName: 'Abametapir',
            description: 'The serum concentration of Rivaroxaban can be increased when it is combined with Abametapir.',
            severity: InteractionSeverity.moderate,
          ),
          DrugInteraction(
            interactingDrugId: 'abatacept',
            interactingDrugName: 'Abatacept',
            description: 'The metabolism of Rivaroxaban can be increased when combined with Abatacept.',
            severity: InteractionSeverity.moderate,
          ),
          DrugInteraction(
            interactingDrugId: 'abciximab',
            interactingDrugName: 'Abciximab',
            description: 'Abciximab may increase the anticoagulant activities of Rivaroxaban.',
            severity: InteractionSeverity.high,
          ),
          DrugInteraction(
            interactingDrugId: 'abemaciclib',
            interactingDrugName: 'Abemaciclib',
            description: 'Abemaciclib may decrease the excretion rate of Rivaroxaban which could result in a higher serum level.',
            severity: InteractionSeverity.moderate,
          ),
          DrugInteraction(
            interactingDrugId: 'herbal_anticoagulants',
            interactingDrugName: 'Garlic, ginger, bilberry, danshen, piracetam, ginkgo biloba',
            description: 'Avoid herbs and supplements with anticoagulant/antiplatelet activity.',
            severity: InteractionSeverity.moderate,
          ),
          DrugInteraction(
            interactingDrugId: 'st_johns_wort',
            interactingDrugName: 'St. John\'s Wort',
            description: 'Co-administration will decrease levels of this medication.',
            severity: InteractionSeverity.moderate,
          ),
        ],
      ),
    ];
  }
}
