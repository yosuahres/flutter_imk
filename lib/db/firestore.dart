import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference userFootprintLogs =
      FirebaseFirestore.instance.collection('user_footprint_logs');

  /// CREATE: Add a new user footprint log
  Future<void> addUserFootprintLog({
    required String userId,
    required String activityTitle,
    required double co2eKg,
    required String category,
    required DateTime date,
  }) async {
    await userFootprintLogs.add({
      'userId': userId,
      'activityTitle': activityTitle,
      'co2e_kg': co2eKg,
      'category': category,
      'date': date,
    });
  }

  /// READ: Fetch user footprint logs for a specific user, optionally from a certain date, and limits the result.
  Future<QuerySnapshot> getUserFootprintLogs({
    required String userId,
    DateTime? from,
    int limit = 5,
  }) {
    Query query = userFootprintLogs.where('userId', isEqualTo: userId);
    if (from != null) {
      query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(from));
    }
    query = query.orderBy('date', descending: true).limit(limit);
    return query.get();
  }

  /// UPDATE: Update a user footprint log by document ID
  Future<void> updateUserFootprintLog({
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await userFootprintLogs.doc(docId).update(data);
  }

  /// DELETE: Delete a user footprint log by document ID
  Future<void> deleteUserFootprintLog(String docId) async {
    await userFootprintLogs.doc(docId).delete();
  }
}