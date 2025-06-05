import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final String userId;
  FirestoreService({required this.userId});

  Future<void> addCarbonEntry(Map<String, dynamic> entryData) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('carbon_entries')
        .add(entryData);
  }

  Stream<List<Map<String, dynamic>>> getRecentCarbonEntries({int limit = 5}) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('carbon_entries')
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<double> getTotalCarbonFootprint() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('carbon_entries')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .snapshots()
        .map((snapshot) {
      double total = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['co2'] != null) {
          total += (data['co2'] as num).toDouble();
        }
      }
      return total;
    });
  }
}