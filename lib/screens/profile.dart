import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  // _RecycleState createState() => _RecycleState(); // Corrected this to match the class name
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Dummy data - replace with actual user data from your state management/backend
  final String _userName = "Jane EcoWarrior";
  final String _userEmail = "jane.eco@example.com";
  final String _profileImageUrl = "https://i.pravatar.cc/150?img=5"; // Placeholder image
  final double _co2Saved = 125.7; // in kg
  final int _itemsRecycled = 88;
  final int _educationModulesCompleted = 5;
  final String _ecoStatus = "Eco Champion";

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
              child: Column(
                children: <Widget>[
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white.withOpacity(0.8),
                    backgroundImage: NetworkImage(_profileImageUrl),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _userName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userEmail,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement edit profile navigation/logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edit Profile Tapped!')),
                      );
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- Eco Status/Summary ---
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              color: Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield_moon_outlined, color: primaryColor, size: 30),
                  const SizedBox(width: 10),
                  Text(
                    'Status: $_ecoStatus',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),

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
                  _buildStatCard(
                    context,
                    icon: Icons.eco_outlined,
                    title: 'Carbon Footprint Reduced',
                    value: '${_co2Saved.toStringAsFixed(1)} kg CO₂e',
                    iconColor: Colors.green.shade600,
                  ),
                  _buildStatCard(
                    context,
                    icon: Icons.recycling_outlined,
                    title: 'Items Recycled',
                    value: '$_itemsRecycled items',
                    iconColor: Colors.blue.shade600,
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
                      // TODO: Navigate to settings screen
                       ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('App Settings Tapped!')),
                      );
                    },
                  ),
                  _buildActionItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () {
                      // TODO: Navigate to notification settings
                       ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notifications Tapped!')),
                      );
                    },
                  ),
                  _buildActionItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      // TODO: Navigate to help screen or show a dialog
                       ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Help & Support Tapped!')),
                      );
                    },
                  ),
                  _buildActionItem(
                    icon: Icons.info_outline,
                    title: 'About App',
                    onTap: () {
                      // TODO: Show about dialog
                       ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('About App Tapped!')),
                      );
                    },
                  ),
                  _buildActionItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    color: Colors.red,
                    onTap: () {
                      // TODO: Implement logout logic
                       ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Logout Tapped!')),
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