# DoseSure (DawaTrack) - System Architecture

## 1. Overview
DoseSure is a Flutter-based mobile medication adherence tracking application designed for patients and clinicians in Kenya. The system enables medication management, dose tracking with photo verification, drug interaction checking, and real-time monitoring.

## 2. Architecture Pattern
**Pattern**: Model-View-Provider (MVP) with Clean Architecture principles
- **Models**: Data entities and business logic
- **Views**: UI screens and widgets
- **Providers**: State management using Provider pattern
- **Services**: Business logic and external integrations

## 3. System Components

### 3.1 Frontend Layer (Flutter)
```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
├─────────────────────────────────────────────────────────┤
│  Screens/                                                │
│  ├── Patient Screens                                     │
│  │   ├── PatientHomeScreen                              │
│  │   ├── MedicationListScreen                           │
│  │   ├── SideEffectsScreen                              │
│  │   ├── HerbalUseScreen                                │
│  │   ├── AdherenceScreen                                │
│  │   └── HistoryScreen                                  │
│  │                                                       │
│  ├── Clinician Screens                                  │
│  │   ├── ClinicianDashboardScreen                       │
│  │   ├── PatientDetailsScreen                           │
│  │   ├── PrescribeMedicationScreen                      │
│  │   ├── DrugInteractionScreen                          │
│  │   └── ClinicianReportsScreen                         │
│  │                                                       │
│  └── Auth Screens                                       │
│      ├── RoleSelectionScreen                            │
│      ├── PatientLoginScreen / RegisterScreen            │
│      └── ClinicianLoginScreen / RegisterScreen          │
└─────────────────────────────────────────────────────────┘
```

### 3.2 State Management Layer
```
┌─────────────────────────────────────────────────────────┐
│                    Provider Layer                        │
├─────────────────────────────────────────────────────────┤
│  ├── AuthProvider                                        │
│  │   ├── User authentication state                      │
│  │   ├── Login/Logout/Register                          │
│  │   └── Current user management                        │
│  │                                                       │
│  └── HealthDataProvider                                 │
│      ├── Medications stream                             │
│      ├── Dose logs stream                               │
│      ├── Side effects stream                            │
│      ├── Herbal uses stream                             │
│      └── Adherence calculations                         │
└─────────────────────────────────────────────────────────┘
```

### 3.3 Business Logic Layer
```
┌─────────────────────────────────────────────────────────┐
│                    Services Layer                        │
├─────────────────────────────────────────────────────────┤
│  ├── FirestoreService                                   │
│  │   ├── CRUD operations for all entities              │
│  │   ├── Real-time data streams                         │
│  │   └── Query optimization                             │
│  │                                                       │
│  ├── NotificationService                                │
│  │   ├── Alarm scheduling                               │
│  │   ├── Medication reminders                           │
│  │   └── Alarm management                               │
│  │                                                       │
│  ├── PhotoVerificationService                           │
│  │   ├── Image capture                                  │
│  │   ├── Firebase Storage upload                        │
│  │   └── Photo proof management                         │
│  │                                                       │
│  ├── MedicationExpiryService                            │
│  │   ├── Expiry date checking                           │
│  │   ├── Auto-deactivation                              │
│  │   └── Expiry notifications                           │
│  │                                                       │
│  ├── ReportExportService                                │
│  │   ├── PDF generation                                 │
│  │   ├── CSV export                                     │
│  │   └── Report sharing                                 │
│  │                                                       │
│  └── DrugDatabaseService                                │
│      ├── Drug interaction database                      │
│      ├── Anticoagulant data                             │
│      └── Interaction checking                           │
└─────────────────────────────────────────────────────────┘
```

### 3.4 Data Layer
```
┌─────────────────────────────────────────────────────────┐
│                      Models Layer                        │
├─────────────────────────────────────────────────────────┤
│  ├── User (Patient/Clinician)                           │
│  ├── Medication                                          │
│  ├── DoseLog                                             │
│  ├── DoseIntake                                          │
│  ├── SideEffect                                          │
│  ├── HerbalUse                                           │
│  ├── Drug                                                │
│  ├── DrugInteraction                                     │
│  └── Comment                                             │
└─────────────────────────────────────────────────────────┘
```

### 3.5 Backend Layer (Firebase)
```
┌─────────────────────────────────────────────────────────┐
│                   Firebase Services                      │
├─────────────────────────────────────────────────────────┤
│  ├── Firebase Authentication                            │
│  │   └── Email/Password authentication                  │
│  │                                                       │
│  ├── Cloud Firestore (NoSQL Database)                   │
│  │   ├── users/                                         │
│  │   ├── medications/                                   │
│  │   ├── doseLogs/                                      │
│  │   ├── doseIntakes/                                   │
│  │   ├── sideEffects/                                   │
│  │   ├── herbalUses/                                    │
│  │   ├── drugs/                                         │
│  │   └── comments/                                      │
│  │                                                       │
│  └── Firebase Storage                                   │
│      └── dose_photos/{userId}/{medicationId}/           │
└─────────────────────────────────────────────────────────┘
```

