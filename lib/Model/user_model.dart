class UserModel {
  final int userId;
  final String username;
  final String password;
  final String email;
  final String phone;
  final String role;
  final bool isVerifiedHero;
  final DateTime createdAt;

  UserModel({
    required this.userId,
    required this.username,
    required this.password,
    required this.email,
    required this.phone,
    required this.role,
    required this.isVerifiedHero,
    required this.createdAt,
  });

  @override
  String toString() {
    return 'UserModel{userId: $userId, username: $username, password: $password, email: $email, phone: $phone, role: $role, isVerifiedHero: $isVerifiedHero, createdAt: $createdAt}';
  }
}
