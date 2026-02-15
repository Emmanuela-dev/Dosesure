class Drug {
  final String id;
  final String name;
  final String category;
  final String? description;

  Drug({
    required this.id,
    required this.name,
    required this.category,
    this.description,
  });

  factory Drug.fromJson(Map<String, dynamic> json) {
    return Drug(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
    };
  }
}
