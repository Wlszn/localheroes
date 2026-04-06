class PaymentModel {
  final int paymentId;
  final int userId;
  final int taskId;
  final double amount;
  final String status;

  PaymentModel({
    required this.paymentId,
    required this.userId,
    required this.taskId,
    required this.amount,
    required this.status,
  });

  @override
  String toString() {
    return 'PaymentModel{paymentId: $paymentId, userId: $userId, taskId: $taskId, amount: $amount, status: $status}';
  }
}
