import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fp_imk/screens/auth/login.dart';
import 'package:fp_imk/screens/profile/edit_profile_screen.dart';
import 'package:fp_imk/db/firestore.dart'; // Import FirestoreService
import 'package:cloud_firestore/cloud_firestore.dart'; // For QuerySnapshot
import 'package:fp_imk/screens/profile/app_settings_screen.dart'; // Import AppSettingsScreen
import 'package:fp_imk/screens/profile/help_support_screen.dart'; // Import HelpSupportScreen

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // These will be fetched dynamically
  // final String _userName = "Jane EcoWarrior";
  // final String _userEmail = "jane.eco@example.com";
  // final String _profileImageUrl = "https://i.pravatar.cc/150?img=5";

  final int _educationModulesCompleted = 5;
  final String _ecoStatus = "Eco Champion";

  FirestoreService? _firestoreService;

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _firestoreService = FirestoreService(userId: user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF2E7D6E);
    final Color accentColor = const Color(0xFF5DB075); // A lighter green for accents

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: primaryColor,
        elevation: 0, // Flat app bar
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // --- User Info Header ---
          Container(
            width: double.infinity, // Add this line
            padding: const EdgeInsets.all(20.0),
            color: primaryColor,
              child: StreamBuilder<DocumentSnapshot>(
                stream: _firestoreService?.getUserDataStream(), // Assuming you add this method to FirestoreService
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(color: Colors.white);
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white));
                  }
                  final userData = snapshot.data?.data() as Map<String, dynamic>?;
                  final userName = userData?['username'] ?? 'User Name';
                  final userEmail = FirebaseAuth.instance.currentUser?.email ?? 'user@example.com';
                  final profileImageUrl = userData?['profileImageUrl'] ?? 'https://i.pravatar.cc/150?img=5'; // Default placeholder

                  return Column(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white.withOpacity(0.8),
                        backgroundImage: NetworkImage(profileImageUrl),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                          );
                        },
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit Profile'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // --- Eco Status/Summary ---
            // Container(
            //   padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            //   color: Colors.grey[100],
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       Icon(Icons.shield_moon_outlined, color: primaryColor, size: 30),
            //       const SizedBox(width: 10),
            //       Text(
            //         'Status: $_ecoStatus',
            //         style: TextStyle(
            //           fontSize: 18,
            //           fontWeight: FontWeight.w600,
            //           color: primaryColor,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            const SizedBox(height: 20),

            // --- Statistics Section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Your Impact',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 15),
                  StreamBuilder<double>(
                    stream: _firestoreService?.getTotalCarbonFootprint() ?? Stream.value(0.0),
                    builder: (context, snapshot) {
                      final co2Saved = snapshot.data ?? 0.0;
                      return _buildStatCard(
                        context,
                        icon: Icons.eco_outlined,
                        title: 'Carbon Footprint Reduced',
                        value: '${co2Saved.toStringAsFixed(1)} kg CO₂e',
                        iconColor: Colors.green.shade600,
                      );
                    },
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestoreService?.getRecyclingStatsThisMonth() ?? Stream.empty(),
                    builder: (context, snapshot) {
                      final itemsRecycled = snapshot.data?.docs.length ?? 0;
                      return _buildStatCard(
                        context,
                        icon: Icons.recycling_outlined,
                        title: 'Items Recycled',
                        value: '$itemsRecycled items',
                        iconColor: Colors.blue.shade600,
                      );
                    },
                  ),
                  _buildStatCard(
                    context,
                    icon: Icons.school_outlined,
                    title: 'Climate Education',
                    value: '$_educationModulesCompleted Modules Completed',
                    iconColor: Colors.orange.shade600,
                  ),
                  // You can add more stats related to news read, etc.
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Divider(indent: 16, endIndent: 16),
            const SizedBox(height: 10),

            // --- Account Actions ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Account & Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildActionItem(
                    icon: Icons.settings_outlined,
                    title: 'App Settings',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AppSettingsScreen()),
                      );
                    },
                  ),
                  _buildActionItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () {
                      // Logic for Notifications (still unknown)
                    },
                  ),
                  _buildActionItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
                      );
                    },
                  ),
                  _buildActionItem(
                    icon: Icons.info_outline,
                    title: 'About App',
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Ikling',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '© 2024 Ikling. All rights reserved.',
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Text(
                              'Ikling is an application dedicated to helping you track your carbon footprint, recycle, and learn about climate education.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  _buildActionItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    color: Colors.red,
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30), // Extra space at the bottom
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 30, color: iconColor),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColorDark, // Using a darker shade of primary
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    Color? color, // Optional color for icon and text (e.g., for logout)
    required VoidCallback onTap,
  }) {
    final itemColor = color ?? const Color(0xFF2E7D6E); // Default to primaryColor
    return ListTile(
      leading: Icon(icon, color: itemColor),
      title: Text(
        title,
        style: TextStyle(fontSize: 16, color: itemColor, fontWeight: FontWeight.w500),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
    );
  }
}
