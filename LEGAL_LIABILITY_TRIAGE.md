# Legal Liability & Triage System Documentation

## The Clinician's Burden Problem

### Legal Liability Issue
When a patient reports a side effect or adverse event through the app, creating a real-time notification to the clinician creates legal liability:

1. **Delayed Response Risk**: If a clinician doesn't see the notification for 48 hours, who is responsible?
2. **Proof of Receipt**: How can we ensure the physician has seen and acted on the report?
3. **Emergency Situations**: Critical symptoms require immediate action, not delayed clinician review

### Legal Precedents
- **Duty of Care**: Once notified, clinicians have a legal duty to respond appropriately
- **Standard of Care**: Delayed response to serious symptoms can constitute negligence
- **Documentation**: Electronic health records create legal evidence of notification timing

## DawaTrack's Triage Solution

### Three-Tier Triage System

#### 1. EMERGENCY (Red Flag Symptoms)
**Action**: Automated prompt for immediate emergency care

**Symptoms Classified as Emergency**:
- Difficulty breathing
- Chest pain
- Severe allergic reaction / Anaphylaxis
- Swelling of face or throat
- Severe rash with blistering or peeling skin
- Stevens-Johnson syndrome indicators
- Seizures
- Loss of consciousness
- Severe bleeding
- Blood in stool or urine
- Severe abdominal pain
- Confusion or slurred speech
- Paralysis
- Severe headache with vision loss
- Irregular heartbeat / Fainting

**Patient Response**:
- Immediate full-screen alert: "MEDICAL EMERGENCY"
- Direct prompt: "CALL 911 or go to nearest emergency room NOW"
- One-tap emergency call button
- Clear disclaimer: "Do not wait for your doctor to respond"
- Report logged but NOT relied upon for clinician notification

**Clinician Notification**: 
- Report logged to dashboard for follow-up
- NO real-time notification (to avoid liability)
- Marked as "Patient directed to emergency services"

**Legal Protection**:
- App explicitly states it does NOT replace emergency services
- Patient instructed to seek immediate care independently
- Clinician not expected to respond in real-time

#### 2. URGENT (Requires Prompt Attention)
**Action**: Dashboard notification + patient guidance

**Symptoms Classified as Urgent**:
- Persistent vomiting
- Severe diarrhea
- High fever
- Severe dizziness
- Persistent headache
- Unusual bleeding
- Severe nausea
- Jaundice (yellowing of skin/eyes)
- Dark urine
- Severe fatigue
- Rapid weight loss
- Severe pain

**Patient Response**:
- Alert dialog: "Urgent Medical Attention"
- Guidance: "Contact your healthcare provider within 24 hours"
- Warning: "If symptoms worsen, seek emergency care immediately"
- Report logged to clinician dashboard

**Clinician Notification**:
- Flagged on dashboard with "URGENT" badge
- Visible in side effects review section
- NO push notification or real-time alert
- Clinician reviews during normal workflow

**Legal Protection**:
- Patient instructed to contact provider directly
- App serves as supplementary documentation tool
- No expectation of immediate clinician response through app

#### 3. ROUTINE (Standard Dashboard Review)
**Action**: Dashboard logging only

**Symptoms Classified as Routine**:
- Mild nausea
- Mild headache
- Drowsiness
- Dry mouth
- Mild stomach upset
- Minor skin irritation
- Other non-urgent symptoms

**Patient Response**:
- Confirmation: "Side effect reported to your healthcare provider"
- Guidance: "If symptoms worsen, report them immediately"

**Clinician Notification**:
- Logged to dashboard
- Reviewed during routine patient monitoring
- No special flags or alerts

### Implementation Details

#### Triage Algorithm
```dart
class SymptomTriage {
  static TriageLevel classifySymptom(String description) {
    // Keyword matching against emergency/urgent symptom lists
    // Returns: emergency, urgent, or routine
  }
}
```

