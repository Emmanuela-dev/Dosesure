# Database-Driven Drug System Setup Guide

## Overview
Your DawaTrack app now uses a **dynamic drug database** stored in Firestore. All drugs, interactions, and warnings come from the database instead of being hardcoded.

## 🎯 Key Features

### 1. Dynamic Drug Selection
- Clinicians see a dropdown with ALL drugs from Firestore
- Drugs are organized by category (Anticoagulant, Antibiotic, etc.)
- Each drug shows warnings, dosages, and interactions

### 2. Automatic Interaction Detection
- System checks drug interactions using database relationships
- Interactions are detected based on the `interactions` field in each drug
- Visual graph shows all interactions with severity levels

### 3. Easy Database Management
- Add new drugs directly to Firestore
- Update interactions without code changes
- Scale to hundreds or thousands of drugs

## 📋 Setup Steps

### Step 1: Populate the Database

Run the population script to add initial drugs:

```bash
cd dosesure
flutter run scripts/populate_drugs.dart
```

This adds 26 drugs across 10 categories to your Firestore `drugs` collection.

### Step 2: Verify in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Navigate to Firestore Database
4. Check the `drugs` collection - you should see 26 documents

### Step 3: Test the System

#### As Clinician:
1. Login to clinician account
2. Select a patient
3. Click "Prescribe Medication"
4. Select drug category (e.g., "ANTIBIOTIC")
5. Choose drug from dropdown (e.g., "Amoxicillin")
6. Notice:
   - Common dosages appear as chips
   - Warnings show for high-alert drugs
   - Interactions are listed

#### As Patient:
1. Login to patient account
2. View prescribed medications
3. Check drug interaction screen
4. See visual graph of interactions

## 🗄️ Database Structure

### Drugs Collection (`drugs`)

Each drug document contains:

```json
{
  "id": "amoxicillin",
  "name": "Amoxicillin",
  "genericName": "Amoxicillin",
  "category": "antibiotic",
  "isHighAlert": false,
  "commonDosages": ["250mg", "500mg", "875mg"],
  "interactions": ["warfarin", "methotrexate"],
  "warnings": "Complete full course. Check for penicillin allergy."
}
```

### How Interactions Work

When Drug A lists Drug B in its `interactions` array:
- System detects the interaction
- Creates interaction warning
- Shows in drug interaction graph
- Displays severity based on `isHighAlert` status

Example:
- Warfarin has `interactions: ["aspirin", "ibuprofen", "amoxicillin"]`
- If patient takes Warfarin + Ibuprofen → Interaction detected!

## ➕ Adding New Drugs

### Method 1: Via Firebase Console (Easy)

1. Go to Firestore Database
2. Open `drugs` collection
3. Click "Add Document"
4. Fill in fields:
   ```
   Document ID: drug_id_here
   Fields:
     - id: "drug_id_here"
     - name: "Drug Name"
     - genericName: "Generic Name"
     - category: "antibiotic" (or other category)
     - isHighAlert: false
     - commonDosages: ["100mg", "200mg"]
     - interactions: ["other_drug_id"]
     - warnings: "Important warnings here"
   ```
5. Save

### Method 2: Extend the Script (Bulk)

Edit `scripts/populate_drugs.dart` and add to the `drugs` array:

```dart
{
  'id': 'new_drug',
  'name': 'New Drug Name',
  'genericName': 'Generic Name',
  'category': 'antibiotic',
  'isHighAlert': false,
  'commonDosages': ['100mg', '200mg'],
  'interactions': ['warfarin', 'aspirin'],
  'warnings': 'Take with food.'
},
```

Then run the script again.

## 🔄 How It Works

### Prescription Flow

```
Clinician opens prescription screen
    ↓
AuthProvider loads drugs from Firestore
    ↓
Dropdown shows drugs by category
    ↓
Clinician selects drug
    ↓
System shows warnings & dosages from database
    ↓
Prescription saved with drug name
```

### Interaction Detection Flow

```
Patient has multiple medications
    ↓
Drug Interaction Screen opens
    ↓
System loads all drugs from database
    ↓
For each medication pair:
  - Find drug in database
  - Check if drug1.interactions contains drug2.id
  - If yes → Create interaction warning
    ↓
Display interaction graph
```

## 🎨 Categories Available

- `anticoagulant` - Blood thinners
- `antiretroviral` - HIV medications
- `antidiabetic` - Diabetes medications
- `antibiotic` - Antibiotics
- `antihypertensive` - Blood pressure medications
- `antacid` - Stomach acid reducers
- `analgesic` - Pain relievers
- `statin` - Cholesterol medications
- `antidepressant` - Depression medications
- `antimalarial` - Malaria medications
- `other` - Other medications

## 🚨 High-Alert Medications

Drugs with `isHighAlert: true` show:
- ⚠️ Warning icon
- Red border in prescription screen
- Prominent warning message
- Extra confirmation needed

Examples:
- Warfarin (bleeding risk)
- Insulin (hypoglycemia risk)
- Metformin (lactic acidosis risk)

## 📊 Interaction Severity Levels

The system determines severity:
- **HIGH**: One or both drugs are high-alert
- **MODERATE**: Standard drugs interacting
- **LOW**: Minor interactions

## 🔧 Troubleshooting

### Drugs Not Showing in Dropdown

1. Check Firestore rules allow read access
2. Verify drugs exist in Firestore console
3. Check app logs for errors
4. Try "Refresh Drug Database" button

### Interactions Not Detected

1. Verify drug IDs match exactly
2. Check `interactions` array in Firestore
3. Ensure both drugs are in database
4. Drug names must match between prescription and database

### Script Fails to Run

1. Ensure Firebase is configured: `flutterfire configure`
2. Check internet connection
3. Verify Firestore is enabled in Firebase Console
4. Check write permissions in Firestore rules

## 📝 Best Practices

1. **Use Consistent IDs**: Use lowercase, underscores (e.g., `calcium_carbonate`)
2. **Complete Interaction Lists**: Add interactions to both drugs
3. **Clear Warnings**: Write specific, actionable warnings
4. **Test Interactions**: Prescribe test combinations to verify
5. **Regular Updates**: Keep drug database current with medical guidelines

## 🔐 Security Considerations

Update Firestore rules to allow:
- Clinicians: Read/Write drugs
- Patients: Read-only drugs

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /drugs/{drugId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'clinician';
    }
  }
}
```

## 🎓 Next Steps

1. ✅ Run populate script
2. ✅ Verify drugs in Firebase
3. ✅ Test prescription flow
4. ✅ Test interaction detection
5. 📚 Add more drugs as needed
6. 🔄 Keep database updated

## 📞 Support

For issues or questions:
- Check Firebase Console logs
- Review app debug logs
- Verify Firestore rules
- Test with simple drug combinations first
