import 'drug_interaction.dart';

enum DrugCategory {
  anticoagulant,
  antiretroviral,
  antidiabetic,
  antibiotic,
  antihypertensive,
  antacid,
  analgesic,
  statin,
  antidepressant,
  antimalarial,
  other,
}

class Drug {
  final String id;
  final String name;
  final String genericName;
  final DrugCategory category;
  final bool isHighAlert;
  final List<String> commonDosages;
  final List<String> interactions; // Legacy field for simple interactions
  final List<DrugInteraction> detailedInteractions; // New field for detailed interactions
  final String warnings;
  final String? description;
  final String? indications;
  final String? use;
  final List<String>? brandNames;

  Drug({
    required this.id,
    required this.name,
    required this.genericName,
    required this.category,
    required this.isHighAlert,
    required this.commonDosages,
    required this.interactions,
    this.detailedInteractions = const [],
    required this.warnings,
    this.description,
    this.indications,
    this.use,
    this.brandNames,
  });

  factory Drug.fromJson(Map<String, dynamic> json) {
    try {
      // Ensure all required fields are present and not null
      final id = json['id'];
      final name = json['name'];
      final category = json['category'];
      
      if (id == null) throw 'Missing required field: id';
      if (name == null) throw 'Missing required field: name';
      if (category == null) throw 'Missing required field: category';
      
      // Parse detailed interactions
      List<DrugInteraction> detailedInteractions = [];
      if (json['detailedInteractions'] != null) {
        detailedInteractions = (json['detailedInteractions'] as List<dynamic>)
            .map((e) => DrugInteraction.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      
      return Drug(
        id: id.toString(),
        name: name.toString(),
        genericName: (json['genericName'] ?? name).toString(),
        category: DrugCategory.values.firstWhere(
          (e) => e.name == category.toString(),
          orElse: () => DrugCategory.other,
        ),
        isHighAlert: json['isHighAlert'] == true,
        commonDosages: (json['commonDosages'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        interactions: (json['interactions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        detailedInteractions: detailedInteractions,
        warnings: (json['warnings'] ?? '').toString(),
        description: json['description']?.toString(),
        indications: json['indications']?.toString(),
        use: json['use']?.toString(),
        brandNames: (json['brandNames'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      );
    } catch (e) {
      print('❌ Error in Drug.fromJson: $e');
      print('📋 JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'genericName': genericName,
      'category': category.name,
      'isHighAlert': isHighAlert,
      'commonDosages': commonDosages,
      'interactions': interactions,
      'detailedInteractions': detailedInteractions.map((e) => e.toJson()).toList(),
      'warnings': warnings,
      'description': description,
      'indications': indications,
      'use': use,
      'brandNames': brandNames,
    };
  }

  String get categoryDisplay {
    switch (category) {
      case DrugCategory.anticoagulant:
        return 'Anticoagulant';
      case DrugCategory.antiretroviral:
        return 'Antiretroviral';
      case DrugCategory.antidiabetic:
        return 'Anti-diabetic';
      case DrugCategory.antibiotic:
        return 'Antibiotic';
      case DrugCategory.antihypertensive:
        return 'Antihypertensive';
      case DrugCategory.antacid:
        return 'Antacid/PPI';
      case DrugCategory.analgesic:
        return 'Analgesic';
      case DrugCategory.statin:
        return 'Statin';
      case DrugCategory.antidepressant:
        return 'Antidepressant';
      case DrugCategory.antimalarial:
        return 'Antimalarial';
      case DrugCategory.other:
        return 'Other';
    }
  }
}
