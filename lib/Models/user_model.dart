import 'package:cloud_firestore/cloud_firestore.dart';

enum Role { seeker, hero, admin }

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final Role role;
  final bool isApproved;
  final DateTime createdAt;

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.isApproved,
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
      'isApproved': isApproved,
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
      isApproved: map['isApproved'] ?? false,
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
      isApproved: isVerifiedHero ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserModel{userId: $uid, name: $name, email: $email, phone: $phone, role: $role, isApproved: $isApproved, createdAt: $createdAt}';
  }
}
