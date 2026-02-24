import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import '../lib/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final firestore = FirebaseFirestore.instance;
  final drugsRef = firestore.collection('drugs');
  
  print('Starting drug database population...');
  
  // Check if drugs already exist
  final snapshot = await drugsRef.limit(1).get();
  if (snapshot.docs.isNotEmpty) {
    print('Drugs already exist. Clearing old data...');
    final batch = firestore.batch();
    final allDocs = await drugsRef.get();
    for (var doc in allDocs.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    print('Old data cleared.');
  }
  
  // Add all drugs
  final drugs = [
    // ANTICOAGULANTS
    {'id': 'warfarin', 'name': 'Warfarin', 'genericName': 'Warfarin Sodium', 'category': 'anticoagulant', 'isHighAlert': true, 'commonDosages': ['2mg', '5mg', '10mg'], 'interactions': ['aspirin', 'ibuprofen', 'amoxicillin', 'rifampin'], 'warnings': 'Monitor INR regularly. Risk of bleeding. Avoid vitamin K-rich foods.'},
    {'id': 'rivaroxaban', 'name': 'Rivaroxaban (Xarelto)', 'genericName': 'Rivaroxaban', 'category': 'anticoagulant', 'isHighAlert': true, 'commonDosages': ['10mg', '15mg', '20mg'], 'interactions': ['aspirin', 'ketoconazole', 'rifampin'], 'warnings': 'Risk of bleeding. Do not stop abruptly.'},
    {'id': 'apixaban', 'name': 'Apixaban (Eliquis)', 'genericName': 'Apixaban', 'category': 'anticoagulant', 'isHighAlert': true, 'commonDosages': ['2.5mg', '5mg'], 'interactions': ['aspirin', 'ketoconazole', 'rifampin'], 'warnings': 'Risk of bleeding. Monitor renal function.'},
    
    // ANTIRETROVIRALS
    {'id': 'efavirenz', 'name': 'Efavirenz (Sustiva)', 'genericName': 'Efavirenz', 'category': 'antiretroviral', 'isHighAlert': true, 'commonDosages': ['600mg'], 'interactions': ['rifampin', 'warfarin', 'midazolam'], 'warnings': 'Take on empty stomach. May cause CNS effects.'},
    {'id': 'tenofovir', 'name': 'Tenofovir (Viread)', 'genericName': 'Tenofovir Disoproxil', 'category': 'antiretroviral', 'isHighAlert': true, 'commonDosages': ['300mg'], 'interactions': ['didanosine', 'atazanavir'], 'warnings': 'Monitor renal function. Risk of bone loss.'},
    {'id': 'dolutegravir', 'name': 'Dolutegravir (Tivicay)', 'genericName': 'Dolutegravir', 'category': 'antiretroviral', 'isHighAlert': true, 'commonDosages': ['50mg'], 'interactions': ['rifampin', 'calcium', 'iron'], 'warnings': 'Take 2 hours before or 6 hours after antacids.'},
    
    // ANTIDIABETICS
    {'id': 'insulin_regular', 'name': 'Insulin Regular', 'genericName': 'Human Insulin', 'category': 'antidiabetic', 'isHighAlert': true, 'commonDosages': ['Variable units'], 'interactions': ['beta_blockers', 'corticosteroids'], 'warnings': 'Risk of hypoglycemia. Monitor blood glucose.'},
    {'id': 'metformin', 'name': 'Metformin (Glucophage)', 'genericName': 'Metformin HCl', 'category': 'antidiabetic', 'isHighAlert': true, 'commonDosages': ['500mg', '850mg', '1000mg'], 'interactions': ['contrast_dye', 'alcohol'], 'warnings': 'Risk of lactic acidosis. Monitor renal function.'},
    {'id': 'glimepiride', 'name': 'Glimepiride (Amaryl)', 'genericName': 'Glimepiride', 'category': 'antidiabetic', 'isHighAlert': true, 'commonDosages': ['1mg', '2mg', '4mg'], 'interactions': ['warfarin', 'beta_blockers'], 'warnings': 'Risk of hypoglycemia. Take with breakfast.'},
    
    // ANTIBIOTICS
    {'id': 'amoxicillin', 'name': 'Amoxicillin', 'genericName': 'Amoxicillin', 'category': 'antibiotic', 'isHighAlert': false, 'commonDosages': ['250mg', '500mg', '875mg'], 'interactions': ['warfarin', 'methotrexate'], 'warnings': 'Complete full course. Check for penicillin allergy.'},
    {'id': 'azithromycin', 'name': 'Azithromycin (Zithromax)', 'genericName': 'Azithromycin', 'category': 'antibiotic', 'isHighAlert': false, 'commonDosages': ['250mg', '500mg'], 'interactions': ['warfarin', 'digoxin'], 'warnings': 'May prolong QT interval. Take on empty stomach.'},
    {'id': 'ciprofloxacin', 'name': 'Ciprofloxacin (Cipro)', 'genericName': 'Ciprofloxacin', 'category': 'antibiotic', 'isHighAlert': false, 'commonDosages': ['250mg', '500mg', '750mg'], 'interactions': ['antacids', 'warfarin', 'theophylline'], 'warnings': 'Take 2 hours before or 6 hours after antacids.'},
    
    // ANTIHYPERTENSIVES
    {'id': 'amlodipine', 'name': 'Amlodipine (Norvasc)', 'genericName': 'Amlodipine Besylate', 'category': 'antihypertensive', 'isHighAlert': false, 'commonDosages': ['2.5mg', '5mg', '10mg'], 'interactions': ['simvastatin', 'grapefruit'], 'warnings': 'May cause ankle swelling. Monitor blood pressure.'},
    {'id': 'lisinopril', 'name': 'Lisinopril (Prinivil)', 'genericName': 'Lisinopril', 'category': 'antihypertensive', 'isHighAlert': false, 'commonDosages': ['5mg', '10mg', '20mg', '40mg'], 'interactions': ['potassium', 'nsaids'], 'warnings': 'Monitor potassium levels. May cause dry cough.'},
    {'id': 'hydrochlorothiazide', 'name': 'Hydrochlorothiazide (HCTZ)', 'genericName': 'Hydrochlorothiazide', 'category': 'antihypertensive', 'isHighAlert': false, 'commonDosages': ['12.5mg', '25mg', '50mg'], 'interactions': ['lithium', 'digoxin'], 'warnings': 'May cause electrolyte imbalance. Monitor potassium.'},
    
    // ANTACIDS
    {'id': 'aluminium_hydroxide', 'name': 'Aluminium Hydroxide', 'genericName': 'Aluminium Hydroxide', 'category': 'antacid', 'isHighAlert': false, 'commonDosages': ['320mg', '600mg'], 'interactions': ['ciprofloxacin', 'tetracycline', 'iron'], 'warnings': 'May cause constipation. Take 2 hours apart from other medications.'},
    {'id': 'calcium_carbonate', 'name': 'Calcium Carbonate (Tums)', 'genericName': 'Calcium Carbonate', 'category': 'antacid', 'isHighAlert': false, 'commonDosages': ['500mg', '750mg', '1000mg'], 'interactions': ['tetracycline', 'levothyroxine', 'iron'], 'warnings': 'May cause constipation. Limit use with kidney disease.'},
    {'id': 'omeprazole', 'name': 'Omeprazole (Prilosec)', 'genericName': 'Omeprazole', 'category': 'antacid', 'isHighAlert': false, 'commonDosages': ['20mg', '40mg'], 'interactions': ['clopidogrel', 'warfarin', 'methotrexate'], 'warnings': 'Take 30 minutes before meals. Long-term use may affect bone density.'},
    
    // ANALGESICS
    {'id': 'ibuprofen', 'name': 'Ibuprofen (Advil)', 'genericName': 'Ibuprofen', 'category': 'analgesic', 'isHighAlert': false, 'commonDosages': ['200mg', '400mg', '600mg', '800mg'], 'interactions': ['warfarin', 'aspirin', 'lisinopril'], 'warnings': 'Take with food. Risk of GI bleeding with long-term use.'},
    {'id': 'acetaminophen', 'name': 'Acetaminophen (Tylenol)', 'genericName': 'Acetaminophen', 'category': 'analgesic', 'isHighAlert': false, 'commonDosages': ['325mg', '500mg', '650mg'], 'interactions': ['warfarin', 'alcohol'], 'warnings': 'Do not exceed 4000mg per day. Risk of liver damage.'},
    
    // STATINS
    {'id': 'atorvastatin', 'name': 'Atorvastatin (Lipitor)', 'genericName': 'Atorvastatin Calcium', 'category': 'statin', 'isHighAlert': false, 'commonDosages': ['10mg', '20mg', '40mg', '80mg'], 'interactions': ['grapefruit', 'clarithromycin', 'gemfibrozil'], 'warnings': 'Monitor liver function. May cause muscle pain.'},
    {'id': 'simvastatin', 'name': 'Simvastatin (Zocor)', 'genericName': 'Simvastatin', 'category': 'statin', 'isHighAlert': false, 'commonDosages': ['5mg', '10mg', '20mg', '40mg'], 'interactions': ['grapefruit', 'amlodipine', 'diltiazem'], 'warnings': 'Take in evening. Avoid grapefruit juice.'},
    
    // ANTIDEPRESSANTS
    {'id': 'sertraline', 'name': 'Sertraline (Zoloft)', 'genericName': 'Sertraline HCl', 'category': 'antidepressant', 'isHighAlert': false, 'commonDosages': ['25mg', '50mg', '100mg'], 'interactions': ['warfarin', 'nsaids', 'tramadol'], 'warnings': 'May take 4-6 weeks for full effect. Do not stop abruptly.'},
    {'id': 'fluoxetine', 'name': 'Fluoxetine (Prozac)', 'genericName': 'Fluoxetine HCl', 'category': 'antidepressant', 'isHighAlert': false, 'commonDosages': ['10mg', '20mg', '40mg'], 'interactions': ['warfarin', 'tramadol', 'aspirin'], 'warnings': 'May cause insomnia. Take in morning.'},
    
    // ANTIMALARIALS
    {'id': 'artemether_lumefantrine', 'name': 'Artemether/Lumefantrine (Coartem)', 'genericName': 'Artemether/Lumefantrine', 'category': 'antimalarial', 'isHighAlert': false, 'commonDosages': ['20mg/120mg'], 'interactions': ['efavirenz', 'rifampin', 'ketoconazole'], 'warnings': 'Take with fatty food. Complete full course.'},
    {'id': 'quinine', 'name': 'Quinine Sulfate', 'genericName': 'Quinine Sulfate', 'category': 'antimalarial', 'isHighAlert': false, 'commonDosages': ['300mg', '600mg'], 'interactions': ['warfarin', 'digoxin', 'mefloquine'], 'warnings': 'May cause cinchonism. Monitor for tinnitus.'},
  ];
  
  print('Adding ${drugs.length} drugs to database...');
  
  for (var drug in drugs) {
    await drugsRef.doc(drug['id'] as String).set(drug);
    print('Added: ${drug['name']}');
  }
  
  print('\n✅ Successfully added ${drugs.length} drugs to Firestore!');
  print('You can now use these drugs in the prescription screen.');
}
