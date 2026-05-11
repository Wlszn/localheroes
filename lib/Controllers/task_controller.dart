import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/task_model.dart';

// Handles creation, reading, accepting, and releasing tasks
class TaskController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<TaskModel>> getMyTasks() {
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
              .map((doc) => TaskModel.fromDocument(doc))
              .toList();
        });
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

    if (user == null) {
      throw Exception('No logged in user found');
    }

    final task = TaskModel(
      id: '',
      seekerId: user.uid,
      heroId: null,
      title: title,
      description: description,
      categoryId: categoryId,
      location: location,
      price: price,
      status: Status.open,
      createdAt: DateTime.now(),
      deadline: deadline,
      assignedAt: null,
      latitude: latitude,
      longitude: longitude,
    );

    await _firestore.collection('tasks').add(task.toMap());
  }

  Stream<List<TaskModel>> getAvailableTasks() {
    return _firestore
        .collection('tasks')
        .where('status', isEqualTo: Status.open.name)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TaskModel.fromDocument(doc))
              .toList();
        });
  }

  Stream<List<TaskModel>> getMyAssignedHeroTasks() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value([]);

    }
    return _firestore
        .collection('tasks')
        .where('heroId', isEqualTo: user.uid)
        .where('status', isEqualTo: Status.assigned.name)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TaskModel.fromDocument(doc))
              .toList();
        });
  }

  Future<void> acceptTask(String taskId) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No logged in hero found');
    }

    final taskRef = _firestore.collection('tasks').doc(taskId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(taskRef);

      if (!snapshot.exists) {
        throw Exception('Task does not exist');
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final currentStatus = data['status']?.toString();

      if (currentStatus != Status.open.name) {
        throw Exception('This task has already been accepted');
      }

      transaction.update(taskRef, {
        'status': Status.assigned.name,
        'heroId': user.uid,
        'assignedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> releaseTask(String taskId) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No logged in hero found');
    }

    final taskRef = _firestore.collection('tasks').doc(taskId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(taskRef);

      if (!snapshot.exists) {
        throw Exception('Task does not exist');
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final currentHeroId = data['heroId']?.toString();

      if (currentHeroId != user.uid) {
        throw Exception('You cannot release a task assigned to another hero');
      }

      transaction.update(taskRef, {
        'status': Status.open.name,
        'heroId': FieldValue.delete(),
        'assignedAt': FieldValue.delete(),
      });
    });
  }

  Future<int> countCompletedTasks() async {
    final snapshot = await _firestore
        .collection('tasks')
        .where('status', isEqualTo: Status.completed.name)
        .get();

    return snapshot.size;
  }
}
