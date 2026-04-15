import 'package:cloud_firestore/cloud_firestore.dart';

enum Role { seeker, hero, admin }

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final Role role;
  final bool isVerifiedHero;
  final DateTime createdAt;

  //CollectionReference users = FirebaseFirestore.instance.collection('users');

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.isVerifiedHero,
    required this.createdAt,
  });

  //save user to firebase
  Map<String, dynamic> toMap() {
    return {
      'userId': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'isVerifiedHero': isVerifiedHero,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  //Read user from firebase
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['userId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: Role.values.firstWhere(
        (role) => role.name == map['role'],
        orElse: () => Role.seeker,
      ),
      isVerifiedHero: map['isVerifiedHero'] ?? false,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap(data);
  }

  //modify user fields
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    Role? role,
    bool? isVerifiedHero,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isVerifiedHero: isVerifiedHero ?? this.isVerifiedHero,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // // Create User
  // Future<void> addUser() async {
  //   if (name.isNotEmpty && password.isNotEmpty && email.isNotEmpty && phone.isNotEmpty) {
  //     await users.add({
  //       'userId': userId,
  //       'name': name,
  //       'password': password,
  //       'email': email,
  //       'phone': phone,
  //       'role': role.name,
  //       'isVerifiedHero': isVerifiedHero,
  //       'createdAt': createdAt,
  //     });
  //   }
  // }
  //
  // // Read all users in real-time (like StreamBuilder)
  // // Stream for real-time read
  // // QuerySnapshot fetches multiple documents
  // Stream<QuerySnapshot> readUsers() {
  //   return users.snapshots();
  // }
  //
  // // Read a single user by document ID
  // // Future for one-time read
  // // DocumentSnapshot fetches one document
  // Future<DocumentSnapshot> readUserById(String id) {
  //   return users.doc(id).get();
  // }
  //
  // // Read users with a filter (example: role = "hero")
  // Future<QuerySnapshot> readUsersByRole(String role) {
  //   return users.where('role', isEqualTo: role).get();
  // }

  @override
  String toString() {
    return 'UserModel{userId: $uid, name: $name, email: $email, phone: $phone, role: $role, isVerifiedHero: $isVerifiedHero, createdAt: $createdAt}';
  }
}
