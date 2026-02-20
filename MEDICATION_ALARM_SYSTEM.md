# Medication Alarm & Reminder System - Implementation Guide

## Overview
The medication alarm/reminder system is the core feature of DawaTrack, ensuring patients take their medications on time and clinicians can monitor adherence.

## Key Features Implemented

### 1. Scheduled Medication Reminders
- **Location**: `lib/services/notification_service.dart`
- **How it works**:
  - When a medication is prescribed, notifications are scheduled for each dose time
  - Uses `flutter_local_notifications` for local push notifications
  - Repeats daily at the specified times
  - Automatically stops when medication expires

### 2. Tap-to-Confirm Medication Intake
- **Location**: `lib/screens/patient_home_screen.dart`
- **How it works**:
  - When a scheduled dose time arrives (within 30 minutes), a prominent orange card appears
  - Patient taps the card to confirm they've taken the medication
  - Visual feedback changes from "Time to take!" to "Taken" with green checkmark
  - Records the exact time the dose was taken in Firestore

### 3. Visual Status Indicators
Each medication dose shows one of four states:
- **🟢 Taken** (Green): Patient confirmed taking the medication
- **🟠 Time to take!** (Orange): Current dose time - tap to confirm
- **🔴 Missed** (Red): Scheduled time has passed without confirmation
- **🔵 Scheduled** (Blue): Future dose times

### 4. Automatic Medication Expiry
- **Location**: `lib/services/medication_expiry_service.dart`
- **How it works**:
  - Checks all medications when patient/clinician logs in
  - Compares current date with medication `endDate`
  - Automatically deactivates expired medications
  - Cancels all future notifications for expired medications
  - Shows notification to user about expired medications

### 5. Clinician Dashboard Sync
- **Location**: `lib/screens/clinician_dashboard_screen.dart`
- **How it works**:
  - Shows only active (non-expired) medications
  - Displays patient adherence rates based on confirmed doses
  - Automatically removes expired medications from view
  - Updates in real-time as patients confirm doses

## Data Flow

### When Medication is Prescribed:
1. Clinician prescribes medication with:
   - Name, dosage, frequency
   - Times (e.g., ["08:00", "14:00", "20:00"])
   - Start date and end date
2. Medication saved to Firestore
3. Notifications scheduled for each time
4. Patient sees medication in their home screen

### When Dose Time Arrives:
1. Local notification fires at scheduled time
2. Patient opens app and sees orange "TAP TO CONFIRM" card
3. Patient taps card
4. System records:
   - Dose log with taken=true
   - Exact time taken
   - Next scheduled dose time
5. Visual feedback changes to green "Taken"
6. Clinician dashboard updates with new adherence data

### When Medication Expires:
1. System checks expiry on app launch
2. If current date > end date:
   - Sets `isActive = false`
   - Cancels all notifications
   - Removes from active medication list
3. Medication no longer appears in patient home screen
4. Medication no longer appears in clinician dashboard
5. Historical data (dose logs) remains for reporting

## Database Structure

### Medications Collection
```
medications/{medicationId}
  - id: string
  - name: string
  - dosage: string
  - frequency: string
  - times: string[] (e.g., ["08:00", "20:00"])
  - startDate: timestamp
  - endDate: timestamp
  - isActive: boolean
  - patientId: string
  - prescribedBy: string
  - userId: string
```

### Dose Logs Collection
```
doseLogs/{logId}
  - id: string
  - medicationId: string
  - scheduledTime: timestamp
  - takenTime: timestamp (null if not taken)
  - taken: boolean
  - userId: string
```

### Dose Intakes Collection
```
doseIntakes/{intakeId}
  - id: string
  - medicationId: string
  - medicationName: string
  - takenAt: timestamp
  - scheduledTime: string (e.g., "08:00")
  - nextDueTime: timestamp
  - userId: string
```

## User Experience Flow

### Patient Journey:
1. **Morning (8:00 AM)**:
   - Receives notification: "💊 Time to take your medication"
   - Opens app
   - Sees orange card: "TAP TO CONFIRM - 08:00 - 500mg"
   - Taps card
   - Sees green confirmation: "Medication confirmed! Next dose: 2:00 PM"

2. **Afternoon (2:00 PM)**:
   - Receives notification again
   - Repeats confirmation process

3. **After 3 Days**:
   - Medication expires
   - No more notifications
   - Medication disappears from home screen
   - Can view history in History screen

### Clinician Journey:
1. **Prescribes Medication**:
   - Selects patient
   - Enters medication details
   - Sets 3-day duration
   - Saves prescription

2. **Monitors Adherence**:
   - Views patient dashboard
   - Sees adherence rate (e.g., 85%)
   - Sees which doses were taken/missed
   - Can add comments on side effects

3. **After 3 Days**:
   - Medication automatically removed from active list
   - Can view historical adherence data in reports

## Configuration

### Notification Permissions
Required permissions in `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### Notification Channel
- **Channel ID**: `medication_reminders`
- **Channel Name**: Medication Reminders
- **Importance**: High
- **Sound**: Enabled
- **Vibration**: Enabled

## Testing the System

### Test Scenario 1: Immediate Notification
1. Prescribe medication with current time + 1 minute
2. Wait for notification
3. Open app and confirm dose
4. Verify green "Taken" status

### Test Scenario 2: Expiry
1. Prescribe medication with end date = today
2. Wait until midnight
3. Open app next day
4. Verify medication is removed

### Test Scenario 3: Missed Dose
1. Prescribe medication with time in the past
2. Open app
3. Verify red "Missed" status

## Troubleshooting

### Notifications Not Appearing
- Check notification permissions in device settings
- Verify exact alarm permission is granted
- Check battery optimization settings

### Medication Not Expiring
- Verify end date is set correctly
- Check system date/time
- Restart app to trigger expiry check

### Tap Not Working
- Ensure medication time is within 30 minutes of current time
- Check if dose was already confirmed
- Verify internet connection for Firestore sync

## Future Enhancements
1. Snooze functionality for reminders
2. Custom notification sounds per medication
3. Medication refill reminders
4. Integration with pharmacy systems
5. Wearable device notifications
6. Voice confirmation support
