class DoseLog {
  final String id;
  final String medicationId;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final bool taken;
  final String? notes;
  final String? photoProofUrl;
  final bool isVerified;

  DoseLog({
    required this.id,
    required this.medicationId,
    required this.scheduledTime,
    this.takenTime,
    this.taken = false,
    this.notes,
    this.photoProofUrl,
    this.isVerified = false,
  });

  factory DoseLog.fromJson(Map<String, dynamic> json) {
    return DoseLog(
      id: json['id'],
      medicationId: json['medicationId'],
      scheduledTime: DateTime.parse(json['scheduledTime']),
      takenTime: json['takenTime'] != null ? DateTime.parse(json['takenTime']) : null,
      taken: json['taken'] ?? false,
      notes: json['notes'],
      photoProofUrl: json['photoProofUrl'],
      isVerified: json['isVerified'] ?? false,
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
      'photoProofUrl': photoProofUrl,
      'isVerified': isVerified,
    };
  }
}