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
  final List<String> interactions;
  final String warnings;
  final String? description;

  Drug({
    required this.id,
    required this.name,
    required this.genericName,
    required this.category,
    required this.isHighAlert,
    required this.commonDosages,
    required this.interactions,
    required this.warnings,
    this.description,
  });

  factory Drug.fromJson(Map<String, dynamic> json) {
    return Drug(
      id: json['id'],
      name: json['name'],
      genericName: json['genericName'] ?? json['name'],
      category: DrugCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => DrugCategory.other,
      ),
      isHighAlert: json['isHighAlert'] ?? false,
      commonDosages: List<String>.from(json['commonDosages'] ?? []),
      interactions: List<String>.from(json['interactions'] ?? []),
      warnings: json['warnings'] ?? '',
      description: json['description'],
    );
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
      'warnings': warnings,
      'description': description,
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
