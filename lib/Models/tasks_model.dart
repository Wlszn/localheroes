enum Status { open, assigned, completed, cancelled }

class TasksModel {
  final int taskId;
  final int seekerId;
  final int categoryId;
  final String title;
  final String description;
  final String location;
  final double price;
  final Status status;
  final DateTime createdAt;

  TasksModel({
    required this.taskId,
    required this.seekerId,
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
    return 'TasksModel{taskId: $taskId, seekerId: $seekerId, categoryId: $categoryId, title: $title, description: $description, location: $location, price: $price, status: $status, createdAt: $createdAt}';
  }
}
