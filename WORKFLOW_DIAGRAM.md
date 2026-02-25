# Drug Interaction Detection - Visual Workflow

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                     DAWATRACK SYSTEM                             │
│                                                                   │
│  ┌──────────────┐      ┌──────────────┐      ┌──────────────┐  │
│  │   Clinician  │      │   Patient    │      │   Firebase   │  │
│  │  Dashboard   │      │    Portal    │      │  Firestore   │  │
│  └──────┬───────┘      └──────────────┘      └──────┬───────┘  │
│         │                                             │          │
│         │ Select Patient                              │          │
│         ▼                                             │          │
│  ┌──────────────────────────────────────────┐        │          │
│  │   Prescribe Medication Screen            │        │          │
│  │                                           │        │          │
│  │  1. Select Drug Category                 │        │          │
│  │     └─► Anticoagulant                    │        │          │
│  │                                           │        │          │
│  │  2. Select Specific Drug                 │        │          │
│  │     └─► Warfarin                         │        │          │
│  │                                           │        │          │
│  │  3. AUTOMATIC INTERACTION CHECK          │◄───────┤          │
│  │     ┌─────────────────────────────┐      │        │          │
│  │     │ checkDrugInteractions()     │      │        │          │
│  │     │  - Get patient active meds  │──────┼────────┘          │
│  │     │  - Compare with new drug    │      │                   │
│  │     │  - Return interactions      │      │                   │
│  │     └─────────────────────────────┘      │                   │
│  │                                           │                   │
│  │  4. Display Result                       │                   │
│  │     ┌─ No active meds ─► ✅ No warnings │                   │
│  │     ├─ No interactions ─► ✅ Safe       │                   │
│  │     └─ Interactions ────► ⚠️ Warning    │                   │
│  │                                           │                   │
│  │  5. Complete Prescription                │                   │
│  │     └─► Enter dosage, times, etc.        │                   │
│  │                                           │                   │
│  │  6. Click "Save"                         │                   │
│  │     └─► If interactions: Show Dialog     │                   │
│  │                                           │                   │
│  └───────────────────────────────────────────┘                  │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘
```

## Interaction Detection Flow

```
START: Clinician selects drug
         │
         ▼
    ┌─────────────────────┐
    │ Get Patient's       │
    │ Active Medications  │
    └──────────┬──────────┘
               │
               ▼
        ┌──────────────┐
        │ Any active   │───── NO ────► ✅ Return empty list
        │ medications? │                  (No warnings)
        └──────┬───────┘
               │ YES
               ▼
    ┌─────────────────────┐
    │ Get New Drug        │
    │ Details & Interactions│
    └──────────┬──────────┘
               │
               ▼
    ┌─────────────────────┐
    │ For Each Active Med:│
    │ - Check if new drug │
    │   interacts with it │
    │ - Check if it       │
    │   interacts with    │
    │   new drug          │
    └──────────┬──────────┘
               │
               ▼
        ┌──────────────┐
        │ Interactions │───── NO ────► ✅ Return empty list
        │ found?       │                  (Safe to prescribe)
        └──────┬───────┘
               │ YES
               ▼
    ┌─────────────────────┐
    │ Collect All         │
    │ Interactions with   │
    │ Severity Levels     │
    └──────────┬──────────┘
               │
               ▼
    ⚠️ Return interaction list
       (Show warnings)
