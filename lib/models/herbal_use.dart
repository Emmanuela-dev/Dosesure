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
    };
  }
}