#### Data Model
```dart
class SideEffect {
  final String triageLevel;              // 'emergency', 'urgent', 'routine'
  final bool requiresEmergencyAction;    // true for emergency level
  final bool clinicianNotified;          // false for emergency (patient directed to 911)
  final DateTime? clinicianViewedAt;     // timestamp when clinician reviews
}
```

#### User Flow

**Emergency Symptoms**:
1. Patient enters symptom description
2. Triage algorithm detects emergency keywords
3. Full-screen emergency dialog appears
4. "CALL 911" button with direct phone integration
5. Disclaimer: "This app does NOT replace emergency services"
6. Report logged for clinician follow-up only

**Urgent Symptoms**:
1. Patient enters symptom description
2. Triage algorithm detects urgent keywords
3. Alert dialog with guidance to contact provider within 24 hours
4. Report logged and flagged on clinician dashboard
5. Patient instructed to contact provider directly if needed

**Routine Symptoms**:
1. Patient enters symptom description
2. Standard confirmation message
3. Report logged to dashboard
4. Clinician reviews during normal workflow

### Legal Safeguards

#### Disclaimers
1. **App Launch**: Terms of service clearly state app is not for emergencies
2. **Side Effect Screen**: Prominent emergency symptoms warning
3. **Emergency Dialog**: Explicit statement that clinician will NOT be notified in real-time
4. **Urgent Dialog**: Clear instruction to contact provider directly

#### Documentation
- All side effects timestamped
- Triage level recorded
- Patient actions logged (e.g., "Emergency dialog shown")
- Clinician review timestamps captured

#### Liability Protection
1. **No Real-Time Notification**: Clinicians not expected to monitor app 24/7
2. **Patient Self-Advocacy**: Emergency symptoms direct patient to 911, not clinician
3. **Clear Communication**: Patients informed of app limitations
4. **Standard of Care**: Aligns with medical best practices (emergency = 911, not app)

### Clinician Dashboard Features

#### Side Effects Review Panel
- **Emergency Reports**: Marked "Patient directed to emergency services"
- **Urgent Reports**: Flagged with orange "URGENT" badge
- **Routine Reports**: Standard display
- **Viewed Status**: Timestamp when clinician reviews each report
- **Response Tracking**: Comment section for clinician notes

#### Acknowledgment System
- Clinician can mark reports as "Reviewed"
- Timestamp recorded for legal documentation
- Optional response/comment to patient
- Audit trail maintained

### Best Practices

#### For Patients
- Use 911 for emergencies, not the app
- Contact provider directly for urgent concerns
- App is supplementary documentation tool
- Report all symptoms for comprehensive record

#### For Clinicians
- Review dashboard regularly (daily recommended)
- Acknowledge urgent reports within 24 hours
- Document review and actions taken
- Educate patients on proper emergency response

### Regulatory Compliance

#### HIPAA Considerations
- All data encrypted and access-controlled
- Audit logs maintained
- Patient consent obtained

#### Medical Device Classification
- App is wellness/documentation tool, not diagnostic device
- Does not replace clinical judgment
- Not intended for emergency use

#### Informed Consent
- Patients acknowledge app limitations
- Terms of service clearly define scope
- Emergency use explicitly excluded

## Comparison: Before vs After

### Before (Liability Risk)
- All side effects trigger clinician notification
- Expectation of real-time response
- Legal duty created upon notification
- No differentiation by severity
- Clinician liable for delayed response

### After (Liability Protection)
- Emergency symptoms → Patient directed to 911
- Urgent symptoms → Patient contacts provider directly
- Routine symptoms → Dashboard review
- No expectation of real-time clinician monitoring
- App serves as documentation, not emergency communication

## References

1. **Medical Malpractice Law**: Duty of care and standard of care requirements
2. **FDA Guidance**: Mobile medical applications guidance (2015)
3. **AMA Guidelines**: Telemedicine and digital health best practices
4. **HIPAA**: Privacy and security requirements for health apps

## Disclaimer

DawaTrack is a medication management and documentation tool. It is NOT intended for emergency use. In case of medical emergency, call 911 or go to the nearest emergency room immediately. Do not rely on this app for urgent medical communication with your healthcare provider.
