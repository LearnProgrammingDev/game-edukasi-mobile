class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final int expPoints;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.expPoints,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'] ?? 'student',
      expPoints: json['exp_points'] ?? 0,
    );
  }
}