```

## User Interface States

### State 1: Checking Interactions
```
┌────────────────────────────────────────┐
│ 🔵 Checking for drug interactions...   │
│                                         │
│ [Loading spinner]                      │
└────────────────────────────────────────┘
```

### State 2: No Interactions (Safe)
```
┌────────────────────────────────────────┐
│ ✅ No drug interactions detected       │
│    with current medications            │
│                                         │
│ Safe to prescribe                      │
└────────────────────────────────────────┘
```

### State 3: Interactions Detected (Warning)
```
┌────────────────────────────────────────┐
│ ⚠️ 2 DRUG INTERACTION(S) DETECTED      │
│                                         │
│ Patient is taking: Warfarin, Heparin   │
│                                         │
│ You will be prompted to review         │
│ interactions before prescribing.       │
└────────────────────────────────────────┘
```

## Interaction Warning Dialog

```
┌─────────────────────────────────────────────────────────┐
│  ⚠️  Drug Interaction Warning                           │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  The patient is currently taking medications that       │
│  may interact with Warfarin:                            │
│                                                          │
│  ┌────────────────────────────────────────────────┐    │
│  │ 🔴 HIGH SEVERITY                                │    │
│  │                                                  │    │
│  │ Warfarin ↔ Abciximab                           │    │
│  │                                                  │    │
│  │ The risk or severity of bleeding can be        │    │
│  │ increased when Abciximab is combined with      │    │
│  │ Warfarin.                                       │    │
│  │                                                  │    │
│  │ Severity: HIGH                                  │    │
│  └────────────────────────────────────────────────┘    │
│                                                          │
│  ┌────────────────────────────────────────────────┐    │
│  │ 🟠 MODERATE SEVERITY                            │    │
│  │                                                  │    │
│  │ Warfarin ↔ Abacavir                            │    │
│  │                                                  │    │
│  │ Abacavir may decrease the excretion rate of    │    │
│  │ Warfarin which could result in a higher        │    │
│  │ serum level.                                    │    │
│  │                                                  │    │
│  │ Severity: MODERATE                              │    │
│  └────────────────────────────────────────────────┘    │
│                                                          │
│  Do you want to proceed with prescribing this          │
│  medication?                                            │
│                                                          │
│  Type "closely monitoring" to override and prescribe   │
│  anyway, or cancel to choose a different medication.   │
│                                                          │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  [Cancel]                              [Override]       │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

## Override Confirmation Dialog

```
┌─────────────────────────────────────────┐
│  Confirm Override                        │
├─────────────────────────────────────────┤
│                                          │
│  Type "closely monitoring" to confirm:  │
│                                          │
│  ┌────────────────────────────────────┐ │
│  │ [Text Input Field]                 │ │
│  └────────────────────────────────────┘ │
│                                          │
│  This confirms you understand the       │
│  interaction risks and will monitor     │
│  the patient closely.                   │
│                                          │
├─────────────────────────────────────────┤
│                                          │
│  [Cancel]                    [Confirm]  │
│                                          │
└─────────────────────────────────────────┘
```

## Severity Color Coding

```
┌──────────────────────────────────────────────────────┐
│  Interaction Severity Levels                         │
├──────────────────────────────────────────────────────┤
│                                                       │
│  ⚠️  LOW (Yellow)                                    │
│      Minor interactions, monitor if needed           │
│      Example: Heparin + Calcium Supplement           │
│                                                       │
│  🟠  MODERATE (Orange)                               │
│      Significant interactions, consider alternatives │
│      Example: Warfarin + Abacavir                    │
│                                                       │
│  🔴  HIGH (Red)                                      │
│      Serious interactions, requires attention        │
│      Example: Warfarin + Abciximab                   │
│                                                       │
│  ⛔  CONTRAINDICATED (Dark Red/Black)                │
│      Do not combine these medications                │
│      Example: [To be added in future]                │
│                                                       │
└──────────────────────────────────────────────────────┘
```

## Database Structure

