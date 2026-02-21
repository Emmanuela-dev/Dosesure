class HerbalUse {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final String purpose;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final String? notes;
  final String? localName;
  final String? botanicalGenus;
  final String? photoUrl;
  final String? preparationMethod;
  final String? geographicOrigin;

  HerbalUse({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.purpose,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    this.notes,
    this.localName,
    this.botanicalGenus,
    this.photoUrl,
    this.preparationMethod,
    this.geographicOrigin,
  });

  factory HerbalUse.fromJson(Map<String, dynamic> json) {
    return HerbalUse(
      id: json['id'],
      name: json['name'],
      dosage: json['dosage'],
      frequency: json['frequency'],
      purpose: json['purpose'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      isActive: json['isActive'] ?? true,
      notes: json['notes'],
      localName: json['localName'],
      botanicalGenus: json['botanicalGenus'],
      photoUrl: json['photoUrl'],
      preparationMethod: json['preparationMethod'],
      geographicOrigin: json['geographicOrigin'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'purpose': purpose,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'notes': notes,
      'localName': localName,
      'botanicalGenus': botanicalGenus,
      'photoUrl': photoUrl,
      'preparationMethod': preparationMethod,
      'geographicOrigin': geographicOrigin,
    };
  }
}