## 4. Data Flow Architecture

### 4.1 Patient Medication Tracking Flow
```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Patient    │────▶│ Alarm Rings  │────▶│ Stop Alarm   │
│   Login      │     │ (Continuous) │     │   Button     │
└──────────────┘     └──────────────┘     └──────────────┘
                                                   │
                                                   ▼
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  Firestore   │◀────│  Log Dose    │◀────│ Confirm Dose │
│   Updated    │     │  + Photo     │     │  (Optional)  │
└──────────────┘     └──────────────┘     └──────────────┘
                            │
                            ▼
                    ┌──────────────┐
                    │  Real-time   │
                    │  Adherence   │
                    │  Update      │
                    └──────────────┘
```

### 4.2 Clinician Prescription Flow
```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  Clinician   │────▶│   Select     │────▶│   Choose     │
│   Login      │     │   Patient    │     │   Drug       │
└──────────────┘     └──────────────┘     └──────────────┘
                                                   │
                                                   ▼
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  Schedule    │────▶│   Check      │────▶│  Prescribe   │
│  Alarms      │     │ Interactions │     │  Medication  │
└──────────────┘     └──────────────┘     └──────────────┘
                                                   │
                                                   ▼
                                          ┌──────────────┐
                                          │  Firestore   │
                                          │   Saved      │
                                          └──────────────┘
                                                   │
                                                   ▼
                                          ┌──────────────┐
                                          │  Patient's   │
                                          │  Real-time   │
                                          │   Update     │
                                          └──────────────┘
```

