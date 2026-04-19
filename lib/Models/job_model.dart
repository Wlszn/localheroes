import 'package:cloud_firestore/cloud_firestore.dart';

class JobModel {
  final String id;
  final String seekerId;
  final String title;
  final String description;
  final String categoryId;
  final String rental;
  final double price;
  final String status;
  final DateTime createdAt;

  JobModel({
    required this.id,
    required this.seekerId,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.rental,
    required this.price,
    required this.status,
    required this.createdAt,
  });

  factory JobModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return JobModel(
      id: doc.id,
      seekerId: data['seekerId']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      categoryId: data['categoryId']?.toString() ?? '',
      rental: data['rental']?.toString() ?? '',
      price: (data['price'] ?? 0).toDouble(),
      status: data['status']?.toString().toLowerCase() ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}