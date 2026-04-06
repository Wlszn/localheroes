class AdminLogsModel {
  final int logId;
  final int userId;
  final String action;
  final String targetUser;
  final String description;
  final DateTime date;

  AdminLogsModel({
    required this.logId,
    required this.userId,
    required this.action,
    required this.targetUser,
    required this.description,
    required this.date,
  });

  @override
  String toString() {
    return 'AdminLogsModel{logId: $logId, userId: $userId, action: $action, targetUser: $targetUser, description: $description, date: $date}';
  }
}
