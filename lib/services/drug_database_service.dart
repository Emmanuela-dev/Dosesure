import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/drug.dart';
import '../models/drug_interaction.dart';

class DrugDatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initializeDrugDatabase() async {
    final drugsRef = _firestore.collection('drugs');
    final snapshot = await drugsRef.limit(1).get();
    
    final drugs = _getComprehensiveDrugList();
    
    for (var drug in drugs) {
      await drugsRef.doc(drug.id).set(drug.toJson());
    }
  }

  List<Drug> _getComprehensiveDrugList() {
    return [
      // ANTICOAGULANTS
      Drug(
        id: 'warfarin',
        name: 'Warfarin',
        genericName: 'Warfarin',
        brandNames: ['Coumadin', 'Jantoven'],
        category: DrugCategory.anticoagulant,
        isHighAlert: true,
        commonDosages: ['1mg', '3mg', '5mg'],
        use: 'Vitamin K antagonist used to treat venous thromboembolism, pulmonary embolism, thromboembolism with atrial fibrillation',
        indications: 'Prophylaxis and treatment of venous thromboembolism, thromboembolism with atrial fibrillation, cardiac valve replacement, post-MI',
        warnings: 'High-alert anticoagulant. Monitor INR regularly. Risk of bleeding.',
        interactions: ['abacavir'],
        detailedInteractions: [
          DrugInteraction(
            interactingDrugId: 'abacavir',
            interactingDrugName: 'Abacavir',
            description: 'Abacavir may decrease the excretion rate of Warfarin which could result in a higher serum level.',
            severity: InteractionSeverity.high,
          ),
        ],
      ),
      Drug(
        id: 'heparin',
        name: 'Heparin Sodium',
        genericName: 'Heparin',
        brandNames: ['Defencath', 'Heparin Leo'],
        category: DrugCategory.anticoagulant,
        isHighAlert: true,
        commonDosages: ['5mL Vial'],
        use: 'Anticoagulant for thromboprophylaxis and treatment of thrombosis',
        indications: 'Prophylaxis and treatment of venous thrombosis, prevention of post-operative DVT and PE, atrial fibrillation',
        warnings: 'High-alert anticoagulant. Monitor aPTT. Risk of bleeding and thrombocytopenia.',
        interactions: [],
        detailedInteractions: [],
      ),
      Drug(
        id: 'enoxaparin',
        name: 'Enoxaparin',
        genericName: 'Enoxaparin',
        category: DrugCategory.anticoagulant,
        isHighAlert: true,
        commonDosages: ['40mg/0.4mL', '80mg/0.8mL'],
        use: 'Low molecular weight heparin for DVT prophylaxis and ischemic complications',
        indications: 'Prevention of ischemic complications in unstable angina, non-Q-wave MI, DVT prophylaxis, treatment of DVT/PE',
        warnings: 'High-alert anticoagulant. Monitor anti-Xa levels if needed. Risk of bleeding.',
        interactions: [],
        detailedInteractions: [],
      ),
      Drug(
        id: 'rivaroxaban',
        name: 'Rivaroxaban',
        genericName: 'Rivaroxaban',
        brandNames: ['Rivaroxaban Accord', 'Rivaroxaban Mylan', 'Xarelto'],
        category: DrugCategory.anticoagulant,
        isHighAlert: true,
        commonDosages: ['10mg', '15mg', '20mg'],
        use: 'Factor Xa inhibitor for DVT, PE treatment and prevention',
        indications: 'Prevention of VTE post-surgery, stroke prevention in atrial fibrillation, treatment of DVT/PE',
        warnings: 'High-alert anticoagulant. Not recommended in severe renal impairment (<30mL/min). Risk of bleeding.',
        interactions: [],
        detailedInteractions: [],
      ),
      Drug(
        id: 'apixaban',
        name: 'Apixaban',
        genericName: 'Apixaban',
        brandNames: ['Eliquis'],
        category: DrugCategory.anticoagulant,
        isHighAlert: true,
        commonDosages: ['2.5mg', '5mg'],
        use: 'Factor Xa inhibitor for stroke prevention and VTE treatment',
        indications: 'Stroke prevention in atrial fibrillation, treatment and prevention of DVT/PE',
        warnings: 'Risk of bleeding. Monitor renal function.',
        interactions: [],
        detailedInteractions: [],
      ),

      // INTERACTING DRUGS
      Drug(
        id: 'abacavir',
        name: 'Abacavir',
        genericName: 'Abacavir',
        category: DrugCategory.other,
        isHighAlert: false,
        commonDosages: ['300mg', '600mg'],
        use: 'An antiviral medication used to treat HIV',
        indications: 'Treatment of HIV infection in combination with other antiretroviral agents',
        warnings: 'May interact with anticoagulants. Screen for HLA-B*5701 allele before use.',
        interactions: ['warfarin'],
        detailedInteractions: [
          DrugInteraction(
            interactingDrugId: 'warfarin',
            interactingDrugName: 'Warfarin',
            description: 'Abacavir may decrease the excretion rate of Warfarin which could result in a higher serum level.',
            severity: InteractionSeverity.high,
          ),
        ],
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
