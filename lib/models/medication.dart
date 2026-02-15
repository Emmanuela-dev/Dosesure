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
  final String? prescribedBy; // Doctor/Clinician ID who prescribed this medication
  final String? prescribedByName; // Doctor/Clinician name for display
  final String? patientId; // Patient ID this medication is for

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
    this.prescribedBy,
    this.prescribedByName,
    this.patientId,
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
      prescribedBy: json['prescribedBy'],
      prescribedByName: json['prescribedByName'],
      patientId: json['patientId'],
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
      'prescribedBy': prescribedBy,
      'prescribedByName': prescribedByName,
      'patientId': patientId,
    };
  }
}