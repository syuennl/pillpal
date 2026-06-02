class User {
  final String id;
  final String name;
  final String phone;
  final String email; // for auth or caregiver invites

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
  });
}
