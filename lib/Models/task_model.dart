import 'package:cloud_firestore/cloud_firestore.dart';

enum Status { open, assigned, completed, cancelled }

class TaskModel {
  final String id;
  final String seekerId;
  final String title;
  final String description;
  final String categoryId;
  final String location;
  final double price;
  final Status status;
  final DateTime createdAt;
  final DateTime deadline;
  final double? latitude;
  final double? longitude;
  final String? heroId;
  final DateTime? assignedAt;
  final DateTime? completedAt;

  TaskModel({
    required this.id,
    required this.seekerId,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.location,
    required this.price,
    required this.status,
    required this.createdAt,
    required this.deadline,
    this.latitude,
    this.longitude,
    this.heroId,
    this.assignedAt,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'seekerId': seekerId,
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'location': location,
      'price': price,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'deadline': Timestamp.fromDate(deadline),
      'latitude': latitude,
      'longitude': longitude,
      'heroId': heroId,
    };
  }

  factory TaskModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return TaskModel(
      id: doc.id,
      seekerId: data['seekerId']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      categoryId: data['categoryId']?.toString() ?? '',
      location: data['location']?.toString() ?? '',
      price: (data['price'] ?? 0).toDouble(),
      status: Status.values.firstWhere(
        (s) => s.name == (data['status']?.toString().toLowerCase() ?? 'open'),
        orElse: () => Status.open,
      ),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      deadline: data['deadline'] != null
          ? (data['deadline'] as Timestamp).toDate()
          : DateTime.now(),
      latitude: data['latitude'] != null
          ? (data['latitude'] as num).toDouble()
          : null,
      longitude: data['longitude'] != null
          ? (data['longitude'] as num).toDouble()
          : null,
      heroId: data['heroId']?.toString(),
      assignedAt: data['assignedAt'] != null
          ? (data['assignedAt'] as Timestamp).toDate()
          : null,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
    );
  }
}
