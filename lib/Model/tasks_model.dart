class TasksModel {
  final int taskId;
  final int userId;
  final int categoryId;
  final String title;
  final String description;
  final String location;
  final double price;
  final String status;
  final DateTime createdAt;

  TasksModel({
    required this.taskId,
    required this.userId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.location,
    required this.price,
    required this.status,
    required this.createdAt,
  });

  @override
  String toString() {
    return 'TasksModel{taskId: $taskId, userId: $userId, categoryId: $categoryId, title: $title, description: $description, location: $location, price: $price, status: $status, createdAt: $createdAt}';
  }
}
