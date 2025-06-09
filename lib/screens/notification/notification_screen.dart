import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fp_imk/db/firestore.dart';
import 'package:fp_imk/widgets/custom_bottom_nav_bar.dart'; // Import custom nav bar
import 'package:fp_imk/screens/home.dart'; // For navigation
import 'package:fp_imk/screens/profile/app_settings_screen.dart'; // For navigation
import 'package:fp_imk/screens/profile.dart'; // For profile navigation
import 'package:flutter/services.dart'; // For SystemChrome

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  FirestoreService? _firestoreService;
  int _selectedIndex = 1; // Notification is the 2nd tab (index 1)

  static const Color _appHeaderColor = Color(0xFF609966);
  static const Color _primaryTextColor = Colors.white;
  static const Color _scaffoldBgColor = Color(0xFFF0F2F0);

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _firestoreService = FirestoreService(userId: user.uid);
      _firestoreService?.updateLastNotificationViewedTimestamp();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Handle navigation based on index
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
        break;
      case 1:
        // Already on Notification, do nothing
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AppSettingsScreen()));
        break;
    }
  }

  Widget _buildHeader(BuildContext context, String userName) {
    return Container(
      padding: const EdgeInsets.only(top: 16.0 + kToolbarHeight / 3, left: 16.0, right: 16.0, bottom: 16.0),
      color: _appHeaderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end, // Align to end for profile
            children: [
              Text(
                userName,
                style: const TextStyle(color: _primaryTextColor, fontSize: 16),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context, MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: _appHeaderColor.withOpacity(0.8), size: 24,),
                  radius: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: _appHeaderColor,
      statusBarIconBrightness: Brightness.light,
    ));

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (authSnapshot.hasData) {
          return StreamBuilder<DocumentSnapshot>(
            stream: _firestoreService?.getUserDataStream(),
            builder: (context, userDocSnapshot) {
              if (userDocSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (userDocSnapshot.hasError) {
                return Scaffold(
                  body: Center(child: Text('Error: ${userDocSnapshot.error}')),
                );
              }

              final userData = userDocSnapshot.data?.data() as Map<String, dynamic>?;
              final userName = userData?['username'] ?? authSnapshot.data?.displayName ?? authSnapshot.data?.email?.split('@')[0] ?? "User";
              final displayUserName = (userName == "User" && authSnapshot.data?.email == null) ? "None" : userName;

              return Scaffold(
                backgroundColor: _scaffoldBgColor,
                body: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      _buildHeader(context, displayUserName),
                      Expanded(
                        child: _firestoreService == null
                            ? const Center(child: Text('Please log in to view notifications.'))
                            : StreamBuilder<List<Map<String, dynamic>>>(
                                stream: _firestoreService!.getRecentNotifications(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  if (snapshot.hasError) {
                                    return Center(child: Text('Error: ${snapshot.error}'));
                                  }
                                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                    return const Center(child: Text('No new notifications.'));
                                  }

                                  final notifications = snapshot.data!;

                                  return ListView.builder(
                                    padding: const EdgeInsets.all(8.0),
                                    itemCount: notifications.length,
                                    itemBuilder: (context, index) {
                                      final notification = notifications[index];
                                      final message = notification['message'] ?? 'No message';
                                      final timestamp = notification['timestamp'] as Timestamp?;
                                      final formattedTime = timestamp != null
                                          ? _formatTimestamp(timestamp)
                                          : 'Unknown time';

                                      return Card(
                                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                                        elevation: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                message,
                                                style: const TextStyle(fontSize: 16.0),
                                              ),
                                              const SizedBox(height: 4.0),
                                              Text(
                                                formattedTime,
                                                style: TextStyle(
                                                  fontSize: 12.0,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
                bottomNavigationBar: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 8),
                  child: CustomBottomNavBar(
                    selectedIndex: _selectedIndex,
                    onItemTapped: _onItemTapped,
                  ),
                ),
              );
            },
          );
        } else {
          return const Text('Please log in to view notifications.');
        }
      },
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final notificationDate = DateTime(date.year, date.month, date.day);

    if (notificationDate.isAtSameMomentAs(today)) {
      return 'Today at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (notificationDate.isAtSameMomentAs(yesterday)) {
      return 'Yesterday at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }
}
