enum Status { pending, completed, failed }

class PaymentsModel {
  final int paymentId;
  final int payerId;
  final int receiverId;
  final int taskId;
  final double amount;
  final double tip;
  final Status status;
  final DateTime paidAt;

  PaymentsModel({
    required this.paymentId,
    required this.payerId,
    required this.receiverId,
    required this.taskId,
    required this.amount,
    required this.tip,
    required this.status,
    required this.paidAt,
  });

  @override
  String toString() {
    return 'PaymentsModel{paymentId: $paymentId, payerId: $payerId, receiverId: $receiverId, taskId: $taskId, amount: $amount, tip: $tip, status: $status, paidAt: $paidAt}';
  }
}
