import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/task_model.dart';

class TaskController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<JobModel>> getMyJobs() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('tasks')
        .where('seekerId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => JobModel.fromDocument(doc))
              .toList();
        });
  }

  Future<void> createJob({
    required String title,
    required String description,
    required String categoryId,
    required String location,
    required double price,
    required DateTime deadline,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No Logged in user found');
    }

    final job = JobModel(
      id: '',
      seekerId: user.uid,
      title: title,
      description: description,
      categoryId: categoryId,
      location: location,
      price: price,
      status: Status.open,
      createdAt: DateTime.now(),
      deadline: deadline,
    );

    await _firestore.collection('tasks').add(job.toMap());
  }

  Stream<List<JobModel>> getAvailableJobs() {
    return _firestore
        .collection('tasks')
        .where('status', isEqualTo: Status.open.name)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => JobModel.fromDocument(doc)).toList();
    });
  }
}
