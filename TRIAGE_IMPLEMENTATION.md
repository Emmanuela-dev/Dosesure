# Triage System Implementation Summary

## Problem Addressed

**Legal Liability Risk**: Real-time notifications to clinicians for adverse events create legal duty of care. If a clinician doesn't see a notification for 48 hours and the patient suffers harm, the clinician and app could be liable.

## Solution Implemented

### Three-Tier Triage Algorithm

#### 1. Emergency Symptoms → Direct to 911
- **No clinician notification** (avoids liability)
- Patient shown full-screen emergency alert
- One-tap call to 911
- Clear disclaimer: "Do not wait for your doctor"

#### 2. Urgent Symptoms → Patient Contacts Provider
- Dashboard notification only (no push/real-time alert)
- Patient instructed to contact provider within 24 hours
- Flagged as "URGENT" on clinician dashboard

#### 3. Routine Symptoms → Dashboard Review
- Standard logging to dashboard
- Clinician reviews during normal workflow
- No special alerts

## Code Changes

### New Files Created

#### 1. `symptom_triage_service.dart`
```dart
- Emergency symptom keywords (23 symptoms)
- Urgent symptom keywords (12 symptoms)
- Classification algorithm
- Triage messages for each level
```

### Models Updated

#### `side_effect.dart`
Added fields:
- `triageLevel`: 'emergency', 'urgent', or 'routine'
- `requiresEmergencyAction`: boolean flag
- `clinicianNotified`: tracks notification status
- `clinicianViewedAt`: timestamp for legal documentation

### UI Updates

#### `side_effects_screen.dart`
1. **Emergency Dialog**:
   - Red alert with emergency icon
   - "CALL 911" button with phone integration
   - Legal disclaimer about app limitations
   - Cannot be dismissed without acknowledgment

2. **Urgent Dialog**:
   - Orange warning with guidance
   - Instructions to contact provider within 24 hours
   - Reminder that clinician may not see immediately

3. **Emergency Warning Banner**:
   - Displayed at top of side effect form
   - Lists emergency symptoms
   - Instructs to call 911 immediately

4. **Visual Indicators**:
   - Emergency reports: Red border, "EMERGENCY" badge
   - Urgent reports: Orange border, "URGENT" badge
   - Routine reports: Standard display

### Dependencies Added

```yaml
url_launcher: ^6.2.5  # For one-tap 911 calling
```

## User Experience

### Patient Flow - Emergency Symptom

1. Patient enters "difficulty breathing"
2. Triage algorithm detects emergency keyword
3. **Emergency dialog appears**:
   ```
   ⚠️ MEDICAL EMERGENCY
   
   These symptoms require immediate medical attention.
   
   CALL EMERGENCY SERVICES (911) or go to the 
   nearest emergency room NOW.
   
   Do not wait for your doctor to respond.
   
   [CALL 911 BUTTON]  [I understand]
   ```
4. Patient taps "CALL 911" → Phone dialer opens
5. Report logged but marked "Patient directed to emergency services"

### Patient Flow - Urgent Symptom

1. Patient enters "persistent vomiting"
2. Triage algorithm detects urgent keyword
3. **Urgent dialog appears**:
   ```
   ⚠️ Urgent Medical Attention
   
   These symptoms need prompt medical evaluation.
   
   Contact your healthcare provider within 24 hours.
   If symptoms worsen, seek emergency care immediately.
   
   Your healthcare provider will be notified, but may 
   not see this immediately. Contact them directly.
   
   [I understand]
   ```
4. Report logged and flagged on clinician dashboard

### Patient Flow - Routine Symptom

1. Patient enters "mild nausea"
2. Standard confirmation
3. Report logged to dashboard

## Legal Protection Mechanisms

### 1. No Real-Time Clinician Notification
- Emergency symptoms bypass clinician entirely
- Urgent symptoms go to dashboard only (no push notifications)
- Eliminates expectation of immediate response

### 2. Patient Self-Advocacy
- Emergency symptoms direct patient to 911
- Urgent symptoms instruct patient to contact provider directly
- App is documentation tool, not emergency communication

### 3. Clear Disclaimers
- Emergency dialog explicitly states clinician won't be notified in real-time
- Side effect screen has prominent emergency warning
- Terms of service exclude emergency use

### 4. Audit Trail
- All reports timestamped
- Triage level recorded
- Patient actions logged (e.g., "Emergency dialog shown")
- Clinician review timestamps captured

## Clinician Dashboard

### Side Effects Panel
- **Emergency Reports**: 
  - Red border
  - "EMERGENCY" badge
  - Note: "Patient directed to emergency services"
  
- **Urgent Reports**:
  - Orange border
  - "URGENT" badge
  - Recommended review within 24 hours

- **Routine Reports**:
  - Standard display
  - Review during normal workflow

### Acknowledgment System
- Clinician can mark as "Reviewed"
- Timestamp recorded
- Comment section for response
- Audit trail maintained

## Emergency Symptoms List

Classified as requiring immediate 911 call:
- Difficulty breathing
- Chest pain
- Severe allergic reaction / Anaphylaxis
- Swelling of face or throat
- Severe rash with blistering/peeling
- Stevens-Johnson syndrome
- Seizures
- Loss of consciousness
- Severe bleeding
- Blood in stool/urine
- Severe abdominal pain
- Confusion/slurred speech
- Paralysis
- Severe headache with vision loss
- Irregular heartbeat/fainting

## Urgent Symptoms List

Classified as requiring provider contact within 24 hours:
- Persistent vomiting
- Severe diarrhea
- High fever
- Severe dizziness
- Persistent headache
- Unusual bleeding
- Severe nausea
- Jaundice
- Dark urine
- Severe fatigue
- Rapid weight loss
- Severe pain

## Benefits

### For Patients
- Clear guidance on when to seek emergency care
- No confusion about app's role
- Immediate action for serious symptoms
- Comprehensive symptom documentation

### For Clinicians
- Protected from liability for delayed response
- No expectation of 24/7 app monitoring
- Dashboard review during normal workflow
- Audit trail for legal protection

### For App/Organization
- Reduced legal liability
- Compliance with medical best practices
- Clear scope definition
- Regulatory alignment

## Testing Recommendations

1. **Keyword Testing**: Verify all emergency/urgent keywords trigger correct triage
2. **UI Testing**: Ensure emergency dialog cannot be bypassed
3. **Phone Integration**: Test 911 calling on various devices
4. **Audit Logging**: Verify all actions are timestamped
5. **Disclaimer Display**: Confirm disclaimers shown at appropriate times

## Future Enhancements

- [ ] Multi-language support for symptom keywords
- [ ] Machine learning for symptom classification
- [ ] Integration with poison control centers
- [ ] Geolocation for nearest emergency room
- [ ] Emergency contact notification (family members)

## Conclusion

This triage system addresses legal liability by:
1. Directing emergency symptoms to 911, not clinicians
2. Eliminating real-time notification expectations
3. Providing clear patient guidance
4. Creating comprehensive audit trails
5. Aligning with medical best practices

The app serves as a documentation and monitoring tool, NOT an emergency communication system.