```
Firestore Collection: drugs
│
├── Document: warfarin
│   ├── id: "warfarin"
│   ├── name: "Warfarin"
│   ├── genericName: "Warfarin"
│   ├── brandNames: ["Coumadin", "Jantoven"]
│   ├── category: "anticoagulant"
│   ├── isHighAlert: true
│   ├── commonDosages: ["1mg", "3mg", "5mg"]
│   ├── use: "Vitamin K antagonist..."
│   ├── indications: "Prophylaxis and treatment..."
│   ├── warnings: "High-alert anticoagulant..."
│   ├── interactions: []
│   └── detailedInteractions: [
│       ├── {
│       │   interactingDrugId: "abciximab",
│       │   interactingDrugName: "Abciximab",
│       │   description: "Risk of bleeding...",
│       │   severity: "high"
│       │   }
│       └── {...}
│       ]
│
├── Document: heparin
│   └── [Similar structure]
│
├── Document: enoxaparin
│   └── [Similar structure]
│
└── Document: rivaroxaban
    └── [Similar structure]
```

## Timeline of Events

```
Time    Event                           System Action
─────────────────────────────────────────────────────────────
T0      Clinician logs in               Load clinician dashboard
T1      Selects patient                 Load patient details
T2      Clicks "Prescribe Medication"   Open prescription screen
T3      Selects category: Anticoagulant Load anticoagulant drugs
T4      Selects drug: Warfarin          ► Trigger interaction check
T5      System checks Firestore         Get patient active meds
T6      Compares interactions           Process interaction logic
T7      Returns results                 Update UI state
T8      Shows visual indicator          Display warning/success
T9      Clinician enters dosage         Form validation
T10     Clicks "Save"                   ► Check if interactions exist
T11     If interactions: Show dialog    Display detailed warnings
T12     Clinician reviews               Read interaction details
T13     Types "closely monitoring"      Validate override phrase
T14     Clicks "Confirm"                Proceed with prescription
T15     Medication saved to Firestore   Success notification
T16     Patient receives notification   Alarm scheduled
```

## Decision Tree

```
                    Prescribe Medication
                            │
                            ▼
                    Select Drug Category
                            │
                            ▼
                    Select Specific Drug
                            │
                            ▼
              ┌─────────────────────────┐
              │ Patient has active meds?│
              └─────────┬───────────────┘
                        │
            ┌───────────┴───────────┐
            │                       │
           NO                      YES
            │                       │
            ▼                       ▼
    ✅ No warnings        Check for interactions
    Continue normally              │
                        ┌──────────┴──────────┐
                        │                     │
                   Interactions          No interactions
                    detected?                 │
                        │                     ▼
                       YES              ✅ Safe to prescribe
                        │               Continue normally
                        ▼
              Show warning indicator
                        │
                        ▼
              Clinician clicks "Save"
                        │
                        ▼
              Show interaction dialog
                        │
            ┌───────────┴───────────┐
            │                       │
         Cancel                  Override
            │                       │
            ▼                       ▼
    Choose different      Type "closely monitoring"
    medication                     │
                                   ▼
                          Confirm and prescribe
                                   │
                                   ▼
                          ✅ Prescription saved
```

## Key Features Summary

```
┌─────────────────────────────────────────────────────────┐
│  ✅ IMPLEMENTED FEATURES                                 │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  1. ✓ Real-time interaction detection                   │
│  2. ✓ Visual indicators (loading, success, warning)     │
│  3. ✓ Severity-based color coding                       │
│  4. ✓ Detailed interaction descriptions                 │
│  5. ✓ Override mechanism with confirmation              │
│  6. ✓ No false warnings for single medications          │
│  7. ✓ Bidirectional interaction checking                │
│  8. ✓ High-alert drug flagging                          │
│  9. ✓ 4 anticoagulant drugs with 29 interactions        │
│  10. ✓ Comprehensive documentation                      │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

## Success Criteria

```
✅ Interaction detection works correctly
✅ No warnings when prescribing first medication
✅ Warnings appear when interactions detected
✅ Override mechanism requires exact phrase
✅ Visual indicators update in real-time
✅ Severity levels displayed correctly
✅ Dialog shows all interaction details
✅ Cancel button works properly
✅ Prescription succeeds after override
✅ Database initializes with anticoagulants
```

---

**Note:** This visual workflow demonstrates the complete interaction detection system from clinician action to prescription completion, including all decision points and user interface states.
