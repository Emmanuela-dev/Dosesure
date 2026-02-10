# DoseSure - Medication Management App

DoseSure is a comprehensive Flutter mobile application for medication management, tracking, and drug interaction monitoring. The app helps patients manage their medications while providing clinicians with tools to monitor patient adherence and detect potential drug interactions.

## Features

### Patient Features
- **Medication Tracking**: Add, view, and manage all medications with dosage, frequency, and schedule
- **Dose Logging**: Log medication doses with timestamp tracking
- **Side Effects Reporting**: Report and track side effects from medications
- **Herbal Medicine Tracking**: Monitor herbal supplements and traditional medicines
- **Adherence Monitoring**: Track medication adherence rates over time
- **Drug Interaction Alerts**: Visual graph showing potential drug interactions with severity indicators

### Clinician Features
- **Patient Dashboard**: Overview of all patients and their medication adherence
- **Drug Interaction Analysis**: Interactive graph visualization showing drug interactions
- **Patient Reports**: Detailed reports on medication compliance and side effects
- **Alert System**: Notifications for high-risk drug interactions

## Drug Interaction Graph

The Drug Interaction feature provides an interactive visualization of potential drug interactions:

- **Interactive Graph**: Circular network showing medications as nodes with interaction edges
- **Severity Levels**:
  -  Low: Minor interactions, monitor if needed
  -  Moderate: Significant interactions, consider alternatives
  - High: Serious interactions, requires attention
  - Contraindicated: Do not combine these medications
- **Detailed Information**: Tap on any interaction to see:
  - Description of the interaction
  - Possible symptoms
  - Recommendations for management

### Supported Interactions
The app detects various drug interactions including:
- Aspirin + Warfarin (bleeding risk)
- Lisinopril + Potassium (hyperkalemia)
- Ibuprofen + Aspirin (reduced cardioprotection)
- Amlodipine + Simvastatin (rhabdomyolysis risk)
- Antacids + Antibiotics (reduced absorption)
- Antacids + Iron supplements (reduced absorption)
- Metformin + Contrast dye (lactic acidosis)



## Dependencies

- **provider**: State management
- **intl**: Internationalization and date formatting
- **shared_preferences**: Local storage
- **google_fonts**: Google Fonts integration
- **flutter_local_notifications**: Local notifications
- **firebase_core**: Firebase core
- **cloud_firestore**: Firestore database
- **firebase_auth**: Authentication

## Drug Interaction Detection

The app uses a rule-based system to detect drug interactions. Each interaction includes:
- Severity level
- Description of the interaction effect
- List of possible symptoms
- Clinical recommendations

