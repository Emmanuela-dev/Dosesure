import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/drug.dart';

class DrugDatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initializeDrugDatabase() async {
    final drugsRef = _firestore.collection('drugs');
    final snapshot = await drugsRef.limit(1).get();
    
    if (snapshot.docs.isEmpty) {
      final drugs = _getComprehensiveDrugList();
      for (var drug in drugs) {
        await drugsRef.doc(drug.id).set(drug.toJson());
      }
    }
  }

  List<Drug> _getComprehensiveDrugList() {
    return [
      // ANTICOAGULANTS
      Drug(
        id: 'warfarin',
        name: 'Warfarin',
        genericName: 'Warfarin Sodium',
        category: DrugCategory.anticoagulant,
        isHighAlert: true,
        commonDosages: ['2mg', '5mg', '10mg'],
        interactions: ['abacavir', 'rivaroxaban', 'apixaban', 'ibuprofen'],
        warnings: 'Monitor INR regularly. Risk of bleeding. Avoid vitamin K-rich foods.',
      ),
      Drug(
        id: 'rivaroxaban',
        name: 'Rivaroxaban (Xarelto)',
        genericName: 'Rivaroxaban',
        category: DrugCategory.anticoagulant,
        isHighAlert: true,
        commonDosages: ['10mg', '15mg', '20mg'],
        interactions: ['warfarin', 'apixaban'],
        warnings: 'Risk of bleeding. Do not stop abruptly.',
      ),
      Drug(
        id: 'apixaban',
        name: 'Apixaban (Eliquis)',
        genericName: 'Apixaban',
        category: DrugCategory.anticoagulant,
        isHighAlert: true,
        commonDosages: ['2.5mg', '5mg'],
        interactions: ['warfarin', 'rivaroxaban'],
        warnings: 'Risk of bleeding. Monitor renal function.',
      ),
      // NON-INTERACTING DRUGS
      Drug(
        id: 'paracetamol',
        name: 'Paracetamol',
        genericName: 'Acetaminophen',
        category: DrugCategory.other,
        isHighAlert: false,
        commonDosages: ['500mg', '1000mg'],
        interactions: [],
        warnings: 'Do not exceed 4000mg per day. Risk of liver damage.',
      ),
      Drug(
        id: 'metformin',
        name: 'Metformin',
        genericName: 'Metformin HCl',
        category: DrugCategory.other,
        isHighAlert: false,
        commonDosages: ['500mg', '850mg', '1000mg'],
        interactions: [],
        warnings: 'Take with food. Monitor kidney function.',
      ),
      // INTERACTING DRUGS
      Drug(
        id: 'abacavir',
        name: 'Abacavir',
        genericName: 'Abacavir Sulfate',
        category: DrugCategory.other,
        isHighAlert: true,
        commonDosages: ['300mg', '600mg'],
        interactions: ['warfarin'],
        warnings: 'May decrease excretion of Warfarin, resulting in higher serum levels. Monitor INR closely.',
      ),
      Drug(
        id: 'ibuprofen',
        name: 'Ibuprofen',
        genericName: 'Ibuprofen',
        category: DrugCategory.other,
        isHighAlert: false,
        commonDosages: ['200mg', '400mg', '600mg'],
        interactions: ['warfarin'],
        warnings: 'Increases bleeding risk when combined with anticoagulants. Take with food.',
      ),
    ];
  }

  Future<List<Drug>> getAllDrugs() async {
    try {
      final snapshot = await _firestore.collection('drugs').get();
      print('DrugDatabaseService.getAllDrugs - Found ${snapshot.docs.length} documents');
      
      final drugs = <Drug>[];
      for (var doc in snapshot.docs) {
        try {
          final data = Map<String, dynamic>.from(doc.data());
          if (!data.containsKey('id')) {
            data['id'] = doc.id;
          }
          final drug = Drug.fromJson(data);
          drugs.add(drug);
        } catch (e) {
          print('Error parsing drug ${doc.id}: $e');
        }
      }
      
      print('DrugDatabaseService.getAllDrugs - Successfully parsed ${drugs.length} drugs');
      return drugs;
    } catch (e) {
      print('DrugDatabaseService.getAllDrugs - Error: $e');
      rethrow;
    }
  }

  Future<List<Drug>> getDrugsByCategory(DrugCategory category) async {
    final snapshot = await _firestore
        .collection('drugs')
        .where('category', isEqualTo: category.name)
        .get();
    return snapshot.docs.map((doc) => Drug.fromJson(doc.data())).toList();
  }

  Future<List<Drug>> getHighAlertDrugs() async {
    final snapshot = await _firestore
        .collection('drugs')
        .where('isHighAlert', isEqualTo: true)
        .get();
    return snapshot.docs.map((doc) => Drug.fromJson(doc.data())).toList();
  }

  Future<Drug?> getDrugById(String id) async {
    final doc = await _firestore.collection('drugs').doc(id).get();
    if (doc.exists) {
      return Drug.fromJson(doc.data()!);
    }
    return null;
  }
}
