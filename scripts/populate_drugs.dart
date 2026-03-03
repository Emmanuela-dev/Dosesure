import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import '../lib/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final firestore = FirebaseFirestore.instance;
  final drugsRef = firestore.collection('drugs');
  
  print('Starting drug database population...');
  
  // Clear old data
  print('Clearing old data...');
  final allDocs = await drugsRef.get();
  for (var doc in allDocs.docs) {
    await doc.reference.delete();
  }
  print('Old data cleared.');
  
  // Add drugs
  final drugs = [
    // ANTICOAGULANTS
    {'id': 'warfarin', 'name': 'Warfarin', 'genericName': 'Warfarin Sodium', 'category': 'anticoagulant', 'isHighAlert': true, 'commonDosages': ['2mg', '5mg', '10mg'], 'interactions': ['abacavir', 'rivaroxaban', 'apixaban', 'ibuprofen'], 'warnings': 'Monitor INR regularly. Risk of bleeding. Avoid vitamin K-rich foods.'},
    {'id': 'rivaroxaban', 'name': 'Rivaroxaban (Xarelto)', 'genericName': 'Rivaroxaban', 'category': 'anticoagulant', 'isHighAlert': true, 'commonDosages': ['10mg', '15mg', '20mg'], 'interactions': ['warfarin', 'apixaban'], 'warnings': 'Risk of bleeding. Do not stop abruptly.'},
    {'id': 'apixaban', 'name': 'Apixaban (Eliquis)', 'genericName': 'Apixaban', 'category': 'anticoagulant', 'isHighAlert': true, 'commonDosages': ['2.5mg', '5mg'], 'interactions': ['warfarin', 'rivaroxaban'], 'warnings': 'Risk of bleeding. Monitor renal function.'},
    
    // NON-INTERACTING DRUGS
    {'id': 'paracetamol', 'name': 'Paracetamol', 'genericName': 'Acetaminophen', 'category': 'other', 'isHighAlert': false, 'commonDosages': ['500mg', '1000mg'], 'interactions': [], 'warnings': 'Do not exceed 4000mg per day. Risk of liver damage.'},
    {'id': 'metformin', 'name': 'Metformin', 'genericName': 'Metformin HCl', 'category': 'other', 'isHighAlert': false, 'commonDosages': ['500mg', '850mg', '1000mg'], 'interactions': [], 'warnings': 'Take with food. Monitor kidney function.'},
    
    // INTERACTING DRUGS
    {'id': 'abacavir', 'name': 'Abacavir', 'genericName': 'Abacavir Sulfate', 'category': 'other', 'isHighAlert': true, 'commonDosages': ['300mg', '600mg'], 'interactions': ['warfarin'], 'warnings': 'May decrease excretion of Warfarin, resulting in higher serum levels. Monitor INR closely.'},
    {'id': 'ibuprofen', 'name': 'Ibuprofen', 'genericName': 'Ibuprofen', 'category': 'other', 'isHighAlert': false, 'commonDosages': ['200mg', '400mg', '600mg'], 'interactions': ['warfarin'], 'warnings': 'Increases bleeding risk when combined with anticoagulants. Take with food.'},
  ];
  
  print('Adding ${drugs.length} drugs to database...');
  
  for (var drug in drugs) {
    await drugsRef.doc(drug['id'] as String).set(drug);
    print('Added: ${drug['name']}');
  }
  
  print('\n✅ Successfully added ${drugs.length} drugs to Firestore!');
  print('Drugs include:');
  print('  - 3 Anticoagulants (Warfarin, Rivaroxaban, Apixaban)');
  print('  - 2 Non-interacting drugs (Paracetamol, Metformin)');
  print('  - 2 Interacting drugs (Abacavir, Ibuprofen)');
  print('\nYou can now test the drug interaction system!');
}
