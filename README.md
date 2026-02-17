# DawaTrack - Smart Medication Management System

DawaTrack is a comprehensive Flutter mobile application designed to help patients manage their medications while providing clinicians with tools to monitor patient adherence and detect potential drug interactions.

## 🎯 Overview

DawaTrack bridges the gap between patients and healthcare providers by offering real-time medication tracking, automated reminders, and intelligent drug interaction detection. The app ensures patients take their medications on time while giving clinicians visibility into patient compliance.

## ✨ Key Features

### For Patients

#### 📱 Medication Management
- **View Prescribed Medications**: See all medications prescribed by your doctor with dosage, frequency, and timing
- **Medication Schedule Timeline**: Visual timeline showing today's medication schedule with color-coded status:
  - 🟢 **Green (Taken)**: Dose has been confirmed
  - 🟠 **Orange (Upcoming)**: Dose is due within 30 minutes - clickable to confirm
  - 🔴 **Red (Missed)**: Scheduled time has passed without confirmation
  - 🔵 **Blue (Scheduled)**: Future doses for today

#### ⏰ Smart Dose Confirmation
- **One-Tap Confirmation**: Click the orange "Confirm dose" button when it's time to take medication
- **Automatic Alarm Reset**: After confirming a dose, the alarm automatically resets for the next scheduled time
- **Next Dose Notification**: See exactly when your next dose is due after confirmation
- **Intelligent Scheduling**: System calculates next dose based on clinician-specified frequency

#### 🔔 Medication Reminders
- **Exact Alarm Scheduling**: Precise notifications at medication times
- **Persistent Reminders**: Alarms work even when app is closed
- **Permission Management**: Runtime permission requests for alarms and notifications

#### 📊 Health Tracking
- **Adherence Monitoring**: Track your medication compliance percentage
- **Side Effects Reporting**: Log and monitor side effects from medications
- **Herbal Medicine Tracking**: Record herbal supplements and traditional medicines
- **Medication History**: View complete history of doses taken

#### 🔐 User Account
- **Secure Authentication**: Firebase-based login system
- **Profile Management**: Update personal information
- **Sign Out**: Secure logout with confirmation dialog

### For Clinicians

#### 👨‍⚕️ Patient Management
- **Patient Dashboard**: Overview of all assigned patients
- **Patient Details**: View individual patient medication lists and adherence rates
- **Prescription Management**: Prescribe medications with specific dosage and timing

#### 💊 Medication Prescription
- **Drug Database**: Access to comprehensive antacid medication database:
  - Aluminium Hydroxide
  - Calcium Carbonate
  - Magnesium Hydroxide
  - Sodium Bicarbonate
  - Combination Antacid
- **Custom Dosing**: Specify dosage amount, frequency, and exact times
- **Instructions**: Add special instructions for patients
- **Duration**: Set start and end dates for medications

#### 🔍 Drug Interaction Detection
- **Interactive Graph Visualization**: Circular network showing medications as nodes with interaction edges
- **Severity Indicators**:
  - ⚠️ **Low**: Minor interactions, monitor if needed
  - 🟡 **Moderate**: Significant interactions, consider alternatives
  - 🔴 **High**: Serious interactions, requires attention
  - ⛔ **Contraindicated**: Do not combine these medications

#### 📈 Monitoring & Analytics
- **Adherence Tracking**: Monitor patient medication compliance
- **Alert System**: Notifications for high-risk drug interactions
- **Patient Reports**: Detailed reports on medication compliance and side effects

## 🏗️ Technical Architecture

### Technology Stack
- **Framework**: Flutter 3.9.2
- **Language**: Dart
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **State Management**: Provider
- **Local Storage**: SharedPreferences
- **Notifications**: flutter_local_notifications with timezone support
- **Permissions**: permission_handler


### Project Structure
```
lib/
├── main.dart                          # App entry point
├── models/                            # Data models
│   ├── medication.dart                # Medication model
│   ├── dose_log.dart                  # Dose logging model
│   ├── dose_intake.dart               # Dose intake tracking
│   ├── side_effect.dart               # Side effects model
│   ├── herbal_use.dart                # Herbal medicine model
│   ├── drug.dart                      # Drug database model
│   └── user.dart                      # User model
├── providers/                         # State management
│   ├── auth_provider.dart             # Authentication state
│   └── health_data_provider.dart      # Health data state
├── screens/                           # UI screens
│   ├── splash_screen.dart             # App splash screen
│   ├── patient_login_screen.dart      # Patient login
│   ├── clinician_login_screen.dart    # Clinician login
│   ├── patient_home_screen.dart       # Patient dashboard
│   ├── clinician_dashboard_screen.dart # Clinician dashboard
│   ├── medication_list_screen.dart    # Medication list
│   ├── prescribe_medication_screen.dart # Prescription form
│   ├── side_effects_screen.dart       # Side effects tracking
│   ├── herbal_use_screen.dart         # Herbal medicine tracking
│   └── history_screen.dart            # Medication history
├── services/                          # Business logic
│   ├── firestore_service.dart         # Firestore operations
│   └── notification_service.dart      # Notification scheduling
└── utils/
    └── theme.dart                     # App theming

android/
└── app/src/main/
    └── AndroidManifest.xml            # Android permissions
```
### First-Time Setup

