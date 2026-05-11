import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentController {
  final CollectionReference payments =
  FirebaseFirestore.instance.collection('payments');

  Future<double> getTotalRevenue() async {
    final snapshot =
    await payments.where('status', isEqualTo: 'paid').get();

    double total = 0;

    for (var doc in snapshot.docs) {
      total += (doc['amount'] as num).toDouble();
    }

    return total;
  }
}
