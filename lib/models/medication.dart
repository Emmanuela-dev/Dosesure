class Medication {
  final String id;
  final String name;
  final String dosage;
  final String frequency; // e.g., "Once daily", "Twice daily"
  final List<String> times; // List of times like ["08:00", "20:00"]
  final String instructions;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.times,
    required this.instructions,
    required this.startDate,
    this.endDate,
    this.isActive = true,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      name: json['name'],
      dosage: json['dosage'],
      frequency: json['frequency'],
      times: List<String>.from(json['times']),
      instructions: json['instructions'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'times': times,
      'instructions': instructions,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
    };
  }
}