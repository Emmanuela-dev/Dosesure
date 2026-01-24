class DoseLog {
  final String id;
  final String medicationId;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final bool taken;
  final String? notes;

  DoseLog({
    required this.id,
    required this.medicationId,
    required this.scheduledTime,
    this.takenTime,
    this.taken = false,
    this.notes,
  });

  factory DoseLog.fromJson(Map<String, dynamic> json) {
    return DoseLog(
      id: json['id'],
      medicationId: json['medicationId'],
      scheduledTime: DateTime.parse(json['scheduledTime']),
      takenTime: json['takenTime'] != null ? DateTime.parse(json['takenTime']) : null,
      taken: json['taken'] ?? false,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'scheduledTime': scheduledTime.toIso8601String(),
      'takenTime': takenTime?.toIso8601String(),
      'taken': taken,
      'notes': notes,
    };
  }
}