import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import '../models/medication.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _isInitialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;
    await Alarm.init();
    _isInitialized = true;
    debugPrint('NotificationService initialized');
  }

  /// Schedule medication reminders for a medication
  Future<void> scheduleMedicationReminders(Medication medication) async {
    if (!_isInitialized) {
      await initialize();
    }

    await cancelMedicationReminders(medication.id);

    if (!medication.isActive) {
      debugPrint('Medication ${medication.name} is not active');
      return;
    }

    if (medication.endDate != null && DateTime.now().isAfter(medication.endDate!)) {
      debugPrint('Medication ${medication.name} has ended');
      return;
    }

    for (int i = 0; i < medication.times.length; i++) {
      final time = medication.times[i];
      final alarmId = _generateNotificationId(medication.id, i);
      
      final timeParts = _parseTime(time);
      if (timeParts == null) continue;

      final hour = timeParts['hour']!;
      final minute = timeParts['minute']!;
      
      final now = DateTime.now();
      var alarmTime = DateTime(now.year, now.month, now.day, hour, minute);
      if (alarmTime.isBefore(now)) {
        alarmTime = alarmTime.add(const Duration(days: 1));
      }

      final alarmSettings = AlarmSettings(
        id: alarmId,
        dateTime: alarmTime,
        assetAudioPath: 'assets/alarm.mp3',
        loopAudio: true,
        vibrate: true,
        volume: 0.8,
        androidFullScreenIntent: true,
        notificationSettings: NotificationSettings(
          title: '💊 TIME TO TAKE MEDICATION',
          body: '${medication.name} - ${medication.dosage}',
          stopButton: 'Stop Alarm',
        ),
      );

      await Alarm.set(alarmSettings: alarmSettings);
      
      debugPrint('✅ Scheduled alarm for ${medication.name} at $time (${alarmTime})');
    }
  }



  /// Parse time string (HH:MM or H:MM) to hours and minutes
  Map<String, int>? _parseTime(String time) {
    try {
      // Handle various formats: "08:00", "8:00", "08:00 AM", "8:00 PM"
      String cleanTime = time.trim().toUpperCase();
      bool isPM = cleanTime.contains('PM');
      bool isAM = cleanTime.contains('AM');
      
      // Remove AM/PM
      cleanTime = cleanTime.replaceAll('AM', '').replaceAll('PM', '').trim();
      
      final parts = cleanTime.split(':');
      if (parts.length != 2) return null;

      int hour = int.parse(parts[0].trim());
      int minute = int.parse(parts[1].trim());

      // Convert 12-hour format to 24-hour
      if (isPM && hour != 12) {
        hour += 12;
      } else if (isAM && hour == 12) {
        hour = 0;
      }

      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        return null;
      }

      return {'hour': hour, 'minute': minute};
    } catch (e) {
      debugPrint('Error parsing time: $e');
      return null;
    }
  }



  /// Generate a unique notification ID based on medication ID and time index
  int _generateNotificationId(String medicationId, int timeIndex) {
    // Use hashCode to get a consistent integer from the medication ID
    // Add timeIndex to differentiate between multiple times for the same medication
    return (medicationId.hashCode + timeIndex) % 2147483647; // Max int value
  }

  /// Cancel all reminders for a specific medication
  Future<void> cancelMedicationReminders(String medicationId) async {
    for (int i = 0; i < 10; i++) {
      final alarmId = _generateNotificationId(medicationId, i);
      await Alarm.stop(alarmId);
    }
    debugPrint('Cancelled reminders for medication: $medicationId');
  }

  /// Cancel all medication reminders
  Future<void> cancelAllReminders() async {
    await Alarm.stopAll();
    debugPrint('Cancelled all reminders');
  }

  /// Stop a specific alarm
  Future<void> stopAlarm(int alarmId) async {
    await Alarm.stop(alarmId);
    debugPrint('Stopped alarm: $alarmId');
  }

  /// Check if an alarm is ringing
  bool isAlarmRinging(int alarmId) {
    return Alarm.getAlarms().any((alarm) => alarm.id == alarmId);
  }

  /// Get notification ID for medication and time
  int getNotificationId(String medicationId, int timeIndex) {
    return _generateNotificationId(medicationId, timeIndex);
  }

  /// Show an immediate test alarm
  Future<void> showTestNotification() async {
    if (!_isInitialized) {
      await initialize();
    }

    final alarmTime = DateTime.now().add(const Duration(seconds: 5));
    
    final alarmSettings = AlarmSettings(
      id: 999,
      dateTime: alarmTime,
      assetAudioPath: 'assets/alarm.mp3',
      loopAudio: true,
      vibrate: true,
      volume: 0.8,
      androidFullScreenIntent: true,
      notificationSettings: NotificationSettings(
        title: '💊 Test Alarm',
        body: 'This is a test medication alarm!',
        stopButton: 'Stop Alarm',
      ),
    );

    await Alarm.set(alarmSettings: alarmSettings);
    debugPrint('Test alarm set for 5 seconds from now');
  }

  /// Schedule reminders for multiple medications
  Future<void> scheduleAllMedicationReminders(List<Medication> medications) async {
    for (final medication in medications) {
      await scheduleMedicationReminders(medication);
    }
  }


}
