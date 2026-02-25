# Anticoagulant Drug Interaction Detection - Implementation Guide

## Overview

This document describes the implementation of the drug interaction detection system for anticoagulant medications in DawaTrack. The system automatically detects potential drug interactions when clinicians prescribe medications to patients who are already taking other drugs.

## Key Features

### 1. **Interaction Detection Only When Multiple Drugs Are Prescribed**
- The system ONLY shows drug interactions when a patient is already taking at least one medication
- If prescribing the first medication to a patient, NO interactions are shown
- This prevents unnecessary warnings and focuses on actual multi-drug scenarios

### 2. **Real-Time Interaction Checking**
- When a clinician selects a drug from the dropdown, the system immediately checks for interactions
- Visual indicators show:
  - 🔵 **Checking...** - Blue loading indicator while checking
  - ✅ **No Interactions** - Green success message if no interactions found
  - ⚠️ **Interactions Detected** - Red warning with count of interactions

### 3. **Severity-Based Warnings**
Interactions are classified by severity:
- **Low** (⚠️ Yellow) - Minor interactions, monitor if needed
- **Moderate** (🟠 Orange) - Significant interactions, consider alternatives
- **High** (🔴 Red) - Serious interactions, requires attention
- **Contraindicated** (⛔ Red/Black) - Do not combine these medications

### 4. **Override Mechanism**
Clinicians can override interaction warnings by:
1. Reviewing the detailed interaction information
2. Typing "closely monitoring" to confirm they understand the risks
3. Proceeding with the prescription

## Anticoagulant Drugs in Database

### 1. Warfarin
- **Brand Names**: Coumadin, Jantoven
- **Dosage Strengths**: 1mg, 3mg, 5mg
- **Use**: Vitamin K antagonist for venous thromboembolism, pulmonary embolism, atrial fibrillation
- **Interactions**:
  - Abacavir (Moderate) - May increase Warfarin serum levels
  - Abametapir (Moderate) - Increases Warfarin concentration
  - Abatacept (Moderate) - Increases Warfarin concentration
  - Abciximab (High) - Increased bleeding risk
  - Abemaciclib (Moderate) - Increases Warfarin metabolism

### 2. Heparin Sodium
- **Brand Names**: Defencath, Heparin Leo
- **Dosage Strengths**: 5mL Vial
- **Use**: Anticoagulant for thromboprophylaxis and thrombosis treatment
- **Interactions**:
  - Abciximab (High) - Increased bleeding risk
  - Acebutolol (Moderate) - Increased hyperkalemia risk
  - Aceclofenac (High) - Increased bleeding and hemorrhage risk
  - Acemetacin (High) - Increased bleeding and hemorrhage risk
  - Acenocoumarol (High) - Increased bleeding risk

### 3. Enoxaparin
- **Dosage Strengths**: 40mg/0.4mL, 80mg/0.8mL
- **Use**: Low molecular weight heparin for DVT prophylaxis
- **Interactions**:
  - Abciximab (High) - Increased bleeding risk
  - Acebutolol (Moderate) - Increased hyperkalemia risk
  - Aceclofenac (High) - Increased bleeding and hemorrhage risk
  - Acemetacin (High) - Increased bleeding and hemorrhage risk
  - Acenocoumarol (High) - Increased bleeding risk

### 4. Rivaroxaban
- **Brand Names**: Rivaroxaban Accord, Rivaroxaban Mylan, Xarelto
- **Dosage Strengths**: 10mg, 15mg, 20mg
- **Use**: Factor Xa inhibitor for DVT, PE treatment and prevention
- **Interactions**:
  - Abacavir (Moderate) - May increase Rivaroxaban serum levels
  - Abametapir (Moderate) - Increases Rivaroxaban concentration
  - Abatacept (Moderate) - Increases Rivaroxaban metabolism
  - Abciximab (High) - Increased anticoagulant activity
  - Abemaciclib (Moderate) - May increase Rivaroxaban serum levels

## Technical Implementation

### New Files Created

1. **`lib/models/drug_interaction.dart`**
   - Defines the `DrugInteraction` class
   - Includes `InteractionSeverity` enum (low, moderate, high, contraindicated)
   - Handles JSON serialization/deserialization

### Modified Files

1. **`lib/models/drug.dart`**
   - Added `detailedInteractions` field (List<DrugInteraction>)
   - Added `indications`, `use`, and `brandNames` fields
   - Updated JSON parsing to handle detailed interactions

