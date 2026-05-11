import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/user_model.dart';

class UserController {
  final CollectionReference users =
  FirebaseFirestore.instance.collection('users');

  // ---------------- COUNT METHODS ----------------

  Future<int> countAllUsers() async {
    final snapshot = await users.get();
    return snapshot.size;
  }

  Future<int> countActiveHeroes() async {
    final snapshot = await users
        .where('role', isEqualTo: Role.hero.name)
        .where('isVerifiedHero', isEqualTo: true)
        .get();

    return snapshot.size;
  }

  // ---------------- GET LISTS ----------------

  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await users.get();

    return snapshot.docs
        .map((doc) => UserModel.fromDocument(doc))
        .toList();
  }

  Future<List<UserModel>> getPendingHeroVerifications() async {
    final snapshot = await users
        .where('role', isEqualTo: Role.hero.name)
        .where('isVerifiedHero', isEqualTo: false)
        .get();

    return snapshot.docs
        .map((doc) => UserModel.fromDocument(doc))
        .toList();
  }

  // ---------------- APPROVE / REJECT ----------------

  Future<void> approveHero(String uid) async {
    await users.doc(uid).update({
      'isVerifiedHero': true,
      'verifiedAt': Timestamp.now(),
    });
  }

  Future<void> rejectHero(String uid) async {
    await users.doc(uid).update({
      'isVerifiedHero': false,
      'rejectedAt': Timestamp.now(),
    });
  }
}
