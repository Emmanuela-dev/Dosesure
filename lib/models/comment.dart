class Comment {
  final String id;
  final String userId;
  final String authorName;
  final String targetId;
  final String targetOwnerId;
  final String text;
  final DateTime createdAt;
  final bool isRead;

  Comment({
    required this.id,
    required this.userId,
    required this.authorName,
    required this.targetId,
    required this.targetOwnerId,
    required this.text,
    required this.createdAt,
    this.isRead = false,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      authorName: json['authorName'] ?? 'Unknown',
      targetId: json['targetId'] ?? '',
      targetOwnerId: json['targetOwnerId'] ?? '',
      text: json['text'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'authorName': authorName,
      'targetId': targetId,
      'targetOwnerId': targetOwnerId,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }
}