1. **Grant Permissions**: On first launch, allow:
   - Notifications
   - Exact alarms and reminders
   - Internet access

2. **Create Account**:
   - **Patient**: Register with email, password, and doctor assignment
   - **Clinician**: Register with email, password, and specialization

3. **Initialize Data**: Default antacid medications are automatically loaded

## 📱 How to Use

### For Patients

1. **Login**: Use your email and password
2. **View Medications**: See all prescribed medications on home screen
3. **Check Schedule**: Scroll to "Medication Schedule" section
4. **Confirm Doses**: 
   - Wait for medication time (shows orange "Upcoming" 30 minutes before)
   - Click "Confirm [time] dose" button
   - System records intake and schedules next alarm
5. **Track Progress**: Monitor adherence percentage in Health Summary
6. **Report Issues**: Use "Side Effects" to log any adverse reactions

### For Clinicians

1. **Login**: Use your clinician credentials
2. **View Patients**: See all assigned patients on dashboard
3. **Prescribe Medication**:
   - Click patient card
   - Tap "Prescribe Medication"
   - Select drug from database
   - Enter dosage (e.g., "500mg")
   - Choose frequency (e.g., "Twice daily")
   - Set times (e.g., "08:00, 20:00")
   - Add instructions
   - Set start/end dates
   - Save prescription
4. **Monitor Adherence**: Check patient compliance rates
5. **Review Interactions**: View drug interaction graph for safety

## 🔒 Security & Privacy

- **Authentication**: Firebase Authentication with email/password
- **Data Encryption**: All data encrypted in transit and at rest
- **Role-Based Access**: Patients and clinicians have separate permissions
- **HIPAA Considerations**: Designed with healthcare privacy in mind
- **Local Storage**: Sensitive data stored securely using SharedPreferences

## 🔔 Notification System

### How It Works
1. **Prescription**: Clinician prescribes medication with specific times
2. **Scheduling**: System schedules exact alarms for each dose time
3. **Notification**: Patient receives notification at scheduled time
4. **Confirmation**: Patient clicks button to confirm dose taken
5. **Rescheduling**: System automatically schedules next dose alarm
6. **Persistence**: Alarms survive app restarts and device reboots

### Alarm Features
- **Exact Timing**: Uses `SCHEDULE_EXACT_ALARM` permission for precision
- **Daily Recurrence**: Automatically repeats daily at specified times
- **Timezone Support**: Handles timezone changes correctly
- **Battery Optimization**: Works even with battery saver enabled

## 🐛 Troubleshooting

### Alarms Not Working
1. Go to phone Settings → Apps → DawaTrack → Permissions
2. Enable "Alarms & reminders"
3. Enable "Notifications"
4. Disable battery optimization for DawaTrack

### Medications Not Showing
1. Ensure internet connection is active
2. Check Firebase Firestore rules allow read access
3. Verify patient is assigned to a clinician
4. Restart the app

### Login Issues
1. Verify email and password are correct
2. Check internet connection
3. Ensure Firebase Authentication is enabled
4. Try password reset if needed

## 🔄 Data Flow

### Medication Prescription Flow
```
Clinician → Prescribe Screen → FirestoreService.addMedication() 
→ Firestore Database → Real-time Listener → Patient's HealthDataProvider 
→ Patient Home Screen → NotificationService.scheduleMedicationReminders()
```

### Dose Confirmation Flow
```
Patient → Confirm Button → _confirmDoseIntake() 
→ Create DoseIntake & DoseLog → FirestoreService.recordDoseIntake() 
→ HealthDataProvider.logDose() → NotificationService.scheduleMedicationReminders() 
→ Calculate Next Dose Time → Schedule New Alarm → Show Confirmation
```

## 🎨 UI/UX Features

- **Material Design**: Clean, modern interface following Material Design guidelines
- **Google Fonts**: Custom typography for better readability
- **Color-Coded Status**: Intuitive visual indicators for medication status
- **Responsive Layout**: Adapts to different screen sizes
- **Dark Mode Ready**: Theme system supports dark mode (future enhancement)
- **Accessibility**: High contrast, readable fonts, clear icons

## 🚧 Future Enhancements

- [ ] Multi-language support
- [ ] Dark mode
- [ ] Medication refill reminders
- [ ] Pharmacy integration
- [ ] Family member monitoring
- [ ] Apple Health / Google Fit integration
- [ ] Medication interaction warnings in real-time
- [ ] Voice-activated dose confirmation
- [ ] Wearable device support
- [ ] Telemedicine integration
- [ ] AI-powered adherence predictions

