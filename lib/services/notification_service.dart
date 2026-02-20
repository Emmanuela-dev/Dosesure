import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/medication.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz_data.initializeTimeZones();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/logo');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions on Android 13+
    await _requestPermissions();

    _isInitialized = true;
    debugPrint('NotificationService initialized');
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    // Request Android permissions
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
    }

    // Request iOS permissions
    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Can navigate to medication details or log dose screen
  }

  /// Schedule medication reminders for a medication
  Future<void> scheduleMedicationReminders(Medication medication) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Cancel any existing notifications for this medication
    await cancelMedicationReminders(medication.id);

    // Skip if medication is not active
    if (!medication.isActive) {
      debugPrint('Medication ${medication.name} is not active, skipping reminders');
      return;
    }

    // Skip if medication has ended (check if endDate has passed)
    if (medication.endDate != null) {
      final now = DateTime.now();
      final endOfDay = DateTime(medication.endDate!.year, medication.endDate!.month, medication.endDate!.day, 23, 59, 59);
      if (now.isAfter(endOfDay)) {
        debugPrint('Medication ${medication.name} has ended on ${medication.endDate}, skipping reminders');
        return;
      }
    }

    // Schedule notification for each time
    for (int i = 0; i < medication.times.length; i++) {
      final time = medication.times[i];
      final notificationId = _generateNotificationId(medication.id, i);
      
      await _scheduleDaily(
        id: notificationId,
        title: '💊 Time to take your medication',
        body: '${medication.name} - ${medication.dosage}\n${medication.instructions}',
        time: time,
        payload: medication.id,
      );
      
      debugPrint('Scheduled reminder for ${medication.name} at $time (ID: $notificationId)');
    }
  }

  /// Schedule a daily notification at a specific time
  Future<void> _scheduleDaily({
    required int id,
    required String title,
    required String body,
    required String time,
    String? payload,
  }) async {
    final timeParts = _parseTime(time);
    if (timeParts == null) {
      debugPrint('Invalid time format: $time');
      return;
    }

    final hour = timeParts['hour']!;
    final minute = timeParts['minute']!;

    // Get the next occurrence of this time
    final scheduledDate = _nextInstanceOfTime(hour, minute);

    const androidDetails = AndroidNotificationDetails(
      'medication_reminders',
      'Medication Reminders',
      channelDescription: 'Notifications for medication reminders',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/logo',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/logo'),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily at this time
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
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

  /// Get the next occurrence of a specific time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Generate a unique notification ID based on medication ID and time index
  int _generateNotificationId(String medicationId, int timeIndex) {
    // Use hashCode to get a consistent integer from the medication ID
    // Add timeIndex to differentiate between multiple times for the same medication
    return (medicationId.hashCode + timeIndex) % 2147483647; // Max int value
  }

  /// Cancel all reminders for a specific medication
  Future<void> cancelMedicationReminders(String medicationId) async {
    // Cancel notifications for up to 10 time slots (should be more than enough)
    for (int i = 0; i < 10; i++) {
      final notificationId = _generateNotificationId(medicationId, i);
      await _notifications.cancel(notificationId);
    }
    debugPrint('Cancelled reminders for medication: $medicationId');
  }

  /// Cancel all medication reminders
  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
    debugPrint('Cancelled all reminders');
  }

  /// Show an immediate notification (for testing)
  Future<void> showTestNotification() async {
    if (!_isInitialized) {
      await initialize();
    }

    const androidDetails = AndroidNotificationDetails(
      'medication_reminders',
      'Medication Reminders',
      channelDescription: 'Notifications for medication reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      '💊 Test Notification',
      'This is a test medication reminder!',
      notificationDetails,
    );
  }

  /// Schedule reminders for multiple medications
  Future<void> scheduleAllMedicationReminders(List<Medication> medications) async {
    for (final medication in medications) {
      await scheduleMedicationReminders(medication);
    }
  }

  /// Get all pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
