import 'package:flutter/material.dart';
import '../models/medication.dart';
import 'firestore_service.dart';
import 'notification_service.dart';

class MedicationExpiryService {
  static final MedicationExpiryService _instance = MedicationExpiryService._internal();
  factory MedicationExpiryService() => _instance;
  MedicationExpiryService._internal();

  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();

  /// Check and deactivate expired medications for a user
  Future<List<Medication>> checkAndDeactivateExpiredMedications(String userId) async {
    try {
      final medications = await _firestoreService.getMedicationsForUserFuture(userId);
      final now = DateTime.now();
      final expiredMeds = <Medication>[];

      for (final med in medications) {
        if (med.isActive && med.endDate != null) {
          final endOfDay = DateTime(med.endDate!.year, med.endDate!.month, med.endDate!.day, 23, 59, 59);
          
          if (now.isAfter(endOfDay)) {
            // Medication has expired, deactivate it
            final updatedMed = Medication(
              id: med.id,
              name: med.name,
              dosage: med.dosage,
              frequency: med.frequency,
              times: med.times,
              instructions: med.instructions,
              startDate: med.startDate,
              endDate: med.endDate,
              isActive: false,
              prescribedBy: med.prescribedBy,
              prescribedByName: med.prescribedByName,
              patientId: med.patientId,
            );

            await _firestoreService.updateMedication(updatedMed);
            await _notificationService.cancelMedicationReminders(med.id);
            expiredMeds.add(updatedMed);
            
            debugPrint('Deactivated expired medication: ${med.name} (ended on ${med.endDate})');
          }
        }
      }

      return expiredMeds;
    } catch (e) {
      debugPrint('Error checking expired medications: $e');
      return [];
    }
  }

  /// Check if a medication is expired
  bool isMedicationExpired(Medication medication) {
    if (medication.endDate == null) return false;
    
    final now = DateTime.now();
    final endOfDay = DateTime(medication.endDate!.year, medication.endDate!.month, medication.endDate!.day, 23, 59, 59);
    
    return now.isAfter(endOfDay);
  }

  /// Get days remaining for a medication
  int getDaysRemaining(Medication medication) {
    if (medication.endDate == null) return -1;
    
    final now = DateTime.now();
    final endDate = medication.endDate!;
    
    return endDate.difference(now).inDays;
  }
}