2. **`lib/services/firestore_service.dart`**
   - Added `checkDrugInteractions()` method
   - Checks patient's current active medications
   - Compares new drug against existing medications
   - Returns list of detected interactions
   - Updated `initializeDefaultDrugs()` with anticoagulant data

3. **`lib/services/drug_database_service.dart`**
   - Updated anticoagulant drugs with detailed interaction data
   - Added brand names, indications, and use information

4. **`lib/screens/prescribe_medication_screen.dart`**
   - Added `_checkInteractions()` method
   - Added `_showInteractionWarning()` dialog
   - Real-time interaction checking when drug is selected
   - Visual indicators for interaction status
   - Override mechanism with confirmation

## User Workflow

### Scenario 1: First Medication (No Interactions)
1. Clinician selects patient
2. Opens prescription screen
3. Selects drug category (e.g., Anticoagulant)
4. Selects drug (e.g., Warfarin)
5. System checks for interactions → **No active medications found**
6. Shows green "No drug interactions detected" message
7. Clinician completes prescription
8. Medication is prescribed successfully

### Scenario 2: Second Medication (No Interaction)
1. Patient already taking Paracetamol
2. Clinician prescribes Warfarin
3. System checks interactions → **No interactions between Paracetamol and Warfarin**
4. Shows green "No drug interactions detected" message
5. Prescription proceeds normally

### Scenario 3: Second Medication (Interaction Detected)
1. Patient already taking Warfarin
2. Clinician selects Abciximab
3. System immediately shows red warning:
   - "1 DRUG INTERACTION(S) DETECTED"
   - "Patient is taking: Warfarin"
   - "You will be prompted to review interactions before prescribing"
4. Clinician clicks "Save" to prescribe
5. System shows detailed interaction dialog:
   - Drug names: Warfarin ↔ Abciximab
   - Description: "The risk or severity of bleeding can be increased..."
   - Severity: HIGH
6. Clinician has two options:
   - **Cancel**: Choose a different medication
   - **Override**: Type "closely monitoring" to confirm and proceed
7. If override confirmed, medication is prescribed with warning logged

## Database Structure

### Drug Document (Firestore)
```json
{
  "id": "warfarin",
  "name": "Warfarin",
  "genericName": "Warfarin",
  "brandNames": ["Coumadin", "Jantoven"],
  "category": "anticoagulant",
  "isHighAlert": true,
  "commonDosages": ["1mg", "3mg", "5mg"],
  "use": "Vitamin K antagonist...",
  "indications": "Prophylaxis and treatment...",
  "warnings": "High-alert anticoagulant...",
  "interactions": [],
  "detailedInteractions": [
    {
      "interactingDrugId": "abciximab",
      "interactingDrugName": "Abciximab",
      "description": "The risk or severity of bleeding...",
      "severity": "high"
    }
  ]
}
```

## Future Enhancements

1. **Herbal Medicine Interactions**
   - Detect interactions with patient-reported herbal medicines
   - Alert clinician when prescribing if patient uses herbs

2. **Food Interactions**
   - Add food interaction warnings (e.g., Vitamin K-rich foods with Warfarin)
   - Grapefruit juice interactions

3. **Dosage-Dependent Interactions**
   - Some interactions only occur at certain dosages
   - Implement dosage-aware interaction checking

4. **Interaction History**
   - Log all interaction overrides
   - Track clinician decisions for audit purposes

5. **Patient Notifications**
   - Notify patients about drug interactions
   - Provide educational materials about their medications

6. **AI-Powered Suggestions**
   - Suggest alternative medications when interactions detected
   - Rank alternatives by safety and efficacy

## Testing Checklist

- [ ] Test prescribing first medication (no interactions)
- [ ] Test prescribing second non-interacting medication
- [ ] Test prescribing interacting medication
- [ ] Test override mechanism with correct phrase
- [ ] Test override mechanism with incorrect phrase
- [ ] Test cancel button in interaction dialog
- [ ] Test visual indicators (loading, success, warning)
- [ ] Test with multiple active medications
- [ ] Test with high-alert drugs
- [ ] Test database initialization on first run

## References

- DrugBank Database: https://go.drugbank.com/
- Kenya Essential Medical List (KEML)
- Stockley's Principles of Drug-Drug Interactions

## Notes

- This implementation is for TESTING purposes with pilot drugs
- Future versions will use approved clinical databases
- All interaction data sourced from DrugBank and KEML
- Severity classifications follow standard pharmacological guidelines
