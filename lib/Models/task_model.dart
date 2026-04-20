//Jobs/Tasks for the users

import 'package:cloud_firestore/cloud_firestore.dart';

enum Status { open, assigned, completed, cancelled }

class JobModel {
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

  JobModel({
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
    };
  }

  factory JobModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return JobModel(
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
    );
  }
}