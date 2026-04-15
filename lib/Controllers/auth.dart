import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/user_model.dart';

class AuthController {
  //firebase auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //user table in firebase
  final CollectionReference usersCollection = FirebaseFirestore.instance
      .collection('users');

  //Register user
  Future<UserModel?> registerUser({
    required String name,
    required String email,
    required String password,
    required String phone,
    required Role role,
  }) async {
    try {
      //create auth account using the users email and password
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      //get new firebase user
      User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return null;
      }

      //create user model
      UserModel newUser = UserModel(
        uid: firebaseUser.uid,
        name: name,
        email: email,
        phone: phone,
        role: role,
        isVerifiedHero: false,
        createdAt: DateTime.now(),
      );

      //save user to firebase
      await usersCollection.doc(firebaseUser.uid).set(newUser.toMap());

      return newUser;
    } catch (e) {
      throw Exception('Error Registering User: $e');
    }
  }

  //Login user
  Future<UserCredential> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception('Login error: ${e.message}');
    } catch (e) {
      throw Exception('Error Logging in User: $e');
    }
  }

  //Logout user
  Future<void> lopgoutUser() async {
    await _auth.signOut();
  }

  //Get current user logged in
  User? getCurrentFirebaseUser() {
    return _auth.currentUser;
  }

  //Get current user data
  Future<UserModel?> getCurrentUserData() async {
    try {
      User? firebaseUser = _auth.currentUser;

      if (firebaseUser == null) {
        return null;
      }

      DocumentSnapshot doc = await usersCollection.doc(firebaseUser.uid).get();

      if (!doc.exists) {
        return null;
      }

      return UserModel.fromDocument(doc);
    } catch (e) {
      throw Exception('Error getting current user data: $e');
    }
  }

  //Get user by id
  Future<UserModel?> getUserByUid(String uid) async {
    try {
      DocumentSnapshot doc = await usersCollection.doc(uid).get();

      if (!doc.exists) {
        return null;
      }

      return UserModel.fromDocument(doc);
    }
    catch (e) {
      throw Exception('Error getting user by uid: $e');
    }
  }













































}
