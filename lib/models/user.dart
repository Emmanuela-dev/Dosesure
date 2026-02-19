enum UserRole { patient, clinician }

class User {
    User copyWith({
      String? id,
      String? name,
      String? email,
      UserRole? role,
      String? doctorId,
      String? notes,
    }) {
      return User(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        role: role ?? this.role,
        doctorId: doctorId ?? this.doctorId,
        notes: notes ?? this.notes,
      );
    }
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? doctorId; // For patients to link to their doctor
  final String? notes; // Clinician notes

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.doctorId,
    this.notes,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? 'User',
      email: json['email'] ?? '',
      role: UserRole.values[json['role'] ?? 0],
      doctorId: json['doctorId'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.index,
      'doctorId': doctorId,
      'notes': notes,
    };
  }
}