### 4.3 Real-time Synchronization Flow
```
┌─────────────────────────────────────────────────────────┐
│                  Firestore Real-time                     │
│                    Stream Listeners                      │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  Clinician Deletes    ──────────▶   Firestore           │
│   Medication                         Document           │
│                                      Deleted            │
│                                         │               │
│                                         ▼               │
│                                   Stream Detects        │
│                                     Change              │
│                                         │               │
│                                         ▼               │
│  Patient's UI     ◀──────────    Provider Updates      │
│   Auto-updates                    Medication List      │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

## 5. Database Schema

### 5.1 Firestore Collections

#### users/
```json
{
  "id": "string",
  "email": "string",
  "name": "string",
  "role": "int (0=patient, 1=clinician)",
  "doctorId": "string (optional)",
  "createdAt": "timestamp"
}
```

#### medications/
```json
{
  "id": "string",
  "userId": "string",
  "name": "string",
  "dosage": "string",
  "frequency": "string",
  "times": ["string"],
  "instructions": "string",
  "startDate": "string (ISO8601)",
  "endDate": "string (ISO8601, optional)",
  "isActive": "boolean",
  "prescribedBy": "string",
  "prescribedByName": "string",
  "patientId": "string",
  "createdAt": "timestamp"
}
```

#### doseLogs/
```json
{
  "id": "string",
  "userId": "string",
  "medicationId": "string",
  "scheduledTime": "timestamp",
  "takenTime": "timestamp",
  "taken": "boolean",
  "photoProofUrl": "string (optional)",
  "isVerified": "boolean",
  "createdAt": "timestamp"
}
```

#### doseIntakes/
```json
{
  "id": "string",
  "userId": "string",
  "medicationId": "string",
  "medicationName": "string",
  "takenAt": "timestamp",
  "scheduledTime": "string",
  "nextDueTime": "timestamp",
  "photoProofUrl": "string (optional)",
  "isVerified": "boolean",
  "createdAt": "timestamp"
}
```

#### sideEffects/
```json
{
  "id": "string",
  "userId": "string",
  "medicationId": "string",
  "description": "string",
  "severity": "string",
  "reportedDate": "timestamp",
  "notes": "string (optional)",
  "createdAt": "timestamp"
}
```

#### herbalUses/
```json
{
  "id": "string",
  "userId": "string",
  "name": "string",
  "localName": "string (optional)",
  "botanicalGenus": "string (optional)",
  "dosage": "string",
  "frequency": "string",
  "purpose": "string",
  "notes": "string (optional)",
  "createdAt": "timestamp"
}
```

#### drugs/
```json
{
  "id": "string",
  "name": "string",
  "genericName": "string",
  "brandNames": ["string"],
  "category": "string",
  "isHighAlert": "boolean",
  "commonDosages": ["string"],
  "use": "string",
  "indications": "string",
  "warnings": "string",
  "detailedInteractions": [
    {
      "interactingDrugId": "string",
      "interactingDrugName": "string",
      "description": "string",
      "severity": "string"
    }
  ]
}
```

#### comments/
```json
{
  "id": "string",
  "targetId": "string",
  "targetType": "string",
  "targetOwnerId": "string",
  "authorId": "string",
  "authorName": "string",
  "authorRole": "string",
  "content": "string",
  "isRead": "boolean",
  "createdAt": "timestamp"
}
```

## 6. Key Features & Implementation

### 6.1 Medication Adherence Tracking
- **Self-reported**: Patient confirms dose without photo
- **Verified**: Patient confirms dose with photo proof
- **Real-time calculation**: Adherence percentage updates instantly
- **Visual indicators**: Color-coded adherence rates (Green ≥80%, Orange ≥60%, Red <60%)

### 6.2 Alarm System
- **Continuous ringing**: Alarm loops until manually stopped
- **Manual toggle**: Red "STOP" button appears when alarm rings
- **Scheduled reminders**: Alarms set for each medication time
- **Auto-scheduling**: Alarms reschedule for next day automatically

### 6.3 Photo Verification
- **Camera integration**: Image picker for dose photos
- **Firebase Storage**: Secure cloud storage for photos
- **Verification flag**: Distinguishes verified vs self-reported doses
- **Research-backed**: Addresses 20-30% overestimation in self-reporting

### 6.4 Drug Interaction Checking
- **Pre-loaded database**: Anticoagulant drugs with interactions
- **Real-time checking**: Validates new prescriptions against active medications
- **Severity levels**: High, Moderate, Low interaction warnings
- **Detailed descriptions**: Specific interaction effects and recommendations

### 6.5 Clinician Portal
- **Patient management**: View and manage multiple patients
- **Prescription workflow**: Drug selection, dosage, scheduling
- **Monitoring dashboard**: Real-time adherence and side effects
- **Comment system**: Two-way communication with patients
- **Report generation**: PDF/CSV export of patient data

### 6.6 Medication Expiry Management
- **Auto-deactivation**: Medications past end date automatically deactivated
- **Visual warnings**: Orange badge for medications expiring within 2 days
- **Background checking**: Runs on app launch and patient view

## 7. Security & Privacy

### 7.1 Authentication
- Firebase Authentication with email/password
- Role-based access control (Patient/Clinician)
- Secure session management

### 7.2 Data Protection
- Firestore security rules for data isolation
- Patient data only accessible by assigned clinician
- Encrypted data transmission (HTTPS)
- Photo storage with access control

### 7.3 HIPAA Considerations
- Patient consent for photo verification
- Secure data storage and transmission
- Audit trails via Firestore timestamps
- Data retention policies

## 8. Technology Stack

### 8.1 Frontend
- **Framework**: Flutter 3.9.2
- **Language**: Dart
- **State Management**: Provider 6.1.2
- **UI Components**: Material Design

### 8.2 Backend
- **BaaS**: Firebase
  - Authentication
  - Cloud Firestore
  - Cloud Storage
- **Hosting**: Firebase Hosting (optional)

### 8.3 Key Dependencies
- `alarm: ^4.0.2` - Medication reminders
- `image_picker: ^1.0.7` - Photo capture
- `pdf: ^3.10.7` - Report generation
- `cloud_firestore: ^5.5.2` - Database
- `firebase_storage: ^12.3.6` - File storage
- `provider: ^6.1.2` - State management

## 9. Scalability Considerations

### 9.1 Database Optimization
- Indexed queries for fast retrieval
- Pagination for large datasets
- Composite indexes for complex queries
- Stream listeners for real-time updates

### 9.2 Performance
- Lazy loading of medication lists
- Image compression before upload
- Cached data for offline access
- Optimized widget rebuilds

### 9.3 Future Enhancements
- Multi-language support (Swahili, English)
- SMS reminders for low-connectivity areas
- Offline mode with sync
- AI-powered adherence predictions
- Integration with pharmacy systems
- Wearable device integration

## 10. Deployment Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Production Setup                      │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────┐         ┌──────────────┐             │
│  │   Android    │         │     iOS      │             │
│  │   APK/AAB    │         │     IPA      │             │
│  └──────────────┘         └──────────────┘             │
│         │                        │                      │
│         └────────────┬───────────┘                      │
│                      ▼                                  │
│            ┌──────────────────┐                         │
│            │  Firebase Cloud  │                         │
│            │   Infrastructure │                         │
│            └──────────────────┘                         │
│                      │                                  │
│         ┌────────────┼────────────┐                     │
│         ▼            ▼            ▼                     │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐               │
│  │   Auth   │ │Firestore │ │ Storage  │               │
│  └──────────┘ └──────────┘ └──────────┘               │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

## 11. Error Handling & Logging

### 11.1 Error Handling
- Try-catch blocks for all async operations
- User-friendly error messages
- Fallback mechanisms for failed operations
- Graceful degradation for offline scenarios

### 11.2 Logging
- Debug prints for development
- Firebase Crashlytics (optional)
- Error tracking and reporting
- Performance monitoring

## 12. Testing Strategy

### 12.1 Unit Tests
- Model serialization/deserialization
- Service method logic
- Provider state management
- Utility functions

### 12.2 Integration Tests
- Firebase operations
- Authentication flows
- Data synchronization
- Alarm scheduling

### 12.3 Widget Tests
- UI component rendering
- User interactions
- Navigation flows
- Form validations

### 12.4 End-to-End Tests
- Complete user journeys
- Patient medication tracking
- Clinician prescription workflow
- Real-time synchronization

---

**Document Version**: 1.0  
**Last Updated**: 2024  
**Maintained By**: DoseSure Development Team
