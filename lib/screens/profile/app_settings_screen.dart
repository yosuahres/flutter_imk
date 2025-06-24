import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fp_imk/db/firestore.dart';
import 'package:fp_imk/widgets/custom_bottom_nav_bar.dart';
import 'package:fp_imk/screens/home.dart';
import 'package:fp_imk/screens/notification/notification_screen.dart';
import 'package:fp_imk/screens/profile.dart';
import 'package:flutter/services.dart'; // For SystemChrome

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool _isNotificationsEnabled = true;
  late SharedPreferences _prefs;
  FirestoreService? _firestoreService;
  int _selectedIndex = 2; // Settings is the 3rd tab (index 2)

  static const Color _appHeaderColor = Color(0xFF609966);
  static const Color _primaryTextColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _firestoreService = FirestoreService(userId: user.uid);
    }
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _isNotificationsEnabled = _prefs.getBool('isNotificationsEnabled') ?? true;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    await _prefs.setBool(key, value);
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
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
        break;
      case 2:
        // Already on Settings, do nothing
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
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      _buildHeader(context, displayUserName),
                      Expanded(
                        child: ListView(
                          children: [
                            SwitchListTile(
                              title: Text(
                                'Enable Notifications',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              value: _isNotificationsEnabled,
                              onChanged: (bool value) {
                                setState(() {
                                  _isNotificationsEnabled = value;
                                });
                                _saveSetting('isNotificationsEnabled', value);
                              },
                              secondary: const Icon(Icons.notifications),
                            ),
                            ListTile(
                              title: Text(
                                'Data Usage',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              subtitle: Text(
                                'View information about your data consumption',
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey[400]
                                      : Colors.black54,
                                ),
                              ),
                              leading: const Icon(Icons.data_usage),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Data Usage details coming soon!')),
                                );
                              },
                            ),
                          ],
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
          return const Text('Please log in to view settings.'); // Or navigate to LoginScreen
        }
      },
    );
  }
}
