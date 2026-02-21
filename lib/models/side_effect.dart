class SideEffect {
  final String id;
  final String medicationId;
  final String description;
  final int severity; // 1-5 scale
  final DateTime reportedDate;
  final String? notes;
  final String triageLevel; // 'emergency', 'urgent', 'routine'
  final bool requiresEmergencyAction;
  final bool clinicianNotified;
  final DateTime? clinicianViewedAt;

  SideEffect({
    required this.id,
    required this.medicationId,
    required this.description,
    required this.severity,
    required this.reportedDate,
    this.notes,
    this.triageLevel = 'routine',
    this.requiresEmergencyAction = false,
    this.clinicianNotified = false,
    this.clinicianViewedAt,
  });

  factory SideEffect.fromJson(Map<String, dynamic> json) {
    return SideEffect(
      id: json['id'],
      medicationId: json['medicationId'],
      description: json['description'],
      severity: json['severity'],
      reportedDate: DateTime.parse(json['reportedDate']),
      notes: json['notes'],
      triageLevel: json['triageLevel'] ?? 'routine',
      requiresEmergencyAction: json['requiresEmergencyAction'] ?? false,
      clinicianNotified: json['clinicianNotified'] ?? false,
      clinicianViewedAt: json['clinicianViewedAt'] != null 
          ? DateTime.parse(json['clinicianViewedAt']) 
          : null,
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
      'triageLevel': triageLevel,
      'requiresEmergencyAction': requiresEmergencyAction,
      'clinicianNotified': clinicianNotified,
      'clinicianViewedAt': clinicianViewedAt?.toIso8601String(),
    };
  }

  SideEffect copyWith({
    DateTime? clinicianViewedAt,
  }) {
    return SideEffect(
      id: id,
      medicationId: medicationId,
      description: description,
      severity: severity,
      reportedDate: reportedDate,
      notes: notes,
      triageLevel: triageLevel,
      requiresEmergencyAction: requiresEmergencyAction,
      clinicianNotified: clinicianNotified,
      clinicianViewedAt: clinicianViewedAt ?? this.clinicianViewedAt,
    );
  }
}