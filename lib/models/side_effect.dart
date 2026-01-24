class SideEffect {
  final String id;
  final String medicationId;
  final String description;
  final int severity; // 1-5 scale
  final DateTime reportedDate;
  final String? notes;

  SideEffect({
    required this.id,
    required this.medicationId,
    required this.description,
    required this.severity,
    required this.reportedDate,
    this.notes,
  });

  factory SideEffect.fromJson(Map<String, dynamic> json) {
    return SideEffect(
      id: json['id'],
      medicationId: json['medicationId'],
      description: json['description'],
      severity: json['severity'],
      reportedDate: DateTime.parse(json['reportedDate']),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'description': description,
      'severity': severity,
      'reportedDate': reportedDate.toIso8601String(),
      'notes': notes,
    };
  }
}