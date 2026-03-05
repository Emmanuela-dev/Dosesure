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
  
  // Add anticoagulant drugs with detailed interactions
  final drugs = [
    // ANTICOAGULANTS
    {
      'id': 'warfarin',
      'name': 'Warfarin',
      'genericName': 'Warfarin Sodium',
      'category': 'anticoagulant',
      'isHighAlert': true,
      'commonDosages': ['2mg', '5mg', '10mg'],
      'interactions': ['abacavir'],
      'detailedInteractions': [
        {'interactingDrugId': 'abacavir', 'interactingDrugName': 'Abacavir', 'description': 'Abacavir may decrease the excretion rate of Warfarin which could result in a higher serum level.', 'severity': 'high'},
      ],
      'warnings': 'Monitor INR regularly. Risk of bleeding. Avoid vitamin K-rich foods and grapefruit juice.',
    },
    {
      'id': 'rivaroxaban',
      'name': 'Rivaroxaban',
      'genericName': 'Rivaroxaban',
      'brandNames': ['Xarelto'],
      'category': 'anticoagulant',
      'isHighAlert': true,
      'commonDosages': ['10mg', '15mg', '20mg'],
      'interactions': [],
      'detailedInteractions': [],
      'warnings': 'Risk of bleeding. Do not stop abruptly. Monitor renal function.',
    },
    {
      'id': 'apixaban',
      'name': 'Apixaban',
      'genericName': 'Apixaban',
      'brandNames': ['Eliquis'],
      'category': 'anticoagulant',
      'isHighAlert': true,
      'commonDosages': ['2.5mg', '5mg'],
      'interactions': [],
      'detailedInteractions': [],
      'warnings': 'Risk of bleeding. Monitor renal function. Do not crush tablets.',
    },
    {
      'id': 'heparin',
      'name': 'Heparin',
      'genericName': 'Heparin Sodium',
      'category': 'anticoagulant',
      'isHighAlert': true,
      'commonDosages': ['5000 units', '10000 units'],
      'interactions': [],
      'detailedInteractions': [],
      'warnings': 'Monitor aPTT. Risk of heparin-induced thrombocytopenia. IV/SC administration only.',
    },
    {
      'id': 'enoxaparin',
      'name': 'Enoxaparin',
      'genericName': 'Enoxaparin Sodium',
      'brandNames': ['Lovenox'],
      'category': 'anticoagulant',
      'isHighAlert': true,
      'commonDosages': ['30mg', '40mg', '60mg'],
      'interactions': [],
      'detailedInteractions': [],
      'warnings': 'Monitor anti-Xa levels in renal impairment. SC injection only.',
    },

    // INTERACTING DRUGS
    {
      'id': 'abacavir',
      'name': 'Abacavir',
      'genericName': 'Abacavir Sulfate',
      'category': 'other',
      'isHighAlert': false,
      'commonDosages': ['300mg', '600mg'],
      'use': 'An antiviral medication used to treat HIV',
      'interactions': ['warfarin'],
      'detailedInteractions': [
        {'interactingDrugId': 'warfarin', 'interactingDrugName': 'Warfarin', 'description': 'Abacavir may decrease the excretion rate of Warfarin which could result in a higher serum level.', 'severity': 'high'},
      ],
      'warnings': 'May interact with anticoagulants. Screen for HLA-B*5701 allele before use.',
    },
  ];
  
  print('Adding ${drugs.length} drugs to database...');
  
  for (var drug in drugs) {
    await drugsRef.doc(drug['id'] as String).set(drug);
    print('Added: ${drug['name']}');
  }
  
  print('\n✅ Successfully added ${drugs.length} drugs to Firestore!');
  print('Drugs include:');
  print('  - 5 Anticoagulants (Warfarin, Rivaroxaban, Apixaban, Heparin, Enoxaparin)');
  print('  - 1 Interacting drug (Abacavir)');
  print('\nYou can now test the drug interaction system!');
}
