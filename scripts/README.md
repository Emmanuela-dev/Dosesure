# Drug Database Population Script

## Overview
This script populates your Firestore database with a comprehensive drug database including interactions, warnings, and dosage information.

## How to Run

### Option 1: Using Flutter (Recommended)
```bash
# Navigate to project root
cd dosesure

# Run the script
flutter run scripts/populate_drugs.dart
```

### Option 2: Using Dart
```bash
# Navigate to project root
cd dosesure

# Run with dart
dart run scripts/populate_drugs.dart
```

## What This Script Does

1. **Connects to Firebase**: Initializes Firebase connection
2. **Clears Old Data**: Removes any existing drugs to prevent duplicates
3. **Adds 26 Drugs** across multiple categories:
   - Anticoagulants (Warfarin, Rivaroxaban, Apixaban)
   - Antiretrovirals (Efavirenz, Tenofovir, Dolutegravir)
   - Antidiabetics (Insulin, Metformin, Glimepiride)
   - Antibiotics (Amoxicillin, Azithromycin, Ciprofloxacin)
   - Antihypertensives (Amlodipine, Lisinopril, HCTZ)
   - Antacids (Aluminium Hydroxide, Calcium Carbonate, Omeprazole)
   - Analgesics (Ibuprofen, Acetaminophen)
   - Statins (Atorvastatin, Simvastatin)
   - Antidepressants (Sertraline, Fluoxetine)
   - Antimalarials (Artemether/Lumefantrine, Quinine)

## Database Structure

Each drug contains:
- `id`: Unique identifier
- `name`: Brand/common name
- `genericName`: Generic drug name
- `category`: Drug category
- `isHighAlert`: Boolean for high-risk medications
- `commonDosages`: Array of typical dosages
- `interactions`: Array of drug IDs that interact
- `warnings`: Important safety information

## After Running

Once complete, you can:
1. **Prescribe Medications**: Dropdown will show all drugs from database
2. **View Interactions**: System automatically detects interactions based on database
3. **Add More Drugs**: Manually add to Firestore or extend this script

## Troubleshooting

### Firebase Not Initialized
- Ensure `firebase_options.dart` exists
- Run `flutterfire configure` if needed

### Permission Denied
- Check Firestore security rules
- Ensure you have write access to `drugs` collection

### Script Hangs
- Check internet connection
- Verify Firebase project is active
