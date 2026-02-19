class Comment {
  final String id;
  final String userId; // Doctor or patient
  final String targetId; // SideEffect or HerbalUse id
  final String text;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.targetId,
    required this.text,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userId: json['userId'],
      targetId: json['targetId'],
      text: json['text'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'targetId': targetId,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
