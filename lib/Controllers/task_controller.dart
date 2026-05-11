import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/task_model.dart';

class TaskController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // ── Seeker ────────────────────────────────────────────────────────────────

  Stream<List<TaskModel>> getMyTasks() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('tasks')
        .where('seekerId', isEqualTo: user.uid)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TaskModel.fromDocument(doc)).toList(),
        );
  }

  Future<void> createTask({
    required String title,
    required String description,
    required String categoryId,
    required String location,
    required double price,
    required DateTime deadline,
    double? latitude,
    double? longitude,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No logged in user found');

    final task = TaskModel(
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
      latitude: latitude,
      longitude: longitude,
    );

    await _firestore.collection('tasks').add(task.toMap());
  }

  // ── Hero ──────────────────────────────────────────────────────────────────

  Stream<List<TaskModel>> getAvailableTasks() {
    return _firestore
        .collection('tasks')
        .where('status', isEqualTo: Status.open.name)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TaskModel.fromDocument(doc)).toList(),
        );
  }

  // Tasks the current hero has accepted (assigned to them)
  Stream<List<TaskModel>> getHeroAssignedTasks() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('tasks')
        .where('heroId', isEqualTo: user.uid)
        .where('status', isEqualTo: Status.assigned.name)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TaskModel.fromDocument(doc)).toList(),
        );
  }

  // Gets both available and accepted tasks for the hero map
  Stream<List<TaskModel>> getMapTasks() {
    return _firestore
        .collection('tasks')
        .where('status', whereIn: [
      Status.open.name,
      Status.assigned.name,
    ])
        .snapshots()
        .map(
          (snapshot) =>
          snapshot.docs.map((doc) => TaskModel.fromDocument(doc)).toList(),
    );
  }

  // All tasks ever completed by this hero (for income history)
  Stream<List<TaskModel>> getHeroCompletedTasks() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('tasks')
        .where('heroId', isEqualTo: user.uid)
        .where('status', isEqualTo: Status.completed.name)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TaskModel.fromDocument(doc)).toList(),
        );
  }

  // Hero accepts an open task → status becomes assigned
  Future<void> acceptTask(String taskId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No logged in user found');

    await _firestore.collection('tasks').doc(taskId).update({
      'status': Status.assigned.name,
      'heroId': user.uid,
      'assignedAt': Timestamp.now(),
    });
  }

  // Hero releases a task they can no longer do → back to open
  Future<void> releaseTask(String taskId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No logged in user found');

    await _firestore.collection('tasks').doc(taskId).update({
      'status': Status.open.name,
      'heroId': null,
      'assignedAt': null,
    });
  }

  // Hero marks their assigned task as completed
  Future<void> completeTask(String taskId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No logged in user found');

    await _firestore.collection('tasks').doc(taskId).update({
      'status': Status.completed.name,
      'completedAt': Timestamp.now(),
    });
  }

  // ── Admin / shared ────────────────────────────────────────────────────────

  Future<int> countCompletedTasks() async {
    final snapshot = await _firestore
        .collection('tasks')
        .where('status', isEqualTo: Status.completed.name)
        .get();
    return snapshot.size;
  }
}
