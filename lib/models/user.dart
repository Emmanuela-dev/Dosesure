enum UserRole { patient, clinician }

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? doctorId; // For patients to link to their doctor

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.doctorId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: UserRole.values[json['role']],
      doctorId: json['doctorId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.index,
      'doctorId': doctorId,
    };
  }
}