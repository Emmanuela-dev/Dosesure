# Quick Setup Guide - Anticoagulant Drug Interactions

## What's New?

✅ **4 Anticoagulant drugs** added to database with detailed interaction profiles
✅ **Automatic interaction detection** when prescribing medications
✅ **Real-time warnings** shown to clinicians before prescribing
✅ **Override mechanism** for clinicians to proceed with caution
✅ **Severity-based alerts** (Low, Moderate, High, Contraindicated)

## Setup Steps

### 1. Update Dependencies (if needed)
No new dependencies required! The feature uses existing Flutter and Firebase packages.

### 2. Database Initialization
The anticoagulant drugs will be automatically added to your Firestore database when you run the app.

**What happens on first run:**
- App checks if anticoagulant drugs exist in Firestore
- If not found, automatically creates 4 anticoagulant drugs:
  - Warfarin (with 9 interactions)
  - Heparin Sodium (with 7 interactions)
  - Enoxaparin (with 6 interactions)
  - Rivaroxaban (with 7 interactions)

### 3. Firestore Rules
Your existing Firestore rules already allow drug read/write access. No changes needed.

### 4. Test the Feature

#### Test Case 1: No Interactions
1. Login as clinician
2. Select a patient with NO active medications
3. Go to "Prescribe Medication"
4. Select category: "Anticoagulant"
5. Select drug: "Warfarin"
6. **Expected**: Green message "No drug interactions detected"
7. Complete prescription normally

#### Test Case 2: Interaction Detected
1. First, prescribe Warfarin to a patient (as above)
2. Then prescribe a second medication that interacts
3. For testing, you can:
   - Add Abciximab to the database, OR
   - Manually add a medication named "Abciximab" to the patient
4. Try to prescribe Warfarin again
5. **Expected**: Red warning appears immediately when selecting Warfarin
6. Click "Save" to prescribe
7. **Expected**: Detailed interaction dialog appears
8. Type "closely monitoring" to override
9. **Expected**: Prescription succeeds with warning logged

## How It Works

### For Clinicians

**When selecting a drug:**
```
1. Select drug category → Select specific drug
2. System checks patient's active medications
3. If interactions found → Red warning appears
4. Continue with prescription → Detailed dialog shows
5. Review interactions → Override or Cancel
```

**Visual Indicators:**
- 🔵 **Blue** = Checking for interactions...
- ✅ **Green** = No interactions detected
- ⚠️ **Red** = Interactions detected (count shown)

**Interaction Dialog:**
- Shows all detected interactions
- Displays severity level for each
- Explains the interaction mechanism
- Requires typing "closely monitoring" to override

### For Patients

**No changes to patient experience:**
- Patients receive medications as prescribed
- Reminders work the same way
- No interaction warnings shown to patients (clinician responsibility)

## Anticoagulant Drugs Available

| Drug | Brand Names | Dosages | High Alert |
|------|-------------|---------|------------|
| Warfarin | Coumadin, Jantoven | 1mg, 3mg, 5mg | ✅ Yes |
| Heparin Sodium | Defencath, Heparin Leo | 5mL Vial | ✅ Yes |
| Enoxaparin | - | 40mg/0.4mL, 80mg/0.8mL | ✅ Yes |
| Rivaroxaban | Xarelto, Rivaroxaban Accord | 10mg, 15mg, 20mg | ✅ Yes |

## Common Interactions

### Warfarin Interactions:
- **Abciximab** (High) - Increased bleeding risk
- **Abacavir** (Moderate) - Increased Warfarin levels
- **Abametapir** (Moderate) - Increased Warfarin concentration
- **Abatacept** (Moderate) - Increased Warfarin concentration
- **Abemaciclib** (Moderate) - Increased metabolism

### Heparin Interactions:
- **Abciximab** (High) - Increased bleeding risk
- **Aceclofenac** (High) - Increased bleeding/hemorrhage
- **Acemetacin** (High) - Increased bleeding/hemorrhage
- **Acenocoumarol** (High) - Increased bleeding risk
- **Acebutolol** (Moderate) - Increased hyperkalemia risk

### Enoxaparin Interactions:
- **Abciximab** (High) - Increased bleeding risk
- **Aceclofenac** (High) - Increased bleeding/hemorrhage
- **Acemetacin** (High) - Increased bleeding/hemorrhage
- **Acenocoumarol** (High) - Increased bleeding risk
- **Acebutolol** (Moderate) - Increased hyperkalemia risk

### Rivaroxaban Interactions:
- **Abciximab** (High) - Increased anticoagulant activity
- **Abacavir** (Moderate) - Increased Rivaroxaban levels
- **Abametapir** (Moderate) - Increased Rivaroxaban concentration
- **Abatacept** (Moderate) - Increased metabolism
- **Abemaciclib** (Moderate) - Increased Rivaroxaban levels

## Troubleshooting

### Issue: Drugs not showing in dropdown
**Solution:**
1. Check internet connection
2. Verify Firestore rules allow read access to 'drugs' collection
3. Check console for initialization errors
4. Try restarting the app

### Issue: Interactions not detected
**Solution:**
1. Ensure patient has active medications (check `isActive` field)
2. Verify drug names match exactly (case-insensitive matching)
3. Check that `detailedInteractions` field exists in drug documents
4. Review console logs for errors

### Issue: Override not working
**Solution:**
1. Type exactly: "closely monitoring" (lowercase, with space)
2. Check for typos
3. Ensure dialog is not dismissed accidentally

### Issue: Database not initializing
**Solution:**
1. Check Firebase connection
2. Verify Firestore rules allow write access
3. Check console for error messages
4. Manually trigger initialization from AuthProvider

## Code Locations

**Models:**
- `lib/models/drug.dart` - Drug model with interactions
- `lib/models/drug_interaction.dart` - Interaction model

**Services:**
- `lib/services/firestore_service.dart` - Interaction checking logic
- `lib/services/drug_database_service.dart` - Drug initialization

**Screens:**
- `lib/screens/prescribe_medication_screen.dart` - Prescription UI with warnings

## Next Steps

1. **Test thoroughly** with different scenarios
2. **Add more interacting drugs** to test with (e.g., Abciximab, Acebutolol)
3. **Monitor logs** for any errors during interaction checking
4. **Collect feedback** from clinicians on warning clarity
5. **Expand database** with more anticoagulants and interactions

## Support

For issues or questions:
1. Check console logs for detailed error messages
2. Review `ANTICOAGULANT_INTERACTIONS.md` for detailed documentation
3. Verify Firestore data structure matches expected format
4. Test with simple cases first (one drug, then two drugs)

## Important Notes

⚠️ **This is a pilot implementation for testing purposes**
- Interaction data from DrugBank and KEML
- Future versions will use approved clinical databases
- Always verify interactions with authoritative sources
- Clinician judgment supersedes automated warnings

✅ **Production Readiness**
- Before production use, validate all interaction data
- Add comprehensive logging for audit trails
- Implement interaction override tracking
- Add patient notification system
- Conduct thorough clinical validation
