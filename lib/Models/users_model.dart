import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localheroes/screens/roleScreen.dart';

enum Role { seeker, hero, admin }

class UsersModel {
  final int userId;
  final String name;
  final String password;
  final String email;
  final String phone;
  final Role role;
  final bool isVerifiedHero;
  final DateTime createdAt;

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  UsersModel({
    required this.userId,
    required this.name,
    required this.password,
    required this.email,
    required this.phone,
    required this.role,
    required this.isVerifiedHero,
    required this.createdAt,
  });

  // Create User
  Future<void> addUser() async {
    if (name.isNotEmpty && password.isNotEmpty && email.isNotEmpty && phone.isNotEmpty) {
      await users.add({
        'userId': userId,
        'name': name,
        'password': password,
        'email': email,
        'phone': phone,
        'role': role.name,
        'isVerifiedHero': isVerifiedHero,
        'createdAt': createdAt,
      });
    }
  }

  // Read all users in real-time (like StreamBuilder)
  // Stream for real-time read
  // QuerySnapshot fetches multiple documents
  Stream<QuerySnapshot> readUsers() {
    return users.snapshots();
  }

  // Read a single user by document ID
  // Future for one-time read
  // DocumentSnapshot fetches one document
  Future<DocumentSnapshot> readUserById(String id) {
    return users.doc(id).get();
  }

  // Read users with a filter (example: role = "hero")
  Future<QuerySnapshot> readUsersByRole(String role) {
    return users.where('role', isEqualTo: role).get();
  }


  @override
  String toString() {
    return 'UserModel{userId: $userId, name: $name, password: $password, email: $email, phone: $phone, role: $role, isVerifiedHero: $isVerifiedHero, createdAt: $createdAt}';
  }
}
