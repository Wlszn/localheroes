enum Status { pending, accepted, rejected, completed }

class TaskAssignmentsModel {
  final int assignmentId;
  final int heroId;
  final int taskId;
  final Status status;
  final DateTime assignedAt;

  TaskAssignmentsModel({
    required this.assignmentId,
    required this.heroId,
    required this.taskId,
    required this.status,
    required this.assignedAt,
  });

  @override
  String toString() {
    return 'TaskAssignmentsModel{assignmentId: $assignmentId, heroId: $heroId, taskId: $taskId, status: $status, assignedAt: $assignedAt}';
  }
}
