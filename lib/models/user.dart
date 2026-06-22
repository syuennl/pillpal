class User {
  final String id;
  final String name;
  final String? phone;
  final String email; // for auth or caregiver invites

  User({
    required this.id,
    required this.name,
    this.phone,
    required this.email,
  });

  User copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }
}
