import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference userFootprintLogs =
      FirebaseFirestore.instance.collection('user_footprint_logs');

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

  Future<void> updateUserFootprintLog({
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await userFootprintLogs.doc(docId).update(data);
  }

  Future<void> deleteUserFootprintLog(String docId) async {
    await userFootprintLogs.doc(docId).delete();
  }


  // Collection for recycle logs

  final CollectionReference recycleLogs =
      FirebaseFirestore.instance.collection('recycle_logs');

  Future<void> addRecycleLog({
    required String userId,
    required String location,
    required String description,
    String? imageUrl,
    required DateTime timestamp,
  }) async {
    await recycleLogs.add({
      'userId': userId,
      'location': location,
      'description': description,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
    });
  }

  Future<QuerySnapshot> getRecycleLogs({required String userId}) {
    return recycleLogs
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();
  }

  Future<void> deleteRecycleLog(String docId) async {
    await recycleLogs.doc(docId).delete();
  }
}