import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/drug.dart';
import '../models/drug_interaction.dart';

class DrugDatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initializeDrugDatabase() async {
    final drugsRef = _firestore.collection('drugs');
    final snapshot = await drugsRef.limit(1).get();
    
    // Always add drugs for now
    final drugs = _getComprehensiveDrugList();
    
    for (var drug in drugs) {
      await drugsRef.doc(drug.id).set(drug.toJson());
    }
  }

  List<Drug> _getComprehensiveDrugList() {
    return [
      // HIGH-ALERT: ANTICOAGULANTS (Updated with detailed interactions)
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
        interactions: [],
        detailedInteractions: [
          DrugInteraction(
            interactingDrugId: 'abacavir',
            interactingDrugName: 'Abacavir',
            description: 'Abacavir may decrease the excretion rate of Warfarin which could result in a higher serum level.',
            severity: InteractionSeverity.moderate,
          ),
          DrugInteraction(
            interactingDrugId: 'abametapir',
            interactingDrugName: 'Abametapir',
            description: 'The serum concentration of Warfarin can be increased when it is combined with Abametapir.',
            severity: InteractionSeverity.moderate,
          ),
          DrugInteraction(
            interactingDrugId: 'abatacept',
            interactingDrugName: 'Abatacept',
            description: 'The serum concentration of Warfarin can be increased when it is combined with Abatacept.',
            severity: InteractionSeverity.moderate,
          ),
          DrugInteraction(
            interactingDrugId: 'abciximab',
            interactingDrugName: 'Abciximab',
            description: 'The risk or severity of bleeding can be increased when Abciximab is combined with Warfarin.',
            severity: InteractionSeverity.high,
          ),
          DrugInteraction(
            interactingDrugId: 'abemaciclib',
            interactingDrugName: 'Abemaciclib',
            description: 'The metabolism of Abemaciclib can be increased when combined with Warfarin.',
            severity: InteractionSeverity.moderate,
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
        detailedInteractions: [
          DrugInteraction(
            interactingDrugId: 'abciximab',
            interactingDrugName: 'Abciximab',
            description: 'The risk or severity of bleeding can be increased when Abciximab is combined with Heparin.',
            severity: InteractionSeverity.high,
          ),
          DrugInteraction(
            interactingDrugId: 'acebutolol',
            interactingDrugName: 'Acebutolol',
            description: 'The risk or severity of hyperkalemia can be increased when Heparin is combined with Acebutolol.',
            severity: InteractionSeverity.moderate,
          ),
          DrugInteraction(
            interactingDrugId: 'aceclofenac',
            interactingDrugName: 'Aceclofenac',
            description: 'The risk or severity of bleeding and hemorrhage can be increased when Aceclofenac is combined with Heparin.',
            severity: InteractionSeverity.high,
          ),
          DrugInteraction(
            interactingDrugId: 'acemetacin',
            interactingDrugName: 'Acemetacin',
            description: 'The risk or severity of bleeding and hemorrhage can be increased when Heparin is combined with Acemetacin.',
            severity: InteractionSeverity.high,
          ),
          DrugInteraction(
            interactingDrugId: 'acenocoumarol',
            interactingDrugName: 'Acenocoumarol',
            description: 'The risk or severity of bleeding can be increased when Heparin is combined with Acenocoumarol.',
            severity: InteractionSeverity.high,
          ),
        ],
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
        detailedInteractions: [
          DrugInteraction(
            interactingDrugId: 'abciximab',
            interactingDrugName: 'Abciximab',
            description: 'The risk or severity of bleeding can be increased when Abciximab is combined with Enoxaparin.',
            severity: InteractionSeverity.high,
          ),
          DrugInteraction(
            interactingDrugId: 'acebutolol',
            interactingDrugName: 'Acebutolol',
            description: 'The risk or severity of hyperkalemia can be increased when Acebutolol is combined with Enoxaparin.',
            severity: InteractionSeverity.moderate,
          ),
          DrugInteraction(
            interactingDrugId: 'aceclofenac',
            interactingDrugName: 'Aceclofenac',
            description: 'The risk or severity of bleeding and hemorrhage can be increased when Aceclofenac is combined with Enoxaparin.',
            severity: InteractionSeverity.high,
          ),
          DrugInteraction(
            interactingDrugId: 'acemetacin',
            interactingDrugName: 'Acemetacin',
            description: 'The risk or severity of bleeding and hemorrhage can be increased when Enoxaparin is combined with Acemetacin.',
            severity: InteractionSeverity.high,
          ),
          DrugInteraction(
            interactingDrugId: 'acenocoumarol',
            interactingDrugName: 'Acenocoumarol',
            description: 'The risk or severity of bleeding can be increased when Enoxaparin is combined with Acenocoumarol.',
            severity: InteractionSeverity.high,
          ),
        ],
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
        detailedInteractions: [
          DrugInteraction(
            interactingDrugId: 'abacavir',
            interactingDrugName: 'Abacavir',
            description: 'Abacavir may decrease the excretion rate of Rivaroxaban which could result in a higher serum level.',
            severity: InteractionSeverity.moderate,
          ),
          DrugInteraction(
            interactingDrugId: 'abametapir',
            interactingDrugName: 'Abametapir',
            description: 'The serum concentration of Rivaroxaban can be increased when it is combined with Abametapir.',
            severity: InteractionSeverity.moderate,
          ),
          DrugInteraction(
            interactingDrugId: 'abatacept',
            interactingDrugName: 'Abatacept',
            description: 'The metabolism of Rivaroxaban can be increased when combined with Abatacept.',
            severity: InteractionSeverity.moderate,
          ),
          DrugInteraction(
            interactingDrugId: 'abciximab',
            interactingDrugName: 'Abciximab',
            description: 'Abciximab may increase the anticoagulant activities of Rivaroxaban.',
            severity: InteractionSeverity.high,
          ),
          DrugInteraction(
            interactingDrugId: 'abemaciclib',
            interactingDrugName: 'Abemaciclib',
            description: 'Abemaciclib may decrease the excretion rate of Rivaroxaban which could result in a higher serum level.',
            severity: InteractionSeverity.moderate,
          ),
        ],
      ),
      Drug(
        id: 'apixaban',
        name: 'Apixaban (Eliquis)',
        genericName: 'Apixaban',
        category: DrugCategory.anticoagulant,
        isHighAlert: true,
        commonDosages: ['2.5mg', '5mg'],
        interactions: ['aspirin', 'ketoconazole', 'rifampin'],
        warnings: 'Risk of bleeding. Monitor renal function.',
      ),

      // HIGH-ALERT: ANTIRETROVIRALS
      Drug(
        id: 'efavirenz',
        name: 'Efavirenz (Sustiva)',
        genericName: 'Efavirenz',
        category: DrugCategory.antiretroviral,
        isHighAlert: true,
        commonDosages: ['600mg'],
        interactions: ['rifampin', 'warfarin', 'midazolam'],
        warnings: 'Take on empty stomach. May cause CNS effects.',
      ),
      Drug(
        id: 'tenofovir',
        name: 'Tenofovir (Viread)',
        genericName: 'Tenofovir Disoproxil',
        category: DrugCategory.antiretroviral,
        isHighAlert: true,
        commonDosages: ['300mg'],
        interactions: ['didanosine', 'atazanavir'],
        warnings: 'Monitor renal function. Risk of bone loss.',
      ),
      Drug(
        id: 'dolutegravir',
        name: 'Dolutegravir (Tivicay)',
        genericName: 'Dolutegravir',
        category: DrugCategory.antiretroviral,
        isHighAlert: true,
        commonDosages: ['50mg'],
        interactions: ['rifampin', 'calcium', 'iron'],
        warnings: 'Take 2 hours before or 6 hours after antacids.',
      ),

      // HIGH-ALERT: ANTI-DIABETICS
      Drug(
        id: 'insulin_regular',
        name: 'Insulin Regular',
        genericName: 'Human Insulin',
        category: DrugCategory.antidiabetic,
        isHighAlert: true,
        commonDosages: ['Variable units'],
        interactions: ['beta_blockers', 'corticosteroids'],
        warnings: 'Risk of hypoglycemia. Monitor blood glucose.',
      ),
      Drug(
        id: 'metformin',
        name: 'Metformin (Glucophage)',
        genericName: 'Metformin HCl',
        category: DrugCategory.antidiabetic,
        isHighAlert: true,
        commonDosages: ['500mg', '850mg', '1000mg'],
        interactions: ['contrast_dye', 'alcohol'],
        warnings: 'Risk of lactic acidosis. Monitor renal function.',
      ),
      Drug(
        id: 'glimepiride',
        name: 'Glimepiride (Amaryl)',
        genericName: 'Glimepiride',
        category: DrugCategory.antidiabetic,
        isHighAlert: true,
        commonDosages: ['1mg', '2mg', '4mg'],
        interactions: ['warfarin', 'beta_blockers'],
        warnings: 'Risk of hypoglycemia. Take with breakfast.',
      ),

      // ANTIBIOTICS
      Drug(
        id: 'amoxicillin',
        name: 'Amoxicillin',
        genericName: 'Amoxicillin',
        category: DrugCategory.antibiotic,
        isHighAlert: false,
        commonDosages: ['250mg', '500mg', '875mg'],
        interactions: ['warfarin', 'methotrexate'],
        warnings: 'Complete full course. Check for penicillin allergy.',
      ),
      Drug(
        id: 'azithromycin',
        name: 'Azithromycin (Zithromax)',
        genericName: 'Azithromycin',
        category: DrugCategory.antibiotic,
        isHighAlert: false,
        commonDosages: ['250mg', '500mg'],
        interactions: ['warfarin', 'digoxin'],
        warnings: 'May prolong QT interval. Take on empty stomach.',
      ),
      Drug(
        id: 'ciprofloxacin',
        name: 'Ciprofloxacin (Cipro)',
        genericName: 'Ciprofloxacin',
        category: DrugCategory.antibiotic,
        isHighAlert: false,
        commonDosages: ['250mg', '500mg', '750mg'],
        interactions: ['antacids', 'warfarin', 'theophylline'],
        warnings: 'Take 2 hours before or 6 hours after antacids.',
      ),

      // ANTIHYPERTENSIVES
      Drug(
        id: 'amlodipine',
        name: 'Amlodipine (Norvasc)',
        genericName: 'Amlodipine Besylate',
        category: DrugCategory.antihypertensive,
        isHighAlert: false,
        commonDosages: ['2.5mg', '5mg', '10mg'],
        interactions: ['simvastatin', 'grapefruit'],
        warnings: 'May cause ankle swelling. Monitor blood pressure.',
      ),
      Drug(
        id: 'lisinopril',
        name: 'Lisinopril (Prinivil)',
        genericName: 'Lisinopril',
        category: DrugCategory.antihypertensive,
        isHighAlert: false,
        commonDosages: ['5mg', '10mg', '20mg', '40mg'],
        interactions: ['potassium', 'nsaids'],
        warnings: 'Monitor potassium levels. May cause dry cough.',
      ),
      Drug(
        id: 'hydrochlorothiazide',
        name: 'Hydrochlorothiazide (HCTZ)',
        genericName: 'Hydrochlorothiazide',
        category: DrugCategory.antihypertensive,
        isHighAlert: false,
        commonDosages: ['12.5mg', '25mg', '50mg'],
        interactions: ['lithium', 'digoxin'],
        warnings: 'May cause electrolyte imbalance. Monitor potassium.',
      ),

      // ANTACIDS (Original category)
      Drug(
        id: 'aluminium_hydroxide',
        name: 'Aluminium Hydroxide',
        genericName: 'Aluminium Hydroxide',
        category: DrugCategory.antacid,
        isHighAlert: false,
        commonDosages: ['320mg', '600mg'],
        interactions: ['ciprofloxacin', 'tetracycline', 'iron'],
        warnings: 'May cause constipation. Take 2 hours apart from other medications.',
      ),
      Drug(
        id: 'calcium_carbonate',
        name: 'Calcium Carbonate (Tums)',
        genericName: 'Calcium Carbonate',
        category: DrugCategory.antacid,
        isHighAlert: false,
        commonDosages: ['500mg', '750mg', '1000mg'],
        interactions: ['tetracycline', 'levothyroxine', 'iron'],
        warnings: 'May cause constipation. Limit use with kidney disease.',
      ),
      Drug(
        id: 'omeprazole',
        name: 'Omeprazole (Prilosec)',
        genericName: 'Omeprazole',
        category: DrugCategory.antacid,
        isHighAlert: false,
        commonDosages: ['20mg', '40mg'],
        interactions: ['clopidogrel', 'warfarin', 'methotrexate'],
        warnings: 'Take 30 minutes before meals. Long-term use may affect bone density.',
      ),

      // ANALGESICS
      Drug(
        id: 'ibuprofen',
        name: 'Ibuprofen (Advil)',
        genericName: 'Ibuprofen',
        category: DrugCategory.analgesic,
        isHighAlert: false,
        commonDosages: ['200mg', '400mg', '600mg', '800mg'],
        interactions: ['warfarin', 'aspirin', 'lisinopril'],
        warnings: 'Take with food. Risk of GI bleeding with long-term use.',
      ),
      Drug(
        id: 'acetaminophen',
        name: 'Acetaminophen (Tylenol)',
        genericName: 'Acetaminophen',
        category: DrugCategory.analgesic,
        isHighAlert: false,
        commonDosages: ['325mg', '500mg', '650mg'],
        interactions: ['warfarin', 'alcohol'],
        warnings: 'Do not exceed 4000mg per day. Risk of liver damage.',
      ),

      // STATINS
      Drug(
        id: 'atorvastatin',
        name: 'Atorvastatin (Lipitor)',
        genericName: 'Atorvastatin Calcium',
        category: DrugCategory.statin,
        isHighAlert: false,
        commonDosages: ['10mg', '20mg', '40mg', '80mg'],
        interactions: ['grapefruit', 'clarithromycin', 'gemfibrozil'],
        warnings: 'Monitor liver function. May cause muscle pain.',
      ),
      Drug(
        id: 'simvastatin',
        name: 'Simvastatin (Zocor)',
        genericName: 'Simvastatin',
        category: DrugCategory.statin,
        isHighAlert: false,
        commonDosages: ['5mg', '10mg', '20mg', '40mg'],
        interactions: ['grapefruit', 'amlodipine', 'diltiazem'],
        warnings: 'Take in evening. Avoid grapefruit juice.',
      ),

      // ANTIDEPRESSANTS
      Drug(
        id: 'sertraline',
        name: 'Sertraline (Zoloft)',
        genericName: 'Sertraline HCl',
        category: DrugCategory.antidepressant,
        isHighAlert: false,
        commonDosages: ['25mg', '50mg', '100mg'],
        interactions: ['warfarin', 'nsaids', 'tramadol'],
        warnings: 'May take 4-6 weeks for full effect. Do not stop abruptly.',
      ),
      Drug(
        id: 'fluoxetine',
        name: 'Fluoxetine (Prozac)',
        genericName: 'Fluoxetine HCl',
        category: DrugCategory.antidepressant,
        isHighAlert: false,
        commonDosages: ['10mg', '20mg', '40mg'],
        interactions: ['warfarin', 'tramadol', 'aspirin'],
        warnings: 'May cause insomnia. Take in morning.',
      ),

      // ANTIMALARIALS
      Drug(
        id: 'artemether_lumefantrine',
        name: 'Artemether/Lumefantrine (Coartem)',
        genericName: 'Artemether/Lumefantrine',
        category: DrugCategory.antimalarial,
        isHighAlert: false,
        commonDosages: ['20mg/120mg'],
        interactions: ['efavirenz', 'rifampin', 'ketoconazole'],
        warnings: 'Take with fatty food. Complete full course.',
      ),
      Drug(
        id: 'quinine',
        name: 'Quinine Sulfate',
        genericName: 'Quinine Sulfate',
        category: DrugCategory.antimalarial,
        isHighAlert: false,
        commonDosages: ['300mg', '600mg'],
        interactions: ['warfarin', 'digoxin', 'mefloquine'],
        warnings: 'May cause cinchonism. Monitor for tinnitus.',
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
