class DoseIntake {
  final String id;
  final String medicationId;
  final String medicationName;
  final DateTime takenAt;
  final String scheduledTime;
  final DateTime nextDueTime;
  final String? photoProofUrl;
  final bool isVerified;

  DoseIntake({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.takenAt,
    required this.scheduledTime,
    required this.nextDueTime,
    this.photoProofUrl,
    this.isVerified = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'medicationName': medicationName,
      'takenAt': takenAt.toIso8601String(),
      'scheduledTime': scheduledTime,
      'nextDueTime': nextDueTime.toIso8601String(),
      'photoProofUrl': photoProofUrl,
      'isVerified': isVerified,
    };
  }

  factory DoseIntake.fromJson(Map<String, dynamic> json) {
    return DoseIntake(
      id: json['id'],
      medicationId: json['medicationId'],
      medicationName: json['medicationName'],
      takenAt: DateTime.parse(json['takenAt']),
      scheduledTime: json['scheduledTime'],
      nextDueTime: DateTime.parse(json['nextDueTime']),
      photoProofUrl: json['photoProofUrl'],
      isVerified: json['isVerified'] ?? false,
    );
  }
}
