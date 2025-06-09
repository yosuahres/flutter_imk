import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // For debugPrint

class FirestoreService {
  final String userId;
  FirestoreService({required this.userId});

  // --- Carbon Tracking Methods ---
  Future<void> addCarbonEntry(Map<String, dynamic> entryData) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('carbon_entries')
        .add(entryData);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'lastActivityTimestamp': FieldValue.serverTimestamp()});
    debugPrint('FirestoreService: Carbon entry added. lastActivityTimestamp updated for user $userId');

    // Add a notification for the new carbon entry
    await addNotification({
      'type': 'carbon_tracking',
      'message': 'New carbon entry added: ${entryData['co2']} kg CO2 on ${entryData['date'] != null ? (entryData['date'] as Timestamp).toDate().toLocal().toString().split(' ')[0] : 'N/A'}.',
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });
    debugPrint('FirestoreService: Notification added for carbon entry.');
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

  // --- User Profile Methods ---
  Stream<DocumentSnapshot> getUserDataStream() {
    return FirebaseFirestore.instance.collection('users').doc(userId).snapshots();
  }

  // --- Notifications Methods ---
  Future<void> addNotification(Map<String, dynamic> notificationData) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add(notificationData);
  }

  Stream<List<Map<String, dynamic>>> getRecentNotifications({int limit = 5}) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true) // Assuming a 'timestamp' field
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data()).toList());
  }

  // --- Recycling Methods ---
  Future<void> addRecycledItem(Map<String, dynamic> itemData) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('recycled_items')
        .add(itemData);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'lastActivityTimestamp': FieldValue.serverTimestamp()});
    debugPrint('FirestoreService: Recycled item added. lastActivityTimestamp updated for user $userId');

    // Add a notification for the new recycled item
    await addNotification({
      'type': 'recycled_item',
      'message': 'New item recycled: ${itemData['itemName']} (${itemData['quantity']}).',
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });
    debugPrint('FirestoreService: Notification added for recycled item.');
  }

  Stream<List<Map<String, dynamic>>> getRecentRecycledItems({int limit = 3}) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('recycled_items')
        .orderBy('dateRecycled', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<QuerySnapshot> getRecyclingStatsThisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('recycled_items')
        .where('dateRecycled', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .snapshots();
  }

  Stream<List<Map<String, dynamic>>> fetchRecentRecycledItems({int limit = 3}) {
  return getRecentRecycledItems(limit: limit);
}

  Future<void> updateLastNotificationViewedTimestamp() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'lastNotificationViewedTimestamp': FieldValue.serverTimestamp()});
    debugPrint('FirestoreService: lastNotificationViewedTimestamp updated for user $userId');
  }

Stream<QuerySnapshot> fetchRecyclingStatsThisMonth() {
  return getRecyclingStatsThisMonth();
}

Future<void> logRecycledItem(Map<String, dynamic> itemData) {
  return addRecycledItem(itemData);
}
}
